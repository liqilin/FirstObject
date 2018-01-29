//
//  AppDelegate.m
//  Operate
//
//  Created by user on 15/8/20.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import "AppDelegate.h"
#import "Macro.h"
@interface AppDelegate ()<UIAlertViewDelegate>
{
    
    __block NSString *updateUrl;
    
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    
//    [self.window setRootViewController:rootController];
    

    [DataBase shareInstance];

    BOOL state = [[[NSUserDefaults standardUserDefaults] objectForKey:@"firstLaunch"] boolValue];
    if (!state) {
        
        [self insertInto];

        
    }

    [JumpObject showLoginVC];

//172.17.210.53:3500/mpos/mobile_pos/checkVersion?appNo=MPS&currentVer=1.0.1&appType=ios
    NSDictionary * dict =
    @{@"appNo":@"MPS",@"appType":@"ios",@"currentVer":[Util getAppShortVersion]};
    
    NSString *urlstr =  [JumpObject getHttpUrl];
    
    [HTTPService GetHttpToServerWith:[NSString stringWithFormat:@"%@/mobile_pos/checkVersion",urlstr] WithParameters:dict success:^(NSDictionary *dic) {
        
        
//        [JumpObject showLoginVC];

        if ([[dic objectForKey:@"data"] isEqual:[NSNull null]]) {
            
            //            [Util showHud:@"请求错误" withView:self.window];
            return ;
            
        }
        NSDictionary *dataDic = [dic objectForKey:@"data"];
        
        if ([[dataDic objectForKey:@"isUpgrade"] intValue]  == 0) {
            
            return ;
            
        }
        
        NSString *title = [NSString stringWithFormat:@"版本更新(当前版本:%@)", [Util getAppShortVersion]];
        updateUrl = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",[dataDic objectForKey:@"upadteURL"]];
        NSString *msg = [NSString stringWithFormat:@"\n有最新的版本:%@，是否更新？\n\n", [dataDic objectForKey:@"latestVersion"]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"更新", nil];
        
        alert.tag = 1711;
        
        [alert show];
        
        
    } error:^(NSError *error) {
        
//        [JumpObject showLoginVC];

    }];
    
//    [JumpObject showLoginVC];

    

    
//    
//    [HTTPService GetHttpToServerWith:[NSString stringWithFormat:@"%@/mobile_ope/getAppVersion",urlstr] WithParameters:nil success:^(NSDictionary *dic) {
//        
//        
//        if ([[dic objectForKey:@"data"] isEqual:[NSNull null]]) {
//            
//            //            [Util showHud:@"请求错误" withView:self.window];
//            return ;
//            
//        }
//        NSString *dataDic = [dic objectForKey:@"data"];
//        
//        [JumpObject saveserverVersionString:dataDic];
//        
////        [JumpObject showLoginVC];
//
//        
//    } error:^(NSError *error) {
//        
//        
////        [JumpObject showLoginVC];
//
//    }];
    [self.window makeKeyAndVisible];


    
    // Override point for customization after application launch.
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1711) {
        
        if (buttonIndex == 1) {
            
            NSLog(@"%@",updateUrl);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];

//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-services://?action=download-manifest&url=https://dev.belle.net.cn/ios/MPS/1.0.3/Ordering.plist"]];

            
            
        }
    }
    
}


- (void)insertInto
{
    
//    DataUrlModel *model = [[DataUrlModel alloc] init];
//    model.titleName = @"开发环境";
//    model.urlStr = @"http://172.17.210.53:3500/mpos";
//    model.urlType = @"开发环境";
//    
//   
//    DataUrlModel *localmodel = [[DataUrlModel alloc] init];
//    localmodel.titleName = @"本地环境";
//    localmodel.urlStr = @"http://172.17.215.110:3200";
//    localmodel.urlType = @"开发环境";

//    [DataBase insertIntoDataBase:localmodel];
    DataUrlModel *mode = [[DataUrlModel alloc] init];
    mode.titleName = @"生产环境";
    mode.urlStr = @"http://retail.belle.net.cn/mpos";
    mode.urlType = @"生产环境";
    
    [[NSUserDefaults standardUserDefaults] setObject:mode.urlStr forKey:@"setUrl"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [DataBase insertIntoDataBase:mode];


}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//禁止屏幕旋转
-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    
    return UIInterfaceOrientationMaskPortrait;
}


@end
