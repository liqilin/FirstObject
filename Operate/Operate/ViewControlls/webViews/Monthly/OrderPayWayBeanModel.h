//
//  OrderPayWayBeanModel.h
//  Operate
//
//  Created by user on 2017/11/3.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface OrderPayWayBeanModel : BaseModel

/**
 * 商品总金额 Y (结算价-减价)*数量 默认 0.00 付款
 */
@property (assign, nonatomic) double amount;
/**
 * 付款人
 */
@property (strong, nonatomic) NSString *payName;
@end
