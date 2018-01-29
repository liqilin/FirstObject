//
//  SetUrlCell.h
//  Operate
//
//  Created by user on 15/9/2.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetUrlCell : UITableViewCell

@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *contentLabel;

@property(nonatomic,strong)UILabel *datetime;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
