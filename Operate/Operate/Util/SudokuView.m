//
//  SudokuView.m
//  EasyLesson
//
//  Created by user on 15/5/6.
//  Copyright (c) 2015年 yachao. All rights reserved.
//

#import "SudokuView.h"
#import "Macro.h"

#define HEIGHT_BUT 70
#define WIDTH_BUT (Screen_Width-100)/4

#define BUT_WIDTH 45
@interface SudokuView()
{
    
    UIView *backView;
    
    NSMutableArray *buttons;
    
    
    
    
}
@end


//static float viewWidth = Screen_Width;

static float viewHeight = 220;

@implementation SudokuView
@synthesize delegate = _delegate;


- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        viewHeight = Screen_Height-120;
//        viewWidth = frame.size.width;
        
        [self configView];
    }
    return self;
    
}

- (void)configView
{
    
 
    backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, viewHeight)];
    
    backView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:backView];
    
    buttons = [NSMutableArray array];
    
    
}
- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    int col = (Screen_Width- WIDTH_BUT*4)/5;
    int row = (viewHeight - HEIGHT_BUT*4)/5;
    
    [buttons removeAllObjects];
    
        

    [self.sudokuNumbers enumerateObjectsUsingBlock:^(NSString * imageName, NSUInteger idx, BOOL *stop) {
        
        float x = col + idx%4 *(col + WIDTH_BUT);
        float y = row + idx/5 *(row +HEIGHT_BUT);

        UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(x+10, y, WIDTH_BUT, WIDTH_BUT)];
        
        [backView addSubview:tempView];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:self.sudokuHeights[idx]] forState:UIControlStateHighlighted];

        [button addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(tempView.frame.size.width/2-30, 10, BUT_WIDTH, BUT_WIDTH);
        
        [tempView addSubview:button];
        
        [buttons addObject:button];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tempView.frame.size.width/2-50, button.frame.origin.y+button.frame.size.height, 100, 40)];
        label.backgroundColor = [UIColor clearColor];
        label.center = CGPointMake(button.center.x, label.center.y);
        
        label.font = [UIFont systemFontOfSize:13];
        label.text  = self.titleNumbers[idx];
        
        label.textAlignment = NSTextAlignmentCenter;
        
        [tempView addSubview:label];
        
    }];
    
}

- (void)buttonPress:(UIButton *)sender
{
  NSUInteger buttonIndex =  [buttons indexOfObject:sender];
    
//    NSLog(@"%s",__func__);
    
    
    if ([_delegate respondsToSelector:@selector(clickButtonwithSudokuView:currentIndex:)]) {
        
        [_delegate clickButtonwithSudokuView:self currentIndex:(int)buttonIndex];
    }
//    switch (buttonIndex) {
//        case 0:
//            
//            break;
//        case 0:
//            
//            break;
//
//        case 0:
//            
//            break;
//
//            
//            
//        default:
//            break;
//    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
