//
//  dbManager.m
//  cooperation
//
//  Created by 锦颐养老 on 16/10/25.
//  Copyright © 2016年 陕西大众健康投资管理有限公司. All rights reserved.
//
#define dbPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

#import "dbManager.h"
#import "DBHelper.h"
@implementation dbManager

+(instancetype)sharedDBManager
{
    static dbManager *_dbManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _dbManager = [[dbManager alloc] init];
    });
    
    return _dbManager;
}
#pragma mark - 创建表
//创建数据列表 根据列名数组创建
/**
 *  根据数据模型创建数据表
 *
 *  @param tableName  创建的表的名称
 *  @param cols       列名数组
 */
- (BOOL)createAllTableWithTableName:(NSString *)tableName
                       withColNames:(NSMutableArray *)cols
{
    //先移除再创建
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *fileName = [NSString stringWithFormat:@"/%@.db",tableName];
    NSString *path = [dbPath stringByAppendingPathComponent:fileName];
    [filemanager removeItemAtPath:path error:nil];
    
    FMDatabase *db = [DBHelper openAllDatabaseWithDbName:tableName];
    
    NSString *colName = @"";
    //拼接数据库每列的名称
    for (int i=0; i<cols.count; i++) {
        
        NSString *name = cols[i];
        colName = [NSString stringWithFormat:@"%@,%@ varchar",colName,name];
        
    }
    NSString *user = [NSString stringWithFormat:@"create table if not exists %@(id integer autoincre ment primary key%@);",tableName,colName];
    BOOL result = [db executeUpdate:user];
    [db close];
    if (result )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
#pragma mark - 数据库插入数据
/**
 * 数据库插入数据
 *
 *  @param tableName  创建的表的名称
 *  @param colNames   表头每列的名称数组
 *  @param  dataArr    要插入的数据数组
 */
- (BOOL )insertDataWithTableName:(NSString *)tableName
                    withColNames:(NSArray *)colNames
                     withDataArr:(NSArray *)dataArr
{
    FMDatabase *db = [DBHelper openAllDatabaseWithDbName:tableName];
    
    NSString *colName = colNames[0];
    NSString *values = @"?";
    
    //拼接数据库每列的名称
    if (colNames.count>1) {
        
        for (int i =1; i<colNames.count;i++) {
            colName = [NSString stringWithFormat:@"%@,%@",colName,colNames[i]];
            values = [NSString stringWithFormat:@"%@,?",values];
        }
    }
    BOOL result = [db executeUpdate:[NSString stringWithFormat:@"insert into %@(%@) values (%@);",tableName,colName,values]withArgumentsInArray:dataArr];
    
    return result;
}
/**
 * 数据库插入数据 根据数据字典
 *
 *  @param tableName  创建的表的名称
 *  @param  dic       要插入的数据字典
 */
- (BOOL )insertDataWithTableName:(NSString *)tableName withDataDic:(NSMutableDictionary *)dic
{
    FMDatabase *db = [DBHelper openAllDatabaseWithDbName:tableName];
    
    NSMutableArray *keyArr = [NSMutableArray array];
    NSMutableArray *objArr = [NSMutableArray array];
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [keyArr addObject:key];
        [objArr addObject:obj];
    }];
    
    NSString *colName = keyArr[0];
    NSString *values = @"?";
    
    //拼接数据库每列的名称
    if (keyArr.count>1) {
        
        for (int i =1; i<keyArr.count;i++) {
            colName = [NSString stringWithFormat:@"%@,%@",colName,keyArr[i]];
            values = [NSString stringWithFormat:@"%@,?",values];
        }
    }
    BOOL result = [db executeUpdate:[NSString stringWithFormat:@"insert into %@(%@) values (%@);",tableName,colName,values]withArgumentsInArray:objArr];
    
    return result;
}

#pragma mark - 数据库查询一条数据
/**
 * 数据库查询一条数据 根据列名称数组获取数据
 *
 *  @param tableName 要查询的表的名称
 *  @param colName   要查询的列名称
 *  @param colData   要查询的列数据
 *  @param cols      列名称数组
 */
- (NSMutableDictionary *)searchDataWithTableName:(NSString *)tableName
                                   withSearchCol:(NSString *)colName
                               WithSearchColData:(NSString *)colData
                                    withColNames:(NSMutableArray *)cols
{
    FMDatabase *db = [DBHelper openAllDatabaseWithDbName:tableName];
    //执行查询语句
    
    NSString *QueryStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?",tableName,colName];
    FMResultSet *result = [db executeQuery:QueryStr,colData];

    NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
    while (result.next)
    {
        for (int i=0; i<cols.count; i++) {
            
            NSString *name = cols[i];
            
            id colData = [result stringForColumn:name];
            
            NSLog(@"%@===%@",colData,name);
            
            [returnDic setValue:colData forKey:name];
            
        }
    }
    return returnDic;
}
/**
 * 数据库多条件查询数据 根据键值对获取数据
 *
 *  @param tableName 要查询的表的名称
 *  @param valueDic  基准键值对
 *  @param cols      列名称数组
 */
- (NSMutableArray *)searchDataWithTableName:(NSString *)tableName
                              withSearchColDateDic:(NSDictionary *)valueDic
                               withTableColNames:(NSMutableArray *)cols
{
    FMDatabase *db = [DBHelper openAllDatabaseWithDbName:tableName];
    
    //执行查询语句
    NSString *QueryStr = nil;
    FMResultSet *result = nil;
    if (valueDic.allKeys ==1) {
        
        QueryStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",tableName,[valueDic.allKeys firstObject],[valueDic.allValues firstObject]];
        result = [db executeQuery:QueryStr];
        
    }else{
        QueryStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",tableName,[valueDic.allKeys firstObject],[valueDic.allValues firstObject]];
        for (int i =1; i< valueDic.allKeys.count; i++) {
            
            QueryStr = [NSString stringWithFormat:@"%@ and %@ = '%@'",QueryStr,valueDic.allKeys[i],valueDic.allValues[i]];
        }
        result = [db executeQuery:QueryStr];
    }
    
    NSMutableArray *resultArr = [NSMutableArray array];
    while (result.next)
    {
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        for (int i=0; i<cols.count; i++) {
            
            NSString *name = cols[i];
            id colData = [result stringForColumn:name];
            
            [returnDic setValue:colData forKey:name];
        }
        [resultArr addObject:returnDic];
    }
    NSLog(@"resultArr==%@",resultArr);
    return resultArr;
}
#pragma mark - 数据库查询所有数据
/**
 * 数据库根据列数组获取所有数据
 *
 *  @param tableName 要查询的表的名称
 *  @param cols      每列名称的数组
 */
- (NSMutableArray *)searchAllWithTableName:(NSString *)tableName
                              withColNames:(NSMutableArray *)cols
{
    FMDatabase *db = [DBHelper openAllDatabaseWithDbName:tableName];
    //执行查询语句
    FMResultSet *result = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",tableName]];
    
    NSMutableArray *users = [[NSMutableArray alloc]init];
    
    while (result.next)
    {
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionary];
        
        for (int i=0; i<cols.count; i++) {
            NSString *name = cols[i];
            id colData = [result stringForColumn:name];
            [returnDic setValue:colData forKey:name];
        }
        [users addObject:returnDic];
    }
    return users;
}
#pragma mark - 更新数据
/**
 * 数据库根据列数组更新数据
 *
 *  @param tableName 要更新的表的名称
 *  @param valueDic      查找基准键值对
 *  @param newValueDic   更新数据键值对
 */
- (BOOL)updataWithTableName:(NSString *)tableName
       withSearchColDateDic:(NSDictionary *)valueDic
        withNewColDateDic:(NSDictionary *)newValueDic
{
    FMDatabase *db = [DBHelper openAllDatabaseWithDbName:tableName];
    //执行查询语句
    NSString *QueryStr = nil;
    BOOL update = NO;
    if (valueDic.allKeys ==1) {
        
        QueryStr = [NSString stringWithFormat:@"update %@ set %@ = '%@' WHERE %@ = '%@'",tableName,[newValueDic.allKeys firstObject],[newValueDic.allValues firstObject],[valueDic.allKeys firstObject],[valueDic.allValues firstObject]];
        update = [db executeUpdate:QueryStr];
        
    }else{
        QueryStr = [NSString stringWithFormat:@"update %@ set %@ = '%@' WHERE %@ = '%@'",tableName,[newValueDic.allKeys firstObject],[newValueDic.allValues firstObject],[valueDic.allKeys firstObject],[valueDic.allValues firstObject]];
        for (int i =1; i< valueDic.allKeys.count; i++) {
            
            QueryStr = [NSString stringWithFormat:@"%@ and %@ = '%@'",QueryStr,valueDic.allKeys[i],valueDic.allValues[i]];
        }
        update = [db executeUpdate:QueryStr];
    }
    return update;

}
#pragma mark - 删除数据库数据
/**
 * 删除数据库
 *
 *  @param tableName 要删除的表的名称
 */
- (void)deleteAllWithTableName:(NSString *)tableName
{
    FMDatabase *db = [DBHelper openAllDatabaseWithDbName:tableName];
    [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@",tableName]];
}
#pragma mark - 删除数据库一条数据

/**
 * 根据列名称删除数据库一条数据
 *
 *  @param tableName 要删除的表的名称
 */
- (void)deleteWithTableName:(NSString *)tableName
                withColName:(NSString *)colName
                withColData:(id)data
{
    FMDatabase *db = [DBHelper openAllDatabaseWithDbName:tableName];
    
    [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@= ?",tableName,colName],[NSString stringWithFormat:@"%@",data]];
    [db close];
}

/**
 * 根据多值查询、删除数据库一条数据
 *
 *  @param tableName 要删除的表的名称
 *  @param valueDic  查询基准键值对
 */
- (void)deleteWithTableName:(NSString *)tableName
                withSearchColDateDic:(NSDictionary *)valueDic
{
    FMDatabase *db = [DBHelper openAllDatabaseWithDbName:tableName];
    
    //执行查询语句
    NSString *QueryStr = nil;
    FMResultSet *result = nil;
    if (valueDic.allKeys ==1) {
        
        QueryStr = [NSString stringWithFormat:@"DELETE  FROM %@ WHERE %@ = '%@'",tableName,[valueDic.allKeys firstObject],[valueDic.allValues firstObject]];
        [db executeUpdate:QueryStr];
        
    }else{
        QueryStr = [NSString stringWithFormat:@"DELETE  FROM %@ WHERE %@ = '%@'",tableName,[valueDic.allKeys firstObject],[valueDic.allValues firstObject]];
        for (int i =1; i< valueDic.allKeys.count; i++) {
            
            QueryStr = [NSString stringWithFormat:@"%@ and %@ = '%@'",QueryStr,valueDic.allKeys[i],valueDic.allValues[i]];
        }
        [db executeUpdate:QueryStr];
    }
    [db close];
}



@end
