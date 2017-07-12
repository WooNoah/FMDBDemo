//
//  StudentModel.h
//  FMDBDemo
//
//  Created by 吴迪 on 17/7/12.
//  Copyright © 2017年 No. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StudentModel : NSObject


@property (assign, nonatomic) int id;

@property (nonatomic,copy) NSString *name;

@property (nonatomic,copy) NSString *gender;

@property (assign, nonatomic) int age;

@end
