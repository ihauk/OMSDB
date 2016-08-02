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
#import "OMSDBSQLQueue.h"
#import "OMSDBSQLMaker.h"

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
    [self.dbOperationQueue addOperation:queue];
    
}

#pragma mark -
#pragma mark - crud

- (BOOL)saveObject:(OMSDBObject*)object {
    
    object.operateType = enuObjectOperatTypeAdd;
    
    NSString*sqlStr = [object buildCreateSQLString];
    OMSDBSQLQueue *create = [[OMSDBSQLQueue alloc] initWithSQLStr:sqlStr];
    [_dbOperationQueue addOperation:create];
    
    OMSDBSQL *sqlObj = [object buildInsertSQL];
    sqlObj.dataObj = object;
    OMSDBSQLQueue *queue = [[OMSDBSQLQueue alloc] initWithSQLObj:sqlObj];
    [_dbOperationQueue addOperation:queue];
    
    return YES;
}


- (BOOL)deleteObject:(OMSDBObject*)object {
    
    return YES;
}

- (void)fetchObject:(OMSDBObject*)object {
    
    
}

- (BOOL)updateObject:(OMSDBObject*)object {
    
    return YES;
}

- (NSArray<OMSDBObject*> *)queryObjects:(Class)class {
    
    return nil;
}

#pragma mark -
#pragma mark - getter

-(NSOperationQueue *)dbOperationQueue {
    if (!_dbOperationQueue) {
        _dbOperationQueue = [[NSOperationQueue alloc] init];
        _dbOperationQueue.maxConcurrentOperationCount =1 ;
    }
    
    return _dbOperationQueue;
}


@end
