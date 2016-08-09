//
//  OMSDBSession.m
//  OMSDB
//
//  Created by zhuhao on 16/7/30.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import "OMSDBSession.h"
#import "OMSDBObject.h"
#import <sqlite3.h>
#import "OMSDBSQLMaker.h"
#import "OMSDBCondition.h"

@interface OMSDBSession ()
//@property(nonatomic) sqlite3 *dbHandler;
@property(nonatomic,strong) NSOperationQueue *dbOperationQueue;
@property(nonatomic,strong) NSString *dbPath;
@property(nonatomic,strong) NSString *dbName;

@end

@implementation OMSDBSession

#pragma mark -
#pragma mark - init

+ (instancetype)sharedInstance {
    static OMSDBSession *s_classManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_classManager = [[ OMSDBSession alloc] init];
    });
    
    return s_classManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dbOperationQueue.name = @"COM.OMSDB.OPERATIONQUEUE";
    }
    return self;
}

- (void)configDBSessionWithPath:(NSString*)dbPath dbName:(NSString*)dbName {

    _dbName = dbName;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isExist = [fileManager fileExistsAtPath:dbPath isDirectory:&isDir];
    if (!(isExist && isDir)) {
        [fileManager createDirectoryAtPath:dbPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    _dbPath = [dbPath stringByAppendingString:[NSString stringWithFormat:@"/%@",_dbName]];
    
    OMSDBSQLQueue *queue = [[OMSDBSQLQueue alloc]initWithDBPath:_dbPath];
    [self addOperationToQueue:queue];
    
}

#pragma mark -
#pragma mark - insert

- (BOOL)saveObject:(OMSDBObject*)object {
    
//    NSString*sqlStr = [object buildCreateSQLString];
//    OMSDBSQLQueue *create = [[OMSDBSQLQueue alloc] initWithSQLStr:sqlStr];
//    [self addOperationToQueue:create];
    
    NSString *insertSql = [object buildInsertSQL];
    OMSDBSQLQueue *queue = [[OMSDBSQLQueue alloc] initWithSQLStr:insertSql];
    [self addOperationToQueue:queue];
    
    return YES;
}

#pragma mark -
#pragma mark - delete

- (BOOL)deleteObject:(OMSDBObject*)object {
    
    NSString *deleteSQL = [object buildDeleteObjectSQL];
    OMSDBSQLQueue *deleteQueue = [[OMSDBSQLQueue alloc] initWithSQLStr:deleteSQL];
    
    [self addOperationToQueue:deleteQueue];
    return YES;
}

-(BOOL)deleteTableWithObjectClass:(Class)className {
    NSString *deleteSQL = [[className class] buildDeleteAllObjectSQL];
    OMSDBSQLQueue *deleteQueue = [[OMSDBSQLQueue alloc] initWithSQLStr:deleteSQL];
    
    [self addOperationToQueue:deleteQueue];
    
    return YES;
}

#pragma mark -
#pragma mark - select

- (NSArray<OMSDBObject*> *)fetchObjectsFromClass:(Class)className completed:(FetchCompletedBlock)complete {
    
    NSString *sql = [[className class] buildSelectAllSQL];
    OMSDBSQLQueue *queue = [[OMSDBSQLQueue alloc] initWithSQLStr:sql
                                                    sqlQueueType:enuSQLQueueTypeSQLSelect
                                                      objectType:[className class]
                                                        complete:^(NSArray<OMSDBObject *> *arr, NSError *error) {
                                                          
                                                            if (complete) {
                                                                complete(arr,error);
                                                            }
                                                            NSLog(@"回来啦~");
                                                      }];
    
    [self addOperationToQueue:queue];
    
    return nil;
}


//FIXME: int 类型 初始化为 0 的问题
- (OMSDBObject*)fetchObject:(OMSDBObject*)object completed:(FetchCompletedBlock)complete{
    
    NSString *sql = [object buildFetchObjectSQL];
    OMSDBSQLQueue *queue = [[OMSDBSQLQueue alloc] initWithSQLStr:sql
                                                    sqlQueueType:enuSQLQueueTypeSQLSelect
                                                      objectType:[object class]
                                                        complete:^(NSArray<OMSDBObject *> *arr, NSError *error) {
                                                            
                                                            if (complete) {
                                                                complete(arr,error);
                                                            }
                                                            NSLog(@"回来啦~");
                                                        }];
    
    [self addOperationToQueue:queue];
    return object;
}

-(void )fetchObjectsFromClass:(Class)className conditions:(NSArray<OMSDBCondition*> *)conditions completed:(FetchCompletedBlock)complete {
    
    NSString *sql = [[className class] buildSelectAllSQL];
    
    if (conditions && conditions.count >= 1) {
        
        NSUInteger count = conditions.count;
        __block NSString *whereConditions = @"";
        __block NSString *orderConditions = @"";
        [conditions enumerateObjectsUsingBlock:^(OMSDBCondition * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.conditionType == enuConditionWhere) {
                whereConditions = [whereConditions stringByAppendingString:obj.conditionStr];
                
                    whereConditions = [whereConditions stringByAppendingString:@" and "];
                
            }
            if (obj.conditionType == enuConditionOrder) {
                orderConditions = [orderConditions stringByAppendingString:obj.conditionStr];
                
                    orderConditions = [orderConditions stringByAppendingString:@","];
                
            }
            
        }];
        
        sql = [sql stringByReplacingOccurrencesOfString:@";" withString:@" "];
        if (whereConditions.length > 0) {
            sql = [sql stringByAppendingString:@" where "];
            whereConditions = [whereConditions substringToIndex:whereConditions.length-4];
            sql = [sql stringByAppendingString:whereConditions];
        }
        if (orderConditions.length > 0) {
            sql = [sql stringByAppendingString:@" order by "];
            orderConditions = [orderConditions substringToIndex:orderConditions.length-1];
            sql = [sql stringByAppendingString:orderConditions];
        }
        
        sql = [sql stringByAppendingString:@";"];
    }
    
    OMSDBSQLQueue *queue = [[OMSDBSQLQueue alloc] initWithSQLStr:sql
                                                    sqlQueueType:enuSQLQueueTypeSQLSelect
                                                      objectType:[className class]
                                                        complete:^(NSArray<OMSDBObject *> *arr, NSError *error) {
                                                            
                                                            if (complete) {
                                                                complete(arr,error);
                                                            }
                                                            NSLog(@"回来啦~");
                                                        }];
    
    [self addOperationToQueue:queue];
}

#pragma mark -
#pragma mark - update


- (BOOL)updateObject:(OMSDBObject*)object {
    
    return YES;
}

#pragma mark -
#pragma mark - custom sql 

-(void)exxcuteCustomSQL:(NSString *)sqlStr {
    
}



#pragma mark -
#pragma mark - getter

-(NSOperationQueue *)dbOperationQueue {
    if (!_dbOperationQueue) {
        _dbOperationQueue = [[NSOperationQueue alloc] init];
        _dbOperationQueue.maxConcurrentOperationCount = 1 ;
    }
    
    return _dbOperationQueue;
}

- (void)addOperationToQueue:(NSOperation*)operation {
//    NSOperation* lastOp = self.dbOperationQueue.operations.lastObject;
//    if ( lastOp != nil ){
//        
//        [ operation addDependency: lastOp ];
//    }
    NSLog(@"add *");
    [self.dbOperationQueue addOperations:@[operation] waitUntilFinished:YES];
    
}


@end
