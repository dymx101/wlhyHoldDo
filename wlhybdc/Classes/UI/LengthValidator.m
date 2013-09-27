//
//  LengthValidator.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-13.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "LengthValidator.h"
static NSString* const LengthValidatorDomain = @"com.wlhy.LengthValidator";
static NSString* const minLengthKey = @"minLength";
static NSString* const maxLengthKey = @"maxLength";
static NSString* const constLengthKey = @"constLength";

@implementation LengthValidator

-(BOOL)validateInput:(UITextField *)textField error:(NSError *__autoreleasing *)error{
    NSUInteger textLength = textField.text.length;
    NSString* errorMsg=nil;
    if([textField isKindOfClass: [UITextField class]]){
        if(textLength ==0){
            errorMsg =@"不能为空";
        }
    } //添加其他的类型的校验
    else{
        
    }
    
    if(errorMsg&& error){
        NSString* desc=NSLocalizedString(@"输入校验失败", @"");
        NSString* reason = NSLocalizedString(errorMsg, @"");
        *error = [NSError errorWithDomain:LengthValidatorDomain code:1002 userInfo:@{NSLocalizedDescriptionKey:desc,
         NSLocalizedFailureReasonErrorKey:reason    }];
        return NO;
    }
    return YES;
   
}
@end
