//
//  CreateactivityVC.m
//  Operate
//
//  Created by user on 15/8/24.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import "ForgetPasswordVC.h"

@implementation ForgetPasswordVC

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [_activityIndicatorView stopAnimating];
    
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext[@"js2ios"] = self;
    
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
    
    
    self.jsContext[@"loginPage"]  = ^(NSString *str){
        NSLog(@"loginPage");
        
    };

    
}

- (void)loginPage
{
    
    NSLog(@"%s",__func__);
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSString *urlString = [[request URL] absoluteString];
    
    if ([urlString hasPrefix:@"iosmainwin://"]) {
        if ([urlString isEqualToString:@"iosmainwin://show?iosmainwin"]) {
            [self showiOSToast];
        }
        
        return NO;
    }
    
    return YES;
}
- (void)showiOSToast
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}

@end
