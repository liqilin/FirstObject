//
//  DailyVC.m
//  Operate
//
//  Created by user on 15/8/24.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import "DailyVC.h"

@implementation DailyVC

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [_activityIndicatorView stopAnimating];
    
    NSString* js = [NSString stringWithFormat:@"window.getUserInfo('companyNo=%@;department=%@;email=%@;loginName=%@;loginPassword=%@;mobilePhone=%@;organName=%@;organNo=%@;sex=%@;shardingFlag=%@;shopName=%@;shopNo=%@;state=%@;storeAddress=%@;storeFullName=%@;storeNo=%@;storeOrganNo=%@;storeParentNo=%@;storeShortName=%@;telPhone=%@;type=%@;userId=%@;userName=%@;userNo=%@;organTypeNo=%@');",
                    [self.modeldictary  objectForKey:@"companyNo"],
                    [self.modeldictary  objectForKey:@"department"],
                    [self.modeldictary  objectForKey:@"email"],
                    [self.modeldictary  objectForKey:@"loginName"],
                    [self.modeldictary  objectForKey:@"loginPassword"],
                    [self.modeldictary  objectForKey:@"mobilePhone"],
                    [self.modeldictary  objectForKey:@"organName"],
                    [self.modeldictary  objectForKey:@"organNo"],
                    [self.modeldictary  objectForKey:@"sex"],
                    [self.modeldictary  objectForKey:@"shardingFlag"],
                    [self.modeldictary  objectForKey:@"shopName"],
                    [self.modeldictary  objectForKey:@"shopNo"],
                    [self.modeldictary  objectForKey:@"state"],
                    [self.modeldictary  objectForKey:@"storeAddress"],
                    [self.modeldictary  objectForKey:@"storeFullName"],
                    [self.modeldictary  objectForKey:@"storeNo"],
                    [self.modeldictary  objectForKey:@"storeOrganNo"],
                    [self.modeldictary  objectForKey:@"storeParentNo"],
                    [self.modeldictary  objectForKey:@"storeShortName"],
                    [self.modeldictary  objectForKey:@"telPhone"],
                    [self.modeldictary  objectForKey:@"type"],
                    [self.modeldictary  objectForKey:@"userId"],
                    [self.modeldictary  objectForKey:@"userName"],
                    [self.modeldictary  objectForKey:@"userNo"],
                    [self.modeldictary  objectForKey:@"organTypeNo"]];
    
    [webView stringByEvaluatingJavaScriptFromString:js];
    
    
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}

@end
