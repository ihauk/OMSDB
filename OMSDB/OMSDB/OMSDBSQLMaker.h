//
//  OMSDBSQLMaker.h
//  OMSDB
//
//  Created by zhuhao on 16/8/1.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMSDBObject.h"

@interface OMSDBSQLParam : NSObject

@property(nonatomic,assign) NSInteger index;
@property(nonatomic,strong) NSString *tableField;
@property(nonatomic,strong) NSString *propertyName;
@property(nonatomic,strong) NSString *fieldType;

@end

@interface OMSDBSQL : NSObject

@property(nonatomic,strong) NSString *headerCmdSQL;
@property(nonatomic,strong) NSMutableArray<OMSDBSQLParam*> *paramArrray;
@property(nonatomic,strong) OMSDBObject *dataObj;
@end

@interface OMSDBSQLMaker : NSObject

@end
