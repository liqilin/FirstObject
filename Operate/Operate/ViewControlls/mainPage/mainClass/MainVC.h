//
//  MainVC.h
//  BlueTouch
//
//  Created by user on 15/1/13.
//  Copyright (c) 2015年 hanyachao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Macro.h"
#import "NavTabBarView.h"

#define NAVLEFTINDEX 676

#define NAVRIGHTINDEX 677


@interface MainVC : UIViewController <NavTabBarViewDelegate>
{
    
    NavTabBarView *navbarView;

}






@end
