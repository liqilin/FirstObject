//
//  CustomerServiceVC.m
//  Operate
//
//  Created by user on 2017/11/27.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import "CustomerServiceVC.h"

@interface CustomerServiceVC ()<UIWebViewDelegate>
@property(nonatomic,strong)UIWebView *webView;
@end

@implementation CustomerServiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    navView.backgroundColor = [UIColor colorWithRed:45/255.f green:190/255.f blue:130/255.f alpha:1];
    [self.view addSubview:navView];
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-120/2, 20, 120, 44)];
    title.text = @"在线客服";
    title.backgroundColor = [UIColor clearColor];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:20];
    [navView addSubview:title];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.frame = CGRectMake(10, 27, 30, 30);
//    [back setTitle:@"返回" forState:UIControlStateNormal];
//    [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    back.backgroundColor = [UIColor clearColor];
    [back setBackgroundImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backToMonthlyVC) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:back];
    
    
    self.webView.scalesPageToFit = YES;
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.scalesPageToFit = YES;
    self.webView.scrollView.bounces  = NO;
    
    
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",self.url]];
    if (url == nil) {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *urlstr = [user objectForKey:@"kefuurl"];
        url = [NSURL URLWithString:[urlstr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
}
- (void)backToMonthlyVC
{
    [self.navigationController popViewControllerAnimated:YES];
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
