//
//  BaseModel.m
//  CloudRecord
//
//  Created by wiki on 15/4/6.
//  Copyright (c) 2015年 wiki. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel
// 对特殊字符 id 进行处理
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"Undefined Key: %@", key);
}
// 将所有的数据转换为字符串
-(void)setValue:(id)value forKey:(NSString *)key{
    
    if([value isKindOfClass:[NSNull class]]){
        value=nil;
    }else{
        value = [NSString stringWithFormat:@"%@",value];
    }
    [super setValue:value forKey:key];
}
// 字典转模型
-(id)initWithDic:(NSDictionary *)modelDic{
    
    self = [super init];
    if(self){
        [self setValuesForKeysWithDictionary:modelDic];
    }
    return self;
    
}

@end