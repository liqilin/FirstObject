//
//  SalesDtlBeanModel.m
//  Operate
//
//  Created by user on 2017/11/3.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import "SalesDtlBeanModel.h"

@implementation SalesDtlBeanModel
- (id)init
{
    self = [super init];
    _itemCode = @"";
    _itemName = @"";
    _colorName = @"";
    _colorNo = @"";
    _sizeNo = @"";
    _brandNo = @"";
    _styleNo = @"";
    
    
    _qty = 0;
    _tagPrice = 0;
    _discPrice = 0;
    _settlePrice = 0;
    _itemDiscount = 0;
    _amount = 0;
    
    return self;
}
@end
