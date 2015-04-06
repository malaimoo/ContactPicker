//
//  EmployeModel.m
//  CloudRecord
//
//  Created by wiki on 15/4/6.
//  Copyright (c) 2015年 wiki. All rights reserved.
//

#import "EmployeModel.h"

@implementation EmployeModel

-(NSString *)fullName{
    
    return [NSString stringWithFormat:@"%@%@",self.last,self.first];
    
}


@end
