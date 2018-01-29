//
//  EditSetUrlVC.m
//  Operate
//
//  Created by user on 15/9/2.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import "EditSetUrlVC.h"
#define LAB_WIDTH 70
@interface EditSetUrlVC()<UITextFieldDelegate>
{
    
    //    背景图
    UIScrollView *bicScrollView;
    //    输入框试图
//    UIView *textFieldView;
    //    用户名密码
    UITextField *userNameText;
    
    UITextField *setUrlText;

    UITextField *setServerTypeText;

    NSString *userNameStr;
    
    NSString *setUrlString;
//    种类选择
//    NSString *typeString;
    
    
}
@end

@implementation EditSetUrlVC

- (void)viewDidLoad{
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwasHidden:) name:UIKeyboardDidHideNotification object:nil];

    
    
    navbarView.leftImage = @"icon_back.png";
    navbarView.titleName = self.infoTitle;

//    if (self.currentViewControllerType == PushCurrentViewControllerTypeEdit) {
//        
//        
//    }else{
//        
//        typeString = @"开发环境";
//    }
    [self configview];
    
}

- (void)configview
{
    
    
    bicScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(navbarView.frame) , Screen_Width, Screen_Height-64)];
    bicScrollView.backgroundColor = RGBA(239, 240, 241, 1);
    bicScrollView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardDown:)];
    [bicScrollView addGestureRecognizer:tap];
    
    
    [self.view addSubview:bicScrollView];
    
    UIView *textBCView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 153)];
    textBCView.backgroundColor = [UIColor whiteColor];
    [bicScrollView addSubview:textBCView];
    
    
    
    UILabel *serverLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5,LAB_WIDTH  , 40)];
    serverLab.text = @"应用场景:";
    serverLab.font = [UIFont systemFontOfSize:16];
    serverLab.backgroundColor = [UIColor clearColor];
    [textBCView addSubview:serverLab];
    
    
    setServerTypeText = [[UITextField alloc] initWithFrame:CGRectMake(90, 0, CGRectGetWidth(textBCView.frame)-90, 50)];
    setServerTypeText.delegate = self;
    
    setServerTypeText.placeholder = @"如实施环境";
    [setServerTypeText addTarget:self action:@selector(retuanKeyMothod:) forControlEvents:UIControlEventEditingDidEndOnExit];
    setServerTypeText.tag = 1003;
    setServerTypeText.font = [UIFont systemFontOfSize:14];
    
    setServerTypeText.backgroundColor = [UIColor clearColor];
    setServerTypeText.returnKeyType = UIReturnKeyNext;
    setServerTypeText.borderStyle = UITextBorderStyleNone;
    
    [textBCView addSubview:setServerTypeText];

    
    UIView *serverTypelinse = [[UIView alloc] initWithFrame:CGRectMake(0, 51,Screen_Width , 0.3)];
    serverTypelinse.backgroundColor = [Util uiColorFromString:@"#c2d0ca"];
//    serverTypelinse.hidden = NO;

//    serverTypelinse.backgroundColor = [UIColor blackColor];
    [textBCView addSubview:serverTypelinse];

    
    UILabel *urlNameLab = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(serverTypelinse.frame)+5,LAB_WIDTH  , 40)];
    urlNameLab.text = @"服务器名:";
    urlNameLab.font = [UIFont systemFontOfSize:16];
    urlNameLab.backgroundColor = [UIColor clearColor];
    [textBCView addSubview:urlNameLab];

    userNameText = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMinX(setServerTypeText.frame), CGRectGetMaxY(serverTypelinse.frame), CGRectGetWidth(setServerTypeText.frame), 50)];
    userNameText.delegate = self;
    if (self.currentViewControllerType == PushCurrentViewControllerTypeEdit) {
        
        userNameText.text = self.urlModel.titleName;
        
        
        userNameStr = self.urlModel.titleName;
    }else{
        
        userNameText.placeholder = @"如TATA";
    }
    [userNameText addTarget:self action:@selector(retuanKeyMothod:) forControlEvents:UIControlEventEditingDidEndOnExit];
    userNameText.tag = 1001;
    userNameText.font = [UIFont systemFontOfSize:14];
    userNameText.backgroundColor = [UIColor clearColor];
    userNameText.returnKeyType = UIReturnKeyNext;
    userNameText.borderStyle = UITextBorderStyleNone;
    [textBCView addSubview:userNameText];
    
    
//    UIImageView *serveTypelinse = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(userNameText.frame),CGRectGetWidth(self.view.frame) , 0.3)];
//    serveTypelinse.backgroundColor = [Util uiColorFromString:@"#c2d0ca"];
//    
//    serveTypelinse.backgroundColor = [UIColor blackColor];
//
//    [textBCView addSubview:serveTypelinse];

    
    UIView *userlinse = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(userNameText.frame),CGRectGetWidth(textBCView.frame) , 0.3)];
    userlinse.hidden = NO;
    
    userlinse.backgroundColor = [Util uiColorFromString:@"#c2d0ca"];
    [textBCView addSubview:userlinse];

    
    UILabel *urlLab = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(userlinse.frame)+5,LAB_WIDTH  , 40)];
    urlLab.text = @"IP地址:";
    urlLab.font = [UIFont systemFontOfSize:16];
    urlLab.backgroundColor = [UIColor clearColor];
    [textBCView addSubview:urlLab];

    
    setUrlText = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMinX(setServerTypeText.frame), CGRectGetMaxY(userlinse.frame)+1, CGRectGetWidth(userNameText.frame), CGRectGetHeight(userNameText.frame))];
    setUrlText.delegate = self;
    if (self.currentViewControllerType == PushCurrentViewControllerTypeEdit) {
        
        setUrlText.text = self.urlModel.urlStr;
        setUrlString = self.urlModel.urlStr;

        
    }else{
        
        setUrlText.placeholder = @"服务器地址";
    }
    [setUrlText addTarget:self action:@selector(retuanKeyMothod:) forControlEvents:UIControlEventEditingDidEndOnExit];
    setUrlText.tag = 1002;
    setUrlText.font = [UIFont systemFontOfSize:14];

    setUrlText.backgroundColor = [UIColor clearColor];
    setUrlText.returnKeyType = UIReturnKeyDone;
    setUrlText.borderStyle = UITextBorderStyleNone;

    [textBCView addSubview:setUrlText];

    
    UIView *urlLinse = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(setUrlText.frame),CGRectGetWidth(textBCView.frame) , 0.3)];
    urlLinse.backgroundColor = [Util uiColorFromString:@"#c2d0ca"];
    
    urlLinse.hidden = NO;

    [textBCView addSubview:urlLinse];

    
    
    UIButton *urlBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [urlBut setFrame:CGRectMake((Screen_Width-(Screen_Width-50))/2, CGRectGetMaxY(textBCView.frame)+30,Screen_Width-50 , 35)];
    
    
    urlBut.titleLabel.font = [UIFont systemFontOfSize:15];
    [urlBut setTitle:@"提交" forState:UIControlStateNormal];
    
     [urlBut setBackgroundColor:[Util uiColorFromString:@"#33d793"]];
    [urlBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [urlBut addTarget:self action:@selector(selectedUrlButPress:) forControlEvents:UIControlEventTouchUpInside];
    
    [bicScrollView addSubview:urlBut];
}


//- (int)getCurrentUrlTypeIn:(NSString *)type
//{
//    int idx = 1;
//    
//    if ([type isEqualToString:@"正式环境"]) {
//        
//        idx = 0;
//        
//    }else if ([type isEqualToString:@"开发环境"]){
//        idx = 1;
//  
//    }else if ([type isEqualToString:@"测试环境"]){
//        idx = 2;
// 
//    }else if ([type isEqualToString:@"生产环境"]){
//        
//        idx = 3;
//
//    }
//    
//    return idx;
//    
//}

//static int onOneIdx = 1202;
//
//
//- (void)selectedUrlTypeButPress:(UIButton *)sender
//{
//    UIButton *button = (UIButton *)[self.view viewWithTag:onOneIdx];
//    [button setBackgroundColor:[UIColor whiteColor]];
//        
//    
//    sender.backgroundColor = [UIColor blueColor];
//    switch (sender.tag - 1201) {
//        case 0://正式环境
//            
//            typeString = @"正式环境";
//
//            
//            break;
//            
//        case 1://开发
//            typeString = @"开发环境";
//
//            break;
//        case 2://测试
//            typeString = @"测试环境";
//
//            break;
//        case 3://生产
//            typeString = @"生产环境";
//
//            break;
//            
//        default:
//            break;
//    }
//  
//    onOneIdx = sender.tag;
//    
//}
//完成按钮
- (void)selectedUrlButPress:(UIButton *)sender
{
    
    [self.view endEditing:YES];
    if (userNameStr.length == 0 || userNameStr == nil || [userNameStr isEqualToString:@""]) {
        
        
        
        
        [Util  showHud:@"服务名称不能为空" withView:self.view];
        return;
        
    }
    if (setUrlString.length == 0 || setUrlString == nil || [setUrlString isEqualToString:@""]) {
        
        [Util  showHud:@"服务器地址不能为空" withView:self.view];
        
        
        return;
    }
    
    if (setServerTypeText.text.length == 0 || setServerTypeText.text == nil || [setServerTypeText.text isEqualToString:@""]) {
        
        [Util  showHud:@"环境不能为空" withView:self.view];
        
        return;
    }

    if (self.currentViewControllerType == PushCurrentViewControllerTypeNew) {
        
        DataUrlModel *model = [[DataUrlModel alloc] init];
        model.titleName = userNameStr;
        
        if ([setUrlString hasPrefix:@"http://"]||[setUrlString hasPrefix:@"https://"]) {
            
            
        }else{
            setUrlString = [NSString stringWithFormat:@"http://%@",setUrlString];
        }
        model.urlStr = setUrlString;
        model.urlType = setServerTypeText.text;
        
        [DataBase insertIntoDataBase:model];
    }else{
        self.urlModel.titleName = userNameStr;
        self.urlModel.urlStr = setUrlString;
        self.urlModel.urlType = setServerTypeText.text;
        
        [DataBase updateFromDataBase:self.urlModel];
        
    }
 
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
    
}
- (void)keyboardDown:(UIGestureRecognizer *)gesture
{
    [userNameText resignFirstResponder];
    
    [setUrlText resignFirstResponder];

}


#pragma mark-keyboard
- (void)keyboardwasShown:(NSNotification*)notification{
    
    [UIView animateWithDuration:.0005 animations:^{
        bicScrollView.contentOffset = CGPointMake(0, 0);
        
    }];
    
    
    NSLog(@"keyboardwasShown");
}


- (void)keyboardwasHidden:(NSNotification*)notification{
    
    NSLog(@"keyboardwasHidden");
    [UIView animateWithDuration:.5 animations:^{
        
        bicScrollView.contentOffset = CGPointMake(0, 0);
    }];
    
}

- (void)retuanKeyMothod:(UITextField *)sender
{
    switch (sender.tag) {
        case 1001:
            
            [setUrlText becomeFirstResponder];
            NSLog(@"next");
            break;
        case 1002:
            
            [setUrlText resignFirstResponder];
            
            [setServerTypeText resignFirstResponder];
            [userNameText resignFirstResponder];
            
            break;
        case 1003:
            
            [setServerTypeText becomeFirstResponder];
            
            
            break;

        default:
            break;
    }
    
}


#pragma mark-TextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    if (textField == userNameText) {
        
        [userNameText resignFirstResponder];
        
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField == userNameText) {
        
        userNameStr = textField.text;
        
        
    }else if (textField == setUrlText){
        
        if ([textField.text hasPrefix:@"http://"]||[textField.text hasPrefix:@"https://"]) {
            
            setUrlString = textField.text;

        }else{
            setUrlString = [NSString stringWithFormat:@"http://%@",textField.text];

        }
        
        
    }
    else if (textField == setServerTypeText){
    
        
        setServerTypeText.text = textField.text;
        
        
    }
    
    



}


- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}
@end
