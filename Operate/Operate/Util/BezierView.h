//
//  BezierView.h
//  HNRuMi
//
//  Created by 韩亚周 on 15/12/3.
//  Copyright (c) 2015年 HYZ. All rights reserved.
//

#import <UIKit/UIKit.h>


/*!二维码扫描页面的框*/
@interface BezierView : UIView
/*!线的颜色  默认  0x5987F8*/
@property (nonatomic, strong) UIColor               *cornerLineColor;
/*!线的宽度 默认  4.0f*/
@property (nonatomic, assign) CGFloat               lineWidth;
/*!扫描线的定时器*/
@property (nonatomic, strong) dispatch_source_t     timer;
- (void)start;
- (void)stop;
@end
