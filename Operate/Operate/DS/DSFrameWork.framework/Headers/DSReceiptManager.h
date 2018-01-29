//
//  DSReceiptManager.h
//
//
//  Copyright © 2016年 Dascom . All rights reserved.
//

#define kADKVersion @"baili_1.1"


#import <Foundation/Foundation.h>
#import "DSHeader.h"


@interface DSReceiptManager : NSObject

+ (DSReceiptManager *)shareReceiptManager;


/**
 连接打印机

 @param ipString IP
 @param port 端口
 @return 成功 YES 失败 NO
 */
-(BOOL)connectWifi:(NSString*)ipString andPort:(int)port;

-(void)DSLinkWifi:(NSString*)ipString andPort:(int)port;


/**
 关闭连接
 */
-(void)DSCloseWifi;


/**
 WIFI 连接状态

 @return yes 已连接 no 连接断开
 */
-(BOOL)DSWifiState;

/**
 打印机复位

 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSReset;


/**
 设置页长(写入 flash)

 @param inch 页长，单位:英寸
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)setPageLength:(double)inch;


/**
 设置页长(当次开机有效)

 @param inch 页长，单位:英寸
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSSetPageLenOnce:(double)inch;


/**
 设置页长命令的有效性

 @param enable true 表示页长命令有效 false 表示页长命令无效
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSSetPageLenCmd:(BOOL)enable;


/**
 设置换页切纸命令的有效性

 @param enable true 表示页长命令有效 false 表示页长命令无效
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSSetPaperCutCmd:(BOOL)enable;


/**
 正向走纸(向前推纸)

 @param inch 走纸长度， 单位: 英寸
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSPaperForward:(double)inch;


/**
 DSPaperBackward

 @param inch 走纸长度， 单位: 英寸
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSPaperBackward:(double)inch;


/**
 回退之前已设置(通过   设置) 的走纸距离

 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSPaperBacklast;


/**
 DSSetLineSpace

 @param inch 行距，单位:英寸
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSSetLineSpace:(double)inch;


/**
 设置左边界

 @param columns 字符列数 0≤columns≤50
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSSetLeftMargin:(int)columns;


/**
 设置绝对横向位置

 @param inch 为以当前左边限为基准，右移打印头的距离 0≤inch≤5, 单位:英寸
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSSetHPosition:(double)inch;


/**
 设置粗体

 @param enable true 表示设置粗体 false 表示取消粗体
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSSetFontBold:(BOOL)enable;


/**
 设置斜体

 @param enable true 表示设置斜体 false 表示取消斜体
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSSetFontItalic:(BOOL)enable;


/**
 设置汉字无级变倍

 @param xScale 为横向倍数，1/3≤xScale≤4
 @param yScale 为纵向倍数，1/3≤yScale≤4  当xScale=yScale=0时，退出无级变倍方式
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSScaleCharactersX:(double)xScale andY:(double)yScale;


/**
 设置打印位置

 @param xInch 横向位置，单位:英寸
 @param yInch 纵向位置，单位:英寸
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSSetLocationX:(double)xInch andY:(double)yInch;


/**
 顺向走纸

 @param inch 走纸距离，单位:英寸 0≤inch≤255/180
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSAdvancePosition:(double)inch;


/**
 逆向走纸

 @param inch 走纸距离，单位:英寸 0≤inch≤255/180
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSReversePosition:(double)inch;


/**
 换页

 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSFormFeed;


/**
 回车

 @return
 */
- (BOOL)DSCarriageReturn;


/**
 换行

 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSLineFeed;


- (BOOL)setCutter:(BOOL)enable;

/**
 * 设置是否自动切纸、设置打印标签数 如果不调用该接口，批量打印完才切纸。调用该接口后，遇到调用该接口的地方就切纸。
 *
 * @param iQty 打印相同副本的标签数量，一般取值为 1.
 * @param bEnableCutter  是否切纸。true: 切纸，false: 不切
 * @return 如果成功，返回值是true； 如果失败，返回值是false
 */
-(BOOL)DSZPLSetCutter:(int)iQty andCutter:(BOOL)bEnableCutter;

/**
 设置打印速度

 @param arg 速度 0:超高速 1:高密 2:高速
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSSetSpeedMode:(int)arg;

/**
 打印文本

 @param str 文本
 @param hex 文本是否为16进制
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSPrintData:(NSString *)str hex:(BOOL)hex;


/**
 设置页长

 @param len 页长
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)SetPageLength:(double)len;

/**
 打印表格横线

 @param command 
     0: 设置用户打印的内容。设置为该值时，本函数不能单独调用，必须配合参数为 2、3 一起使用。
     1: 在用户指定的某个坐标打印。设置为该值时，可以单独调用本函 数。
     2: 一页标签打印开始。 设置为该值时，后续所有参数都被忽略。 本函数不能单独调用，必须配合参数 0、3 一起使用。
     3: 一页标签打印结束。 设置为该值时，后续所有参数都被忽略。 本函数不能单独调用，必须配合参数 0、2 一起使用。
 @param horizontal 线段起点的横坐标。单位:英寸
 @param vertical 线段起点的纵坐标。单位:英寸
 @param length 线段的长度。单位:英寸
 @param thick 线的粗细。 单位:英寸
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL) Print_HLine:(int) command andHorizontal:(double) horizontal andVertical:(double) vertical andLenth:(double)length andThick:(double) thick;



/**
 打印表格竖线

 @param command 
         0: 设置用户打印的内容。设置为该值时，本函数不能单独调用，必须配合参数为 2、3 一起使用。
         1: 在用户指定的某个坐标打印。设置为该值时，可以单独调用本函 数。
         2: 一页标签打印开始。 设置为该值时，后续所有参数都被忽略。 本函数不能单独调用，必须配合参数 0、3 一起使用。
         3: 一页标签打印结束。 设置为该值时，后续所有参数都被忽略。 本函数不能单独调用，必须配合参数 0、2 一起使用。
 @param horizontal 线段起点的横坐标。单位:英寸
 @param vertical 线段起点的纵坐标。单位:英寸
 @param length 线段的长度。单位:英寸
 @param thick 线的粗细。 单位:英寸
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
-(BOOL) Print_VLine:(int)command andHorizontal:(double)horizontal andVertical:(double)vertical andLenth:(double)length andThick:(double)thick;


/**
 打印文本

 @param command 
        0: 设置用户打印的内容。设置为该值时，本函数不能单独调用，必须配合参数为 2、3 一起使用。
        1: 在用户指定的某个坐标打印。设置为该值时，可以单独调用本函 数。
        2: 一页标签打印开始。 设置为该值时，后续所有参数都被忽略。 本函数不能单独调用，必须配合参数 0、3 一起使用。
        3: 一页标签打印结束。 设置为该值时，后续所有参数都被忽略。 本函数不能单独调用，必须配合参数 0、2 一起使用。
 @param darkness 打印浓度，范围[0,30]。
 @param horizontal 打印横向位置，单位:英寸(inch)。
 @param vertical 打印纵向位置，单位:英寸(inch)。
 @param height 字符纵向放大倍数，1≤height≤10。
 @param width 字符横向放大倍数，1≤width≤10。
 @param text 打印的内容
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
-(BOOL)PrintText:(int)command andDarkness:(int)darkness andHorizontal:(double)horizontal andVertical:(double)vertical andHeight:(int)height andWidth:(int) width andText:(NSString*)text;


/**
 区域内打印居中文本 (实质为代码形式打印)

 @param command
                 0: 设置用户打印的内容。设置为该值时，本函数不能单独调用，必须配合参数为 2、3 一起使用。
                 1: 在用户指定的某个坐标打印。设置为该值时，可以单独调用本函 数。
                 2: 一页标签打印开始。 设置为该值时，后续所有参数都被忽略。 本函数不能单独调用，必须配合参数 0、3 一起使用。
                 3: 一页标签打印结束。 设置为该值时，后续所有参数都被忽略。 本函数不能单独调用，必须配合参数 0、2 一起使用。
 @param darkness 打印浓度，范围[0,30]。
 @param cellHorizontal 打印横向位置，单位:英寸(inch)。
 @param vertical 打印纵向位置，单位:英寸(inch)。
 @param CellWidth 区域宽度
 @param height 字符纵向放大倍数，1≤height≤10
 @param width 字符横向放大倍数，1≤width≤10。
 @param text 内容
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
-(BOOL)PrintCenterTextInCell:(int)command andDarkNess:(int)darkness andHorizontal:(double) cellHorizontal andVertical:(double)vertical andWidth:(double)CellWidth andHeight:(int)height andWidth:(int)width andText:(NSString *)text;

/**
 *区域内居中打印文本 (实质为图像形式打印)
 *                  
 * @param command 0: 设置用户打印的内容。设置为该值时，本函数不能单独调用，必须配合参数为 2、3 一起使用。
                  1: 在用户指定的某个坐标打印。设置为该值时，可以单独调用本函 数。
                  2: 一页标签打印开始。 设置为该值时，后续所有参数都被忽略。 本函数不能单独调用，必须配合参数 0、3 一起使用。
                  3: 一页标签打印结束。 设置为该值时，后续所有参数都被忽略。 本函数不能单独调用，必须配合参数 0、2 一起使用。
 * @param cellHorizontal 单元格的横坐标，单位：英寸
 * @param vertical 文本的纵坐标，单位：英寸
 * @param CellWidth 单元格的宽度，单位：英寸
 * @param fontface 字体名称(手机里面必须存在该字体)
 * @param bold 是否粗体，true表示粗体
 * @param fontsize 字号
 * @param text 打印的内容
 * @return 如果成功，返回值是true； 如果失败，返回值是false
 */
-(BOOL)DSZPLPrintCenterTextInCell:(int)command andCellH:(double)cellHorizontal andVertical:(double) vertical andCellW:(double)CellWidth andFont:(UIFont *) fontface andBold:(BOOL) bold andFontSize:(int)fontsize andText:(NSString *) text;
/**
 打印条码

 @param command 
         0: 设置用户打印的内容。设置为该值时，本函数不能单独调用，必须配合参数为 2、3 一起使用。
         1: 在用户指定的某个坐标打印。设置为该值时，可以单独调用本函 数。
         2: 一页标签打印开始。 设置为该值时，后续所有参数都被忽略。 本函数不能单独调用，必须配合参数 0、3 一起使用。
         3: 一页标签打印结束。 设置为该值时，后续所有参数都被忽略。 本函数不能单独调用，必须配合参数 0、2 一起使用。
 @param darkness 打印浓度，范围[0,30]
 @param horizontal 打印横向位置，单位:英寸(inch)。
 @param vertical 打印纵向位置，单位:英寸(inch)。
 @param height 条码高度，单位:英寸(inch)。
 @param heightHumanRead 人工识别字符高度，单位:点(dot)。
 @param widthHumanRead 人工识别字符宽度，单位:点(dot)。
 @param flagHumanRead 打印人工识别符: true 为打印，false 为不打印。
 @param posHumanRead 人工识别字符的位置: true 为在条码上方打印，false 为在条码下方打印。
 @param content 条码的内容。
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
-(BOOL) PrintCode128:(int)command andDarkness:(int)darkness andHorizontal:(double)horizontal andVertical:(double)vertical andHeight:(double)height andHeightHuman:(int)heightHumanRead andWidthHuman:(int)widthHumanRead andFlagHuman:(BOOL)flagHumanRead andPosHuman:(BOOL)posHumanRead andContent:(NSString *)content;

/**
 打印二维码

 @param command
         0: 设置用户打印的内容。设置为该值时，本函数不能单独调用，必须配合参数为 2、3 一起使用。
         1: 在用户指定的某个坐标打印。设置为该值时，可以单独调用本函 数。
         2: 一页标签打印开始。 设置为该值时，后续所有参数都被忽略。 本函数不能单独调用，必须配合参数 0、3 一起使用。
         3: 一页标签打印结束。 设置为该值时，后续所有参数都被忽略。 本函数不能单独调用，必须配合参数 0、2 一起使用。
 @param darkness 打印浓度，范围[0,30]
 @param horizontal 打印横向位置，单位:英寸(inch)。
 @param vertical 打印纵向位置，单位:英寸(inch)。
 @param correct 纠错级别，其值为 @"L"、@"M"、@"Q"、@"H"
 @param content 条码的内容。
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)Print_QRCode:(int)command darkness:(int)darkness horizontal:(double)horizontal vertical:(double)vertical correct:(NSString *)correct content:(NSString *)content;


/**
 黑底白字

 @param font_x 打印横向位置
 @param font_y 打印纵向位置
 @param size 文字大小
 @param data 打印内容
 @param black_w 区块宽度
 @param black_h 区块高度
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSprintWhite:(double)font_x font_y:(double)font_y size:(double)size data:(NSString *) data black_w:(double)black_w black_h:(double)black_h;


/**
 打印图片

 @param horizontal 打印横向位置
 @param vertical 打印纵向位置
 @param bitmap 图像
 @param paperWidth 暂时无用
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSZPLPrintImageWhite:(double)horizontal vertical:(double)vertical  Bitmap:(UIImage *)bitmap paperWidth:(double)paperWidth;


/**
 设置 DSZPLPrintTextLine 方向

 @param dir 方向   dir: 旋转方向 0： 不旋转 1： 旋转 90 度 2： 旋转 180 度 3： 旋转 270 度
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
- (BOOL)DSSetDirection:(int)dir;


/**
 条码字段默认值：设置条码宽度

 @param narrowBarWidth 条码窄条宽度 [1-30]
 @param wideToNarrowRatio 宽条宽度与窄条宽度的比值 [2.0-3.0] 步值0.1
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
-(BOOL)DSSetBarcodeDefaults:(int)narrowBarWidth andWideToNarrowRatio:(double)wideToNarrowRatio;

/**
 设置图像阈值

 @param iThread 阈值 [0-255].
 */
- (void)DSSetThread:(int)iThread;


/**
 以图像方式打印文字　注意：空格要全角

 @param horizontal 水平方向
 @param vertical 垂直方向
 @param fontface 字体 nil时为 @"PingFangHK-Light"
 @param bold 此参数无用,若要粗体,请直接使用fontface带粗体的字体
 @param size 字体大小
 @param text 文字
 @return  如果成功，返回值是true； 如果失败，返回值是false
 */

/**
  以图像方式打印文字　注意：空格要全角

 @param horizontal 水平位置
 @param vertical 谁知位置
 @param fontface 字体 为nil时 使用 systemfont,并且使用boldweight设置粗细程度
 @param boldweight 粗体程度
 @param size 字体大小
 @param text 文本
 @param bShowStyleBlackFont YES 白底黑字 NO 黑底白字
 @return 如果成功，返回值是true； 如果失败，返回值是false
 */
-(BOOL)DSZPLPrintTextLine:(double)horizontal andVertical:(double)vertical andFontName:(NSString *)fontface andBoldweight:(CGFloat)boldweight andSize:(int)size andText:(NSString*) text andShowStyle:(BOOL)bShowStyleBlackFont;



/**
 * 条码 识别码平铺
 * @param command
 *            0: 设置用户打印的内容。设置为该值时，本函数不能单独调用，必须配合参数为 2、3 一起使用。 1:
 *            在用户指定的某个坐标打印。设置为该值时，可以单独调用本函数。 2: 一页标签打印开始。
 *            设置为该值时，后续所有参数都被忽略。本函数不能单独调用，必须配合参数 0、3 一起使用。 3: 一页标签打印结束。
 *            设置为该值时，后续所有参数都被忽略。本函数不能单独调用，必须配合参数 0、2 一起使用。
 * @param darkness 打印浓度，范围[0,30]。
 * @param horizontal 打印横向位置，单位：英寸(inch)。
 * @param vertical 打印纵向位置，单位：英寸(inch)。
 * @param height 条码高度，单位：英寸(inch)。
 * @param sizeHumanRead 人工识别字符的大小
 * @param fontface 字体名称(手机里面必须存在该字体)
 * @param bold 是否粗体，true表示粗体
 * @param content 条码的内容。
 * @return 如果成功，返回值是true； 如果失败，返回值是false
 */
-(BOOL) DSPrintCode128Dispersion:(int) command andDarkness:(int)darkness andHorizontal:(double)horizontal andVertical:(double)vertical andHeight:(double) height andSizeHuman:(int)sizeHumanRead andFont:(UIFont *) fontface andBold:(BOOL) bold andContent:(NSString *) content;

/**
 * 打印带圈字符
 *
 * @param xPos 横坐标，单位：英寸
 * @param yPos 纵坐标，单位：英寸
 * @param data 圈里面的字符
 * @return 如果成功，返回值是true； 如果失败，返回值是false
 */

-(BOOL) PrintBelle:(double) xPos andYpos:(double)yPos andData:(NSString *)data;
@end
