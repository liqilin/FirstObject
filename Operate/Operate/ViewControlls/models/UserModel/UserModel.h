//
//  UserModel.h
//  Operate
//
//  Created by user on 15/8/21.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import "MainModel.h"

@interface UserModel : MainModel

@property(nonatomic,strong)NSDictionary *authorityUserDic;

@property(nonatomic,strong)NSArray *authorityUserList;

@end
