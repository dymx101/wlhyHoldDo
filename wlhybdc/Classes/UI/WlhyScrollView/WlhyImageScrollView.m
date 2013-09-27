//
//  WlhyImageScrollView.m
//  HorizontalScrollViewDemo
//
//  Created by Hello on 13-9-2.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "WlhyImageScrollView.h"

#import <QuartzCore/QuartzCore.h>

#define  PIC_WIDTH 100
#define  PIC_HEIGHT 100
#define  INSETS 5



@interface WlhyImageScrollView ()
{
    
}

@property (strong, nonatomic) UIScrollView *picScroller;
@property (strong, nonatomic) UIButton *plusButton;

@end


@implementation WlhyImageScrollView


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _addedPicArray =[[NSMutableArray alloc] init];
        
        _picScroller = [[UIScrollView alloc] init];
        _picScroller.showsHorizontalScrollIndicator = YES;
        [self addSubview:_picScroller];
        
        _plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_plusButton setFrame:CGRectMake(INSETS, INSETS, PIC_WIDTH, PIC_HEIGHT)];
        [_plusButton setImage:[UIImage imageNamed:@"plus_icon.png"] forState:UIControlStateNormal];
        [_plusButton addTarget:self action:@selector(addPicButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [_picScroller addSubview:_plusButton];
        
    }
    return self;
}

- (void)didMoveToSuperview
{
    [_picScroller setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

- (void)refreshScrollView
{
    for (UIView *tempView in [_picScroller subviews]) {
        if (tempView == _plusButton) {
            continue;
        }
        [tempView removeFromSuperview];
    }
    
    
    
    for (int i = 0; i < _addedPicArray.count; i++) {
        
        UIImage *image = [UIImage imageWithData:[_addedPicArray objectAtIndex:i]];
        
        UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [imageButton setImage:image forState:UIControlStateNormal];
        [imageButton setFrame:CGRectMake(INSETS + i*(PIC_WIDTH + INSETS), INSETS, PIC_WIDTH, PIC_HEIGHT)];
        [imageButton setTag:i+1100];
        [imageButton addTarget:self action:@selector(imageButtonTouched:)
              forControlEvents:UIControlEventTouchUpInside];
        
        /*
        CABasicAnimation *positionAnim=[CABasicAnimation animationWithKeyPath:@"position"];
        [positionAnim setFromValue:[NSValue valueWithCGPoint:CGPointMake(imageButton.center.x, imageButton.center.y)]];
        [positionAnim setToValue:[NSValue valueWithCGPoint:CGPointMake(INSETS + i*(PIC_WIDTH + INSETS), imageButton.center.y)]];
        [positionAnim setDelegate:self];
        [positionAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [positionAnim setDuration:0.25f];
        [imageButton.layer addAnimation:positionAnim forKey:nil];
        [imageButton setCenter:CGPointMake(INSETS + i*(PIC_WIDTH + INSETS), imageButton.center.y)];
        */
         
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setImage:[UIImage imageNamed:@"deleteTag.png"] forState:UIControlStateNormal];
        [deleteButton setFrame:CGRectMake(-10, -10, 30, 30)];
        [deleteButton setTag:i+1200];
        [deleteButton addTarget:self action:@selector(deleteButtonTouched:)
               forControlEvents:UIControlEventTouchUpInside];
        [imageButton addSubview:deleteButton];
        
        [_picScroller addSubview:imageButton];
    }
    
    //移动添加按钮
    /*
    CABasicAnimation *positionAnim=[CABasicAnimation animationWithKeyPath:@"position"];
    [positionAnim setFromValue:[NSValue valueWithCGPoint:CGPointMake(_plusButton.center.x, _plusButton.center.y)]];
    [positionAnim setToValue:[NSValue valueWithCGPoint:CGPointMake(_plusButton.center.x+INSETS+PIC_WIDTH, _plusButton.center.y)]];
    [positionAnim setDelegate:self];
    [positionAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [positionAnim setDuration:0.25f];
    [_plusButton.layer addAnimation:positionAnim forKey:nil];
    [_plusButton setCenter:CGPointMake(_plusButton.center.x+INSETS+PIC_WIDTH, _plusButton.center.y)];
     */
    
    [_plusButton setFrame:CGRectMake(_addedPicArray.count *(PIC_WIDTH+INSETS), INSETS, PIC_WIDTH, PIC_HEIGHT)];
    
    _plusButton.enabled = YES;
    if (_addedPicArray.count >= 5) {
        _plusButton.enabled = NO;
    }
    
    [_picScroller setContentSize:CGSizeMake((_addedPicArray.count+1) *(PIC_WIDTH+INSETS), self.frame.size.height)];
    [_picScroller scrollRectToVisible:CGRectMake((_addedPicArray.count+1) *(PIC_WIDTH+INSETS), INSETS, self.frame.size.height, self.frame.size.height) animated:YES];
    
}


- (void)imageButtonTouched:(id)sender
{
    
    NSInteger tag = [(UIButton *)sender tag] - 1100;
    [_delegate showBigPicAtIndex:tag];
}

- (void)deleteButtonTouched:(id)sender
{
    
    NSInteger tag = [(UIButton *)sender tag] - 1200;
    [_delegate removePicAtIndex:tag];
}

- (void)clearPics:(id)sender
{
    
    [_addedPicArray removeAllObjects];
    
    CABasicAnimation *positionAnim=[CABasicAnimation animationWithKeyPath:@"position"];
    [positionAnim setFromValue:[NSValue valueWithCGPoint:CGPointMake(_plusButton.center.x, _plusButton.center.y)]];
    [positionAnim setToValue:[NSValue valueWithCGPoint:CGPointMake(INSETS+PIC_WIDTH/2, _plusButton.center.y)]];
    [positionAnim setDelegate:self];
    [positionAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [positionAnim setDuration:0.25f];
    
    [_plusButton.layer addAnimation:positionAnim forKey:nil];
    
    [_plusButton setCenter:CGPointMake(INSETS+PIC_WIDTH/2, _plusButton.center.y)];
    [self refreshScrollView];
}

- (void)addPicButtonTouched:(id)sneder
{
    [_delegate addPic];
}

@end
