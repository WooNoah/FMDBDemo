//
//  ViewController.m
//  FMDBDemo
//
//  Created by 吴迪 on 17/7/12.
//  Copyright © 2017年 No. All rights reserved.
//

#import "ViewController.h"

#import "StudentModel.h"

#import "DDDatabase.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *button1;

@property (strong, nonatomic) DDDatabase *db;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    //1.获得数据库文件的路径
    NSString *doc =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)  lastObject];
    NSLog(@"sandbox path:%@",doc);
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"student.sqlite"];
    
    
    self.db = [DDDatabase shareInstance];
    
    if ([self.db isExistTable:@"t_student"]) {
        NSLog(@"存在t_student表");
    }else {
        NSLog(@"不存在");
    }
    
    
    
    
//    //2.获得数据库
//    self.db = [FMDatabase databaseWithPath:fileName];
//    
//    //3.使用如下语句，如果打开失败，可能是权限不足或者资源不足。通常打开完操作操作后，需要调用 close 方法来关闭数据库。在和数据库交互 之前，数据库必须是打开的。如果资源或权限不足无法打开或创建数据库，都会导致打开失败。
//    if ([self.db open])
//    {
//        NSLog(@"open成功");
//        
//        //4.创表
//        BOOL result = [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_student (id integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age integer NOT NULL);"];
//        if (result)
//        {
//            NSLog(@"创建表成功");
//        }
//    }
    
    

    
}

- (IBAction)queryOrdered:(id)sender {
    NSArray *arr = [self.db queryDatasInTable:@"t_student" keys:@[@"id",@"name",@"age"] where:@"age > 20 AND age < 30"];
    NSLog(@"20 - 30:\n%@",arr);
}


- (IBAction)queryAction:(id)sender {
    // 查询数据
//    FMResultSet *rs = [self.db executeQuery:@"SELECT * FROM t_student"];
//    
//    // 遍历结果集
//    while ([rs next]) {
//        NSString *name = [rs stringForColumn:@"name"];
//        int age = [rs intForColumn:@"age"];
//        NSLog(@"name:%@\r\n",name);
//        NSLog(@"age:%d\r\n",age);
//    }
    
    NSArray *result = [self.db queryWithTableName:@"t_student"];
    NSLog(@"all:%@",result);
}

- (IBAction)insertAction:(id)sender {
    int age = arc4random()%90 + 10;
    NSString *name = @"wudi";
    
    NSDictionary *data = @{@"name":name,@"age":@(age)};
    
    
    if([self.db insertIntoTable:@"t_student" Datas:data]) {
        NSLog(@"插入成功");
    }else {
        NSLog(@"插入失败");
    }
    
    //1.executeUpdate:不确定的参数用？来占位（后面参数必须是oc对象，；代表语句结束）
//    if ([self.db executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?,?);",name,@(age)]) {
//        NSLog(@"insert success");
//    }
    
    //2.executeUpdateWithForamat：不确定的参数用%@，%d等来占位 （参数为原始数据类型，执行语句不区分大小写）
//    [self.db executeUpdateWithForamat:@"insert into t_student (name,age) values (%@,%i);",name,age];
//    
//    //3.参数是数组的使用方式
//    [self.db executeUpdate:@"INSERT INTO t_student(name,age) VALUES  (?,?);"withArgumentsInArray:@[name,@(age)]];
    
}


- (IBAction)deleteAll:(id)sender {
    if ([self.db deleteAllDatasInTableName:@"t_student"]) {
        NSLog(@"suc");
    }else {
        NSLog(@"fail");
    }
}

- (IBAction)deleteUserWithID:(int)uid {
    if ([self.db deleteDataInTable:@"t_student" where:@"age < 50 OR AGE = 66"]) {
        NSLog(@"delete suc");
    }else {
        NSLog(@"delete fail");
    }
}

- (IBAction)updateUserInfo {
    NSDictionary *data = @{@"name":@"wkkkkj",@"age":@(66)};
    if ([self.db updateTableName:@"t_student" Datas:data where:@"name = 'wudi' and age < 50"]) {
        NSLog(@"更新成功");
    }else {
        NSLog(@"更新失败");
    }
    
//    if([self.db updateWithTableName:@"t_student" valueDict:data where:nil]) {
//        NSLog(@"更新成功");
//    }else {
//        NSLog(@"更新失败");
//    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
