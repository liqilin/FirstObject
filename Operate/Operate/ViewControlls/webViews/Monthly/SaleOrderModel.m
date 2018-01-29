//
//  SaleOrderModel.m
//  Operate
//
//  Created by user on 2017/11/3.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import "SaleOrderModel.h"

@implementation SaleOrderModel
- (id)init
{
    self = [super init];
    _orderNo = @"";
    _createTime = @"";
    _payTime = @"";
    _outDate = @"";
    _businessTypeStr = @"";
    _assistantName = @"";
    _vipNo = @"";
    _shopName = @"";
    _companyName = @"";
    _remark = @"";
    _wildcardName = @"";
    _marketTicketNo = @"";
    
    _qty = 0;
    _remainAmount = [NSDecimalNumber decimalNumberWithString:@""];
    _allAmount = [NSDecimalNumber decimalNumberWithString:@""];
    _amount = [NSDecimalNumber decimalNumberWithString:@""];
    _printSum = 0;
    _baseScore = 0;
    _proScore = 0;
    
    return self;
}
@end
