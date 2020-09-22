//
//  WTNetwork+NSCategory.h
//  WTNetwork_Example
//
//  Created by Haoxing on 2020/9/21.
//  Copyright © 2020 txywjw@icloud.com. All rights reserved.
//

#import "WTNetwork.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (WTNetwork)

- (NSData *)wtnet_toJsonData;

- (NSString *)wtnet_toJsonString;

@end

@interface NSDictionary (WTNetwork)

- (NSData *)wtnet_toJsonData;

- (NSString *)wtnet_toJsonString;

- (NSString *)wtnet_componentsJoinedByMiddleString:(NSString *)middle segmentationString:(NSString *)segmentation;

@end

@interface NSData (WTNetwork)

- (id)wtnet_toJsonObject;

@end

@interface NSString (WTNetwork)

- (id)wtnet_toJsonObject;

- (NSString *)wtnet_URLEncoded;

- (NSString *)wtnet_sha256;

@end





NS_ASSUME_NONNULL_END
