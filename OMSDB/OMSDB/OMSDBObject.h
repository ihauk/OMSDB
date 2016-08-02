//
//  OMSDBObject.h
//  OMSDB
//
//  Created by zhuhao on 16/7/30.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class OMSDBSQL;

typedef NS_ENUM(NSUInteger, OMSDBObjectOperatType) {
    enuObjectOperatTypeAdd,
    enuObjectOperatTypeDelete,
    enuObjectOperatTypeFetchOne,
    enuObjectOperatTypeQueryAll
};


@interface OCObjectProperty : NSObject

@property(nonatomic,strong) NSString *propertyName;
@property(nonatomic,strong) NSString *propertyType;

@end


@protocol OMSDBObjectProtocol <NSObject>

- (NSString*)tableNameForObject;

- (void)propertyNameMappedDBTableFileds;

@end


@interface OMSDBObject : NSObject<OMSDBObjectProtocol>

@property(nonatomic,assign) OMSDBObjectOperatType *operateType;

- (NSArray *)getProrertyList;

- (void)mapProperty:(NSString*)propertyRef tableField:(NSString*)fieldName;

- (NSString*)buildCreateSQLString;

- (OMSDBSQL*)buildInsertSQL ;

@end



