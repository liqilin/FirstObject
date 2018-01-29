//
//  SetUrlVC.m
//  Operate
//
//  Created by user on 15/8/20.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import "SetUrlVC.h"
#import "Macro.h"
#import "SetUrlCell.h"
#import "EditSetUrlVC.h"
@interface SetUrlVC()<UITableViewDataSource,UITableViewDelegate>
{
 
//    UITextField *urlText;
////    
//    NSString *urlString;
    
    UITableViewCellEditingStyle _editingStyle;
    BOOL isEditState;

}

@property(nonatomic,strong)UITableView *tableView;

@property(nonatomic,strong)NSMutableArray *dataMy;

@end

@implementation SetUrlVC


- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    isEditState = YES;
    
    navbarView.leftImage = @"icon_back.png";
    navbarView.titleName = @"服务器选择";
    self.view.backgroundColor = RGBA(230, 230, 230,1);
    
    self.dataMy = [[NSMutableArray alloc] initWithCapacity:2];
    NSLog(@"%@",[DataBase selectAllDataFromDataBase]);
    
    self.dataMy  = [DataBase selectAllDataFromDataBase];
    UIButton *urlBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [urlBut setFrame:CGRectMake(Screen_Width-70, 22, 70 , 35)];
    [urlBut setBackgroundColor:[UIColor clearColor]];
    
    
    [urlBut setTitle:@"新增" forState:UIControlStateNormal];
    urlBut.titleLabel.font = [UIFont systemFontOfSize:15];
    
    [urlBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [urlBut addTarget:self action:@selector(addUrlButPress:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:urlBut];

    
    
    [self configView];
}
- (void)addUrlButPress:(UIButton *)sender
{
    
    
    EditSetUrlVC *newUrl = [[EditSetUrlVC alloc] init];
    
    newUrl.infoTitle = @"新增服务器";
    newUrl.currentViewControllerType = PushCurrentViewControllerTypeNew;
    
    [self.navigationController pushViewController:newUrl animated:YES];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.tableView.editing = NO;
    
    self.dataMy  = [DataBase selectAllDataFromDataBase];

    [self.tableView reloadData];
    
    
}
- (void)configView
{
    
    
    
  
    _editingStyle = UITableViewCellEditingStyleDelete;
    
//    UIButton *urlBut = [UIButton buttonWithType:UIButtonTypeCustom];
//    [urlBut setFrame:CGRectMake(Screen_Width-70, 20, 70 , 35)];
//    [urlBut setBackgroundColor:[UIColor clearColor]];
//    
//    
//    [urlBut setTitle:@"新增" forState:UIControlStateNormal];
//    
//    [urlBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    
//    [urlBut addTarget:self action:@selector(selectedUrlButPress:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:urlBut];
//    NSArray *tempArray = @[@"编辑",@"新增"];
//
//    
//    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(navbarView.frame), Screen_Height, 44)];
//    buttonView.backgroundColor  = [UIColor  clearColor];
//    buttonView.layer.cornerRadius = 3;
//    buttonView.clipsToBounds = YES;
//    
//    [self.view addSubview:buttonView];
//    
//    __block float maxIndex = 0;
//    [tempArray enumerateObjectsUsingBlock:^(NSString * title, NSUInteger idx, BOOL *stop) {
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button setFrame:CGRectMake(idx*(Screen_Width/2), 0, Screen_Width/2-1 , 44)];
//        [button setBackgroundColor:RGBA(238, 238, 238, 1)];
//        
//        if (idx == 0) {
//
//            maxIndex = CGRectGetMaxX(button.frame);
//            
//        }
//        
//        button.tag = 1401 + idx;
//        
//        
//        button.titleLabel.font = [UIFont systemFontOfSize:17];
//        [button setTitle:title forState:UIControlStateNormal];
//        
//        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        
//        [button addTarget:self action:@selector(selectedButPress:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [buttonView addSubview:button];
//        
//        
//        
//    }];
//
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(maxIndex, CGRectGetMaxY(navbarView.frame), 2, 44)];
//    line.backgroundColor  = [UIColor  blackColor];
//    
//    [buttonView addSubview:line];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(navbarView.frame), Screen_Width, Screen_Height-CGRectGetMaxY(navbarView.frame)) style:UITableViewStylePlain];

    if (iOS_version >6.2)
    {
        
        self.tableView.frame = CGRectMake(0, CGRectGetMaxY(navbarView.frame), Screen_Width, Screen_Height-CGRectGetMaxY(navbarView.frame));
        
    }else{
        self.tableView.frame = CGRectMake(0, CGRectGetMaxY(navbarView.frame), Screen_Width, Screen_Height-CGRectGetMaxY(navbarView.frame));
        
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.allowsSelectionDuringEditing = YES;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    //    self.tableView.footerHidden = YES;
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    //    UIView *view = [];
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}



#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    return [self.dataMy count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellInderfier = @"cell";
    
    SetUrlCell *cell = [tableView dequeueReusableCellWithIdentifier:cellInderfier];
    if (cell == nil) {
        
        cell = [[SetUrlCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellInderfier];
    }
    DataUrlModel *model = [self.dataMy objectAtIndex:indexPath.row];
    
    cell.titleLabel.text =model.urlType;
    
    cell.contentLabel.text = model.titleName;
    cell.datetime.text = model.urlStr;
    
    NSString *currentUrl =  [[NSUserDefaults standardUserDefaults] objectForKey:@"setUrl"];
    if ([currentUrl isEqualToString:model.urlStr]) {
        
        cell.backgroundColor = RGBA(220, 220, 220,1);
    }else{
        
        cell.backgroundColor = [UIColor whiteColor];
  
    }

    return cell;
    
}

#pragma mark ---deit delete---


// 指定哪一行可以编辑 哪行不能编辑
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 设置 哪一行的编辑按钮 状态 指定编辑样式
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _editingStyle;
}

// 判断点击按钮的样式 来去做添加 或删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 删除的操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        DataUrlModel *model = [self.dataMy objectAtIndex:indexPath.row];
        [self.dataMy removeObjectAtIndex:indexPath.row];
//        [_icoArray removeObjectAtIndex:indexPath.row];
//
        
        
        [DataBase deleteDataFromDataBase:model];
        
        
        NSArray *indexPaths = @[indexPath]; // 构建 索引处的行数 的数组
        // 删除 索引的方法 后面是动画样式
        [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:(UITableViewRowAnimationLeft)];
        
    }
    
    // 添加的操作
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        
        NSArray *indexPaths = @[indexPath];
        [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:(UITableViewRowAnimationRight)];
        
    }
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61;    //cell.xib里的高度
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    
    DataUrlModel *model = [self.dataMy objectAtIndex:indexPath.row];
    if(isEditState == NO)
    {
        EditSetUrlVC *newUrl = [[EditSetUrlVC alloc] init];
        
        newUrl.infoTitle = @"修改地址";
        newUrl.currentViewControllerType = PushCurrentViewControllerTypeEdit;
        
        
        newUrl.urlModel = model;
        
        [self.navigationController pushViewController:newUrl animated:YES];

        
    }else{
        
        [[NSUserDefaults standardUserDefaults] setObject:model.urlStr forKey:@"setUrl"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [JumpObject savehttpUrlString:model.urlStr];
        
        
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
  
}



/*改变删除按钮的title*/
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

//- (void)selectedUrlButPress:(UIButton *)sender
//{
//    
//    EditSetUrlVC *newUrl = [[EditSetUrlVC alloc] init];
//    
//    newUrl.infoTitle = @"新增地址";
//    newUrl.currentViewControllerType = PushCurrentViewControllerTypeNew;
//    
//    [self.navigationController pushViewController:newUrl animated:YES];
//    
//}


#pragma mark-
- (void)selectedButPress:(UIButton *)sender
{
    
    switch (sender.tag - 1401) {
        case 0:{
            
            BOOL isseleceed= !sender.isSelected;
            
            [sender setSelected:isseleceed];
            
//            if (isseleceed) {
//                
//                [self.tableView endEditing:YES];
//                
//                _editingStyle = UITableViewCellEditingStyleDelete;
//            }else{
//                
//                [self.tableView endEditing:NO];
//
//            }
            
            
            [self.tableView setEditing:!self.tableView.editing animated:YES];
            
            if (self.tableView.editing)
            {
                
                [sender setTitle:@"完成" forState:UIControlStateNormal];
                
                isEditState = NO;
                
            }
            else
            {
                
                isEditState = YES;

                [sender setTitle:@"编辑" forState:UIControlStateNormal];

                
            }
            
            
        }
            
            break;
            
        case 1:{
            EditSetUrlVC *newUrl = [[EditSetUrlVC alloc] init];
            
            newUrl.infoTitle = @"新增地址";
            newUrl.currentViewControllerType = PushCurrentViewControllerTypeNew;
            
            [self.navigationController pushViewController:newUrl animated:YES];
            
        }
            
            break;

        default:
            break;
    }
    
    
}
//- (void)delegateWith:(NavTabBarView *)tabbar and:(NSUInteger)idx WithCurrentBut:(UIButton *)currentBut
//{
//    
//    switch (idx) {
//        case NAVLEFTINDEX:
//        {
//            
//            
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//            
//            break;
//            
//        case NAVRIGHTINDEX:
//        {
//            
//            
//          
//            
//            
//        }
//            
//            break;
//        default:
//            break;
//    }
//
//    
//}
- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}


@end
