//
//  ShoppingListBean.m
//  Operate
//
//  Created by user on 2017/11/14.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import "ShoppingListBean.h"

@implementation ShoppingListBean
- (id)init
{
    self = [super init];
    if (self) {
        _orderSource = 0;
        _title  = @"";
        _orderNo = @"";
        _thirdOrderNo = @"";
        _receivingName = @"";
        _receivingNameReturn = @"";
        _payTime = 0;
        _receivingAddress = @"";
        _zipCode = @"";
        _receivingTel = @"";
        _qty = 0;
        _expressNo = @"";
        _printTicketRemark = @"";
        
    }
    return self;
}
@end
