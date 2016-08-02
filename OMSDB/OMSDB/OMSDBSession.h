//
//  OMSDBSession.h
//  OMSDB
//
//  Created by zhuhao on 16/7/30.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OMSDBObject;


@interface OMSDBSession : NSObject

+ (instancetype)sharedInstance;

- (void)configDBSessionWithPath:(NSString*)dbPath dbName:(NSString*)dbName;

- (BOOL)saveObject:(OMSDBObject*)object;

- (BOOL)deleteObject:(OMSDBObject*)object;

- (void)fetchObject:(OMSDBObject*)object;

- (BOOL)updateObject:(OMSDBObject*)object;

@end
