//
//  CreateactivityVC.h
//  Operate
//
//  Created by user on 15/8/24.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import "MainWedView.h"

#import <JavaScriptCore/JavaScriptCore.h>

@protocol JS2Export <JSExport>

- (void)loginPage;
@end

//创建活动
@interface ForgetPasswordVC : MainWedView<JS2Export>
@property(nonatomic,strong) JSContext *jsContext;


@property(nonatomic,strong) NSDictionary *modeldictary;

@end
