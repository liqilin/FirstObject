//
//  OcOrderDtlDto.h
//  Operate
//
//  Created by user on 2017/11/14.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import "BaseModel.h"

@interface OcOrderDtlDto : BaseModel
@property(nonatomic,strong) NSString  *itemName;

@property(nonatomic,assign) NSInteger  qty;

@property(nonatomic,strong) NSString  *thirdSpec;
@end
