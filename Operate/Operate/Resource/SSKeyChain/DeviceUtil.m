//
//  DeviceUtil.m
//  Ordering
//
//  Created by tiger on 14-6-17.
//  Copyright (c) 2014年 yshh. All rights reserved.
//
//功能描述：
//修改记录：（仅记录功能修改）

#import "DeviceUtil.h"
#import "SSKeychain.h"
#import <sys/utsname.h>
#import "UserModel.h"
#import "MBProgressHUDHelper.h"

#define UUID_SERVICE @"com.yshh.userinfo"
#define UUID_KEY @"uuid"
@implementation DeviceUtil

+ (NSString*)getUUID
{
    NSString *retrieveuuid = [SSKeychain passwordForService:UUID_SERVICE account:UUID_KEY];
    if ( retrieveuuid == nil || [retrieveuuid isEqualToString:@""])
    {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
        retrieveuuid =  [NSString stringWithFormat:@"%@",uuidStr];
        
        [SSKeychain setPassword: retrieveuuid
                     forService:UUID_SERVICE account:UUID_KEY];
        CFRelease(uuidStr);
        CFRelease(uuid);
    }
    return retrieveuuid;
}
+ (NSString *)getNewUUID
{
    __block NSString *retrieveuuid = [SSKeychain passwordForService:UUID_SERVICE account:UUID_KEY];
    if ( retrieveuuid == nil || [retrieveuuid isEqualToString:@""]|| [retrieveuuid isEqualToString:@"(null)"])
    {
        NSString *urlstr =  [JumpObject getHttpUrl];
        NSString *urlstrs =  [NSString stringWithFormat:@"%@/app/common/get/uuid",urlstr];
        dispatch_semaphore_t signal = dispatch_semaphore_create(1);
        [HTTPService GetHttpToServerWith:urlstrs WithParameters:nil success:^(NSDictionary *dic) {
            if ([[dic objectForKey:@"errorCode"] integerValue] == 0) {
                retrieveuuid = [NSString stringWithFormat:@"%@",[dic objectForKey:@"data"]];
                [SSKeychain setPassword: [NSString stringWithFormat:@"%@",retrieveuuid]
                             forService:UUID_SERVICE account:UUID_KEY];
            }else{
                [MBProgressHUDHelper showHudOverWindow:[NSString stringWithFormat:@"从服务器获取UUID失败！"] afterDelay:2.5f];
            }
            dispatch_semaphore_signal(signal);
        } error:^(NSError *error) {
            dispatch_semaphore_signal(signal);
            [MBProgressHUDHelper showHudOverWindow:[NSString stringWithFormat:@"从服务器获取UUID失败！"] afterDelay:2.5f];
        }];
        dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
    }
    return [NSString stringWithFormat:@"%@",retrieveuuid];
}
+ (NSString*) machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *result = [NSString stringWithCString:systemInfo.machine
                                          encoding:NSUTF8StringEncoding];
    return result;
}

+ (NSString*)getAppVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return appCurVersion;
}

@end
