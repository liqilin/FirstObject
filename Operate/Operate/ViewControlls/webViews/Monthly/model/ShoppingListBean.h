//
//  ShoppingListBean.h
//  Operate
//
//  Created by user on 2017/11/14.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import "BaseModel.h"

@interface ShoppingListBean : BaseModel
@property(nonatomic,assign) NSInteger orderSource; // 订单来源    0-正常   1-优购
@property(nonatomic,strong) NSString  *title;  // 提货小票标题  正常提货小票为：销售单，优购提货小票为：购物清单
@property(nonatomic,strong) NSString  *orderNo; // 订单号   正常提货小票为：订单号，优购提货小票为：优购订单号
@property(nonatomic,strong) NSString  *thirdOrderNo; // 优购第三方订单号，京东、淘宝、唯品会等等，优购独有
@property(nonatomic,strong) NSString  *receivingName; // 收货人
@property(nonatomic,strong) NSString  *receivingNameReturn; // 退货收货人  有够独有
@property(nonatomic,assign) long payTime; // 收银时间
@property(nonatomic,strong) NSString  *receivingAddress; // 退货地址
@property(nonatomic,strong) NSString  *zipCode;  // 退货邮编， 优购独有
@property(nonatomic,strong) NSString  *receivingTel;  // 退货联系电话， 优购独有
@property(nonatomic,assign) NSInteger qty;  // 商品总数
@property(nonatomic,strong) NSString  *expressNo;  // 快递单号  正常提货小票独有
@property(nonatomic,strong) NSString  *printTicketRemark;  // 小票打印备注       正常提货小票为：销售门店中的门店参数小票打印备注；  优购提货小票为：通过一级渠道是优购的默认用优购的提示，否则用其他渠道的提示；
@property(nonatomic,strong) NSArray  *orderDtls;
@end
