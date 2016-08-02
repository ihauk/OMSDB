//
//  OMSDBSQLMaker.m
//  OMSDB
//
//  Created by zhuhao on 16/8/1.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import "OMSDBSQLMaker.h"

@implementation OMSDBSQLParam

@end


@implementation OMSDBSQL

-(NSMutableArray<OMSDBSQLParam *> *)paramArrray {
    if (!_paramArrray) {
        _paramArrray = [NSMutableArray array];
    }
    
    return _paramArrray;
}



@end


@implementation OMSDBSQLMaker

@end
