//
//  WTNetwork+Base.h
//  WTNetwork_Example
//
//  Created by Haoxing on 2020/9/21.
//  Copyright © 2020 txywjw@icloud.com. All rights reserved.
//

#import "WTNetwork.h"

NS_ASSUME_NONNULL_BEGIN

@interface WTNetwork (Base)

- (void)method:(NSString *)method
     urlString:(NSString *)urlString
     parameter:(NSDictionary *)parameter
       addFile:(nullable void(^)(void(^addFile)(NSString *key, NSString *filename, NSData *data)))addFile
      progrees:(nullable void(^)(CGFloat progrees))progrees
       success:(nullable void(^)(id response))success
       failure:(nullable void(^)(NSError *error, id errorResponse, NSString *message))failure;

- (void)request:(NSURLRequest *)request
      parameter:(NSDictionary *)parameter
       progrees:(nullable void(^)(CGFloat progrees))progrees
        success:(nullable void(^)(id response))success
        failure:(nullable void(^)(NSError *error, id errorResponse, NSString *message))failure;

@end

NS_ASSUME_NONNULL_END
