//
//  UserModel.m
//  Operate
//
//  Created by user on 15/8/21.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super initWithAttributes:attributes];
    if (!self) {
        
        return nil;
        
        
    }
    /*
     @property(nonatomic,copy)NSString *goodid;
     @property(nonatomic,copy)NSString *newsthumb;
     
     
     @property(nonatomic,copy)NSString *title;
     @property(nonatomic,copy)NSString *content;
     @property(nonatomic,copy)NSString *createdate;
     */
    self.authorityUserDic = nilOrJSONObjectForKey(attributes, @"authorityUser");
    self.authorityUserList = nilOrJSONObjectForKey(attributes, @"authorityUserModuleDtoList");
//    self.goodid = nilOrJSONObjectForKey(attributes, @"id");
//    self.content = nilOrJSONObjectForKey(attributes, @"content");
//    self.createdate = nilOrJSONObjectForKey(attributes, @"createdate");
    
    
    return self;
    
}
@end
