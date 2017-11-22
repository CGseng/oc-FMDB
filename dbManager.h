//
//  dbManager.h
//  cooperation
//
//  Created by 锦颐养老 on 16/10/25.
//  Copyright © 2016年 陕西大众健康投资管理有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@class dbAllModel;
@class newsModel;
@interface dbManager : NSObject

/*
 方法描述:
 单例模式创建对象
 返回结果:
 dbManager
 */
+ (instancetype)sharedDBManager;

#pragma mark - 创建数据库
/**
 方法说明:
 * 创建数据库表,这个方法一般在启动程序时调用。appdelegate中调用
 *  根据数据模型创建数据表
 *
 *  @param tableName  创建的表的名称
 *  @param cols       列名数组
 */
- (BOOL)createAllTableWithTableName:(NSString *)tableName
                       withColNames:(NSMutableArray *)cols;

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
                     withDataArr:(NSArray *)dataArr;
/**
 * 数据库插入数据 根据数据字典
 *
 *  @param tableName  创建的表的名称
 *  @param  dic       要插入的数据字典
 */
- (BOOL )insertDataWithTableName:(NSString *)tableName
                     withDataDic:(NSMutableDictionary *)dic;


#pragma mark - 数据库查询数据
/**
 * 数据库查询数据 根据列名称数组获取数据
 *
 *  @param tableName 要查询的表的名称
 *  @param colName   要查询的列名称
 *  @param colData   要查询的列数据
 *  @param cols      列名称数组
 */
- (NSDictionary *)searchDataWithTableName:(NSString *)tableName
                                   withSearchCol:(NSString *)colName
                               WithSearchColData:(NSString *)colData
                                    withColNames:(NSMutableArray *)cols;
/**
 * 数据库多条件查询数据 根据键值对获取数据
 *
 *  @param tableName 要查询的表的名称
 *  @param valueDic  基准键值对
 *  @param cols      列名称数组
 */
- (NSMutableArray *)searchDataWithTableName:(NSString *)tableName
                       withSearchColDateDic:(NSDictionary *)valueDic
                          withTableColNames:(NSMutableArray *)cols;

/**
 * 数据库根据列数组获取所有数据
 *
 *  @param tableName 要查询的表的名称
 *  @param cols      每列名称的数组
 */
- (NSMutableArray *)searchAllWithTableName:(NSString *)tableName
                              withColNames:(NSMutableArray *)cols;

#pragma mark - 更新数据库
/**
 * 数据库根据列数组更新数据
 *
 *  @param tableName 要更新的表的名称
 *  @param valueDic      查找基准键值对
 *  @param newValueDic   更新数据键值对
 */
- (BOOL)updataWithTableName:(NSString *)tableName
       withSearchColDateDic:(NSDictionary *)valueDic
          withNewColDateDic:(NSDictionary *)newValueDic;

#pragma mark - 数据库删除数据
/**
 * 删除数据库
 *
 *  @param tableName 要删除的表的名称
 */
- (void)deleteAllWithTableName:(NSString *)tableName;
/**
 * 根据列名称删除数据库一条数据
 *
 *  @param tableName 要删除的表的名称
 */
- (void)deleteWithTableName:(NSString *)tableName
                withColName:(NSString *)colName
                withColData:(id)data;
/**
 * 根据多值查询、删除数据库一条数据
 *
 *  @param tableName 要删除的表的名称
 *  @param valueDic  查询基准键值对
 */
- (void)deleteWithTableName:(NSString *)tableName
       withSearchColDateDic:(NSDictionary *)valueDic;
@end

