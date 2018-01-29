//
//  SudokuView.h
//  EasyLesson
//
//  Created by user on 15/5/6.
//  Copyright (c) 2015年 yachao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SudokuView;

@protocol SudokuViewDelegate <NSObject>

@optional

- (void)clickButtonwithSudokuView:(SudokuView *)sudokuView currentIndex:(int)index;


@end

@interface SudokuView : UIView

@property(nonatomic)id <SudokuViewDelegate>delegate;


@property(nonatomic,strong)NSArray *sudokuNumbers;


@property(nonatomic,strong)NSArray *sudokuHeights;

@property(nonatomic,strong)NSArray *titleNumbers;


@end
