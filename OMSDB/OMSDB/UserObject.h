//
//  UserObject.h
//  OMSDB
//
//  Created by zhuhao on 16/7/30.
//  Copyright © 2016年 zhuhao. All rights reserved.
//

#import "OMSDBObject.h"

@interface UserObject : OMSDBObject

@property(nonatomic,strong) NSString *userName;
@property(nonatomic,strong) NSString *pwd;
@property(nonatomic,strong) NSString *birthday;
@property(nonatomic,assign) NSInteger sex;
@property(nonatomic,assign) NSInteger age;

@end
