//
//  HTTPService.m
//  KeMan
//
//  Created by user on 14-8-4.
//
//

#import "HTTPService.h"
#import "AFNetworking.h"
#import "Macro.h"

@implementation HTTPService



#pragma GET请求

+ (void)GetHttpToServerWith:(NSString *)urlString  WithParameters:(NSDictionary *)paras success:(void (^) (NSDictionary *dic))result error:(void (^) (NSError *error))error_
{
    
    
//    NSString * encodedString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
//    NSURL *URL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString parameters:paras success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        
        result(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"错误:---%@",error);
        error_(error);
    }];
}

#pragma post请求

+ (void)POSTHttpToServerWith:(NSString *)urlString WithParameters:(NSDictionary *)paras success:(void (^) (NSDictionary *dic))result error:(void (^) (NSError *error))error_
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:urlString parameters:paras success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        result(responseObject);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        error_(error);
    }];
}



#pragma mark-上传图片和数据多上传
+ (void)PostHttpToServerImageAndDataWith:(NSString *)urlString WithParmeters:(NSDictionary *)paras WithFilePath:(NSString *)Path  imageName:(NSString *)name andImageFile:(UIImage *)image success:(void (^) (NSDictionary *dic))result error:(void (^) (NSError *error))error_
{
    
    
//    NSLog(@"dictayt===%@",paras);

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:urlString parameters:paras constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

        [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"file" fileName:name mimeType:@"image/png"];
        
//        [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"myfile" fileName:name mimeType:@"image/png"];


    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        result(responseObject);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        error_(error);

//        NSLog(@"Error: %@", error);
    }];
}

+ (void)downloadString:(NSString *)str WithFileType:(NSString *)type downLoadPath:(void(^)(float currentprogress))curprogress error:(void (^)(NSError *error))error_

{
    NSURL *URL = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];

    
    //下载请求
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [request setValue:@"identity" forHTTPHeaderField:@"Accept-Encoding"];

  
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:[self getFilePath:type] append:YES];
    //下载进度回调
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {        //下载进度

        float progress = ((float)totalBytesRead) / (totalBytesExpectedToRead);
        NSLog(@"%f",progress);
        
        curprogress(progress);
    }];
    //成功和失败回调
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"ok");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        error_(error);
        
    }];
    [operation start];
}


+ (NSString *)getFilePath:(NSString *)type
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
//    NSString *tempStr = [Util getCurrentDate];
    NSString * tempStr = [Util getCurrentDateWithFormat:@"YYYYMMddhh:mm"];
    
    if ([type isEqualToString:@"MP3"]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath: [NSString stringWithFormat:@"%@/Documents/myMP3", NSHomeDirectory()] attributes:nil];
        tempStr = [tempStr stringByAppendingString:@".mp3"];
        
        return [docDir stringByAppendingString:[NSString stringWithFormat:@"/myMP3/%@",tempStr]];

        
    }else if ([type isEqualToString:@"Move"]){
        
        [[NSFileManager defaultManager] createDirectoryAtPath: [NSString stringWithFormat:@"%@/Documents/myMove", NSHomeDirectory()] attributes:nil];
        tempStr = [tempStr stringByAppendingString:@".wmv"];
        
        return [docDir stringByAppendingString:[NSString stringWithFormat:@"/myMove/%@",tempStr]];

    }else if ([type isEqualToString:@"Other"]){
        
        [[NSFileManager defaultManager] createDirectoryAtPath: [NSString stringWithFormat:@"%@/Documents/myOther", NSHomeDirectory()] attributes:nil];
        tempStr = [tempStr stringByAppendingString:@".swf"];
        
        return [docDir stringByAppendingString:[NSString stringWithFormat:@"/myOther/%@",tempStr]];

    }

    
    return [docDir stringByAppendingString:[NSString stringWithFormat:@"/%@",tempStr]];
}

#pragma mark-下载文件
+ (void)downloadWithFilePathString:(NSString *)urlString WithFileType:(NSString *)type downLoadPath:(void (^) (NSString *filePath))filePath_ error:(void (^)(NSError *error))error_

{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
     NSURL *URL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSURL *URL = [[NSURL alloc]initWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        
        if ([type isEqualToString:@"MP3"]) {
            
            [[NSFileManager defaultManager] createDirectoryAtPath: [NSString stringWithFormat:@"%@/Documents/myMP3", NSHomeDirectory()] attributes:nil];
            documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"myMP3"];
            
        }else if ([type isEqualToString:@"Move"]){
            
            [[NSFileManager defaultManager] createDirectoryAtPath: [NSString stringWithFormat:@"%@/Documents/myMove", NSHomeDirectory()] attributes:nil];
            documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"myMove"];
            
        }else if ([type isEqualToString:@"Other"]){
            
            [[NSFileManager defaultManager] createDirectoryAtPath: [NSString stringWithFormat:@"%@/Documents/myOther", NSHomeDirectory()] attributes:nil];
            documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"myOther"];
            
        
//            [[NSFileManager defaultManager] createDirectoryAtPath: [NSString stringWithFormat:@"%@/myOther", NSHomeDirectory()] attributes:nil];
//            documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"myOther"];

        }
        

        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
        
        NSLog(@"response==%@",response);
        NSString *tempUrl = [NSString stringWithFormat:@"%@",filePath];
        
        filePath_(tempUrl);
        error_(error);

    }];
    [downloadTask resume];
}



+ (void)downloadFileURL:(NSString *)aUrl savePath:(NSString *)aSavePath fileName:(NSString *)aFileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //检查本地文件是否已存在
    NSString *fileName = [NSString stringWithFormat:@"%@/%@", aSavePath, aFileName];
    
    //检查附件是否存在
    if ([fileManager fileExistsAtPath:fileName]) {
//        NSData *audioData = [NSData dataWithContentsOfFile:fileName];
//        [self requestFinished:[NSDictionary dictionaryWithObject:audioData forKey:@"res"] tag:aTag];
    }else{
        //创建附件存储目录
        if (![fileManager fileExistsAtPath:aSavePath]) {
            [fileManager createDirectoryAtPath:aSavePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        //下载附件
        NSURL *url = [NSURL URLWithString:aUrl];
        
        NSLog(@"url=%@==%@",url,aUrl);
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.inputStream   = [NSInputStream inputStreamWithURL:url];
        operation.outputStream  = [NSOutputStream outputStreamToFileAtPath:fileName append:NO];
        
        //下载进度控制
         [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
         NSLog(@"is download：%f", (float)totalBytesRead/totalBytesExpectedToRead);
         }];
        
        //已完成下载
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"%@===",responseObject);
            
//            NSData *audioData = [NSData dataWithContentsOfFile:fileName];
            //设置下载数据到res字典对象中并用代理返回下载数据NSData
//            [self requestFinished:[NSDictionary dictionaryWithObject:audioData forKey:@"res"] tag:aTag];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            //下载失败
//            [self requestFailed:aTag];
        }];
        
        [operation start];
    }
}

#pragma mark-上传文件
+ (void)uploadToServerWithFilePathString:(NSString *)urlString WithServerPath:(NSString *)path success:(void (^) (NSDictionary *dic))result error:(void (^) (NSError *error))error_

{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURL *filePath = [NSURL fileURLWithPath:path];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePath progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            error_(error);
            NSLog(@"Error: %@", error);
        } else {
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            result(dic);

            NSLog(@"Success: %@ %@", response, responseObject);
        }
    }];
    [uploadTask resume];
}



@end
