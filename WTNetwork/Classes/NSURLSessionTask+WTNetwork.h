//
//  NSURLSessionTask+WTNetwork.h
//  WTNetworking
//
//  Created by Haoxing on 2020/9/22.
//  Copyright © 2020 txywjw@icloud.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSessionTask (WTNetwork)
@property (nonatomic, strong) NSURL *wtnet_URL;
@property (nonatomic, copy) NSDictionary *wtnet_parameter;
@property (nonatomic, strong) NSMutableData *wtnet_data;
@property (nonatomic, strong) NSHTTPURLResponse *wtnet_response;
@property (nonatomic, copy, nullable) void(^wtnet_progrees)(CGFloat progrees);
@property (nonatomic, copy, nullable) void(^wtnet_success)(id response);
@property (nonatomic, copy, nullable) void(^wtnet_failure)(NSError *error, id errorResponse, NSString *message);
@end


NS_ASSUME_NONNULL_END
