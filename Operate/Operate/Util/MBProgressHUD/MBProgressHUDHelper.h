//
//  MBProgressHUDHelper.h
//  Ordering
//
//  Created by tiger on 14-4-25.
//  Copyright (c) 2014年 yshh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface MBProgressHUDHelper : NSObject
+ (void)showHudOverWindow:(NSString *)text hideTime:(CGFloat)time xOffset:(CGFloat)xOffset;

+ (void)showHud:(NSString *)text;
+ (void)showHud:(NSString *)text mode:(MBProgressHUDMode)mode;

+ (void)showHud:(NSString *)text hideTime:(CGFloat)time view:(UIView *)view;
+ (void)showHud:(NSString *)text hideTime:(CGFloat)time view:(UIView *)view mode:(MBProgressHUDMode)mode;
+ (void)showHud:(NSString *)text mode:(MBProgressHUDMode)mode xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset margin:(CGFloat)margin;

+ (void)showHud:(NSString *)text view:(UIView *)view;
+ (void)showHud:(NSString *)text view:(UIView *)view yOffset:(CGFloat)yOffset;

+ (void)showHudOverWindow:(NSString *)text;
+ (void)showHudOverWindow:(NSString *)text afterDelay:(CGFloat)delayTime;

// 用自定义视图来创建HUD
+ (void)showHud:(UIView *)customView andText:(NSString *)text view:(UIView *)view;
+ (void)showHud:(UIView *)customView andText:(NSString *)text view:(UIView *)view xOffset:(CGFloat)xOffset;

+ (void)newHUDInView:(UIView*)view;

+ (void)hideHUD;

+ (void)hideAllHUD;

+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated;
@end

