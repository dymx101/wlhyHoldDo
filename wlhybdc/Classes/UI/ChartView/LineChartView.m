//
//  LineChartView.m
//  wlhybdc
//
//  Created by ios on 13-7-29.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "LineChartView.h"


#define LEFT_MARGIN     30.0
#define RIGHT_MARGIN    10
#define X_INTEVAL       40
#define X_LABEL_HEIGHT  15        //X坐标文字的高度
#define YMARK_NUMBER   5

#define PCColorDefault [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]


@interface PointerLayer : CALayer

@end


@implementation PointerLayer

- (id)init
{
    if ((self = [super init]))
    {
        self.needsDisplayOnBoundsChange = YES;
    }
    
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    {
        CGContextAddEllipseInRect(ctx, self.bounds);
        CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
        CGContextFillPath(ctx);
    }
    CGContextRestoreGState(ctx);
}

@end

//========================================================================
//========================================================================


@interface LineChartView ()
{
    float totalTime;
    float maxSpeed;
    float lineAreaWidth;
    
    float flexibleMaxSpeed;
    float flexibleMaxTime;
    
    int xMark_number;
}

@property (nonatomic, strong) PointerLayer *pointerLayer;

@end


@implementation LineChartView


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self){
        self.backgroundColor = [UIColor clearColor];
        
        self.pointerLayer = [PointerLayer layer];
        self.pointerLayer.frame = CGRectMake(0, 0, 8.0, 8.0);
        self.pointerLayer.position = CGPointMake(LEFT_MARGIN, self.bounds.size.height - X_LABEL_HEIGHT);
        [self.layer addSublayer:self.pointerLayer];
        
        xMark_number = 10;
    }
    return self;
}


#pragma mark - drawRect

- (void)drawRect:(CGRect)rect
{
    NSLog(@"drawRect :: _dataSource %@", _dataSource);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    
    
    //绘制Y轴直线：：
    CGContextMoveToPoint(context, LEFT_MARGIN-1, 0);
    CGContextAddLineToPoint(context, LEFT_MARGIN-1, self.bounds.size.height-X_LABEL_HEIGHT);
    CGContextStrokePath(context);
    
    //绘制X轴直线：：
    CGContextMoveToPoint(context, LEFT_MARGIN, self.bounds.size.height-X_LABEL_HEIGHT);
    CGContextAddLineToPoint(context, self.bounds.size.width - RIGHT_MARGIN,
                            self.bounds.size.height-X_LABEL_HEIGHT);
    CGContextStrokePath(context);
    
    //绘制Y轴的刻度：：
    CGContextSetRGBFillColor(context, 0, 0, 0, 1.0);
    
    NSString *yValueString;
    float yPositionInterval = (self.bounds.size.height - X_LABEL_HEIGHT) / YMARK_NUMBER;
    float yValueInterval = flexibleMaxSpeed / YMARK_NUMBER;
    for (int i = 0; i < YMARK_NUMBER; i++) {
        //绘制Y轴刻度数量的数字：：
        yValueString = [NSString stringWithFormat:@"%.0f", flexibleMaxSpeed - i*yValueInterval];
        CGRect yValueRect = CGRectMake(0, yPositionInterval * i, LEFT_MARGIN, 20);
        [yValueString drawInRect:yValueRect
                        withFont:[UIFont systemFontOfSize:11]
                   lineBreakMode:NSLineBreakByWordWrapping
                       alignment:NSTextAlignmentCenter];
    }
    
    //绘制X轴的刻度：：
    CGContextSetRGBFillColor(context, 0, 0, 0, 1.0);
    
    NSLog(@"flexibleMaxTime :: %f", flexibleMaxTime);
    
    xMark_number = 10;
    if (flexibleMaxTime <= 10) {
        xMark_number = flexibleMaxTime;
    }
    
    NSString *xValueString;
    float xPositionInterval = (self.bounds.size.width - LEFT_MARGIN - RIGHT_MARGIN) / xMark_number;
    float xValueInterval = flexibleMaxTime / xMark_number;
    
    NSLog(@"%f", xPositionInterval);
    NSLog(@"%f", xValueInterval);
    
    for (int i = 0; i <= xMark_number; i++) {
        //绘制X轴刻度数量的数字：：
        xValueString = [NSString stringWithFormat:@"%.0f", i * xValueInterval];
        
        [xValueString drawInRect:
         CGRectMake(xPositionInterval * i + LEFT_MARGIN * 0.8, self.bounds.size.height - 0.9 * X_LABEL_HEIGHT, 15, X_LABEL_HEIGHT) withFont:[UIFont systemFontOfSize:11]
                   lineBreakMode:NSLineBreakByWordWrapping
                       alignment:NSTextAlignmentLeft];
    }
    
    
    //绘制表示运动步骤的线条：：
    int currentTime = 0.0;
    float currentX, currentY;
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.7 green:0.8 blue:0.7 alpha:1.0].CGColor);//折线颜色
    CGContextSetLineWidth(context, 2);
    currentX = [self getXLocationWithTime:0];
    currentY = [self getYLocationWithTime:0];
    CGContextMoveToPoint(context, currentX, currentY);
    
    NSDictionary *currentStep = [_dataSource objectAtIndex:0];
//    currentTime += [[currentStep objectForKey:@"time"] floatValue];
    
    for (int i = 0; i < _dataSource.count; i++) {
        
        currentStep = [_dataSource objectAtIndex:i];

        currentX = [self getXLocationWithTime:currentTime + [[currentStep objectForKey:@"time"] floatValue]];
        CGContextAddLineToPoint(context, currentX, currentY);
        
        currentTime += [[currentStep objectForKey:@"time"] floatValue];
        currentY = [self getYLocationWithTime:currentTime];
        CGContextAddLineToPoint(context, currentX, currentY);
        
        
        currentX = [self getXLocationWithTime:currentTime];
        CGContextAddLineToPoint(context, currentX, currentY);
    }
    
    CGContextStrokePath(context);
    
    /*
    //绘制标示文字：：
    CGContextSaveGState(context);
    CGFloat _pad = 40.0;
    
    //--表示线
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor );
    CGContextMoveToPoint(context, 0,-_pad+10);
    CGContextAddLineToPoint(context, 40,-_pad+10);
    CGContextStrokePath(context);
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(15, -40+5, 10, 10));
    //
    NSString * str = @"当前运动段";
    //转换y轴方向,画字符串
    CGContextScaleCTM(context, 1, -1);
    [str drawAtPoint:CGPointMake(40, _pad-15) withFont:[UIFont systemFontOfSize:10]];
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    str=@"时间（Min)";
    [str drawAtPoint:CGPointMake(280, _pad-20) withFont:[UIFont systemFontOfSize:10]];
    
    str=@"速度(KM/H)";
    CGContextRotateCTM(context, M_PI_2);
    [str drawAtPoint:CGPointMake(10, 80) withFont:[UIFont systemFontOfSize:10]];
    
    CGContextRestoreGState(context);
    */
    
    return;
    
}

#pragma mark - Private method

- (float)getXLocationWithTime:(float)time
{
    if (time < 0.0001) {
        return LEFT_MARGIN;
    }
    float xLocation = (self.bounds.size.width - LEFT_MARGIN - RIGHT_MARGIN) / flexibleMaxTime * time;
    return xLocation + LEFT_MARGIN;
}

- (float)getYLocationWithTime:(float)time
{
    float timeSum = 0.0;
    int currentStep = 0;
    
    for (int i = 0; i < _dataSource.count; i++) {
        NSDictionary *temp = [_dataSource objectAtIndex:i];
        timeSum += [[temp objectForKey:@"time"] floatValue];
        if (time < timeSum) {
            currentStep = i;
            break;
        }
    }
    
    float currentSpeed = [[[_dataSource objectAtIndex:currentStep] objectForKey:@"speed"] floatValue];
    float yLocation = self.bounds.size.height / flexibleMaxSpeed * (flexibleMaxSpeed - currentSpeed);
    return yLocation + 1;
    
}

- (CGFloat)getTotalValueByKey:(NSString*)key
{
    CGFloat  total = 0.0f;
    for (NSDictionary *dict in _dataSource) {
        total += [[dict objectForKey:key] floatValue];
    }
    return total;
}

- (CGFloat)getMaxSpeed
{
    float max = [[[_dataSource objectAtIndex:0] objectForKey:@"speed"] floatValue];
    
    for (NSDictionary *tempDic in _dataSource) {
        if ([[tempDic objectForKey:@"speed"] floatValue] > max) {
            max = [[tempDic objectForKey:@"speed"] floatValue];
        }
    }
    
    max = ceilf(max);
    
    return max;
}


- (int)getFlexibleExtremumWithRealValue:(float)realValue
{
    int result = 0;
    
    int shang = (int)realValue / 5;
    int yuShu = (int)realValue % 5;
    
    if (yuShu == 0) {
        result = shang * 5;
    } else {
        result = (shang + 1) * 5;
    }
    
    return result;
}


#pragma mark - interface method

- (void)movePointerWithTime:(float)time
{
    float pointerX = [self getXLocationWithTime:time];
    float pointerY = [self getYLocationWithTime:time];
    
    NSLog(@"%f, %f, %f", time, pointerX, pointerY);
    _pointerLayer.position = CGPointMake(pointerX, pointerY);
}

- (void)setDataSource:(NSArray *)dataSource
{
    /*
     (
     {
     bigStep = 1;
     contents = "";
     frequency = "";
     resttime = "";
     slope = 3;
     smallStep = 1;
     speed = 3;
     step = "";
     strength = "";
     time = 2;
     title = "";
     },
     {
     bigStep = 1;
     contents = "";
     frequency = "";
     resttime = "";
     slope = 5;
     smallStep = 2;
     speed = 6;
     step = "";
     strength = "";
     time = 2;
     title = "";
     },
     {
     bigStep = 1;
     contents = "";
     frequency = "";
     resttime = "";
     slope = 8;
     smallStep = 3;
     speed = 8;
     step = "";
     strength = "";
     time = 3;
     title = "";
     },
     {
     bigStep = 1;
     contents = "";
     frequency = "";
     resttime = "";
     slope = 6;
     smallStep = 4;
     speed = 6;
     step = "";
     strength = "";
     time = 2;
     title = "";
     },
     {
     bigStep = 1;
     contents = "";
     frequency = "";
     resttime = "";
     slope = 3;
     smallStep = 5;
     speed = 3;
     step = "";
     strength = "";
     time = 2;
     title = "";
     }
     )
     */
    
    NSLog(@"dataSource in lineView :: %@", dataSource);
    _dataSource = dataSource;

    totalTime = [self getTotalValueByKey:@"time"];
    maxSpeed = [self getMaxSpeed];
    
    flexibleMaxSpeed = [self getFlexibleExtremumWithRealValue:maxSpeed];
    flexibleMaxTime = (int)totalTime + 1; //[self getFlexibleExtremumWithRealValue:totalTime];
    lineAreaWidth = totalTime * (self.bounds.size.width - LEFT_MARGIN - RIGHT_MARGIN) / flexibleMaxTime;
    NSLog(@"flexibleMaxTime :: %f", flexibleMaxTime);
    _pointerLayer.position = CGPointMake(LEFT_MARGIN, [self getYLocationWithTime:0]);
    
    [self setNeedsDisplay];
}

@end
