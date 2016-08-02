//
//  OMSDBSQLQueue.m
//  OMSDB
//
//  Created by zhuhao on 16/8/1.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import "OMSDBSQLQueue.h"
#import <sqlite3.h>

typedef NS_ENUM(NSUInteger, OMSDBSQLQueueType) {
    enuSQLQueueTypeOpenDB,
    enuSQLQueueTypeCloseDB,
    enuSQLQueueTypeExecuteSqlString,
    enuSQLQueueTypeExecuteSqlObj
};

static sqlite3 *_dbHandler;

@interface OMSDBSQLQueue ()

//@property(nonatomic) sqlite3 *dbHandler;
@property(nonatomic,strong) NSString *dbPath;
@property(nonatomic,strong) NSString *sqlStr;
@property(nonatomic,strong) OMSDBSQL *sqlObj;
@property(nonatomic,assign) OMSDBSQLQueueType queueType;


@end

@implementation OMSDBSQLQueue

-(instancetype)initWithSQLStr:(NSString*)sqlStr {
    self = [super init];
    if (self) {
        self.sqlStr = sqlStr;
        self.queueType = enuSQLQueueTypeExecuteSqlString;
    }
    return self;
}

-(instancetype)initWithDBPath:(NSString*)dbPath {
    self = [super init];
    if (self) {
        _dbPath = dbPath;
        self.queueType = enuSQLQueueTypeOpenDB;
    }
    return self;
}

- (instancetype)initWithSQLObj:(OMSDBSQL *)sqlobj{
    self = [super init];
    if (self) {
        self.sqlObj = sqlobj;
        self.queueType = enuSQLQueueTypeExecuteSqlObj;
    }
    return self;
}

-(void)main {
    switch (_queueType) {
        case enuSQLQueueTypeOpenDB:
        {
            [self openDB];
        }
            break;
        case enuSQLQueueTypeExecuteSqlString:
        {
            [self execteSql:_sqlStr];
        }
            break;
        case enuSQLQueueTypeExecuteSqlObj:
        {
            
        }
            break;
        case enuSQLQueueTypeCloseDB:
        {
            [self closeDB];
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)openDB {
    //    sqlite3_config(SQLITE_CONFIG_SERIALIZED);
    if (sqlite3_open([_dbPath UTF8String],&_dbHandler) != SQLITE_OK) {
        NSLog(@"#OMSDB#数据库打开失败，将关闭数据库");
        sqlite3_close(_dbHandler);
        
        return NO;
    }
    NSLog(@"#OMSDB#数据库打开success ");
    return YES;
}

- (void)closeDB {
    sqlite3_close(_dbHandler);
}

-(void)execteSql:(NSString *)sql
{
    char *err;
    if (sqlite3_exec(_dbHandler, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(_dbHandler);
        NSLog(@"数据库sql操作数据失败!，%@",sql);
    }
}

-(void)execteSqlObj:(OMSDBSQL *)sqlObj
{
    NSString *sql = @"INSERT OR REPLACE INTO t_draft "
    "(user_id,user_source,conversation_type,content,update_time) "
    "values (?,?,?,?,?)";
    
    NSString *sqlStr = sqlObj.headerCmdSQL;
    
    
    sqlStr = [sqlStr stringByAppendingString:@" ( "];
    __block NSString *fieldKeys = @"";
    __block NSString *fieldValues = @"";
    [sqlObj.paramArrray enumerateObjectsUsingBlock:^(OMSDBSQLParam * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        fieldKeys = [fieldKeys stringByAppendingString:obj.tableField];
    }];
    
    
//    sqlite3_stmt *statement;
//    if (sqlite3_prepare_v2(_dbHandler, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
//        
//        sqlite3_bind_text(statement, 1, [draftModel.userId UTF8String], -1, NULL);
//        sqlite3_bind_int(statement, 2, (int32_t)draftModel.userSource);
//        sqlite3_bind_int(statement, 3, (int32_t)draftModel.conversationType);
//        sqlite3_bind_text(statement, 4, [draftModel.content UTF8String], -1, NULL);
//        sqlite3_bind_int(statement, 5, (int32_t)draftModel.time);
//        
//        if (sqlite3_step(statement) != SQLITE_DONE) {
//            
//            DebugLog(@"插入draft失败");
//        }
//    }else{
//        DebugLog(@" draft :sql error");
//    }
//    
//    sqlite3_finalize(statement);
//    sqlite3_close(db_handler);
}





@end
