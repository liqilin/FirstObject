//
//  ExpressInfoBean.m
//  Operate
//
//  Created by user on 2017/11/15.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import "ExpressInfoBean.h"

@implementation ExpressInfoBean
-(id)init{
    self = [super init];
    if (self) {
        id
        _receivingName = @"";
        _receivingTel = @"";
        _zipCode = @"";
        _receivingAddress = @"";
        _orderType = @"";
        _remark = @"";
        _createTime = @"";
        _createUser = @"";
        _updateTime = @"";
        _updateUser = @"";
        _shardingFlag = @"";
        _province = @"";
        _city = @"";
        _county = @"";
        _expressNo = @"";
        _destCode = @"";
        _stationId = @"";
        _logisticsName = @"";
        _stationName = @"";
        _payMode = @"";
        _payAreaCode = @"";
        _monthCard = @"";
        _fromProvince = @"";
        _fromCity = @"";
        _fromCounty = @"";
        _fromAddress = @"";
        _fromName = @"";
        _fromTel = @"";
        _currentTime = @"";
    }
    return self;
}
@end
