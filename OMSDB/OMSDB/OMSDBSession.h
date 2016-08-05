//
//  OMSDBSession.h
//  OMSDB
//
//  Created by zhuhao on 16/7/30.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMSDBSQLQueue.h"
@class OMSDBObject;


@interface OMSDBSession : NSObject

+ (instancetype)sharedInstance;

- (void)configDBSessionWithPath:(NSString*)dbPath dbName:(NSString*)dbName;


//insert

- (BOOL)saveObject:(OMSDBObject*)object;

//delete

- (BOOL)deleteObject:(OMSDBObject*)object;

- (BOOL)deleteTableWithObjectClass:(Class)className;


//select

- (OMSDBObject*)fetchObject:(OMSDBObject*)object
                  completed:(FetchCompletedBlock)complete;

- (OMSDBObject*)fetchObjectsFromClass:(Class)className
                  completed:(FetchCompletedBlock)complete;


//update

- (BOOL)updateObject:(OMSDBObject*)object;

@end
