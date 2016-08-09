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



//typedef NSString OMSDBCondition;
//extern OMSDBCondition *makeCondition(NSString*propertyname,id value ,NSString * operate) ;

@interface OCObjectProperty : NSObject

@property(nonatomic,strong) NSString *propertyName;
@property(nonatomic,strong) NSString *propertyType;

@end


@protocol OMSDBObjectProtocol <NSObject>

+ (NSString*)tableNameForObject;

- (void)propertyNameMappedDBTableFileds;

@end


@interface OMSDBObject : NSObject<OMSDBObjectProtocol>

@property(nonatomic,assign) OMSDBObjectOperatType *operateType;

- (NSArray *)getProrertyList;

//FIXME: 修改传入的字符串
- (void)mapProperty:(NSString*)propertyRef tableField:(NSString*)fieldName;

+ (NSString *)convertOCTypeToSQLType:(NSString *)oc_type ;

//FIXME: 修改传入的字符串，用上去不是很爽
- (void)markPropertyAsQuery:(NSString*)property value:(id)value;

/**
 *  CRUD
 *
 */

- (NSString*)buildCreateSQLString;

- (NSString*)buildInsertSQL ;

+ (NSString*)buildSelectAllSQL;

- (NSString*)buildFetchObjectSQL;


- (NSString*)buildDeleteObjectSQL;
+ (NSString*)buildDeleteAllObjectSQL;

@end



