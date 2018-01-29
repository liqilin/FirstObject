//
//  DSHeader.h
//  
//
//  Created by dascomzz on 16/1/22.
//  Copyright © 2016年 DS. All rights reserved.
//

#ifndef DSHeader_h
#define DSHeader_h

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class DSBluetoothPrinter;
#endif  /*__OBJC__*/



//打印机型号
typedef NS_ENUM(NSInteger, DSPrinterModel) {
    DSPrinterModel1140,
    DSPrinterModel5130,
    DSPrinterModel1125Plus,
    
    DSPrinterModelAGP1000,
    DSPrinterModel2600II,
    DSPrinterModelAPE6020F,
    DSPrinterModelAR3000,
    DSPrinterModelAR3000H,
    DSPrinterModelAR300K,
    DSPrinterModelAR300KPlus,
    DSPrinterModelAR400,
    DSPrinterModelAR400Plus,
    DSPrinterModelAR400IIPlus,
    DSPrinterModelAR410,
    DSPrinterModelAR410II,
    DSPrinterModelAR500,
    DSPrinterModelAR500II,
    DSPrinterModelAR500IIZK,
    DSPrinterModelAR500ZK,
    DSPrinterModelAR510,
    DSPrinterModelAR510ZK,
    DSPrinterModelAR520,
    DSPrinterModelAR520Pro,
    DSPrinterModelAR540,
    DSPrinterModelAR550,
    DSPrinterModelAR550II,
    DSPrinterModelAR570,
    DSPrinterModelAR580,
    DSPrinterModelAR580p,
    DSPrinterModelAR580II,
    DSPrinterModelAR580Pro,
    DSPrinterModelAR600,
    DSPrinterModelAR600H,
    DSPrinterModelAR600HZK,
    DSPrinterModelAR600II,
    DSPrinterModelAR600ZK,
    DSPrinterModelAR610,
    DSPrinterModelAR700,
    DSPrinterModelAR700ZK,
    DSPrinterModelAX320,
    DSPrinterModelAX370,
    
    DSPrinterModelBL101,
    
    DSPrinterModelC800,
    DSPrinterModelC805,
    DSPrinterModelCRP130,
    DSPrinterModelCTP110,
    DSPrinterModelCTP80,
    DSPrinterModelCZ900,
    
    DSPrinterModelDL200,
    DSPrinterModelDL210,
    DSPrinterModelDL218,
    DSPrinterModelDM210,
    DSPrinterModelDM210P36,
    DSPrinterModelDM212,
    DSPrinterModelDM212PUB,
    DSPrinterModelDM220,
    DSPrinterModelDM220P36,
    DSPrinterModelDM310,
    DSPrinterModelDM330,
    DSPrinterModelDP330,
    DSPrinterModelDP330L,
    DSPrinterModelDP530,
    DSPrinterModelDS1000,
    DSPrinterModelDS1000CP1,
    DSPrinterModelDS1000CP2,
    DSPrinterModelDS1100,
    DSPrinterModelDS1100GD,
    DSPrinterModelDS1100II,
    DSPrinterModelDS1100IIPlus,
    DSPrinterModelDS1100ZK,
    DSPrinterModelDS1120,
    DSPrinterModelDS1700,
    DSPrinterModelDS1700GD,
    DSPrinterModelDS1700H,
    DSPrinterModelDS1700II,
    DSPrinterModelDS1700IIPlus,
    DSPrinterModelDS1700TX,
    DSPrinterModelDS1700TXZK,
    DSPrinterModelDS1700ZK,
    DSPrinterModelDS1830,
    DSPrinterModelDS1860,
    DSPrinterModelDS1860CP1,
    DSPrinterModelDS1860CP2,
    DSPrinterModelDS1860Pro,
    DSPrinterModelDS1870,
    DSPrinterModelDS1920,
    DSPrinterModelDS1920_1,
    DSPrinterModelDS1930,
    DSPrinterModelDS1930Pro,
    DSPrinterModelDS200,
    DSPrinterModelDS2000,
    DSPrinterModelDS2100,
    DSPrinterModelDS2100GD,
    DSPrinterModelDS2100H,
    DSPrinterModelDS2100II,
    DSPrinterModelDS2100ZK,
    DSPrinterModelDS2130,
    DSPrinterModelDS2230,
    DSPrinterModelDS2600H,
    DSPrinterModelDS300,
    DSPrinterModelDS3100,
    DSPrinterModelDS3100ZK,
    DSPrinterModelDS320Plus,
    DSPrinterModelDS3200Ⅳ,
    DSPrinterModelDS3200H,
    DSPrinterModelDS3200IIPlus,
    DSPrinterModelDS3200IIIPlus,
    DSPrinterModelDS400,
    DSPrinterModelDS500,
    DSPrinterModelDS5400Ⅳ,
    DSPrinterModelDS5400H,
    DSPrinterModelDS5400HPro,
    DSPrinterModelDS5400III,
    DSPrinterModelDS5400IIIGD,
    DSPrinterModelDS5400IIIZK,
    DSPrinterModelDS600,
    DSPrinterModelDS600Pro,
    DSPrinterModelDS600ZK,
    DSPrinterModelDS610,
    DSPrinterModelDS610II,
    DSPrinterModelDS615,
    DSPrinterModelDS620,
    DSPrinterModelDS620II,
    DSPrinterModelDS640,
    DSPrinterModelDS6400III,
    DSPrinterModelDS6400IIIZK,
    DSPrinterModelDS6400TX,
    DSPrinterModelDS650,
    DSPrinterModelDS650II,
    DSPrinterModelDS650Pro,
    DSPrinterModelDS660,
    DSPrinterModelDS660C,
    DSPrinterModelDS660P,
    DSPrinterModelDS660Pro,
    DSPrinterModelDS670,
    DSPrinterModelDS700,
    DSPrinterModelDS700II,
    DSPrinterModelDS700ZK,
    DSPrinterModelDS710,
    DSPrinterModelDS710ZK,
    DSPrinterModelDS7110,
    DSPrinterModelDS7120,
    DSPrinterModelDS7120Pro,
    DSPrinterModelDS7210,
    DSPrinterModelDS1989,
    DSPrinterModelDS7220,
    DSPrinterModelDS7310,
    DSPrinterModelDS7830,
    DSPrinterModelDS7860,
    DSPrinterModelDS800,
    DSPrinterModelDS800ZK,
    DSPrinterModelDS900,
    DSPrinterModelDS900II,
    DSPrinterModelDS910,
    DSPrinterModelDS910II,
    DSPrinterModelDS940,
    DSPrinterModelDS970,
    DSPrinterModelDS980,
    DSPrinterModelDT210,
    DSPrinterModelDT230,
    DSPrinterModelDT230F,
    DSPrinterModelDT230US,
    
    DSPrinterModelGI300K,
    DSPrinterModelGI400K,
    DSPrinterModelGI630K,
    
    DSPrinterModelHX300,
    DSPrinterModelHX400,
    
    DSPrinterModelKFD1100,
    DSPrinterModelKPJ1000,
    
    DSPrinterModelPY6820B,
    
    DSPrinterModelRICHC800,
    DSPrinterModelRICHPR3Plus,
    
    DSPrinterModelSK300,
    DSPrinterModelSK600,
    DSPrinterModelSK600Plus,
    DSPrinterModelSK600II,
    DSPrinterModelSK650,
    DSPrinterModelSK800,
    DSPrinterModelSK800II,
    DSPrinterModelSK810,
    DSPrinterModelSK820,
    DSPrinterModelSK820KW,
    DSPrinterModelSK820II,
    DSPrinterModelSK830,
    DSPrinterModelSK860,
    
    DSPrinterModelTD1125,
    DSPrinterModelTD1225,
    DSPrinterModelTD1318,
    DSPrinterModelTD1318Plus,
    DSPrinterModelTD1325,
    DSPrinterModelTD1430,
    DSPrinterModelTD2600,
    DSPrinterModelTD2610,
    DSPrinterModelTX182,
    DSPrinterModelTX186,
    DSPrinterModelTY1300,
    DSPrinterModelTY1800,
    DSPrinterModelTY1800II,
    DSPrinterModelTY20E,
    DSPrinterModelTY2300,
    DSPrinterModelTY300,
    DSPrinterModelTY300ZK,
    DSPrinterModelTY500,
    
    DSPrinterModelTY600,
    DSPrinterModelTY600Plus,
    DSPrinterModelTY600K,
    DSPrinterModelTY600KZK,
    DSPrinterModelTY6150,
    DSPrinterModelTY6150KW,
    DSPrinterModelTY6200,
    DSPrinterModelTY800,
    DSPrinterModelTY800Plus,
    DSPrinterModelTY800ZK,
    DSPrinterModelTY805,
    DSPrinterModelTY810,
    DSPrinterModelTY820,
    DSPrinterModelTY820Plus,
    DSPrinterModelTY820II,
    DSPrinterModelTY820K,
    DSPrinterModelTY900Pro,
    
    DSPrinterModelWD710,
    DSPrinterModelWD710PU,
    DSPrinterModelWD720,
    DSPrinterModelWD720PU,
    DSPrinterModelXY600,
    DSPrinterModelXY800,
};

//打印机连接类型
typedef NS_ENUM(NSInteger, DSPrinterConnectType) {
    PrinterWifiConnect,//WiFi连接
    PrinterBluetoothConnect,//蓝牙连接
    PrinterConnectNull,//无连接
};

//蓝牙设备状态
typedef NS_ENUM(NSInteger, DSBluetoothState) {
    DSBluetoothStateUnknown = 0,
    DSBluetoothStateResetting,
    DSBluetoothStateUnsupported,
    DSBluetoothStateUnauthorized,
    DSBluetoothStatePoweredOff,
    DSBluetoothStatePoweredOn,
    DSBluetoothStateCanPrint,//可以开始打印
    DSBluetoothStateCannotPrint,//还不能开始打印
};

typedef NS_ENUM(NSInteger, DSPrinterDPI) {
    DSPrinterDPI180x180,//180x180

};

typedef NS_ENUM(NSInteger, DSDBarCodeType) {
    DSDBarCodeTypeCode128,//
    DSDBarCodeTypeQRCode,//
};

typedef NS_ENUM(NSInteger, DSDBarCodePosition) {
    DSDBarCodePositionNone,//
    DSDBarCodePositionTop,//
    DSDBarCodePositionButton,//
};

/**
 *  打印机连接成功 回调Block
 */
typedef void(^printerConnectSuccess)();

/**
 *  打印机连接失败 回调Block
 *
 */
typedef void(^printerConnectFail)();

/**
 *  打印数据写入到打印机完成 回调Block
 */
typedef void(^dataSentSuccess)();

/**
 *  打印数据写入到打印机失败 回调Block
 *
 */
typedef void(^dataSentFail)();

//方法调用错误原因
typedef NS_ENUM(NSInteger, DSError) {
    DSErrorNone,//没有错误
    DSErrorWithParameters,//输入参数错误
    DSErrorWithConnect,//连接错误
    DSErrorWithNoneData,//所要发送的打印数据为空
    DSErrorSetError
};

//连接错误原因
typedef NS_ENUM(NSInteger, DSWifiConnectError) {
    DSWifiConnectErrorWithOccupy,//连接被占用
    DSWifiConnectErrorWithOther,//其他错误,如连接非得实打印机
    DSWifiConnectErrorWithTimeout,//连接超时
    DSWifiConnectErrorNoSupportModel,//打印机型号不支持
};

//打印旋转方向
typedef NS_ENUM(NSInteger, DSOrientation) {
    DSOrientationUp,            // 默认方向 不旋转
    DSOrientationRight, 
    DSOrientationDown,          // 图片顺时针旋转180度
    DSOrientationLeft,          // 图片向左旋转 逆时针90度
            // 图片向右旋转 顺时针90度
};

//POS 对齐方式
typedef NS_ENUM(NSInteger, DSJustification) {
    DSJustificationLeft,          // 左对齐
    DSJustificationCenter,        // 居中
    DSJustificationRight,         // 右对齐
};

//ZPL 对齐方式
typedef NS_ENUM(NSInteger, DSZPLJustification) {
    DSZPLJustificationLeft,         // 左对齐
    DSZPLJustificationRight,        // 居中
    DSZPLJustificationAuto,         // 自动对齐
};

//ESC打印机速度模式
typedef NS_ENUM(NSInteger, DSESCPrintSpeed) {
    DSESCPrintSpeed0,          // 超高速模式
    DSESCPrintSpeed1,          // 高密模式
    DSESCPrintSpeed2,          // 高速模式
};

#pragma mark- ZPLQRCode 参数定义

//QRCodereliabilitylevel H Q M L
typedef NS_ENUM(NSInteger, DSQRCodereliabilitylevel) {
    DSQRCodeReliabilityLevelH,//ultra-high reliability level
    DSQRCodeReliabilityLevelQ,//high reliability level
    DSQRCodeReliabilityLevelM,//standard level
    DSQRCodeReliabilityLevelL,//high density level
};

//QRCodeCharacterMode <N, A, B, K>
typedef NS_ENUM(NSInteger, DSQRCodeCharacterMode) {
    DSQRCodeCharacterModeN,//numeric
    DSQRCodeCharacterModeA,//alphanumeric
    DSQRCodeCharacterModeB,//Bxxxx = 8-bit byte mode. This handles the 8-bit Latin/Kana character set in accordance with JIS X 0201 (character values 0x00 to 0xFF).
    DSQRCodeCharacterModeK,//Kanji — handles only Kanji characters in accordance with the Shift JIS system based on JIS X 0208. This means that all parameters after the character mode K should be 16-bit characters. If there are any 8-bit characters (such as ASCII code), an error occurs.
};

#pragma mark- code128 参数定义
//code128 边框颜色 黑色 白色
typedef NS_ENUM(NSInteger, DSLineColor) {
    DSLineColorBlack,//黑色边线
    DSLineColorWhite,//白色边线 即透明
};

#pragma mark- DataMatrixBarCode 参数定义
//数据矩阵 质量等级
typedef NS_ENUM(NSInteger, DSDataMatrixBarCodeQualityLevel) {
    DSDataMatrixBarCodeQualityLevel0,//
    DSDataMatrixBarCodeQualityLevel50,//
    DSDataMatrixBarCodeQualityLevel80,//
    DSDataMatrixBarCodeQualityLevel100,//
    DSDataMatrixBarCodeQualityLevel140,//
    DSDataMatrixBarCodeQualityLevel200,//
};

#pragma mark- logLevel
typedef NS_OPTIONS(NSInteger,DSLogLevel) {
    DSLogNone   = 0,      //不打印LOG
    DSLogInfo   = 1 << 1, //打印普通消息
    DSLogError  = 1 << 2, //打印错误
};

#pragma mark- POS 参数定义
//POS 字母模式选项
typedef NS_OPTIONS(NSInteger,DSPOSPrintCharacterModes) {
    DSPOSPrintCharacterModeFont1 = 0,//选择字体1
    DSPOSPrintCharacterModeFont2 = 1 ,//选择字体2
    DSPOSPrintCharacterModeEmphasizedTurnOff = 0 << 3,//取消强调效果
    DSPOSPrintCharacterModeEmphasizedTurnOn = 1 << 3,//选择强调效果
    DSPOSPrintCharacterModeDoubleHeightCanceled = 0 << 4,//取消两倍高度
    DSPOSPrintCharacterModeDoubleHeightSelected = 1 << 4,//选择两倍高度
    DSPOSPrintCharacterModeDoublewidthCanceled = 0 << 5,//取消两倍宽度
    DSPOSPrintCharacterModeDoublewidthSelected = 1 << 5,//选择两倍宽度
    DSPOSPrintCharacterModeUnderlineTurnOff = 0 << 7,//取消下划线效果
    DSPOSPrintCharacterModeUnderlineTurnOn = 1 << 7,//选择下划线效果
};


//POS 汉字模式选项
typedef NS_OPTIONS(NSInteger,DSPOSPrintChineseModes) {
    DSPOSPrintChineseModeDoublewidthCanceled = 0 << 2,//取消两倍宽度
    DSPOSPrintChineseModeDoublewidthSelected = 1 << 2,//选择两倍宽度
    DSPOSPrintChineseModeDoubleHeightCanceled = 0 << 3,//取消两倍高度
    DSPOSPrintChineseModeDoubleHeightSelected = 1 << 3,//选择两倍高度
    DSPOSPrintChineseModeUnderlineTurnOff = 0 << 7,//取消下划线效果
    DSPOSPrintChineseModeUnderlineTurnOn = 1 << 7,//选择下划线效果
};

//POS 文字选择方向
typedef NS_ENUM(NSInteger, DSPOSRotation) {
    DSPOSRotation0 = 0,//不旋转
    DSPOSRotation90,//向右旋转(顺时针90°)1-dot character spacing
    DSPOSRotation180,//向右旋转(顺时针180°)1.5-dot character spacing
};

//POS POS 字母高度
typedef NS_ENUM(NSInteger, DSPOSFontHeight) {
    DSPOSFontHeight1 = 0,//正常大小
    DSPOSFontHeight2 = 1 ,//2倍大小 往下递增
    DSPOSFontHeight3 = 2 ,//
    DSPOSFontHeight4 = 3 ,//
    DSPOSFontHeight5 = 4 ,//
    DSPOSFontHeight6 = 5 ,//
    DSPOSFontHeight7 = 6 ,//
    DSPOSFontHeight8 = 7 ,//
};

//POS POS 字母宽度
typedef NS_ENUM(NSInteger, DSPOSFontWidth) {
    DSPOSFontWidth1 = 0,//正常大小
    DSPOSFontWidth2 = 16 ,//2倍大小 往下递增
    DSPOSFontWidth3 = 32 ,//
    DSPOSFontWidth4 = 48 ,//
    DSPOSFontWidth5 = 64 ,//
    DSPOSFontWidth6 = 80 ,//
    DSPOSFontWidth7 = 96 ,//
    DSPOSFontWidth8 = 112 ,//
};

//POS POS 字母高度
typedef NS_ENUM(NSInteger, DSPOSBarCode) {
    DSPOSBarCode39  = 4,//code39
    DSPOSBarCodeITF = 5,//codeITF
    DSPOSBarCode128 = 73,//code128
    
};

//POS POS 字母高度
typedef NS_ENUM(NSInteger, DSPOSPrintMode) {
    DSPOSPageMode  = 0,//页模式
    DSPOSstandardMode = 1,//标准模式
};

//POS POS 页模式打印位置
typedef NS_ENUM(NSInteger, DSPOSPrintPageModeDirection) {
    DSPOSPrintPageModeDirectionUpperLeft = 0,//左上角
    DSPOSPrintPageModeDirectionLowerLeft = 1,//左下角
    DSPOSPrintPageModeDirectionLowerRight = 2,//左下角
    DSPOSPrintPageModeDirectionUpperRight = 3,//左上角
    
};

//POS POS 国际字符集
typedef NS_ENUM(NSInteger, DSPOSInternationalCharacterSet) {
    DSPOSInternationalCharacterSetUSA = 0,//
    DSPOSInternationalCharacterSetFrance = 1,//
    DSPOSInternationalCharacterSetGermany = 2,//
    DSPOSInternationalCharacterSetUK = 3,//
    DSPOSInternationalCharacterSetDenmarkI = 4,//
    DSPOSInternationalCharacterSetSweden = 5,//
    DSPOSInternationalCharacterSetItaly = 6,//
    DSPOSInternationalCharacterSetSpain = 7,//
    DSPOSInternationalCharacterSetJapan = 8,//
    DSPOSInternationalCharacterSetNorway = 9,//
    DSPOSInternationalCharacterSetDenmarkII = 10,//
    DSPOSInternationalCharacterSetSpainII = 11,//
    DSPOSInternationalCharacterSetLatinAmerica = 12,//
    DSPOSInternationalCharacterSetKorean = 13,//
    DSPOSInternationalCharacterSetSloveniaCroatia = 14,//
    DSPOSInternationalCharacterSetChinese = 15,//
};

//POS POS 一维码人工标识位置
typedef NS_ENUM(NSInteger, DSPOSHRI_CharactersPosition) {
    DSPOSHRI_CharactersPositionNotPrint = 0,//
    DSPOSHRI_CharactersPositionAboveTheBarCode = 1,//
    DSPOSHRI_CharactersPositionBelowTheBarCode = 2,//
    DSPOSHRI_CharactersPositionBothAboveAndBelowTheBarCode = 3,//
};

//POS POS 一维码人工标识字体
typedef NS_ENUM(NSInteger, DSPOSHRI_CharactersFont) {
    DSPOSHRI_CharactersFontA = 0,//
    DSPOSHRI_CharactersFontB = 1,//
    DSPOSHRI_CharactersFontC = 2,//
};

//POS QRCodereliabilitylevel H Q M L
typedef NS_ENUM(NSInteger, DSPOSQRCodeErrorCorrectionLevel) {
    DSPOSQRCodeErrorCorrectionLevelL = 48,//7%
    DSPOSQRCodeErrorCorrectionLevelM = 49,//15%
    DSPOSQRCodeErrorCorrectionLevelQ = 50,//25%
    DSPOSQRCodeErrorCorrectionLevelH = 51,//30%
};

//POS QRCodereliabilitylevel H Q M L
typedef NS_ENUM(NSInteger, DSPOSPDF417ErrorCorrectionLevel) {
    DSPOSPDF417ErrorCorrectionLevel0 = 48,
    DSPOSPDF417ErrorCorrectionLevel1 ,
    DSPOSPDF417ErrorCorrectionLevel2 ,
    DSPOSPDF417ErrorCorrectionLevel3 ,
    DSPOSPDF417ErrorCorrectionLevel4 ,
    DSPOSPDF417ErrorCorrectionLevel5 ,
    DSPOSPDF417ErrorCorrectionLevel6 ,
    DSPOSPDF417ErrorCorrectionLevel7 ,
    DSPOSPDF417ErrorCorrectionLevel8 ,
};


#pragma mark- DM 字体对齐方式
typedef NS_ENUM(NSInteger, DMAlignment) {
    DMAlignmentLeft,//左
    DMAlignmentCenter,//中
    DMAlignmentRight,//右
};

#endif /* DSHeader_h */
