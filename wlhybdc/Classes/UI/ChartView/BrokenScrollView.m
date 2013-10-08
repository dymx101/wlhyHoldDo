//
//  CurveScrollView.m
//  ScrollViewTest
//
//  Created by miracles3 on 13-4-22.
//  Copyright (c) 2013年 miracles3. All rights reserved.
//

#import "BrokenScrollView.h"

#define X_Inteval 50


@interface BrokenScrollView ()

@property(strong, nonatomic) NSArray *dataArray;

@end

@implementation BrokenScrollView



- (id)initWithFrame:(CGRect)frame dataArray:(NSArray *)kDataArray
{
    self = [super initWithFrame:frame];
    if (self) {
        _min = 0.0f;
        _max = 300.0f;
        _dataArray = kDataArray;
        
        [self setFrame:frame];
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}


#pragma mark -draw Rect

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /*
     (
     {
     value = 164;
     ym = "2013-08";
     },
     {
     value = 165;
     ym = "2013-08";
     }
     )
    */
    
    
    //绘制X坐标上面的日期文字::
    NSString *dateString;
    for (int i = 0; i < self.dataArray.count; i++) {
        dateString = [[self.dataArray objectAtIndex:i] objectForKey:@"ym"];         //sample: "2013-01"
        
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.4 green:0.7 blue:0.4 alpha:1.0].CGColor);
        
        [dateString drawInRect:CGRectMake(X_Inteval * i, self.bounds.size.height - X_LABEL_HEIGHT, 50, X_LABEL_HEIGHT)
                      withFont:[UIFont systemFontOfSize:10]
                 lineBreakMode:NSLineBreakByWordWrapping
                     alignment:NSTextAlignmentCenter];
        
    }
    
    for (int i = 0; i < self.dataArray.count; i++) {
        [self drawLine:context dataArrayIndex:i xLocation:i*X_Inteval];
    }
    
    return;
    
}


#pragma mark -draw Line
//绘制折线条：：
- (void)drawLine:(CGContextRef)context dataArrayIndex:(int)index xLocation:(float)xLocation
{
    
    float yValue = [[[self.dataArray objectAtIndex:index] objectForKey:@"value"] floatValue];
    float currentPointLocation = [self getYLocationWithYValue:yValue];
    
    
    CGContextSaveGState(context);
    
    UIColor *lineColor = [UIColor colorWithRed:0.5 green:0.9 blue:0.5 alpha:1.0];
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextSetFillColorWithColor(context, lineColor.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 2);
    
    //在拐弯的地方绘制小圈：：
    CGContextAddEllipseInRect(context, CGRectMake(xLocation + X_Inteval/2.0-4, currentPointLocation-4, 8, 8));//在这个框中画圆
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextFillPath(context);

    if (index == 0) {
        CGContextRestoreGState(context);
        return;
    }
    
    //绘制连接线：：
    yValue = [[[self.dataArray objectAtIndex:index - 1] objectForKey:@"value"] floatValue];
    float lastYLocation = [self getYLocationWithYValue:yValue];
    CGContextMoveToPoint(context, xLocation - X_Inteval/2.0, lastYLocation);
    CGContextAddLineToPoint(context, xLocation + X_Inteval/2.0, currentPointLocation);
    CGContextStrokePath(context);

    CGContextRestoreGState(context);
}



#pragma mark - get Y Location 

- (float)getYLocationWithYValue:(float)yValue
{
    float yValueInteval, yLocation;
    
    yValueInteval = (self.bounds.size.height-X_LABEL_HEIGHT)/(_max - _min);
    yLocation = yValueInteval * (_max - yValue);
    NSLog(@"y == %f , %f", yValue, yLocation);
    return yLocation;
}


@end
