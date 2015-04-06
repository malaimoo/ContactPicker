//
//  EmployeModel.h
//  CloudRecord
//
//  Created by wiki on 15/4/6.
//  Copyright (c) 2015年 wiki. All rights reserved.
//

#import "BaseModel.h"

@interface EmployeModel : BaseModel

@property (nonatomic,copy) NSString *first;
@property (nonatomic,copy) NSString *last;
@property (nonatomic,copy) NSString *fullName;
@property (nonatomic,copy) NSString *telphone;

@end
