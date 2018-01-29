//
//  CustomerCards.h
//  Operate
//
//  Created by user on 2017/11/14.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import "BaseModel.h"

@interface CustomerCards : BaseModel
/**
 * levelNameStr : 银卡会员
 * accumulatedIntegral : 0
 * remainIntegral : 0
 */
/**
 * 品牌名称
 */
@property(nonatomic,strong) NSString  *brandName;
/**
 * 累计积分
 */
@property(nonatomic,assign) NSInteger  accumulatedIntegral;
/**
 * 有效积分
 */
@property(nonatomic,assign) NSInteger  remainIntegral;
@end
