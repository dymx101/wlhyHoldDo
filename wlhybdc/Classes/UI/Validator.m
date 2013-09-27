//
//  Validator.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-12.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "Validator.h"

@implementation Validator
-(BOOL)validateInput:(UITextField *)textField error:(NSError *__autoreleasing *)error{
    if(error){
        *error=nil;
    }
    return NO;
}
@end
