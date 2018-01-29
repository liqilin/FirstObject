//
//  JumpManger.m
//  EasyLesson
//
//  Created by user on 15/4/29.
//  Copyright (c) 2015年 yachao. All rights reserved.
//

#import "JumpManger.h"
#import "LoginVC.h"
#import "UserModel.h"
#import "MainVC.h"
#import "PrintViewController.h"

#import "HomePageVC.h"
#import "PromotionVC.h"
#import "ShopVC.h"
#import "StatementsVC.h"
#import "MonthlyVC.h"
#import "RegisterVC.h"
#import "ForgetPasswordVC.h"
#import "ScanningViewColl.h"

#import "CustomTabBar.h"

@interface JumpManger ()

{
    
    UINavigationController *mainNav;
    UINavigationController *mainPageVC; // 主页
    UINavigationController *leftPageVC;

    
    NSString * httpUrlString;
    
    NSString * scanString;

    NSString * serverVersion;

    UserModel *userModel;
    
}

@end

static JumpManger *singleton = nil;

@implementation JumpManger



+ (JumpManger *)shareManger
{
    if (!singleton) {
        
        singleton =  [[super allocWithZone:NULL] init];
        
        
    }
    return singleton;
    
}

- (id)init{
    
    self = [super init];
    
//    [[NSUserDefaults standardUserDefaults] setObject:@"http://172.17.215.110:3200" forKey:@"setUrl"];

    serverVersion = @"0.0.0";
    httpUrlString = [[NSUserDefaults standardUserDefaults] objectForKey:@"setUrl"];
    
    return self;
    
}

- (void)showMainController
{
    
    
//        CustomTabBar *tb=[[CustomTabBar alloc]init];
//        //设置控制器为Window的根控制器
//
//        //b.创建子控制器
//        HomePageVC *c1=[[HomePageVC alloc]init];
//        c1.tabBarItem.title=@"首页";
//        c1.tabBarItem.image=[UIImage imageNamed:@"icon_task.png"];
//
//        UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:c1];
//
//        StatementsVC *c2=[[StatementsVC alloc]init];
//        c2.tabBarItem.title=@"报表";
//        c2.tabBarItem.image=[UIImage imageNamed:@"icon_exchange.png"];
//        UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:c2];
//
//        PromotionVC *c3=[[PromotionVC alloc]init];
//        c3.tabBarItem.title=@"促销";
//        c3.tabBarItem.image=[UIImage imageNamed:@"icon_me.png"];
//        UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:c3];
//
//        ShopVC *c4=[[ShopVC alloc]init];
//        c4.tabBarItem.title=@"巡店";
//        c4.tabBarItem.image=[UIImage imageNamed:@"icon_more.png"];
//        UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:c4];
//
//
//        //c.添加子控制器到ITabBarController中
//        //c.1第一种方式
//        //    [tb addChildViewController:c1];
//        //    [tb addChildViewController:c2];
//
//        //c.2第二种方式
//        tb.nomalImageArray = @[@"icon_task.png",@"icon_exchange.png",@"icon_me.png",@"icon_more.png"];
//        tb.hightImageArray = @[@"icon_task.png",@"icon_exchange.png",@"icon_me.png",@"icon_more.png"];
//
//        tb.titlesarray = @[@"首页",@"报表",@"促销",@"巡店"];
//        tb.viewControllers=@[nav1,nav2,nav3,nav4];
//
//        [Util getAppDelegate].window.rootViewController=tb;

    

    
}

- (void)showViewController
{
    
//    c1.tabBarItem.title=@"首页";
//    c1.tabBarItem.image=[UIImage imageNamed:@"icon_task.png"];
    NSString *urlStr = [JumpObject getHttpUrl];//不再拼接域名，由登录接口返回
    NSInteger index = 0;
    for (int i = 0; i < urlStr.length; i++) {
        NSString *subS = [urlStr substringWithRange:NSMakeRange(i, 1)];
        if ([subS isEqualToString:@"/"]) {
            index ++;
            if (index == 3) {
                urlStr = [urlStr substringWithRange:NSMakeRange(0, i+1)];
            }
        }
    }
//    NSURL *url = [NSURL URLWithString:urlStr];
//    NSString *host = [url host];
//    if ([urlStr hasPrefix:@"http://"]) {
//        urlStr = @"http:";
//    }else if ([urlStr hasPrefix:@"https://"]){
//        urlStr = @"https:";
//    }

    MonthlyVC *mothly = [[MonthlyVC alloc] init];
    
    mothly.modeldictary = [JumpObject getUserModel].authorityUserDic;
    

    NSString *tempStr =  [NSString stringWithFormat:@"%@%@",urlStr,[JumpObject.userMain objectForKey:@"opeLoginUrl"]];
    
    NSLog(@"JumpObject.userMain=%@",JumpObject.userMain);
    NSLog(@"tempStr=%@",tempStr);
    
    mothly.infoUrl = [NSString stringWithFormat:@"%@%@",urlStr,[JumpObject.userMain objectForKey:@"opeLoginUrl"]];
    if (JumpObject.userMain == nil) {
        mothly.infoUrl = [NSString stringWithFormat:@"%@%@",urlStr,[JumpObject.authorityUser objectForKey:@"opeLoginUrl"]];
    }



    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:mothly];

   
    [Util getAppDelegate].window.rootViewController = loginNav;
    
}

- (void)pushToAVfuntionVIew
{
    

}


- (void)saveUserInfo:(UserModel *)model
{
    
    userModel = model;
    
}

- (void)savehttpUrlString:(NSString *)Str
{
    
    httpUrlString = Str;
    
}


- (NSString *)getScanNingData
{
    return scanString;
    
}

- (void)saveScanStringData:(NSString *)Str
{
    
    scanString = Str;
    
}



- (void)saveserverVersionString:(NSString *)Str
{
    
    serverVersion = Str;
    
}


- (NSString *)getServersionString
{
    
//    NSLog(@"httpUrlString=%@",httpUrlString);
    return serverVersion;
    
}



- (UserModel *)getUserModel
{
    
    return userModel;
    
}

- (NSString *)getHttpUrl
{
    
//    NSLog(@"httpUrlString=%@",httpUrlString);
    return httpUrlString;
    
}
- (void)showLoginVC
{
    

    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    LoginVC * login = [[LoginVC alloc]init];
    
    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:login];

    [Util getAppDelegate].window.rootViewController = loginNav;
    
}


- (void)showForgetPasswordvcWith:(MainVC *)currentVC
{
    ForgetPasswordVC *menuVC = [[ForgetPasswordVC alloc] init];
    
    NSString *urlStr = [JumpObject getHttpUrl];
    
    menuVC.infoUrl = [NSString stringWithFormat:@"%@/mobile_mmp/html/pages/login/forgetPwd.html",urlStr];
    
    [currentVC.navigationController pushViewController:menuVC animated:YES];
    
}

- (void)showRegistervcWith:(MainVC *)currentViewController
{
    RegisterVC *menuVC = [[RegisterVC alloc] init];
    
    NSString *urlStr = [JumpObject getHttpUrl];
    
    
    menuVC.infoUrl = [NSString stringWithFormat:@"%@/mobile_mmp/html/pages/login/register.html",urlStr];
    
    [currentViewController.navigationController pushViewController:menuVC animated:YES];
    

    

}



// 关闭菜单
-(void)closeSwitchMenu:(BOOL)animation
{
    
//    UIViewController *tempVC = [Util getAppDelegate].window.rootViewController;
//    if ([tempVC isKindOfClass:[MMDrawerController class]]) {
//        [(MMDrawerController *)tempVC closeDrawerAnimated:animation completion:^(BOOL finished) {
//            
//        }];
//    }
    
    
    
}
// 打开菜单.
-(void)openSwitchMenu:(BOOL)animatin
{
    
//    UIViewController *tempVC = [Util  getAppDelegate].window.rootViewController;
//    if ([tempVC isKindOfClass:[MMDrawerController class]]) {
//        [(MMDrawerController *)tempVC openDrawerSide:MMDrawerSideLeft animated:animatin completion:^(BOOL finished) {
//            
//        }];
//    }
    
    
}
// 当前菜单状态. yes ,close , no ,show
-(BOOL)currentSwitchMenuState{
//    UIViewController *tempVC = [Util getAppDelegate].window.rootViewController;
//    if ([tempVC isKindOfClass:[MMDrawerController class]]) {
//        MMDrawerSide state = ((MMDrawerController *)mainPageVC).openSide;
//        if (state == MMDrawerSideLeft) {
//            return NO;
//        }
//        return YES;
//    }
    return YES;
}


@end
