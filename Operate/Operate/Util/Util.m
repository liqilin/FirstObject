//
//  Util.m
//  mlh
//
//  Created by qd on 13-5-10.
//  Copyright (c) 2013年 sunday. All rights reserved.
//

#import "Util.h"
#import "Macro.h"
#import "sys/utsname.h"
 #import <SystemConfiguration/CaptiveNetwork.h>

@interface Util ()
//{
//    MBProgressHUD *HUD;
//}
@end
static Util *class = nil;
@implementation Util


- (void)dealloc
{
//    HUD = nil;
}
#pragma mark - HUD show and shide
//+ (CGFloat)


#pragma mark-utit
+ (Util *)getUtitObject
{
    if (class == nil) {
        class = [[Util alloc] init];
    }
    return class;
}

//NSString UTF8转码
+(NSString *)getUTF8Str:(NSString *)str{
    return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

//不转webview打不开啊。。
+(NSString *)getWebViewUrlStr:(NSString *)urlStr{
    return [urlStr stringByAddingPercentEscapesUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
}


//去掉空格
+(NSString *) stringByRemoveTrim:(NSString *)str
{
    
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

//根据文字、字体、文字区域宽度，得到文字区域高度
+ (CGFloat)heightForText:(NSString*)sText Font:(UIFont*)font forWidth:(CGFloat)fWidth
{
    CGSize szContent = [sText sizeWithFont:font constrainedToSize:CGSizeMake(fWidth, CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
    return  szContent.height;
}

//根据文字信息和url，得到最终的文字message（总长度不超过140）。 url可以为nil。
-(NSString *)getMessageWithText:(NSString *)text url:(NSString *)url{
    if (text == nil && url == nil) {
        return nil;
    }
    if (text == nil) {
        return url;
    }
    
    //text != nil
    NSMutableString *messageText  = [[NSMutableString alloc] init];
    if (url == nil) {
        int trimlength =  [text length]- 140;
        if (trimlength > 0) {
            [messageText appendFormat:@"%@",[text substringWithRange:NSMakeRange(0, [text length]-trimlength)]];
        }else{
            [messageText appendFormat:@"%@",text];
        }
//        NSLog(@"%u%@",[messageText length],messageText);
        return messageText;
    }else{
        int trimlength =  [text length] + [url length] - 140;
        if (trimlength > 0) {
            [messageText appendFormat:@"%@%@",[text substringWithRange:NSMakeRange(0, [text length]-trimlength)],url];
        }else{
            [messageText appendFormat:@"%@%@",text,url];
        }
//        NSLog(@"%u%@",[messageText length],messageText);
        return messageText;
    }
    
}

//view根据原来的frame做调整，重新setFrame，fakeRect的4个参数如果<0，则用原来frame的相关参数，否则就用新值。
+ (void) View:(UIView *)view ReplaceFrameWithRect:(CGRect) fakeRect{
    CGRect frame = view.frame;
    CGRect newRect;
    newRect.origin.x = fakeRect.origin.x > 0 ? fakeRect.origin.x : frame.origin.x;
    newRect.origin.y = fakeRect.origin.y > 0 ? fakeRect.origin.y : frame.origin.y;
    newRect.size.width = fakeRect.size.width > 0 ? fakeRect.size.width : frame.size.width;
    newRect.size.height = fakeRect.size.height > 0 ? fakeRect.size.height : frame.size.height;
    [view setFrame:newRect];
}

//view根据原来的bounds做调整，重新setBounds，fakeRect的4个参数如果<0，则用原来bounds的相关参数，否则就用新值。
+ (void) View:(UIView *)view ReplaceBoundsWithRect:(CGRect) fakeRect{
    CGRect bounds = view.bounds;
    CGRect newRect;
    newRect.origin.x = fakeRect.origin.x > 0 ? fakeRect.origin.x : bounds.origin.x;
    newRect.origin.y = fakeRect.origin.y > 0 ? fakeRect.origin.y : bounds.origin.y;
    newRect.size.width = fakeRect.size.width > 0 ? fakeRect.size.width : bounds.size.width;
    newRect.size.height = fakeRect.size.height > 0 ? fakeRect.size.height : bounds.size.height;
    [view setBounds:newRect];
}



//根据@"#eef4f4"得到UIColor
+ (UIColor *) uiColorFromString:(NSString *) clrString
{
	return [Util uiColorFromString:clrString alpha:1.0];
}

//将原始图片draw到指定大小范围，从而得到并返回新图片。能缩小图片尺寸和大小
+ (UIImage*)ScaleImage:(UIImage*)image ToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//将图片保存到document目录下
+ (void)saveDocImage:(UIImage *)tempImage WithName:(NSString *)imageName
{
    NSData* imageData = UIImageJPEGRepresentation(tempImage, 0.4);
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    [imageData writeToFile:fullPathToFile atomically:NO];
}

//根据@"#eef4f4"得到UIColor

+ (UIColor *) uiColorFromString:(NSString *) clrString alpha:(double)alpha
{
	if ([clrString length] == 0) {
		return [UIColor clearColor];
	}
	
	if ( [clrString caseInsensitiveCompare:@"clear"] == NSOrderedSame) {
		return [UIColor clearColor];
	}
	
	if([clrString characterAtIndex:0] == 0x0023 && [clrString length]<8)
	{
		const char * strBuf= [clrString UTF8String];
		
		int iColor = strtol((strBuf+1), NULL, 16);
		typedef struct colorByte
		{
			unsigned char b;
			unsigned char g;
			unsigned char r;
		}CLRBYTE;
		CLRBYTE * pclr = (CLRBYTE *)&iColor;
		return [UIColor colorWithRed:((double)pclr->r/255) green:((double)pclr->g/255) blue:((double)pclr->b/255) alpha:alpha];
	}
	return [UIColor blackColor];
}

//字符串转颜色
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    
    if ([cString length] < 6)
        return [UIColor whiteColor];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor whiteColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}



//将浮点数转换为NSString，并设置保留小数点位数
+ (NSString *)getStringFromFloat:(float) f withDecimal:(int) decimalPoint{
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:kCFNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:decimalPoint];

    return  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:f]];
}

+ (int) randomFromMin:(int)min ToMax:(int)max
{
    int randNum = arc4random() % (max-min) + min; //create the random number.
    return randNum;
}

+ (int) defaultRandom
{
    return [self randomFromMin:1 ToMax:9999];
}
#pragma mark-scoket的数据转化

+ (UInt16)uint16FromNetData:(NSData *)data
{
    return ntohs(*((UInt16 *)[data bytes]));
}

+ (UInt32)uint32FromNetData:(NSData *)data
{
    return ntohl(*((UInt32 *)[data bytes]));
}


+ (void)setFont:(UILabel *)label
{
    //@"AvantGardeITCbyBT-Medium"
    [label setFont:[UIFont fontWithName:@"AvantGardeITCbyBT-Book" size:label.font.pointSize]];
}

+ (void)setFontFor:(NSArray *)labelArray
{
    for (UILabel * label in labelArray)
    {
        [self setFont:label];
    }
}
//mac地址 转换
+ (NSString *)macString:(NSData *)mac
{
//    NSLog(@"%@");
    if (mac.length == 12)
    {
        NSMutableString * result = [NSMutableString string];
        Byte * bytes = (Byte *)mac.bytes;
        for (NSInteger index = 0; index < mac.length; index ++)
        {
            [result appendFormat:@"%02x:",bytes[index]];
        }
        return [result substringToIndex:result.length - 1];
    }
    return @"";
}

- (NSString *)getMacStringWith:(NSString *)mac
{
    
    NSString *temp = nil;
    for (int i = 0; i < mac.length; i++) {
       NSString *str = [mac substringFromIndex:2];
        
        [temp stringByAppendingString:[NSString stringWithFormat:@"%@:",str]];
    }
    return temp;
}


+ (UIWindow *)getAppWindow
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    return window;
}

//获取到当前wifi名字
+ (NSString *)getWifiName
{
    NSString *wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            //            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            CFRelease(dictRef);
        }
    }
    CFRelease(wifiInterfaces);
    return wifiName;
}

//获取budle 版本
+ (NSString *)getAppVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

//CFBundleShortVersionString

//app本身版本
+ (NSString *)getAppShortVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getAppName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}


//警告框
+ (UIAlertView *)showAlertWithTitle:(NSString *)title msg:(NSString *)msg
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    return alert;
}
//delegate对象
+ (AppDelegate *)getAppDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (NSData *)macStrTData:(NSString *)str
{
    int byteLen = str.length % 2 == 0 ? str.length / 2 : str.length / 2 + 1;
    
    UInt8 bytes[byteLen];
    for (int i = byteLen - 1; i >= 0; i--)
    {
        int rangeLocation = MAX(i * 2, 0);
        int rangeLength = rangeLocation + 2 > str.length ? 1 : 2;
        NSString *aStr = [str substringWithRange:NSMakeRange(rangeLocation ,rangeLength)];
        bytes[i] = strtol([aStr UTF8String], NULL, 16);
    }
    
    NSData *data = [NSData dataWithBytes:bytes length:byteLen];
    return data;
}

+ (NSString *)getMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    NSLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

+ (NSData *)netDataFromUint16:(UInt16)number
{
    UInt16 netNumber = htons(number);
    NSData * data = [NSData dataWithBytes:(Byte *)&netNumber length:2];
    return data;
}


+ (NSData *)macStrTData:(NSString *)str
{
    int byteLen = str.length % 2 == 0 ? str.length / 2 : str.length / 2 + 1;
    
    UInt8 bytes[byteLen];
    for (int i = byteLen - 1; i >= 0; i--)
    {
        int rangeLocation = MAX(i * 2, 0);
        int rangeLength = rangeLocation + 2 > str.length ? 1 : 2;
        NSString *aStr = [str substringWithRange:NSMakeRange(rangeLocation ,rangeLength)];
        bytes[i] = strtol([aStr UTF8String], NULL, 16);
    }
    
    NSData *data = [NSData dataWithBytes:bytes length:byteLen];
    return data;
}


#pragma mark-
#pragma mark-转换随机433地址 只适合本项目使用
+ (NSData *)getRFAddressWith:(NSString *)string
{
    NSArray * tempArray = [string componentsSeparatedByString:@":"];
    UInt8 byt[3];
    for (int i = 0; i < [tempArray count]; i ++) {
        byt[i] = [[tempArray objectAtIndex:i] intValue];
    }
    
    NSData *data = [NSData dataWithBytes:byt length:3];
    
    return data;
}

+ (UIImage *)getImageFile:(NSString *)imagePath
{
    UIImage *endImage;
    NSString *dataPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:[NSString stringWithFormat:@"/%@",imagePath]];//获取程序包中相应文件的路径
    NSFileManager *fileMa = [NSFileManager defaultManager];
    
    if(![fileMa fileExistsAtPath:dataPath]){

        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:[Util getFilePathWithImageName:imagePath]]) {
            NSLog(@"找不到图片");
            
        }else{
            endImage = [[UIImage alloc] initWithContentsOfFile:[Util getFilePathWithImageName:imagePath]];

        }
            
    }else{
        endImage = [UIImage imageNamed:imagePath];

    }
    
        
    return endImage;
    
}

+ (void)deleteCancleImageFileWithPath:(NSString *)path
{
    if ([path hasPrefix:@"/"]) {
        
        NSError *error = nil;
        if([[NSFileManager defaultManager] removeItemAtPath:path error:&error]){
            NSLog(@"文件移除成功");
        }
        else {
            NSLog(@"error=%@", error);
        }
    }else{
        
        return;
    }
    
    

}

//数组排序临时方法

//+ (NSMutableArray *)invertedOrder:(NSMutableArray *)timeArray
//{
//    
//    for (int i = 0; i<[timeArray count]; i++)
//    {
//        for (int j=i+1; j<[timeArray count]; j++)
//        {
//            
//            Device *dici = timeArray[i];
//            Device *dicj = timeArray[j];
//            
////            int a = [dici.orderNumber intValue];
////            int b = [dicj.orderNumber intValue];
//            if (dici.orderNumber > dicj.orderNumber)
//            {
//                [timeArray replaceObjectAtIndex:i withObject:dicj];
//                [timeArray replaceObjectAtIndex:j withObject:dici];
//            }
//        }
//    }
//    return timeArray;
//}
//
#pragma mark-md5

//获取图片路径
+ (NSString *)getFilePathWithImageName:(NSString *)imageName
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    return [docDir stringByAppendingString:[NSString stringWithFormat:@"/%@",imageName]];
}

+ (NSString *)getPassWordWithmd5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
   NSString * string = [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
//    return [string uppercaseStringWithLocale:[NSLocale currentLocale]];
    return string;
    
}

//数组去重复对象
+ (NSMutableArray *)arraytoreToArray:(NSMutableArray *)aArray
{
    NSMutableArray *array = [ NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i<aArray.count; i++)
    {
        id str = [aArray objectAtIndex:i];
        
        if ([array containsObject:str])
        {
            
        }
        else
        {
            [array addObject:str];
        }
    }
    
    return array;
}
+ (NSString *)getUUID
{
    
    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *cfuuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
    
//    NSString *timeSp = [NSString stringWithFormat:@"%li", (long)[[NSDate date] timeIntervalSince1970] ];
    

    cfuuidString  = [cfuuidString lowercaseString];
    
    return cfuuidString;
}


//mac地址的拼接
+ (NSString *)getMAcStringWithstring:(NSString *)mac
{
    
    
    NSMutableArray *temparray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i = 0; i <mac.length/2; i ++) {
        
        NSString *str = [mac substringWithRange:NSMakeRange(i*2, 2)];
        [temparray addObject:str];
    }
    
    NSString *string = @"";
    for (NSString *macstr in temparray) {
        
        
        string =  [string stringByAppendingString:[macstr stringByAppendingString:@":"]];
    }
    
    
    return  [string substringToIndex:[string length] - 1];
    
}

//+ (UIColor *)getGreenColor
//{
//    
//    return RGBA(140, 240, 5, 1);
//}
//
//
//+ (UIColor *)getWhiteColor
//{
//    
//    return RGBA(243, 248, 238, 1);
//}


// 是否4英寸屏幕
+ (BOOL)is4InchScreen
{
    static BOOL bIs4Inch = NO;
    static BOOL bIsGetValue = NO;
    
    if (!bIsGetValue)
    {
        CGRect rcAppFrame = [UIScreen mainScreen].bounds;
        bIs4Inch = (rcAppFrame.size.height == 568.0f);
        
        bIsGetValue = YES;
    }else{}
    
    return bIs4Inch;
}

//4.7寸
+ (BOOL)is4_7InchScreen
{
    static BOOL bIs4_7Inch = NO;
    static BOOL bIsGetValue = NO;
    
    if (!bIsGetValue)
    {
        CGRect rcAppFrame = [UIScreen mainScreen].bounds;
        bIs4_7Inch = (rcAppFrame.size.height == 667.0f);
        
        bIsGetValue = YES;
    }else{}
    
    return bIs4_7Inch;
}


//3.5寸
+ (BOOL)is3_5InchScreen
{
    static BOOL bIs3_5Inch = NO;
    static BOOL bIsGetValue = NO;
    
    if (!bIsGetValue)
    {
        CGRect rcAppFrame = [UIScreen mainScreen].bounds;
        bIs3_5Inch = (rcAppFrame.size.height == 667.0f);
        
        bIsGetValue = YES;
    }else{}
    
    return bIs3_5Inch;
}


//获取当前试用语言
+ (NSString *)getCurrentLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    NSLog( @"%@" , currentLanguage);
    
    return currentLanguage;
}

//获取当前所在国家/区域
+ (NSString *)getCurrentCountry
{
    
    NSLocale *currentLocale = [NSLocale currentLocale];
    
    NSLog(@"Country Code is %@", [currentLocale objectForKey:NSLocaleCountryCode]);
    
    return  [currentLocale objectForKey:NSLocaleCountryCode];
}


//当前项目可用 bluetouch

+ (float)getCurrentShoursWith:(NSUInteger)index
{
    float tempFloat = 0.1f;
    switch (index) {
        case 0:
            tempFloat = 1.0f;
            break;
        case 1:
            tempFloat = 0.9f;
            
            
            break;
            
        case 2:
            tempFloat = 0.8f;
            
            break;
            
        case 3:
            tempFloat = 0.7f;
            
            break;
            
        case 4:
            tempFloat = 0.6f;
            
            break;
            
        case 5:
            tempFloat = 0.5f;
            
            break;
            
        case 6:
            tempFloat = 0.3f;
            
            break;
            
        case 7:
            tempFloat = 0.15f;
            
            break;
        case 8:
            tempFloat = 0.0f;
            
            break;
            
            
        default:
            break;
    }
    
    return tempFloat;
    
}


#pragma mark-图片去色
//图片去色
+ (UIImage *)grayImage:(UIImage *)sourceImage
{
    int bitmapInfo = kCGImageAlphaNone;
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  8,      // bits per component
                                                  0,
                                                  colorSpace,
                                                  bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGContextDrawImage(context,
                       CGRectMake(0, 0, width, height), sourceImage.CGImage);
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    return grayImage;
}


//根据字符串获得宽高
+ (CGSize)getStringWidthWithStringLenth:(NSString *)string Withfont:(float)fontz
{
    
    UIFont *font = [UIFont systemFontOfSize:fontz];
    CGSize size = CGSizeMake( Screen_Width, 2000);
    NSString *tempStr = string;
    CGSize tempSize = [tempStr sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    
    
    return tempSize;
    

}

+(NSString *)getCurrentDate
{
    long long  time = [[NSDate date] timeIntervalSince1970]*1000;
    NSString * timeStr = [NSString stringWithFormat:@"%lld",time];
    return timeStr;
}


+(NSString *)getCurrentDateWithFormat:(NSString *)format
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:[NSDate date]];
}

+ (void)showHud:(NSString *)string  withView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = string;
    hud.margin = 10.f;
    hud.yOffset = 0.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2.0f];

}

+ (void)showIndeterminateHud:(NSString *)string  withView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = string;
    hud.margin = 10.f;
    hud.yOffset = 0.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:NO afterDelay:2.5];
    
    
}


//获取设备udid
+ (NSString *)deviceUUIDString{
    
    

    return [[UIDevice currentDevice].identifierForVendor UUIDString];
    
}


//获取设备版本号
+ (NSString *)deviceSystemVersion{
//    NSString *systemVersion;
    
//     [[UIDevice currentDevice] systemVersion];
    
    return [[UIDevice currentDevice] systemVersion];
    
    
    
}

//获取设备型号
+ (NSString*)deviceVersion
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";


    //iPod
    
    if ([deviceString isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";
    //iPad
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";

    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2 (32nm)";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad mini (GSM)";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad mini (CDMA)";
    
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3(WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3(CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3(4G)";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4 (4G)";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    if ([deviceString isEqualToString:@"iPad4,4"]||[deviceString isEqualToString:@"iPad4,5"]||[deviceString isEqualToString:@"iPad4,6"]) return @"iPad mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"]||[deviceString isEqualToString:@"iPad4,8"]||[deviceString isEqualToString:@"iPad4,9"])  return @"iPad mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad mini 4";

    
    return deviceString;
}

//判断值是否为空

+ (BOOL)currentValueEmpty:(NSObject *)value
{
    
    return [value isEqual:[NSNull null]];
    
}


@end
