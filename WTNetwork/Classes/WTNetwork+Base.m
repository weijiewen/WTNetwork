//
//  WTNetwork+Base.m
//  WTNetwork_Example
//
//  Created by Haoxing on 2020/9/21.
//  Copyright © 2020 txywjw@icloud.com. All rights reserved.
//

#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import <CoreTelephony/CTCarrier.h>

#import <CoreServices/CoreServices.h>

#import <MobileCoreServices/MobileCoreServices.h>

#import <objc/runtime.h>

#import "WTNetwork+Base.h"

#import "WTNetwork+NSCategory.h"

#import "NSURLSessionTask+WTNetwork.h"

@interface WTNetwork (URLSessionDelegate) <NSURLSessionDataDelegate>
@end
@implementation WTNetwork (URLSessionDelegate)

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    dataTask.wtnet_response = (NSHTTPURLResponse *)response;
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    if (task.wtnet_progrees) {
        dispatch_async(dispatch_get_main_queue(), ^{
            double progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
            task.wtnet_progrees(progress);
        });
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [dataTask.wtnet_data appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    NSString *HTTPMethod = task.currentRequest.HTTPMethod;
    NSString *HTTPURL = task.currentRequest.URL.absoluteString;
    NSDictionary *HTTPHeader = task.currentRequest.allHTTPHeaderFields;
    NSDictionary *HTTPParameter = task.wtnet_parameter;
    NSData *HTTPData = task.wtnet_data;
    NSURLRequest *HTTPRequest = task.currentRequest;
    NSHTTPURLResponse *HTTPResponse = task.wtnet_response;
    
    id logResponse = [[NSString alloc] initWithData:HTTPData encoding:NSUTF8StringEncoding];
    id jsonObj = [HTTPData wtnet_toJsonObject];
    if (jsonObj) {
        logResponse = jsonObj;
    }
    NSError *requestError = error;
    if (!requestError) {
        if ([HTTPResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            if (HTTPResponse.statusCode < 400) {
                if ([self.delegate respondsToSelector:@selector(wtnet_didSuccessWithRequest:response:responseData:errorString:)]) {
                    NSString *errorString;
                    jsonObj = [self.delegate wtnet_didSuccessWithRequest:HTTPRequest response:HTTPResponse responseData:HTTPData errorString:&errorString];
                    if (jsonObj) {
                        requestError = nil;
                    }
                    else {
                        requestError = [[NSError alloc] initWithDomain:@"com.haoxing.networkError" code:HTTPResponse.statusCode userInfo:@{@"reson" : @"wtnet_didSuccessWithRequest 代理返回nil", @"title":errorString ? errorString : @"", @"data":logResponse ? logResponse : @""}];
                    }
                }
                else {
                    requestError = nil;
                }
            }
            else {
                requestError = [[NSError alloc] initWithDomain:@"com.haoxing.networkError" code:task.wtnet_response.statusCode userInfo:@{@"localizedString":[NSHTTPURLResponse localizedStringForStatusCode:task.wtnet_response.statusCode],@"data":logResponse}];
            }
        }
        else {
            requestError = [[NSError alloc] initWithDomain:@"com.haoxing.networkError" code:500 userInfo:@{@"title":@"返回数据不是http格式", @"data":logResponse}];
        }
    }
    if (requestError) {
        if (requestError.code == NSURLErrorCancelled) {
            if (!self.showLog) {
                NSLog(@"请求取消 \nmethod: %@ \nurl: %@", HTTPMethod, HTTPURL);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                !task.wtnet_failure ?: task.wtnet_failure(error, jsonObj, @"请求取消");
                task.wtnet_progrees = nil;
                task.wtnet_failure = nil;
                task.wtnet_success = nil;
            });
        }
        else {
            if (!self.showLog) {
                NSLog(@"请求失败 \nmethod: %@ \nurl: %@ \nheader: \n%@ \n\nparameter: \n%@ \n\nerror: %@ \n\nresponse: \n%@", HTTPMethod, HTTPURL, HTTPHeader, HTTPParameter, requestError, logResponse);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *message = @"请求失败";
                if (self.delegate && [self.delegate respondsToSelector:@selector(wtnet_didFailureWithRequest:response:data:error:reloadRequest:)]) {
                    message = [self.delegate wtnet_didFailureWithRequest:HTTPRequest response:HTTPResponse data:HTTPData error:requestError reloadRequest:^{
                        [self request:HTTPRequest parameter:HTTPParameter progrees:task.wtnet_progrees success:task.wtnet_success failure:task.wtnet_failure];
                    }];
                }
                !task.wtnet_failure ?: task.wtnet_failure(requestError, jsonObj, message);
                task.wtnet_progrees = nil;
                task.wtnet_failure = nil;
                task.wtnet_success = nil;
            });
        }
    }
    else {
        if (!self.showLog) {
            NSLog(@"请求成功 \nmethod: %@ \nurl: %@ \nheader: \n%@ \n\nparameter: \n%@ \n\nresponse: \n%@", HTTPMethod, HTTPURL, HTTPHeader, HTTPParameter, logResponse);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            !task.wtnet_success ?: task.wtnet_success(jsonObj ? jsonObj : HTTPData);
            task.wtnet_progrees = nil;
            task.wtnet_failure = nil;
            task.wtnet_success = nil;
        });
    }
}



- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
    else if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate])
    {
        [self.cers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSData * _Nonnull obj, BOOL * _Nonnull stop) {
            CFDataRef inP12Data = (__bridge CFDataRef)obj;
            SecIdentityRef myIdentity;
            
            OSStatus securityError = errSecSuccess;
            CFStringRef password = (__bridge CFStringRef)key;
            const void *keys[] = { kSecImportExportPassphrase };
            const void *values[] = { password };
            CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
            CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
            securityError = SecPKCS12Import(inP12Data, options, &items);
            if (securityError == 0)
            {
                CFDictionaryRef ident = CFArrayGetValueAtIndex(items,0);
                const void *tempIdentity = NULL;
                tempIdentity = CFDictionaryGetValue(ident, kSecImportItemIdentity);
                myIdentity = (SecIdentityRef)tempIdentity;
                
                SecCertificateRef myCertificate;
                SecIdentityCopyCertificate(myIdentity, &myCertificate);
                const void *certs[] = { myCertificate };
                CFArrayRef certsArray =CFArrayCreate(NULL, certs,1,NULL);
                NSURLCredential *credential = [NSURLCredential credentialWithIdentity:myIdentity certificates:(__bridge NSArray*)certsArray persistence:NSURLCredentialPersistencePermanent];
                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
                return ;
            }
            
            if (options) {
                CFRelease(options);
            }
        }];
        if (!self.showLog) {
            NSLog(@"https 无匹配证书");
        }
    }
}


@end

@interface WTNetwork (URLSession)
@property (nonatomic, strong) NSURLSession *session;
@end
@implementation WTNetwork (URLSession)
- (void)setSession:(NSURLSession *)session {
    objc_setAssociatedObject(self, @selector(session), session, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSURLSession *)session {
    return objc_getAssociatedObject(self, _cmd);
}
@end


@implementation WTNetwork (Base)

- (void)method:(NSString *)method
     urlString:(NSString *)urlString
     parameter:(NSDictionary *)parameter
       addFile:(nullable void(^)(void(^addFile)(NSString *key, NSString *filename, NSData *data)))addFile
      progrees:(nullable void(^)(CGFloat progrees))progrees
       success:(nullable void(^)(id response))success
       failure:(nullable void(^)(NSError *error, id errorResponse, NSString *message))failure {
    if ([self checkNetworkStatus] == WTNetworkStatusNoNetwork) {
        NSError *error = [[NSError alloc] initWithDomain:@"com.haoxing.networkError" code:404 userInfo:@{@"message": @"无网络连接"}];
        !failure ?: failure(error, nil, @"无网络连接");
        NSLog(@"请求失败 \nmethod: %@ \nurl: %@ \n\nparameter: \n%@ \n\nerror: %@", method, urlString, parameter, error);
        return;
    }
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    for (NSString *key in parameter.allKeys) {
        [param setObject:[parameter[key] wtnet_URLEncoded] forKey:key];
    }
    parameter = param.copy;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *requestURLString = urlString;
        if (self.delegate && [self.delegate respondsToSelector:@selector(wtnet_willRequestURLString:)]) {
            NSString *getURLString = [self.delegate wtnet_willRequestURLString:urlString];
            if (getURLString.length) {
                requestURLString = getURLString;
            }
        }
        NSURL *url;
        if ([method.uppercaseString isEqualToString:@"GET"] && parameter.allKeys.count) {
            NSMutableString *componentsJoinedString = [NSMutableString stringWithString:requestURLString];
            if (![componentsJoinedString containsString:@"?"]) {
                [componentsJoinedString appendString:@"?"];
            }
            else {
                [componentsJoinedString appendString:@"&"];
            }
            [componentsJoinedString appendString:[parameter wtnet_componentsJoinedByMiddleString:@"=" segmentationString:@"&"]];
            
            url = [NSURL URLWithString:componentsJoinedString];
        }
        else {
            url = [NSURL URLWithString:requestURLString];
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = method.uppercaseString;
        
        NSString *userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
        if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            NSMutableString *mutableUserAgent = [userAgent mutableCopy];
            if (CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false)) {
                userAgent = mutableUserAgent;
            }
        }
        [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
        
        NSDictionary *header = @{@"Accept-Language":@"zh-Hans-US;q=1, en;q=0.9", @"Content-Type":@"text/html", @"User-Agent":userAgent};
        request.allHTTPHeaderFields = header;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(wtnet_willRequest:parameter:)]) {
            [self.delegate wtnet_willRequest:request parameter:parameter];
        }
        if (![method.uppercaseString isEqualToString:@"GET"] && !request.HTTPBody) {
            [request setHTTPMethod:method.uppercaseString];
            if (!addFile) {
                NSString *contentType = [request valueForHTTPHeaderField:@"Content-Type"];
                if ([contentType containsString:@"application/json"]) {
                    request.HTTPBody = [parameter wtnet_toJsonData];
                }
                else if ([contentType containsString:@"application/x-www-form-urlencoded"]) {
                    request.HTTPBody = [[parameter wtnet_componentsJoinedByMiddleString:@"=" segmentationString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
                }
            }
            else {
                NSString *boundary = [NSString stringWithFormat:@"HXBoundary%@", [[NSUUID UUID] UUIDString]];
                NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
                [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
                
                NSMutableData *httpBody = [NSMutableData data];
                
                [parameter enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
                    [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
                    [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
                }];
                
                // 本地文件的NSData
                void(^addFileBloack)(NSString *key, NSString *filename, NSData *data) = ^(NSString *key, NSString *filename, NSData *data) {
                    CFStringRef extension = (__bridge CFStringRef)[filename pathExtension];
                    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
                    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
                    
                    CFRelease(UTI);
                    
                    [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, filename] dataUsingEncoding:NSUTF8StringEncoding]];
                    [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
                    [httpBody appendData:data];
                    [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                };
                addFile(addFileBloack);
                [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                request.HTTPBody = httpBody;
            }
        }
        [self request:request parameter:parameter progrees:progrees success:success failure:failure];
    });
}

- (void)request:(NSURLRequest *)request
      parameter:(NSDictionary *)parameter
       progrees:(nullable void(^)(CGFloat progrees))progrees
        success:(nullable void(^)(id response))success
        failure:(nullable void(^)(NSError *error, id errorResponse, NSString *message))failure {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!self.session) {
            self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue currentQueue]];
        }
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
        dataTask.wtnet_URL = request.URL;
        dataTask.wtnet_parameter = parameter;
        dataTask.wtnet_data = [NSMutableData data];
        dataTask.wtnet_progrees = progrees;
        dataTask.wtnet_success = success;
        dataTask.wtnet_failure = failure;
        [dataTask resume];
    });
}

@end
