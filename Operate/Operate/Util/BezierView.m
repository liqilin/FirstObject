//
//  BezierView.m
//  HNRuMi
//
//  Created by 韩亚周 on 15/12/3.
//  Copyright (c) 2015年 HYZ. All rights reserved.
//

#import "BezierView.h"


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBA(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

@interface BezierView ()

@property (nonatomic, strong) NSLayoutConstraint   *lineY;
@property (nonatomic, strong) UIImageView          *lineImageView;

@end

@implementation BezierView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _lineImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _lineImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _lineImageView.image = [UIImage imageNamed:@"codeLine.png"];
        [self addSubview:_lineImageView];
        
        [self addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"H:|-4-[_lineImageView]-4-|"
                              options:1.0
                              metrics:nil
                              views:NSDictionaryOfVariableBindings(_lineImageView)]];
        [self addConstraint:[NSLayoutConstraint
                             constraintWithItem:_lineImageView
                             attribute:NSLayoutAttributeHeight
                             relatedBy:NSLayoutRelationEqual
                             toItem:nil
                             attribute:NSLayoutAttributeHeight
                             multiplier:1.0
                             constant:4.0f]];
        _lineY = [NSLayoutConstraint
                  constraintWithItem:_lineImageView
                  attribute:NSLayoutAttributeTop
                  relatedBy:NSLayoutRelationEqual
                  toItem:self
                  attribute:NSLayoutAttributeTop
                  multiplier:1.0
                  constant:0.0];
        [self addConstraint:_lineY];
        /*间隔还是0.02秒*/
        uint64_t interval = 0.02 * NSEC_PER_SEC;
        /*创建一个专门执行timer回调的GCD队列*/
        dispatch_queue_t queue = dispatch_queue_create("my queue", 0);
        /*创建Timer*/
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        /*使用dispatch_source_set_timer函数设置timer参数*/
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 0), interval, 0);
        /*设置回调*/
        dispatch_source_set_event_handler(_timer, ^(){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(_lineY.constant>=CGRectGetHeight(self.frame)-4){
                    _lineY.constant = 0;
                }else{
                    _lineY.constant = _lineY.constant+4;
                }
            });
        });
//        dispatch_resume(_timer);
    }
    return self;
}

- (void)start{
    dispatch_resume(_timer);
    dispatch_async(dispatch_get_main_queue(), ^{
        _lineY.constant = 0;
        _lineImageView.hidden = NO;
    });
}
- (void)stop{
//    dispatch_source_cancel(_timer);
    dispatch_suspend(_timer);
    dispatch_async(dispatch_get_main_queue(), ^{
        _lineY.constant = self.bounds.size.height/2;
        _lineImageView.hidden = NO;
    });
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat height = CGRectGetHeight(rect);
    CGFloat width = CGRectGetWidth(rect);
    /*左上角*/
    [path moveToPoint:CGPointMake(0 , 0)];
    [path addLineToPoint:CGPointMake(20, 0)];
    [path moveToPoint:CGPointMake(0 , 0)];
    [path addLineToPoint:CGPointMake(0, 20)];
    /*右上角*/
    [path moveToPoint:CGPointMake(width , 0)];
    [path addLineToPoint:CGPointMake(width, 20)];
    [path moveToPoint:CGPointMake(width-20 , 0)];
    [path addLineToPoint:CGPointMake(width, 0)];
    /*左下角*/
    [path moveToPoint:CGPointMake(0 , height-20)];
    [path addLineToPoint:CGPointMake(0, height)];
    [path moveToPoint:CGPointMake(0 , height)];
    [path addLineToPoint:CGPointMake(20, height)];
    /*右下角*/
    [path moveToPoint:CGPointMake(width-20 , height)];
    [path addLineToPoint:CGPointMake(width, height)];
    [path moveToPoint:CGPointMake(width, height)];
    [path addLineToPoint:CGPointMake(width, height-20)];
    [_cornerLineColor?_cornerLineColor:UIColorFromRGB(0x5987F8) setStroke];
    path.lineWidth = _lineWidth?_lineWidth:4.0f;
    [path stroke];
}

@end
