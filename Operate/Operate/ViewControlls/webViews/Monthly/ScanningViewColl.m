//
//  ScanningViewColl.m
//  Operate
//
//  Created by user on 16/4/20.
//  Copyright © 2016年 hanyc. All rights reserved.
//

#import "ScanningViewColl.h"
#import <AVFoundation/AVFoundation.h>
#import "Util.h"
#import "Macro.h"
#import "BezierView.h"
#define  FoundationColor   RGBA(60, 64, 65, 0.4)

@interface ScanningViewColl ()<AVCaptureMetadataOutputObjectsDelegate>
{
    UIView *scanningView;
    NSString *strValue;

}
@property (nonatomic, strong) BezierView   *bezierView;
@property ( strong , nonatomic ) AVCaptureDevice * device;
@property ( strong , nonatomic ) AVCaptureDeviceInput * input;
@property ( strong , nonatomic ) AVCaptureMetadataOutput * output;
@property ( strong , nonatomic ) AVCaptureSession * session;
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * preview;

@end

@implementation ScanningViewColl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    NSString *mediaType = AVMediaTypeVideo;// Or AVMediaTypeAudio
    if (authStatus ==  AVAuthorizationStatusAuthorized) {
        [self configview];
        
    }else if (authStatus ==AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@""message:@"营运宝并未取得相机权限请前往设置中开启" delegate:self cancelButtonTitle:NSLocalizedString(@"确定",@"OK")otherButtonTitles:nil,nil];
        
        alertView.tag = 1652;
        [alertView show];
    }
    else if (authStatus ==AVAuthorizationStatusNotDetermined) //第一次使用，则会弹出是否打开权限
        
    {
        [self configview];
        
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            
            if (granted)
                
            {
                
                _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
                
            }
            
        }];
    }

    // Do any additional setup after loading the view.
}

- (void)configview
{
    UIView *titleBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,CGRectGetWidth(self.view.frame) , 64)];
    
    
    titleBarView.backgroundColor = [UIColor colorWithRed:45/255.f green:190/255.f blue:130/255.f alpha:1];
    
    [self.view addSubview:titleBarView];
    
    
    UIButton *backbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    backbutton.frame = CGRectMake(10, 22, 33, 40);
    backbutton.clipsToBounds = YES;
    backbutton.layer.cornerRadius = 3;
    [backbutton setImage:[UIImage imageNamed:@"app-top-back.png"] forState:UIControlStateNormal];
    [backbutton addTarget:self action:@selector(closemetadata) forControlEvents:UIControlEventTouchUpInside];
    [titleBarView addSubview:backbutton];
    
    if (self.cordType == 1) {
        UIView *upBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), (CGRectGetHeight(self.view.bounds)- 64 - CGRectGetWidth(self.view.frame)*3/4)/2)];
        upBgView.backgroundColor = [UIColor blackColor];
        upBgView.alpha = 0.65;
        
        UIView *leftBgView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(upBgView.frame), (CGRectGetWidth(self.view.frame) - CGRectGetWidth(self.view.frame)*3/4)/2, CGRectGetWidth(self.view.frame)*3/4)];
        leftBgView.backgroundColor = [UIColor blackColor];
        leftBgView.alpha = 0.65;
        
        if (_bezierView) {
            [_bezierView removeFromSuperview];
            _bezierView = nil;
        }
        _bezierView = [[BezierView alloc] initWithFrame:CGRectMake(0.0f, 0, CGRectGetWidth(self.view.frame)*3/4, CGRectGetWidth(self.view.frame)*3/4)];
        _bezierView.center = CGPointMake(self.view.center.x, self.view.center.y+64/2);
        
        [_bezierView stop];
        
        UIView *rightBgView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_bezierView.frame), leftBgView.frame.origin.y, leftBgView.frame.size.width, CGRectGetWidth(self.view.frame)*3/4)];
        rightBgView.backgroundColor = [UIColor blackColor];
        rightBgView.alpha = 0.65;
        
        UIView *downBgView = [[UIView alloc]initWithFrame:CGRectMake(0, _bezierView.frame.origin.y + _bezierView.frame.size.height, CGRectGetWidth(self.view.frame), (CGRectGetHeight(self.view.bounds)- 64 - CGRectGetWidth(self.view.frame)*3/4)/2)];
        downBgView.backgroundColor = [UIColor blackColor];
        downBgView.alpha = 0.65;
        
        UILabel *alertTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.view.frame), 40)];
        alertTextLabel.textColor = [UIColor whiteColor];
        alertTextLabel.backgroundColor = [UIColor clearColor];
        alertTextLabel.text = [NSString stringWithFormat:@"请将条形码放置于扫描框内的中间，蓝色线条处"];
        alertTextLabel.textAlignment = NSTextAlignmentCenter;
        [downBgView addSubview:alertTextLabel];
        
        
        [self test];
        [self.view addSubview:upBgView];
        [self.view addSubview:leftBgView];
        [self.view addSubview:_bezierView];
        [self.view addSubview:rightBgView];
        [self.view addSubview:downBgView];
        
    }else{
        if (_bezierView) {
            [_bezierView removeFromSuperview];
            _bezierView = nil;
        }
        
        _bezierView = [[BezierView alloc] initWithFrame:CGRectMake(40.0f, 130.0f, CGRectGetWidth(self.view.frame)-80.0f, (CGRectGetWidth(self.view.frame)-80.0f)*7.0f/6.0f)];
        [_bezierView start];
        
        [self test];
        [self.view addSubview:_bezierView];
    }
    

}
-(void)backs
{
    [_session stopRunning];
    _input = nil;
    _output = nil;
    [_preview removeFromSuperlayer];
    _preview = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- ( void )captureOutput:( AVCaptureOutput *)captureOutput didOutputMetadataObjects:( NSArray *)metadataObjects fromConnection:( AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    
    if ([metadataObjects count ] > 0 )
    {
        // 停止扫描
        
        [ _session stopRunning ];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex :0];
        stringValue = metadataObject.stringValue ;
        
        NSLog(@"stringvalue=%@",stringValue);
//        [JumpObject saveScanStringData:stringValue];
        
        strValue = stringValue;
        
//        dispatch_async(dispatch_get_main_queue(),^ {
        
            dispatch_async(dispatch_get_main_queue(),^ {
                JSValue * value = self.jscontext[@"getScan2Date"];
                [self.jscontext[@"setTimeout"] callWithArguments:@[value,@0,stringValue]];
                
            });
//            [_jscontext[@"getScan2Date"]  callWithArguments:@[stringValue]];
//        });

        [self performSelector:@selector(backs) withObject:nil afterDelay:0.2];

        
        if ([_delegate respondsToSelector:@selector(backTheScanViewWith:)]) {
            
            [_delegate  backTheScanViewWith:stringValue];
        }


        
    }
}


- (void)closemetadata{
    
    
//    [self dismissViewControllerAnimated:YES completion:nil];

        [self.navigationController popViewControllerAnimated:YES];
    
    
}


- (void)dealloc
{
    
    

}
- (void)viewWillDisappear:(BOOL)animated
{
    [_session stopRunning];
    _input = nil;
        [_bezierView stop];
    _output = nil;
                    [_preview removeFromSuperlayer];
    _preview = nil;
}
- (void)test
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        _device = [ AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo ];
        _input = [ AVCaptureDeviceInput deviceInputWithDevice : self.device error : nil ];
        _output = [[ AVCaptureMetadataOutput alloc ] init ];
        [ _output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue ()];
        _session = [[ AVCaptureSession alloc ] init ];
        [ _session setSessionPreset : AVCaptureSessionPresetHigh ];
        if ([ _session canAddInput : self.input ])
        {
            [ _session addInput : self.input ];
        }
        if ([ _session canAddOutput :self.output ])
        {
            [ _session addOutput : self.output ];
        }
        // 条码类型 AVMetadataObjectTypeQRCode
        if (self.cordType == 2) {
            _output . metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                              AVMetadataObjectTypeEAN13Code,
                                              AVMetadataObjectTypeEAN8Code,
                                              AVMetadataObjectTypeUPCECode,
                                              AVMetadataObjectTypeCode39Code,
                                              AVMetadataObjectTypeCode39Mod43Code,
                                              AVMetadataObjectTypeCode93Code,
                                              AVMetadataObjectTypeCode128Code,
                                              AVMetadataObjectTypePDF417Code
                                              ];
        }else{
            _output . metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                              AVMetadataObjectTypeEAN13Code,
                                              AVMetadataObjectTypeEAN8Code,
                                              AVMetadataObjectTypeUPCECode,
                                              AVMetadataObjectTypeCode39Code,
                                              AVMetadataObjectTypeCode39Mod43Code,
                                              AVMetadataObjectTypeCode93Code,
                                              AVMetadataObjectTypeCode128Code,
                                              AVMetadataObjectTypePDF417Code
                                              ];
        }
    
        // Preview
        _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session ];
        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill ;
        _preview.frame = self.view.layer.bounds;
        [self.view.layer insertSublayer:_preview atIndex: 0];
        // Start
        [ _session startRunning];
        if (self.cordType == 2) {
            CGRect rect = self.view.layer.bounds;
            CGRect intertRect = [_preview metadataOutputRectOfInterestForRect:rect];
            CGRect layerRect = [_preview rectForMetadataOutputRectOfInterest:intertRect];
            NSLog(@"扫描区域：%@,  %@",NSStringFromCGRect(intertRect),NSStringFromCGRect(layerRect));
            _output.rectOfInterest = intertRect;
        }else{
            CGRect rect = CGRectMake(0, _bezierView.frame.origin.y - 20, CGRectGetWidth(self.view.frame), _bezierView.frame.size.height+40);
            CGRect intertRect = [_preview metadataOutputRectOfInterestForRect:rect];
            CGRect layerRect = [_preview rectForMetadataOutputRectOfInterest:intertRect];
            NSLog(@"扫描区域：%@,  %@",NSStringFromCGRect(intertRect),NSStringFromCGRect(layerRect));
            _output.rectOfInterest = intertRect;
        }
        
    }else{
        [Util showAlertWithTitle:@"温馨提示" msg:@"当前设备不支持拍照"];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
