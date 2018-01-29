//
//  AuditactivityVC.h
//  Operate
//
//  Created by user on 15/8/24.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import "MainWedView.h"
//审计活动
#import <JavaScriptCore/JavaScriptCore.h>

@protocol TestExport <JSExport>

- (void)loginPage;
@end
//月报




@interface RegisterVC : MainWedView<TestExport>


@property(nonatomic,strong) JSContext *jsContext;

@property(nonatomic,strong) NSDictionary *modeldictary;
@end
