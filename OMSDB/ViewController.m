//
//  ViewController.m
//  OMSDB
//
//  Created by zhuhao on 16/7/30.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import "ViewController.h"
#import "UserObject.h"
#import "OMSDBSession.h"

#define varString(var) [NSString stringWithFormat:@"%s",#var]
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UserObject *obj = [[UserObject alloc] init];
    obj.userName = @"hauk";
    obj.pwd = @"www.com";
    obj.age = 10;
    obj.sex = 1;
    obj.birthday = @"sss";
//    [obj propertyNameMappedDBTableFileds];
//    [obj getProrertyList];
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    documentsPath = [documentsPath stringByAppendingPathComponent:@"DB"];
    
    [[OMSDBSession sharedInstance] configDBSessionWithPath:documentsPath dbName:@"db.db"];
    
    
    [[OMSDBSession sharedInstance] saveObject:obj];
//    [[OMSDBSession sharedInstance] fetchObjectsFromClass:[UserObject class] completed:^(NSArray<OMSDBObject *> *obj, NSError *error) {
//        
//    }];
    
    
    
    UserObject *fo = [[UserObject alloc]init];
    fo.userName = @"duola";
    fo.sex = 2;
    [fo markPropertyAsQuery:@"userName"];
    [fo markPropertyAsQuery:@"sex"];
    
    [[OMSDBSession sharedInstance] fetchObject:fo completed:^(NSArray<OMSDBObject *> *obj, NSError *error) {
        
    }];
    
//    UserObject *deleObj = [[UserObject alloc] init];
//    deleObj.userName = @"hauk";
//    deleObj.sex = 1;
//    [deleObj markPropertyAsQuery:@"userName"];
//    [deleObj markPropertyAsQuery:@"sex"];
//    [[OMSDBSession sharedInstance] deleteObject:deleObj];
    
    [[OMSDBSession sharedInstance] deleteTableWithObjectClass:[UserObject class]];
    
}


@end
