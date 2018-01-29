//
//  SaleOrderModel.h
//  Operate
//
//  Created by user on 2017/11/3.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface SaleOrderModel : BaseModel

/**
 * 订单号 Y
 */
@property (strong, nonatomic) NSString *orderNo;
/**
 * 订单商品总数量 Y
 */
@property (assign, nonatomic) NSInteger qty;
/**
 * 订单找零金额 N
 */
@property (strong, nonatomic) NSDecimalNumber *remainAmount;
/**
 * 订单应收总金额 Y
 */
@property (strong, nonatomic) NSDecimalNumber *allAmount;
/**
 * 订单实收总金额 Y 订单应收总金额+找零金额 默认 0.00
 */
@property (strong, nonatomic) NSDecimalNumber *amount;
/**
 * 订单商品明细
 */
@property (strong, nonatomic) NSArray *orderDtls;
/**
 * 订单商品收银信息
 */
@property (strong, nonatomic) NSArray *orderPaywayList;
/**
 * 创建时间 Y yyyy-MM-dd HH:mm:ss
 */
@property (strong, nonatomic) NSString *createTime;
/**
 * 收银时间 Y yyyy-MM-dd HH:mm:ss
 */
@property (strong, nonatomic) NSString *payTime;
/**
 * 打印次数
 * @return
 */
@property (assign, nonatomic) NSInteger printSum;
/**
 * 销售日期 Y yyyy-MM-dd
 */
@property (strong, nonatomic) NSString *outDate;
/**
 * 销售类型  订单业务类型 Y 0-正常销售 1-跨店销售 2-商场团购 (3-公司团购，暂不启用） 3-内购 4-员购 5-专柜团购 6-特卖销售 默认为0
 * @return
 */
@property (strong, nonatomic) NSString *businessTypeStr;
/**
 * 营业员姓名 N
 */
@property (strong, nonatomic) NSString *assistantName;
/**
 * 会员编号 N 有会员时必填
 */
@property (strong, nonatomic) NSString *vipNo;
/**
 门店名称
 */
@property (strong, nonatomic) NSString *shopName;
/**
 * 结算公司名称
 */
@property (strong, nonatomic) NSString *companyName;
/**
 * 订单备注
 * @return
 */
@property (strong, nonatomic) NSString *remark;
/**
 * 基本总积分
 */
@property (assign, nonatomic) NSInteger baseScore;

/**
 * 整单分摊总积分
 */
@property (assign, nonatomic) NSInteger proScore;

/**
 * 卡级别
 */
@property (strong, nonatomic) NSString *wildcardName;

/**
 * 小票号
 */
@property (strong, nonatomic) NSString *marketTicketNo;
@end
