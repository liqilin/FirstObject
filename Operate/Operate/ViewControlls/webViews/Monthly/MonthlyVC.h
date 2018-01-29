//
//  MonthlyVC.h
//  Operate
//
//  Created by user on 15/8/24.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import "MainWedView.h"
//月报

#import <JavaScriptCore/JavaScriptCore.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

@protocol TestJSExport <JSExport>

//获取定位信息
- (void)getPositionData;
//打开二维码扫描
- (void)openScan3;
- (void)openScan2;
- (void)goPrintipSetVC;
- (void)showSetPageDialog;
- (void)printSaleList:(NSString *)gDataStr;
- (void)printShoppingOrderList:(NSString *)dataString;
- (void)printExpressDocument:(NSString *)dataString;
//跳转客服会话界面
- (void)openCustomService:(NSString *)urlStr;

//getScan2Date
//获取设备信息
- (void)getDeviceData;

- (void)checkUpdate;

- (void)giveCall:(NSString *)tel;

- (void)openCamera:(id)isPhoto;

- (void)getLoginUserData;
- (void)getIOSUserMain;

- (void)loginPage;

//setLoginUserData
@end
//月报


@interface MonthlyVC : MainWedView <TestJSExport,AMapLocationManagerDelegate,AMapSearchDelegate>

@property(nonatomic,strong) JSContext *jsContext;

@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic,strong) AMapLocationManager *locationAManager;



@property(nonatomic,strong) NSDictionary *modeldictary;

@end
