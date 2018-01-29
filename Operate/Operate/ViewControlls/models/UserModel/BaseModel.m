//
//  BaseModel.m
//  Operate
//
//  Created by user on 2017/11/10.
//  Copyright © 2017年 hanyc. All rights reserved.
//

#import "BaseModel.h"



@implementation BaseModel

+ (id)model
{
    return [[[self class] alloc] init];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
} /* init */


- (void)load
{
}

- (void)unload
{
}

- (id)initWithDicionary:(NSDictionary *)dict
{
    self = [self init];
    if (self)
    {
        [self toEntityWithDict:dict];
    }
    return self;
}

- (id)initWithJSONStr:(NSString *)str
{
    self = [super init];
    if (self)
    {
        [self toEntityWithStr:str];
    }
    return self;
}

+ (NSMutableArray *) modelsByJSONArrayStr:(NSString *)str
{
    NSMutableArray *arrays = [NSMutableArray array];
    if (str == nil || [str isEqualToString:@""])
    {
        return arrays;
    }
    
    NSError *error;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    //    NSArray *array = [dict objectForKey:@"data"];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop)
     {
         [arrays addObject:[self toEntityByDict:obj]];
     }];
    
    return arrays;
}

+ (NSMutableArray *) modelsByDictionaryArray:(NSArray *)arr
{
    NSMutableArray *list= [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dic in arr)
    {
        id data = [[[self class] alloc] initWithDicionary:dic];
        [list addObject:data];
    }
    return list;
}

//- (NSString*) toJson{
//    NSError *error = nil;
//    NSString *jsonString;
//    NSDictionary *dict = [self toDictionary];
//    NSData *jsonData = [NSJSONSerialization
//                        dataWithJSONObject:dict
//                        options:NSJSONWritingPrettyPrinted
//                        error:&error];
//    if ([jsonData length] > 0 &&
//        error == nil){
//
//        jsonString = [[NSString alloc] initWithData:jsonData
//                                           encoding:NSUTF8StringEncoding];
//
//    }
//    //    jsonString = [dict JSONString];
//    return jsonString;
//}

//- (NSDictionary *)toDictionary
//{
//    NSMutableDictionary *props = [NSMutableDictionary dictionary];
//
//    return [self copyToDictionary:props class:[self class]];
//}
//
//- (NSDictionary *)copyToDictionary:(NSMutableDictionary *)props class:(Class)class
//{
//    if([[class superclass] isSubclassOfClass:[BaseModel class]])
//    {
//        [self copyToDictionary:props class:[class superclass]];
//    }
//
//    unsigned int outCount, i;
//    objc_property_t *properties = class_copyPropertyList(class, &outCount);
//    for (i = 0; i < outCount; i++) {
//        objc_property_t property = properties[i];
//        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
//        id propertyValue = [self valueForKey:(NSString *)propertyName];
//        //DLog(@"名称:%@--值:%@---属性:%@",propertyName,propertyValue,attr);
//        if ([propertyValue isKindOfClass:[NSArray class]])
//        {
//            NSArray *firstArray = (NSArray *)propertyValue;
//            NSMutableString *jsonString = [[NSMutableString alloc] initWithFormat:@"["];
//            for (int i = 0; i < [firstArray count]; i++) {
//                id model = firstArray[i];
//                if([model isKindOfClass:[BaseModel class]])
//                {
//                    NSString *string;
//                    //                    string  = [model toJson];
//                    //                    BaseModel *subModel = (BaseModel *)model;
//                    //                    NSDictionary *dict = subModel.keyValues;
//                    NSDictionary *dict = [model toDictionary];
//                    string = [dict JSONString];
//                    [jsonString appendString:string];
//                    [jsonString appendString:@","];
//
//                    // 处理json字符串
//                    NSString *character = nil;
//                    for (int i = 0; i < jsonString.length; i ++) {
//                        character = [jsonString substringWithRange:NSMakeRange(i, 1)];
//                        if ([character isEqualToString:@"\\"])
//                            [jsonString deleteCharactersInRange:NSMakeRange(i, 1)];
//                    }
//
//                    NSRange range1 = [jsonString rangeOfString:@"\"["];
//                    if ([jsonString rangeOfString:@"\"["].length > 0) {
//                        [jsonString deleteCharactersInRange:NSMakeRange(range1.location, 1)];
//                    }
//
//                    NSRange range2 = [jsonString rangeOfString:@"]\""];
//                    if ([jsonString rangeOfString:@"]\""].length > 0) {
//                        [jsonString deleteCharactersInRange:NSMakeRange(range2.location+1, 1)];
//                    }
//                }
//            }
//
//            if([jsonString length] == 1){
//                [jsonString appendString:@"]"];
//            } else {
//                NSUInteger location = [jsonString length]-1;
//                NSRange range       = NSMakeRange(location, 1);
//                [jsonString replaceCharactersInRange:range withString:@"]"];
//            }
//
//            propertyValue = jsonString;
//        }
//

//        if (propertyValue)
//            [props setObject:propertyValue forKey:propertyName];
//    }
//    free(properties);
//    return props;
//}

#pragma mark private
//通过jsonStr给对象赋值
- (void)toEntityWithStr:(NSString *)jsonStr
{
    if (jsonStr == nil || [jsonStr isEqualToString:@""])
    {
        return;
    }
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    [self toEntityWithDict:dict];
}

//通过NSDictionary给对象赋值
- (void)toEntityWithDict:(NSDictionary *)dict
{
    if (dict == nil)
    {
        return;
    }
    [self copyProperty:[self class] dict:dict];
}

- (void)copyProperty:(Class)class dict:(NSDictionary *)dict
{
    if([dict isKindOfClass:[NSNull class]])
    {
        return;
    }
    if([[class superclass] isSubclassOfClass:[BaseModel class]])
    {
        [self copyProperty:[class superclass] dict:dict];
    }
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSArray *propertyAttributes = [[NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding] componentsSeparatedByString:@","];
        
        id propertyObj = [dict objectForKey:propertyName]; //dict中的propertydict的值
        id propertyValue = [self valueForKey:propertyName]; //self中的property当前值
        
        //className格式如: T@"NSString"
        NSString *className = [[propertyAttributes objectAtIndex:0] stringByReplacingOccurrencesOfString:@"T@" withString:@""];
        className = [className stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        Class class = NSClassFromString(className);
        if ([class isSubclassOfClass:[BaseModel class]])
        {
            BaseModel *baseEntity = (BaseModel *)propertyValue;
            if (!baseEntity)  //如果对象的propertyValue为nil,那么我们需要初始化对象
            {
                baseEntity = [[class alloc] init];
            }
            
            [baseEntity toEntityWithDict:propertyObj];
            [self setValue:baseEntity forKey:propertyName];
        }
        else
        {
            if (propertyObj == [NSNull null] || [[propertyObj class] isKindOfClass:[NSNull class]])
            {
                // Do something for a null
                //DLog(@"haha=%@",propertyObj);
            }
            else if (propertyObj != nil && ![propertyObj  isEqual: @""])
            {
                [self setValue:propertyObj forKey:propertyName];
            }
        }
    }
    
    free(properties);
}

+ (BaseModel *)toEntityByDict:(NSDictionary *)dict
{
    BaseModel *model = [self model];
    if (dict == nil)
    {
        return model;
    }
    return [self copyProperty:model class:[self class] dict:dict];
}

+ (BaseModel *)copyProperty:(BaseModel *)model class:(Class)class dict:(NSDictionary *)dict
{
    // 给  ********************   model 配值？？？？？？？
    if([[class superclass] isSubclassOfClass:[BaseModel class]])
    {
        [self copyProperty:model class:[class superclass] dict:dict];
    }
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSArray *propertyAttributes = [[NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding] componentsSeparatedByString:@","];
        
        id propertyObj = [dict objectForKey:propertyName]; //dict中的propertydict的值
        id propertyValue = [model valueForKey:propertyName]; //self中的property当前值
        
        //className格式如: T@"NSString"
        NSString *className = [[propertyAttributes objectAtIndex:0] stringByReplacingOccurrencesOfString:@"T@" withString:@""];
        className = [className stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        Class class = NSClassFromString(className);
        if ([class isSubclassOfClass:[BaseModel class]])
        {
            BaseModel *baseEntity = (BaseModel *)propertyValue;
            if (!baseEntity)  //如果对象的propertyValue为nil,那么我们需要初始化对象
            {
                baseEntity = [[class alloc] init];
            }
            
            [baseEntity toEntityWithDict:propertyObj];
            [model setValue:baseEntity forKey:propertyName];
        }
        else
        {
            if (propertyObj == [NSNull null]|| [[propertyObj class] isKindOfClass:[NSNull class]])
            {
                
            }
            else if (propertyObj != nil && ![propertyObj  isEqual: @""]&& ![propertyObj  isEqual: @"null"])
            {
                [model setValue:propertyObj forKey:propertyName];
            }
        }
    }
    
    free(properties);
    return model;
}

@end
