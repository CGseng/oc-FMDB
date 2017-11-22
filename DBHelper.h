//
//  DBHelper.h
//  cooperation
//
//  Created by 锦颐养老 on 16/10/26.
//  Copyright © 2016年 陕西大众健康投资管理有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
@interface DBHelper : NSObject
//根据名称创建数据库
+(FMDatabase *)openAllDatabaseWithDbName:(NSString *)name;

@end
