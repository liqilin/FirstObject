//
//  OcOrderDtlDto.m
//  Operate
//
//  Created by user on 2017/11/14.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import "OcOrderDtlDto.h"

@implementation OcOrderDtlDto
- (id)init
{
    self = [super init];
    if (self) {
        _itemName = @"";
        _qty = 0;
        _thirdSpec = @"";
    }
    return self;
}
@end
