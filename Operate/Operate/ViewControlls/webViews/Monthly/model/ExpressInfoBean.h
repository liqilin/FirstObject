//
//  ExpressInfoBean.h
//  Operate
//
//  Created by user on 2017/11/15.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import "BaseModel.h"

@interface ExpressInfoBean : BaseModel

@property(nonatomic,strong)NSString *id;
@property(nonatomic,strong)NSString *orderNo;
@property(nonatomic,strong)NSString *receivingName;
@property(nonatomic,strong)NSString *receivingTel;
@property(nonatomic,strong)NSString *zipCode;
@property(nonatomic,strong)NSString *receivingAddress;
@property(nonatomic,strong)NSString *orderType;
@property(nonatomic,strong)NSString *remark;
@property(nonatomic,strong)NSString *createTime;
@property(nonatomic,strong)NSString *createUser;
@property(nonatomic,strong)NSString *updateTime;
@property(nonatomic,strong)NSString *updateUser;
@property(nonatomic,strong)NSString *shardingFlag;
@property(nonatomic,strong)NSString *province;
@property(nonatomic,strong)NSString *city;
@property(nonatomic,strong)NSString *county;
@property(nonatomic,strong)NSString *expressNo;
@property(nonatomic,strong)NSString *destCode;
@property(nonatomic,strong)NSString *stationId;
@property(nonatomic,strong)NSString *logisticsName;
@property(nonatomic,strong)NSString *stationName;
@property(nonatomic,strong)NSString *payMode;
@property(nonatomic,strong)NSString *payAreaCode;
@property(nonatomic,strong)NSString *monthCard;
@property(nonatomic,strong)NSString *fromProvince;
@property(nonatomic,strong)NSString *fromCity;
@property(nonatomic,strong)NSString *fromCounty;
@property(nonatomic,strong)NSString *fromAddress;
@property(nonatomic,strong)NSString *fromName;
@property(nonatomic,strong)NSString *fromTel;
@property(nonatomic,strong)NSString *currentTime;
@end
