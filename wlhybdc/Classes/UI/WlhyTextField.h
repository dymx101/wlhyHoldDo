//
//  WlhyTextField.h
//  wlhybdc
//
//  Created by linglong meng on 12-10-12.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Validator.h"
@interface WlhyTextField : UITextField
@property(nonatomic,strong)IBOutlet Validator* validator;

-(BOOL) validate;
@end
