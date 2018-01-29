//
//  NavTabBarView.h
//  BlueTouch
//
//  Created by user on 15/1/15.
//  Copyright (c) 2015年 hanyachao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NavTabBarView;
@protocol NavTabBarViewDelegate<NSObject>

@optional

- (void)delegateWith:(NavTabBarView *)tabbar and:(NSUInteger)idx WithCurrentBut:(UIButton *)currentBut;


@end

@interface NavTabBarView : UIView

@property(nonatomic,copy)NSString *leftImage;

@property(nonatomic,copy)NSString *rigthtImage;

@property(nonatomic,copy)NSString *leftImageH;

@property(nonatomic,copy)NSString *rigthtImageH;

@property(nonatomic,copy)NSString *titleName;





@property(nonatomic)id delegate;


@end
