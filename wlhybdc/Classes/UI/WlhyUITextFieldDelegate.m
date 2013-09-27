//
//  WlhyUITextFieldDelegate.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-12.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyUITextFieldDelegate.h"
#import "Validator.h"
#import "WlhyTextField.h"

@implementation WlhyUITextFieldDelegate

-(id) init{
    self=[super init];
    if(self){
        
    }
    
    return self;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if([textField isKindOfClass:[WlhyTextField class]]){
        [(WlhyTextField*)textField validate];
    }
}


@end
