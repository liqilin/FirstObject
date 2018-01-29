//
//  SalesDtlBeanModel.h
//  Operate
//
//  Created by user on 2017/11/3.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface SalesDtlBeanModel : BaseModel
/**
 * 商品编码 Y
 */
@property (strong, nonatomic) NSString *itemCode;
/**
 * 商品牌价
 */
@property (assign, nonatomic) double tagPrice;

/**
 * 商品折扣价 Y
 */
@property (assign, nonatomic) double discPrice;
/**
 * 商品结算价 Y
 */
@property (assign, nonatomic) double settlePrice;

/**
 * 商品数量 Y
 */
@property (assign, nonatomic) NSInteger qty;
/**
 * 商品名称
 */
@property (strong, nonatomic) NSString *itemName;

/**
 * 商品颜色
 */
@property (strong, nonatomic) NSString *colorName;

/**
 * 商品颜色编码
 */
@property (strong, nonatomic) NSString *colorNo;

/**
 * 商品折数
 */
@property (assign, nonatomic) double itemDiscount;

/**
 * 商品尺码 规格
 */
@property (strong, nonatomic) NSString *sizeNo;

/**
 * 商品总金额 Y (结算价-减价)*数量 默认 0.00 付款
 */
@property (assign, nonatomic) double amount;

/**
 * 商品品牌编码
 */
@property (strong, nonatomic) NSString *brandNo;

/**
 * 商品款号
 */
@property (strong, nonatomic) NSString *styleNo;
@end
