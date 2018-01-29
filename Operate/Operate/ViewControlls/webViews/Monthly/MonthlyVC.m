//
//  MonthlyVC.m
//  Operate
//
//  Created by user on 15/8/24.
//  Copyright (c) 2015年 hanyc. All rights reserved.
//

#import "MonthlyVC.h"
#import <WebKit/WebKit.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearchOption.h>
#import <AVFoundation/AVFoundation.h>
#import "ScanningViewColl.h"
#import "DeviceUtil.h"
#import <CoreLocation/CoreLocation.h>
#import "PrintViewController.h"
#import "MBProgressHUDHelper.h"

#import "SaleOrderModel.h"
#import "SalesDtlBeanModel.h"
#import "OrderPayWayBeanModel.h"
#import "CustomerCards.h"
#import "ShoppingListBean.h"
#import "OcOrderDtlDto.h"
#import "ExpressInfoBean.h"

#import "PTKtestUtil.h"
#import <DSFrameWork/DSFrameWork.h>
#import "CustomerServiceVC.h"



@interface MonthlyVC()<UIImagePickerControllerDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,AVCaptureMetadataOutputObjectsDelegate,UIActionSheetDelegate,ScanDelegate,UIAlertViewDelegate,CLLocationManagerDelegate>
{
    
    NSString *updateUrl;
    
    BMKLocationService *_locService;
    
    BMKGeoCodeSearch *_searcher;
    UIActionSheet *   myActionSheet;
    UIView *scanningView;
    
    NSString *filePath;
    
//    UIView *bcView;
    BOOL isbool;

    UIImagePickerController *pickerController;
    CLLocationCoordinate2D pt;
    
    int x;
    int y;
    CGFloat _cgBoldweight;
    
    double tailPos;// mm
    int fontSize;
}


@property (nonatomic, strong) CLLocationManager *locationManager;//定位服务管理类
@property (nonatomic, assign) NSInteger locationNumber;

@property ( strong , nonatomic ) AVCaptureDevice * device;
@property ( strong , nonatomic ) AVCaptureDeviceInput * input;
@property ( strong , nonatomic ) AVCaptureMetadataOutput * output;
@property ( strong , nonatomic ) AVCaptureSession * session;
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * preview;

@property (strong, nonatomic) PTKPrintSDK *ptkSDks;
@property (strong, nonatomic) PTKtestUtil *ptkTestUtil;
@property (strong, nonatomic) NSMutableArray *linkList;

@property (strong, nonatomic) DSReceiptManager * manager;

@end

@implementation MonthlyVC

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    isbool = NO;
    
    self.navigationController.navigationBarHidden = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.webView.allowsInlineMediaPlayback = YES;
    
    self.view.backgroundColor = [UIColor redColor];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];

//    [self configview];
}
- (void)didBecomeActive:(NSNotification *)no
{
    NSLog(@"---------APP后台进入前台的时候js调用的方法");
    [self.jsContext[@"pageResume"] callWithArguments:nil];
}

- (void)checkUpdate{
    
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
            NSString *msg = [NSString stringWithFormat:@"\n有最新的版本:%@，是否更新？\n\n", [dataDic objectForKey:@"latestVersion"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"更新", nil];
            
            alert.tag = 1711;
            [alert show];
            
        }
    } error:^(NSError *error) {
        
        
    }];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1711) {
        
        if (buttonIndex == 1) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];
        }
    }
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f,title-%@ subtitke %@",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude,userLocation.title,userLocation.subtitle);

    if (self.locationNumber == 5 ) {
         pt = (CLLocationCoordinate2D){userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude};
        BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
        reverseGeoCodeSearchOption.reverseGeoPoint = pt;
        BOOL flag = [_searcher reverseGeoCode:reverseGeoCodeSearchOption];
        if(flag){
            NSLog(@"反geo检索发送成功");
        }
        else{
            NSLog(@"反geo检索发送失败");
        }
    }
    self.locationNumber += 1;
}
//接收反向地理编码结果
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:
(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        //          在此处理正常结果
        NSLog(@"adress=%@=%f=%f=%@",result.addressDetail.city,pt.latitude,pt.longitude ,result.address);
        
        NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
        [forMatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *nowDate = [forMatter stringFromDate:[NSDate date]];
        dispatch_async(dispatch_get_main_queue(),^ {

        [self.jsContext[@"setPositionData"] callWithArguments:@[@{@"nameValuePairs":@{@"lontitude":[NSString stringWithFormat:@"%f",pt.longitude],@"latitude":[NSString stringWithFormat:@"%f",pt.latitude],@"country":@"中国",@"city":result.addressDetail.city,@"district":result.addressDetail.district,@"street":result.addressDetail.streetName,@"province":result.addressDetail.province,@"time":nowDate,@"locationDesCribe":[NSString stringWithFormat:@"%@号",result.addressDetail.streetNumber]}}]];

        });
        [_locService stopUserLocationService];
        _locService.delegate = nil;
        _locService = nil;

    }else {
        NSLog(@"抱歉，未找到结果");
    }
}

//获取定位信息
- (void)getPositionData
{
    [self configLocationManager];
}
//打开二维码扫描
- (void)openScan3
{
    ScanningViewColl *scan = [[ScanningViewColl alloc] init];
    scan.delegate = self;
    scan.cordType = 2;
    scan.jscontext = self.jsContext;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController pushViewController:scan animated:YES];
}
//打开一维码扫描
- (void)openScan2
{
    
    ScanningViewColl *scan = [[ScanningViewColl alloc] init];
    
    scan.delegate = self;
    scan.cordType = 1;
    scan.jscontext = self.jsContext;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController pushViewController:scan animated:YES];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
//获取设备型号
- (void)getDeviceData
{

    
    JSValue *picCallback = _jsContext[@"setDeviceData"];
    /**
     *  改变P标签
     */
    NSString *uuidStr = [DeviceUtil getNewUUID];
    
    [picCallback callWithArguments:@[@{@"systemVersion":[Util deviceSystemVersion],@"imei":uuidStr,@"machineModel":[Util deviceVersion],@"mac":@""}]];
    
}


- (void)giveCall:(NSString *)tel
{
 
    
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",tel];
    //            NSLog(@"str======%@",str);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];

}


- (void)startLocation{
    
    _locationManager = [[CLLocationManager alloc] init];//创建CLLocationManager对象
    _locationManager.delegate = self;//设置代理，这样函数didUpdateLocations才会被回调
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];//精确到10米范围
    [_locationManager requestAlwaysAuthorization];
    [_locationManager startUpdatingLocation]; //启动定位服务
    self.locationNumber = 0;
    
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // 设备的当前位置
    CLLocation *currLocation = [locations lastObject];
    NSLog(@"location-%@",currLocation);
    if (currLocation.horizontalAccuracy >300) {
        
        NSLog(@"不符合标准");
        return;
    }
    if(self.locationNumber == 3){
        
  

    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:currLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        for (CLPlacemark *place in placemarks) {
            NSDictionary *location = [place addressDictionary];
            //            NSLog(@"%@",location);
            NSString *city = [location objectForKey:@"City"];
            NSString *subLocality = [location objectForKey:@"SubLocality"];
            NSString *street = [location objectForKey:@"Street"];
            NSString *name = [location objectForKey:@"Name"];
            NSString *state = [location objectForKey:@"State"];
            
            if (city == nil) {
                city = @"";
            }if (subLocality == nil) {
                subLocality = @"";
            }if (street == nil) {
                street = @"";
            }
            
            if (name == nil) {
                name = @"";
            }
            if (state == nil) {
                state = @"";
            }
            
            NSLog(@"%@",[NSString stringWithFormat:@"%@%@%@",city,subLocality,street]);

                NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
                [forMatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                NSString *nowDate = [forMatter stringFromDate:[NSDate date]];

            
                [self.jsContext[@"setPositionData"] callWithArguments:@[@{@"nameValuePairs":@{@"lontitude":[[NSNumber numberWithDouble:currLocation.coordinate.longitude] stringValue],@"latitude":[NSString stringWithFormat:@"%.8f",currLocation.coordinate.latitude],@"country":@"中国",@"city":city,@"district":subLocality,@"province":state,@"time":nowDate,@"locationDesCribe":[NSString stringWithFormat:@"%@附近",name],@"street":[NSString stringWithFormat:@"%@号",street]}}]];
            [_locationManager stopUpdatingLocation];
            
            }
        
    }];
          }
    self.locationNumber +=1;
    
    
}



- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [_activityIndicatorView stopAnimating];

    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext[@"js2ios"] = self;

    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };

    self.jsContext[@"setImgData"]  = ^(NSString *str){
        NSLog(@"setImgData");
    };
    
    [self.jsContext[@"getUserInfo"] callWithArguments:@[[self dataTOjsonString:self.modeldictary]]];

    
    
}

-(NSString*)dataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}



//加载失败时调用的方法
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
    NSLog(@"%@",error);
}

- (void)loginPage
{
    
    [JumpObject showLoginVC];
    
//    [self.navigationController popViewControllerAnimated:YES];
    
}
#pragma mark- 打印销售单
- (void)goPrintipSetVC
{
    PrintViewController *printVC = [[PrintViewController alloc]init];
    [self.navigationController pushViewController:printVC animated:YES];
}
//打印销售单供h5调用的方法
- (void)printSaleList:(NSString *)gDataStr
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUDHelper showHud:@"正在打印" mode:MBProgressHUDModeIndeterminate xOffset:0.0f yOffset:0.0f margin:15.0f];
    });
    
    
    NSDictionary *retDict = nil;
    if ([gDataStr isKindOfClass:[NSString class]]) {
        NSData *jsonData = [gDataStr dataUsingEncoding:NSUTF8StringEncoding];
        retDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        NSLog(@"打印数据字典--\n%@",[retDict description]);
        NSUserDefaults *userDeful = [NSUserDefaults standardUserDefaults];
        NSInteger pringDeviceKind = [userDeful integerForKey:@"printDeviceKind1"];
        NSString *orderIP = [userDeful objectForKey:@"orderIP"];
        NSString *ip = [NSString stringWithFormat:@"%@",orderIP];
        if (ip == nil || [ip isEqualToString:@""] || [userDeful objectForKey:@"orderIP"] ==nil) {
            [MBProgressHUDHelper hideAllHUD];
            [MBProgressHUDHelper showHud:@"打印IP设置为空，请设置IP" hideTime:2.5 view:self.view];
            return;
        }
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
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            
            if ([def objectForKey:@"fontSizeNum"]) {
                fontSize = [[def objectForKey:@"fontSizeNum"] intValue];
            }else{
                fontSize = 9;
            }
        }else if (pringDeviceKind == 1){//得实
            self.manager = [DSReceiptManager shareReceiptManager];
            fontSize = 20;
            isconnect = [self.manager connectWifi:ip andPort:9100];
        }
        x = 1;
        y = 1;
        tailPos = 0;
        _cgBoldweight = UIFontWeightRegular;
        _linkList = [NSMutableArray arrayWithCapacity:2];
        if (isconnect == YES) {
            if (pringDeviceKind == 0) {
                [self saleOrderPrint:retDict];;
            }else if (pringDeviceKind == 1){
                
                [self DSSaleOrderPrint:retDict];;

            }
        }else{
            [MBProgressHUDHelper hideAllHUD];
            [MBProgressHUDHelper showHud:[NSString stringWithFormat:@"打印机连接失败"] hideTime:2.5 view:self.view];
        }
        
    }else{
        [MBProgressHUDHelper hideAllHUD];
        [MBProgressHUDHelper showHud:[NSString stringWithFormat:@"无数据"] hideTime:2.5 view:self.view];
    }
}

- (void)saleOrderPrint:(NSDictionary *)dataDic
{
    NSArray *saleOrderArray = [dataDic objectForKey:@"orders"];
    
    NSDictionary *saleOrderDic = [saleOrderArray objectAtIndex:0];
    
    SaleOrderModel *saleDataModel = [[SaleOrderModel alloc]initWithDicionary:saleOrderDic];
    NSLog(@"%@",saleDataModel);
    NSMutableArray *datilModelArray = [NSMutableArray arrayWithCapacity:2];
    for (NSDictionary *datilDic in saleDataModel.orderDtls) {
        SalesDtlBeanModel *datilModel = [[SalesDtlBeanModel alloc]initWithDicionary:datilDic];
        [datilModelArray addObject:datilModel];
    }
    saleDataModel.orderDtls = datilModelArray;
    
    NSMutableArray *orderPayModelArray = [NSMutableArray arrayWithCapacity:2];
    for (NSDictionary *payDic in saleDataModel.orderPaywayList) {
        OrderPayWayBeanModel *orderPayModel = [[OrderPayWayBeanModel alloc]initWithDicionary:payDic];
        [orderPayModelArray addObject:orderPayModel];
    }
    saleDataModel.orderPaywayList = orderPayModelArray;
    if (JumpObject.isNewPrint == YES) {
        NSMutableArray *customerCardsList = [NSMutableArray arrayWithCapacity:10];
        if ([dataDic objectForKey:@"customerCards"]) {
            NSArray *customerCards = [dataDic objectForKey:@"customerCards"];
            for (NSDictionary *dic in customerCards) {
                CustomerCards *cardDataModel = [[CustomerCards alloc]initWithDicionary:dic];
                [customerCardsList addObject:cardDataModel];
            }
        }
        int num = 1;
        if ([[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"num_sale_ticket_pda"] objectForKey:@"defaultValue"]) {
            num = [[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"num_sale_ticket_pda"] objectForKey:@"defaultValue"] intValue];
        }
        for (int i = 0; i < num; i++) {
            BOOL  isend = NO;
            if (i == (num -1)) {
                isend = YES;
            }
            [self newPrintSaleOrder:saleDataModel andOrderList:saleDataModel.orderDtls andOrderPayWayList:saleDataModel.orderPaywayList andCustomerCardslist:customerCardsList isEnd:isend];
        }
    }else{
        int num = 1;
        if ([[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"num_sale_ticket_pda"] objectForKey:@"defaultValue"]) {
            num = [[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"num_sale_ticket_pda"] objectForKey:@"defaultValue"] intValue];
        }
        for (int i = 0; i < num; i++) {
            BOOL  isend = NO;
            if (i == (num -1)) {
                isend = YES;
            }
            [self printSaleOrder:saleDataModel andOrderList:saleDataModel.orderDtls andOrderPayWayList:saleDataModel.orderPaywayList isEnd:isend];
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
        }else{
            xPos += 10;
            xPos += 11.5;
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
    if (isEnd == YES) {
        if (_ptkTestUtil != nil) {
            [_ptkTestUtil DSCloseWifi];
            [MBProgressHUDHelper hideAllHUD];
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
    [_ptkTestUtil DSSetBarcodeDefaults:2 andWideToNarrowRatio:3.0];
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
        NSString *shopAddress = [[JumpObject.userMain objectForKey:@"shopInfo"] objectForKey:@"address"];
        if ([shopAddress isKindOfClass: [NSNull class]] == NO && [shopAddress isEqualToString:@"null"] == NO) {
            //打印店铺地址
            if(shopAddress.length > 20){
                NSString *firstStr = [shopAddress substringWithRange:NSMakeRange(0, 20)];
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:firstStr andShowStyle:true];
                NSString *subStr = [shopAddress substringFromIndex:20];
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos + 3) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:subStr andShowStyle:true];
                
            }else{
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos + 1) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:shopAddress andShowStyle:true];
            }
        }else{
            
        }
        id  shopTel = [[JumpObject.userMain objectForKey:@"shopInfo"] objectForKey:@"tel"];
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
        xPos += 13;
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
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(90) andVertical:printHight + 0.35 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",(([dataModel.remainAmount isKindOfClass:[NSNull class]] || dataModel.remainAmount == NULL)?@"":dataModel.remainAmount)] andShowStyle:TRUE];
    
    //由登录接口返回参数控制是否打印显示
    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_brand_no"] objectForKey:@"defaultValue"] integerValue] == 0) {
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.35 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.companyName] andShowStyle:TRUE];
    }
    
    [_linkList removeAllObjects];
    if (orderPayWayList && orderPayWayList.count > 0) {
        for (int i = 0; i<orderPayWayList.count; i++) {
            OrderPayWayBeanModel *orderPayModel = [orderPayWayList objectAtIndex:i];
            [_linkList addObject:[NSString stringWithFormat:@"%@:%.2f",orderPayModel.payName,orderPayModel.amount]];
            
        }
        NSString *payName = _linkList[_linkList.count-1];
        NSData *bytesData = [payName dataUsingEncoding:NSUTF8StringEncoding];
        
        double pos = 105 - bytesData.length * 1 - 5;
        double ymoneyPos = printHight;// 英尺
        
        for (NSInteger j = _linkList.count - 1; j > 0; j--) {
            NSString *payName = _linkList[j];
            if (pos < 0) {
                pos = 105 - bytesData.length * 1 - 5;
                ymoneyPos += 0.2;
            }
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(pos) andVertical:ymoneyPos+0.56 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",payName] andShowStyle:TRUE];
            pos = pos - bytesData.length* 1 - 5;
        }
        
        if (pos < 0) {
            pos = 105 - bytesData.length * 1 -5;
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
            if(order_remark.length > 0 && order_remark.length <= 41) {
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.72 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",order_remark] andShowStyle:TRUE];
                
            } else {
                for (int i = 0; i <= order_remark.length/41; i++ ) {
                    if((i + 1) * 41 >= order_remark.length) {
                        NSString *subString = [order_remark substringWithRange:NSMakeRange(i*41, order_remark.length - i*41)];
                        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.77+remarkHeight andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:subString andShowStyle:TRUE];
                    } else {
                        NSString *subString = [order_remark substringWithRange:NSMakeRange(i*40, 41)];
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
                                NSString *subStrs = [subRemark substringWithRange:NSMakeRange(j*41, len - j*41)];
                                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.77+remarkHeight+i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",subStrs] andShowStyle:TRUE];
                            } else {
                                NSString *subStrss = [subRemark substringWithRange:NSMakeRange(j*41, 41)];
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
#pragma mark ——end
#pragma mark -得实打印销售单
- (void)DSSaleOrderPrint:(NSDictionary *)dataDic
{
    NSArray *saleOrderArray = [dataDic objectForKey:@"orders"];
    NSDictionary *saleOrderDic = [saleOrderArray objectAtIndex:0];
    
    SaleOrderModel *saleDataModel = [[SaleOrderModel alloc]initWithDicionary:saleOrderDic];
    NSLog(@"%@",saleDataModel);
    NSMutableArray *datilModelArray = [NSMutableArray arrayWithCapacity:2];
    for (NSDictionary *datilDic in saleDataModel.orderDtls) {
        SalesDtlBeanModel *datilModel = [[SalesDtlBeanModel alloc]initWithDicionary:datilDic];
        [datilModelArray addObject:datilModel];
    }
    saleDataModel.orderDtls = datilModelArray;
    
    NSMutableArray *orderPayModelArray = [NSMutableArray arrayWithCapacity:2];
    for (NSDictionary *payDic in saleDataModel.orderPaywayList) {
        OrderPayWayBeanModel *orderPayModel = [[OrderPayWayBeanModel alloc]initWithDicionary:payDic];
        [orderPayModelArray addObject:orderPayModel];
    }
    saleDataModel.orderPaywayList = orderPayModelArray;
    if (JumpObject.isNewPrint == YES) {
        NSMutableArray *customerCardsList = [NSMutableArray arrayWithCapacity:10];
        if ([dataDic objectForKey:@"customerCards"]) {
            NSArray *customerCards = [dataDic objectForKey:@"customerCards"];
            for (NSDictionary *dic in customerCards) {
                CustomerCards *cardDataModel = [[CustomerCards alloc]initWithDicionary:dic];
                [customerCardsList addObject:cardDataModel];
            }
        }
        int num = 1;
        if ([[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"num_sale_ticket_pda"] objectForKey:@"defaultValue"]) {
            num = [[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"num_sale_ticket_pda"] objectForKey:@"defaultValue"] intValue];
        }
        for (int i = 0; i < num; i++) {
            BOOL  isend = NO;
            if (i == (num -1)) {
                isend = YES;
            }
            [self DSNewPrintSaleOrder:saleDataModel andOrderList:saleDataModel.orderDtls andOrderPayWayList:saleDataModel.orderPaywayList andCustomerCardslist:customerCardsList isEnd:isend];
        }

    }else{
        int num = 1;
        if ([[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"num_sale_ticket_pda"] objectForKey:@"defaultValue"]) {
            num = [[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"num_sale_ticket_pda"] objectForKey:@"defaultValue"] intValue];
        }
        for (int i = 0; i < num; i++) {
            BOOL  isend = NO;
            if (i == (num -1)) {
                isend = YES;
            }
            [self DSPrintSaleOrder:saleDataModel andOrderList:saleDataModel.orderDtls andOrderPayWayList:saleDataModel.orderPaywayList isEnd:isend];

        }
    }
}
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
            yPos = 45 + 3;
            x++;
        }
    }
    if (!((yPos + 30) < 125) && yPos != 44) {
        x++;
    }
    // -----------------------------------------
    yPos = 45 + 3.0;
    [self.manager setPageLength:mm2inch(136)];
    for (int i = 0; i < num; i++) {
        SalesDtlBeanModel *saleBeanModel = [orderList objectAtIndex:i];
        if (printH) {
            [self DSSetPrintHeader:dataModel];
        }
        //编码
        CGFloat xPos =2.0;
        if ([saleBeanModel.itemCode isEqualToString:@""] || [saleBeanModel.itemCode isEqualToString:@"null"] || [saleBeanModel.itemCode isKindOfClass:[NSNull class]]) {
            saleBeanModel.itemCode = @" ";
        }
        [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:saleBeanModel.itemCode andShowStyle:TRUE];
        if([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_brand_no"] objectForKey:@"defaultValue"] integerValue] == 0){
            //品牌名
            xPos += 25;
            if ([saleBeanModel.brandNo isEqualToString:@""] || [saleBeanModel.brandNo isEqualToString:@"null"] || [saleBeanModel.brandNo isKindOfClass:[NSNull class]]) {
                saleBeanModel.brandNo = @" ";
            }
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
            if ([saleBeanModel.sizeNo isEqualToString:@""] || [saleBeanModel.sizeNo isEqualToString:@"null"] || [saleBeanModel.sizeNo isKindOfClass:[NSNull class]]) {
                saleBeanModel.sizeNo = @" ";
            }
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
        }else{
            xPos += 10;
            xPos += 11.5;
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
            yPos = 48;
            printH = true;
        }
    }
    
    if (yPos == 48) {//明细为空
        
        [self DSSetPrintHeader:dataModel];//打印小票头部
        tailPos = 48;
        [self DSPrintTail:orderPayWayList andDataModel:dataModel];//打印合计和付款方式
        
    } else if ((yPos + 25) < 130) {// 一页内
        tailPos = yPos + 1;//合计行开始的高度
        [self DSPrintTail:orderPayWayList andDataModel:dataModel];//打印合计和付款方式
        
    } else { // 1页内 头打不下
        //        [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(92 + 4) andVertical:mm2inch(yPos) andHeight:1 andWidth:1 andText:[NSString stringWithFormat:@"%d/%d页",y,x]];
        y++;
        [self.manager PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
        [self DSSetPrintHeader:dataModel];
        tailPos = 48;
        [self DSPrintTail:orderPayWayList andDataModel:dataModel];
    }
    [self.manager DSZPLSetCutter:1 andCutter:TRUE];
    result = [self.manager PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
    if (isEnd == YES) {
        if (self.manager != nil) {
            [self.manager DSCloseWifi];
            [MBProgressHUDHelper hideAllHUD];
        }
    }
    x = 1;
    y = 1;
    return result;
}
- (void)DSSetPrintHeader:(SaleOrderModel *)dataModel
{
    CGFloat yPos = 6;//打印纵向位置
    [self.manager PrintText:2 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
    [self.manager DSSetDirection:0];
    
    // 销售单上面打印店铺品牌的名称
    NSInteger isShowLogo = [[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_brand_logo"] objectForKey:@"defaultValue"] integerValue];
    if(isShowLogo == 1) {
        NSString *brandName = [[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_brand_name"] objectForKey:@"defaultValue"];
        
        if([brandName isKindOfClass:[NSNull class]] || [brandName isEqualToString:@"null"]|| [brandName isEqualToString:@""]) {
            // 不再打印这一行
            yPos += 3;
        } else {
            [self.manager DSZPLPrintTextLine:mm2inch(44) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:0 andSize:fontSize andText:brandName andShowStyle:TRUE];
            yPos += 3;
        }
    } else {
        // 为0时不显示，这一行不打印。
    }
    CGFloat line_Height = 4;//每行间隔高度
    //打印销售单头
    [self.manager DSZPLPrintTextLine:mm2inch(47) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"销售单" andShowStyle:TRUE];
    
    //打印条码
    if (dataModel.orderNo.length < 10 ) {
        [self.manager DSSetBarcodeDefaults:3 andWideToNarrowRatio:2.0];
    }else if (dataModel.orderNo.length < 18 ){
        [self.manager DSSetBarcodeDefaults:2 andWideToNarrowRatio:2.0];
    }else{
        [self.manager DSSetBarcodeDefaults:1 andWideToNarrowRatio:2.0];
    }
    yPos += line_Height;
//    [self.manager PrintCode128:0 andDarkness:30 andHorizontal:mm2inch(1.5) andVertical:mm2inch(yPos) andHeight:0.3 andHeightHuman:26 andWidthHuman:48 andFlagHuman:true andPosHuman:false andContent:[dataModel.orderNo isEqualToString:@""]?@"  ":dataModel.orderNo];
    [self.manager DSPrintCode128Dispersion:0 andDarkness:30 andHorizontal:mm2inch(1.5) andVertical:mm2inch(yPos) andHeight:0.3 andSizeHuman:26 andFont:nil andBold:YES andContent:dataModel.orderNo];
    //系统日
    [self.manager DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"系统日：%@",dataModel.createTime] andShowStyle:TRUE];
    //打印日
    NSDate * date = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init ];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * dateStr = [dateFormatter stringFromDate:date];
    yPos += line_Height;
    
    [self.manager DSZPLPrintTextLine:mm2inch(64.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"    打印：%@", dateStr] andShowStyle:TRUE];
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
        if ([dataModel.shopName isEqualToString:@""] || [dataModel.shopName isEqualToString:@"null"] || [dataModel.shopName isKindOfClass:[NSNull class]]) {
            dataModel.shopName = @" ";
        }
        [self.manager DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.shopName] andShowStyle:TRUE];
        
    }
    
    [self.manager DSZPLPrintTextLine:mm2inch(64.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"    类型：%@",([dataModel.businessTypeStr isEqualToString:@"null"] == NO &&dataModel.businessTypeStr.length >0?dataModel.businessTypeStr:@"")] andShowStyle:TRUE];
    
    //******
    yPos += line_Height;
    [self.manager DSZPLPrintTextLine:mm2inch(64.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"    单号：%@",dataModel.orderNo] andShowStyle:TRUE];
    
    //打印店铺地址和店铺电话
    
    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_shop_address"] objectForKey:@"defaultValue"] integerValue] == 0) {
        NSString *shopAddress = [[JumpObject.userMain objectForKey:@"shopInfo"] objectForKey:@"address"];
        if ([shopAddress isKindOfClass: [NSNull class]] == NO && [shopAddress isEqualToString:@"null"] == NO) {
            //打印店铺地址
            if(shopAddress.length > 20){
                NSString *firstStr = [shopAddress substringWithRange:NSMakeRange(0, 20)];
                [self.manager DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:firstStr andShowStyle:true];
                NSString *subStr = [shopAddress substringFromIndex:20];
                [self.manager DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos + 3) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:subStr andShowStyle:true];
                
            }else{
                if ([shopAddress isEqualToString:@""]) {
                    shopAddress = @" ";
                }
                [self.manager DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos + 1) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:shopAddress andShowStyle:true];
            }
        }else{
            
        }
        id  shopTel = [[JumpObject.userMain objectForKey:@"shopInfo"] objectForKey:@"tel"];
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
    [self.manager DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"会员卡：%@",([dataModel.vipNo isEqualToString:@"null"] == YES?@" ":dataModel.vipNo)] andShowStyle:TRUE];
    
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
        xPos += 13;
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
    [self.manager DSZPLPrintTextLine:mm2inch(90) andVertical:printHight + 0.35 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",(([dataModel.remainAmount isKindOfClass:[NSNull class]] || dataModel.remainAmount == NULL)?@"":dataModel.remainAmount)] andShowStyle:TRUE];
    
    //由登录接口返回参数控制是否打印显示
    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_brand_no"] objectForKey:@"defaultValue"] integerValue] == 0) {
        [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.35 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",[dataModel.companyName isEqualToString:@""]?@" ":dataModel.companyName] andShowStyle:TRUE];
    }
    
    [_linkList removeAllObjects];
    if (orderPayWayList && orderPayWayList.count > 0) {
        for (int i = 0; i<orderPayWayList.count; i++) {
            OrderPayWayBeanModel *orderPayModel = [orderPayWayList objectAtIndex:i];
            if ([orderPayModel.payName isKindOfClass:[NSNull class]] == NO && orderPayModel.payName.length > 0 && [orderPayModel.payName isEqualToString:@"null"] == NO) {
                [_linkList addObject:[NSString stringWithFormat:@"%@:%.2f",orderPayModel.payName,orderPayModel.amount]];
            }
            
        }
        NSString *payName = _linkList[_linkList.count-1];
        NSData *bytesData = [payName dataUsingEncoding:NSUTF8StringEncoding];
        
        double pos = 105 - bytesData.length * 1 - 10;
        double ymoneyPos = printHight;// 英尺
        
        for (NSInteger j = _linkList.count - 1; j >= 0; j--) {
            NSString *payName = _linkList[j];
            if (pos < 0) {
                pos = 105 - bytesData.length * 1 - 10;
                ymoneyPos += 0.2;
            }
            
            if (payName.length>0) {
                [self.manager DSZPLPrintTextLine:mm2inch(pos) andVertical:ymoneyPos+0.56 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",payName] andShowStyle:TRUE];
            }
            
            pos = pos - bytesData.length* 1 - 10;
        }
        
        if (pos < 0) {
            pos = 105 - bytesData.length * 1 -10;
            ymoneyPos += 0.2;
        }
//        [self.manager DSZPLPrintTextLine:mm2inch(pos) andVertical:ymoneyPos+0.56 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",_linkList[0]] andShowStyle:TRUE];
        
        [self.manager Print_HLine:0 andHorizontal:mm2inch(62) andVertical:printHight andLenth:mm2inch(38) andThick:mm2inch(0.3)];
        [self.manager Print_HLine:0 andHorizontal:mm2inch(62) andVertical:printHight + 0.5 andLenth:mm2inch(38) andThick:mm2inch(0.3)];
        //    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(6) andVertical:printHight + 0.69 andLenth:mm2inch(100) andThick:mm2inch(0.3)];
        [self.manager Print_HLine:0 andHorizontal:mm2inch(1) andVertical:printHight + 0.69 andLenth:mm2inch(100) andThick:mm2inch(0.3)];
        
        double remarkHeight = 0;
        NSString *order_remark = dataModel.remark;
        if ([order_remark isEqualToString:@"null"] == NO) {
            order_remark = [NSString stringWithFormat:@"订单备注：%@",order_remark];
            if(order_remark.length > 0 && order_remark.length <= 41) {
                [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.72 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",order_remark] andShowStyle:TRUE];
                
            } else {
                for (int i = 0; i <= order_remark.length/41; i++ ) {
                    if((i + 1) * 41 >= order_remark.length) {
                        NSString *subString = [order_remark substringWithRange:NSMakeRange(i*41, order_remark.length - i*41)];
                        [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.77+remarkHeight andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:subString andShowStyle:TRUE];
                    } else {
                        NSString *subString = [order_remark substringWithRange:NSMakeRange(i*40, 41)];
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
                                NSString *subStrs = [subRemark substringWithRange:NSMakeRange(j*41, len - j*41)];
                                [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.77+remarkHeight+i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",subStrs] andShowStyle:TRUE];
                            } else {
                                NSString *subStrss = [subRemark substringWithRange:NSMakeRange(j*41, 41)];
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
#pragma mark ——end
#pragma mark- 打印小票带二维码

/**
 打印新业务小票带二维码
 
 @param orderList orderList description
 @param orderPayWayList orderPayWayList description
 @return 0
 */
- (void)printBrandLogo:(NSString *)brandNo{
    NSInteger isShowLogo = [[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_brand_logo"] objectForKey:@"defaultValue"] integerValue];
    if(isShowLogo == 1) {
        NSString *brandName = [[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_brand_name"] objectForKey:@"defaultValue"];
        if([brandName isKindOfClass:[NSNull class]] || [brandName isEqualToString:@"null"]) {
            int size = 35;
            if ([self stringLength:brandNo] <= 7) {
                brandNo = [self changeStringTo7Str:brandNo];
            }else if ([self stringLength:brandNo] <= 12){
                brandNo = [NSString stringWithFormat:@"%@",brandNo];
                size = 32;;
            }else{
                brandNo = [NSString stringWithFormat:@"%@",brandNo];
                size = 28;
            }
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(6) andFontName:nil andBoldweight:UIFontWeightBold andSize:size andText:[NSString stringWithFormat:@"%@",brandNo] andShowStyle:false];
        } else {
            int size = 35;
            if ([self stringLength:brandName] <= 7) {
                brandName = [self changeStringTo7Str:brandName];
            }else if ([self stringLength:brandName] <= 12){
                brandName = [NSString stringWithFormat:@"%@",brandName];
                size = 32;;
            }else{
                brandName = [NSString stringWithFormat:@"%@",brandName];
                size = 28;
            }
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(6) andFontName:nil andBoldweight:UIFontWeightBold andSize:size andText:[NSString stringWithFormat:@"%@",brandName] andShowStyle:false];
        }
    }else{
        int size = 35;
        if ([self stringLength:brandNo] <= 7) {
            brandNo = [self changeStringTo7Str:brandNo];
        }else if ([self stringLength:brandNo] <= 12){
            brandNo = [NSString stringWithFormat:@"%@",brandNo];
            size = 32;;
        }else{
            brandNo = [NSString stringWithFormat:@"%@",brandNo];
            size = 28;
        }
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(6) andFontName:nil andBoldweight:UIFontWeightBold andSize:size andText:[NSString stringWithFormat:@"%@",brandNo] andShowStyle:false];
    }
    
}
-(NSString *)changeStringTo7Str:(NSString *)str
{
    if ([self stringLength:str] == 1) {
        str = [NSString stringWithFormat:@"         %@         ",str];
    }else if ([self stringLength:str] == 2){
        str = [NSString stringWithFormat:@"       %@        ",str];
    }else if ([self stringLength:str] == 3){
        str = [NSString stringWithFormat:@"      %@      ",str];
    }else if ([self stringLength:str] == 4){
        str = [NSString stringWithFormat:@"    %@     ",str];
    }else if ([self stringLength:str] == 5){
        str = [NSString stringWithFormat:@"   %@   ",str];
    }else if ([self stringLength:str] == 6){
        str = [NSString stringWithFormat:@" %@  ",str];
    }else {
        str = [NSString stringWithFormat:@"%@",str];
    }
    return str;
}
-(NSUInteger)stringLength:(NSString *) text{
    
    NSUInteger asciiLength = 0;
    
    for (NSUInteger i = 0; i < text.length; i++) {
        
        
        unichar uc = [text characterAtIndex: i];
        
        asciiLength += isascii(uc) ? 1 : 2;
    }
    
    NSUInteger unicodeLength = asciiLength;
    
    return unicodeLength;
    
}
- (void)newSetPrintHeader:(SaleOrderModel *)dataModel
{
    
    [_ptkTestUtil PrintText:2 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
    [_ptkTestUtil DSSetDirection:0];
    

    NSArray *brandNoList = [JumpObject.userMain objectForKey:@"brandNoList"];
    NSString *brandNo = [(NSDictionary *)[brandNoList objectAtIndex:0] objectForKey:@"brandNo"];
    [self printBrandLogo:brandNo];
    
    
    
    //打印条码
    if (dataModel.orderNo.length >=20) {
        [_ptkTestUtil DSSetBarcodeDefaults:1 andWideToNarrowRatio:3.0];
    }
//    [_ptkTestUtil DSSetBarcodeDefaults:2.5 andWideToNarrowRatio:2.0];
    [_ptkTestUtil DSSetBarcodeDefaults:2 andWideToNarrowRatio:3.0];
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
        NSString *shopAddress = [[JumpObject.userMain objectForKey:@"shopInfo"] objectForKey:@"address"];
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
            yPos += 4;
        }
        
        id  shopTel = [[JumpObject.userMain objectForKey:@"shopInfo"] objectForKey:@"tel"];
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
    xPos += 11;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"数量" andShowStyle:TRUE];
    xPos += 13;
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"金额" andShowStyle:TRUE];
    //打印明细头部第二条直线
    yPos = yPos + line_Height - 0.5;
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(1) andVertical:mm2inch(yPos) andLenth:mm2inch(100) andThick:mm2inch(0.3)];
}
- (BOOL)newPrintSaleOrder:(SaleOrderModel *)dataModel andOrderList:(NSArray *)orderList andOrderPayWayList:(NSArray *)orderPayWayList andCustomerCardslist:(NSArray *)customerCardsList isEnd:(NSInteger)isEnd
{
    double yPos = 53;// mm---used:46.5   andorid:53
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
                if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_display_styleno_itemcode"] objectForKey:@"defaultValue"] integerValue] == 1 && [saleBeanModel.styleNo isKindOfClass:[NSNull class]] == NO && saleBeanModel.styleNo != nil) {
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
                    xPos += 14.5;
                    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%.2f",saleBeanModel.tagPrice] andShowStyle:TRUE];
                    xPos += 13;
                    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%.2f%%",saleBeanModel.itemDiscount] andShowStyle:TRUE];
                    
                } else {
                    xPos += 14.5;
                    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"--"] andShowStyle:TRUE];//牌价
                    xPos += 15;
                    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"--"] andShowStyle:TRUE];//扣率
                }
                //数量
                xPos += 13.5;
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%ld",saleBeanModel.qty] andShowStyle:TRUE];
                //金额
                xPos += 11;
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%.2f",saleBeanModel.amount] andShowStyle:TRUE];
                yPos += 8;
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
                
            } else { // 1页内 头打不下
                [_ptkTestUtil PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
                [_ptkTestUtil setPageLengthEX:mm2inch(130)];
                [self newSetPrintHeader:dataModel];
                tailPos = 53;
                [self newPrintTail:orderPayWayList andDataModel:dataModel andCustomerCardsList:customerCardsList];
            }
            result = [_ptkTestUtil PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
        }
        
        if (isEnd == YES) {
            if (_ptkTestUtil != nil) {
                [_ptkTestUtil DSCloseWifi];
                [MBProgressHUDHelper hideAllHUD];
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
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(1) andVertical:printHight andLenth:mm2inch(100) andThick:mm2inch(0.3)];

    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.05 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"合计" andShowStyle:TRUE];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(75) andVertical:printHight + 0.05 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%ld",dataModel.qty] andShowStyle:TRUE];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(86) andVertical:printHight + 0.05 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.allAmount] andShowStyle:TRUE];
    
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.2 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"应收" andShowStyle:TRUE];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(86) andVertical:printHight + 0.2 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.allAmount] andShowStyle:TRUE];
    
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.35 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"实收" andShowStyle:TRUE];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(86) andVertical:printHight + 0.35 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.amount] andShowStyle:TRUE];
    
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.5 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"找零" andShowStyle:TRUE];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(86) andVertical:printHight + 0.5 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.remainAmount] andShowStyle:TRUE];
    
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(1) andVertical:printHight + 0.69 andLenth:mm2inch(100) andThick:mm2inch(0.3)];

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
       
        
        if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_vip_info"] objectForKey:@"defaultValue"] integerValue] == 1 && [dataModel.vipNo isEqualToString:@"null"] == NO) {
        
            NSString *vipNo = dataModel.vipNo;
            NSString *wildcardName = dataModel.wildcardName;
            NSInteger jifen = dataModel.baseScore + dataModel.proScore;
            NSString *str = [NSString stringWithFormat:@"会员卡号：%@  本次积分：%ld  卡级别：%@" ,vipNo,jifen,wildcardName];
            
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.95 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:str andShowStyle:TRUE];
            printHight += 0.5;
        }
        if([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_show_vip_info_baroque"] objectForKey:@"defaultValue"] integerValue] == 1 && customerCardsList != nil){
            [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(1) andVertical:printHight + 0.72 andLenth:mm2inch(100) andThick:mm2inch(0.3)];
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(43) andVertical:printHight+0.75 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"会员积分信息" andShowStyle:TRUE];
            [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(1) andVertical:printHight + 0.89 andLenth:mm2inch(100) andThick:mm2inch(0.3)];
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(10) andVertical:printHight+0.95 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"品牌名称" andShowStyle:TRUE];
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(45) andVertical:printHight+0.95 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"累计积分" andShowStyle:TRUE];
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(80) andVertical:printHight+0.95 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"有效积分" andShowStyle:TRUE];
            double inch = 1.1;
            for(int i = 0;i<customerCardsList.count;i++) {
                CustomerCards  *cardModel = [customerCardsList objectAtIndex:i];
//                mSmartPrint.DSZPLPrintTextLine(mm2inch(10), printHight + inch, fontface, false, fontSize, cards.getBrandName());
//                mSmartPrint.DSZPLPrintTextLine(mm2inch(45), printHight + inch, fontface, false, fontSize, cards.getRemainIntegral()+"");
//                mSmartPrint.DSZPLPrintTextLine(mm2inch(80), printHight + inch, fontface, false, fontSize, cards.getAccumulatedIntegral()+"");
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(10) andVertical:printHight+inch andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",cardModel.brandName] andShowStyle:TRUE];
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(45) andVertical:printHight+inch andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%ld",cardModel.remainIntegral] andShowStyle:TRUE];
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(80) andVertical:printHight+inch andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%ld",cardModel.accumulatedIntegral] andShowStyle:TRUE];
                inch += 0.14;
            }
            printHight += 0.6;
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
                    if (len > 41) {
                        for(int j = 0; j <= len/41; j++) {  // 每行最大长度是41个
                            if((j + 1) * 41 >= len) {
                                NSString *subStrs = [subRemark substringWithRange:NSMakeRange(j*41, len - (j*41))];
                                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.9+i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",subStrs] andShowStyle:TRUE];
                            } else {
                                NSString *subStrss = [subRemark substringWithRange:NSMakeRange(j*41,  41)];
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
        //打印二维码
        if ([[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_weixin_qrcode"] objectForKey:@"defaultValue"] != nil && [[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_weixin_qrcode"] objectForKey:@"defaultValue"] isKindOfClass:[NSNull class]] == NO){
            
            NSString  *logoImageUrl = [[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_weixin_qrcode"] objectForKey:@"defaultValue"];
            
            [_ptkSDks PTK_DrawBar2D_QR:mm2inch(19)*200 andY:(printHight +i+ 1)*200 andW:20 andV:20 andO:0 andR:4 andM:4 andG:2 andS:8 andStr:logoImageUrl];
        }
        if ([[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_weibo_qrcode"] objectForKey:@"defaultValue"] != nil && [[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_weibo_qrcode"] objectForKey:@"defaultValue"] isKindOfClass:[NSNull class]] == NO){
            
            NSString  *logoImageUrl = [[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_weibo_qrcode"] objectForKey:@"defaultValue"];
            
            [_ptkSDks PTK_DrawBar2D_QR:mm2inch(67)*200 andY:(printHight +i+ 1)*200 andW:160 andV:160 andO:0 andR:4 andM:4 andG:2 andS:8 andStr:logoImageUrl];
            
        }
        //二维码打印end
    }
}

#pragma mark- end
#pragma mark- 得实打印小票带二维码

/**
 打印新业务小票带二维码
 
 @param orderList orderList description
 @param orderPayWayList orderPayWayList description
 @return 0
 */
- (void)DSPrintBrandLogo:(NSString *)brandNo{
    NSInteger isShowLogo = [[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_brand_logo"] objectForKey:@"defaultValue"] integerValue];
    if(isShowLogo == 1) {
        NSString *brandName = [[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_brand_name"] objectForKey:@"defaultValue"];
        if([brandName isKindOfClass:[NSNull class]] || [brandName isEqualToString:@"null"] || [brandName isEqualToString:@""]) {
            int size = 35;
            if ([self DSStringLength:brandNo] <= 7) {
                brandNo = [self DSChangeStringTo7Str:brandNo];
            }else if ([self DSStringLength:brandNo] <= 12){
                brandNo = [NSString stringWithFormat:@"%@",brandNo];
                size = 32;;
            }else{
                brandNo = [NSString stringWithFormat:@"%@",brandNo];
                size = 28;
            }
            [self.manager DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(6) andFontName:nil andBoldweight:UIFontWeightBold andSize:size andText:[NSString stringWithFormat:@"%@",brandNo] andShowStyle:false];
        } else {
            int size = 35;
            if ([self DSStringLength:brandName] <= 7) {
                brandName = [self DSChangeStringTo7Str:brandName];
            }else if ([self DSStringLength:brandName] <= 12){
                brandName = [NSString stringWithFormat:@"%@",brandName];
                size = 32;;
            }else{
                brandName = [NSString stringWithFormat:@"%@",brandName];
                size = 28;
            }
            [self.manager DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(6) andFontName:nil andBoldweight:UIFontWeightBold andSize:size andText:[NSString stringWithFormat:@"%@",brandName] andShowStyle:false];
        }
    }else{
        int size = 35;
        if ([self DSStringLength:brandNo] <= 7) {
            brandNo = [self DSChangeStringTo7Str:brandNo];
        }else if ([self DSStringLength:brandNo] <= 12){
            brandNo = [NSString stringWithFormat:@"%@",brandNo];
            size = 32;;
        }else{
            brandNo = [NSString stringWithFormat:@"%@",brandNo];
            size = 28;
        }
        if (brandNo.length>0) {
            [self.manager DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(6) andFontName:nil andBoldweight:UIFontWeightBold andSize:size andText:[NSString stringWithFormat:@"%@",brandNo] andShowStyle:false];
        }
    }
}
-(NSString *)DSChangeStringTo7Str:(NSString *)str
{
    if ([self DSStringLength:str] == 1) {
        str = [NSString stringWithFormat:@"         %@         ",str];
    }else if ([self DSStringLength:str] == 2){
        str = [NSString stringWithFormat:@"       %@        ",str];
    }else if ([self DSStringLength:str] == 3){
        str = [NSString stringWithFormat:@"      %@      ",str];
    }else if ([self DSStringLength:str] == 4){
        str = [NSString stringWithFormat:@"    %@     ",str];
    }else if ([self DSStringLength:str] == 5){
        str = [NSString stringWithFormat:@"   %@   ",str];
    }else if ([self DSStringLength:str] == 6){
        str = [NSString stringWithFormat:@" %@  ",str];
    }else {
        str = [NSString stringWithFormat:@"%@",str];
    }
    return str;
}
-(NSUInteger)DSStringLength:(NSString *) text{
    
    NSUInteger asciiLength = 0;
    
    for (NSUInteger i = 0; i < text.length; i++) {
        
        
        unichar uc = [text characterAtIndex: i];
        
        asciiLength += isascii(uc) ? 1 : 2;
    }
    
    NSUInteger unicodeLength = asciiLength;
    
    return unicodeLength;
    
}
- (void)DSNewSetPrintHeader:(SaleOrderModel *)dataModel
{
//    [self.manager setPageLength:mm2inch(136)];
    [self.manager PrintText:2 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
    [self.manager DSSetDirection:0];
    
    
    NSArray *brandNoList = [JumpObject.userMain objectForKey:@"brandNoList"];
    NSString *brandNo = [(NSDictionary *)[brandNoList objectAtIndex:0] objectForKey:@"brandNo"];
    [self DSPrintBrandLogo:brandNo];
    
    
    
    //打印条码
    if (dataModel.orderNo.length > 17) {
        [self.manager DSSetBarcodeDefaults:1 andWideToNarrowRatio:3.0];
    }else{
        [self.manager DSSetBarcodeDefaults:2 andWideToNarrowRatio:3.0];
    }
    if ([dataModel.orderNo isEqualToString:@""] || [dataModel.orderNo isEqualToString:@"null"] || [dataModel.orderNo isKindOfClass:[NSNull class]]) {
        dataModel.shopName = @" ";
    }
    [self.manager DSPrintCode128Dispersion:0 andDarkness:30 andHorizontal:mm2inch(1.5) andVertical:mm2inch(21) andHeight:0.3 andSizeHuman:26 andFont:nil andBold:YES andContent:dataModel.orderNo];
    
    CGFloat yPos = 6;//打印纵向位置
    CGFloat line_Height = 4;//每行间隔高度
    
    //系统日
    [self.manager DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"系统日：%@",dataModel.createTime] andShowStyle:TRUE];
    //打印日
    NSDate * date = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init ];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * dateStr = [dateFormatter stringFromDate:date];
    yPos += line_Height;
    
    [self.manager DSZPLPrintTextLine:mm2inch(64.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"    打印：%@", dateStr] andShowStyle:TRUE];
    //******交易日
    yPos += line_Height;
    [self.manager DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"交易日：%@",dataModel.outDate] andShowStyle:TRUE];
    //打印小票号
    yPos += line_Height;
    [self.manager DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"小票号：%@",dataModel.outDate] andShowStyle:TRUE];
    /**
     * 订单业务类型 Y 0-正常销售 1-跨店销售 2-商场团购 (3-公司团购，暂不启用） 3-内购 4-员购 5-专柜团购 6-特卖销售
     * 默认为0 - 离线开单为0
     */
    //******打印类型
    
    yPos += line_Height;
    
    
    [self.manager DSZPLPrintTextLine:mm2inch(64.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"    类型：%@",([dataModel.businessTypeStr isEqualToString:@"null"] == NO &&dataModel.businessTypeStr.length >0?dataModel.businessTypeStr:@"")] andShowStyle:TRUE];
    
    //******单号
    yPos += line_Height;
    [self.manager DSZPLPrintTextLine:mm2inch(64.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"    单号：%@",dataModel.orderNo] andShowStyle:TRUE];
    
    //******营业员
    yPos += line_Height;
    [self.manager DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"营业员：%@",dataModel.assistantName] andShowStyle:TRUE];
    
    //******打印店铺名
    yPos += line_Height;
    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_shop_name"] objectForKey:@"defaultValue"] integerValue] == 0) {
        if ([dataModel.shopName isEqualToString:@""] || [dataModel.shopName isEqualToString:@"null"] || [dataModel.shopName isKindOfClass:[NSNull class]]) {
            dataModel.shopName = @" ";
        }
        [self.manager DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.shopName] andShowStyle:TRUE];
        
    }
    
    //打印店铺地址和店铺电话
    yPos += line_Height;
    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_shop_address"] objectForKey:@"defaultValue"] integerValue] == 0) {
        NSString *shopAddress = [[JumpObject.userMain objectForKey:@"shopInfo"] objectForKey:@"address"];
        if ([shopAddress isKindOfClass: [NSNull class]] == NO && [shopAddress isEqualToString:@"null"] == NO) {
            //打印店铺地址
            if(shopAddress.length > 20){
                NSString *firstStr = [shopAddress substringWithRange:NSMakeRange(0, 20)];
                [self.manager DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:firstStr andShowStyle:true];
                NSString *subStr = [shopAddress substringFromIndex:20];
                [self.manager DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos + 3) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:subStr andShowStyle:true];
                yPos += 6;
                
            }else{
                if ([shopAddress isEqualToString:@""]) {
                    shopAddress = @" ";
                }
                [self.manager DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:shopAddress andShowStyle:true];
                yPos += 4;
            }
        }else{
            yPos += 4;
        }
        
        id  shopTel = [[JumpObject.userMain objectForKey:@"shopInfo"] objectForKey:@"tel"];
        if ([shopTel isKindOfClass: [NSNull class]] == NO && [shopTel isEqualToString:@"null"] == NO) {
            //打印店铺电话，和会员卡处于同一行
            [self.manager DSZPLPrintTextLine:mm2inch(1.5) andVertical:mm2inch(yPos)andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"Tel：%@",shopTel] andShowStyle:TRUE];
        }
    }
    
    //    //******会员卡
    //    yPos += line_Height;
    //    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"会员卡：%@",([dataModel.vipNo isEqualToString:@"null"] == YES?@"":dataModel.vipNo)] andShowStyle:TRUE];
    
    //打印一行直线，隔开小票头部，开始打印明细头部
    yPos += line_Height;
    [self.manager Print_HLine:0 andHorizontal:mm2inch(1) andVertical:mm2inch(yPos) andLenth:mm2inch(100) andThick:mm2inch(0.3)];
    yPos += 1;
    CGFloat xPos =2.0;
    [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"商品款号/商品编码" andShowStyle:TRUE];
    
    //    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_brand_no"] objectForKey:@"defaultValue"] integerValue] == 0) {
    //        //品牌是否显示
    //        xPos += 20;
    //        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"品牌" andShowStyle:TRUE];
    //    }else{
    //        xPos += 20;
    //    }
    xPos += 33;
    [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"规格" andShowStyle:TRUE];
    //    if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_discount"] objectForKey:@"defaultValue"] integerValue] == 0) {
    //牌价和折扣显示
    xPos += 15;
    [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"牌价" andShowStyle:TRUE];
    xPos += 13;
    [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"折扣" andShowStyle:TRUE];
    //    }else{
    //        xPos += 12;
    //        xPos += 11;
    //    }
    //    xPos += 11;
    //    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"结算价" andShowStyle:TRUE];
    xPos += 11;
    [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"数量" andShowStyle:TRUE];
    xPos += 13;
    [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"金额" andShowStyle:TRUE];
    //打印明细头部第二条直线
    yPos = yPos + line_Height - 0.5;
    [self.manager Print_HLine:0 andHorizontal:mm2inch(1) andVertical:mm2inch(yPos) andLenth:mm2inch(100) andThick:mm2inch(0.3)];
}
- (BOOL)DSNewPrintSaleOrder:(SaleOrderModel *)dataModel andOrderList:(NSArray *)orderList andOrderPayWayList:(NSArray *)orderPayWayList andCustomerCardslist:(NSArray *)customerCardsList isEnd:(NSInteger)isEnd
{
    double yPos = 53;// mm---used:46.5   andorid:53
    bool result = false;
    bool printH = true;
    if (dataModel != nil)
    {
        if (orderList != nil && [orderList count] > 0)
        {
            NSInteger num = [orderList count];
            int length = 48;
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
                [self.manager setPageLength:mm2inch(length+mm)];
                //                mSmartPrint.SetPageLength(mm2inch(length+mm));
            }else {
                [self.manager setPageLength:mm2inch(302)];
                //                mSmartPrint.SetPageLength(mm2inch(302));
            }
            // -----------------------------------------
            yPos = 53;
            for (int i = 0; i < num; i++) {
                SalesDtlBeanModel *saleBeanModel = [orderList objectAtIndex:i];
                if (printH) {
                    [self DSNewSetPrintHeader:dataModel];
                }
                //打印商品编码或款号
                CGFloat xPos = 2.0;
                if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_display_styleno_itemcode"] objectForKey:@"defaultValue"] integerValue] == 1 && [saleBeanModel.styleNo isKindOfClass:[NSNull class]] == NO && saleBeanModel.styleNo != nil) {
                    if ([saleBeanModel.styleNo isEqualToString:@""] || [saleBeanModel.styleNo isEqualToString:@"null"]) {
                        saleBeanModel.styleNo = @" ";
                    }
                    [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:saleBeanModel.styleNo andShowStyle:TRUE];
                }else{
                    if ([saleBeanModel.itemCode isEqualToString:@""] || [saleBeanModel.itemCode isEqualToString:@"null"] || [saleBeanModel.itemCode isKindOfClass:[NSNull class]]|| saleBeanModel.itemCode == nil) {
                        saleBeanModel.itemCode = @" ";
                    }
                    [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:saleBeanModel.itemCode andShowStyle:TRUE];
                }
                //打印名称
                if ([saleBeanModel.itemName isEqualToString:@""] || [saleBeanModel.itemName isEqualToString:@"null"] || [saleBeanModel.itemName isKindOfClass:[NSNull class]]) {
                    saleBeanModel.itemName = @" ";
                }
                [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos + 4) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:saleBeanModel.itemName andShowStyle:TRUE];
                //打印规格
                xPos += 32;
                if([saleBeanModel.colorNo isKindOfClass:[NSNull class]] == NO && [saleBeanModel.colorNo isEqualToString:@"null"] == NO && [saleBeanModel.colorNo isEqualToString:@""] == NO){
                    NSString *str = [NSString stringWithFormat:@"%@-%@",saleBeanModel.colorNo,saleBeanModel.sizeNo];
                    [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:str andShowStyle:TRUE];
                }else{
                    if ([saleBeanModel.sizeNo isEqualToString:@""] || [saleBeanModel.sizeNo isEqualToString:@"null"] || [saleBeanModel.sizeNo isKindOfClass:[NSNull class]]) {
                        saleBeanModel.sizeNo = @" ";
                    }
                    [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:saleBeanModel.sizeNo andShowStyle:TRUE];
                    
                }
                if (saleBeanModel.tagPrice > 0) {
                    xPos += 14.5;
                    [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%.2f",saleBeanModel.tagPrice] andShowStyle:TRUE];
                    xPos += 13;
                    [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%.2f%%",saleBeanModel.itemDiscount] andShowStyle:TRUE];
                    
                } else {
                    xPos += 14.5;
                    [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"--"] andShowStyle:TRUE];//牌价
                    xPos += 15;
                    [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"--"] andShowStyle:TRUE];//扣率
                }
                //数量
                xPos += 13.5;
                [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%ld",saleBeanModel.qty] andShowStyle:TRUE];
                //金额
                xPos += 11;
                [self.manager DSZPLPrintTextLine:mm2inch(xPos) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%.2f",saleBeanModel.amount] andShowStyle:TRUE];
                yPos += 8;
                if (yPos < 300) {
                    printH = false;
                } else {
                    z++;
                    [self.manager PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
                    
                    if(z*00 <= length){
                        [self.manager setPageLength:mm2inch(302)];
                    }else{
                        
                        [self.manager setPageLength:mm2inch((length%300) + mm)];
                    }
                    [self.manager PrintText:2 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
                    [self.manager DSSetDirection:0];
                    
                    yPos = 0;
                }
            }
            if (yPos <= 250) {
                
                tailPos = yPos;
                [self DSNewPrintTail:orderPayWayList andDataModel:dataModel andCustomerCardsList:customerCardsList];
                
            } else { // 1页内 头打不下
                [self.manager PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
                [self.manager setPageLength:mm2inch(130)];
                [self DSNewSetPrintHeader:dataModel];
                tailPos = 53;
                [self DSNewPrintTail:orderPayWayList andDataModel:dataModel andCustomerCardsList:customerCardsList];
            }
            [self.manager DSZPLSetCutter:1 andCutter:TRUE];
            result = [self.manager PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
        }
        
        if (isEnd == YES) {
            if (self.manager != nil) {
                [self.manager DSCloseWifi];
                [MBProgressHUDHelper hideAllHUD];
            }
        }
    }
    x = 1;
    y = 1;
    return result;
}


-(void)DSNewPrintTail:(NSArray *)orderPayWayList andDataModel:(SaleOrderModel *)dataModel andCustomerCardsList:(NSArray *)customerCardsList
{
    double printHight = mm2inch(tailPos);
    [self.manager Print_HLine:0 andHorizontal:mm2inch(1) andVertical:printHight andLenth:mm2inch(100) andThick:mm2inch(0.3)];
    
    [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.05 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"合计" andShowStyle:TRUE];
    [self.manager DSZPLPrintTextLine:mm2inch(75) andVertical:printHight + 0.05 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%ld",dataModel.qty] andShowStyle:TRUE];
    [self.manager DSZPLPrintTextLine:mm2inch(86) andVertical:printHight + 0.05 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.allAmount] andShowStyle:TRUE];
    
    [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.2 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"应收" andShowStyle:TRUE];
    [self.manager DSZPLPrintTextLine:mm2inch(86) andVertical:printHight + 0.2 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.allAmount] andShowStyle:TRUE];
    
    [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.35 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"实收" andShowStyle:TRUE];
    [self.manager DSZPLPrintTextLine:mm2inch(86) andVertical:printHight + 0.35 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.amount] andShowStyle:TRUE];
    
    [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.5 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"找零" andShowStyle:TRUE];
    [self.manager DSZPLPrintTextLine:mm2inch(86) andVertical:printHight + 0.5 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",dataModel.remainAmount] andShowStyle:TRUE];
    
    [self.manager Print_HLine:0 andHorizontal:mm2inch(1) andVertical:printHight + 0.69 andLenth:mm2inch(100) andThick:mm2inch(0.3)];
    
    [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.75 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"收款明细" andShowStyle:TRUE];
    
    
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
            if ([payName isEqualToString:@""] || [payName isEqualToString:@"null"] || [payName isKindOfClass:[NSNull class]]) {
                payName = @" ";
            }
            [self.manager DSZPLPrintTextLine:mm2inch(pos) andVertical:ymoneyPos+0.75 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",payName] andShowStyle:TRUE];
            pos = pos + bytesData.length*1;
        }
        
        
        if ([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_ticket_display_vip_info"] objectForKey:@"defaultValue"] integerValue] == 1 && [dataModel.vipNo isEqualToString:@"null"] == NO) {
            
            NSString *vipNo = dataModel.vipNo;
            NSString *wildcardName = dataModel.wildcardName;
            NSInteger jifen = dataModel.baseScore + dataModel.proScore;
            NSString *str = [NSString stringWithFormat:@"会员卡号：%@  本次积分：%ld  卡级别：%@" ,vipNo,jifen,wildcardName];
            
            [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.95 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:str andShowStyle:TRUE];
            printHight += 0.5;
        }
        if([[[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"is_show_vip_info_baroque"] objectForKey:@"defaultValue"] integerValue] == 1 && customerCardsList != nil){
            [self.manager Print_HLine:0 andHorizontal:mm2inch(1) andVertical:printHight + 0.72 andLenth:mm2inch(100) andThick:mm2inch(0.3)];
            [self.manager DSZPLPrintTextLine:mm2inch(43) andVertical:printHight+0.75 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"会员积分信息" andShowStyle:TRUE];
            [self.manager Print_HLine:0 andHorizontal:mm2inch(1) andVertical:printHight + 0.89 andLenth:mm2inch(100) andThick:mm2inch(0.3)];
            [self.manager DSZPLPrintTextLine:mm2inch(10) andVertical:printHight+0.95 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"品牌名称" andShowStyle:TRUE];
            [self.manager DSZPLPrintTextLine:mm2inch(45) andVertical:printHight+0.95 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"累计积分" andShowStyle:TRUE];
            [self.manager DSZPLPrintTextLine:mm2inch(80) andVertical:printHight+0.95 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"有效积分" andShowStyle:TRUE];
            double inch = 1.1;
            for(int i = 0;i<customerCardsList.count;i++) {
                CustomerCards  *cardModel = [customerCardsList objectAtIndex:i];
                //                mSmartPrint.DSZPLPrintTextLine(mm2inch(10), printHight + inch, fontface, false, fontSize, cards.getBrandName());
                //                mSmartPrint.DSZPLPrintTextLine(mm2inch(45), printHight + inch, fontface, false, fontSize, cards.getRemainIntegral()+"");
                //                mSmartPrint.DSZPLPrintTextLine(mm2inch(80), printHight + inch, fontface, false, fontSize, cards.getAccumulatedIntegral()+"");
                if ([cardModel.brandName isEqualToString:@""] || [cardModel.brandName isEqualToString:@"null"] || [cardModel.brandName isKindOfClass:[NSNull class]]) {
                    cardModel.brandName = @" ";
                }
                [self.manager DSZPLPrintTextLine:mm2inch(10) andVertical:printHight+inch andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",cardModel.brandName] andShowStyle:TRUE];
                [self.manager DSZPLPrintTextLine:mm2inch(45) andVertical:printHight+inch andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%ld",cardModel.remainIntegral] andShowStyle:TRUE];
                [self.manager DSZPLPrintTextLine:mm2inch(80) andVertical:printHight+inch andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%ld",cardModel.accumulatedIntegral] andShowStyle:TRUE];
                inch += 0.14;
            }
            printHight += 0.6;
        }
        printHight += 0.1;
        double i = mm2inch(2);
        id remark = [[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"print_ticket_remark"] objectForKey:@"defaultValue"];
        
        if ([remark isKindOfClass:[NSNull class]] == NO && [remark isEqualToString:@"null"] == NO) {
            NSArray *remarkArray = [(NSString *)remark componentsSeparatedByString:@"。"];
            if (remarkArray.count > 0) {
                [self.manager DSZPLPrintTextLine:mm2inch(45) andVertical:printHight + 0.85  andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:@"特别提示" andShowStyle:TRUE];
                for (NSString *subRemark in remarkArray) {
                    NSInteger len = subRemark.length;
                    if (len > 41) {
                        for(int j = 0; j <= len/41; j++) {  // 每行最大长度是41个
                            if((j + 1) * 41 >= len) {
                                NSString *subStrs = [subRemark substringWithRange:NSMakeRange(j*41, len - (j*41))];
                                [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.9+i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",subStrs] andShowStyle:TRUE];
                            } else {
                                NSString *subStrss = [subRemark substringWithRange:NSMakeRange(j*41,  41)];
                                [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.9+i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",subStrss] andShowStyle:TRUE];
                                i += mm2inch(3);
                            }
                        }
                    }else{
                        [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight+0.9+i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",[subRemark isEqualToString:@""]?@" ":subRemark] andShowStyle:TRUE];
                    }
                    i = i + mm2inch(3);
                }
            }
        }
        //打印二维码
        NSString  *logoImageUrl = [[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_weixin_qrcode"] objectForKey:@"defaultValue"];
        if (logoImageUrl != nil && [logoImageUrl isKindOfClass:[NSNull class]] == NO){
            
            [self.manager Print_QRCode:0 darkness:30 horizontal:mm2inch(19) vertical:(printHight +i+ 1) correct:@"L" content:logoImageUrl];
        }
        NSString  *logoImageUrl2 = [[[JumpObject.userMain objectForKey:@"shopParams"] objectForKey:@"ticket_print_weibo_qrcode"] objectForKey:@"defaultValue"];
        if (logoImageUrl2 != nil && [logoImageUrl2 isKindOfClass:[NSNull class]] == NO){
            
            [self.manager Print_QRCode:0 darkness:30 horizontal:mm2inch(67) vertical:(printHight +i+ 1) correct:@"L" content:logoImageUrl2];
            
        }

        //二维码打印end
    }
}

#pragma mark- end

#pragma mark- 打印购物清单
-(void)printShoppingOrderList:(NSString *)dataString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUDHelper showHud:@"正在打印" mode:MBProgressHUDModeIndeterminate xOffset:0.0f yOffset:0.0f margin:15.0f];
    });
    NSData *jsonData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *retDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *orderIP = [userDefaults objectForKey:@"orderIP"];
    NSString *ip = [NSString stringWithFormat:@"%@",orderIP];
    if (ip == nil || [ip isEqualToString:@""]|| [userDefaults objectForKey:@"orderIP"] ==nil) {
        [MBProgressHUDHelper hideAllHUD];
        [MBProgressHUDHelper showHud:@"打印IP设置为空，请设置IP" hideTime:2.5 view:self.view];
        return;
    }
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
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        
        if ([def objectForKey:@"fontSizeNum"]) {
            fontSize = [[def objectForKey:@"fontSizeNum"] intValue];
        }else{
            fontSize = 9;
        }
    }else if (pringDeviceKind == 1){//得实
        self.manager = [DSReceiptManager shareReceiptManager];
        fontSize = 20;
        isconnect = [self.manager connectWifi:ip andPort:9100];
    }
    x = 1;
    y = 1;
    tailPos = 0;
    _cgBoldweight = UIFontWeightRegular;
    //        UIFontWeightUltraLight  - 超细字体
    //        UIFontWeightThin  - 纤细字体
    //        UIFontWeightLight  - 亮字体
    //        UIFontWeightRegular  - 常规字体
    //        UIFontWeightMedium  - 介于Regular和Semibold之间
    //        UIFontWeightSemibold  - 半粗字体
    //        UIFontWeightBold  - 加粗字体
    //        UIFontWeightHeavy  - 介于Bold和Black之间
    //        UIFontWeightBlack  - 最粗字体(理解)
    _linkList = [[NSMutableArray alloc]initWithCapacity:3];
    if (isconnect == YES) {
        if (pringDeviceKind == 0) {
            [_ptkSDks PTKClearBuffer];
            ShoppingListBean *shoppingBeanModel = [[ShoppingListBean alloc]initWithDicionary:retDict];
            NSArray *orderDtls = [retDict objectForKey:@"orderDtls"];
            NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:2];
            for (NSDictionary *dic in orderDtls) {
                OcOrderDtlDto *ocModel = [[OcOrderDtlDto alloc]initWithDicionary:dic];
                [tempArray addObject:ocModel];
            }
            shoppingBeanModel.orderDtls = tempArray;
            [self PrintShoppingOrder:shoppingBeanModel];
        }else if (pringDeviceKind == 1){
            ShoppingListBean *shoppingBeanModel = [[ShoppingListBean alloc]initWithDicionary:retDict];
            NSArray *orderDtls = [retDict objectForKey:@"orderDtls"];
            NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:2];
            for (NSDictionary *dic in orderDtls) {
                OcOrderDtlDto *ocModel = [[OcOrderDtlDto alloc]initWithDicionary:dic];
                [tempArray addObject:ocModel];
            }
            shoppingBeanModel.orderDtls = tempArray;
            [self DSPrintShoppingOrder:shoppingBeanModel];
        }
    }else{
        [MBProgressHUDHelper hideAllHUD];
        [MBProgressHUDHelper showHud:[NSString stringWithFormat:@"打印机连接失败"] hideTime:2.5 view:self.view];
    }
}
- (BOOL)PrintShoppingOrder:(ShoppingListBean *)shoppingListBean
{
    double yPos = 50.0;//
    BOOL result = false;
    BOOL printH = true;
    if (shoppingListBean != NULL) {
//        mSmartPrint.SetPageLength(mm2inch(136));
        [_ptkTestUtil setPageLengthEX:mm2inch(136)];
        NSArray *orderDtlDtos = shoppingListBean.orderDtls;
        if (orderDtlDtos != nil && orderDtlDtos.count > 0) {
            NSInteger num = orderDtlDtos.count;
            // -----------------------------------------
            for (int i = 0; i < num; i++) {
                yPos += 4.02;
                if (!(yPos < 125)) {
                    yPos = 50.0;
                    x++;
                }
            }
            if (!((yPos + 30) < 125) && yPos != 44) {
                x++;
            }
            // -----------------------------------------
            yPos = 50.0;
            for (int i = 0; i < num; i++) {
                if (printH) {
                    [self printShoppingListHead:shoppingListBean];
                }
                OcOrderDtlDto *ocOrderModel = orderDtlDtos[i];
                NSString *itemName = ocOrderModel.itemName;
                if( itemName.length > 27) {
                    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",[itemName substringWithRange:NSMakeRange(0, 27)]] andShowStyle:TRUE];
                    
                    if(itemName.length <= 54) {
                            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(yPos + 3) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",[itemName substringWithRange:NSMakeRange(27, itemName.length - 27)]] andShowStyle:TRUE];
                    } else {
                            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(yPos + 3) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@...",[itemName substringWithRange:NSMakeRange(27, 54-27)]] andShowStyle:TRUE];
                    }
                }else{
                    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",itemName] andShowStyle:TRUE];
                }
                
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",ocOrderModel.thirdSpec] andShowStyle:TRUE];
                [_ptkTestUtil DSZPLPrintTextLine:mm2inch(90) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%ld",ocOrderModel.qty] andShowStyle:TRUE];
               
                yPos += 4.02;
                if (yPos < 121) {
                    printH = false;
                } else {
                    y++;
                    [_ptkTestUtil PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
                    yPos = 50.0;
                    printH = true;
                }
            }
            
            if (yPos == 50) {
                [self printShoppingListHead:shoppingListBean];
                tailPos = 35;
                [self printShoppingListTail:shoppingListBean];
                
            } else if ((yPos + 25) < 130) {// 一页内
                tailPos = yPos + 1;
                [self printShoppingListTail:shoppingListBean];
                
            } else { // 1页内 头打不下
                y++;
                [_ptkTestUtil PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
                [self printShoppingListHead:shoppingListBean];
                tailPos = 50;
                [self printShoppingListTail:shoppingListBean];
            }
            [_ptkTestUtil DSZPLSetCutter:1 andCutter:true];
            result = [_ptkTestUtil PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
            
        }
        
        if (_ptkTestUtil != nil) {
            [_ptkTestUtil DSCloseWifi];
            [MBProgressHUDHelper hideAllHUD];
        }
        
    }
    x = 1;
    y = 1;
    return result;
}
/**
 * 购物清单头部
 * @param shoppingListBean
 */
- (void)printShoppingListHead:(ShoppingListBean *)shoppingListBean {
    if(shoppingListBean == nil) {
        return;
    }
    
//    mSmartPrint.PrintText(2, 30, 0, 0, 1, 1, "");
    [_ptkTestUtil PrintText:2 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
//    mSmartPrint.DSSetDirection(0);
    [_ptkTestUtil DSSetDirection:0];
//    mSmartPrint.DSZPLPrintTextLine(mm2inch(44), mm2inch(10), fontface, false, 32, shoppingListBean.getTitle());
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(44) andVertical:mm2inch(10) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:shoppingListBean.title andShowStyle:TRUE];
//    mSmartPrint.PrintCode128(0, 30, mm2inch(20), mm2inch(16), 0.3, 26, 50, false, false, shoppingListBean.getOrderNo());
    [_ptkTestUtil DSSetBarcodeDefaults:2 andWideToNarrowRatio:3.0];
    [_ptkTestUtil PrintCode128:0 andDarkness:30 andHorizontal:mm2inch(20) andVertical:mm2inch(16) andHeight:0.3 andHeightHuman:26 andWidthHuman:50 andFlagHuman:false andPosHuman:false andContent:shoppingListBean.orderNo];
    
    if(shoppingListBean.orderSource == 0) {
//        mSmartPrint.DSZPLPrintTextLine(mm2inch(2), mm2inch(26), fontface, false, fontSize, "订单编号： " + shoppingListBean.getOrderNo());
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(26) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"订单编号： %@",shoppingListBean.orderNo] andShowStyle:TRUE];
    } else if (shoppingListBean.orderSource == 1) {
        if(shoppingListBean.thirdOrderNo !=nil && [shoppingListBean.thirdOrderNo isEqualToString:@"null"] ==NO) {
//            mSmartPrint.DSZPLPrintTextLine(mm2inch(2), mm2inch(26), fontface, false, fontSize, "订单编号： " + shoppingListBean.getThirdOrderNo()); // 优购第三方订单号
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(26) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"订单编号： %@",shoppingListBean.thirdOrderNo] andShowStyle:TRUE];
        }
    }
    
    if(shoppingListBean.receivingName && [shoppingListBean.receivingName isEqualToString:@"null"] == NO) {
//        mSmartPrint.DSZPLPrintTextLine(mm2inch(2), mm2inch(30), fontface, false, fontSize, "客户名称： " + shoppingListBean.getReceivingName());
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(30) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"客户名称： %@",shoppingListBean.receivingName] andShowStyle:TRUE];
    }
//    mSmartPrint.DSZPLPrintTextLine(mm2inch(2), mm2inch(34), fontface, false, fontSize, "订购时间： "+ new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(shoppingListBean.getPayTime()));
    NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
    [forMatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *nowDate = [forMatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(shoppingListBean.payTime/1000)]];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(34) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"订购时间： %@",nowDate] andShowStyle:TRUE];
//    mSmartPrint.DSZPLPrintTextLine(mm2inch(65), mm2inch(34), fontface, false, fontSize, "商品数量： " + shoppingListBean.getQty());
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(34) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"商品数量： %ld",shoppingListBean.qty] andShowStyle:TRUE];
    
//    mSmartPrint.DSZPLPrintTextLine(mm2inch(2),mm2inch(45),fontface,false,fontSize,"商品名称");
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(45) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"商品名称"] andShowStyle:TRUE];
//    mSmartPrint.DSZPLPrintTextLine(mm2inch(65),mm2inch(45),fontface,false,fontSize,"规格");
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(45) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"规格"] andShowStyle:TRUE];
//    mSmartPrint.DSZPLPrintTextLine(mm2inch(90),mm2inch(45),fontface,false,fontSize,"数量");
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(90) andVertical:mm2inch(45) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"数量"] andShowStyle:TRUE];
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(1) andVertical:mm2inch(44) andLenth:mm2inch(100) andThick:mm2inch(0.3)];
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(1) andVertical:mm2inch(48.5) andLenth:mm2inch(100) andThick:mm2inch(0.3)];
}
- (void)printShoppingListTail:(ShoppingListBean *)shoppingListBean
{
    if(shoppingListBean == nil) {
        return;
    }
    
    double printHight = mm2inch(tailPos);
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(1) andVertical:printHight + 0.05 andLenth:mm2inch(100) andThick:mm2inch(0.3)];
    
    if(shoppingListBean.orderSource == 0 && shoppingListBean.expressNo !=nil && [shoppingListBean.expressNo isEqualToString:@"null"] ==NO ) {
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.06 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"发货联     快递单号： %@",shoppingListBean.expressNo] andShowStyle:TRUE];
    }
    
    double remarkHeight = 0;
    remarkHeight += mm2inch(3);
    double totalTipLines = mm2inch(2);
    NSString *printTicketRemark = shoppingListBean.printTicketRemark;
    
    if ([printTicketRemark isKindOfClass:[NSNull class]] == NO && [printTicketRemark isEqualToString:@"null"] ==NO && [printTicketRemark isEqualToString:@""] == NO) {
        NSArray *remarks = [NSArray array];
        if (printTicketRemark.length > 0) {
            remarks = [printTicketRemark componentsSeparatedByString:@"。"];
        }
        
        if (remarks.count > 0) {
            double i = mm2inch(2);
            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(45) andVertical:printHight + remarkHeight + 0.12 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"温馨提示"] andShowStyle:TRUE];
            for (NSString *s in remarks) {
                if (s.length > 40) {
                    for (int j = 0; j <= s.length / 41; j++) {  // 每行最大长度是41个
                        if ((j + 1) * 41 >= s.length) {
                            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + remarkHeight + 0.17 + i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@。",[s substringWithRange:NSMakeRange(j*41, s.length - j*41)]] andShowStyle:TRUE];
                        } else {
                            [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + remarkHeight + 0.17 + i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",[s substringWithRange:NSMakeRange(j*41, 41)]] andShowStyle:TRUE];
                            i += mm2inch(3);
                            totalTipLines += mm2inch(3);
                        }
                    }
                } else {
                    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + remarkHeight + 0.17 + i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@。",s] andShowStyle:TRUE];
                }
                
                i = i + mm2inch(3);
                totalTipLines += mm2inch(3);
                
            }
        }
    } // 打印 “温馨提示” 结束
    
    totalTipLines += mm2inch(3);
    if([shoppingListBean.receivingAddress isKindOfClass:[NSNull class]] == NO&& [shoppingListBean.receivingAddress isEqualToString:@"null"] == NO && shoppingListBean.receivingAddress.length > 0) {
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + remarkHeight + 0.17 + totalTipLines andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"退货地址： %@",shoppingListBean.receivingAddress] andShowStyle:TRUE];
    }
    
    if(shoppingListBean.orderSource == 1) { // 只有优购订单才打印这些
        
        NSString *receiveNameReturn = shoppingListBean.receivingNameReturn;
        NSString *zipCode = shoppingListBean.zipCode;
        NSString *receiveTel = shoppingListBean.receivingTel;
        
        receiveNameReturn = [receiveNameReturn isEqualToString:@"null"]?receiveNameReturn:@" ";
        zipCode =  [zipCode isEqualToString:@"null"]?receiveNameReturn:@" ";
        receiveTel = [receiveTel isEqualToString:@"null"]?receiveNameReturn:@" ";
        
        [_ptkTestUtil DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + remarkHeight + 0.17 + totalTipLines + mm2inch(3) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"收货人：%@        邮编：%@           电话：%@",receiveNameReturn,zipCode,receiveTel] andShowStyle:TRUE];
    }
    
}
#pragma mark- end
#pragma mark- 得实打印购物清单
- (BOOL)DSPrintShoppingOrder:(ShoppingListBean *)shoppingListBean
{
    double yPos = 50.0;//
    BOOL result = false;
    BOOL printH = true;
    if (shoppingListBean != NULL) {
        [self.manager setPageLength:mm2inch(136)];
        NSArray *orderDtlDtos = shoppingListBean.orderDtls;
        if (orderDtlDtos != nil && orderDtlDtos.count > 0) {
            NSInteger num = orderDtlDtos.count;
            // -----------------------------------------
            for (int i = 0; i < num; i++) {
                yPos += 4.02;
                if (!(yPos < 125)) {
                    yPos = 50.0;
                    x++;
                }
            }
            if (!((yPos + 30) < 125) && yPos != 44) {
                x++;
            }
            // -----------------------------------------
            yPos = 50.0;
            for (int i = 0; i < num; i++) {
                if (printH) {
                    [self DSPrintShoppingListHead:shoppingListBean];
                }
                OcOrderDtlDto *ocOrderModel = orderDtlDtos[i];
                NSString *itemName = ocOrderModel.itemName;
                if ([itemName isEqualToString:@""]) {
                    itemName = @" ";
                }
                if( itemName.length > 27) {
                    [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",[itemName substringWithRange:NSMakeRange(0, 27)]] andShowStyle:TRUE];
                    
                    if(itemName.length <= 54) {
                        NSString *strsss = [NSString stringWithFormat:@"%@",[itemName substringWithRange:NSMakeRange(27, itemName.length - 27)]];
                        [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(yPos + 3) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:strsss andShowStyle:TRUE];
                    } else {
                        [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(yPos + 3) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@...",[itemName substringWithRange:NSMakeRange(27, 54-27)]] andShowStyle:TRUE];
                    }
                }else{
                    [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",itemName] andShowStyle:TRUE];
                }
                if ([ocOrderModel.thirdSpec isEqualToString:@""]) {
                    ocOrderModel.thirdSpec = @"　";
                }
                [self.manager DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",ocOrderModel.thirdSpec] andShowStyle:TRUE];
                [self.manager DSZPLPrintTextLine:mm2inch(90) andVertical:mm2inch(yPos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%ld",ocOrderModel.qty] andShowStyle:TRUE];
                
                yPos += 5.02;
                if (yPos < 121) {
                    printH = false;
                } else {
                    y++;
                    [self.manager PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
                    yPos = 50.0;
                    printH = true;
                }
            }
            
            if (yPos == 50) {
                [self DSPrintShoppingListHead:shoppingListBean];
                tailPos = 35;
                [self DSPrintShoppingListTail:shoppingListBean];
                
            } else if ((yPos + 25) < 130) {// 一页内
                tailPos = yPos + 1;
                [self DSPrintShoppingListTail:shoppingListBean];
                
            } else { // 1页内 头打不下
                y++;
                [self.manager PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
                [self DSPrintShoppingListHead:shoppingListBean];
                tailPos = 50;
                [self DSPrintShoppingListTail:shoppingListBean];
            }
            [self.manager DSZPLSetCutter:1 andCutter:true];
            result = [self.manager PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
        }
        if (self.manager != nil) {
            [self.manager DSCloseWifi];
            [MBProgressHUDHelper hideAllHUD];
        }
        
    }
    x = 1;
    y = 1;
    return result;
}
/**
 * 购物清单头部
 * @param shoppingListBean
 */
- (void)DSPrintShoppingListHead:(ShoppingListBean *)shoppingListBean {
    if(shoppingListBean == nil) {
        return;
    }
    
    //    mSmartPrint.PrintText(2, 30, 0, 0, 1, 1, "");
    [self.manager PrintText:2 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
    //    mSmartPrint.DSSetDirection(0);
    [self.manager DSSetDirection:0];
    //    mSmartPrint.DSZPLPrintTextLine(mm2inch(44), mm2inch(10), fontface, false, 32, shoppingListBean.getTitle());
    if ([shoppingListBean.title isEqualToString:@""] || [shoppingListBean.title isKindOfClass:[NSNull class]]) {
        shoppingListBean.title = @"　";
    }
    [self.manager DSZPLPrintTextLine:mm2inch(44) andVertical:mm2inch(10) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:shoppingListBean.title andShowStyle:TRUE];
    //    mSmartPrint.PrintCode128(0, 30, mm2inch(20), mm2inch(16), 0.3, 26, 50, false, false, shoppingListBean.getOrderNo());
    if (shoppingListBean.orderNo.length < 30) {
        [self.manager DSSetBarcodeDefaults:2 andWideToNarrowRatio:3.0];
    }else{
        [self.manager DSSetBarcodeDefaults:1 andWideToNarrowRatio:3.0];
    }
    if ([shoppingListBean.orderNo isEqualToString:@""] || [shoppingListBean.orderNo isKindOfClass:[NSNull class]]) {
        shoppingListBean.orderNo = @"　";
    }
    [self.manager PrintCode128:0 andDarkness:30 andHorizontal:mm2inch(20) andVertical:mm2inch(16) andHeight:0.3 andHeightHuman:26 andWidthHuman:50 andFlagHuman:false andPosHuman:false andContent:shoppingListBean.orderNo];
//    [self.manager DSPrintCode128Dispersion:0 andDarkness:30 andHorizontal:mm2inch(20) andVertical:mm2inch(16) andHeight:0.3 andSizeHuman:15 andFont:nil andBold:YES andContent:shoppingListBean.orderNo];
    
    if(shoppingListBean.orderSource == 0) {
        //        mSmartPrint.DSZPLPrintTextLine(mm2inch(2), mm2inch(26), fontface, false, fontSize, "订单编号： " + shoppingListBean.getOrderNo());
        [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(26) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"订单编号： %@",shoppingListBean.orderNo] andShowStyle:TRUE];
    } else if (shoppingListBean.orderSource == 1) {
        if(shoppingListBean.thirdOrderNo !=nil && [shoppingListBean.thirdOrderNo isEqualToString:@"null"] ==NO) {
            //            mSmartPrint.DSZPLPrintTextLine(mm2inch(2), mm2inch(26), fontface, false, fontSize, "订单编号： " + shoppingListBean.getThirdOrderNo()); // 优购第三方订单号
            [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(26) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"订单编号： %@",shoppingListBean.thirdOrderNo] andShowStyle:TRUE];
        }
    }
    
    if(shoppingListBean.receivingName && [shoppingListBean.receivingName isEqualToString:@"null"] == NO) {
        //        mSmartPrint.DSZPLPrintTextLine(mm2inch(2), mm2inch(30), fontface, false, fontSize, "客户名称： " + shoppingListBean.getReceivingName());
        [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(30) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"客户名称： %@",shoppingListBean.receivingName] andShowStyle:TRUE];
    }
    //    mSmartPrint.DSZPLPrintTextLine(mm2inch(2), mm2inch(34), fontface, false, fontSize, "订购时间： "+ new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(shoppingListBean.getPayTime()));
    long paytIME = [[NSNumber numberWithLong:shoppingListBean.payTime] longValue]/1000;
    NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
    [forMatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *nowDate = [forMatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:paytIME]];
    [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(34) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"订购时间： %@",nowDate] andShowStyle:TRUE];
    //    mSmartPrint.DSZPLPrintTextLine(mm2inch(65), mm2inch(34), fontface, false, fontSize, "商品数量： " + shoppingListBean.getQty());
    [self.manager DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(34) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"商品数量： %ld",shoppingListBean.qty] andShowStyle:TRUE];
    
    //    mSmartPrint.DSZPLPrintTextLine(mm2inch(2),mm2inch(45),fontface,false,fontSize,"商品名称");
    [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:mm2inch(45) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"商品名称"] andShowStyle:TRUE];
    //    mSmartPrint.DSZPLPrintTextLine(mm2inch(65),mm2inch(45),fontface,false,fontSize,"规格");
    [self.manager DSZPLPrintTextLine:mm2inch(65) andVertical:mm2inch(45) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"规格"] andShowStyle:TRUE];
    //    mSmartPrint.DSZPLPrintTextLine(mm2inch(90),mm2inch(45),fontface,false,fontSize,"数量");
    [self.manager DSZPLPrintTextLine:mm2inch(90) andVertical:mm2inch(45) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"数量"] andShowStyle:TRUE];
    [self.manager Print_HLine:0 andHorizontal:mm2inch(1) andVertical:mm2inch(44) andLenth:mm2inch(100) andThick:mm2inch(0.3)];
    [self.manager Print_HLine:0 andHorizontal:mm2inch(1) andVertical:mm2inch(48.5) andLenth:mm2inch(100) andThick:mm2inch(0.3)];
}
- (void)DSPrintShoppingListTail:(ShoppingListBean *)shoppingListBean
{
    if(shoppingListBean == nil) {
        return;
    }
    
    double printHight = mm2inch(tailPos);
    [self.manager Print_HLine:0 andHorizontal:mm2inch(1) andVertical:printHight + 0.05 andLenth:mm2inch(100) andThick:mm2inch(0.3)];
    
    if(shoppingListBean.orderSource == 0 && shoppingListBean.expressNo !=nil  && [shoppingListBean.expressNo isEqualToString:@""] == NO) {
        [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + 0.06 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"发货联     快递单号： %@",shoppingListBean.expressNo] andShowStyle:TRUE];
    }
    
    double remarkHeight = 0;
    remarkHeight += mm2inch(3);
    double totalTipLines = mm2inch(2);
    NSString *printTicketRemark = shoppingListBean.printTicketRemark;
    
    if ([printTicketRemark isEqualToString:@"null"] ==NO && [printTicketRemark isEqualToString:@""] ==NO && [printTicketRemark isKindOfClass:[NSNull class]] ==NO) {
//        NSArray *remarks = [printTicketRemark componentsSeparatedByString:@"。"];
        NSArray *remarks = [NSArray array];
        if (printTicketRemark.length > 0) {
            remarks = [printTicketRemark componentsSeparatedByString:@"。"];
        }
        if (remarks.count > 0) {
            double i = mm2inch(2);
            [self.manager DSZPLPrintTextLine:mm2inch(45) andVertical:printHight + remarkHeight + 0.12 andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"温馨提示"] andShowStyle:TRUE];
            for (NSString *s in remarks) {
                if (s.length > 40) {
                    for (int j = 0; j <= s.length / 41; j++) {  // 每行最大长度是41个
                        if ((j + 1) * 41 >= s.length) {
                            [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + remarkHeight + 0.17 + i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@。",[s substringWithRange:NSMakeRange(j*41, s.length - j*41)]] andShowStyle:TRUE];
                        } else {
                            [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + remarkHeight + 0.17 + i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",[s substringWithRange:NSMakeRange(j*41, 41)]] andShowStyle:TRUE];
                            i += mm2inch(3);
                            totalTipLines += mm2inch(3);
                        }
                    }
                } else {
                    [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + remarkHeight + 0.17 + i andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@。",s] andShowStyle:TRUE];
                }
                
                i = i + mm2inch(3);
                totalTipLines += mm2inch(3);
                
            }
        }
    } // 打印 “温馨提示” 结束
    
    totalTipLines += mm2inch(3);
    if([shoppingListBean.receivingAddress isKindOfClass:[NSNull class]] ==NO && [shoppingListBean.receivingAddress isEqualToString:@""] == NO && shoppingListBean.receivingAddress.length > 0) {
        [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + remarkHeight + 0.17 + totalTipLines andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"退货地址： %@",shoppingListBean.receivingAddress] andShowStyle:TRUE];
    }
    
    if(shoppingListBean.orderSource == 1) { // 只有优购订单才打印这些
        
        NSString *receiveNameReturn = shoppingListBean.receivingNameReturn;
        NSString *zipCode = shoppingListBean.zipCode;
        NSString *receiveTel = shoppingListBean.receivingTel;
        
        receiveNameReturn = [receiveNameReturn isEqualToString:@"null"]?receiveNameReturn:@" ";
        zipCode =  [zipCode isEqualToString:@"null"]?receiveNameReturn:@" ";
        receiveTel = [receiveTel isEqualToString:@"null"]?receiveNameReturn:@" ";
        
        [self.manager DSZPLPrintTextLine:mm2inch(2) andVertical:printHight + remarkHeight + 0.17 + totalTipLines + mm2inch(3) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"收货人：%@        邮编：%@           电话：%@",receiveNameReturn,zipCode,receiveTel] andShowStyle:TRUE];
    }
    
}
#pragma mark- end
#pragma mark- 顺丰电子面单
-(void)printExpressDocument:(NSString *)dataString
{
    NSDictionary *retDict = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUDHelper showHud:@"正在打印" mode:MBProgressHUDModeIndeterminate xOffset:0.0f yOffset:0.0f margin:15.0f];
    });
    if ([dataString isKindOfClass:[NSString class]]) {
        NSData *jsonData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        retDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        ExpressInfoBean *expressInfoModel = [[ExpressInfoBean alloc]initWithDicionary:retDict];
        NSUserDefaults *userDeful = [NSUserDefaults standardUserDefaults];
        NSInteger pringDeviceKind = [userDeful integerForKey:@"printDeviceKind2"];
        NSString *codeIP = [userDeful objectForKey:@"codeIP"];
        NSString *ip = [NSString stringWithFormat:@"%@",codeIP];
        if (ip == nil || [ip isEqualToString:@""]|| [userDeful objectForKey:@"codeIP"] ==nil) {
            [MBProgressHUDHelper hideAllHUD];
            [MBProgressHUDHelper showHud:@"条码打印IP设置为空，请设置IP" hideTime:2.5 view:self.view];
            return;
        }
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
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            
            if ([def objectForKey:@"fontSizeNum"]) {
                fontSize = [[def objectForKey:@"fontSizeNum"] intValue];
            }else{
                fontSize = 9;
            }
        }else if (pringDeviceKind == 1){//得实
            self.manager = [DSReceiptManager shareReceiptManager];
            fontSize = 20;
            isconnect = [self.manager connectWifi:ip andPort:9100];
        }
        x = 1;
        y = 1;
        tailPos = 0;
        _cgBoldweight = UIFontWeightRegular;
        _linkList = [NSMutableArray arrayWithCapacity:2];
        if (isconnect == YES) {
            if (pringDeviceKind == 0) {
                [self PrintTagA:expressInfoModel];
            }else if (pringDeviceKind == 1){
                [self DSPrintTagA:expressInfoModel];
            }
        }else{
            [MBProgressHUDHelper hideAllHUD];
            [MBProgressHUDHelper showHud:@"条码打印连接失败" hideTime:2.5 view:self.view];
        }
        
    }else{
        
    }
}
- (BOOL)PrintTagA:(ExpressInfoBean *)expressInfo{
    
// 发开始标志
    [_ptkTestUtil PrintText:2 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
    [_ptkTestUtil DSSetDirection:0];
    int ypos = 3;
    int xpos = 4;
    // 标签第二页总共打印5行
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(17 - xpos) andVertical:mm2inch(8) andLenth:mm2inch(78) andThick:mm2inch(0.38)];
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(17 - xpos) andVertical:mm2inch(28) andLenth:mm2inch(78) andThick:mm2inch(0.38)];
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(17 - xpos) andVertical:mm2inch(39) andLenth:mm2inch(78) andThick:mm2inch(0.38)];
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(17 - xpos) andVertical:mm2inch(50) andLenth:mm2inch(78) andThick:mm2inch(0.38)];
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(17 - xpos) andVertical:mm2inch(61) andLenth:mm2inch(78) andThick:mm2inch(0.38)];
    
    // 打印4列
// 高度为55mm
    [_ptkTestUtil Print_VLine:0 andHorizontal:mm2inch(17 - xpos) andVertical:mm2inch(8) andLenth:mm2inch(53) andThick:mm2inch(0.38)];
// 最后一列
    [_ptkTestUtil Print_VLine:0 andHorizontal:mm2inch(17 - xpos +78-0.4) andVertical:mm2inch(1 + 4 + ypos) andLenth:mm2inch(53) andThick:mm2inch(0.38)];
// 第二列
    [_ptkTestUtil Print_VLine:0 andHorizontal:mm2inch(17 - xpos + 8) andVertical:mm2inch(1 + 4 + 20 + ypos) andLenth:mm2inch(22) andThick:mm2inch(0.38)];
// 第三列
    [_ptkTestUtil Print_VLine:0 andHorizontal:mm2inch(17 - xpos + 8 + 25) andVertical:mm2inch(1 + 4 + ypos) andLenth:mm2inch(20) andThick:mm2inch(0.38)];
    
//    Bitmap bitmap = resizeImage(BitmapFactory.decodeResource(context.getResources(), R.drawable.sf_logo), 200, 65);
//    Bitmap bitmap2 = resizeImage(BitmapFactory.decodeResource(context.getResources(), R.drawable.sf_tel), 200, 65);
    
//    if(bitmap != null) {
//        mSmartPrint.DSZPLDrawGraphics(mm2inch(17 + 1.5), mm2inch(10), bitmap);
//    }
//
//    if(bitmap2 != null) {
//        mSmartPrint.DSZPLDrawGraphics(mm2inch(17 + 1.5), mm2inch(18), bitmap2);
//    }
    
    // 打印条形码
    [_ptkTestUtil DSSetBarcodeDefaults:3 andWideToNarrowRatio:3.0];
    [_ptkTestUtil PrintCode128:0 andDarkness:30 andHorizontal:mm2inch(17+5+30-xpos) andVertical:mm2inch(12) andHeight:0.45 andHeightHuman:50 andWidthHuman:80 andFlagHuman:true andPosHuman:false andContent:expressInfo.expressNo];
    
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3-xpos) andVertical:mm2inch(1 + 4 +20 +1 + ypos) andHeight:1 andWidth:1 andText:@"寄"];;
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3-xpos) andVertical:mm2inch(1 + 4 +20 +4 + ypos) andHeight:1 andWidth:1 andText:@"件"];
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3-xpos) andVertical:mm2inch(1 + 4 +20 +7 + ypos) andHeight:1 andWidth:1 andText:@"人"];
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3-xpos) andVertical:mm2inch(1 + 4 +20 + 11 +1 + ypos) andHeight:1 andWidth:1 andText:@"收"];
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3-xpos) andVertical:mm2inch(1 + 4 +20 + 11 +4 + ypos) andHeight:1 andWidth:1 andText:@"件"];
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3-xpos) andVertical:mm2inch(1 + 4 +20 + 11 +7 + ypos) andHeight:1 andWidth:1 andText:@"人"];

    
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(17+3+8-xpos) andVertical:mm2inch(1+4+20 + 1 + ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize+1 andText:[NSString stringWithFormat:@"%@%@",expressInfo.fromName,expressInfo.fromTel] andShowStyle:true];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(17+3+8-xpos) andVertical:mm2inch(1+4+20 + 4 + ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize+1 andText:[NSString stringWithFormat:@"%@%@%@",expressInfo.fromProvince,expressInfo.fromCity,expressInfo.fromCounty] andShowStyle:true];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(17+3+8-xpos) andVertical:mm2inch(1+4+20 + 7 + ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize+1 andText:[NSString stringWithFormat:@"%@",expressInfo.fromAddress] andShowStyle:true];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(17+3+8-xpos) andVertical:mm2inch(1 + 4 + 20 + 11 + 1 + ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize+1 andText:[NSString stringWithFormat:@"%@%@",expressInfo.receivingName,expressInfo.receivingTel] andShowStyle:true];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(17+3+8-xpos) andVertical:mm2inch(1 + 4 + 20 + 11 + 4 + ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize+1 andText:[NSString stringWithFormat:@"%@%@%@",expressInfo.province,expressInfo.city,expressInfo.county] andShowStyle:true];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(17+3+8-xpos) andVertical:mm2inch(1 + 4 + 20 + 11 + 7 + ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize+1 andText:[NSString stringWithFormat:@"%@",expressInfo.receivingAddress] andShowStyle:true];
    
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17 + 1 - xpos) andVertical:mm2inch(1 + 4 +20 + 22 +4 + ypos) andHeight:1 andWidth:1 andText:@"备注："];
    [_ptkTestUtil PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
    
    
    BOOL isOK = [self printTAGB:expressInfo];
    return isOK;
    
}
- (BOOL)printTAGB:(ExpressInfoBean *)expressInfo {
    
    // 发开始标志
    [_ptkTestUtil PrintText:2 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
    [_ptkTestUtil DSSetDirection:0];
    int ypos = 1;
    int xpos = -4;
// 总共打印6行
// 打印标签横线长度为73mm
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(17 + xpos) andVertical:mm2inch(1+4 -ypos) andLenth:mm2inch(78) andThick:mm2inch(0.3)];
// 打印带条形码的那行
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(17 + xpos) andVertical:mm2inch(1+4 + 13 -ypos) andLenth:mm2inch(78) andThick:mm2inch(0.3)];
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(17 + xpos) andVertical:mm2inch(1+4 + 24 -ypos) andLenth:mm2inch(78) andThick:mm2inch(0.3)];
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(17 + xpos) andVertical:mm2inch(1+4 + 35 -ypos) andLenth:mm2inch(78) andThick:mm2inch(0.3)];
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(17 + xpos) andVertical:mm2inch(1+4 + 46 -ypos) andLenth:mm2inch(78) andThick:mm2inch(0.3)];
    [_ptkTestUtil Print_HLine:0 andHorizontal:mm2inch(17 + xpos) andVertical:mm2inch(1+4 + 57 -ypos) andLenth:mm2inch(78) andThick:mm2inch(0.3)];
    
// 高度为55mm
    [_ptkTestUtil Print_VLine:0 andHorizontal:mm2inch(17 + xpos) andVertical:mm2inch(1 + 4 - ypos) andLenth:mm2inch(57) andThick:mm2inch(0.3)];
// 最后一列
    [_ptkTestUtil Print_VLine:0 andHorizontal:mm2inch(17 + 78 - 0.4  + xpos) andVertical:mm2inch(1 + 4 - ypos) andLenth:mm2inch(57) andThick:mm2inch(0.3)];
// 第二列距第一列8mm
    [_ptkTestUtil Print_VLine:0 andHorizontal:mm2inch(17 + 8 + xpos) andVertical:mm2inch(1 + 4 + 13 - ypos) andLenth:mm2inch(44) andThick:mm2inch(0.3)];
// 第三列
    [_ptkTestUtil Print_VLine:0 andHorizontal:mm2inch(17 + 8 + 15 + xpos) andVertical:mm2inch(1 + 4 + 46 - ypos) andLenth:mm2inch(11) andThick:mm2inch(0.3)];
// 第四列上
    [_ptkTestUtil Print_VLine:0 andHorizontal:mm2inch(17 + 53 + xpos) andVertical:mm2inch(1 + 4  - ypos) andLenth:mm2inch(24) andThick:mm2inch(0.3)];
// 第四列下
    [_ptkTestUtil Print_VLine:0 andHorizontal:mm2inch(17 + 53 + xpos) andVertical:mm2inch(1 + 4 + 46 - ypos) andLenth:mm2inch(11) andThick:mm2inch(0.3)];
    
    // 打印条形码
    [_ptkTestUtil DSSetBarcodeDefaults:3 andWideToNarrowRatio:3.0];
    [_ptkTestUtil DSPrintCode128Dispersion:0 andDarkness:30 andHorizontal:mm2inch(17 + 5 + xpos) andVertical:mm2inch(6) andHeight:0.3 andSizeHuman:40 andFont:nil andBold:true andContent:expressInfo.expressNo];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(17 + 54.5 + xpos) andVertical:mm2inch(1 + 4 + 4.5 - ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize+9 andText:[NSString stringWithFormat:@"顺丰次日"] andShowStyle:true];
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 1 - ypos) andHeight:1 andWidth:1 andText:@"目"];
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 4 - ypos) andHeight:1 andWidth:1 andText:@"的"];
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 7 - ypos) andHeight:1 andWidth:1 andText:@"地"];
    if ([expressInfo.destCode isEqualToString:@"null"] ==NO && [expressInfo.destCode isKindOfClass:[NSNull class]] == NO) {
        [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17 + 3 + 5 + 2 + xpos) andVertical:mm2inch(1 + 4 + 11 + 4 - ypos) andHeight:1 andWidth:1 andText:expressInfo.destCode];
    }
    
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17 + 51 + 3 + xpos) andVertical:mm2inch(1 + 4 + 13 + 1 - ypos) andHeight:1 andWidth:1 andText:@"收件号："];
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17 + 51 + 3 + xpos) andVertical:mm2inch(1 + 4 + 13 + 4 - ypos) andHeight:1 andWidth:1 andText:@"寄件员："];
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17 + 51 + 3 + xpos) andVertical:mm2inch(1 + 4 + 13 + 7 - ypos) andHeight:1 andWidth:1 andText:@"派件员："];
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 11 + 1 - ypos) andHeight:1 andWidth:1 andText:@"收"];
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 11 + 4 - ypos) andHeight:1 andWidth:1 andText:@"件"];
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 11 + 7 - ypos) andHeight:1 andWidth:1 andText:@"人"];

    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + xpos) andVertical:mm2inch(1 + 4 + 13 + 11 + 1- ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize+1 andText:[NSString stringWithFormat:@"%@%@",expressInfo.receivingName,expressInfo.receivingTel] andShowStyle:true];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + xpos) andVertical:mm2inch(1 + 4 + 13 + 11 + 4- ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize+1 andText:[NSString stringWithFormat:@"%@%@%@",expressInfo.province,expressInfo.city,expressInfo.county] andShowStyle:true];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + xpos) andVertical:mm2inch(1 + 4 + 13 + 11 + 7- ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize+1 andText:[NSString stringWithFormat:@"%@",expressInfo.receivingAddress] andShowStyle:true];
    
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 22 + 1 - ypos) andHeight:1 andWidth:1 andText:@"寄"];;
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 22 + 4 - ypos) andHeight:1 andWidth:1 andText:@"件"];
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 22 + 7 - ypos) andHeight:1 andWidth:1 andText:@"人"];

    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + xpos) andVertical:mm2inch(1 + 4 + 13 + 22 + 1 - ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize+1 andText:[NSString stringWithFormat:@"%@%@",expressInfo.fromName,expressInfo.fromTel] andShowStyle:true];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + xpos) andVertical:mm2inch(1 + 4 + 13 + 22 + 4 - ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize+1 andText:[NSString stringWithFormat:@"%@%@%@",expressInfo.fromProvince,expressInfo.fromCity,expressInfo.fromCounty] andShowStyle:true];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + xpos) andVertical:mm2inch(1 + 4 + 13 + 22 + 7 - ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize+1 andText:[NSString stringWithFormat:@"%@",expressInfo.fromAddress] andShowStyle:true];
    
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 33 + 1 - ypos) andHeight:1 andWidth:1 andText:@"托"];
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 33 + 4 - ypos) andHeight:1 andWidth:1 andText:@"寄"];
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 33 + 7 - ypos) andHeight:1 andWidth:1 andText:@"物"];
    

    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + 14 + xpos) andVertical:mm2inch(1 + 4 + 13 + 33 + 0 - ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"付款方式：%@",expressInfo.payMode] andShowStyle:true];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + 14 + xpos) andVertical:mm2inch(1 + 4 + 13 + 33 + 2.7 - ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"月结账号：%@",expressInfo.monthCard] andShowStyle:true];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + 14 + xpos) andVertical:mm2inch(1 + 4 + 13 + 33 + 5.4 - ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"第三方地区：%@",expressInfo.payAreaCode] andShowStyle:true];
    [_ptkTestUtil DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + 14 + xpos) andVertical:mm2inch(1 + 4 + 11 + 33 + 10 - ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"重量：          费用:     "] andShowStyle:true];
    
    
    
//    mSmartPrint.PrintText(0, 30, mm2inch(17 + 53 + 3 + xpos), mm2inch(1 + 4 + 13 + 33 + 1 - ypos), 1, 1, "签名：");
//    mSmartPrint.PrintText(0, 30, mm2inch(17 + 53 + 3 + 7 + xpos), mm2inch(1 + 4 + 11 + 33 + 8.5 + 1 - ypos), 1, 1, "__月__日");
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17 + 53 + 3 + xpos) andVertical:mm2inch(1 + 4 + 13 + 33 + 1 - ypos) andHeight:1 andWidth:1 andText:@"签名："];
    [_ptkTestUtil PrintText:0 andDarkness:30 andHorizontal:mm2inch(17 + 53 + 3 + 7 + xpos) andVertical:mm2inch(1 + 4 + 11 + 33 + 8.5 + 1 - ypos) andHeight:1 andWidth:1 andText:@"__月__日"];
    
    
    BOOL isSuccess =     [_ptkTestUtil PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
    if (_ptkTestUtil != nil) {
        [_ptkTestUtil DSCloseWifi];
        [MBProgressHUDHelper hideAllHUD];
    }
    return isSuccess;
}
#pragma mark- end
#pragma mark- 得实顺丰电子面单

- (BOOL)DSPrintTagA:(ExpressInfoBean *)expressInfo{
    
    // 发开始标志
    [self.manager PrintText:2 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
    [self.manager DSSetDirection:0];
    [self.manager DSZPLSetCutter:1 andCutter:NO];
    int ypos = 2;
    int xpos = 14;
    // 标签第二页总共打印5行
    [self.manager Print_HLine:0 andHorizontal:mm2inch(xpos) andVertical:mm2inch(ypos) andLenth:mm2inch(78) andThick:mm2inch(0.38)];
    [self.manager Print_HLine:0 andHorizontal:mm2inch(xpos) andVertical:mm2inch(20+ypos) andLenth:mm2inch(78) andThick:mm2inch(0.38)];
    [self.manager Print_HLine:0 andHorizontal:mm2inch(xpos) andVertical:mm2inch(31+ypos) andLenth:mm2inch(78) andThick:mm2inch(0.38)];
    [self.manager Print_HLine:0 andHorizontal:mm2inch(xpos) andVertical:mm2inch(42+ypos) andLenth:mm2inch(78) andThick:mm2inch(0.38)];
    [self.manager Print_HLine:0 andHorizontal:mm2inch(xpos) andVertical:mm2inch(53+ypos) andLenth:mm2inch(78) andThick:mm2inch(0.38)];
    
    // 打印4列
    // 高度为55mm
    [self.manager Print_VLine:0 andHorizontal:mm2inch(xpos) andVertical:mm2inch(ypos) andLenth:mm2inch(53) andThick:mm2inch(0.38)];
    // 最后一列
    [self.manager Print_VLine:0 andHorizontal:mm2inch(xpos +78) andVertical:mm2inch(ypos) andLenth:mm2inch(53) andThick:mm2inch(0.38)];
    // 第二列
    [self.manager Print_VLine:0 andHorizontal:mm2inch(xpos + 8) andVertical:mm2inch(20 + ypos) andLenth:mm2inch(22) andThick:mm2inch(0.38)];
    // 第三列
    [self.manager Print_VLine:0 andHorizontal:mm2inch(xpos + 33) andVertical:mm2inch(ypos) andLenth:mm2inch(20) andThick:mm2inch(0.38)];
    
    UIImage *image2 = [UIImage imageNamed:@"sf_logo"];
    UIImage *image3 = [UIImage imageNamed:@"sf_tel"];
    //    Bitmap bitmap = resizeImage(BitmapFactory.decodeResource(context.getResources(), R.drawable.sf_logo), 200, 65);
    //    Bitmap bitmap2 = resizeImage(BitmapFactory.decodeResource(context.getResources(), R.drawable.sf_tel), 200, 65);

        if(image2 != nil) {
//            mSmartPrint.DSZPLDrawGraphics(mm2inch(17 + 1.5), mm2inch(10), bitmap);
            [self.manager DSZPLPrintImageWhite:mm2inch(5+xpos) vertical:mm2inch(ypos + 3) Bitmap:image2 paperWidth:300];
        }

        if(image3 != nil) {
            [self.manager DSZPLPrintImageWhite:mm2inch(5+xpos) vertical:mm2inch(ypos + 11) Bitmap:image3 paperWidth:300];
//            mSmartPrint.DSZPLDrawGraphics(mm2inch(17 + 1.5), mm2inch(18), bitmap2);
        }
    
    // 打印条形码
    if (expressInfo.expressNo.length > 12) {
        [self.manager DSSetBarcodeDefaults:1 andWideToNarrowRatio:3];
    }else{
        [self.manager DSSetBarcodeDefaults:2 andWideToNarrowRatio:2];
    }
    if ([expressInfo.expressNo isEqualToString:@""] || [expressInfo.expressNo isKindOfClass:[NSNull class]]) {
        expressInfo.expressNo = @"0";
    }
//    [self.manager PrintCode128:0 andDarkness:30 andHorizontal:mm2inch(35 + xpos) andVertical:mm2inch(ypos + 2) andHeight:0.45 andHeightHuman:20 andWidthHuman:50 andFlagHuman:true andPosHuman:false andContent:expressInfo.expressNo];
    [self.manager DSPrintCode128Dispersion:0 andDarkness:30 andHorizontal:mm2inch(35 + xpos) andVertical:mm2inch(ypos + 2) andHeight:0.45 andSizeHuman:16 andFont:nil andBold:true andContent:expressInfo.expressNo];
    
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(3+xpos) andVertical:mm2inch(21 + ypos) andHeight:1 andWidth:1 andText:@"寄"];
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(3+xpos) andVertical:mm2inch(24 + ypos) andHeight:1 andWidth:1 andText:@"件"];
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(3+xpos) andVertical:mm2inch(27 + ypos) andHeight:1 andWidth:1 andText:@"人"];
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(3+xpos) andVertical:mm2inch(32 + ypos) andHeight:1 andWidth:1 andText:@"收"];
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(3+xpos) andVertical:mm2inch(35 + ypos) andHeight:1 andWidth:1 andText:@"件"];
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(3+xpos) andVertical:mm2inch(38 + ypos) andHeight:1 andWidth:1 andText:@"人"];
    
    if ([expressInfo.fromName isEqualToString:@""] || [expressInfo.fromName isKindOfClass:[NSNull class]]) {
        expressInfo.fromName = @"　";
    }
    if ([expressInfo.fromProvince isEqualToString:@""] || [expressInfo.fromProvince isKindOfClass:[NSNull class]]) {
        expressInfo.fromProvince = @"　";
    }
    if ([expressInfo.fromAddress isEqualToString:@""] || [expressInfo.fromAddress isKindOfClass:[NSNull class]]) {
        expressInfo.fromAddress = @"　";
    }
    if ([expressInfo.receivingName isEqualToString:@""] || [expressInfo.receivingName isKindOfClass:[NSNull class]]) {
        expressInfo.receivingName = @"　";
    }
    if ([expressInfo.province isEqualToString:@""] || [expressInfo.province isKindOfClass:[NSNull class]]) {
        expressInfo.province = @"　";
    }
    if ([expressInfo.receivingAddress isEqualToString:@""] || [expressInfo.receivingAddress isKindOfClass:[NSNull class]]) {
        expressInfo.receivingAddress = @"　";
    }
    [self.manager DSZPLPrintTextLine:mm2inch(11+xpos) andVertical:mm2inch(21 + ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@%@",expressInfo.fromName,expressInfo.fromTel] andShowStyle:true];
    [self.manager DSZPLPrintTextLine:mm2inch(11+xpos) andVertical:mm2inch(24 + ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@%@%@",expressInfo.fromProvince,expressInfo.fromCity,expressInfo.fromCounty] andShowStyle:true];
    [self.manager DSZPLPrintTextLine:mm2inch(11+xpos) andVertical:mm2inch(27 + ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",expressInfo.fromAddress] andShowStyle:true];
    [self.manager DSZPLPrintTextLine:mm2inch(11+xpos) andVertical:mm2inch(32 + ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@%@",expressInfo.receivingName,expressInfo.receivingTel] andShowStyle:true];
    [self.manager DSZPLPrintTextLine:mm2inch(11+xpos) andVertical:mm2inch(35 + ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@%@%@",expressInfo.province,expressInfo.city,expressInfo.county] andShowStyle:true];
    [self.manager DSZPLPrintTextLine:mm2inch(11+xpos) andVertical:mm2inch(38 + ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",expressInfo.receivingAddress] andShowStyle:true];
    
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(3+xpos) andVertical:mm2inch(46 + ypos) andHeight:1 andWidth:1 andText:@"备注："];
    
    [self.manager PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];

    
    
    return [self DSPrintTAGB:expressInfo];
    
}
- (BOOL)DSPrintTAGB:(ExpressInfoBean *)expressInfo {
    
    // 发开始标志
    [self.manager PrintText:2 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
    [self.manager DSSetDirection:0];
    int ypos = 4;
    int xpos = -3;
    // 总共打印6行
    // 打印标签横线长度为73mm
    [self.manager Print_HLine:0 andHorizontal:mm2inch(17 + xpos) andVertical:mm2inch(1+4 -ypos) andLenth:mm2inch(78) andThick:mm2inch(0.3)];
    // 打印带条形码的那行
    [self.manager Print_HLine:0 andHorizontal:mm2inch(17 + xpos) andVertical:mm2inch(1+4 + 13 -ypos) andLenth:mm2inch(78) andThick:mm2inch(0.3)];
    [self.manager Print_HLine:0 andHorizontal:mm2inch(17 + xpos) andVertical:mm2inch(1+4 + 24 -ypos) andLenth:mm2inch(78) andThick:mm2inch(0.3)];
    [self.manager Print_HLine:0 andHorizontal:mm2inch(17 + xpos) andVertical:mm2inch(1+4 + 35 -ypos) andLenth:mm2inch(78) andThick:mm2inch(0.3)];
    [self.manager Print_HLine:0 andHorizontal:mm2inch(17 + xpos) andVertical:mm2inch(1+4 + 46 -ypos) andLenth:mm2inch(78) andThick:mm2inch(0.3)];
    [self.manager Print_HLine:0 andHorizontal:mm2inch(17 + xpos) andVertical:mm2inch(1+4 + 57 -ypos) andLenth:mm2inch(78) andThick:mm2inch(0.3)];
    
    // 高度为55mm
    [self.manager Print_VLine:0 andHorizontal:mm2inch(17 + xpos) andVertical:mm2inch(1 + 4 - ypos) andLenth:mm2inch(57) andThick:mm2inch(0.3)];
    // 最后一列
    [self.manager Print_VLine:0 andHorizontal:mm2inch(17 + 78 - 0.4  + xpos) andVertical:mm2inch(1 + 4 - ypos) andLenth:mm2inch(57) andThick:mm2inch(0.3)];
    // 第二列距第一列8mm
    [self.manager Print_VLine:0 andHorizontal:mm2inch(17 + 8 + xpos) andVertical:mm2inch(1 + 4 + 13 - ypos) andLenth:mm2inch(44) andThick:mm2inch(0.3)];
    // 第三列
    [self.manager Print_VLine:0 andHorizontal:mm2inch(17 + 8 + 15 + xpos) andVertical:mm2inch(1 + 4 + 46 - ypos) andLenth:mm2inch(11) andThick:mm2inch(0.3)];
    // 第四列上
    [self.manager Print_VLine:0 andHorizontal:mm2inch(17 + 53 + xpos) andVertical:mm2inch(1 + 4  - ypos) andLenth:mm2inch(24) andThick:mm2inch(0.3)];
    // 第四列下
    [self.manager Print_VLine:0 andHorizontal:mm2inch(17 + 53 + xpos) andVertical:mm2inch(1 + 4 + 46 - ypos) andLenth:mm2inch(11) andThick:mm2inch(0.3)];
    
    // 打印条形码
    if (expressInfo.expressNo.length >12) {
        [self.manager DSSetBarcodeDefaults:1 andWideToNarrowRatio:3];
    }else{
        [self.manager DSSetBarcodeDefaults:2 andWideToNarrowRatio:2];
    }
    if ([expressInfo.expressNo isEqualToString:@""] || [expressInfo.expressNo isKindOfClass:[NSNull class]]) {
        expressInfo.expressNo = @"0";
    }
    [self.manager DSPrintCode128Dispersion:0 andDarkness:30 andHorizontal:mm2inch(17 + 2 + xpos) andVertical:mm2inch(1+4 -ypos + 1) andHeight:0.3 andSizeHuman:20 andFont:nil andBold:true andContent:expressInfo.expressNo];
    [self.manager DSZPLPrintTextLine:mm2inch(17 + 54.5 + xpos) andVertical:mm2inch(1 + 4 + 4.5 - ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize + 21 andText:[NSString stringWithFormat:@"顺丰次日"] andShowStyle:true];
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 1 - ypos) andHeight:1 andWidth:1 andText:@"目"];
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 4 - ypos) andHeight:1 andWidth:1 andText:@"的"];
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 7 - ypos) andHeight:1 andWidth:1 andText:@"地"];
    if ([expressInfo.destCode isEqualToString:@"null"] ==NO && [expressInfo.destCode isKindOfClass:[NSNull class]] == NO && [expressInfo.destCode isEqualToString:@""] == NO) {
        [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17 + 3 + 5 + 2 + xpos) andVertical:mm2inch(1 + 4 + 11 + 4 - ypos) andHeight:1 andWidth:1 andText:expressInfo.destCode];
    }
    
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17 + 51 + 3 + xpos) andVertical:mm2inch(1 + 4 + 13 + 1 - ypos) andHeight:1 andWidth:1 andText:@"收件号："];
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17 + 51 + 3 + xpos) andVertical:mm2inch(1 + 4 + 13 + 4 - ypos) andHeight:1 andWidth:1 andText:@"寄件员："];
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17 + 51 + 3 + xpos) andVertical:mm2inch(1 + 4 + 13 + 7 - ypos) andHeight:1 andWidth:1 andText:@"派件员："];
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 11 + 1 - ypos) andHeight:1 andWidth:1 andText:@"收"];
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 11 + 4 - ypos) andHeight:1 andWidth:1 andText:@"件"];
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 11 + 7 - ypos) andHeight:1 andWidth:1 andText:@"人"];
    
    if ([expressInfo.receivingName isEqualToString:@""] || [expressInfo.receivingName isKindOfClass:[NSNull class]]) {
        expressInfo.receivingName = @"　";
    }
    if ([expressInfo.province isEqualToString:@""] || [expressInfo.province isKindOfClass:[NSNull class]]) {
        expressInfo.province = @"　";
    }
    if ([expressInfo.receivingAddress isEqualToString:@""] || [expressInfo.receivingAddress isKindOfClass:[NSNull class]]) {
        expressInfo.receivingAddress = @"　";
    }
    if ([expressInfo.fromTel isEqualToString:@""] || [expressInfo.fromTel isKindOfClass:[NSNull class]]) {
        expressInfo.fromTel = @"　";
    }
    if ([expressInfo.fromCity isEqualToString:@""] || [expressInfo.fromCity isKindOfClass:[NSNull class]]) {
        expressInfo.fromCity = @"　";
    }
    if ([expressInfo.fromAddress isEqualToString:@""] || [expressInfo.fromAddress isKindOfClass:[NSNull class]]) {
        expressInfo.fromAddress = @"　";
    }
    [self.manager DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + xpos) andVertical:mm2inch(1 + 4 + 13 + 11 + 1- ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@%@",expressInfo.receivingName,expressInfo.receivingTel] andShowStyle:true];
    [self.manager DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + xpos) andVertical:mm2inch(1 + 4 + 13 + 11 + 4- ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@%@%@",expressInfo.province,expressInfo.city,expressInfo.county] andShowStyle:true];
    [self.manager DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + xpos) andVertical:mm2inch(1 + 4 + 13 + 11 + 7- ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",expressInfo.receivingAddress] andShowStyle:true];
    
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 22 + 1 - ypos) andHeight:1 andWidth:1 andText:@"寄"];;
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 22 + 4 - ypos) andHeight:1 andWidth:1 andText:@"件"];
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 22 + 7 - ypos) andHeight:1 andWidth:1 andText:@"人"];
    
    [self.manager DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + xpos) andVertical:mm2inch(1 + 4 + 13 + 22 + 1 - ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@%@",expressInfo.fromName,expressInfo.fromTel] andShowStyle:true];
    [self.manager DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + xpos) andVertical:mm2inch(1 + 4 + 13 + 22 + 4 - ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@%@%@",expressInfo.fromProvince,expressInfo.fromCity,expressInfo.fromCounty] andShowStyle:true];
    [self.manager DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + xpos) andVertical:mm2inch(1 + 4 + 13 + 22 + 7 - ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize andText:[NSString stringWithFormat:@"%@",expressInfo.fromAddress] andShowStyle:true];
    
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 33 + 1 - ypos) andHeight:1 andWidth:1 andText:@"托"];
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 33 + 4 - ypos) andHeight:1 andWidth:1 andText:@"寄"];
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17+3+xpos) andVertical:mm2inch(1 + 4 + 13 + 33 + 7 - ypos) andHeight:1 andWidth:1 andText:@"物"];
    
    
    [self.manager DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + 14 + xpos) andVertical:mm2inch(1 + 4 + 13 + 33 + 0 - ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize - 1 andText:[NSString stringWithFormat:@"付款方式：%@",expressInfo.payMode] andShowStyle:true];
    [self.manager DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + 14 + xpos) andVertical:mm2inch(1 + 4 + 13 + 33 + 2.7 - ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize - 1 andText:[NSString stringWithFormat:@"月结账号：%@",expressInfo.monthCard] andShowStyle:true];
    [self.manager DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + 14 + xpos) andVertical:mm2inch(1 + 4 + 13 + 33 + 5.4 - ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize - 1 andText:[NSString stringWithFormat:@"第三方地区：%@",expressInfo.payAreaCode] andShowStyle:true];
    [self.manager DSZPLPrintTextLine:mm2inch(17 + 3 + 8 + 14 + xpos) andVertical:mm2inch(1 + 4 + 11 + 33 + 10 - ypos) andFontName:nil andBoldweight:_cgBoldweight andSize:fontSize - 1 andText:[NSString stringWithFormat:@"重量：          费用:     "] andShowStyle:true];
    
    
    
    //    mSmartPrint.PrintText(0, 30, mm2inch(17 + 53 + 3 + xpos), mm2inch(1 + 4 + 13 + 33 + 1 - ypos), 1, 1, "签名：");
    //    mSmartPrint.PrintText(0, 30, mm2inch(17 + 53 + 3 + 7 + xpos), mm2inch(1 + 4 + 11 + 33 + 8.5 + 1 - ypos), 1, 1, "__月__日");
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17 + 53 + 3 + xpos) andVertical:mm2inch(1 + 4 + 13 + 33 + 1 - ypos) andHeight:1 andWidth:1 andText:@"签名："];
    [self.manager PrintText:0 andDarkness:30 andHorizontal:mm2inch(17 + 53 + 3 + 7 + xpos) andVertical:mm2inch(1 + 4 + 11 + 33 + 8.5 + 1 - ypos) andHeight:1 andWidth:1 andText:@"__月__日"];
    
    [self.manager DSZPLSetCutter:1 andCutter:NO];
    BOOL isSuccess = [self.manager PrintText:3 andDarkness:30 andHorizontal:0 andVertical:0 andHeight:1 andWidth:1 andText:@""];
    [MBProgressHUDHelper hideAllHUD];
//    if (self.manager != nil) {
//        [self.manager DSCloseWifi];
//    }
    return isSuccess;
}
#pragma mark- end
- (void)openCustomService:(id)urlStr
{
    NSString *urlstrs = [NSString stringWithFormat:@"%@",urlStr];
    CustomerServiceVC *cut = [[CustomerServiceVC alloc]init];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:urlstrs forKey:@"kefuurl"];
    cut.url = [NSString stringWithFormat:@"%@",urlstrs];
    [self.navigationController pushViewController:cut animated:YES];
    
}
- (void)getIOSUserMain
{
    
    
    [self.jsContext[@"setIOSUserMain"] callWithArguments:@[JumpObject.userMain]];

}

- (void)updateDeviceInfo
{
 
    NSLog(@"%s",__func__);

    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];

    [self.jsContext[@"getImei"] callWithArguments:@[identifierForVendor]];

}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSString *urlString = [[request URL] absoluteString];

    if ([urlString hasPrefix:@"iosmainwin://"]) {
        if ([urlString isEqualToString:@"iosmainwin://show?iosmainwin"]) {
            [self showiOSToast];
        }
        
        return NO;
    }

    
    return YES;
}
- (void)showiOSToast
{

    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)openCamera:(id)isPhoto
{

    NSLog(@"%@",isPhoto);
    if ([isPhoto isEqualToString:@"1"]) {
        //只有拍照，不可以从相册获取
        if (isbool == NO) {
            
            isbool = YES;
            
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"打开照相机"  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self takePhoto];
            }]];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"取    消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                isbool = NO;
            }]];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                actionSheet.popoverPresentationController.sourceView = self.view;
                actionSheet.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height - 120, 1, 1);
                actionSheet.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }else{
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:actionSheet animated:YES completion:^{
                }];
            });
            
        }
    }else{
        if (isbool == NO) {
            
            isbool = YES;
            
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"打开照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self takePhoto];
            }]];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"打开相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self LocalPhoto];
            }]];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"取    消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                isbool = NO;
            }]];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                actionSheet.popoverPresentationController.sourceView = self.view;
                actionSheet.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height - 120, 1, 1);
                actionSheet.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }else{
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:actionSheet animated:YES completion:^{
                }];
            });
//            myActionSheet = [[UIActionSheet alloc]
//                             initWithTitle:nil
//                             delegate:self
//                             cancelButtonTitle:@"取消"
//                             destructiveButtonTitle:nil
//                             otherButtonTitles: @"打开照相机", @"从手机相册获取",nil];
//            myActionSheet.tag = 102;
//            [myActionSheet showInView:self.view];
            
        }
    }
    
    
  
}


- (void)getLoginUserData{
    
    
    [self.jsContext[@"setLoginUserData"]  callWithArguments:@[self.modeldictary]];

    
}
//setLoginUserData
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (actionSheet.tag == 101) {
//
//        switch (buttonIndex)
//        {
//            case 0:  //打开照相机拍照
//
//                [self takePhoto];
//
//                break;
//
//            default:
//                NSLog(@"取消");
//                isbool = NO;
//                break;
//
//
//        }
//    }else{
//        switch (buttonIndex)
//        {
//            case 0:  //打开照相机拍照
//
//                [self takePhoto];
//
//                break;
//
//            case 1:  //打开本地相册
//
//                [self LocalPhoto];
//
//                break;
//            default:
//                NSLog(@"取消");
//                isbool = NO;
//                break;
//
//
//        }
//    }
//
//}



- (void)takePhoto
{
    

    NSLog(@"%d",[NSThread isMainThread]);

//    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;

    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        if (pickerController) {
            [pickerController removeFromParentViewController];
            pickerController = nil;
        }
        pickerController = [[UIImagePickerController alloc] init];
        pickerController.delegate = self;
        //设置拍照后的图片可被编辑
        pickerController.allowsEditing = YES;
        pickerController.sourceType = sourceType;
        [self presentViewController:pickerController animated:YES completion:^{
            
            isbool = NO;

        }];
    }else
    {
        isbool = NO;
        
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

- (void)LocalPhoto
{
    if (pickerController) {
        [pickerController removeFromParentViewController];
        pickerController = nil;
    }
    pickerController = [[UIImagePickerController alloc] init];
    
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    //设置选择后的图片可被编辑
    pickerController.allowsEditing = YES;
    [self presentViewController:pickerController animated:YES completion:^{
        isbool = NO;
    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if ([type isEqualToString:@"public.image"])
    {

        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
//            UIImageWriteToSavedPhotosAlbum (image, nil, nil , nil);    //保存到library
        }
        //
        CGSize imagesize = image.size;
        CGFloat proportion = 1;
        if (imagesize.width <= 1280 && imagesize.height <= 1280) {
            //不做处理
        }else if (imagesize.width > 1280 && imagesize.height >  1280){
            //取最短边为1280，另一边等比缩放
            proportion = imagesize.width < imagesize.height?(1280/image.size.width):(1280/image.size.height);
        }else if (imagesize.width > 1280 || imagesize.height >  1280){
            //取最长边为1280，另一边等比缩放
            proportion = imagesize.width > imagesize.height?(1280/image.size.width):(1280/image.size.height);
        }
        imagesize.height = imagesize.height*proportion;
        imagesize.width = image.size.width*proportion;
        //对图片大小进行压缩--
        image = [self imageWithImage:image scaledToSize:imagesize];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        
        NSString *_encodedImageStr = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

        _encodedImageStr = [NSString  stringWithFormat:@"data:image/png;base64,%@",_encodedImageStr];
        
//    上传图片


        isbool = NO;
        
        [picker dismissViewControllerAnimated:YES completion:^{
            
            pickerController  = nil;
            
        }];
        
        [self.jsContext[@"getBase64ImgData"]  callWithArguments:@[_encodedImageStr]];

//        [self.jsContext[@"setDeviceData"]  callWithArguments:@[@"213"]];

    }
    
    
//
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
}


-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}




#pragma mark- ScanDelegate
- (void)backTheScanViewWith:(NSString *)stringValue
{
    
    NSLog(@"stringValuestringValue=%@",stringValue);

    
    
        if ([stringValue isEqualToString:@""] || stringValue == nil ||[stringValue isEqual:[NSNull null]]) {
            
            NSLog(@"为空");
        }else{
            
            
            

        }

}

#pragma mark-
#pragma mark 高德定位


- (void)configLocationManager
{
    self.locationAManager = [[AMapLocationManager alloc] init];
    
    [self.locationAManager setDelegate:self];
    
    [self.locationAManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    [self.locationAManager setLocationTimeout:6];
    
    [self.locationAManager setReGeocodeTimeout:3];
    [self.locationAManager startUpdatingLocation];
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
{
    NSLog(@"%@",location);
    
    [self searchReGeocodeWithCoordinate:location.coordinate];
}



- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location                    = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension            = YES;
    
    [self.search AMapReGoecodeSearch:regeo];
}


- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error=%@",error);
}
/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    NSLog(@"%@",response);
    if (response.regeocode != nil)
    {
        NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
        [forMatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *nowDate = [forMatter stringFromDate:[NSDate date]];
        
        NSLog(@"%@", response.regeocode.formattedAddress);
        
        [self.jsContext[@"setPositionData"] callWithArguments:@[@{@"nameValuePairs":@{@"lontitude":[NSString stringWithFormat:@"%.17g",request.location.longitude],@"latitude":[NSString stringWithFormat:@"%.17g",request.location.latitude],@"country":@"中国",@"city":response.regeocode.formattedAddress,@"district":@"",@"province":@"",@"time":nowDate,@"locationDesCribe":@"",@"street":@""}}]];
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _locService.delegate = nil;
    
    _searcher.delegate = nil;
    
    _locService = nil;
    
    _searcher = nil;
    
}

@end
