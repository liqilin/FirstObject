//
//  MainModel.h
//  EasyLesson
//
//  Created by user on 15/5/28.
//  Copyright (c) 2015年 yachao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macro.h"

@interface MainModel : NSObject



- (id)initWithAttributes:(NSDictionary *)attributes;

/**
 网络读取列表（BaseModel的子类所组成的array）
 
 @param     path    http地址url
 @param     params  参数
 @param     void (^)(NSDictionary *dict, NSString *code, NSString *msg, NSError *error)block 回调方法，resultArray是返回的array，包含的是BaseModel的子类
 */
+ (void)getModelArrayWithPath:(NSString *)path WithParams:(NSDictionary *)params WithBlock:(void (^)(NSArray *resultArray, NSDictionary *dataDict, NSError *errorr))block;


+ (void)getModelMoreArrayWithPath:(NSString *)path WithParams:(NSDictionary *)params WithBlock:(void (^)(NSArray *resultArray, NSDictionary *dataDict, NSError *errorr))block;


+ (void)postModelArrayWithPathPost:(NSString *)path WithParams:(NSDictionary *)params WithBlock:(void (^)(NSArray *resultArray, NSDictionary *dataDict, NSError *errorr))block;


@end
