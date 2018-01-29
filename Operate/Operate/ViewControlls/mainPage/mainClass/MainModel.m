//
//  MainModel.m
//  EasyLesson
//
//  Created by user on 15/5/28.
//  Copyright (c) 2015年 yachao. All rights reserved.
//

#import "MainModel.h"

@implementation MainModel

- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
//    self.id = nilOrJSONObjectForKey(attributes, @"id") ;
    return self;
}

//GET
+ (void)getModelArrayWithPath:(NSString *)path WithParams:(NSDictionary *)params WithBlock:(void (^)(NSArray *resultArray, NSDictionary *dataDict, NSError *errorr))block{
    
    [HTTPService GetHttpToServerWith:path WithParameters:params success:^(NSDictionary *dic) {
        
        NSMutableArray *objectArray = [NSMutableArray array];

        if ([[dic objectForKey:@"data"] isEqual:[NSNull null]]) {
            
            if (block)
            {
                block([NSArray array],dic, nil);
            }
 
            return ;
            
        }
        
        MainModel *data = [[[self class] alloc] initWithAttributes:[dic objectForKey:@"data"]];
        [objectArray addObject:data];

        NSString *code = [dic valueForKeyPath:@"errorMessage"];
        
        if ([code isEqualToString:@""]) {
            if (block)
            {
                block([NSArray arrayWithArray:objectArray],dic, nil);
            }
        }else{
            
            if (block)
            {
                block([NSArray array],dic, nil);
            }
 
        }

    } error:^(NSError *error) {
        if (block)
        {
            block([NSArray array],nil, error);
        }

    }];
    
}

+ (void)getModelMoreArrayWithPath:(NSString *)path WithParams:(NSDictionary *)params WithBlock:(void (^)(NSArray *resultArray, NSDictionary *dataDict, NSError *errorr))block{
    
    [HTTPService GetHttpToServerWith:path WithParameters:params success:^(NSDictionary *dic) {
        
        NSMutableArray *objectArray = [NSMutableArray array];
        
//        NSLog(@"dict=%@",dic);
        
        for (NSDictionary *attributes in [dic objectForKey:@"data"]) {
            
            
            MainModel *data = [[[self class] alloc] initWithAttributes:attributes];
            [objectArray addObject:data];
        }
    
        
        NSString *code = [dic valueForKeyPath:@"status"];
        
        if ([code isEqualToString:@"success"]) {
            if (block)
            {
                block([NSArray arrayWithArray:objectArray],dic, nil);
            }
        }else{
            
            if (block)
            {
                block([NSArray array],dic, nil);
            }
            
        }
        
    } error:^(NSError *error) {
        if (block)
        {
            block([NSArray array],nil, error);
        }
        
    }];

}


/**
 
 POST Array
 */
+ (void)postModelArrayWithPathPost:(NSString *)path WithParams:(NSDictionary *)params WithBlock:(void (^)(NSArray *resultArray, NSDictionary *dataDict, NSError *errorr))block{
    


    [HTTPService POSTHttpToServerWith:path WithParameters:params success:^(NSDictionary *dic) {
        
        NSMutableArray *objectArray = [NSMutableArray array];
        
        MainModel *data = [[[self class] alloc] initWithAttributes:[dic objectForKey:@"data"]];
        [objectArray addObject:data];
        
        NSString *code = [dic valueForKeyPath:@"status"];
        
        if ([code isEqualToString:@"success"]) {
            if (block)
            {
                block([NSArray arrayWithArray:objectArray],dic, nil);
            }
        }else{
            
            if (block)
            {
                block([NSArray array],dic, nil);
            }
            
        }

    } error:^(NSError *error) {
        if (block)
        {
            block([NSArray array],nil, error);
        }

    }];
    

}


@end
