//
//  WTNetwork.m
//  WTNetwork_Example
//
//  Created by Haoxing on 2020/9/21.
//  Copyright © 2020 txywjw@icloud.com. All rights reserved.
//

#import "WTNetwork.h"

#import "WTNetwork+Base.h"

#import "Reachability.h"

@interface WTNetwork ()
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSData *> *cers;
@end

@implementation WTNetwork
+ (instancetype)network {
    return [WTNetwork.alloc init];
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static WTNetwork *network;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        network = [super allocWithZone:zone];
        network.showLog = true;
    });
    return network;
}
- (void)addCer:(NSData *)cerData password:(NSString *)password {
    if (!self.cers) {
        self.cers = [NSMutableDictionary dictionary];
    }
    [self.cers setObject:cerData forKey:password];
}
- (WTNetworkStatus)checkNetworkStatus {
    Reachability *reachability   = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    WTNetworkStatus status;
    switch (internetStatus) {
        case ReachableViaWiFi:
            status = WTNetworkStatusWifi;
            break;
            
        case ReachableViaWWAN:
            status = WTNetworkStatusWWAN;
            break;
            
        case NotReachable:
            status = WTNetworkStatusNoNetwork;
            
        default:
            break;
    }
    return status;
}
@end

@implementation WTNetwork (Request)

- (void)fileURLString:(NSString *)urlString
            parameter:(NSDictionary *)parameter
              addFile:(nullable void(^)(void(^addFile)(NSString *key, NSString *filename, NSData *data)))addFile
             progrees:(nullable void(^)(CGFloat progrees))progrees
              success:(nullable void(^)(id response))success
              failure:(nullable void(^)(NSError *error, id errorResponse, NSString *message))failure {
    [self method:@"POST" urlString:urlString parameter:parameter addFile:addFile progrees:progrees success:success failure:failure];
}

- (void)getURL:(NSString *)urlString
     parameter:(NSDictionary *)parameter
       success:(void(^)(id response))success
       failure:(nullable void(^)(NSError *error, id response, NSString *message))failure {
    [self method:@"GET" urlString:urlString parameter:parameter addFile:nil progrees:nil success:success failure:failure];
}

- (void)postURL:(NSString *)urlString
      parameter:(NSDictionary *)parameter
        success:(void(^)(id response))success
        failure:(nullable void(^)(NSError *error, id response, NSString *message))failure {
    [self method:@"POST" urlString:urlString parameter:parameter addFile:nil progrees:nil success:success failure:failure];
}

- (void)deleteURL:(NSString *)urlString
        parameter:(NSDictionary *)parameter
          success:(void(^)(id response))success
          failure:(nullable void(^)(NSError *error, id response, NSString *message))failure {
    [self method:@"DELETE" urlString:urlString parameter:parameter addFile:nil progrees:nil success:success failure:failure];
}

- (void)putURL:(NSString *)urlString
     parameter:(NSDictionary *)parameter
       success:(void(^)(id response))success
       failure:(nullable void(^)(NSError *error, id response, NSString *message))failure {
    [self method:@"PUT" urlString:urlString parameter:parameter addFile:nil progrees:nil success:success failure:failure];
}

@end
