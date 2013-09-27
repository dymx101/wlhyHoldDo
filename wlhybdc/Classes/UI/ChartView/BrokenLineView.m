//
//  CurveChartView.m
//  ScrollViewTest
//
//  Created by miracles3 on 13-4-22.
//  Copyright (c) 2013年 miracles3. All rights reserved.
//

#import "BrokenLineView.h"

#import <QuartzCore/QuartzCore.h>
#import "BrokenScrollView.h"


#define LEFT_MARGIN 20
#define BOTTOM_MARGIN 0
#define X_Inteval 50
#define YLABEL_NUMBER 10           //Y轴上要显示多少个坐标文字


@interface BrokenLineView ()
{
    float chartViewWidth;
    
}


@property(strong, nonatomic) UIScrollView *scrollView;
@property(strong, nonatomic) BrokenScrollView *brokenScrollView;

@end



@implementation BrokenLineView



#pragma mark - init
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _max = 300.0f;
        _min = 0.0f;
        
    }
    return self;
}


- (void)setDataArray:(NSArray *)kDataArray
{
    _dataArray = kDataArray;
    
    chartViewWidth = X_Inteval * self.dataArray.count + X_Inteval/2;
    
    //scrollView容纳曲线图中可拖动的部分左右滚动展示：：
    _scrollView = [[UIScrollView alloc] initWithFrame:
                  CGRectMake(LEFT_MARGIN, 0,
                             self.bounds.size.width- LEFT_MARGIN,
                             self.bounds.size.height - BOTTOM_MARGIN)];
    _scrollView.contentSize = CGSizeMake(chartViewWidth, _scrollView.bounds.size.height);
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.alwaysBounceVertical = NO;
    
    //确定scrollView内容视图的相关属性
    _brokenScrollView = [[BrokenScrollView alloc] initWithFrame:
                     CGRectMake(0, 0, chartViewWidth, _scrollView.bounds.size.height)
                                               dataArray:self.dataArray];
    
    _brokenScrollView.max = _max;
    _brokenScrollView.min = _min;
    
    [_scrollView addSubview:_brokenScrollView];
    [self addSubview:_scrollView];
    
    [self setNeedsDisplay];
}


#pragma mark -drawRect
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 0.8);
    
    //绘制X轴直线：：
    CGContextMoveToPoint(context, LEFT_MARGIN,
                         _scrollView.bounds.size.height-X_LABEL_HEIGHT);
    CGContextAddLineToPoint(context, self.bounds.size.width,
                            _scrollView.bounds.size.height-X_LABEL_HEIGHT);
    CGContextStrokePath(context);
    
    //------绘制左侧Y轴：：-------
    CGContextMoveToPoint(context, LEFT_MARGIN, 0);
    CGContextAddLineToPoint(context, LEFT_MARGIN,
                            _scrollView.bounds.size.height-X_LABEL_HEIGHT);
    CGContextStrokePath(context);
    
    //绘制左侧Y轴的刻度文字和横向网线：：
    CGContextSaveGState(context);
    
    CGContextSetRGBFillColor(context, 0, 0, 0, 0.8);
    float lineInterval = (self.bounds.size.height - BOTTOM_MARGIN - X_LABEL_HEIGHT)/YLABEL_NUMBER;
    float valueInteval = (_max - _min)/YLABEL_NUMBER;
    
    NSString *yValueString;
    for (int i = 0; i <= YLABEL_NUMBER; i++) {
        //绘制Y轴刻度数量的数字：：
        yValueString = [NSString stringWithFormat:@"%.0f", _max - i * valueInteval];
        CGRect yValueRect = CGRectMake(0, lineInterval * i, LEFT_MARGIN, 30);
        [yValueString drawInRect:yValueRect
                        withFont:[UIFont systemFontOfSize:10]
                   lineBreakMode:NSLineBreakByWordWrapping
                       alignment:NSTextAlignmentRight];
        
        //绘制横线网格：：
        if (i == YLABEL_NUMBER) {
            continue;
        }
        float lengths[] = {8,8};
        CGContextSetLineDash(context, 0, lengths, 1);
        CGContextSetLineWidth(context, 1);
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 0.2);
        
        CGContextMoveToPoint(context, LEFT_MARGIN, lineInterval * i);
        CGContextAddLineToPoint(context, self.bounds.size.width,
                                lineInterval * i);
        CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);
    
}


@end
