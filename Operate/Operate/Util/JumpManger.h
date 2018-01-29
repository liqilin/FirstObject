//
//  JumpManger.h
//  EasyLesson
//
//  Created by user on 15/4/29.
//  Copyright (c) 2015年 yachao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Util.h"

@class MainVC;
@class UserModel;

#define JumpObject [JumpManger shareManger]
@interface JumpManger : NSObject



@property(nonatomic,strong)NSDictionary *authorityUser;

@property(nonatomic,strong)NSDictionary *userMain;

@property(nonatomic,assign)BOOL isNewPrint;

+ (JumpManger *)shareManger;

- (void)showMainController;

- (void)showViewController;

//显示登录界面
- (void)showLoginVC;

- (void)showRegistervcWith:(MainVC *)currentViewController;


// 关闭菜单
-(void)closeSwitchMenu:(BOOL)animation;
// 打开菜单.
-(void)openSwitchMenu:(BOOL)animatin;
// 当前菜单状态. yes ,close , no ,show
-(BOOL)currentSwitchMenuState;


- (void)saveUserInfo:(UserModel *)model;

- (UserModel *)getUserModel;

- (void)savehttpUrlString:(NSString *)Str;

- (NSString *)getHttpUrl;

- (NSString *)getScanNingData;
- (void)saveScanStringData:(NSString *)Str;


- (void)showForgetPasswordvcWith:(MainVC *)currentVC;

- (void)pushToAVfuntionVIew;

- (void)saveserverVersionString:(NSString *)Str;

- (NSString *)getServersionString;


@end
