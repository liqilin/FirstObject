//
//  MainWedView.h
//  EasyLesson
//
//  Created by user on 15/5/19.
//  Copyright (c) 2015年 yachao. All rights reserved.
//

#import "MainVC.h"
#import <UIKit/UIKit.h>
@interface MainWedView : UIViewController<UIWebViewDelegate,UINavigationControllerDelegate>
{
    UIActivityIndicatorView *_activityIndicatorView;
}

@property (retain, nonatomic)  UIWebView *webView;
@property (nonatomic,copy)NSString *infoUrl;
@property (nonatomic,copy)NSString *infoTitle;
@property (nonatomic,copy)NSString *infoId;


@end
