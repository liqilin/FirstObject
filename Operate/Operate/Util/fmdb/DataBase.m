//
//  DataBase.m
//  KeMan
//
//  Created by user on 14-6-21.
//
//

#import "DataBase.h"
#import "Macro.h"
@implementation DataBase

static DataBase * _db = nil;

static FMDatabase * database = nil;

+ (DataBase *)shareInstance{
    
    @synchronized(self){
        
        if (!_db) {
            
            _db = [[DataBase alloc]init];
            
            [self openDataBase];
//
            [self createTable];
        }
    }
    
    return _db;
}

+ (NSString *)getPath
{
    NSArray *documentPath =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [documentPath objectAtIndex:0];
    NSString *myPath = [path stringByAppendingPathComponent:@"myTest.sqlite"];
    
    NSLog(@"mypath=%@",myPath);
    return myPath;
}

+ (void)openDataBase
{
    if (database) {
        
        return;
    }
    database = [FMDatabase databaseWithPath:[self getPath]];
    if (![database open]) {
//        NSLog(@"open cancel打开失败");
        return;
    }else{
//        NSLog(@"open OK 成功");
    }
    // 为数据库设置缓存,提高查询效率
    database.shouldCacheStatements = YES;

    
}
#pragma mark - 关闭数据库操作
+ (void)closeDataBase{
    
    if (![database close]) {
//        NSLog(@"关闭数据库失败");
        return;
    }
    
    database = nil;
//    NSLog(@"关闭数据库成功");
    
}

#pragma mark - 管理创建表的操作
+ (void)createTable//Name:(NSString *)userTable
{
    
    [self openDataBase];
    
    // 判断表是否存在,不存在就创建------ tableExists
    if (![database tableExists:@"DataTable"]) {
        
        [database executeUpdate:@"CREATE TABLE DataTable(id INTEGER PRIMARY KEY AUTOINCREMENT,titleName TEXT, urlType TEXT, urlStr TEXT)"];
        
        NSLog(@"创建表成功");
    }
    
    [self closeDataBase];
}


+ (void)deleteFromTableView
{
    
    [self openDataBase];

    [database executeUpdate:@"DELETE FROM DataTable"];

    [self closeDataBase];

    
}
#pragma mark - 增加数据操作----- executeUpdate
+ (void)insertIntoDataBase:(DataUrlModel *)model
{
    
    [self openDataBase];
    

    [database executeUpdate:@" INSERT INTO DataTable (titleName,urlType,urlStr) VALUES (?,?,?)",model.titleName,model.urlType,model.urlStr];
    
    [self closeDataBase];
}






#pragma mark - 更新数据操作----- executeUpdate
+ (void)updateFromDataBase:(DataUrlModel *)person{
    
    [self openDataBase];
    
    [database executeUpdate:[NSString stringWithFormat:@"UPDATE DataTable SET titleName ='%@',urlType ='%@',urlStr='%@' WHERE id = '%@' ",person.titleName,person.urlType,person.urlStr,person.urlID]];
    
    [self closeDataBase];
}



#pragma mark - 删除数据操作----- executeUpdate
+ (void)deleteDataFromDataBase:(DataUrlModel *)model
{
    
    [self openDataBase];
    
    
    [database executeUpdate:[NSString stringWithFormat:@" DELETE FROM DataTable WHERE id = '%@'",model.urlID] ];
    
    [self closeDataBase];
}


+ (NSMutableArray *)selectDataFromDataBaseWithId:(NSString *)deviceId
{
    
    [self openDataBase];
    
    FMResultSet * resultSet = [database executeQuery:[NSString stringWithFormat:@"SELECT * FROM DataTable WHERE id IN ('%@')",deviceId]];
    
    NSMutableArray *murableArray = [[NSMutableArray alloc] initWithCapacity:0];
    while ([resultSet next]) {
        DataUrlModel *model = [[DataUrlModel alloc] init];
        model.titleName = [resultSet stringForColumn:@"titleName"];
        model.urlType = [resultSet stringForColumn:@"urlType"];
        model.urlStr = [resultSet stringForColumn:@"urlStr"];
        model.urlID = [resultSet stringForColumn:@"id"];
        
        
        [murableArray addObject:model];
    }
    
    
    [self closeDataBase];
    return murableArray;

}

#pragma -判断当前字段是否存在在表中
+ (void)columnExistsTheVersionName:(NSString *)verson
{
    [self openDataBase];

    if  ([database columnExists:@"currentVersion" inTableWithName:@"DataTable"] == NO) {
        
        
//        [database executeUpdate:@"ALTER TABLE DataTable ADD  currentVersion TEXT Default(?)",verson];
        
        
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE DataTable ADD  currentVersion text Default('1.1.1')"];
        [database executeUpdate:sql];
//        for (DataUrlModel *model in [self selectAllDataFromDataBase]){
//        
//        NSString *update = [NSString stringWithFormat:@"UPDATE DataTable SET currentVersion=? WHERE id =%@",model.urlID];
//            [database executeUpdate:update,verson];
//        }
    }
    
    
    [self closeDataBase];

}
+ (void)updateTheVersionName:(NSString *)verson whereid:(NSString *)urlID {
    
    [self openDataBase];

    [database executeUpdate:[NSString stringWithFormat:@"UPDATE DataTable SET currentVersion ='%@' WHERE id = '%@'",verson,urlID]];

    
    [self closeDataBase];

}



#pragma mark - 查询数据操作(与其他的都不一样,查询是调用executeQuery,切记切记!!!!!!)
 + (NSMutableArray *)selectAllDataFromDataBase
{
    
    [self openDataBase];
    
    FMResultSet * resultSet = [database executeQuery:@"SELECT * FROM DataTable"];
     
     NSMutableArray *murableArray = [[NSMutableArray alloc] initWithCapacity:0];
    while ([resultSet next]) {
        DataUrlModel *model = [[DataUrlModel alloc] init];
        
        model.titleName = [resultSet stringForColumn:@"titleName"];
        model.urlType = [resultSet stringForColumn:@"urlType"];
        model.urlStr = [resultSet stringForColumn:@"urlStr"];
        model.urlID = [resultSet stringForColumn:@"id"];
        model.currentVersion =  [resultSet stringForColumn:@"currentVersion"];
        
        [murableArray addObject:model];
    }
     
    
    [self closeDataBase];
     return murableArray;
}


@end
