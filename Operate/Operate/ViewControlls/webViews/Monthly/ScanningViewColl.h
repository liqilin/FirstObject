//
//  ScanningViewColl.h
//  Operate
//
//  Created by user on 16/4/20.
//  Copyright © 2016年 hanyc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
@class ScanningViewColl;

@protocol ScanDelegate <NSObject>

- (void)backTheScanViewWith:(NSString *)stringValue;


@end


@interface ScanningViewColl : UIViewController

@property(nonatomic,assign)NSInteger cordType;
@property(nonatomic) id<ScanDelegate> delegate;


@property(nonatomic,strong) JSContext * jscontext;

@end
