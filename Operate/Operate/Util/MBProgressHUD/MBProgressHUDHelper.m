//
//  MBProgressHUDHelper.m
//  Ordering
//
//  Created by tiger on 14-4-25.
//  Copyright (c) 2014年 yshh. All rights reserved.
//

#import "MBProgressHUDHelper.h"
#import "MBProgressHUD.h"
#import <Foundation/Foundation.h>

@implementation MBProgressHUDHelper

static MBProgressHUD *hud = nil;

+ (void)showHud:(NSString *)text
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16.0f];
    hud.margin = 10.f;
    hud.xOffset = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? 0.f : 0.0f;
    hud.yOffset = 0.f;
    hud.removeFromSuperViewOnHide = YES;
}

+ (void)showHud:(NSString *)text mode:(MBProgressHUDMode)mode
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = mode;
    hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16.0f];
    hud.margin = 10.f;
    hud.yOffset = -50.f;
    hud.removeFromSuperViewOnHide = YES;
}

+ (void)showHud:(NSString *)text hideTime:(CGFloat)time view:(UIView *)view
{
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.mode = MBProgressHUDModeIndeterminate;
	hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16.0f];
	hud.margin = 10.f;
	hud.yOffset = -50.f;
	hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:time];
}

+ (void)showHud:(NSString *)text hideTime:(CGFloat)time view:(UIView *)view mode:(MBProgressHUDMode)mode
{
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.mode = mode;
	hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16.0f];
	hud.margin = 10.f;
	hud.yOffset = -50.f;
	hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:time];
}

+ (void)showHud:(NSString *)text mode:(MBProgressHUDMode)mode xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset margin:(CGFloat)margin
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = mode;
    hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16.0f];
    hud.margin = margin;
    hud.xOffset = xOffset;
    hud.yOffset = yOffset;
    hud.removeFromSuperViewOnHide = YES;
}

+ (void)showHudOverWindow:(NSString *)text hideTime:(CGFloat)time xOffset:(CGFloat)xOffset
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
	hud.mode = MBProgressHUDModeText;
	hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16.0f];
	hud.margin = 10.f;
    hud.xOffset = xOffset;
	hud.yOffset = -50.f;
	hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:time];
}

+ (void)showHud:(NSString *)text view:(UIView *)view yOffset:(CGFloat)yOffset
{
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16.0f];
    hud.detailsLabelFont = [UIFont systemFontOfSize:16.0f];
	hud.margin = 10.f;
//    hud.xOffset = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? 0.f : ((kSingleton(detailVCWidth) == 800) ? 50.f : 0.0f);
	hud.yOffset = yOffset;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:2];
}

+ (void)showHud:(NSString *)text view:(UIView *)view
{
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.mode = MBProgressHUDModeText;
	hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16.0f];
	hud.margin = 10.f;
//    hud.xOffset = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? 0.f : ((kSingleton(detailVCWidth) == 800) ? 50.f : 0.0f);
	hud.yOffset = 0.f;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:2];
}

+ (void)showHudOverWindow:(NSString *)text afterDelay:(CGFloat)delayTime
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
	hud.mode = MBProgressHUDModeText;
	hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16.0f];
	hud.margin = 10.f;
    hud.xOffset = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? 0.f :0.f;
	hud.yOffset = 0.f;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:delayTime];
}

+ (void)showHudOverWindow:(NSString *)text
{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
	hud.mode = MBProgressHUDModeText;
	hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16.0f];
	hud.margin = 10.f;
    hud.xOffset = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? 0.f : 0.f;
	hud.yOffset = 0.f;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:2];
}

+ (void)showHud:(UIView *)customView andText:(NSString *)text view:(UIView *)view xOffset:(CGFloat)xOffset
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = customView;
    hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16.0f];
    hud.margin = 10.f;
    hud.xOffset = xOffset ? xOffset :0.f;
    hud.yOffset = 0.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

+ (void)showHud:(UIView *)customView andText:(NSString *)text view:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.mode = MBProgressHUDModeCustomView;
    hud.customView = customView;
	hud.detailsLabelText = text;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16.0f];
	hud.margin = 10.f;
    hud.xOffset = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? 0.f :  0.0f;
	hud.yOffset = 0.f;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:2];
}

#pragma mark - Progress

+ (void)newHUDInView:(UIView*)view
{
    if(hud !=nil && hud.superview)
    {
        hud.hidden=NO;
    }
    else{
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.xOffset = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? 0.f :0.f;
    }
    
}

+ (void)hideHUD
{
//     UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
//    [MBProgressHUD hideAllHUDsForView:window animated:NO];
    hud.hidden = YES;
}

+ (void)hideAllHUD
{
     UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [MBProgressHUD hideAllHUDsForView:window animated:NO];
}

+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated
{
    return [MBProgressHUD hideHUDForView:view animated:animated];
}

@end

