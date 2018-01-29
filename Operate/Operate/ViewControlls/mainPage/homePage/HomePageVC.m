//
//  HomePageVC.m
//  Operate
//
//  Created by user on 15/8/20.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import "HomePageVC.h"
#import "SudokuView.h"
#import "UserModel.h"

#import "MonthlyVC.h"
#import "DailyVC.h"

@interface HomePageVC()<SudokuViewDelegate>
{
    
    SudokuView *sudokuview;
}

@end

@implementation HomePageVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    

//    navbarView.frame = CGRectMake(0, 60, Screen_Width, 44);
    navbarView.titleName = @"首页";
    navbarView.leftImage = @"main_tile_logo.png";

    sudokuview = [[SudokuView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(navbarView.frame), Screen_Width, Screen_Height-120)];
    sudokuview.delegate = self;
    
    sudokuview.sudokuNumbers = @[@"shoprollout_normal.png",@"shoprollout_normal.png",@"shopgetgoods_normal.png",@"shoprollout_normal.png"];
    
    sudokuview.sudokuHeights = @[@"shoprollout_onclick.png",@"shoprollout_onclick.png",@"shopgetgoods_onclick.png",@"shoprollout_onclick.png"];
    sudokuview.titleNumbers =
                                                @[@"销售月报",@"销售日报",@"审核活动",@"创建活动"];
    
    [self.view addSubview:sudokuview];
    
    
    

}

#pragma mark-SudokuViewDelegate
- (void)clickButtonwithSudokuView:(SudokuView *)sudokuView currentIndex:(int)index
{
    
    
    NSString *urlStr = [JumpObject getHttpUrl];
    
    
    
    switch (index) {
        case 0:{
            
            MonthlyVC *mothly = [[MonthlyVC alloc] init];
            
            mothly.modeldictary = [JumpObject getUserModel].authorityUserDic;
            mothly.infoUrl = [NSString stringWithFormat:@"%@/mobile_ope_f/html/pages/monthly_sales/index.html",urlStr];
            NSLog(@"");
            
            mothly.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:mothly animated:YES];
            
            
        }
            
//
            break;
        case 1:{
            
            DailyVC *daily = [[DailyVC alloc] init];
            daily.hidesBottomBarWhenPushed = YES;
            
            daily.modeldictary = [JumpObject getUserModel].authorityUserDic;

            daily.infoUrl = [NSString stringWithFormat:@"%@/mobile_ope_f/html/pages/daily_sales/index.html",urlStr];

//            daily.infoUrl = @"http://172.17.215.110:3200/mobile_ope_f/html/pages/daily_sales/index.html";

//            daily.infoUrl = @"http://172.17.210.53:3500/mpos/mobile_ope_f/html/pages/daily_sales/index.html";
            [self.navigationController pushViewController:daily animated:YES];

        }
            
            break;

        case 2:{
//            AuditactivityVC *audit = [[AuditactivityVC alloc] init];
//            audit.hidesBottomBarWhenPushed = YES;
//            audit.infoUrl = [NSString stringWithFormat:@"%@/mobile_ope_f/html/pages/audit_activity/index.html",urlStr];
//            audit.modeldictary = [JumpObject getUserModel].authorityUserDic;
//
//
//            [self.navigationController pushViewController:audit animated:YES];

        }
            break;

        case 3:{
//            CreateactivityVC *creat = [[CreateactivityVC alloc] init];
//            creat.hidesBottomBarWhenPushed = YES;
//            creat.modeldictary = [JumpObject getUserModel].authorityUserDic;
//
//            creat.infoUrl = [NSString stringWithFormat:@"%@/mobile_ope_f/html/pages/create_activity/index.html",urlStr];
//
//            [self.navigationController pushViewController:creat animated:YES];

        }
            break;

            
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
}

@end
