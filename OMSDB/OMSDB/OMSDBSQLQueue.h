//
//  OMSDBSQLQueue.h
//  OMSDB
//
//  Created by zhuhao on 16/8/1.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMSDBSQLMaker.h"

@interface OMSDBSQLQueue : NSOperation

-(instancetype)initWithSQLStr:(NSString*)sqlStr;

-(instancetype)initWithSQLObj:(OMSDBSQL*)sqlobj;

-(instancetype)initWithDBPath:(NSString*)dbPath;

@end
