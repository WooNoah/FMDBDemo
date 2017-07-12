//
//  DDDatabase.h
//  BGFMDB
//
//  Created by 吴迪 on 17/7/12.
//  Copyright © 2017年 Biao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDDatabase : NSObject

/**
 *  创建单例
 */
+ (instancetype)shareInstance;

/**
 *  是否存在某个表
 */
- (BOOL)isExistTable:(NSString *)tableName;

/**
 *  创建表
 *  默认创建主键id
 *  @[@"name text NOT NULL",@"age integer NOT NULL"]
 */
- (BOOL)createTableWithName:(NSString *)tbName KeysCondition:(NSArray *)conditions;


/**
 *  插入数据
 */
- (BOOL)insertIntoTable:(NSString *)tbName Datas:(NSDictionary *)keyValPair;

/**
 *  更新某项数据
 *  keyValPair 传字典  @{@"name":@"1111",@"age":@(10)}
 *  where 传条件语句   @"age > 12 and age < 15"
 *  UPDATE t_student SET name = 'liwx' WHERE age > 12 AND age < 15;"
 */
- (BOOL)updateTableName:(NSString *)tbName Datas:(NSDictionary *)keyValPair where:(NSString *)conditionString;


/**
 *  删除某表中指定数据
 *  conditions 传条件语句  @"age > 12 and age < 15"
 */
- (BOOL)deleteDataInTable:(NSString *)tbName where:(NSString *)conditionString;

/**
 *  删除指定表中所有数据
 */
- (BOOL)deleteAllDatasInTableName:(NSString *)tbName;

/**
 *  drop表单
 */
- (BOOL)dropTable:(NSString *)tbName;

/**
 *  查询数据
 */
- (NSArray *)queryDatasInTable:(NSString *)tbName keys:(NSArray *)keys where:(NSString *)conditionString;

/**
 *  全部查询
 */
- (NSArray*)queryWithTableName:(NSString*)name;


@end
