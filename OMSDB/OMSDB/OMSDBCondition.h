//
//  OMSDBCondition.h
//  OMSDB
//
//  Created by zhuhao on 16/8/9.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, OMSDBCOnditionType) {
    enuConditionWhere,
    enuConditionOrder,
};

@interface OMSDBCondition : NSObject

+ (OMSDBCondition*)makeConditionWithPropertyName:(NSString*)propertyName
                                           value:(id)value
                                        operater:(NSString*)operater;

+ (OMSDBCondition*)makeOerderConditionWithPropertyName:(NSString*)propertyName
                                           orderByASC:(BOOL)isASC;


@property(nonatomic,assign) OMSDBCOnditionType conditionType;
@property(nonatomic,strong) NSString* conditionStr;

@end
