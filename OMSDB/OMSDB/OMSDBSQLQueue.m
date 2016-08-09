//
//  OMSDBSQLQueue.m
//  OMSDB
//
//  Created by zhuhao on 16/8/1.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import "OMSDBSQLQueue.h"
#import <sqlite3.h>
#import "OMSDBObject.h"


static sqlite3 *_dbHandler;

@interface OMSDBSQLQueue ()

//@property(nonatomic) sqlite3 *dbHandler;
@property(nonatomic,strong) NSString *dbPath;
@property(nonatomic,strong) NSString *sqlStr;
@property(nonatomic,strong) OMSDBSQL *sqlObj;
@property(nonatomic,assign) Class classType;
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

-(instancetype)initWithSQLStr:(NSString*)sqlStr sqlQueueType:(OMSDBSQLQueueType)queueType objectType:(Class)classType complete:(FetchCompletedBlock)complete{
    self = [super init];
    if (self) {
        self.sqlStr = sqlStr;
        self.queueType = queueType;
        self.classType = classType;
        self.completeBlock = complete;
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



-(void)main {
    [super main];
    NSLog(@"come on ");
    @try {
        
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
            case enuSQLQueueTypeSQLSelect:
            {
                [self executeQuerySQL:_sqlStr];
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

        
    } @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }
    
    NSLog(@"^^run queue %@",_sqlStr);
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
        [self handleDBError:sql];
    }
}

- (void)executeQuerySQL:(NSString*)sql {
    
    NSMutableArray *array = [NSMutableArray array];
    
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(_dbHandler, sql.UTF8String, -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        
        while (SQLITE_ROW == sqlite3_step(stmt)) {
            id object = [[[_classType class] alloc]init];
            
            NSArray *propertyArr = [object getProrertyList];
            [propertyArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                OCObjectProperty *property = (OCObjectProperty*)obj;
                id value = [self valueForColumn:idx stmt:stmt ocType:property.propertyType];
                [object setValue:value forKey:property.propertyName];
                
            }];
            
            
            [array addObject:object];
        }
        
        if (_completeBlock) {
            _completeBlock(array,nil);
        }
    }else{
        [self handleDBError:sql];
    }
}

- (id)valueForColumn:(int)index stmt:(sqlite3_stmt *)stmt ocType:(NSString*)ocType{
    
    NSString *sqlType = [[_classType class] convertOCTypeToSQLType:ocType];
    id value ;
    if ([sqlType isEqualToString:@"text"]) {
        value = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, index)];
    }
    
    if ([sqlType isEqualToString:@"integer"]) {
        value = [NSNumber numberWithInt:sqlite3_column_int(stmt, index)];
    }
    
    if ([sqlType isEqualToString:@"real"]) {
        value = [NSNumber numberWithDouble:sqlite3_column_double(stmt, index)];
    }
    
    if ([sqlType isEqualToString:@"blob"]) {
        NSString *str = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, index)];
        value = [str dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    if ([sqlType isEqualToString:@"customArr"]) {
        
    }
    
    if ([sqlType isEqualToString:@"customDict"]) {
        
    }
    
    
    return value;
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


- (void)handleDBError:(NSString*)errorSQL {
    
    NSLog(@"sql error: %@ === reason :%s",errorSQL,sqlite3_errmsg(_dbHandler));
}


@end
