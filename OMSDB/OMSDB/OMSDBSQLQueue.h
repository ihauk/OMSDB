//
//  OMSDBSQLQueue.h
//  OMSDB
//
//  Created by zhuhao on 16/8/1.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMSDBSQLMaker.h"

typedef NS_ENUM(NSUInteger, OMSDBSQLQueueType) {
    enuSQLQueueTypeOpenDB,
    enuSQLQueueTypeCloseDB,
    enuSQLQueueTypeExecuteSqlString,
    enuSQLQueueTypeSQLSelect
};

typedef void(^FetchCompletedBlock)(NSArray<OMSDBObject*>* obj,NSError *error);



@interface OMSDBSQLQueue : NSOperation

@property(nonatomic,copy) FetchCompletedBlock completeBlock;

-(instancetype)initWithSQLStr:(NSString*)sqlStr;

-(instancetype)initWithSQLStr:(NSString*)sqlStr
                 sqlQueueType:(OMSDBSQLQueueType)queueType
                   objectType:(Class)classType
                     complete:(FetchCompletedBlock)complete;

-(instancetype)initWithDBPath:(NSString*)dbPath;

@end
