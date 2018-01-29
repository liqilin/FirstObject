//
//  CustomTabBarViewController.m
//  HXPaiUser
//
//  Created by MAC on 14-1-8.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//
#define SLIDE_ANIMATION_DURATION 0.35

#import "CustomTabBar.h"
#import "Macro.h"

@implementation CustomTabBar
{
    UILabel *lab;
}
@synthesize viewControllers = _viewControllers;
@synthesize seletedIndex = _seletedIndex;
@synthesize previousNavViewController = _previousNavViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _seletedIndex = -1;
    }
    return self;
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	if (_seletedIndex == -1)
	{
        //用self.赋值默认会调set方法
		self.seletedIndex = 0;
	}
	else
	{
        //用self.赋值默认会调set方法
		self.seletedIndex = _seletedIndex;
	}

    _tabView = [[UIView alloc] initWithFrame:CGRectMake(0,Screen_Height - 48, Screen_Width, 48)];
    if (iOS_version > 7.0)
    {
        _tabView.frame = CGRectMake(0,Screen_Height - 48, Screen_Width, 48);

    }else{
        _tabView.frame = CGRectMake(0,Screen_Height - 68, Screen_Width, 48);

    }
    _tabView.backgroundColor = RGBA(38, 38, 38, 1);
//    tabBarBGImgView.backgroundColor = [UIColor blueColor];

    [self.view addSubview:_tabView];
    
//    UIImageView *tabBarBGImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inner_choose.png"]];
//    tabBarBGImgView.alpha = 1;
//    tabBarBGImgView.frame = CGRectMake(0, 0, 320, 48);
//    tabBarBGImgView.bounds = _tabView.bounds;
//    [_tabView addSubview:tabBarBGImgView];
//    [tabBarBGImgView release];
    
//    NSArray *labArr = [NSArray arrayWithObjects:@"资讯",@"通知",@"圈子",@"活动",@"产品", nil];
    for (int i = 0; i < self.titlesarray.count; i ++)
    {
        if (0 == i)
        {
            UIImage *scrollImage = [UIImage imageNamed:@"no_in.png"];
            _scrollImgView = [[UIImageView alloc] initWithImage:scrollImage];
//            _scrollImgView.alpha = .6;
            _scrollImgView.backgroundColor = [UIColor blackColor];
            _scrollImgView.bounds = CGRectMake(0, 0,(Screen_Width/_nomalImageArray.count),48);
            
            [_tabView addSubview:_scrollImgView];
            
        }
        UIImage *image = [UIImage imageNamed:[_nomalImageArray objectAtIndex:i]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = i + 2000000;
        [_tabView addSubview:imageView];
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 1000000 + i;
        btn.frame = CGRectMake((Screen_Width/_nomalImageArray.count) * i, 0, Screen_Width/_nomalImageArray.count, 48);
        [btn addTarget:self action:@selector(tabBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_tabView addSubview:btn];
        
        
        imageView.bounds = CGRectMake(0, 0, 24, 24);
        imageView.center = CGPointMake(btn.center.x, btn.center.y-5);
        
      
        
        lab = [[UILabel alloc] init];
        lab.bounds = CGRectMake(0, 0, (Screen_Width/_nomalImageArray.count), 20);
        lab.center = CGPointMake(imageView.frame.size.width/2, imageView.center.y + 12);
        lab.font = [UIFont systemFontOfSize:10];
        if (iOS_version > 7.0)
        {
            lab.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:12];
    
        }
        
//        lab.textColor = [UIColor colorWithRed:73.0/255 green:171.0/255 blue:227.0/255 alpha:1];
        if (0 == i)
        {
            
            lab.textColor = [UIColor whiteColor];
            
            _scrollImgView.center = btn.center;
            imageView.center = CGPointMake(btn.center.x, btn.center.y-5 );
        }else{
            lab.textColor = [UIColor colorWithRed:73.0/255 green:171.0/255 blue:227.0/255 alpha:1];
   
        }

        lab.alpha = .8;
        lab.tag = 1000 + i ;
        lab.backgroundColor = [UIColor clearColor];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.text = [self.titlesarray objectAtIndex:i];
        [imageView addSubview:lab];
        
        
    }
    
    
}
- (void)setSeletedIndex:(int)aIndex
{
    
    
    //如果索引值没有改变不做其他操作
	if (_seletedIndex == aIndex) return;
	
    //如果索引值改变了需要做操作
    /*
     安全性判断
     如果_seletedIndex表示当前显示的有视图
     需要把原来的移除掉，然后把对应的TabBar按钮设置为正常状态
     */
	if (_seletedIndex >= 0)
	{
        /*
         把视图控制器的视图移除掉
         但是数组中视图控制器的对象还在
         */
        //找出对应索引的视图控制器
		UIViewController *priviousViewController = [_viewControllers objectAtIndex:_seletedIndex];
        //移除掉
		[priviousViewController.view removeFromSuperview];
        
		
	}

    UIImageView *tempImgView1 = (UIImageView *)[self.view viewWithTag:aIndex + 2000000];
    UIImageView *tempImgView2 = (UIImageView *)[self.view viewWithTag:_seletedIndex + 2000000];
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^(void)
     {
         
         CGRect tempRect1 = tempImgView1.frame;
         tempRect1.origin.y -= 0;
         tempImgView1.frame = tempRect1;
         
         CGRect tempRect2 = tempImgView2.frame;
         tempRect2.origin.y += 0;
         tempImgView2.frame = tempRect2;
         
     }
    completion:^(BOOL finished){}
     ];
    
    
    //记录一下当前的索引
	_seletedIndex = aIndex;
	
    UIButton *btn = (UIButton *)[self.view viewWithTag:_seletedIndex + 1000000];
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^(void)
     {
         //根据压栈还是出栈设置动画效果
         _scrollImgView.center = CGPointMake(btn.center.x, btn.center.y);
     }
    completion:^(BOOL finished){}
     ];
	
    //获得对应的视图控制器
	UIViewController *currentViewController = [_viewControllers objectAtIndex:aIndex];
    //如果此条件成立表示当前是“导航控制器”
	if ([currentViewController isKindOfClass:[UINavigationController class]])
	{
        //设置导航控制器的代理
		((UINavigationController *)currentViewController).delegate = self;
	}
    //设置当前视图的大小
	currentViewController.view.frame = CGRectMake(0, 0, Screen_Width, self.view.bounds.size.height - 43);
	
    //添加到Tab上
	[self.view addSubview:currentViewController.view];
	
    //把视图放到TabBar下面
	[self.view sendSubviewToBack:currentViewController.view];
	
}

- (void)tabBarButtonClicked:(id)sender
{
    //获得索引
	UIButton *btn = (UIButton *)sender;
	int index = btn.tag - 1000000;
    
    
    /****************修改过******************/
    /*
     得到上一个高亮索引把图片改为正常状态
     
     */
    UILabel *label = (UILabel *)[self.view viewWithTag:self.seletedIndex + 1000];
    label.textColor =  [UIColor colorWithRed:92.0/255 green:172.0/255 blue:215.0/255 alpha:1];
    UIImageView *img = (UIImageView *)[self.view viewWithTag:self.seletedIndex + 2000000];
    img.image = [UIImage imageNamed:[_nomalImageArray objectAtIndex:self.seletedIndex]];
    //用self.赋值默认会调set方法
	self.seletedIndex = index;
    /*
     得到当前点击的按钮并切换图片使其变为高亮状态
     
     */
    UIImageView *img2 = (UIImageView *)[self.view viewWithTag:index + 2000000];
    img2.image = [UIImage imageNamed:[_hightImageArray objectAtIndex:index]];
    UILabel *hightlabel = (UILabel *)[self.view viewWithTag:index + 1000];
    hightlabel.textColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    UILabel *label = (UILabel *)[self.view viewWithTag:self.seletedIndex + 1000];
    label.textColor =  [UIColor whiteColor];
    UIImageView *img = (UIImageView *)[self.view viewWithTag:self.seletedIndex + 2000000];
    img.image = [UIImage imageNamed:[_nomalImageArray objectAtIndex:self.seletedIndex]];
}

#pragma mark -
#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    /*
     第一次加载根视图:previousNavViewController当前导航控制器里面的视图控制器数组
     之后显示视图:previousNavViewController操作前的视图控制器数组
     */
	if (!_previousNavViewController)
	{
        //导航控制器中的视图数组
		self.previousNavViewController = navigationController.viewControllers;
	}
	
	/*
     是否为压栈的标记，初始化为NO
     如果原来的控制器数不大于当前导航的视图控制器数表示是压栈
     */
	BOOL isPush = NO;
	if ([_previousNavViewController count] <= [navigationController.viewControllers count])
	{
		isPush = YES;
	}
	
    /*
     上一个视图控制器当压栈的时候底部条是否隐藏
     当前视图控制器当压栈的时候底部条是否隐藏
     这两个视图控制器有可能是同一个
     */
	BOOL isPreviousHidden = [[_previousNavViewController lastObject] hidesBottomBarWhenPushed];
	BOOL isCurrentHidden = viewController.hidesBottomBarWhenPushed;
    //    [[navigationController.viewControllers lastObject] hidesBottomBarWhenPushed]
	
    //重新记录当前导航器中的视图控制器数组
	self.previousNavViewController = navigationController.viewControllers;
	
    /*
     如果状态相同不做其他操作
     如果上一个显示NO，这个隐藏YES，则隐藏TabBar
     如果上一个隐藏YES，这个显示NO，则显示TabBar
     */
	if (!isPreviousHidden && !isCurrentHidden)
	{
		return;
	}
	else if(isPreviousHidden && isCurrentHidden)
	{
		return;
	}
	else if(!isPreviousHidden && isCurrentHidden)
	{
		//隐藏tabbar 压栈
		[self hideTabBar:isPush ? SlideDirectionDown : SlideDirectionUp  animated:animated];
	}
	else if(isPreviousHidden && !isCurrentHidden)
	{
		//显示tabbar 出栈
		[self showTabBar:isPush ? SlideDirectionDown : SlideDirectionUp animated:animated];
	}
	
}

/*
 显示底部TabBar相关
 需要重置当前视图控制器View的高度为整个屏幕的高度-TabBar的高度
 */
- (void)showTabBar:(SlideDirection)direction animated:(BOOL)isAnimated
{
	
    //执行动画
	[UIView animateWithDuration:isAnimated ? SLIDE_ANIMATION_DURATION : 0 delay:0 options:0 animations:^
	 {
/**********************修改***********************/
		 //动画效果
         if (iOS_version >7.0)
        {
            _tabView.frame = CGRectMake(0, self.view.bounds.size.height-48, Screen_Width, 48);
    
        }else{
            _tabView.frame = CGRectMake(0, self.view.bounds.size.height-48, Screen_Width, 48);

        }
         
	 }
    completion:^(BOOL finished)
	 {
         //动画结束时
         //重置当前视图控制器View的高度为整个屏幕的高度-TabBar的高度
		 UIViewController *currentViewController = [_viewControllers objectAtIndex:_seletedIndex];
		 CGRect viewRect = currentViewController.view.frame;
		 viewRect.size.height = self.view.bounds.size.height;
		 currentViewController.view.frame = viewRect;
	 }];
}

/*
 隐藏底部TabBar相关
 需要重置当前视图控制器View的高度为整个屏幕的高度
 */
- (void)hideTabBar:(SlideDirection)direction animated:(BOOL)isAnimated
{
    //获得当前视图控制器
	UIViewController *currentViewController = [_viewControllers objectAtIndex:_seletedIndex];
	//重置高度
	CGRect viewRect = currentViewController.view.frame;
	viewRect.size.height = self.view.bounds.size.height;
	currentViewController.view.frame = viewRect;
	
	
    //采用Block的形式开启一个动画
	[UIView animateWithDuration:isAnimated ? SLIDE_ANIMATION_DURATION : 0 delay:0 options:0 animations:^(void)
     {
         //根据压栈还是出栈设置动画效果
		 CGRect tempRect = _tabView.frame;
		 tempRect.origin.y = self.view.frame.origin.y + self.view.bounds.size.height * (direction == SlideDirectionDown ? 1 : -1);
		 _tabView.frame = CGRectMake(0, self.view.frame.size.height, Screen_Width, 48);
		 
     }
    completion:^(BOOL finished){}
     ];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}




@end














