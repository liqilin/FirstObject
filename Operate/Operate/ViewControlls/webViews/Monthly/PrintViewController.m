//
//  PrintViewController.m
//  Operate
//
//  Created by user on 2017/11/2.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import "PrintViewController.h"
#import "Util.h"
#import "PTKtestUtil.h"
#import "MBProgressHUDHelper.h"
#import "SaleOrderModel.h"
#import "SalesDtlBeanModel.h"
#import "OrderPayWayBeanModel.h"
#import "JumpManger.h"
#import "Macro.h"
#import <DSFrameWork/DSFrameWork.h>

@interface PrintViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    int x;
    int y;
    CGFloat _cgBoldweight;
    CGFloat _usedPos;
    double tailPos;// mm
    int fontSize;
    UIButton *selectedBtn;
    UITextField *fontSizeTextF;
}
@property (strong, nonatomic) DSReceiptManager * manager;

@property (strong, nonatomic) PTKPrintSDK *ptkSDks;
@property (strong, nonatomic) PTKtestUtil *ptkTestUtil;
@property (strong, nonatomic) UITextField *orderPrintTextF;
@property (strong, nonatomic) UITextField *codePrintTextF;
@property (strong, nonatomic) UITableView *printTable;

@property (strong, nonatomic) NSArray *printDeviceArray;

@property (strong, nonatomic) NSMutableArray *linkList;

@end

@implementation PrintViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat width = self.view.bounds.size.width<self.view.bounds.size.height?self.view.bounds.size.width:self.view.bounds.size.height;
    
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 64)];
    navView.backgroundColor = [UIColor colorWithRed:45/255.f green:190/255.f blue:130/255.f alpha:1];
    [self.view addSubview:navView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 200, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.center = CGPointMake(navView.center.x, navView.center.y+10);
    titleLabel.text = @"打印参数配置";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [navView addSubview:titleLabel];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(5, 20, 44, 44);
    [backButton setBackgroundImage:[UIImage imageNamed:@"icon_back_default"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backButton];
    
    
     /*********************************                          ******************************/
    CGFloat height = navView.frame.size.height;
    
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, height + 10, navView.frame.size.width - 10, 0.4)];
    lineLabel.backgroundColor = [Util uiColorFromString:@"#c2d0ca"];
    [self.view addSubview:lineLabel];
    
    UILabel *shopNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(lineLabel.frame.origin.x, lineLabel.frame.origin.y + 10, 100, 44)];
    shopNameLabel.textColor = [UIColor blackColor];
    shopNameLabel.text = @"店铺WiFi名:";
//    shopNameLabel.font = [UIFont systemFontOfSize:14];
    shopNameLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:shopNameLabel];
    
    UITextField *shopNameTextF = [[UITextField alloc]initWithFrame:CGRectMake(shopNameLabel.frame.origin.x + shopNameLabel.frame.size.width, shopNameLabel.frame.origin.y+2, lineLabel.bounds.size.width - shopNameLabel.bounds.size.width, 40)];
    shopNameTextF.placeholder = @"请输入店铺wifi名";
    [shopNameTextF setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    shopNameTextF.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    shopNameTextF.borderStyle = UITextBorderStyleNone;
    shopNameTextF.returnKeyType = UIReturnKeyDone;
    shopNameTextF.text = [Util getWifiName];
    shopNameTextF.delegate = self;
    [self.view addSubview:shopNameTextF];
    
     /*********************************                          ******************************/
    UILabel *line_2Label = [[UILabel alloc]initWithFrame:CGRectMake(5, shopNameTextF.frame.origin.y + shopNameTextF.frame.size.height + 10, navView.frame.size.width - 10, 0.4)];
    line_2Label.backgroundColor = [Util uiColorFromString:@"#c2d0ca"];
    [self.view addSubview:line_2Label];
    
    UILabel *orderPrintLabel = [[UILabel alloc]initWithFrame:CGRectMake(line_2Label.frame.origin.x, line_2Label.frame.origin.y + 10, 120, 44)];
    orderPrintLabel.textColor = [UIColor blackColor];
    orderPrintLabel.text = @"单据打印机:";
    orderPrintLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:orderPrintLabel];
    
    UIButton *choiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    choiceButton.frame = CGRectMake(orderPrintLabel.frame.origin.x+orderPrintLabel.frame.size.width , orderPrintLabel.frame.origin.y+2, 120, 40);
//    choiceButton.titleLabel.text = @"博思得打印机";
    choiceButton.tag = 1110;
    choiceButton.backgroundColor = [UIColor colorWithRed:240/255.f green:145/255.f blue:95/255.f alpha:1];
    choiceButton.layer.cornerRadius = 5;
    choiceButton.clipsToBounds = YES;
    [choiceButton setTitle:@"博思得打印机" forState:UIControlStateNormal];
    [choiceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [choiceButton addTarget:self action:@selector(showPrints:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:choiceButton];
    
    //**************************
    
    
    
    
    
    _orderPrintTextF = [[UITextField alloc]initWithFrame:CGRectMake(orderPrintLabel.frame.origin.x , orderPrintLabel.frame.origin.y+orderPrintLabel.frame.size.height + 2, lineLabel.bounds.size.width - orderPrintLabel.bounds.size.width, 40)];
    _orderPrintTextF.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    _orderPrintTextF.borderStyle = UITextBorderStyleNone;
    _orderPrintTextF.placeholder = @"请输入打印机IP地址";
    [_orderPrintTextF setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    _orderPrintTextF.delegate = self;
    _orderPrintTextF.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_orderPrintTextF];
    
    UILabel *line_3Label = [[UILabel alloc]initWithFrame:CGRectMake(_orderPrintTextF.frame.origin.x, _orderPrintTextF.frame.origin.y + _orderPrintTextF.frame.size.height, _orderPrintTextF.frame.size.width, 0.3)];
    line_3Label.backgroundColor = [Util uiColorFromString:@"#c2d0ca"];
    [self.view addSubview:line_3Label];
    
    UIButton *testPrintButton = [UIButton buttonWithType:UIButtonTypeCustom];
    testPrintButton.tag = 1122;
    testPrintButton.frame = CGRectMake(_orderPrintTextF.frame.origin.x+_orderPrintTextF.frame.size.width + 10, _orderPrintTextF.frame.origin.y + 4, orderPrintLabel.bounds.size.width - 20, 44 - 8);
    testPrintButton.backgroundColor = [UIColor colorWithRed:45/255.f green:190/255.f blue:130/255.f alpha:1];
    [testPrintButton setTitle:@"测试打印" forState:UIControlStateNormal];
    [testPrintButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [testPrintButton addTarget:self action:@selector(testPrint:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testPrintButton];
    
    
    /*********************************                          ******************************/
    UILabel *line_4Label = [[UILabel alloc]initWithFrame:CGRectMake(5, _orderPrintTextF.frame.origin.y + _orderPrintTextF.frame.size.height + 10, navView.frame.size.width - 10, 0.4)];
    line_4Label.backgroundColor = [Util uiColorFromString:@"#c2d0ca"];
    [self.view addSubview:line_4Label];
    
    UILabel *codePrintLabel = [[UILabel alloc]initWithFrame:CGRectMake(line_4Label.frame.origin.x, line_4Label.frame.origin.y + 10, 120, 44)];
    codePrintLabel.textColor = [UIColor blackColor];
    codePrintLabel.text = @"条码打印机:";
    codePrintLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:codePrintLabel];
    
    UIButton *choicesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    choicesButton.frame = CGRectMake(codePrintLabel.frame.origin.x+codePrintLabel.frame.size.width, codePrintLabel.frame.origin.y+2, 120, 40);
    choicesButton.tag = 1111;
    choicesButton.backgroundColor = [UIColor colorWithRed:240/255.f green:145/255.f blue:95/255.f alpha:1];
    choicesButton.layer.cornerRadius = 5;
    choicesButton.clipsToBounds = YES;
    
    [choicesButton setTitle:@"博思得打印机" forState:UIControlStateNormal];
    [choicesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [choicesButton addTarget:self action:@selector(showPrints:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:choicesButton];
    
    _codePrintTextF = [[UITextField alloc]initWithFrame:CGRectMake(codePrintLabel.frame.origin.x , codePrintLabel.frame.origin.y+codePrintLabel.frame.size.height+2, lineLabel.bounds.size.width - codePrintLabel.bounds.size.width, 40)];
    _codePrintTextF.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    _codePrintTextF.borderStyle = UITextBorderStyleNone;
    _codePrintTextF.placeholder = @"请输入打印机IP地址";
    [_codePrintTextF setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    _codePrintTextF.returnKeyType = UIReturnKeyDone;
    _codePrintTextF.delegate = self;
    [self.view addSubview:_codePrintTextF];
    
    UILabel *line_5Label = [[UILabel alloc]initWithFrame:CGRectMake(_codePrintTextF.frame.origin.x, _codePrintTextF.frame.origin.y + _codePrintTextF.frame.size.height, _codePrintTextF.frame.size.width, 0.3)];
    line_5Label.backgroundColor = [Util uiColorFromString:@"#c2d0ca"];
    [self.view addSubview:line_5Label];
    
    UIButton *testPrint2Button = [UIButton buttonWithType:UIButtonTypeCustom];
    testPrint2Button.tag = 1133;
    testPrint2Button.frame = CGRectMake(_codePrintTextF.frame.origin.x+_codePrintTextF.frame.size.width + 10, _codePrintTextF.frame.origin.y + 4, codePrintLabel.bounds.size.width - 20, 44 - 8);
    testPrint2Button.backgroundColor = [UIColor colorWithRed:45/255.f green:190/255.f blue:130/255.f alpha:1];
    [testPrint2Button setTitle:@"测试打印" forState:UIControlStateNormal];
    [testPrint2Button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [testPrint2Button addTarget:self action:@selector(testPrint:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testPrint2Button];
    
    
    /************************************************************************************/
    
    UILabel *fontSizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, _codePrintTextF.frame.origin.y + 50, 380, 40)];
    fontSizeLabel.textColor = [UIColor blackColor];
    fontSizeLabel.font = [UIFont systemFontOfSize:16];
    NSUserDefaults *use = [NSUserDefaults standardUserDefaults];
    NSString *fonstsize = [use objectForKey:@"fontSizeNum"];
    if (fonstsize == nil) {
        fonstsize = @"9";
    }
    fontSizeLabel.text = [NSString stringWithFormat:@"当前字体大小为：%@（仅支持博思得打印机）",fonstsize];
    fontSizeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:fontSizeLabel];
    
    fontSizeTextF = [[UITextField alloc]initWithFrame:CGRectMake(5, _codePrintTextF.frame.origin.y + 100, width -15, 40)];
    fontSizeTextF.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    fontSizeTextF.borderStyle = UITextBorderStyleNone;
    fontSizeTextF.placeholder = @"输入打印字体大小：1~50，默认大小为9";
    [fontSizeTextF setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    fontSizeTextF.returnKeyType = UIReturnKeyDone;
    fontSizeTextF.delegate = self;
    [self.view addSubview:fontSizeTextF];
    
    
    
    
    
    
    UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleButton.frame = CGRectMake(_codePrintTextF.frame.origin.x + 10, _codePrintTextF.frame.origin.y + 150, 100, 40);
    cancleButton.backgroundColor = [UIColor colorWithRed:45/255.f green:190/255.f blue:130/255.f alpha:1];
    [cancleButton setTitle:@"取      消" forState:UIControlStateNormal];
    [cancleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancleButton addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancleButton];
    
    UIButton *certainButton = [UIButton buttonWithType:UIButtonTypeCustom];
    certainButton.frame = CGRectMake(line_4Label.frame.size.width - 110, cancleButton.frame.origin.y, 100, 40);
    certainButton.backgroundColor = [UIColor colorWithRed:45/255.f green:190/255.f blue:130/255.f alpha:1];
    [certainButton setTitle:@"确      定" forState:UIControlStateNormal];
    [certainButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [certainButton addTarget:self action:@selector(certain) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:certainButton];
    
    
    
    
    
    
    
    
    
    
    
    _printDeviceArray = [NSArray arrayWithObjects:@"博思得打印机",@"得实打印机", nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *orderIP = [userDefaults objectForKey:@"orderIP"];
    NSString *codeIP = [userDefaults objectForKey:@"codeIP"];
    NSInteger printKind1 = [userDefaults integerForKey:@"printDeviceKind1"];
    NSInteger printKind2 = [userDefaults integerForKey:@"printDeviceKind2"];
    [choiceButton setTitle:[_printDeviceArray objectAtIndex:printKind1] forState:UIControlStateNormal];
    [choicesButton setTitle:[_printDeviceArray objectAtIndex:printKind2] forState:UIControlStateNormal];
    if (orderIP) {
        _orderPrintTextF.text = orderIP;
    }
    if (codeIP) {
        _codePrintTextF.text = codeIP;
    }
    _ptkSDks = [PTKPrintSDK sharedPTKPrintInstance];
    _ptkTestUtil = [[PTKtestUtil alloc]init];
    _ptkTestUtil.ptkSDK = _ptkSDks;
    _ptkTestUtil.NarrowWidth = 1;
    _ptkTestUtil.WideWidth = 1;
    
    x = 1;
    y = 1;
    _cgBoldweight = UIFontWeightUltraLight;
    _linkList = [[NSMutableArray alloc]initWithCapacity:3];
    
    tailPos = 0;// mm
    fontSize = 9;
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchBack)];
    
    
    // Do any additional setup after loading the view.
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}
- (void)showPrints:(UIButton *)sender
{
    [self.view endEditing:YES];
    selectedBtn = sender;
    if (_printTable) {
        [_printTable removeFromSuperview];
        _printTable.delegate = nil;
        _printTable = nil;
        return;
    }
    UITableView *table = [[UITableView alloc]initWithFrame:CGRectMake(sender.frame.origin.x + sender.frame.size.width, sender.frame.origin.y+sender.frame.size.height, sender.frame.size.width + 50, [_printDeviceArray count]*44) style:UITableViewStylePlain];
    table.backgroundColor = [UIColor whiteColor];
    table.delegate = self;
    table.dataSource = self;
    table.clipsToBounds = YES;
    table.layer.cornerRadius = 10;
    
    [self.view addSubview:table];
    _printTable = table;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_printDeviceArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [_printDeviceArray objectAtIndex:indexPath.row];
//    cell.backgroundColor = [UIColor colorWithRed:240/255.f green:145/255.f blue:95/255.f alpha:1];
//    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *userDeful = [NSUserDefaults standardUserDefaults];
    if (selectedBtn.tag == 1110) {
        [userDeful setInteger:indexPath.row forKey:@"printDeviceKind1"];
    }else if(selectedBtn.tag == 1111){
        [userDeful setInteger:indexPath.row forKey:@"printDeviceKind2"];
    }
    [userDeful synchronize];
    [selectedBtn setTitle:[_printDeviceArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    [_printTable removeFromSuperview];
    _printTable.delegate = nil;
    _printTable = nil;
}
- (void)testPrint:(UIButton *)sender
{
    NSLog(@"IP1:%@ \nIP2:%@", _orderPrintTextF.text, _codePrintTextF.text);
    if (sender.tag == 1122) {//本地销售单据打印
        NSString *ip = [NSString stringWithFormat:@"%@",_orderPrintTextF.text];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger pringDeviceKind = [userDefaults integerForKey:@"printDeviceKind1"];
        BOOL isconnect = NO;
        if (pringDeviceKind == 0) {//博思得
            _ptkSDks = [PTKPrintSDK sharedPTKPrintInstance];
            isconnect = [_ptkSDks PTKConnect:ip andPort:9100];
            if (_ptkTestUtil == nil) {
                _ptkTestUtil = [[PTKtestUtil alloc]init];
                _ptkTestUtil.ptkSDK = _ptkSDks;
                _ptkTestUtil.NarrowWidth = 1;
                _ptkTestUtil.WideWidth = 1;
            }
            NSUserDefaults *use = [NSUserDefaults standardUserDefaults];
            NSString *size = [use objectForKey:@"fontSizeNum"];
            if (size == nil) {
                fontSize = 9;
            }else{
                fontSize = [size intValue];
            }
        }else if (pringDeviceKind == 1){//得实
            self.manager = [DSReceiptManager shareReceiptManager];
            fontSize = 20;
            isconnect = [self.manager connectWifi:ip andPort:9100];
        }
        
        if(isconnect == PTK_SUCCESS){
            [MBProgressHUDHelper showHud:[NSString stringWithFormat:@"打印机连接成功IP1:%@",ip] hideTime:1.5 view:self.view];
            [_ptkSDks PTKClearBuffer];
            SaleOrderModel *dataModel = [[SaleOrderModel alloc]init];
            dataModel.orderNo = @"CA06BS1703200001";
            
            dataModel.createTime = @"2017-11-02 10:26:06";
            dataModel.payTime = @"2017-11-02 10:26:11";
            dataModel.outDate = @"2017-11-02";
            dataModel.businessTypeStr = @"跨店销售";
            dataModel.assistantName = @"测试";
            dataModel.vipNo = @"null";
            dataModel.shopName = @"哈尔滨太平百盛TM";
            dataModel.companyName = @"百丽鞋业（沈阳）商贸有限公司哈尔滨分公司";
            dataModel.remark = @"";
            dataModel.wildcardName = @"";
            dataModel.marketTicketNo = @"";
            
            dataModel.qty = 2;
            dataModel.remainAmount = 0;
            dataModel.allAmount = [NSDecimalNumber decimalNumberWithString:@"1332"];
            dataModel.amount = [NSDecimalNumber decimalNumberWithString:@"1332"];
            dataModel.printSum = 0;
            dataModel.baseScore = 0;
            dataModel.proScore = 0;
            
            
            SalesDtlBeanModel *saleDetailModel = [[SalesDtlBeanModel alloc]init];
            saleDetailModel.itemCode = @"TQE1MR02DM1DM4";
            saleDetailModel.tagPrice = 1783.56;
            saleDetailModel.discPrice = 1783.56;
            saleDetailModel.settlePrice = 666;
            saleDetailModel.qty = 1;
            saleDetailModel.itemName = @"蓝色牛皮男皮靴";
            saleDetailModel.colorName = @"蓝色";
            saleDetailModel.colorNo = @"M1";
            saleDetailModel.itemDiscount = 37.34;
            saleDetailModel.sizeNo = @"240";
            saleDetailModel.amount = 666;
            saleDetailModel.brandNo = @"TM01";
            saleDetailModel.styleNo = @"";
            
            SalesDtlBeanModel *saleDetail2Model = [[SalesDtlBeanModel alloc]init];
            saleDetail2Model.itemCode = @"TQE1MR02DM1DM4";
            saleDetail2Model.tagPrice = 1783.56;
            saleDetail2Model.discPrice = 1783.56;
            saleDetail2Model.settlePrice = 666;
            saleDetail2Model.qty = 1;
            saleDetail2Model.itemName = @"蓝色牛皮男皮靴";
            saleDetail2Model.colorName = @"蓝色";
            saleDetail2Model.colorNo = @"M1";
            saleDetail2Model.itemDiscount = 37.34;
            saleDetail2Model.sizeNo = @"240";
            saleDetail2Model.amount = 666;
            saleDetail2Model.brandNo = @"TM01";
            saleDetail2Model.styleNo = @"";
            dataModel.orderDtls = [NSArray arrayWithObjects:saleDetailModel,saleDetail2Model, nil];
            
            OrderPayWayBeanModel *orderPayModel = [[OrderPayWayBeanModel alloc]init];
            orderPayModel.payName = @"现金";
            orderPayModel.amount = 1332;
            dataModel.orderPaywayList = [NSArray arrayWithObjects:orderPayModel, nil];
            
            if (pringDeviceKind == 0) {//博思得
                [self printSaleOrder:dataModel andOrderList:dataModel.orderDtls andOrderPayWayList:dataModel.orderPaywayList isEnd:YES];
            }else if (pringDeviceKind == 1){//得实
                [self DSPrintSaleOrder:dataModel andOrderList:dataModel.orderDtls andOrderPayWayList:dataModel.orderPaywayList  isEnd:YES];
            }
        }else{
            [MBProgressHUDHelper showHud:[NSString stringWithFormat:@"打印机连接失败IP1:%@",ip]];
        }
    }else{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *ip = [NSString stringWithFormat:@"%@",_codePrintTextF.text];
        NSInteger pringDeviceKind = [userDefaults integerForKey:@"printDeviceKind2"];
        BOOL isconnect = NO;
        if (pringDeviceKind == 0) {//博思得
            _ptkSDks = [PTKPrintSDK sharedPTKPrintInstance];
            isconnect = [_ptkSDks PTKConnect:ip andPort:9100];
            if (_ptkTestUtil == nil) {
                _ptkTestUtil = [[PTKtestUtil alloc]init];
                _ptkTestUtil.ptkSDK = _ptkSDks;
                _ptkTestUtil.NarrowWidth = 1;
                _ptkTestUtil.WideWidth = 1;
            }
            NSUserDefaults *use = [NSUserDefaults standardUserDefaults];
            NSString *size = [use objectForKey:@"fontSizeNum"];
            if (size == nil) {
                fontSize = 9;
            }else{
                fontSize = [size intValue];
            }
        }else if (pringDeviceKind == 1){//得实
            self.manager = [DSReceiptManager shareReceiptManager];
            fontSize = 20;
            isconnect = [self.manager connectWifi:ip andPort:9100];
        }
        
        _cgBoldweight = UIFontWeightUltraLight;
        if(isconnect == PTK_SUCCESS){
            [MBProgressHUDHelper showHud:[NSString stringWithFormat:@"打印机连接成功IP2:%@",_codePrintTextF.text] hideTime:1.5 view:self.view];
            [_ptkSDks PTKClearBuffer];
            SaleOrderModel *dataModel = [[SaleOrderModel alloc]init];
            dataModel.orderNo = @"CA06BS1703200001";
            
            dataModel.createTime = @"2017-11-02 10:26:06";
            dataModel.payTime = @"2017-11-02 10:26:11";
            dataModel.outDate = @"2017-11-02";
            dataModel.businessTypeStr = @"跨店销售";
            dataModel.assistantName = @"测试";
            dataModel.vipNo = @"null";
            dataModel.shopName = @"哈尔滨太平百盛TM";
            dataModel.companyName = @"百丽鞋业（沈阳）商贸有限公司哈尔滨分公司";
            dataModel.remark = @"";
            dataModel.wildcardName = @"";
            dataModel.marketTicketNo = @"";
            
            dataModel.qty = 2;
            dataModel.remainAmount = 0;
            dataModel.allAmount = [NSDecimalNumber decimalNumberWithString:@"1332"];
            dataModel.amount = [NSDecimalNumber decimalNumberWithString:@"1332"];
            dataModel.printSum = 0;
            dataModel.baseScore = 0;
            dataModel.proScore = 0;
            
            
            SalesDtlBeanModel *saleDetailModel = [[SalesDtlBeanModel alloc]init];
            saleDetailModel.itemCode = @"TQE1MR02DM1DM4";
            saleDetailModel.tagPrice = 1783.56;
            saleDetailModel.discPrice = 1783.56;
            saleDetailModel.settlePrice = 666;
            saleDetailModel.qty = 1;
            saleDetailModel.itemName = @"蓝色牛皮男皮靴";
            saleDetailModel.colorName = @"蓝色";
            saleDetailModel.colorNo = @"M1";
            saleDetailModel.itemDiscount = 37.34;
            saleDetailModel.sizeNo = @"240";
            saleDetailModel.amount = 666;
            saleDetailModel.brandNo = @"TM01";
            saleDetailModel.styleNo = @"";
            
            SalesDtlBeanModel *saleDetail2Model = [[SalesDtlBeanModel alloc]init];
            saleDetail2Model.itemCode = @"TQE1MR02DM1DM4";
            saleDetail2Model.tagPrice = 1783.56;
            saleDetail2Model.discPrice = 1783.56;
            saleDetail2Model.settlePrice = 666;
            saleDetail2Model.qty = 1;
            saleDetail2Model.itemName = @"蓝色牛皮男皮靴";
            saleDetail2Model.colorName = @"蓝色";
            saleDetail2Model.colorNo = @"M1";
            saleDetail2Model.itemDiscount = 37.34;
            saleDetail2Model.sizeNo = @"240";
            saleDetail2Model.amount = 666;
            saleDetail2Model.brandNo = @"TM01";
            saleDetail2Model.styleNo = @"";
            dataModel.orderDtls = [NSArray arrayWithObjects:saleDetailModel,saleDetail2Model, nil];
            
            OrderPayWayBeanModel *orderPayModel = [[OrderPayWayBeanModel alloc]init];
            orderPayModel.payName = @"现金";
            orderPayModel.amount = 1332;
            dataModel.orderPaywayList = [NSArray arrayWithObjects:orderPayModel, nil];
            
            if (pringDeviceKind == 0) {//博思得
                [self printSaleOrder:dataModel andOrderList:dataModel.orderDtls andOrderPayWayList:dataModel.orderPaywayList isEnd:YES];
            }else if (pringDeviceKind == 1){//得实
                [self DSPrintSaleOrder:dataModel andOrderList:dataModel.orderDtls andOrderPayWayList:dataModel.orderPaywayList  isEnd:YES];
            }
        }else{
            [MBProgressHUDHelper showHud:[NSString stringWithFormat:@"打印机连接失败IP2:%@",_codePrintTextF.text] hideTime:1.5 view:self.view];
        }
        
    }
}
/**
 打印本地销售单据
 
 @param orderList orderList description
 @param orderPayWayList orderPayWayList description
 @return 0
 */

- (BOOL)printSaleOrder:(SaleOrderModel *)dataModel andOrderList:(NSArray *)orderList andOrderPayWayList:(NSArray *)orderPayWayList isEnd:(NSInteger)isEnd
{
    double yPos = 45;// mm
    bool result = false;
    bool printH = true;
    NSInteger num = [orderList count];
    // -----------------------------------------
    for (int i = 0; i<num; i++) {
        SalesDtlBeanModel *saleBeanModel = [orderList objectAtIndex:i];
        NSString *itemCode = saleBeanModel.itemCode;
        if (itemCode.length > 14) {
            yPos += 0.3 * 25.4;
        }
        yPos += 4.02;
        if (!(yPos < 125)) {
            yPos = 45 + 1;
            x++;
        }
    }
    if (!((yPos + 30) < 125) && yPos != 44) {
        x++;
    }
    // -----------------------------------------
    yPos = 45 + 1.0;
    for (int i = 0; i < num; i++) {
        SalesDtlBeanModel *saleBeanModel = [orderList objectAtIndex:i];
        if (printH) {
            [self setPrintHeader:dataModel];
        }
        //编码
        CGFloat xPos =2.0;
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:saleBeanModel.itemCode andShowStyle:TRUE];
        if([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_brand_no"] objectForKey:@"defaultValue"] integerValue] == 0){
            //品牌名
            xPos += 25;
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:saleBeanModel.brandNo andShowStyle:TRUE];
        }else{
            xPos += 25;
        }
        //规格
        xPos += 8.5;
        if(saleBeanModel.colorNo.length > 0){
            NSString *str = [NSString stringWithFormat:@"%@-%@",saleBeanModel.colorNo,saleBeanModel.sizeNo];
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:str andShowStyle:TRUE];
        }else{
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:saleBeanModel.sizeNo andShowStyle:TRUE];
        }
        //牌价和折扣
        if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_discount"] objectForKey:@"defaultValue"] integerValue] == 0) {
            if (saleBeanModel.tagPrice > 0) {
                xPos += 10;
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%.2f",saleBeanModel.tagPrice] andShowStyle:TRUE];
                xPos += 11.5;
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%.2f%%",saleBeanModel.itemDiscount] andShowStyle:TRUE];
                
            } else {
                xPos += 10;
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"--"] andShowStyle:TRUE];//牌价
                xPos += 11.5;
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"--"] andShowStyle:TRUE];//扣率
            }
        }
        //结算价
        xPos += 12;
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%.2f",saleBeanModel.settlePrice] andShowStyle:TRUE];
        //数量
        xPos += 15;
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%ld",saleBeanModel.qty] andShowStyle:TRUE];
        //金额
        xPos += 6;
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%.2f",saleBeanModel.amount] andShowStyle:TRUE];
        yPos += 4.0;
        if (yPos < 121) {
            printH = false;
        } else {
            y++;
            [_ptkTestUtil PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
            yPos = 41.5;
            printH = true;
        }
    }
    
    if (yPos == 46) {//明细为空
        
        [self setPrintHeader:dataModel];//打印小票头部
        tailPos = 46;
        [self printTail:orderPayWayList andDataModel:dataModel];//打印合计和付款方式
        
    } else if ((yPos + 25) < 130) {// 一页内
        tailPos = yPos + 1;//合计行开始的高度
        [self printTail:orderPayWayList andDataModel:dataModel];//打印合计和付款方式
        
    } else { // 1页内 头打不下
//        [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(92 + 4) andVertical:mm2inch(yPos) andHeight:1 andWidth:1 andText:[NSString stringWithFormat:@"%d/%d页",y,x]];
        y++;
        [_ptkTestUtil PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
        [self setPrintHeader:dataModel];
        tailPos = 46;
        [self printTail:orderPayWayList andDataModel:dataModel];
    }
    [_ptkTestUtil DSZPLSetCutter:1 andCutter:TRUE];
    result = [_ptkTestUtil PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
    if (isEnd == 1) {
        if (_ptkTestUtil != nil) {
            [_ptkTestUtil DSCloseWifi];
        }
    }
    
    x = 1;
    y = 1;
    return result;
}
- (void)setPrintHeader:(SaleOrderModel *)dataModel
{
    CGFloat yPos = 4;//打印纵向位置
    [_ptkTestUtil PrintText:2 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
    [_ptkTestUtil DSSetDirection:0];
    
    // 销售单上面打印店铺品牌的名称
    NSInteger isShowLogo = [[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_brand_logo"] objectForKey:@"defaultValue"] integerValue];
    if(isShowLogo == 1) {
        NSString *brandName = [[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_brand_name"] objectForKey:@"defaultValue"];
        
        if([brandName isKindOfClass:[NSNull class]] || [brandName isEqualToString:@"null"]) {
            // 不再打印这一行
            yPos += 3;
        } else {
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(44) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:brandName andShowStyle:TRUE];
            yPos += 3;
        }
    } else {
        // 为0时不显示，这一行不打印。
    }
    CGFloat line_Height = 4;//每行间隔高度
    //打印销售单头
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(47) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"销售单" andShowStyle:TRUE];
    
    //打印条码
    if (dataModel.orderNo.length >=20) {
        [_ptkTestUtil DSSetBarcodeDefaults:1 andWideToNarrowRatio:3.0];
    }
    yPos += line_Height;
    [_ptkTestUtil PrintCode128:0 andDarkness:30 andHorizontal:mm2inch(1.5) andVertical:mm2inch(yPos) andHeight:0.3 andHeightHuman:26 andWidthHuman:28 andFlagHuman:true andPosHuman:false andContent:dataModel.orderNo];
    
    //系统日
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"系统日：%@",dataModel.createTime] andShowStyle:TRUE];
    //打印日
    NSDate * date = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init ];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * dateStr = [dateFormatter stringFromDate:date];
    yPos += line_Height;
    
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(64.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"    打印：%@", dateStr] andShowStyle:TRUE];
    //******
    yPos += line_Height;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"交易日：%@",dataModel.outDate] andShowStyle:TRUE];

    /**
     * 订单业务类型 Y 0-正常销售 1-跨店销售 2-商场团购 (3-公司团购，暂不启用） 3-内购 4-员购 5-专柜团购 6-特卖销售
     * 默认为0 - 离线开单为0
     */
    //******打印店铺名和类型
    yPos += line_Height;
    
    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_shop_name"] objectForKey:@"defaultValue"] integerValue] == 0) {
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",([dataModel.shopName isEqualToString:@"null"] == YES?@"":dataModel.shopName)] andShowStyle:TRUE];
        
    }
    
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(64.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"    类型：%@",([dataModel.businessTypeStr isEqualToString:@"null"] == NO &&dataModel.businessTypeStr.length >0?dataModel.businessTypeStr:@"")] andShowStyle:TRUE];
    
    //******
    yPos += line_Height;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(64.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"    单号：%@",dataModel.orderNo] andShowStyle:TRUE];
    
    //打印店铺地址和店铺电话
    
    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_shop_address"] objectForKey:@"defaultValue"] integerValue] == 0) {
        NSString *shopAddress = [JumpObject.authorityUser objectForKey:@"shopAddress"];
        if ([shopAddress isKindOfClass: [NSNull class]] == NO && [shopAddress isEqualToString:@"null"] == NO) {
            //打印店铺地址
            if(shopAddress.length > 20){
                NSString *firstStr = [shopAddress substringWithRange:NSMakeRange(0, 20)];
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos + 1) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:firstStr andShowStyle:true];
                NSString *subStr = [shopAddress substringFromIndex:20];
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos + 3) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:subStr andShowStyle:true];
                
            }else{
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos + 1) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:shopAddress andShowStyle:true];
            }
        }else{
            
        }
        id  shopTel = [JumpObject.authorityUser objectForKey:@"shopTel"];
        if ([shopTel isKindOfClass: [NSNull class]] == NO && [shopTel isEqualToString:@"null"] == NO) {
            //打印店铺电话，和会员卡处于同一行
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos + line_Height*2)andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"Tel：%@",shopTel] andShowStyle:TRUE];
        }
    }
    
    
    //******营业员
    yPos += line_Height;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"营业员：%@",dataModel.assistantName] andShowStyle:TRUE];
    //******会员卡
    yPos += line_Height;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"会员卡：%@",([dataModel.vipNo isEqualToString:@"null"] == YES?@"":dataModel.vipNo)] andShowStyle:TRUE];
    
    //打印一行直线，隔开小票头部，开始打印明细头部
    yPos += line_Height;
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(1) andVertical:mm2inch(yPos) andLenth:mm2inch(100) andThick:mm2inch(0.3)];
    yPos += 1;
    CGFloat xPos =7.0;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"商品编码" andShowStyle:TRUE];
    
    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_brand_no"] objectForKey:@"defaultValue"] integerValue] == 0) {
        //品牌是否显示
        xPos += 20;
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"品牌" andShowStyle:TRUE];
    }else{
        xPos += 20;
    }
    xPos += 8;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(38) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"规格" andShowStyle:TRUE];
    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_discount"] objectForKey:@"defaultValue"] integerValue] == 0) {
        //牌价和折扣是否显示
        xPos += 13;
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"牌价" andShowStyle:TRUE];
        xPos += 11;
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"折扣" andShowStyle:TRUE];
    }else{
        xPos += 12;
        xPos += 11;
    }
    xPos += 11;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"结算价" andShowStyle:TRUE];
    xPos += 13;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(82) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"数量" andShowStyle:TRUE];
    xPos += 10;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(92) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"金额" andShowStyle:TRUE];
    //打印明细头部第二条直线
    yPos = yPos + line_Height + 0.5;
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(1) andVertical:mm2inch(yPos) andLenth:mm2inch(100) andThick:mm2inch(0.3)];
    _usedPos = yPos;
}

-(void) printTail:(NSArray *)orderPayWayList andDataModel:(SaleOrderModel *)dataModel
{
    double printHight = mm2inch(tailPos);
    
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(71) andVertical:printHight + 0.05 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"合计" andShowStyle:TRUE];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(84) andVertical:printHight + 0.05 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%ld",dataModel.qty] andShowStyle:TRUE];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(90) andVertical:printHight + 0.05 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.allAmount] andShowStyle:TRUE];
    
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(71) andVertical:printHight + 0.2 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"付款" andShowStyle:TRUE];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(90) andVertical:printHight + 0.2 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.amount] andShowStyle:TRUE];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(71) andVertical:printHight + 0.35 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"找零" andShowStyle:TRUE];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(90) andVertical:printHight + 0.35 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.remainAmount] andShowStyle:TRUE];
    
    //由登录接口返回参数控制是否打印显示
    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_brand_no"] objectForKey:@"defaultValue"] integerValue] == 0) {
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.35 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.companyName] andShowStyle:TRUE];
    }
    
    [_linkList removeAllObjects];
    if (orderPayWayList && orderPayWayList.count > 0) {
        for (int i = 0; i<orderPayWayList.count; i++) {
            OrderPayWayBeanModel *orderPayModel = [orderPayWayList objectAtIndex:i];
            [_linkList addObject:orderPayModel.payName];
            
        }
        NSString *payName = _linkList[_linkList.count-1];
        NSData *bytesData = [payName dataUsingEncoding:NSUTF8StringEncoding];
        
        double pos = 105 - bytesData.length * 3 - 5;
        double ymoneyPos = printHight;// 英尺
        
        for (NSInteger j = _linkList.count - 1; j > 0; j--) {
            NSString *payName = _linkList[j];
            if (pos < 0) {
                pos = 105 - bytesData.length * 3 - 5;
                ymoneyPos += 0.2;
            }
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(pos) andVertical:ymoneyPos+0.56 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",payName] andShowStyle:TRUE];
            pos = pos - bytesData.length* 3 - 5;
        }
        
        if (pos < 0) {
            pos = 105 - bytesData.length * 3 -5;
            ymoneyPos += 0.2;
        }
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(pos) andVertical:ymoneyPos+0.56 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",_linkList[0]] andShowStyle:TRUE];
        
        [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(62) andVertical:printHight andLenth:mm2inch(38) andThick:mm2inch(0.3)];
        [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(62) andVertical:printHight + 0.5 andLenth:mm2inch(38) andThick:mm2inch(0.3)];
        //    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(6) andVertical:printHight + 0.69 andLenth:mm2inch(100) andThick:mm2inch(0.3)];
        [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(1) andVertical:printHight + 0.69 andLenth:mm2inch(100) andThick:mm2inch(0.3)];
        
        double remarkHeight = 0;
        NSString *order_remark = dataModel.remark;
        if ([order_remark isEqualToString:@"null"] == NO) {
            order_remark = [NSString stringWithFormat:@"订单备注：%@",order_remark];
            if(order_remark.length > 0 && order_remark.length <= 40) {
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.72 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",order_remark] andShowStyle:TRUE];
                
            } else {
                for (int i = 0; i <= order_remark.length/41; i++ ) {
                    if((i + 1) * 41 >= order_remark.length) {
                        NSString *subString = [order_remark substringWithRange:NSMakeRange(i*40, order_remark.length - 1)];
                        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.77+remarkHeight andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:subString andShowStyle:TRUE];
                    } else {
                        NSString *subString = [order_remark substringWithRange:NSMakeRange(i*40, (i + 1) * 40)];
                        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.77+remarkHeight andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:subString andShowStyle:TRUE];
                        remarkHeight += mm2inch(3);
                    }
                }
            }
            remarkHeight += mm2inch(3);
        }
        remarkHeight += mm2inch(3);
        id remark = [[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"print_ticket_remark"] objectForKey:@"defaultValue"];
        if ([remark isKindOfClass:[NSNull class]] == NO && [remark isEqualToString:@"null"] == NO) {
            NSArray *remarkArray = [(NSString *)remark componentsSeparatedByString:@"。"];
            if (remarkArray.count > 0) {
                double i = mm2inch(2);
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.72+remarkHeight andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"特别提示" andShowStyle:TRUE];
                for (NSString *subRemark in remarkArray) {
                    NSInteger len = subRemark.length;
                    if (len > 40) {
                        for(int j = 0; j <= len/41; j++) {  // 每行最大长度是41个
                            if((j + 1) * 41 >= len) {
                                NSString *subStrs = [subRemark substringWithRange:NSMakeRange(j*41-1, len - (j*41-1))];
                                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.77+remarkHeight+i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",subStrs] andShowStyle:TRUE];
                            } else {
                                NSString *subStrss = [subRemark substringWithRange:NSMakeRange((j*41-1) <0?0:(j*41-1), (j + 1) * 41)];
                                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.77+remarkHeight+i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",subStrss] andShowStyle:TRUE];
                                i += mm2inch(3);
                            }
                        }
                    }else{
                        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.77+remarkHeight+i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",subRemark] andShowStyle:TRUE];
                    }
                    i = i + mm2inch(3);
                }
            }
        }
    }
}
#pragma mark- 打印小票带二维码

/**
 打印新业务小票带二维码
 
 @param orderList orderList description
 @param orderPayWayList orderPayWayList description
 @return 0
 */
- (void)newSetPrintHeader:(SaleOrderModel *)dataModel
{
    
    [_ptkTestUtil PrintText:2 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
    [_ptkTestUtil DSSetDirection:0];
    
    // shopLogo
    NSString  *logoImageUrl = [JumpObject.userMain objectForKey:@"shopLogoUrl"];
    if ([logoImageUrl isKindOfClass:[NSNull class]]) {
        logoImageUrl = @"";
    }
    NSData *imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:logoImageUrl == nil?@"":logoImageUrl] options:NSDataReadingMappedIfSafe error:nil];
    UIImage *iamge = [UIImage imageWithData:imageData];
    if(iamge){
        //        Bitmap bitmap = PrintUtil.resizeImage(BitmapFactory.decodeFile(FileUtils.getBrandLogoFile(context)), 415, 100);
        //        PrintBrandLogo(orderDtlList.get(0).getBrandNo());
        [_ptkTestUtil DSZPLDrawGraphics:mm2inch(50) andVertical:mm2inch(6) andImage:iamge];
        
    }else{
        //        PrintBrandLogo(orderDtlList.get(0).getBrandNo());
        [_ptkTestUtil DSZPLDrawGraphics:mm2inch(50) andVertical:mm2inch(6) andImage:iamge];
        
    }
    
    
    
    
    //打印条码
    if (dataModel.orderNo.length >=20) {
        [_ptkTestUtil DSSetBarcodeDefaults:1 andWideToNarrowRatio:3.0];
    }
    [_ptkTestUtil PrintCode128:0 andDarkness:30 andHorizontal:mm2inch(1.5) andVertical:mm2inch(21) andHeight:0.3 andHeightHuman:26 andWidthHuman:28 andFlagHuman:true andPosHuman:false andContent:dataModel.orderNo];
    
    CGFloat yPos = 6;//打印纵向位置
    CGFloat line_Height = 4;//每行间隔高度
    
    //系统日
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"系统日：%@",dataModel.createTime] andShowStyle:TRUE];
    //打印日
    NSDate * date = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init ];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * dateStr = [dateFormatter stringFromDate:date];
    yPos += line_Height;
    
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(64.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"    打印：%@", dateStr] andShowStyle:TRUE];
    //******交易日
    yPos += line_Height;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"交易日：%@",dataModel.outDate] andShowStyle:TRUE];
    //打印小票号
    yPos += line_Height;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"小票号：%@",dataModel.outDate] andShowStyle:TRUE];
    /**
     * 订单业务类型 Y 0-正常销售 1-跨店销售 2-商场团购 (3-公司团购，暂不启用） 3-内购 4-员购 5-专柜团购 6-特卖销售
     * 默认为0 - 离线开单为0
     */
    //******打印类型
    
    yPos += line_Height;
    
    
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(64.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"    类型：%@",([dataModel.businessTypeStr isEqualToString:@"null"] == NO &&dataModel.businessTypeStr.length >0?dataModel.businessTypeStr:@"")] andShowStyle:TRUE];
    
    //******单号
    yPos += line_Height;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(64.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"    单号：%@",dataModel.orderNo] andShowStyle:TRUE];
    
    //******营业员
    yPos += line_Height;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"营业员：%@",dataModel.assistantName] andShowStyle:TRUE];
    
    //******打印店铺名
    yPos += line_Height;
    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_shop_name"] objectForKey:@"defaultValue"] integerValue] == 0) {
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",([dataModel.shopName isEqualToString:@"null"] == YES?@"":dataModel.shopName)] andShowStyle:TRUE];
        
    }
    
    //打印店铺地址和店铺电话
    yPos += line_Height;
    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_shop_address"] objectForKey:@"defaultValue"] integerValue] == 0) {
        NSString *shopAddress = [JumpObject.authorityUser objectForKey:@"shopAddress"];
        if ([shopAddress isKindOfClass: [NSNull class]] == NO && [shopAddress isEqualToString:@"null"] == NO) {
            //打印店铺地址
            if(shopAddress.length > 20){
                NSString *firstStr = [shopAddress substringWithRange:NSMakeRange(0, 20)];
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:firstStr andShowStyle:true];
                NSString *subStr = [shopAddress substringFromIndex:20];
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos + 3) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:subStr andShowStyle:true];
                yPos += 6;
                
            }else{
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:shopAddress andShowStyle:true];
                yPos += 4;
            }
        }else{
            
        }
        
        id  shopTel = [JumpObject.authorityUser objectForKey:@"shopTel"];
        if ([shopTel isKindOfClass: [NSNull class]] == NO && [shopTel isEqualToString:@"null"] == NO) {
            //打印店铺电话，和会员卡处于同一行
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos)andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"Tel：%@",shopTel] andShowStyle:TRUE];
        }
    }
    
    //    //******会员卡
    //    yPos += line_Height;
    //    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"会员卡：%@",([dataModel.vipNo isEqualToString:@"null"] == YES?@"":dataModel.vipNo)] andShowStyle:TRUE];
    
    //打印一行直线，隔开小票头部，开始打印明细头部
    yPos += line_Height;
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(1) andVertical:mm2inch(yPos) andLenth:mm2inch(100) andThick:mm2inch(0.3)];
    yPos += 1;
    CGFloat xPos =2.0;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"商品款号/商品编码" andShowStyle:TRUE];
    
    //    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_brand_no"] objectForKey:@"defaultValue"] integerValue] == 0) {
    //        //品牌是否显示
    //        xPos += 20;
    //        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"品牌" andShowStyle:TRUE];
    //    }else{
    //        xPos += 20;
    //    }
    xPos += 33;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"规格" andShowStyle:TRUE];
    //    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_discount"] objectForKey:@"defaultValue"] integerValue] == 0) {
    //牌价和折扣显示
    xPos += 15;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"牌价" andShowStyle:TRUE];
    xPos += 13;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"折扣" andShowStyle:TRUE];
    //    }else{
    //        xPos += 12;
    //        xPos += 11;
    //    }
    //    xPos += 11;
    //    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"结算价" andShowStyle:TRUE];
    xPos += 12;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"数量" andShowStyle:TRUE];
    xPos += 13;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"金额" andShowStyle:TRUE];
    //打印明细头部第二条直线
    yPos = yPos + line_Height - 0.5;
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(1) andVertical:mm2inch(yPos) andLenth:mm2inch(100) andThick:mm2inch(0.3)];
}
- (BOOL)newPrintSaleOrder:(SaleOrderModel *)dataModel andOrderList:(NSArray *)orderList andOrderPayWayList:(NSArray *)orderPayWayList andCustomerCardslist:(NSArray *)customerCardsList isEnd:(NSInteger)isEnd
{
    double yPos = 53;// mm
    bool result = false;
    bool printH = true;
    if (dataModel != nil)
    {
        if (orderList != nil && [orderList count] > 0)
        {
            NSInteger num = [orderList count];
            int length = 53;
            int z = 1;
            // -----------------------------------------
            for (int i = 0; i < num; i++) {
                length += 8.02;
            }
            
            int mm = 30;
            if([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_show_vip_info_baroque"] objectForKey:@"defaultValue"] integerValue] == 1 && customerCardsList != nil){
                mm += 25;
            }
            if([[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_weixin_qrcode"] objectForKey:@"defaultValue"] != nil && [[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_weixin_qrcode"] objectForKey:@"defaultValue"] isKindOfClass:[NSNull class]] == NO){
                mm += 30;
            }
            if([[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"print_ticket_remark"] objectForKey:@"defaultValue"] != nil && [[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"print_ticket_remark"] objectForKey:@"defaultValue"] isKindOfClass:[NSNull class]] == NO){
                mm += 30;
            }
            if(length < 250){
                //最后一个参数无用
                [_ptkTestUtil setPageLengthEX:mm2inch(length+mm)];
                //                mSmartPrint.SetPageLength(mm2inch(length+mm));
            }else {
                [_ptkTestUtil setPageLengthEX:mm2inch(302)];
                //                mSmartPrint.SetPageLength(mm2inch(302));
            }
            // -----------------------------------------
            yPos = 53;
            for (int i = 0; i < num; i++) {
                SalesDtlBeanModel *saleBeanModel = [orderList objectAtIndex:i];
                if (printH) {
                    [self newSetPrintHeader:dataModel];
                }
                //打印商品编码或款号
                CGFloat xPos = 2.0;
                if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_show_vip_info_baroque"] objectForKey:@"defaultValue"] integerValue] == 0 && [saleBeanModel.styleNo isKindOfClass:[NSNull class]] == NO) {
                    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:saleBeanModel.styleNo andShowStyle:TRUE];
                }else{
                    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:saleBeanModel.itemCode andShowStyle:TRUE];
                }
                //打印名称
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos + 4) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:saleBeanModel.itemName andShowStyle:TRUE];
                //打印规格
                xPos += 32;
                if([saleBeanModel.colorNo isKindOfClass:[NSNull class]] == NO && [saleBeanModel.colorNo isEqualToString:@"null"] == NO){
                    NSString *str = [NSString stringWithFormat:@"%@-%@",saleBeanModel.colorNo,saleBeanModel.sizeNo];
                    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:str andShowStyle:TRUE];
                }else{
                    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:saleBeanModel.sizeNo andShowStyle:TRUE];
                    
                }
                if (saleBeanModel.tagPrice > 0) {
                    xPos += 16;
                    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%.2f",saleBeanModel.tagPrice] andShowStyle:TRUE];
                    xPos += 11.5;
                    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%.2f%%",saleBeanModel.itemDiscount] andShowStyle:TRUE];
                    
                } else {
                    xPos += 16;
                    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"--"] andShowStyle:TRUE];//牌价
                    xPos += 13.5;
                    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"--"] andShowStyle:TRUE];//扣率
                }
                //数量
                xPos += 14;
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%ld",saleBeanModel.qty] andShowStyle:TRUE];
                //金额
                xPos += 11;
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%.2f",saleBeanModel.amount] andShowStyle:TRUE];
                yPos += 8.02;
                if (yPos < 300) {
                    printH = false;
                } else {
                    z++;
                    [_ptkTestUtil PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
                    
                    if(z*00 <= length){
                        [_ptkTestUtil setPageLengthEX:mm2inch(302)];
                    }else{
                        
                        [_ptkTestUtil setPageLengthEX:mm2inch((length%300) + mm)];
                    }
                    [_ptkTestUtil PrintText:2 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
                    [_ptkTestUtil DSSetDirection:0];
                    
                    yPos = 0;
                }
            }
            if (yPos <= 250) {
                
                tailPos = yPos;
                [self newPrintTail:orderPayWayList andDataModel:dataModel andCustomerCardsList:customerCardsList];
                
                //                }
                //                } else if ((yPos + 25) < 400) {// 一页内
                //                    tailPos = yPos + 1;
                //                    NewprintTail(orderPayWayList, salePrintDto);
                //
            } else { // 1页内 头打不下
                [_ptkTestUtil PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
                [_ptkTestUtil setPageLengthEX:mm2inch(130)];
                [self newSetPrintHeader:dataModel];
                tailPos = 53;
                [self newPrintTail:orderPayWayList andDataModel:dataModel andCustomerCardsList:customerCardsList];
            }
            result = [_ptkTestUtil PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
        }
        
        if (isEnd == 1) {
            if (_ptkTestUtil != nil) {
                [_ptkTestUtil DSCloseWifi];
            }
        }
    }
    x = 1;
    y = 1;
    return result;
}


-(void)newPrintTail:(NSArray *)orderPayWayList andDataModel:(SaleOrderModel *)dataModel andCustomerCardsList:(NSArray *)customerCardsList
{
    double printHight = mm2inch(tailPos);
    
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.05 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"合计" andShowStyle:TRUE];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(75) andVertical:printHight + 0.05 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%ld",dataModel.qty] andShowStyle:TRUE];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(86) andVertical:printHight + 0.05 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.allAmount] andShowStyle:TRUE];
    
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.2 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"应收" andShowStyle:TRUE];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(86) andVertical:printHight + 0.2 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.allAmount] andShowStyle:TRUE];
    
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.35 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"实收" andShowStyle:TRUE];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(86) andVertical:printHight + 0.35 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.amount] andShowStyle:TRUE];
    
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.5 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"找零" andShowStyle:TRUE];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(86) andVertical:printHight + 0.5 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.remainAmount] andShowStyle:TRUE];
    
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.75 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"收款明细" andShowStyle:TRUE];
    
    [_linkList removeAllObjects];
    if (orderPayWayList && orderPayWayList.count > 0) {
        for (int i = 0; i<orderPayWayList.count; i++) {
            OrderPayWayBeanModel *orderPayModel = [orderPayWayList objectAtIndex:i];
            [_linkList addObject:[NSString stringWithFormat:@"%@:%.2f",orderPayModel.payName,orderPayModel.amount]];
            
        }
        double pos = 15;
        double ymoneyPos = printHight;// 英尺
        
        for (int i = 0; i < _linkList.count; i++) {
            NSString *payName = _linkList[i];
            NSData *bytesData = [payName dataUsingEncoding:NSUTF8StringEncoding];
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(pos) andVertical:ymoneyPos+0.75 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",payName] andShowStyle:TRUE];
            pos = pos + bytesData.length*1;
        }
        [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(1) andVertical:printHight andLenth:mm2inch(100) andThick:mm2inch(0.3)];
        [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(1) andVertical:printHight + 0.69 andLenth:mm2inch(100) andThick:mm2inch(0.3)];
        
        
        if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_vip_info"] objectForKey:@"defaultValue"] integerValue] == 1 && [dataModel.vipNo isEqualToString:@"null"] == NO) {
            
            NSString *vipNo = dataModel.vipNo;
            NSString *wildcardName = dataModel.wildcardName;
            NSInteger jifen = dataModel.baseScore + dataModel.proScore;
            NSString *str = [NSString stringWithFormat:@"会员卡号：%@  本次积分：%ld  卡级别：%@" ,vipNo,jifen,wildcardName];
            
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.95 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:str andShowStyle:TRUE];
            printHight += 0.5;
        }
        printHight += 0.1;
        double i = mm2inch(2);
        id remark = [[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"print_ticket_remark"] objectForKey:@"defaultValue"];
        if ([remark isKindOfClass:[NSNull class]] == NO && [remark isEqualToString:@"null"] == NO) {
            NSArray *remarkArray = [(NSString *)remark componentsSeparatedByString:@"。"];
            if (remarkArray.count > 0) {
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(45) andVertical:printHight + 0.85  andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"特别提示" andShowStyle:TRUE];
                for (NSString *subRemark in remarkArray) {
                    NSInteger len = subRemark.length;
                    if (len > 40) {
                        for(int j = 0; j <= len/41; j++) {  // 每行最大长度是41个
                            if((j + 1) * 41 >= len) {
                                NSString *subStrs = [subRemark substringWithRange:NSMakeRange(j*41-1, len - (j*41-1))];
                                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.9+i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",subStrs] andShowStyle:TRUE];
                            } else {
                                NSString *subStrss = [subRemark substringWithRange:NSMakeRange((j*41-1) <0?0:(j*41-1), (j + 1) * 41)];
                                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.9+i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",subStrss] andShowStyle:TRUE];
                                i += mm2inch(3);
                            }
                        }
                    }else{
                        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.9+i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",subRemark] andShowStyle:TRUE];
                    }
                    i = i + mm2inch(3);
                }
            }
        }
        
        if ([[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_weixin_qrcode"] objectForKey:@"defaultValue"] != nil && [[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_weixin_qrcode"] objectForKey:@"defaultValue"] isKindOfClass:[NSNull class]] == NO){
            //            Bitmap bitmap = generateBitmap(ticket_print_weixin_qrcode, 200,200);
            //            if(bitmap!=null)
            //                mSmartPrint.DSZPLDrawGraphics(mm2inch(19),printHight + i + 1, bitmap);
            NSString  *logoImageUrl = [JumpObject.userMain objectForKey:[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_weixin_qrcode"] objectForKey:@"defaultValue"]];
            if ([logoImageUrl isKindOfClass:[NSNull class]]) {
                logoImageUrl = @"";
            }
//            NSData *imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:logoImageUrl] options:NSDataReadingMappedIfSafe error:nil];
//            UIImage *iamge = [UIImage imageWithData:imageData];
//            [_ptkTestUtil DSZPLDrawGraphics:mm2inch(50) andVertical:mm2inch(6) andImage:iamge];
            
            
            
        }
        if ([[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_weibo_qrcode"] objectForKey:@"defaultValue"] != nil && [[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_weibo_qrcode"] objectForKey:@"defaultValue"] isKindOfClass:[NSNull class]] == NO){
            //            Bitmap bitmap = generateBitmap(ticket_print_weixin_qrcode, 200,200);
            //            if(bitmap!=null)
            //            mSmartPrint.DSZPLDrawGraphics(mm2inch(67),printHight + i + 1, bitmap);
            NSString  *logoImageUrl = [JumpObject.userMain objectForKey:[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_weibo_qrcode"] objectForKey:@"defaultValue"]];
            if ([logoImageUrl isKindOfClass:[NSNull class]]) {
                logoImageUrl = @"";
            }
//            NSData *imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:logoImageUrl] options:NSDataReadingMappedIfSafe error:nil];
//            UIImage *iamge = [UIImage imageWithData:imageData];
//            [_ptkTestUtil DSZPLDrawGraphics:mm2inch(50) andVertical:mm2inch(6) andImage:iamge];
            
        }
    }
}
#pragma mark- end
#pragma mark- 得实打印
/**
 打印本地销售单据
 
 @param orderList orderList description
 @param orderPayWayList orderPayWayList description
 @return 0
 */

- (BOOL)DSPrintSaleOrder:(SaleOrderModel *)dataModel andOrderList:(NSArray *)orderList andOrderPayWayList:(NSArray *)orderPayWayList isEnd:(NSInteger)isEnd
{
    double yPos = 45;// mm
    bool result = false;
    bool printH = true;
    NSInteger num = [orderList count];
    // -----------------------------------------
    for (int i = 0; i<num; i++) {
        SalesDtlBeanModel *saleBeanModel = [orderList objectAtIndex:i];
        NSString *itemCode = saleBeanModel.itemCode;
        if (itemCode.length > 14) {
            yPos += 0.3 * 25.4;
        }
        yPos += 4.02;
        if (!(yPos < 125)) {
            yPos = 45 + 1;
            x++;
        }
    }
    if (!((yPos + 30) < 125) && yPos != 44) {
        x++;
    }
    // -----------------------------------------
    yPos = 45 + 1.0;
    for (int i = 0; i < num; i++) {
        SalesDtlBeanModel *saleBeanModel = [orderList objectAtIndex:i];
        if (printH) {
            [self DSSetPrintHeader:dataModel];
        }
        //编码
        CGFloat xPos = 2.0;
        [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:saleBeanModel.itemCode andShowStyle:TRUE];
        if([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_brand_no"] objectForKey:@"defaultValue"] integerValue] == 0){
            //品牌名
            xPos += 25;
            [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:saleBeanModel.brandNo andShowStyle:TRUE];
        }else{
            xPos += 25;
        }
        //规格
        xPos += 8.5;
        if(saleBeanModel.colorNo.length > 0){
            NSString *str = [NSString stringWithFormat:@"%@-%@",saleBeanModel.colorNo,saleBeanModel.sizeNo];
            [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:str andShowStyle:TRUE];
        }else{
            [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:saleBeanModel.sizeNo andShowStyle:TRUE];
        }
        //牌价和折扣
        if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_discount"] objectForKey:@"defaultValue"] integerValue] == 0) {
            if (saleBeanModel.tagPrice > 0) {
                xPos += 10;
                [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%.2f",saleBeanModel.tagPrice] andShowStyle:TRUE];
                xPos += 11.5;
                [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%.2f%%",saleBeanModel.itemDiscount] andShowStyle:TRUE];
                
            } else {
                xPos += 10;
                [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"--"] andShowStyle:TRUE];//牌价
                xPos += 11.5;
                [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"--"] andShowStyle:TRUE];//扣率
            }
        }
        //结算价
        xPos += 12;
        [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%.2f",saleBeanModel.settlePrice] andShowStyle:TRUE];
        //数量
        xPos += 15;
        [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%ld",saleBeanModel.qty] andShowStyle:TRUE];
        //金额
        xPos += 6;
        [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%.2f",saleBeanModel.amount] andShowStyle:TRUE];
        yPos += 4.0;
        if (yPos < 121) {
            printH = false;
        } else {
            y++;
            [self.manager PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
            yPos = 41.5;
            printH = true;
        }
    }
    
    if (yPos == 46) {//明细为空
        
        [self DSSetPrintHeader:dataModel];//打印小票头部
        tailPos = 46;
        [self DSPrintTail:orderPayWayList andDataModel:dataModel];//打印合计和付款方式
        
    } else if ((yPos + 25) < 130) {// 一页内
        tailPos = yPos + 1;//合计行开始的高度
        [self DSPrintTail:orderPayWayList andDataModel:dataModel];//打印合计和付款方式
        
    } else { // 1页内 头打不下
        //        [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(92 + 4) andVertical:mm2inch(yPos) andHeight:1 andWidth:1 andText:[NSString stringWithFormat:@"%d/%d页",y,x]];
        y++;
        [self.manager PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
        [self DSSetPrintHeader:dataModel];
        tailPos = 46;
        [self DSPrintTail:orderPayWayList andDataModel:dataModel];
    }
    [self.manager DSZPLSetCutter:1 andCutter:TRUE];
    result = [self.manager PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
    if (isEnd == 1) {
        if (self.manager != nil) {
            [self.manager DSCloseWifi];
        }
    }
    
    x = 1;
    y = 1;
    return result;
}
- (void)DSSetPrintHeader:(SaleOrderModel *)dataModel
{
    [self.manager setPageLength:mm2inch(100)];
    CGFloat yPos = 4;//打印纵向位置
    [self.manager PrintText:2 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
    [self.manager DSSetDirection:0];
    
    // 销售单上面打印店铺品牌的名称
    NSInteger isShowLogo = [[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_brand_logo"] objectForKey:@"defaultValue"] integerValue];
    if(isShowLogo == 1) {
        NSString *brandName = [[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_brand_name"] objectForKey:@"defaultValue"];
        
        if([brandName isKindOfClass:[NSNull class]] || [brandName isEqualToString:@"null"]) {
            // 不再打印这一行
            yPos += 3;
        } else {
            [self.manager DSZPLPrintTextLine:mm2inch(44) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:brandName andShowStyle:TRUE];
            yPos += 3;
        }
    } else {
        // 为0时不显示，这一行不打印。
    }
    CGFloat line_Height = 4;//每行间隔高度
    //打印销售单头
    [self.manager DSZPLPrintTextLine:mm2inch(47) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"销售单" andShowStyle:TRUE];
    
    //打印条码
    if (dataModel.orderNo.length >=20) {
        [self.manager DSSetBarcodeDefaults:1 andWideToNarrowRatio:3.0];
    }
    yPos += line_Height;
    [self.manager PrintCode128:0 andDarkness:30 andHorizontal:mm2inch(1.5) andVertical:mm2inch(yPos) andHeight:0.3 andHeightHuman:26 andWidthHuman:28 andFlagHuman:true andPosHuman:false andContent:dataModel.orderNo];
    
    //系统日
    [self.manager DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"系统日：%@",dataModel.createTime] andShowStyle:TRUE];
    //打印日
    NSDate * date = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init ];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * dateStr = [dateFormatter stringFromDate:date];
    yPos += line_Height;
    
    [self.manager DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"　打印：%@", dateStr] andShowStyle:TRUE];
    //******
    yPos += line_Height;
    [self.manager DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"交易日：%@",dataModel.outDate] andShowStyle:TRUE];
    
    /**
     * 订单业务类型 Y 0-正常销售 1-跨店销售 2-商场团购 (3-公司团购，暂不启用） 3-内购 4-员购 5-专柜团购 6-特卖销售
     * 默认为0 - 离线开单为0
     */
    //******打印店铺名和类型
    yPos += line_Height;
    
    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_shop_name"] objectForKey:@"defaultValue"] integerValue] == 0) {
        [self.manager DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",([dataModel.shopName isEqualToString:@"null"] == YES?@"":dataModel.shopName)] andShowStyle:TRUE];
        
    }
    
    [self.manager DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"　类型：%@",([dataModel.businessTypeStr isEqualToString:@"null"] == NO &&dataModel.businessTypeStr.length >0?dataModel.businessTypeStr:@"")] andShowStyle:TRUE];
    
    //******
    yPos += line_Height;
    [self.manager DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"　单号：%@",dataModel.orderNo] andShowStyle:TRUE];
    
    //打印店铺地址和店铺电话
    
    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_shop_address"] objectForKey:@"defaultValue"] integerValue] == 0) {
        NSString *shopAddress = [JumpObject.authorityUser objectForKey:@"shopAddress"];
        if ([shopAddress isKindOfClass: [NSNull class]] == NO && [shopAddress isEqualToString:@"null"] == NO) {
            //打印店铺地址
            if(shopAddress.length > 20){
                NSString *firstStr = [shopAddress substringWithRange:NSMakeRange(0, 20)];
                [self.manager DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos + 1) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:firstStr andShowStyle:true];
                NSString *subStr = [shopAddress substringFromIndex:20];
                [self.manager DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos + 3) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:subStr andShowStyle:true];
                
            }else{
                [self.manager DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos + 1) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:shopAddress andShowStyle:true];
            }
        }else{
            
        }
        id  shopTel = [JumpObject.authorityUser objectForKey:@"shopTel"];
        if ([shopTel isKindOfClass: [NSNull class]] == NO && [shopTel isEqualToString:@"null"] == NO) {
            //打印店铺电话，和会员卡处于同一行
            [self.manager DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos + line_Height*2)andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"Tel：%@",shopTel] andShowStyle:TRUE];
        }
    }
    
    
    //******营业员
    yPos += line_Height;
    [self.manager DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"营业员：%@",dataModel.assistantName] andShowStyle:TRUE];
    //******会员卡
    yPos += line_Height;
    [self.manager DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"会员卡：%@",([dataModel.vipNo isEqualToString:@"null"] == YES?@"":dataModel.vipNo)] andShowStyle:TRUE];
    
    //打印一行直线，隔开小票头部，开始打印明细头部
    yPos += line_Height;
    [self.manager Print_HLine:0 andHorizontal:mm2inch(1) andVertical:mm2inch(yPos) andLenth:mm2inch(100) andThick:mm2inch(0.3)];
    yPos += 1;
    CGFloat xPos =7.0;
    [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"商品编码" andShowStyle:TRUE];
    
    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_brand_no"] objectForKey:@"defaultValue"] integerValue] == 0) {
        //品牌是否显示
        xPos += 20;
        [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"品牌" andShowStyle:TRUE];
    }else{
        xPos += 20;
    }
    xPos += 8;
    [self.manager DSZPLPrintTextLine:mm2inch(38) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"规格" andShowStyle:TRUE];
    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_discount"] objectForKey:@"defaultValue"] integerValue] == 0) {
        //牌价和折扣是否显示
        xPos += 13;
        [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"牌价" andShowStyle:TRUE];
        xPos += 11;
        [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"折扣" andShowStyle:TRUE];
    }else{
        xPos += 12;
        xPos += 11;
    }
    xPos += 11;
    [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"结算价" andShowStyle:TRUE];
    xPos += 13;
    [self.manager DSZPLPrintTextLine:mm2inch(82) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"数量" andShowStyle:TRUE];
    xPos += 10;
    [self.manager DSZPLPrintTextLine:mm2inch(92) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"金额" andShowStyle:TRUE];
    //打印明细头部第二条直线
    yPos = yPos + line_Height + 0.5;
    [self.manager Print_HLine:0 andHorizontal:mm2inch(1) andVertical:mm2inch(yPos) andLenth:mm2inch(100) andThick:mm2inch(0.3)];
    _usedPos = yPos;
}

-(void)DSPrintTail:(NSArray *)orderPayWayList andDataModel:(SaleOrderModel *)dataModel
{
    double printHight = mm2inch(tailPos);
    
    [self.manager DSZPLPrintTextLine:mm2inch(71) andVertical:printHight + 0.05 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"合计" andShowStyle:TRUE];
    [self.manager DSZPLPrintTextLine:mm2inch(84) andVertical:printHight + 0.05 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%ld",dataModel.qty] andShowStyle:TRUE];
    [self.manager DSZPLPrintTextLine:mm2inch(90) andVertical:printHight + 0.05 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.allAmount] andShowStyle:TRUE];
    
    [self.manager DSZPLPrintTextLine:mm2inch(71) andVertical:printHight + 0.2 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"付款" andShowStyle:TRUE];
    [self.manager DSZPLPrintTextLine:mm2inch(90) andVertical:printHight + 0.2 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.amount] andShowStyle:TRUE];
    [self.manager DSZPLPrintTextLine:mm2inch(71) andVertical:printHight + 0.35 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"找零" andShowStyle:TRUE];
    [self.manager DSZPLPrintTextLine:mm2inch(90) andVertical:printHight + 0.35 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.remainAmount] andShowStyle:TRUE];
    
    //由登录接口返回参数控制是否打印显示
    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_brand_no"] objectForKey:@"defaultValue"] integerValue] == 0) {
        [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.35 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.companyName] andShowStyle:TRUE];
    }
    
    [_linkList removeAllObjects];
    if (orderPayWayList && orderPayWayList.count > 0) {
        for (int i = 0; i<orderPayWayList.count; i++) {
            OrderPayWayBeanModel *orderPayModel = [orderPayWayList objectAtIndex:i];
            [_linkList addObject:orderPayModel.payName];
            
        }
        NSString *payName = _linkList[_linkList.count-1];
        NSData *bytesData = [payName dataUsingEncoding:NSUTF8StringEncoding];
        
        double pos = 105 - bytesData.length * 3 - 5;
        double ymoneyPos = printHight;// 英尺
        
        for (NSInteger j = _linkList.count - 1; j > 0; j--) {
            NSString *payName = _linkList[j];
            if (pos < 0) {
                pos = 105 - bytesData.length * 3 - 5;
                ymoneyPos += 0.2;
            }
            [self.manager DSZPLPrintTextLine:mm2inch(pos) andVertical:ymoneyPos+0.56 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",payName] andShowStyle:TRUE];
            pos = pos - bytesData.length* 3 - 5;
        }
        
        if (pos < 0) {
            pos = 105 - bytesData.length * 3 -5;
            ymoneyPos += 0.2;
        }
        [self.manager DSZPLPrintTextLine:mm2inch(pos) andVertical:ymoneyPos+0.56 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",_linkList[0]] andShowStyle:TRUE];
        
        [self.manager Print_HLine:0 andHorizontal:mm2inch(62) andVertical:printHight andLenth:mm2inch(38) andThick:mm2inch(0.3)];
        [self.manager Print_HLine:0 andHorizontal:mm2inch(62) andVertical:printHight + 0.5 andLenth:mm2inch(38) andThick:mm2inch(0.3)];
        //    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(6) andVertical:printHight + 0.69 andLenth:mm2inch(100) andThick:mm2inch(0.3)];
        [self.manager Print_HLine:0 andHorizontal:mm2inch(1) andVertical:printHight + 0.69 andLenth:mm2inch(100) andThick:mm2inch(0.3)];
        
        double remarkHeight = 0;
        NSString *order_remark = dataModel.remark;
        if ([order_remark isEqualToString:@"null"] == NO) {
            order_remark = [NSString stringWithFormat:@"订单备注：%@",order_remark];
            if(order_remark.length > 0 && order_remark.length <= 40) {
                [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.72 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",order_remark] andShowStyle:TRUE];
                
            } else {
                for (int i = 0; i <= order_remark.length/41; i++ ) {
                    if((i + 1) * 41 >= order_remark.length) {
                        NSString *subString = [order_remark substringWithRange:NSMakeRange(i*40, order_remark.length - 1)];
                        [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.77+remarkHeight andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:subString andShowStyle:TRUE];
                    } else {
                        NSString *subString = [order_remark substringWithRange:NSMakeRange(i*40, (i + 1) * 40)];
                        [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.77+remarkHeight andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:subString andShowStyle:TRUE];
                        remarkHeight += mm2inch(3);
                    }
                }
            }
            remarkHeight += mm2inch(3);
        }
        remarkHeight += mm2inch(3);
        id remark = [[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"print_ticket_remark"] objectForKey:@"defaultValue"];
        if ([remark isKindOfClass:[NSNull class]] == NO && [remark isEqualToString:@"null"] == NO) {
            NSArray *remarkArray = [(NSString *)remark componentsSeparatedByString:@"。"];
            if (remarkArray.count > 0) {
                double i = mm2inch(2);
                [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.72+remarkHeight andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"特别提示" andShowStyle:TRUE];
                for (NSString *subRemark in remarkArray) {
                    NSInteger len = subRemark.length;
                    if (len > 40) {
                        for(int j = 0; j <= len/41; j++) {  // 每行最大长度是41个
                            if((j + 1) * 41 >= len) {
                                NSString *subStrs = [subRemark substringWithRange:NSMakeRange(j*41-1, len - (j*41-1))];
                                [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.77+remarkHeight+i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",subStrs] andShowStyle:TRUE];
                            } else {
                                NSString *subStrss = [subRemark substringWithRange:NSMakeRange((j*41-1) <0?0:(j*41-1), (j + 1) * 41)];
                                [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.77+remarkHeight+i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",subStrss] andShowStyle:TRUE];
                                i += mm2inch(3);
                            }
                        }
                    }else{
                        [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.77+remarkHeight+i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",subRemark] andShowStyle:TRUE];
                    }
                    i = i + mm2inch(3);
                }
            }
        }
    }
}
#pragma mark- end
- (void)cancle
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -保存IP地址配置
- (void)certain
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *orderIP = [userDefaults objectForKey:@"orderIP"];
    NSString *codeIP = [userDefaults objectForKey:@"codeIP"];
    if (orderIP) {
        [userDefaults removeObjectForKey:@"orderIP"];
        [userDefaults setObject:[NSString stringWithString:_orderPrintTextF.text] forKey:@"orderIP"];
    }else{
        [userDefaults setObject:[NSString stringWithString:_orderPrintTextF.text] forKey:@"orderIP"];
    }
    if (codeIP) {
        [userDefaults removeObjectForKey:@"codeIP"];
        [userDefaults setObject:[NSString stringWithString:_codePrintTextF.text] forKey:@"codeIP"];
    }else{
        [userDefaults setObject:[NSString stringWithString:_codePrintTextF.text] forKey:@"codeIP"];
    }
    if (fontSizeTextF.text.length > 0) {
        [userDefaults setObject:[NSString stringWithString:fontSizeTextF.text] forKey:@"fontSizeNum"];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
