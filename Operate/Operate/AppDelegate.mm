//
//  AppDelegate.m
//  Operate
//
//  Created by user on 15/8/20.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import "AppDelegate.h"
#import "Macro.h"

#import <AMapFoundationKit/AMapFoundationKit.h>
@interface AppDelegate ()<UIAlertViewDelegate>
{
    
    __block NSString *updateUrl;
    
//    BMKMapManager *_mapManager;

}


    



@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
//    _mapManager = [[BMKMapManager alloc]init];
//    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
//    BOOL ret = [_mapManager start:@"BHufGwVwymdl1lGGKZABbssRW5G5O418" generalDelegate:nil];
//    if (!ret) {
//        NSLog(@"manager start failed!");
//    }

    
//    NSString *systemModel = [[UIDevice currentDevice] systemVersion];
//    NSLog(@"[Util deviceVersion]=%@\nsystemVersion=%@",[Util deviceVersion],systemModel);
    
    
//    [self.window setRootViewController:rootController];
//    [DataBase deleteFromTableView];
    [self configureAPIKey];
    

    [DataBase shareInstance];

    
    
    BOOL state = [[[NSUserDefaults standardUserDefaults] objectForKey:@"firstLaunch"] boolValue];
    if (!state) {
        
        [self insertInto];
        
    }
    if ([DataBase selectAllDataFromDataBase].count != 0) {
        
        DataUrlModel *model =[[DataBase selectAllDataFromDataBase] objectAtIndex:0];
        
        if (model.currentVersion == nil || [model.currentVersion isEqual:[NSNull null]] || [model.currentVersion isEqualToString:@""]) {
            
            [DataBase deleteFromTableView];
            [self insertInto];

            
            [DataBase columnExistsTheVersionName:[Util getAppShortVersion]];


        }else{
            

            if ([model.currentVersion  isEqualToString:[Util getAppShortVersion] ]) {
                
                for (DataUrlModel *model in [DataBase selectAllDataFromDataBase]) {
                    
                    [DataBase updateTheVersionName:[Util getAppShortVersion] whereid:model.urlID];

                }
                
            }

        }

    }
    

    [JumpObject showLoginVC];

//    NSDictionary * dict =
//    @{@"appNo":@"MPS",@"appType":@"ios",@"currentVer":[Util getAppShortVersion]};
//
//    NSString *urlstr =  [JumpObject getHttpUrl];
//
//    [HTTPService GetHttpToServerWith:[NSString stringWithFormat:@"%@/app/checkVersion",urlstr] WithParameters:dict success:^(NSDictionary *dic) {
//
//        NSLog(@"%@",[dic objectForKey:@"errorMessage"]);
//
//        if ([[dic objectForKey:@"errorCode"] integerValue] == 0) {
//
//
//        if ([[dic objectForKey:@"data"] isEqual:[NSNull null]]) {
//
//            return ;
//        }
//
//        NSDictionary *dataDic = [dic objectForKey:@"data"];
//
//        if ([[dataDic objectForKey:@"isUpgrade"]  isEqual:[NSNull null]]) {
//
//            return;
//        }
//        if ([[dataDic objectForKey:@"isUpgrade"] intValue]  == 0) {
//
//            return;
//        }
//
//        NSString *title = [NSString stringWithFormat:@"版本更新(当前版本:%@)", [Util getAppShortVersion]];
//        updateUrl = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",[dataDic objectForKey:@"upadteURL"]];
//        NSString *msg = [NSString stringWithFormat:@"\n有最新的版本:%@，是否更新？\n\n", [dataDic objectForKey:@"latestVersion"]];
//
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"更新", nil];
//
//        alert.tag = 1711;
//        [alert show];
//
//         }
//    } error:^(NSError *error) {
//
//
//    }];
    

    

    [self.window makeKeyAndVisible];


    return YES;
}



- (void)configureAPIKey
{
    if ([APIKey length] == 0)
    {
        NSString *reason = [NSString stringWithFormat:@"apiKey为空，请检查key是否正确设置。"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:reason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    
    [AMapServices sharedServices].apiKey = (NSString *)APIKey;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1711) {
        
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];
            exit(0);
        }
    }
    
}


- (void)insertInto
{
    

    
    DataUrlModel *mode = [[DataUrlModel alloc] init];
    mode.titleName = @"生产环境";
    mode.urlStr = @"http://retail.belle.net.cn/mmp";
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
    
    NSLog(@"------------APP进入前台");
    
    
    
    
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
