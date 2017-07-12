//
//  DDDatabase.m
//  BGFMDB
//
//  Created by 吴迪 on 17/7/12.
//  Copyright © 2017年 Biao. All rights reserved.
//

#import "DDDatabase.h"
#import "FMDB.h"

#define SQLITE_NAME @"student.sqlite"


#warning 键值只能传NSString
@interface DDDatabase()

@property (nonatomic, strong) FMDatabaseQueue *queue;

@end

static DDDatabase *_dbInstance;
@implementation DDDatabase


+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dbInstance = [[self alloc]init];
    });
    return _dbInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        NSString *filename = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:SQLITE_NAME];
        
        self.queue = [FMDatabaseQueue databaseQueueWithPath:filename];
    }
    return self;
}

- (BOOL)isExistTable:(NSString *)tableName {
    if (tableName==nil){
        NSLog(@"表名不能为空!");
        return NO;
    }
    __block BOOL result;
    [self.queue inDatabase:^(FMDatabase *db) {
        result = [db tableExists:tableName];
    }];
    return result;
}

- (BOOL)createTableWithName:(NSString *)tbName KeysCondition:(NSArray *)conditions {
    if (tbName == nil) {
        NSLog(@"表明不能为空");
        return NO;
    }
    if (conditions.count == 0) {
        NSLog(@"字段数组不能为空!");
        return NO;
    }
    
    __block BOOL result;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString *header = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement",tbName];
        
        NSMutableString *sql = [NSMutableString string];
        [sql appendString:header];
        
        if (conditions.count > 1) {
            for (int i = 0; i < conditions.count; i++) {
                [sql appendFormat:@", %@",conditions[i]];
                if (i==(conditions.count - 1)) {
                    [sql appendString:@");"];
                }
            }
        }else {
            [sql appendFormat:@", %@);",conditions[0]];
        }
        result = [db executeUpdate:sql];
    }];
    return result;
}


- (BOOL)insertIntoTable:(NSString *)tbName Datas:(NSDictionary *)keyValPair {
    if (tbName == nil) {
        NSLog(@"表名不能为空!");
        return NO;
    }
    if (keyValPair == nil){
        NSLog(@"插入值字典不能为空!");
        return NO;
    }
    
    __block BOOL result;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSMutableString *sql = [NSMutableString string];
        [sql appendFormat:@"insert into %@ (",tbName];
        
        NSArray *keys = [keyValPair allKeys];
        NSArray *values = [keyValPair allValues];
        for (int i = 0; i < keys.count; i++) {
            
            if (i == (keys.count - 1)) {
                [sql appendFormat:@"%@) values (",keys[i]];
            }else {
                [sql appendFormat:@"%@,",keys[i]];
            }
        }
        
        for (int i = 0; i < values.count; i++) {
            if (i == (values.count - 1)) {
                [sql appendFormat:@" ?);"];
            }else {
                [sql appendFormat:@" ?,"];
            }
        }
        
        result = [db executeUpdate:sql withArgumentsInArray:values];
    }];
    return result;
}


- (BOOL)updateTableName:(NSString *)tbName Datas:(NSDictionary *)keyValPair where:(NSString *)conditionStr {
    if (tbName == nil) {
        NSLog(@"表名不能为空!");
        return NO;
    }
    if (keyValPair == nil){
        NSLog(@"更新值不能为空!");
        return NO;
    }
    
    __block BOOL result;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSMutableString *sql = [NSMutableString string];
        [sql appendFormat:@"update %@ set ",tbName];
        for (int i = 0; i < [keyValPair allKeys].count; i++) {
            [sql appendFormat:@"%@='%@'",keyValPair.allKeys[i],keyValPair[keyValPair.allKeys[i]]];
            if (i == ([keyValPair allKeys].count - 1)) {
                [sql appendString:@" "];
            }else {
                [sql appendString:@","];
            }
        }
        if (conditionStr != nil && ![conditionStr isEqualToString:@""]) {
            [sql appendFormat:@"WHERE %@;",conditionStr];
        }
        result = [db executeUpdate:sql];
    }];
    return result;
}

- (BOOL)deleteDataInTable:(NSString *)tbName where:(NSString *)conditionString {
    if (tbName == nil) {
        NSLog(@"表名不能为空!");
        return NO;
    }
    if ([conditionString isEqualToString:@""] || conditionString == nil){
        NSLog(@"条件语句错误!");
        return NO;
    }
    
    __block BOOL result;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSMutableString *sql = [NSMutableString string];
        [sql appendFormat:@"delete from %@ where %@;",tbName,conditionString];
        
        result = [db executeUpdate:sql];
    }];
    return result;
}

- (BOOL)deleteAllDatasInTableName:(NSString *)tbName {
    if (tbName == nil){
        NSLog(@"表名不能为空!");
        return NO;
    }
    __block BOOL result;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString* SQL = [NSString stringWithFormat:@"delete from %@;",tbName];
        result = [db executeUpdate:SQL];
    }];
    return result;
}

- (BOOL)dropTable:(NSString *)tbName {
    if (tbName == nil){
        NSLog(@"表名不能为空!");
        return NO;
    }
    __block BOOL result;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString* SQL = [NSString stringWithFormat:@"drop table %@;",tbName];
        result = [db executeUpdate:SQL];
    }];
    return result;
}


- (NSArray *)queryDatasInTable:(NSString *)tbName keys:(NSArray *)keys where:(NSString *)conditionString {
    if (tbName == nil) {
        NSLog(@"表名不能为空!");
        return nil;
    }
    if ([conditionString isEqualToString:@""] || conditionString == nil){
        NSLog(@"条件语句错误!");
        return NO;
    }
    
    __block NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:0];
    [self.queue inDatabase:^(FMDatabase *db) {
        NSMutableString *SQL = [NSMutableString string];
        [SQL appendString:@"select "];
        for(int i=0;i<keys.count;i++){
            [SQL appendFormat:@"%@",keys[i]];
            if (i != (keys.count-1)) {
                [SQL appendString:@","];
            }
        }
        [SQL appendFormat:@" from %@ where %@;",tbName,conditionString];
        
        // 1.查询数据
        FMResultSet *rs = [db executeQuery:SQL];
        // 2.遍历结果集
        while (rs.next) {
            NSMutableDictionary* dictM = [[NSMutableDictionary alloc] init];
            for(int i=0;i<keys.count;i++){
                dictM[keys[i]] = [rs stringForColumn:keys[i]];
            }
            [arrM addObject:dictM];
        }
    }];
    return arrM;
}


/**
 全部查询
 */
- (NSArray*)queryWithTableName:(NSString*)name {
    if (name==nil){
        NSLog(@"表名不能为空!");
        return nil;
    }
    
    __block NSMutableArray* arrM = [[NSMutableArray alloc] init];
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString* SQL = [NSString stringWithFormat:@"select * from %@",name];
        // 1.查询数据
        FMResultSet *rs = [db executeQuery:SQL];
        // 2.遍历结果集
        while (rs.next) {
            NSMutableDictionary* dictM = [[NSMutableDictionary alloc] init];
            for (int i=0;i<[[[rs columnNameToIndexMap] allKeys] count];i++) {
                dictM[[rs columnNameForIndex:i]] = [rs stringForColumnIndex:i];
            }
            [arrM addObject:dictM];
        }
    }];
    //NSLog(@"查询 -- %@",arrM);
    return arrM;
    
}



@end
