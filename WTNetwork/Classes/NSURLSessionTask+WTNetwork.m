//
//  NSURLSessionTask+WTNetwork.m
//  WTNetworking
//
//  Created by Haoxing on 2020/9/22.
//  Copyright © 2020 txywjw@icloud.com. All rights reserved.
//

#import <objc/runtime.h>

#import "NSURLSessionTask+WTNetwork.h"

@implementation NSURLSessionTask (WTNetwork)
- (void)setWtnet_URL:(NSURL *)wtnet_URL {
    objc_setAssociatedObject(self, @selector(wtnet_URL), wtnet_URL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSURL *)wtnet_URL {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setWtnet_parameter:(NSDictionary *)wtnet_parameter {
    objc_setAssociatedObject(self, @selector(wtnet_parameter), wtnet_parameter, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSDictionary *)wtnet_parameter {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setWtnet_data:(NSMutableData *)wtnet_data {
    objc_setAssociatedObject(self, @selector(wtnet_data), wtnet_data, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableData *)wtnet_data {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setWtnet_response:(NSHTTPURLResponse *)wtnet_response {
    objc_setAssociatedObject(self, @selector(wtnet_response), wtnet_response, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSHTTPURLResponse *)wtnet_response {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setWtnet_progrees:(void (^)(CGFloat))wtnet_progrees {
    objc_setAssociatedObject(self, @selector(wtnet_progrees), wtnet_progrees, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^)(CGFloat))wtnet_progrees {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setWtnet_success:(void (^)(id _Nonnull))wtnet_success {
    objc_setAssociatedObject(self, @selector(wtnet_success), wtnet_success, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^)(id _Nonnull))wtnet_success {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setWtnet_failure:(void (^)(NSError * _Nonnull, id _Nonnull, NSString * _Nonnull))wtnet_failure {
    objc_setAssociatedObject(self, @selector(wtnet_failure), wtnet_failure, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^)(NSError * _Nonnull, id _Nonnull, NSString * _Nonnull))wtnet_failure {
    return objc_getAssociatedObject(self, _cmd);
}
@end
