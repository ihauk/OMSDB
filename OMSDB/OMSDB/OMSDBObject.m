//
//  OMSDBObject.m
//  OMSDB
//
//  Created by zhuhao on 16/7/30.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import "OMSDBObject.h"
#import "OMSDBSQLMaker.h"

//#define varString(var) [NSString stringWithFormat:@"%s",#var]

#define kCreateTableSQL @"CREATE TABLE IF NOT EXISTS "

#define kInsertSQL @"INSERT OR REPLACE INTO "

#define kFetchObjectSQL @"SELECT * FROM "

#define kDeleteObjectSQL @"DELETE FROM "

@implementation OCObjectProperty

@end


@interface OMSDBObject ()

@property(nonatomic,strong) NSMutableDictionary *mapingDic;
@property(nonatomic,strong) NSMutableArray *markedQueryPropertyArr;

@end

@implementation OMSDBObject


- (NSArray *)getProrertyList {
    // 记录属性个数
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *tempArrayM = [NSMutableArray array];
    
    for (int i = 0; i < count; i++) {
        OCObjectProperty *oc_property = [[OCObjectProperty alloc] init];
        
        // objc_property_t 属性类型
        objc_property_t property = properties[i];
        
        // 转换为Objective C 字符串
        NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSString *type = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        oc_property.propertyName = name;
        oc_property.propertyType = [self getAttributesWith:type];
        
        NSAssert(![name isEqualToString:@"index"], @"禁止在model中使用index作为属性,否则会引起语法错误");
        
        if ([name isEqualToString:@"hash"]) {
            break;
        }
        
        [tempArrayM addObject:oc_property];
    }
    free(properties);
    
    return [tempArrayM copy];
}

#pragma mark -
#pragma mark - create table


- (NSString*)buildCreateSQLString {
    // 设置 property 与 db 字段的映射
    [self propertyNameMappedDBTableFileds];
    
    
    NSString *tableName = [[self class] tableNameForObject];
    
    __block NSString *createSql = kCreateTableSQL;
    createSql = [createSql stringByAppendingString:tableName];
    createSql = [createSql stringByAppendingString:@" ("];
    
    NSArray *propertyNames = [self getProrertyList];
    [propertyNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OCObjectProperty *oc_property = (OCObjectProperty*)obj;
        
        NSString *tableField = [self getTableFieldByProperty:oc_property.propertyName];
        if (!tableField) {
            tableField = oc_property.propertyName;
        }
        if (tableField) {
            
            createSql = [createSql stringByAppendingString:[NSString stringWithFormat:@" %@ %@",tableField,[[self class ]convertOCTypeToSQLType:oc_property.propertyType]]];
            if (idx != propertyNames.count-1) {
                createSql = [createSql stringByAppendingString:@","];
            }
        }
    }];
    
    
    createSql = [createSql stringByAppendingString:@" );"];
    NSLog(@"sql --- %@ ",createSql);
    
    return createSql;
}


#pragma mark -
#pragma mark - insert

- (NSString*)buildInsertSQL {
    // 设置 property 与 db 字段的映射
    [self propertyNameMappedDBTableFileds];
    
    NSString *tableName = [[self class] tableNameForObject];
    
    __block NSString *insertSql = kInsertSQL;
    insertSql = [insertSql stringByAppendingString:tableName];
    insertSql = [insertSql stringByAppendingString:@" ("];
    
    NSArray *propertyNames = [self getProrertyList];
    
    __block NSString *fieldKeys = @"";
    __block NSString *fieldValues = @"";
    [propertyNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        OCObjectProperty *oc_property = (OCObjectProperty*)obj;
        
        NSString *tableField = [self getTableFieldByProperty:oc_property.propertyName];
        if (!tableField) {
            tableField = oc_property.propertyName;
        }
        
        fieldKeys = [fieldKeys stringByAppendingString:[NSString stringWithFormat:@" %@ ",tableField]];
        if (idx != propertyNames.count-1) {
            fieldKeys = [fieldKeys stringByAppendingString:@","];
        }
        
        id valu = [self valueForKey:oc_property.propertyName];
        
        fieldValues = [fieldValues stringByAppendingString:[NSString stringWithFormat:@" '%@' ",valu]];
        if (idx != propertyNames.count-1) {
            fieldValues = [fieldValues stringByAppendingString:@","];
        }
        
    }];
    
    insertSql = [insertSql stringByAppendingString:fieldKeys];
    insertSql = [insertSql stringByAppendingString:@" ) values ("];
    insertSql = [insertSql stringByAppendingString:fieldValues];
    insertSql = [insertSql stringByAppendingString:@" );"];
    
    NSLog(@"sql --- %@ ",insertSql);
    
    return insertSql;
}

#pragma mark -
#pragma mark - select 

+ (NSString*)buildSelectAllSQL {
    
    NSString *tableName = [self tableNameForObject];
    NSString *selectALlSql = kFetchObjectSQL;
    selectALlSql = [selectALlSql stringByAppendingString:tableName];
    selectALlSql = [selectALlSql stringByAppendingString:@";"];
    NSLog(@"sql --- %@ ",selectALlSql);
    
    return selectALlSql;
}

- (NSString*)buildFetchObjectSQL {
    // 设置 property 与 db 字段的映射
    [self propertyNameMappedDBTableFileds];
    
    NSString *tableName = [[self class] tableNameForObject];
    
    __block NSString *insertSql = kFetchObjectSQL;
    insertSql = [insertSql stringByAppendingString:tableName];
    insertSql = [insertSql stringByAppendingString:@" where "];
    
    NSArray *propertyNames = [self getProrertyList];
    
    __block NSMutableString *queryParam = [NSMutableString string];
    
    [_markedQueryPropertyArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *tableField = [self getTableFieldByProperty:obj];
        if (!tableField) {
            tableField = obj;
        }
        
        id valu = [self valueForKey:obj];
        
        if (valu != nil) {
            NSString* fieldKey = [NSString stringWithFormat:@" %@ ",tableField];
            
            NSString* fieldValue = [NSString stringWithFormat:@" '%@' ",valu];
            [queryParam appendString:[NSString stringWithFormat:@"%@=%@",fieldKey,fieldValue]];
            if (idx != _markedQueryPropertyArr.count-1) {
                [queryParam appendString:@" and "];
            }
        }
    }];
    
//    [propertyNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        
//        OCObjectProperty *oc_property = (OCObjectProperty*)obj;
//        
//        NSString *tableField = [self getTableFieldByProperty:oc_property.propertyName];
//        if (!tableField) {
//            tableField = oc_property.propertyName;
//        }
//        
//        
//        id valu = [self valueForKey:oc_property.propertyName];
//        
//        if (valu != nil) {
//            NSString* fieldKey = [NSString stringWithFormat:@" %@ ",tableField];
//            
//            NSString* fieldValue = [NSString stringWithFormat:@" '%@' ",valu];
//            [queryParam appendString:[NSString stringWithFormat:@"%@=%@",fieldKey,fieldValue]];
//            if (idx != propertyNames.count-1) {
//                [queryParam appendString:@" and "];
//            }
//        }
//        
//    }];
    
//    NSRange rang = NSMakeRange(queryParam.length-@"and".length-1, @"and".length+1);
//    [queryParam deleteCharactersInRange:rang];
    
    insertSql = [insertSql stringByAppendingString:queryParam];
    insertSql = [insertSql stringByAppendingString:@";"];
    
    NSLog(@"sql --- %@ ",insertSql);
    
    return insertSql;
}


#pragma mark -
#pragma mark - delete

- (NSString*)buildDeleteObjectSQL {
    
    NSString *tableName = [[self class] tableNameForObject];
    
    NSString *deleteSQL = kDeleteObjectSQL;
    deleteSQL = [deleteSQL stringByAppendingString:tableName];
    deleteSQL = [deleteSQL stringByAppendingString:@" where "];
    
    __block NSMutableString *queryParam = [NSMutableString string];
    
    [_markedQueryPropertyArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *tableField = [self getTableFieldByProperty:obj];
        if (!tableField) {
            tableField = obj;
        }
        
        id valu = [self valueForKey:obj];
        
        if (valu != nil) {
            NSString* fieldKey = [NSString stringWithFormat:@" %@ ",tableField];
            
            NSString* fieldValue = [NSString stringWithFormat:@" '%@' ",valu];
            [queryParam appendString:[NSString stringWithFormat:@"%@=%@",fieldKey,fieldValue]];
            if (idx != _markedQueryPropertyArr.count-1) {
                [queryParam appendString:@" and "];
            }
        }
    }];
    
    deleteSQL = [deleteSQL stringByAppendingString:queryParam];
    deleteSQL = [deleteSQL stringByAppendingString:@";"];
    
    NSLog(@"sql --- %@ ",deleteSQL);
    
    return deleteSQL;
}


+ (NSString *)buildDeleteAllObjectSQL {
    NSString *tableName = [[self class] tableNameForObject];
    
    NSString *deleteSQL = kDeleteObjectSQL;
    deleteSQL = [deleteSQL stringByAppendingString:tableName];
    deleteSQL = [deleteSQL stringByAppendingString:@";"];
    
    NSLog(@"sql --- %@ ",deleteSQL);
    
    return deleteSQL;
}






-(void)mapProperty:(NSString* )propertyRef tableField:(NSString *)fieldName
{
    if (!_mapingDic) {
        _mapingDic = [NSMutableDictionary dictionary];
    }
//    NSString *propertyName = varString(propertyRef);
//    NSLog(@"var == %@",propertyName);
    [_mapingDic setObject:fieldName forKey:propertyRef];
}

- (void)markPropertyAsQuery:(NSString *)property{
    if (!_markedQueryPropertyArr) {
        _markedQueryPropertyArr = [NSMutableArray array];
    }
    
    [_markedQueryPropertyArr addObject:property];
}

- (NSString*)getTableFieldByProperty:(NSString*)propertyName {
    
    return _mapingDic[propertyName];
}

+ (NSString *)convertOCTypeToSQLType:(NSString *)oc_type {
    if ([oc_type isEqualToString:@"long"] || [oc_type isEqualToString:@"int"] || [oc_type isEqualToString:@"BOOL"]) {
        return @"integer";
    }
    if ([oc_type isEqualToString:@"NSData"]) {
        return @"blob";
    }
    if ([oc_type isEqualToString:@"double"] || [oc_type isEqualToString:@"float"]) {
        return @"real";
    }
    // 自定义数组标记
    if ([oc_type isEqualToString:@"NSArray"] || [oc_type isEqualToString:@"NSMutableArray"]) {
        return @"customArr";
    }
    // 自定义字典标记
    if ([oc_type isEqualToString:@"NSDictionary"] || [oc_type isEqualToString:@"NSMutableDictionary"]) {
        return @"customDict";
    }
    return @"text";
}

#pragma mark
#pragma mark =============== 获取属性对应的OC类型 ===============
- (NSString *)getAttributesWith:(NSString *)type {
    
    NSString *firstType = [[[type componentsSeparatedByString:@","] firstObject] substringFromIndex:1];
    
    NSDictionary *dict = @{@"f":@"float",
                           @"i":@"int",
                           @"d":@"double",
                           @"l":@"long",
                           @"q":@"long",
                           @"c":@"BOOL",
                           @"B":@"BOOL",
                           @"s":@"short",
                           @"I":@"NSInteger",
                           @"Q":@"NSUInteger",
                           @"#":@"Class"};
    
    for (NSString *key in dict.allKeys) {
        if ([key isEqualToString:firstType]) {
            return  [dict valueForKey:firstType];
        }
    }
    return [firstType componentsSeparatedByString:@"\""][1];
}


#pragma mark -
#pragma mark - OMSDBObjectProtocol

+ (NSString *)tableNameForObject {
    
    NSAssert(NO, @"子类必须实现该方法！！！,告诉我这个类的 object 要存入那个 table");
    return @"";
}

-(void)propertyNameMappedDBTableFileds {
    
}


#pragma mark -
#pragma mark - desctrition

-(NSString *)description {
    NSArray *array =  [self getProrertyList];
    __block NSString *des = @"";
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OCObjectProperty* or = obj;
        des = [des stringByAppendingString:[NSString stringWithFormat:@"%@ = %@, ",or.propertyName,[self valueForKey:or.propertyName]]];
    }];
    
    return des;
}



@end
