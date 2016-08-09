//
//  OMSDBTests.m
//  OMSDBTests
//
//  Created by zhuhao on 16/8/5.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UserObject.h"
#import "OMSDBSession.h"
#import "OMSDBCondition.h"

@interface OMSDBTests : XCTestCase

@end

@implementation OMSDBTests

- (void)setUp {
    [super setUp];
    NSLog(@"**setUp");
    
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentsPath = [documentsPath stringByAppendingPathComponent:@"DB"];
    
    [[OMSDBSession sharedInstance] configDBSessionWithPath:documentsPath dbName:@"db.db"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
//    NSString*sqlStr = [[[UserObject alloc]init] buildCreateSQLString];
//    OMSDBSQLQueue *create = [[OMSDBSQLQueue alloc] initWithSQLStr:sqlStr];
//    [self addOperationToQueue:create];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    NSLog(@"**tearDown");
}


//- (void)test0Insert {
//    for (int i = 0; i < 200; i++) {
//        
//        UserObject *obj = [[UserObject alloc] init];
//        obj.userName = @"hauk";
//        obj.pwd = @"www.com";
//        obj.age = i;
//        obj.sex = i%2;
//        obj.birthday = @"sss";
//        
//        [[OMSDBSession sharedInstance] saveObject:obj];
////        sleep(1);
//    }
//}



//- (void)testDeleObj {
//    
//    UserObject *deleObj = [[UserObject alloc] init];
//    
//    [deleObj markPropertyAsQuery:@"userName" value:@"hauk"];
//    [deleObj markPropertyAsQuery:@"sex" value:@1];
//    [[OMSDBSession sharedInstance] deleteObject:deleObj];
//}



//- (void)testDeleTable {
//    
//    [[OMSDBSession sharedInstance] deleteTableWithObjectClass:[UserObject class]];
//}


//- (void)testSelectObj {
//    UserObject *fo = [[UserObject alloc]init];
////    fo.userName = @"duola";
////    fo.sex = 2;
//    [fo markPropertyAsQuery:@"userName" value:@"duola"];
//    [fo markPropertyAsQuery:@"sex" value:@2];
//    
//    [[OMSDBSession sharedInstance] fetchObject:fo completed:^(NSArray<OMSDBObject *> *obj, NSError *error) {
//        NSLog(@"getch single obj %@",obj);
//    }];
//}


//- (void)testSelectTables {
//
//    [[OMSDBSession sharedInstance] fetchObjectsFromClass:[UserObject class] completed:^(NSArray<OMSDBObject *> *obj, NSError *error) {
//
//    }];
//}


- (void)testConditionSelect {
    
    OMSDBCondition *con1 = [UserObject makeConditionWithPropertyName:@"age" value:@11 operater:@"<" ];
    OMSDBCondition *con2 = [UserObject makeOerderConditionWithPropertyName:@"age" orderByASC:NO];
    OMSDBCondition *con4 = [UserObject makeOerderConditionWithPropertyName:@"sex" orderByASC:YES];
    OMSDBCondition *con3 = [UserObject makeConditionWithPropertyName:@"userName" value:@"hauk" operater:@"="];
    
    [[OMSDBSession sharedInstance] fetchObjectsFromClass:[UserObject class] conditions:@[con1,con4,con3,con2] completed:^(NSArray<OMSDBObject *> *array, NSError *error) {
        NSLog(@"----- %@",array);
    }];
}


//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    NSLog(@"**testPerformanceExample");
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
