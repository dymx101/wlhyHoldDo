//
//  NumberValidator.m
//  wlhybdc
//
//  Created by linglong meng on 12-11-7.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "NumberValidator.h"
static NSString* const NumberValidatorDomain = @"com.wlhy.NumberValidator";

@implementation NumberValidator

-(BOOL)validateInput:(UITextField *)textField error:(NSError *__autoreleasing *)error{
    NSUInteger textLength = textField.text.length;
    NSString* errorMsg=nil;
    if([textField isKindOfClass: [UITextField class]]){
        if(textLength >0){
            NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
            f.numberStyle=NSNumberFormatterDecimalStyle;
            if(![f numberFromString:textField.text]){
                errorMsg=@"请输入数字";
            }
        }
    } //添加其他的类型的校验
    else{
        
    }
    
    if(errorMsg&& error){
        NSString* desc=NSLocalizedString(@"输入校验失败", @"");
        NSString* reason = NSLocalizedString(errorMsg, @"");
        *error = [NSError errorWithDomain:NumberValidatorDomain code:1003 userInfo:@{NSLocalizedDescriptionKey:desc,
         NSLocalizedFailureReasonErrorKey:reason    }];
        return NO;
    }
    return YES;

}

@end
