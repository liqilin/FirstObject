//
//  Macro.h
//  BlueTouch
//
//  Created by user on 15/1/13.
//  Copyright (c) 2015年 hanyachao. All rights reserved.
//

#ifndef BlueTouch_Macro_h
#define BlueTouch_Macro_h
////常用工具
#import "Util.h"

#import "HTTPService.h"
//#import "MMProgressHUD.h"

////跳转单利
#import "JumpManger.h"
//
//
#import <WebKit/WebKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

#import "DataBase.h"
#import "MBProgressHUD.h"

#define Screen_Height ([UIScreen mainScreen].bounds.size.height)

#define Screen_Width ([UIScreen mainScreen].bounds.size.width)


#define RGBA(r,g,b,a) [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:a]


#define iOS_version [[[UIDevice currentDevice]systemVersion] floatValue]

#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
//
typedef NS_ENUM(UInt8, BitSwitch){
    kBit8On = 0x01 << 7,
    kBit7On = 0x01 << 6,
    kBit6On = 0x01 << 5,
    kBit5On = 0x01 << 4,
    kBit4On = 0x01 << 3,
    kBit3On = 0x01 << 2,
    kBit2On = 0x01 << 1,
    kBit1On = 0x01,
    kBitAllOn = 0xff,
    kBitAllOff = 0x00
};


const static NSString *APIKey = @"3ec9d172b0f48855c9d6b1fb84f41297";

#define NUMBER_ZERO 0

#define NUMBER_One 1

#define NUMBER_Two 2



#define CURRENT_ORDERID @"order_currentid"

#define STOKEN @"stoken"
#define OrderInfo @"OrderInfo"


#define nilOrJSONObjectForKey(JSON_, KEY_) [JSON_ objectForKey:KEY_] == [NSNull null] ? nil : [JSON_ valueForKeyPath:KEY_];

typedef NS_ENUM(NSInteger,long_out) {
    long_out_ON = 0,
    long_out_OFF = 1
};

//关闭某一位；
#define kBitTurnOff(aBitFlag)  (aBitFlag ^ kBitAllOn)

//所有接口均需要的key
#define ACCESSKEY @"1234567812345678"

//接口 URL

#define SCROLLVIEW_HEIGHT (([UIScreen mainScreen].bounds.size.height == 480)?170:250)




#define UrlString @"http://172.17.210.53:3500/mpos"

#define LoginUrl [NSString stringWithFormat:@"%@/mobile_ope/login",UrlString]

#define GetNewVersion [NSString stringWithFormat:@"%@/mobile_pos/checkVersion",UrlString]

#define GetVersion [NSString stringWithFormat:@"%@/mobile_ope/getAppVersion",UrlString]

#define mm2inch(mm)  (double)(mm)/25.4





#endif
