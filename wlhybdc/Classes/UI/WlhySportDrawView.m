//
//  WlhySportDrawView.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-23.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhySportDrawView.h"

#define kLineColor [UIColor blackColor].CGColor
#define kLineWidth (2.0f)

#define kPointColor [UIColor greenColor]
#define kPointSize (8.0f)

#define kPathAnimationKeyPath @"position"


@interface PointLayer : CALayer

@end

@implementation PointLayer

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
        CGContextSetFillColorWithColor(ctx, kPointColor.CGColor);
        CGContextFillPath(ctx);
    }
    CGContextRestoreGState(ctx);
}

@end

//========================================================================

@interface WlhySportDrawView()
{
    NSUInteger _currentPart;
}
@property (nonatomic, strong) PointLayer *pointLayer;

@end

@implementation WlhySportDrawView

@synthesize pad=_pad;
@synthesize origin=_origin;
@synthesize x_scale=_x_scale;
@synthesize y_scale=_y_scale;
@synthesize x_unit=_x_unit;
@synthesize y_unit=_y_unit;
@synthesize continueTime=_continueTime;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        _pad = 40.0f;
        _origin = CGPointMake(_pad, self.frame.size.height-_pad);
        _x_scale=30.0f;
        _y_scale=20.0f;
        _x_unit=10;
        _y_unit=5;
        _currentPart=0;
        self.pointLayer = [PointLayer layer];
        self.pointLayer.frame = CGRectMake(0, 0, kPointSize, kPointSize);
        self.pointLayer.position=self.origin;
        [self.layer addSublayer:self.pointLayer];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    // 绘制坐标系
    if(self.needRedraw){
        
//        self.dataSource=@[@{@"speed":@"2",@"time":@"1"},
//        @{@"speed":@"2",@"time":@"10"},
//        @{@"speed":@"3",@"time":@"20"},
//        @{@"speed":@"5",@"time":@"5"},
//        @{@"speed":@"6",@"time":@"8"},
//        @{@"speed":@"4",@"time":@"10"},
//        @{@"speed":@"1",@"time":@"5"},];
        [self drawCoordinate:ctx];
        [self drawRunSportLine:ctx];
    }
    // draw text
    CGContextRestoreGState(ctx);
    self.needRedraw=NO;
}

-(void)setNeedsDisplay
{
    [super setNeedsDisplay];
    self.needRedraw=YES;
}

-(void)drawCoordinate:(CGContextRef) ctx
{
    CGContextSaveGState(ctx);
    
    CGSize cSize = CGSizeMake(self.frame.size.width-_pad-2,self.frame.size.height-_pad-2);
    
   // CGFloat xStep = cSize.width/_x_scale;
    //CGFloat yStep = cSize.height/_y_scale;
    CGContextTranslateCTM(ctx, _origin.x, _origin.y);
    
    //转换y轴方向，方便画线
    CGContextScaleCTM(ctx, 1, -1);
    
    CGContextSetLineWidth(ctx, 2.0f);
   // CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:1 green:0.671875 blue:0 alpha:1].CGColor );
    
    //x轴，y轴
    CGContextMoveToPoint(ctx, 0,cSize.height);
    CGContextAddLineToPoint(ctx, 0,0);
    CGContextAddLineToPoint(ctx, cSize.width,0);
    CGContextStrokePath(ctx);
    
    CGContextSetLineWidth(ctx, 1.5f);
   // CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor );
    
    int count = 0;
    char buf[20] = {0};
    
    CGContextSelectFont(ctx, "Helvetica", 10, kCGEncodingMacRoman);
    //CGContextSelectFont(ctx, "STHeitiSC-Light", 10, kCGEncodingMacRoman);
    //x坐标
    for (CGFloat x=0.0; x< cSize.width; x+=_x_scale) {
        CGContextMoveToPoint(ctx, x,0);
        CGContextAddLineToPoint(ctx, x, -5);
        CGContextStrokePath(ctx);
        snprintf(buf,20,"%d", count*10);
        CGContextShowTextAtPoint(ctx, x, -5-10, buf, strlen(buf));
        ++count;
    }
    
    // y坐标
    count =0;
    for (CGFloat y=0.0; y< cSize.height; y+=_y_scale) {
        CGContextMoveToPoint(ctx, 0,y);
        CGContextAddLineToPoint(ctx, -5, y);
        CGContextStrokePath(ctx);
        snprintf(buf,20,"%d", count*5);
        CGContextShowTextAtPoint(ctx, 1, y, buf, strlen(buf));
        ++count;
    }
    
    //--表示线
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor );
    CGContextMoveToPoint(ctx, 0,-_pad+10);
    CGContextAddLineToPoint(ctx, 40,-_pad+10);
    CGContextStrokePath(ctx);
    CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(15, -_pad+5, 10, 10));
    //
    NSString * str = @"当前运动段";
    //转换y轴方向,画字符串
    CGContextScaleCTM(ctx, 1, -1);
    [str drawAtPoint:CGPointMake(40, _pad-15) withFont:[UIFont systemFontOfSize:10]];
    
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    str=@"时间（Min)";
    [str drawAtPoint:CGPointMake(_x_scale*3, _pad-20) withFont:[UIFont systemFontOfSize:10]];
    
    str=@"速度(KM/H)";
    CGContextRotateCTM(ctx, -M_PI_2);
    [str drawAtPoint:CGPointMake(_y_scale, -18) withFont:[UIFont systemFontOfSize:10]];
    CGContextRestoreGState(ctx);
    
}


- (void)drawRunSportLine:(CGContextRef)ctx
{
    if(self.dataSource.count ==0){
        return;
    }
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, _origin.x, _origin.y);
    //转换y轴方向，方便画线
    CGContextScaleCTM(ctx, 1, -1);
    
    CGContextSetLineWidth(ctx, 2.0f);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:1 green:0.671875 blue:0 alpha:1].CGColor );

    //NSDictionary *d = [self.dataSource objectAtIndex:0];
    CGFloat time = 0;//[[d objectForKey:@"time"] floatValue];
    CGFloat speed =0;// [[d objectForKey:@"speed"] floatValue];
    CGFloat x=0;//=(_x_scale/_x_unit)*time;
    CGFloat y=0;//(_y_scale/_y_unit)*speed;
    CGPoint p = CGPointMake(0, y);
    CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
//
    NSUInteger  count = 0;
    for(NSDictionary* d in self.dataSource){
        time = [[d objectForKey:@"time"] floatValue]+time;
        speed = [[d objectForKey:@"speed"] floatValue];
        x=(_x_scale/_x_unit)*time;
        y=(_y_scale/_y_unit)*speed;
        if(count == self.currentStep){
            CGContextMoveToPoint(ctx, p.x, p.y);
            CGContextAddLineToPoint(ctx, p.x, y);
            CGContextStrokePath(ctx);
            CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor );
            
            CGContextMoveToPoint(ctx,  p.x, y);
            CGContextAddLineToPoint(ctx, x, y);
            CGContextStrokePath(ctx);
            CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:1 green:0.671875 blue:0 alpha:1].CGColor );
            
        }else{
            CGContextMoveToPoint(ctx, p.x, p.y);
            CGContextAddLineToPoint(ctx, p.x, y);
            CGContextAddLineToPoint(ctx, x, y);
            CGContextStrokePath(ctx);
        }
        ++count;

        CGContextFillEllipseInRect(ctx, CGRectMake(p.x-2, y-2, 4, 4));
        p.x=x;
        p.y=y;
        CGContextFillEllipseInRect(ctx, CGRectMake(p.x-2, p.y-2, 4, 4));
    }
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
}
-(void)start
{
    CABasicAnimation* animat = [CABasicAnimation animationWithKeyPath:@"position.x"];
    animat.delegate=self;
    animat.duration=10;
    [self.pointLayer setValue:@100 forKeyPath:@"position.x"];
    [self.pointLayer addAnimation:animat forKey:@"pointlayX"];
}

-(void)stop
{
    [self.pointLayer removeAnimationForKey:@"pointlayX"];
}

-(void)pause
{
    CFTimeInterval interval = [self.pointLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.pointLayer.speed=0.0;
    self.pointLayer.timeOffset=interval;
    
}

-(void)resume
{
    CFTimeInterval pausedTime = [self.pointLayer timeOffset];
    self.pointLayer.speed = 1.0;
    self.pointLayer.timeOffset = 0.0;
    self.pointLayer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self.pointLayer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.pointLayer.beginTime = timeSincePause;
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    NSLog(@"string");
}

- (void)setContinueTime:(NSTimeInterval)continueTime
{
    _continueTime=continueTime;
    
    if(self.currentStep >= self.dataSource.count){
        return;
    }

    CGFloat speed = [[[self.dataSource objectAtIndex:self.currentStep] objectForKey:@"speed"]floatValue];

    
    CGFloat y=_origin.y-(_y_scale/_y_unit)*speed ;
    [self.pointLayer setValue:[NSNumber numberWithFloat:y] forKeyPath:@"position.y"];
    
    CGFloat x = (_continueTime/self.timeSpan);
    x = (_x_scale/_x_unit)*x + _origin.x;
    [self.pointLayer setValue:[NSNumber numberWithFloat:x] forKeyPath:@"position.x"];

}


- (CGFloat)getTotalByKey:(NSString*)key
{
    CGFloat  total = 0.0f;
    for (NSDictionary *dict in self.dataSource) {
        total += [[dict objectForKey:key] floatValue];
    }
    return total;
}
@end
