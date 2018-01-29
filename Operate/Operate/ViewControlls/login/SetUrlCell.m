//
//  SetUrlCell.m
//  Operate
//
//  Created by user on 15/9/2.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import "SetUrlCell.h"
#import "Macro.h"

@implementation SetUrlCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 70, 60)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        
        self.titleLabel.textColor = RGBA(2, 47, 126, 1);
        
        
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.text = @"开发环境";//NSLocalizedString(@"Hidden devices", nil);
        [self addSubview:self.titleLabel];
        
        
        
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.titleLabel.frame), CGRectGetMinY(self.titleLabel.frame), 70, 60)];
        self.contentLabel.backgroundColor = [UIColor clearColor];
        self.contentLabel.font = [UIFont systemFontOfSize:14];
        self.contentLabel.text = @"开发环境测试";//NSLocalizedString(@"The device is visible to others", nil);
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.textColor = RGBA(91, 103, 141, 1);
        
        
        [self addSubview:self.contentLabel];
        
        //        授课老师
        self.datetime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.contentLabel.frame),CGRectGetMinY(self.titleLabel.frame), Screen_Width-CGRectGetMaxX(self.contentLabel.frame), 60)];
        self.datetime.backgroundColor = [UIColor clearColor];
        
        self.datetime.textColor = RGBA(144, 151, 144, 1);
        
        self.datetime.numberOfLines = 0;
        self.datetime.font = [UIFont systemFontOfSize:13];
        self.datetime.text = @"http://183.56.163.30:3721/zentao/www/index.php";//NSLocalizedString(@"Hidden devices", nil);
        [self addSubview:self.datetime];
    }
    
    return self;
    
}

@end
