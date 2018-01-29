//
//  EditSetUrlVC.h
//  Operate
//
//  Created by user on 15/9/2.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import "MainVC.h"
#import "DataUrlModel.h"
typedef enum {
   PushCurrentViewControllerTypeEdit= 0,
    PushCurrentViewControllerTypeNew
}PushCurrentViewControllerType;
@interface EditSetUrlVC : MainVC


@property(nonatomic,copy)NSString *infoTitle;


@property(nonatomic,strong)DataUrlModel *urlModel;

@property(nonatomic,assign)PushCurrentViewControllerType currentViewControllerType;

@end
