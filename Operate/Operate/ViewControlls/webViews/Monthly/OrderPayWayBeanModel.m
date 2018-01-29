//
//  OrderPayWayBeanModel.m
//  Operate
//
//  Created by user on 2017/11/3.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import "OrderPayWayBeanModel.h"

@implementation OrderPayWayBeanModel
-(id)init
{
    self= [super init];
    if (self) {
        _amount = 0;
        _payName = @"";
    }
    return self;
}
@end
