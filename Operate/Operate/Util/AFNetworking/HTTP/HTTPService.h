//
//  HTTPService.h
//  KeMan
//
//  Created by user on 14-8-4.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^succeeBlock) (NSDictionary *dic);
typedef void (^errorBlock) (NSError *error);
typedef void (^progress) (float currentprogress);

typedef void (^downBlock) (NSString *filePath);


@interface HTTPService : NSObject


#pragma GET请求

+ (void)GetHttpToServerWith:(NSString *)urlString  WithParameters:(NSDictionary *)paras success:(void (^) (NSDictionary *dic))result error:(void (^) (NSError *error))error_;

#pragma post请求

+ (void)POSTHttpToServerWith:(NSString *)urlString WithParameters:(NSDictionary *)paras success:(void (^) (NSDictionary *dic))result error:(void (^) (NSError *error))error_;

#pragma mark-上传图片和数据多上传
+ (void)PostHttpToServerImageAndDataWith:(NSString *)urlString WithParmeters:(NSDictionary *)paras WithFilePath:(NSString *)Path  imageName:(NSString *)name andImageFile:(UIImage *)image success:(void (^) (NSDictionary *dic))result error:(void (^) (NSError *error))error_;


#pragma mark-下载文件
+ (void)downloadWithFilePathString:(NSString *)urlString WithFileType:(NSString *)type downLoadPath:(void (^) (NSString *filePath))filePath_ error:(void (^)(NSError *error))error_;


//+ (void)downloadFileURL:(NSString *)aUrl savePath:(NSString *)aSavePath fileName:(NSString *)aFileName;

#pragma mark-上传文件
+ (void)uploadToServerWithFilePathString:(NSString *)urlString WithServerPath:(NSString *)path success:(void (^) (NSDictionary *dic))result error:(void (^) (NSError *error))error_;


+ (void)downloadString:(NSString *)str WithFileType:(NSString *)type downLoadPath:(void(^)(float currentprogress))curprogress error:(void (^)(NSError *error))error_;



@end
