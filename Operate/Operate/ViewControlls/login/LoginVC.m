//
//  LoginVC.m
//  Operate
//
//  Created by user on 15/8/20.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import "LoginVC.h"
#import "SetUrlVC.h"
#import "UserModel.h"
#import "DeviceUtil.h"
#import <sys/utsname.h>
#import "PrintViewController.h"
#import "MBProgressHUDHelper.h"
#import "Macro.h"



@interface LoginVC ()<UITextFieldDelegate>
{
//    背景图
    UIScrollView *bicScrollView;
//    输入框试图
    UIView *textFieldView;
    
    
    UIView *showDeviceStateView;
    UIButton *closeBtn;
//    用户名密码
    UITextField *userNameText;
    
    UITextField *passwedText;
    
    
    NSString *userNameStr;
    NSString *passWedStr;
    
    UILabel *versonLab;
    NSString  *updateUrl;
   
}
@property (nonatomic,copy)NSString *devNo;//设备编号
@property (nonatomic,copy)NSString *devName;//设备名称
@property (nonatomic,copy)NSString *loginUser;//登录机构
@property (nonatomic,copy)NSString *devKinds;//设备类型
@property (nonatomic,copy)NSString *devModel;//设备型号
@property (nonatomic,copy)NSString *system;//操作系统
@property (nonatomic,copy)NSString *app;//应用业务
@property (nonatomic,copy)NSString *devState;//设备状态
@property (nonatomic,copy)NSString *devRemark;//设备备注
@end


@implementation LoginVC

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    //添加通知（监听键盘的出现和隐藏）
//    iskeyboarshow = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwasHidden:) name:UIKeyboardDidHideNotification object:nil];

    NSString *urlstr =  [JumpObject getHttpUrl];
    
    //从服务器获取UUID
    [DeviceUtil getNewUUID];
    
    [Util showIndeterminateHud:@"加载中..." withView:self.view];
    //

    
    [HTTPService GetHttpToServerWith:[NSString stringWithFormat:@"%@/app/user/center/getAppVersion",urlstr] WithParameters:nil success:^(NSDictionary *dic) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        if ([[dic objectForKey:@"data"] isEqual:[NSNull null]]) {
            

            return ;
            
        }
        NSString *dataDic = [dic objectForKey:@"data"];
        
        [JumpObject saveserverVersionString:dataDic];
        
        
        [self updataTheVersionName];

        
    } error:^(NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        
    }];

    [self configView];
    [self updataTheCheckVersion];
    self.view.backgroundColor = [UIColor whiteColor];
    navbarView.backgroundColor = [UIColor clearColor];
}
- (void)updataTheCheckVersion
{
    NSDictionary * dict =
    @{@"appNo":@"MPS",@"appType":@"ios",@"currentVer":[Util getAppShortVersion]};
    
    NSString *urlstr =  [JumpObject getHttpUrl];
    
    [HTTPService GetHttpToServerWith:[NSString stringWithFormat:@"%@/app/checkVersion",urlstr] WithParameters:dict success:^(NSDictionary *dic) {
        
        NSLog(@"%@",[dic objectForKey:@"errorMessage"]);
        
        if ([[dic objectForKey:@"errorCode"] integerValue] == 0) {
            
            
            if ([[dic objectForKey:@"data"] isEqual:[NSNull null]]) {
                
                return ;
            }
            
            NSDictionary *dataDic = [dic objectForKey:@"data"];
            
            if ([[dataDic objectForKey:@"isUpgrade"]  isEqual:[NSNull null]]) {
                return;
            }
            if ([[dataDic objectForKey:@"isUpgrade"] intValue]  == 0) {
                return;
            }
            NSString *title = [NSString stringWithFormat:@"版本更新(当前版本:%@)", [Util getAppShortVersion]];
            updateUrl = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",[dataDic objectForKey:@"upadteURL"]];
            NSString *msg = [NSString stringWithFormat:@"\n有最新的版本:%@，请更新\n\n", [dataDic objectForKey:@"latestVersion"]];
            
            if ([[UIDevice currentDevice].systemVersion floatValue]>=8.0) {
                UIAlertController *alertc = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
                [alertc addAction:[UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];
                    exit(0);
                }]];
                [alertc addAction:[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    exit(0);
                }]];
                [self presentViewController:alertc animated:YES completion:^{
                    
                }];
                
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"更新", nil];
                alert.tag = 1711;
                [alert show];
            }
        }
    } error:^(NSError *error) {
    }];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1711) {
        
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];
            exit(0);
        }else{
            exit(0);
        }
    }
    
}

- (void)updataTheVersionName
{
 
    NSString *serverVersion = [JumpObject getServersionString];

//    CGSize size = [Util getStringWidthWithStringLenth:serverVersion Withfont:10];
    
//    if (Screen_Height == 736) {
//        
//        versonLab.frame = CGRectMake(Screen_Width/2-size.width/2, versonLab.frame.origin.y,size.width  , size.height);
//    }
//    if (Screen_Height == 667) {
//        
//        versonLab.frame = CGRectMake(Screen_Width/2-size.width/2, CGRectGetHeight(imageView.frame)-140,size.width  , size.height);
//    }
//    
//    if (Screen_Height == 480) {
//        versonLab.frame = CGRectMake(Screen_Width/2-size.width/2, CGRectGetHeight(imageView.frame)-65,size.width  , size.height);
//        
//        
//    }
    versonLab.font = [UIFont systemFontOfSize:10];

    versonLab.text = [NSString stringWithFormat:@"版本号：%@",serverVersion];
    
}

- (void)afterDelayView
{
    [self configView];
}

- (void)configView
{
    
//    [bicScrollView removeFromSuperview];
    
    
    if (bicScrollView == nil) {
        
        CGFloat Y = CGRectGetMaxY(navbarView.frame)-CGRectGetHeight(navbarView.frame);
        bicScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,Y, Screen_Width, Screen_Height)];
//        bicScrollView.backgroundColor = [Util uiColorFromString:@"#33d793"];
        bicScrollView.backgroundColor = [UIColor whiteColor] ;
        bicScrollView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardDown:)];
        [bicScrollView addGestureRecognizer:tap];
        [self.view addSubview:bicScrollView];

    }

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_top_bacground.jpg"]];
    imageView.frame = CGRectMake(0, 0, Screen_Width, SCROLLVIEW_HEIGHT);
    
    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    if (CGRectGetHeight(self.view.frame) == 667) {
        
        imageView.frame = CGRectMake(0, 0, Screen_Width, 350);
    }
    if (CGRectGetHeight(self.view.frame) == 736) {
        
        imageView.frame = CGRectMake(0, 0, Screen_Width, 400);

    }
    [bicScrollView addSubview:imageView];
    
    UIImageView *topIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_top_bg"]];
    topIconView.frame = CGRectMake(0, 0, 125, 125);
    topIconView.center = imageView.center;
    [imageView addSubview:topIconView];
    
    textFieldView = [[UIView alloc] initWithFrame:CGRectMake((Screen_Width - (Screen_Width - 40))/2,CGRectGetMaxY(imageView.frame)+10 , Screen_Width - 40, 90)];
    
    textFieldView.layer.cornerRadius = 3;
    textFieldView.clipsToBounds = YES;
    
    
    textFieldView.backgroundColor = [UIColor clearColor];
    
    [bicScrollView addSubview:textFieldView];
    
    
    UIImageView *userimg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_user.png"]];
    userimg.frame = CGRectMake(0, 10, 20, 24);
    [textFieldView addSubview:userimg];

    
    NSString * name = [[NSUserDefaults standardUserDefaults]objectForKey:@"name"];
    NSString * password = [[NSUserDefaults standardUserDefaults]objectForKey:@"password"];

    userNameText = [[UITextField alloc] initWithFrame:CGRectMake(31, 0, CGRectGetWidth(textFieldView.frame)-31, CGRectGetHeight(textFieldView.frame)/2)];
    userNameText.delegate = self;
    userNameText.clearButtonMode = UITextFieldViewModeWhileEditing;
    if (name.length != 0) {
        
        userNameText.text = name;
        
  
    }else{
        
        userNameText.placeholder = @"用户名";
    }
    [userNameText addTarget:self action:@selector(retuanKeyMothod:) forControlEvents:UIControlEventEditingDidEndOnExit];
    userNameText.tag = 1001;
    userNameText.backgroundColor = [UIColor clearColor];
    userNameText.returnKeyType = UIReturnKeyNext;

    [textFieldView addSubview:userNameText];
    
    
    UIImageView *linseView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(userNameText.frame),CGRectGetWidth(textFieldView.frame) , 0.3)];
    linseView.backgroundColor = [Util uiColorFromString:@"#c2d0ca"];
    
    [textFieldView addSubview:linseView];

    
    UIImageView *pwdView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_key.png"]];
    pwdView.frame = CGRectMake(0, CGRectGetMaxY(linseView.frame)+10, 20, 24);
    [textFieldView addSubview:pwdView];

    passwedText = [[UITextField alloc] initWithFrame:CGRectMake(31, CGRectGetMaxY(linseView.frame), CGRectGetWidth(textFieldView.frame)-31, CGRectGetHeight(textFieldView.frame)/2)];
    passwedText.delegate = self;
    passwedText.clearButtonMode = UITextFieldViewModeWhileEditing;

    if (password.length != 0) {
        
        passwedText.text = password;
        
        
    }else{
        
        passwedText.placeholder = @"密码";
    }
    passwedText.tag = 1002;
    [passwedText addTarget:self action:@selector(retuanKeyMothod:) forControlEvents:UIControlEventEditingDidEndOnExit];

    passwedText.secureTextEntry = YES;
    
    passwedText.backgroundColor = [UIColor clearColor];
    passwedText.returnKeyType = UIReturnKeyDone;
    
    [textFieldView addSubview:passwedText];
    

    UIImageView *pwdLinse = [[UIImageView alloc] initWithFrame:CGRectMake(0, 89,CGRectGetWidth(textFieldView.frame) , 0.3)];
    pwdLinse.backgroundColor = [Util uiColorFromString:@"#c2d0ca"];
    //    linseView.alpha = 0.3;
    
    [textFieldView addSubview:pwdLinse];
    
    
  
    UIButton *loginbut = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginbut setFrame:CGRectMake(CGRectGetMinX(textFieldView.frame), CGRectGetMaxY(textFieldView.frame)+40, CGRectGetWidth(textFieldView.frame) , 45)];
    [loginbut setBackgroundColor:[Util uiColorFromString:@"#33d793"]];
    
    [loginbut setTitle:@"登录" forState:UIControlStateNormal];
    
    loginbut.layer.cornerRadius = 22;
    loginbut.clipsToBounds = YES;
    
    [loginbut setTitleColor:[Util uiColorFromString:@"#ffffff"] forState:UIControlStateNormal];
    
    [loginbut addTarget:self action:@selector(loginButPress:) forControlEvents:UIControlEventTouchUpInside];
    
    [bicScrollView addSubview:loginbut];
    
    
    
    UIButton *registerbut = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerbut setFrame:CGRectMake(CGRectGetMinX(textFieldView.frame), CGRectGetMaxY(loginbut.frame)+20, CGRectGetWidth(textFieldView.frame) , 45)];
    [registerbut setBackgroundColor:[Util uiColorFromString:@"#f3f3f3"]];
    
    [registerbut setTitle:@"注册" forState:UIControlStateNormal];
    
    registerbut.layer.cornerRadius = 22;
    registerbut.clipsToBounds = YES;
    
    [registerbut setTitleColor:[Util uiColorFromString:@"#666666"] forState:UIControlStateNormal];
    
    [registerbut addTarget:self action:@selector(registerButPress:) forControlEvents:UIControlEventTouchUpInside];
    
    [bicScrollView addSubview:registerbut];

    CGFloat  firstX = 30;
    CGFloat buttonWidth = (Screen_Width - firstX*4)/3;
    
    UIButton *forgetPwdbut = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgetPwdbut setFrame:CGRectMake(firstX, Screen_Height-55, buttonWidth, 40)];
    forgetPwdbut.titleLabel.font = [UIFont systemFontOfSize:14];
    [forgetPwdbut setBackgroundColor:[UIColor clearColor]];
    
    [forgetPwdbut setTitle:@"忘记密码" forState:UIControlStateNormal];
    
    
    [forgetPwdbut setTitleColor:[Util uiColorFromString:@"#666666"] forState:UIControlStateNormal];
    
    [forgetPwdbut addTarget:self action:@selector(forgetPasswordButPress:) forControlEvents:UIControlEventTouchUpInside];
    
    [bicScrollView addSubview:forgetPwdbut];
    
    UIImageView *ampLinse = [[UIImageView alloc] initWithFrame:CGRectMake(forgetPwdbut.frame.origin.x + buttonWidth + firstX/2, Screen_Height-55, 0.5, 30)];
    ampLinse.backgroundColor = [Util uiColorFromString:@"#c2d0ca"];
    [bicScrollView addSubview:ampLinse];
    
    
    UIButton *setUrlBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [setUrlBut setFrame:CGRectMake(forgetPwdbut.frame.origin.x + buttonWidth + firstX, Screen_Height-55, buttonWidth , 40)];
    
    [setUrlBut setTitle:@"连接设置" forState:UIControlStateNormal];
    setUrlBut.titleLabel.font = [UIFont systemFontOfSize:15];
    setUrlBut.backgroundColor = [UIColor clearColor];
    
    [setUrlBut setTitleColor:[Util uiColorFromString:@"#666666"] forState:UIControlStateNormal];

    
    [setUrlBut addTarget:self action:@selector(setUrlButPress:) forControlEvents:UIControlEventTouchUpInside];
    
    [bicScrollView addSubview:setUrlBut];
    
    UIImageView *ampLinses = [[UIImageView alloc] initWithFrame:CGRectMake(setUrlBut.frame.origin.x + buttonWidth + firstX/2, Screen_Height-55, 0.5, 30)];
    ampLinses.backgroundColor = [Util uiColorFromString:@"#c2d0ca"];
    [bicScrollView addSubview:ampLinses];

    UIButton *checkDeviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkDeviceBtn setFrame:CGRectMake(setUrlBut.frame.origin.x + buttonWidth + firstX, Screen_Height-55, buttonWidth , 40)];
    
    [checkDeviceBtn setTitle:@"查看设备" forState:UIControlStateNormal];
    checkDeviceBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    checkDeviceBtn.backgroundColor = [UIColor clearColor];
    [checkDeviceBtn setTitleColor:[Util uiColorFromString:@"#666666"] forState:UIControlStateNormal];
    
    [checkDeviceBtn addTarget:self action:@selector(checkDeviceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [bicScrollView addSubview:checkDeviceBtn];
    
    
    NSString *version  = [Util getAppShortVersion];
    
    NSString *serverVersion = [JumpObject getServersionString];
    
    NSString *versionString = [NSString stringWithFormat:@"版本号：%@",([serverVersion isEqualToString:@"0.0.0"]?version:serverVersion)];
    CGSize size = [Util getStringWidthWithStringLenth:versionString Withfont:10];
    
    versonLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,120 , size.height +10)];
    versonLab.text = versionString;
    CGPoint ImageCenter = imageView.center;
    ImageCenter.y = ImageCenter.y + 35;
    versonLab.center = ImageCenter;
    versonLab.textAlignment = NSTextAlignmentCenter;
    versonLab.font = [UIFont systemFontOfSize:10];
    versonLab.textColor = [UIColor whiteColor];
    versonLab.backgroundColor = [UIColor clearColor];
    [imageView addSubview:versonLab];
    
    userNameStr = userNameText.text;
    
    passWedStr = passwedText.text;
    
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}
#pragma mark-butMethod
- (void)forgetPasswordButPress:(UIButton *)sender
{
    [JumpObject showForgetPasswordvcWith:self];
    
}

- (void)registerButPress:(UIButton *)sender
{
    
    
    [JumpObject showRegistervcWith:self];
}

- (void)setUrlButPress:(UIButton *)sender
{
    
    SetUrlVC *seturl = [[SetUrlVC alloc] init];
    
    [self.navigationController pushViewController:seturl animated:YES];
    

}


- (void)checkDeviceBtnClick:(UIButton *)sender
{
    NSString *urlstr =  [JumpObject getHttpUrl];
    NSString *uuid = [DeviceUtil getNewUUID];
    NSDictionary * dict = @{@"devCode":uuid};
    [UserModel getModelArrayWithPath:[NSString stringWithFormat:@"%@/mobile_ope/deviceInfo",urlstr] WithParams:dict WithBlock:^(NSArray *resultArray, NSDictionary *dataDict, NSError *errorr) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (errorr != nil) {
            
        }else{
            if ([[dataDict objectForKey:@"errorCode"]  intValue] == 0) {
                NSDictionary *devInfoDic = [dataDict objectForKey:@"data"];
                if ([[devInfoDic objectForKey:@"devStatus"] isKindOfClass:[NSNull class]] || [devInfoDic objectForKey:@"devStatus"] == NULL) {
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"该设备未注册，请登录注册" preferredStyle:UIAlertControllerStyleAlert];
                    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    }]];
                    [self presentViewController:alertVC animated:YES completion:^{
                    }];
                }else{
                    self.devNo = ([devInfoDic objectForKey:@"devCode"] == NULL || [[devInfoDic objectForKey:@"devCode"] isKindOfClass:[NSNull class]])?@"":[devInfoDic objectForKey:@"devCode"];
                    self.devName = ([devInfoDic objectForKey:@"devName"] == NULL || [[devInfoDic objectForKey:@"devName"] isKindOfClass:[NSNull class]])?@"":[devInfoDic objectForKey:@"devName"];
                    self.loginUser = ([devInfoDic objectForKey:@"orgName"] == NULL || [[devInfoDic objectForKey:@"orgName"] isKindOfClass:[NSNull class]])?@"":[devInfoDic objectForKey:@"orgName"];
                    if ([[devInfoDic objectForKey:@"devType"] integerValue] == 0) {
                        self.devKinds = @"移动设备";
                    }else{
                        self.devKinds = @"PC  设备";
                    }
                    self.devModel = ([devInfoDic objectForKey:@"devModel"] == NULL || [[devInfoDic objectForKey:@"devModel"] isKindOfClass:[NSNull class]])?@"":[devInfoDic objectForKey:@"devModel"];
                    if (![devInfoDic objectForKey:@"devOs"] || [[devInfoDic objectForKey:@"devOs"] isKindOfClass:[NSNull class]] || [devInfoDic objectForKey:@"devOs"] == nil) {
                        self.system = @"";
                    }else{
                        self.system = [devInfoDic objectForKey:@"devOs"];
                    }
                    self.app = ([devInfoDic objectForKey:@"devBiz"] == NULL || [[devInfoDic objectForKey:@"devBiz"] isKindOfClass:[NSNull class]])?@"":[devInfoDic objectForKey:@"devBiz"];
                    NSInteger devState = [[devInfoDic objectForKey:@"devStatus"] integerValue];
                    if (devState == 0) {
                        self.devState = @"未认证";
                        
                    }else if (devState == 1)
                    {
                        self.devState = @"已认证";
                        
                    }else if (devState == -1){
                        self.devState = @"已禁用";
                    }
                    self.devRemark =([devInfoDic objectForKey:@"devComment"] == NULL || [[devInfoDic objectForKey:@"devComment"] isKindOfClass:[NSNull class]])?@"":[devInfoDic objectForKey:@"devComment"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showDevInfo];
                    });
                }
            }
        }
    }];
    
    
    
}
- (void)showDevInfo{
    
    UIControl *bgControl = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
    bgControl.alpha = 0.8;
    bgControl.tag = 1111;
    bgControl.backgroundColor = [UIColor blackColor];
    [bgControl addTarget:self action:@selector(bgClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bgControl];
    
    showDeviceStateView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width*0.85, 460)];
    showDeviceStateView.backgroundColor = [UIColor whiteColor];
    showDeviceStateView.center = self.view.center;
    showDeviceStateView.layer.cornerRadius = 8.0;
    showDeviceStateView.clipsToBounds = YES;
    [self.view addSubview:showDeviceStateView];
    
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(showDeviceStateView.frame.origin.x + Screen_Width*0.85 - 20, showDeviceStateView.frame.origin.y - 20, 40, 40);
    closeBtn.backgroundColor = [UIColor clearColor];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"close_icon"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(removeDeviceStateView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    
    
    CGFloat labelWidth = 100;
    UIFont *labelFont = [UIFont systemFontOfSize:15.5f];
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(showDeviceStateView.frame.size.width/2 - 60, 10, 120, 40)];
    titleLab.text = @"设备信息";
    titleLab.font = [UIFont systemFontOfSize:21.f];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = [UIColor colorWithRed:34/255.f green:214/255.f blue:144/255.f alpha:1];
    [showDeviceStateView addSubview:titleLab];
    
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 55, showDeviceStateView.frame.size.width, 1)];
    line.backgroundColor = [Util uiColorFromString:@"#c2d0ca"];
    [showDeviceStateView addSubview:line];
    
    UILabel *tdevNoLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, labelWidth, 40)];
    tdevNoLab.text = @"设备编号：";
    tdevNoLab.font = labelFont;
    tdevNoLab.textAlignment = NSTextAlignmentRight;
    tdevNoLab.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:tdevNoLab];
    
    UILabel *devNo = [[UILabel alloc]initWithFrame:CGRectMake(labelWidth + 10, tdevNoLab.frame.origin.y, showDeviceStateView.frame.size.width - labelWidth - 20, 58)];
    devNo.text = self.devNo;
    devNo.numberOfLines = 0;
//    devNo.backgroundColor = [UIColor blueColor];
    devNo.font = labelFont;
    devNo.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:devNo];
    
    UILabel *devNameLab = [[UILabel alloc]initWithFrame:CGRectMake(10, devNo.frame.origin.y + devNo.frame.size.height, labelWidth, 40)];
    devNameLab.text = @"设备名称：";
    devNameLab.font = labelFont;
    devNameLab.textAlignment = NSTextAlignmentRight;
    devNameLab.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:devNameLab];
    
    UILabel *devName = [[UILabel alloc]initWithFrame:CGRectMake(labelWidth +10, devNameLab.frame.origin.y, devNo.frame.size.width, 40)];
    devName.text = self.devName;
    devName.font = labelFont;
    devName.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:devName];
    
    UILabel *loginUserLab = [[UILabel alloc]initWithFrame:CGRectMake(10, devName.frame.origin.y + devName.frame.size.height, labelWidth, 40)];
    loginUserLab.text = @"登录机构：";
    loginUserLab.font = labelFont;
    loginUserLab.textAlignment = NSTextAlignmentRight;
    loginUserLab.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:loginUserLab];
    
    UILabel *loginUser = [[UILabel alloc]initWithFrame:CGRectMake(labelWidth +10, loginUserLab.frame.origin.y, devNo.frame.size.width, 40)];
    loginUser.text = self.loginUser;
    loginUser.font = labelFont;
    loginUser.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:loginUser];
    
    UILabel *devKindsLab = [[UILabel alloc]initWithFrame:CGRectMake(10, loginUser.frame.origin.y + loginUser.frame.size.height, labelWidth, 40)];
    devKindsLab.text = @"设备类型：";
    devKindsLab.font = labelFont;
    devKindsLab.textAlignment = NSTextAlignmentRight;
    devKindsLab.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:devKindsLab];
    
    UILabel *devKinds = [[UILabel alloc]initWithFrame:CGRectMake(labelWidth +10, devKindsLab.frame.origin.y, devNo.frame.size.width, 40)];
    devKinds.text = self.devKinds;
    devKinds.font = labelFont;
    devKinds.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:devKinds];
    
    UILabel *devModelLab = [[UILabel alloc]initWithFrame:CGRectMake(10, devKinds.frame.origin.y + devKinds.frame.size.height, labelWidth, 40)];
    devModelLab.text = @"设备型号：";
    devModelLab.font = labelFont;
    devModelLab.textAlignment = NSTextAlignmentRight;
    devModelLab.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:devModelLab];
    
    UILabel *devModel = [[UILabel alloc]initWithFrame:CGRectMake(labelWidth +10, devModelLab.frame.origin.y, devNo.frame.size.width, 40)];
    devModel.text = self.devModel;
    devModel.font = labelFont;
    devModel.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:devModel];
    
    UILabel *systemLab = [[UILabel alloc]initWithFrame:CGRectMake(10, devModel.frame.origin.y + devModel.frame.size.height, labelWidth, 40)];
    systemLab.text = @"操作系统：";
    systemLab.font = labelFont;
    systemLab.textAlignment = NSTextAlignmentRight;
    systemLab.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:systemLab];
    
    UILabel *system = [[UILabel alloc]initWithFrame:CGRectMake(labelWidth +10, systemLab.frame.origin.y, devNo.frame.size.width, 40)];
    system.text = self.system;
    system.font = labelFont;
    system.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:system];
    
    UILabel *appLab = [[UILabel alloc]initWithFrame:CGRectMake(10, system.frame.origin.y + system.frame.size.height, labelWidth, 40)];
    appLab.text = @"应用业务：";
    appLab.font = labelFont;
    appLab.textAlignment = NSTextAlignmentRight;
    appLab.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:appLab];
    
    UILabel *app = [[UILabel alloc]initWithFrame:CGRectMake(labelWidth +10, appLab.frame.origin.y, devNo.frame.size.width, 40)];
    app.text = self.app;
    app.font = labelFont;
    app.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:app];
    
    UILabel *devStateLab = [[UILabel alloc]initWithFrame:CGRectMake(10, app.frame.origin.y + app.frame.size.height, labelWidth, 40)];
    devStateLab.text = @"设备状态：";
    devStateLab.font = labelFont;
    devStateLab.textAlignment = NSTextAlignmentRight;
    devStateLab.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:devStateLab];
    
    UILabel *devState = [[UILabel alloc]initWithFrame:CGRectMake(labelWidth +10, devStateLab.frame.origin.y, devNo.frame.size.width, 40)];
    devState.text = self.devState;
    devState.font = labelFont;
    devState.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:devState];
    
    UILabel *devRemarkLab = [[UILabel alloc]initWithFrame:CGRectMake(10, devState.frame.origin.y + devState.frame.size.height, labelWidth, 40)];
    devRemarkLab.text = @"设备备注：";
    devRemarkLab.font = labelFont;
    devRemarkLab.textAlignment = NSTextAlignmentRight;
    devRemarkLab.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:devRemarkLab];
    
    UILabel *devRemark = [[UILabel alloc]initWithFrame:CGRectMake(labelWidth +10, devRemarkLab.frame.origin.y, devNo.frame.size.width, 40)];
    devRemark.text = self.devRemark;
    devRemark.font = labelFont;
    devRemark.textColor = [UIColor blackColor];
    [showDeviceStateView addSubview:devRemark];
    
//    UIImageView *lines = [[UIImageView alloc]initWithFrame:CGRectMake(0, devRemarkLab.frame.origin.y+devRemarkLab.frame.size.height + 5, showDeviceStateView.frame.size.width, 1)];
//    lines.backgroundColor = [Util uiColorFromString:@"#c2d0ca"];
//    [showDeviceStateView addSubview:lines];
//    
//    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    cancleBtn.frame = CGRectMake(showDeviceStateView.frame.size.width*0.15,lines.frame.origin.y + 15, showDeviceStateView.frame.size.width*0.7, 40);
//    cancleBtn.backgroundColor = [UIColor colorWithRed:34/255.f green:214/255.f blue:144/255.f alpha:1];
//    [cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [cancleBtn setTitle:@"确      定" forState:UIControlStateNormal];
//    cancleBtn.layer.cornerRadius = 8.f;
//    cancleBtn.clipsToBounds = YES;
//    [cancleBtn addTarget:self action:@selector(removeDeviceStateView:) forControlEvents:UIControlEventTouchUpInside];
//    [showDeviceStateView addSubview:cancleBtn];
}
- (void)bgClick:(UIControl *)sender
{
    [sender removeFromSuperview];
    sender = nil;
    [closeBtn removeFromSuperview];
    closeBtn = nil;
    [showDeviceStateView removeFromSuperview];
    showDeviceStateView = nil;
}
- (void)removeDeviceStateView:(UIButton *)sender
{
    
    [sender removeFromSuperview];
    sender = nil;
    UIControl *bgCon = (UIControl *)[self.view viewWithTag:1111];
    if (bgCon) {
        [bgCon removeFromSuperview];
        bgCon = nil;
    }
    [showDeviceStateView removeFromSuperview];
    showDeviceStateView = nil;
    
}
- (void)loginButPress:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    
////测试
//    PrintViewController *printVC = [[PrintViewController alloc]init];
//    [self.navigationController pushViewController:printVC animated:YES];
//    return;
    
    
    if (userNameStr.length == 0 || userNameStr == nil || [userNameStr isEqualToString:@""]) {
        [Util  showHud:@"用户名不能为空" withView:self.view];
        return;
        
    }
    if (passWedStr.length == 0 || passWedStr == nil || [passWedStr isEqualToString:@""]) {
        
        [Util  showHud:@"密码不能为空" withView:self.view];

        return;
    }
    
    NSString *urlstr =  [JumpObject getHttpUrl];

    if ([urlstr hasPrefix:@"http://"]||[urlstr hasPrefix:@"https://"]) {
        
    }else{
        [Util  showHud:@"访问地址不正确" withView:self.view];
        
        return;
    }
    NSString *uuid = [DeviceUtil getNewUUID];
    NSLog(@"uuid----%@",uuid);
    if ([uuid isEqual:NULL] || [uuid isEqualToString:@""] || [uuid isEqualToString:@"(null)"]) {
        return;
    }
    NSString* userPhoneName = [[UIDevice currentDevice] name];
    NSLog(@"手机名称: %@", userPhoneName);
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSLog(@"手机系统版本: %@", phoneVersion);
    NSString* phoneModel = [self iphoneType];
    NSLog(@"手机型号: %@",phoneModel);
    NSDictionary * dict = @{@"username":userNameStr,@"password":passWedStr,@"devCode":uuid,@"devName":userPhoneName,@"devType":@"0",@"devModel":phoneModel,@"devOs":[NSString stringWithFormat:@"iOS %@",phoneVersion],@"devBiz":@"营运宝",@"appVersion":[DeviceUtil getAppVersion]};
    
    NSLog(@"urlstr----%@",[NSString stringWithFormat:@"%@/mobile_ope/login2",urlstr]);
    NSLog(@"%@",[dict description]);
    [Util showIndeterminateHud:@"加载中..." withView:self.view];
//    [MBProgressHUDHelper showHud:@"加载中..." mode: xOffset:MBProgressHUDAnimationZoom yOffset:2.f margin:0];
    [UserModel getModelArrayWithPath:[NSString stringWithFormat:@"%@/mobile_ope/login2",urlstr] WithParams:dict WithBlock:^(NSArray *resultArray, NSDictionary *dataDict, NSError *errorr) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        if (errorr != nil) {
            
             [Util  showHud:[errorr.userInfo objectForKey:@"NSLocalizedDescription"] withView:self.view];
        }else{
            if ([[dataDict objectForKey:@"errorCode"]  intValue] == 0) {
                if (resultArray.count != NUMBER_ZERO) {
                    UserModel *model = [resultArray objectAtIndex:NUMBER_ZERO];
                    [[NSUserDefaults standardUserDefaults] setObject:userNameStr forKey:@"name"];
                    [[NSUserDefaults standardUserDefaults] setObject:passWedStr forKey:@"password"];
                    [[NSUserDefaults standardUserDefaults] synchronize];

                    JumpObject.authorityUser = [[dataDict objectForKey:@"data"] objectForKey:@"authorityUser"];
                    JumpObject.userMain = [[dataDict objectForKey:@"data"] objectForKey:@"userMain"];
                    [JumpObject saveUserInfo:model];
//                    organTypeNo = U010101
                    NSString *userType = [NSString stringWithFormat:@"%@",[JumpObject.userMain objectForKey:@"organTypeNo"]];
                    if ([userType isEqualToString:@"U010105"]) {
                        //新业务
                        JumpObject.isNewPrint = YES;
                    }
                    [JumpObject showViewController];
                }
            }else{
                
                if ([[dataDict objectForKey:@"errorMessage"]  isEqual:[NSNull null]]) {
                    return ;
                }
                [Util  showHud:[dataDict objectForKey:@"errorMessage"] withView:self.view];
            }
        }
    }];
}

#pragma mark-keyboard
- (void)keyboardwasShown:(NSNotification*)notification{

    
    [UIView animateWithDuration:.0005 animations:^{
        bicScrollView.contentOffset = CGPointMake(0, 40);

    }];

    
    NSLog(@"keyboardwasShown");
}


- (void)keyboardwasHidden:(NSNotification*)notification{
    
//     if (!iskeyboarshow) {
//        return;
//    }
//    if (iPhone4) {
//        if (isinfoshow) {
//            CGRect frame = self.view.frame;
//            frame.origin.y +=100;
//            frame.size.height -=100;
//            self.view.frame = frame;
//            iskeyboarshow = NO;
//        }
//    }
    NSLog(@"keyboardwasHidden");
    [UIView animateWithDuration:.2 animations:^{

    bicScrollView.contentOffset = CGPointMake(0, 0);
    }];

}

- (void)retuanKeyMothod:(UITextField *)sender
{
    switch (sender.tag) {
        case 1001:
            
            [passwedText becomeFirstResponder];
            NSLog(@"next");
            break;
            case 1002:
            
            [passwedText resignFirstResponder];

            [userNameText resignFirstResponder];

            break;
            
        default:
            break;
    }
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [passwedText resignFirstResponder];
    [userNameText resignFirstResponder];
}

- (void)keyboardDown:(UIGestureRecognizer *)gesture
{
    [passwedText resignFirstResponder];
    [userNameText resignFirstResponder];
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
        
    }else if (textField == passwedText){
        passWedStr = textField.text;
    }
}
struct utsname systemInfo;

- (NSString *)iphoneType {
    
    
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    return platform;
    
}

@end
