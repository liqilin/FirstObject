//
//  DeviceUtil.h
//  Ordering
//
//  Created by tiger on 14-6-17.
//  Copyright (c) 2014年 yshh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceUtil : NSObject
/**
 获取系统UUID，并存入钥匙串
 **/
+ (NSString *)getUUID;
/**
 获取服务器返回的UUID，并存入钥匙串
 **/
+ (NSString *)getNewUUID;

+ (NSString *)machineName;
/**
 获取APP版本号
 **/
+ (NSString*)getAppVersion;
@end
