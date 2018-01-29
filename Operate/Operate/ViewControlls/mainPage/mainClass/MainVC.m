//
//  MainVC.m
//  BlueTouch
//
//  Created by user on 15/1/13.
//  Copyright (c) 2015年 hanyachao. All rights reserved.
//

#import "MainVC.h"



@interface MainVC ()
{
    

}

@end


@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;

    self.view.backgroundColor = RGBA(232, 233, 232, 1);
    [self configViews];
  
    // Do any additional setup after loading the view.
}


- (void)configViews
{
    
    
    navbarView = [[NavTabBarView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 64)];
    
    
  //  NSLog(@"==%f",Screen_Width);
//    if (iOS_version >=6.1f) {
//        
//        navbarView.frame =   CGRectMake(0, 0, Screen_Width, 64);
//    }
    navbarView.delegate = self;
    navbarView.backgroundColor = [Util uiColorFromString:@"#33d793"];
    navbarView.leftImage = @"";

    navbarView.rigthtImage = @"";
    

    [self.view addSubview:navbarView];
    
  

   
    
    
}

#pragma mark-NavDelegate
//导航栏代理方法
- (void)delegateWith:(NavTabBarView *)tabbar and:(NSUInteger)idx WithCurrentBut:(UIButton *)currentBut
{
    switch (idx) {
        case NAVLEFTINDEX:
        {
          

            [self.navigationController popViewControllerAnimated:YES];
        }
            
            break;
            
        case NAVRIGHTINDEX:
        {
            
            


        }
            
            break;
        default:
            break;
    }
    
}
    


    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
