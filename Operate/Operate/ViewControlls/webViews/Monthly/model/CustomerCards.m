//
//  CustomerCards.m
//  Operate
//
//  Created by user on 2017/11/14.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import "CustomerCards.h"

@implementation CustomerCards
-(id)init{
    self = [super init];
    if (self) {
        _accumulatedIntegral = 0;
        _brandName = @"";
        _remainIntegral = 0;
    }
    return self;
}
@end
