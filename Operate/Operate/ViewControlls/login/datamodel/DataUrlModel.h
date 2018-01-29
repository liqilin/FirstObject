//
//  DataUrlModel.h
//  Operate
//
//  Created by user on 15/9/2.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataUrlModel : NSObject
//服务器名称
@property(nonatomic,copy)NSString *titleName;
//服务器类型
@property(nonatomic,copy)NSString *urlType;
//服务器了链接
@property(nonatomic,copy)NSString *urlStr;


@property(nonatomic,copy)NSString *urlID;


@property(nonatomic,copy)NSString *currentVersion;

@end
