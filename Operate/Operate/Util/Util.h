//
//  Util.h
//  mlh
//
//  Created by qd on 13-5-10.
//  Copyright (c) 2013年 sunday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
//c++ 获取mac地址
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>


#import <CommonCrypto/CommonDigest.h>//C++/MD5
@interface Util : NSObject




//获得对象
+ (Util *)getUtitObject;


//字符串转颜色
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;

//去掉空格
+(NSString *) stringByRemoveTrim:(NSString *)str;

//不转webview打不开啊。。
+(NSString *)getWebViewUrlStr:(NSString *)urlStr;

//NSString UTF8转码
+(NSString *)getUTF8Str:(NSString *)str;

//根据文字、字体、文字区域宽度，得到文字区域高度
+ (CGFloat)heightForText:(NSString*)sText Font:(UIFont*)font forWidth:(CGFloat)fWidth;

//view根据原来的frame做调整，重新setFrame，fakeRect的4个参数如果<0，则用原来frame的相关参数，否则就用新值。
+ (void) View:(UIView *)view ReplaceFrameWithRect:(CGRect) fakeRect;

//view根据原来的bounds做调整，重新setBounds，fakeRect的4个参数如果<0，则用原来bounds的相关参数，否则就用新值。
+ (void) View:(UIView *)view ReplaceBoundsWithRect:(CGRect) fakeRect;

//根据@"#eef4f4"得到UIColor
+ (UIColor *) uiColorFromString:(NSString *) clrString;
+ (UIColor *) uiColorFromString:(NSString *) clrString alpha:(double)alpha;

//将原始图片draw到指定大小范围，从而得到并返回新图片。能缩小图片尺寸和大小
+ (UIImage*)ScaleImage:(UIImage*)image ToSize:(CGSize)newSize;
//将图片保存到document目录下
+ (void)saveDocImage:(UIImage *)tempImage WithName:(NSString *)imageName;

//将浮点数转换为NSString，并设置保留小数点位数
+ (NSString *)getStringFromFloat:(float) f withDecimal:(int) decimalPoint;
+ (int) defaultRandom;

+ (UIAlertView *)showAlertWithTitle:(NSString *)title msg:(NSString *)msg;
#pragma mark-scoket的数据转化
+ (UInt16)uint16FromNetData:(NSData *)data;

+ (UInt32)uint32FromNetData:(NSData *)data;


+ (NSString *)macString:(NSData *)mac;

+ (void)setFont:(UILabel *)label;
+ (void)setFontFor:(NSArray *)labelArray;
//获得window
+ (UIWindow *)getAppWindow;

//获取app budle版本
+ (NSString *)getAppVersion;

//app本身版本
+ (NSString *)getAppShortVersion;

//获取app名字
+ (NSString *)getAppName;
//获得wifi名字
+ (NSString *)getWifiName;
//字符串转化data
- (NSData *)macStrTData:(NSString *)str;

- (NSString *)getMacStringWith:(NSString *)mac;

+ (NSString *)getMacAddress;


+ (NSData *)netDataFromUint16:(UInt16)number;


+ (AppDelegate *)getAppDelegate;

//单位：毫秒
+(NSString *)getCurrentDate;
//当前日期
+(NSString *)getCurrentDateWithFormat:(NSString *)format;

#pragma mark-
#pragma mark-转换随机433地址 只适合本项目使用
+ (NSData *)getRFAddressWith:(NSString *)string;


//数组排序临时方法

//+ (NSMutableArray *)invertedOrder:(NSMutableArray *)timeArray;

+ (UIImage *)getImageFile:(NSString *)imagePath;

+ (void)deleteCancleImageFileWithPath:(NSString *)path;

#pragma mark-md5
//MD5加密
+ (NSString *)getPassWordWithmd5:(NSString *)str;

//数组去重复对象
+ (NSMutableArray *)arraytoreToArray:(NSMutableArray *)aArray;

//获取图片路径
+ (NSString *)getFilePathWithImageName:(NSString *)imageName;


+ (NSString *)getUUID;


//mac地址的拼接
+ (NSString *)getMAcStringWithstring:(NSString *)mac;


////获得浅绿色
//+ (UIColor *)getGreenColor;
//
////白色
//+ (UIColor *)getWhiteColor;
//

// 是否4英寸屏幕
+ (BOOL)is4InchScreen;


//获取当前试用语言
+ (NSString *)getCurrentLanguage;


//获取当前所在国家/区域
+ (NSString *)getCurrentCountry;


+ (float)getCurrentShoursWith:(NSUInteger)index;


#pragma mark-图片去色
//图片去色
+ (UIImage *)grayImage:(UIImage *)sourceImage;

//根据字符串获得宽高
+ (CGSize)getStringWidthWithStringLenth:(NSString *)string Withfont:(float)fontz;


//提示文本
+ (void)showHud:(NSString *)string withView:(UIView *)view;
//加载
+ (void)showIndeterminateHud:(NSString *)string  withView:(UIView *)view;


//获取设备型号
+ (NSString*)deviceVersion;

//获取设备udid
+ (NSString *)deviceUUIDString;
//获取设备版本号
+ (NSString *)deviceSystemVersion;
//判断值是否为空
+ (BOOL)currentValueEmpty:(NSObject *)value;

@end
