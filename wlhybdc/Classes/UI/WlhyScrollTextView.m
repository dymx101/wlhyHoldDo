//
//  WlhyScrollTextView.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-22.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyScrollTextView.h"

@interface WlhyScrollTextView()<UITextViewDelegate>{
    NSTimer* _timer;
}

@end

@implementation WlhyScrollTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if(self){
        self.text=@"/*"
        "// Only override drawRect: if you perform custom drawing."
        "// An empty implementation adversely affects performance during animation."
        "- (void)drawRect:(CGRect)rect"
        "{"
        "    // Drawing code"
        "}"
        "*/ ";
        
        self.delegate=self;

    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(BOOL)shouldChangeTextInRange:(UITextRange *)range replacementText:(NSString *)text{
    NSLog(@"%@",text);
    return YES;
}

-(void)setText:(NSString *)text{
    [super setText:text];
    
    CGSize s = [self.text sizeWithFont:self.font];
    
    if (!CGSizeEqualToSize(s,CGSizeZero) && self.text.length >0) {
        self.contentSize=s;
    }
}

@end
