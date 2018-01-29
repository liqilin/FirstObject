//
//  NavTabBarView.m
//  BlueTouch
//
//  Created by user on 15/1/15.
//  Copyright (c) 2015年 hanyachao. All rights reserved.
//

#import "NavTabBarView.h"

#import "Macro.h"

@interface NavTabBarView()
{
    
    
    UIView *barView;
    
//    NSArray *array;
    
}


@end


static NSUInteger const buttonWidth = 32;
@implementation NavTabBarView

@synthesize delegate = _delegate;

- (instancetype )initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        [self configView];
        
    }
    
    return self;
    
}



- (CGRect)screenWith
{
    
    return [UIScreen mainScreen].bounds;
}
- (void)configView
{
    
    barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,Screen_Width , 44)];
    
    barView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:barView];
    
    
    
//    [array enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
//     
//        
//        
//    }];
}

- (void)layoutSubviews
{
    
    UIButton * leftButton =
    [UIButton buttonWithType:UIButtonTypeCustom];
    
    leftButton.frame =
    CGRectMake(5, 2, buttonWidth+6, buttonWidth);
    
    if (iOS_version >= 7.0f) {
        
        leftButton.frame =  CGRectMake(8, 25, buttonWidth-6, buttonWidth-6);
    }
    
//    [leftButton setBackgroundColor:[UIColor redColor]];

//    if ([self.leftImage isEqualToString:@""]) {
//        
//        [leftButton setTitle:self.leftName forState:UIControlStateNormal];
//        
//    }else{
    
        [leftButton setImage:[UIImage imageNamed:self.leftImage] forState:UIControlStateNormal];
        [leftButton setImage:[UIImage imageNamed:self.leftImageH] forState:UIControlStateHighlighted];
        
//    }
    
    leftButton.tag = 676;


      [barView addSubview:leftButton];
    
    UIButton * rightButton =
    [UIButton buttonWithType:UIButtonTypeCustom];
    
    rightButton.frame =
    CGRectMake([self screenWith].size.width-55, leftButton.frame.origin.y, buttonWidth+10, buttonWidth);
    
    rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
//    if ([self.rigthtImage isEqualToString:@""]) {
//        
//        [rightButton setTitle:self.rithtName forState:UIControlStateNormal];
//
//    }else{
    
        [rightButton setImage:[UIImage imageNamed:self.rigthtImage] forState:UIControlStateNormal];
        
        [rightButton setImage:[UIImage imageNamed:self.rigthtImageH] forState:UIControlStateHighlighted];

//    }
    
    
    rightButton.backgroundColor = [UIColor clearColor];
    [barView addSubview:rightButton];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.center.x-70, leftButton.frame.origin.y,140, buttonWidth)];
    
    
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor  = [UIColor clearColor];
    label.text = self.titleName;
    
    label.textColor = [UIColor whiteColor];
    
    rightButton.tag = 677;
    [barView addSubview:label];
    
    
    [leftButton addTarget:self action:@selector(leftButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    [rightButton addTarget:self action:@selector(rightButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    [super layoutSubviews];

}

- (void)leftButtonPress:(UIButton *)sender
{
    
    if ([self.leftImage isEqualToString:@""] || self.leftImage == nil) {
        
        return;
        
    }
    if ([_delegate respondsToSelector:@selector(delegateWith:and:WithCurrentBut:)]) {

    [_delegate delegateWith:self and:sender.tag WithCurrentBut:sender];
    
    }
}

- (void)rightButtonPress:(UIButton *)sender
{
    
    
    if ([self.rigthtImage isEqualToString:@""] ) {
        
        return;
        
    }

    if ([_delegate respondsToSelector:@selector(delegateWith:and:WithCurrentBut:)]) {
        
        [_delegate delegateWith:self and:sender.tag WithCurrentBut:sender];

    }
     

}


@end
