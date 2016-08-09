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
    
//    OMSDBCondition *con1 = [OMSDBCondition makeConditionWithPropertyName:@"age" value:@11 operater:@"<"];
//    
//    [[OMSDBSession sharedInstance] fetchObjectsFromClass:[UserObject class] conditions:@[con1] completed:^(NSArray<OMSDBObject *> *array, NSError *error) {
//        NSLog(@"----- %@",array);
//    }];
}


@end
