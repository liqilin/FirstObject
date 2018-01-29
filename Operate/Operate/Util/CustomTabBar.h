//
//  CustomTabBarViewController.h
//  HXPaiUser
//
//  Created by MAC on 14-1-8.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//自定义tabbar类
typedef enum
{
    SlideDirectionDown = 0,
    SlideDirectionUp
} SlideDirection;

@interface CustomTabBar : UIViewController<UINavigationControllerDelegate>

{
    //TabBar视图
    UIView *_tabView;
    
	//TabBar视图数组
	NSArray  *_viewControllers;
    
    //正常状态下的图片数组
//	NSArray  *_nomalImageArray;
    
    UIImageView *_scrollImgView;
    
    //TabBar被选中的索引
	int      _seletedIndex;
	
    //导航控制器中的视图数组
	NSArray  *_previousNavViewController;
    
//    NSArray *_hightImageArray;
}
/*
 描述的过程其实就是生成set和get方法的过程
 例如：
 描述了int seletedIndex;
 描述之后可以用self.seletedIndex赋值
 如果在.m里实现了一个 setSeletedIndex方法，那当用self.seletedIndex赋值
 的时候会不会调用setSeletedIndex这个方法？会调用
 */
@property (nonatomic,retain) NSArray  *previousNavViewController;

@property (nonatomic,retain) NSArray  *nomalImageArray;
@property (nonatomic,retain) NSArray  *hightImageArray;

@property (nonatomic,retain) NSArray  *titlesarray;

@property (nonatomic,retain) NSArray  *viewControllers;
@property (nonatomic,assign) int      seletedIndex;

- (void)tabBarButtonClicked:(id)sender;

- (void)showTabBar:(SlideDirection)direction animated:(BOOL)isAnimated;
- (void)hideTabBar:(SlideDirection)direction animated:(BOOL)isAnimated;





@end







