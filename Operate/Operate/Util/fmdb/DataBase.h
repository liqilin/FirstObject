//
//  DataBase.h
//  KeMan
//
//  Created by user on 14-6-21.
//
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "DataUrlModel.h"
@interface DataBase : NSObject

//关闭数据库
+ (void)closeDataBase;

//插入数据
+ (void)insertIntoDataBase:(DataUrlModel *)model;

//获得对象 并打开数据库，创建表
+ (DataBase *)shareInstance;

//根据id删除数据
+ (void)deleteDataFromDataBase:(DataUrlModel *)model;


#pragma mark - 更新数据操作----- executeUpdate
+ (void)updateFromDataBase:(DataUrlModel *)person;

//查询数据

+ (NSMutableArray *)selectDataFromDataBaseWithId:(NSString *)deviceId;


+ (NSMutableArray *)selectAllDataFromDataBase;



+ (void)deleteFromTableView;


+ (void)updateTheVersionName:(NSString *)verson whereid:(NSString *)urlID;

+ (void)columnExistsTheVersionName:(NSString *)verson;







@end
