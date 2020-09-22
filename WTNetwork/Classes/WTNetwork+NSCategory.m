//
//  WTNetwork+NSCategory.m
//  WTNetwork_Example
//
//  Created by Haoxing on 2020/9/21.
//  Copyright © 2020 txywjw@icloud.com. All rights reserved.
//

#import <CommonCrypto/CommonCrypto.h>

#import <objc/runtime.h>

#import "WTNetwork+NSCategory.h"

@implementation NSArray (WTNetwork)

- (NSData *)wtnet_toJsonData
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    
    if ([jsonData length]&&error== nil){
        return jsonData;
    }else{
        return nil;
    }
}

- (NSString *)wtnet_toJsonString {
    return [[NSString alloc] initWithData:[self wtnet_toJsonData] encoding:NSUTF8StringEncoding];
}

@end

@implementation NSDictionary (WTNetwork)

- (NSData *)wtnet_toJsonData
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    if (jsonData.length && error == nil){
        return jsonData;
    }
    else{
        return nil;
    }
}

- (NSString *)wtnet_toJsonString {
    return [[NSString alloc] initWithData:[self wtnet_toJsonData] encoding:NSUTF8StringEncoding];
}

- (NSString *)wtnet_componentsJoinedByMiddleString:(NSString *)middle segmentationString:(NSString *)segmentation {
    NSMutableString *componentsJoinedString = [NSMutableString string];
    for (NSString *key in self.allKeys) {
        if (componentsJoinedString.length) {
            [componentsJoinedString appendString:segmentation];
        }
        id value = [self objectForKey:key];
        [componentsJoinedString appendFormat:@"%@%@%@", key, middle, value ? value : @""];
    }
    return componentsJoinedString;
}

@end

@implementation NSData (WTNetwork)

- (id)wtnet_toJsonObject {
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:self
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }
    else {
        NSString *json = [NSString.alloc initWithData:self encoding:NSUTF8StringEncoding];
        if (!json.length) {
            return nil;
        }
        json = [self wtnet_replacingNewLineAndWhitespaceCharactersFromJsonString:json];
        NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
        error = nil;
        jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                     options:NSJSONReadingAllowFragments
                                                       error:&error];
        if (jsonObject) {
            return jsonObject;
        }
        else {
            return nil;
        }
    }
}

- (NSString *)wtnet_replacingNewLineAndWhitespaceCharactersFromJsonString:(NSString *)string {
    NSScanner *scanner = [[NSScanner alloc] initWithString:string];
    [scanner setCharactersToBeSkipped:nil];
    NSMutableString *result = [[NSMutableString alloc] init];
    
    NSString *temp;
    NSCharacterSet*newLineAndWhitespaceCharacters = [ NSCharacterSet newlineCharacterSet];
    // 扫描
    while (![scanner isAtEnd])
    {
        temp = nil;
        [scanner scanUpToCharactersFromSet:newLineAndWhitespaceCharacters intoString:&temp];
        if (temp) [result appendString:temp];
        
        // 替换换行符
        if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
            if (result.length > 0 && ![scanner isAtEnd]) // Dont append space to beginning or end of result
                [result appendString:@"|"];
        }
    }
    return result;
}

@end

@implementation NSString (WTNetwork)

- (id)wtnet_toJsonObject {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data wtnet_toJsonObject];
}

- (NSString *)wtnet_URLEncoded {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (NSString *)wtnet_sha256 {
    const char* str = [self UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }
    ret = (NSMutableString *)[ret uppercaseString];
    return ret;
}

@end
