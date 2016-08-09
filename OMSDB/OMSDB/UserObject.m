//
//  UserObject.m
//  OMSDB
//
//  Created by zhuhao on 16/7/30.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import "UserObject.h"

@implementation UserObject

+ (void)propertyNameMappedDBTableFileds {
    
    [self mapProperty:@"userName" tableField:@"user_name"];
    [self mapProperty:@"pwd" tableField:@"password"];
    
}

+ (NSString *)tableNameForObject {
    
    return @"t_user";
}

@end
