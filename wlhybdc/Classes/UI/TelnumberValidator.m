//
//  TelnumberValidator.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-13.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "TelnumberValidator.h"

static NSString* const TelnumberValidatorDomain=@"com.wlhy.TelnumberValidatorDomain";

@implementation TelnumberValidator
-(BOOL)validateInput:(UITextField *)textField error:(NSError *__autoreleasing *)error{
    NSError* regError = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^1\\d{10}$" options:NSRegularExpressionAnchorsMatchLines error:&regError];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:textField.text options:NSMatchingAnchored range:NSMakeRange(0, textField.text.length)];
    if(!numberOfMatches){
        if(error){
            NSString* desc=NSLocalizedString(@"号码校验失败", @"");
            NSString* reason = NSLocalizedString(@"不是有效的手机号码", @"");
            *error = [NSError errorWithDomain:TelnumberValidatorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey:desc,
             NSLocalizedFailureReasonErrorKey:reason    }];
        }
        return NO;
    }
    return YES;
}
@end
