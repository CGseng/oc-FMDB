//
//  DBHelper.m
//  cooperation
//
//  Created by 锦颐养老 on 16/10/26.
//  Copyright © 2016年 陕西大众健康投资管理有限公司. All rights reserved.
//
#define dbPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

#import "DBHelper.h"

@implementation DBHelper
//根据名称创建数据库
+(FMDatabase *)openAllDatabaseWithDbName:(NSString *)name
{
    NSString *fileName = [NSString stringWithFormat:@"/%@.db",name];
    NSString *path = [dbPath stringByAppendingPathComponent:fileName];
    FMDatabase *db = [FMDatabase databaseWithPath:path];
    //数据库设置缓存 
    [db setShouldCacheStatements:YES];    
    if (![db open]) {
        NSLog(@"Could not open db.%@",name);
        return nil;
    }else{
        return db;
    }
}

@end
