//
//  Validator.h
//  wlhybdc
//
//  Created by linglong meng on 12-10-12.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Validator : NSObject
-(BOOL) validateInput:(UITextField*)textField error:(NSError**)error;
@end
