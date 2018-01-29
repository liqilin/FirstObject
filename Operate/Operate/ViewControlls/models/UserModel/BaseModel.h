//
//  BaseModel.h
//  Operate
//
//  Created by user on 2017/11/10.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface BaseModel : NSObject

/**
 *  从字典初始化
 *  [[BaseModel alloc] initWithDicionary: @{@"name": @"1",@"text": @"chifan",@"price": @"13"}];
 *  @param dict @{@"name": @"1",@"text": @"chifan",@"price": @"13"}
 *
 *  @return self
 */
- (id) initWithDicionary:(NSDictionary *)dict;

/**
 *  从JSON字符串初始化
 *
 *  @param str {"name": "1","text": "chifan","price": "13"}
 *
 *  @return self
 */
- (id) initWithJSONStr:(NSString *)str;

/**
 *  初始化数组（BaseModel）格式json字符串
 *
 *  @param str [
 {
 "name": "22",
 "text": "chifan",
 "price": "13"
 },
 {
 "name": "66",
 "text": "chifan",
 "price": "13"
 }
 ]
 *
 *  @return NSMutableArray
 */
+ (NSMutableArray *) modelsByJSONArrayStr:(NSString *)str;

+ (NSMutableArray *) modelsByDictionaryArray:(NSArray *)arr;

//- (NSDictionary *)toDictionary;

//- (NSString *) toJson;
@end
