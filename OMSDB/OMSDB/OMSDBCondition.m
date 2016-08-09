//
//  OMSDBCondition.m
//  OMSDB
//
//  Created by zhuhao on 16/8/9.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import "OMSDBCondition.h"

@implementation OMSDBCondition

+ (OMSDBCondition *)makeConditionWithPropertyName:(NSString *)propertyName value:(id)value operater:(NSString *)operater {
    
    OMSDBCondition *condition = [[OMSDBCondition alloc]init];
    condition.conditionType = enuConditionWhere;
    
    if (!propertyName || !value || !operater) {
        return condition;
    }
    condition.conditionStr = [NSString stringWithFormat:@"%@%@'%@'",propertyName,operater,value];
    
    return condition;
}

+ (OMSDBCondition *)makeOerderConditionWithPropertyName:(NSString *)propertyName orderByASC:(BOOL)isASC {
  
    OMSDBCondition *condition = [[OMSDBCondition alloc]init];
    condition.conditionType = enuConditionOrder;
    
    if (!propertyName) {
        return condition;
    }
    condition.conditionStr = [NSString stringWithFormat:@" %@ %@ ",propertyName,isASC ? @"ASC":@"DESC"];
    
    return condition;
}

@end
