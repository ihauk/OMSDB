//
//  OMSDBSession.h
//  OMSDB
//
//  Created by zhuhao on 16/7/30.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMSDBSQLQueue.h"
#import "OMSDBObject.h"
#import "OMSDBCondition.h"
//@class OMSDBObject;


@interface OMSDBSession : NSObject

+ (instancetype)sharedInstance;

- (void)configDBSessionWithPath:(NSString*)dbPath dbName:(NSString*)dbName;


#pragma mark -
#pragma mark -  Insert

- (BOOL)saveObject:(OMSDBObject*)object;


#pragma mark -
#pragma mark - Delete

- (BOOL)deleteObject:(OMSDBObject*)object;

- (BOOL)deleteTableWithObjectClass:(Class)className;


#pragma mark -
#pragma mark - Select

- (OMSDBObject*)fetchObject:(OMSDBObject*)object
                  completed:(FetchCompletedBlock)complete;

- (OMSDBObject*)fetchObjectsFromClass:(Class)className
                  completed:(FetchCompletedBlock)complete;

- (void)fetchObjectsFromClass:(Class)className
                           conditions:(NSArray<OMSDBCondition*>*)conditions
                            completed:(FetchCompletedBlock)complete;


#pragma mark -
#pragma mark - Update

- (BOOL)updateObject:(OMSDBObject*)object;


#pragma mark -
#pragma mark - SQL

- (void)exxcuteCustomSQL:(NSString*)sqlStr;

@end
