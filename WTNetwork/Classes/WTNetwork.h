//
//  WTNetwork.h
//  WTNetwork_Example
//
//  Created by Haoxing on 2020/9/21.
//  Copyright © 2020 txywjw@icloud.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WTNetworkStatus) {
    
    WTNetworkStatusNoNetwork,           //无网络
    
    WTNetworkStatusWifi,                //wifi网络
    
    WTNetworkStatusWWAN,                //蜂窝网络
};

NS_ASSUME_NONNULL_BEGIN

@protocol WTNetworkDelegate <NSObject>
@required
- (NSString *)wtnet_willRequestURLString:(NSString *)URLString;
- (NSMutableURLRequest *)wtnet_willRequest:(NSMutableURLRequest *)request parameter:(NSDictionary *)parameter;
- (nullable id)wtnet_didSuccessWithRequest:(NSURLRequest *)request response:(NSHTTPURLResponse *)response responseData:(NSData *)responseData errorString:(NSString *_Nullable*_Nullable)errorString;
- (NSString *)wtnet_didFailureWithRequest:(NSURLRequest *)request response:(NSURLResponse *)response data:(NSData *)data error:(NSError * _Nullable)error reloadRequest:(dispatch_block_t)reloadRequest;
@optional
@end

@interface WTNetwork : NSObject

@property (nonatomic, weak) id <WTNetworkDelegate> delegate;

@property (nonatomic, strong, readonly) NSMutableDictionary <NSString *, NSData *> *cers;

@property (nonatomic, assign) BOOL showLog;

+ (instancetype)network;

- (void)addCer:(NSData *)cerData password:(NSString *)password;

- (WTNetworkStatus)checkNetworkStatus;

@end

@interface WTNetwork (Request)

- (void)fileURLString:(NSString *)urlString
            parameter:(NSDictionary *)parameter
              addFile:(nullable void(^)(void(^addFile)(NSString *key, NSString *filename, NSData *data)))addFile
             progrees:(nullable void(^)(CGFloat progrees))progrees
              success:(nullable void(^)(id response))success
              failure:(nullable void(^)(NSError *error, id errorResponse, NSString *message))failure;

- (void)getURL:(NSString *)urlString
     parameter:(NSDictionary *)parameter
       success:(void(^)(id response))success
       failure:(nullable void(^)(NSError *error, id response, NSString *message))failure;

- (void)postURL:(NSString *)urlString
      parameter:(NSDictionary *)parameter
        success:(void(^)(id response))success
        failure:(nullable void(^)(NSError *error, id response, NSString *message))failure;

- (void)deleteURL:(NSString *)urlString
        parameter:(NSDictionary *)parameter
          success:(void(^)(id response))success
          failure:(nullable void(^)(NSError *error, id response, NSString *message))failure;

- (void)putURL:(NSString *)urlString
     parameter:(NSDictionary *)parameter
       success:(void(^)(id response))success
       failure:(nullable void(^)(NSError *error, id response, NSString *message))failure;

@end

NS_ASSUME_NONNULL_END
