//
//  MainWedView.m
//  EasyLesson
//
//  Created by user on 15/5/19.
//  Copyright (c) 2015年 yachao. All rights reserved.
//

#import "MainWedView.h"
#import "Macro.h"
@interface MainWedView ()

@end

@implementation MainWedView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWebView];

//    self.backButton.hidden = NO;
//    self.imageView_L.hidden = NO;
//    self.titlelab.text = NSLocalizedString(@"AGB", nil);
    
    self.title = self.infoTitle;
    
    
    //    self.backButton.hidden = NO;
    // Do any additional setup after loading the view.
}

- (void)initWebView
{
    
//    self.titlelab.text = @"详情";
    self.webView.scalesPageToFit = YES;
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height )];
//    if (iOS_version >= 7.0f)
//    {
//        self.webView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height );
//    }
    
    //禁止自动转为链接
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    
    
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.scalesPageToFit = YES;
    self.webView.scrollView.bounces  = NO;
    
        NSURLRequest *request = [NSURLRequest requestWithURL:[ NSURL URLWithString:self.infoUrl] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    [self.webView loadRequest:request];
//    [self.webView loadRequest:[ NSURLRequest requestWithURL:[ NSURL URLWithString:self.infoUrl]]];
    [self.view addSubview:self.webView];
    [_activityIndicatorView setFrame:CGRectMake(Screen_Width/2, (Screen_Height-10 - 44)/2 - 10, 20, 20)];
    [self.webView addSubview:_activityIndicatorView];
    
    
}
- (void)loadView
{
    [super loadView];
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.hidesWhenStopped = YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.webView reload];
}




- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //判断是否是单击
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        NSURL *url = [request URL];
        if([[UIApplication sharedApplication]canOpenURL:url])
        {
            [[UIApplication sharedApplication]openURL:url];
        }
        return NO;
    }
    return YES;
}

#pragma mark-- UIWebViewDelegate
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [_activityIndicatorView stopAnimating];
    //    HUDShowErrorServerOrNetwork
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
    [_activityIndicatorView startAnimating];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [_activityIndicatorView stopAnimating];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
