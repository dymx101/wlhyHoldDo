//
//  RatingViewController.m
//  RatingController
//
//  Created by Ajay on 2/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RatingView.h"


@interface RatingView ()
{
	UIImage *unselectedImage, *partlySelectedImage, *fullySelectedImage;
    
	float starRating, lastRating;
	float height, width; // of each image of the star!
}

@property (nonatomic, strong) UIButton *s1;
@property (nonatomic, strong) UIButton *s2;
@property (nonatomic, strong) UIButton *s3;
@property (nonatomic, strong) UIButton *s4;
@property (nonatomic, strong) UIButton *s5;


@end

@implementation RatingView

@synthesize s1, s2, s3, s4, s5;


-(void)setImagesDeselected:(NSString *)deselectedImage
			partlySelected:(NSString *)halfSelectedImage
			  fullSelected:(NSString *)fullSelectedImage
{
	unselectedImage = [UIImage imageNamed:deselectedImage];
	partlySelectedImage = halfSelectedImage == nil ? unselectedImage : [UIImage imageNamed:halfSelectedImage];
	fullySelectedImage = [UIImage imageNamed:fullSelectedImage];
	
	height=0.0; width=0.0;
	if (height < [fullySelectedImage size].height) {
		height = [fullySelectedImage size].height;
	}
	if (height < [partlySelectedImage size].height) {
		height = [partlySelectedImage size].height;
	}
	if (height < [unselectedImage size].height) {
		height = [unselectedImage size].height;
	}
	if (width < [fullySelectedImage size].width) {
		width = [fullySelectedImage size].width;
	}
	if (width < [partlySelectedImage size].width) {
		width = [partlySelectedImage size].width;
	}
	if (width < [unselectedImage size].width) {
		width = [unselectedImage size].width;
	}
	
	starRating = 0;
	lastRating = 0;
    
	s1 = [UIButton buttonWithType:UIButtonTypeCustom];
	s2 = [UIButton buttonWithType:UIButtonTypeCustom];
	s3 = [UIButton buttonWithType:UIButtonTypeCustom];
	s4 = [UIButton buttonWithType:UIButtonTypeCustom];
	s5 = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [s1 setImage:unselectedImage forState:UIControlStateNormal];
    [s1 setImage:fullySelectedImage forState:UIControlStateSelected];
	[s2 setImage:unselectedImage forState:UIControlStateNormal];
    [s2 setImage:fullySelectedImage forState:UIControlStateSelected];
    [s3 setImage:unselectedImage forState:UIControlStateNormal];
    [s3 setImage:fullySelectedImage forState:UIControlStateSelected];
    [s4 setImage:unselectedImage forState:UIControlStateNormal];
    [s4 setImage:fullySelectedImage forState:UIControlStateSelected];
    [s5 setImage:unselectedImage forState:UIControlStateNormal];
    [s5 setImage:fullySelectedImage forState:UIControlStateSelected];
    
    [s1 addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [s2 addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [s3 addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [s4 addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [s5 addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [s1 setSelected:NO];
    [s2 setSelected:NO];
    [s3 setSelected:NO];
    [s4 setSelected:NO];
    [s5 setSelected:NO];
    
	[s1 setFrame:CGRectMake(0,         0, width, height)];
	[s2 setFrame:CGRectMake(width,     0, width, height)];
	[s3 setFrame:CGRectMake(2 * width, 0, width, height)];
	[s4 setFrame:CGRectMake(3 * width, 0, width, height)];
	[s5 setFrame:CGRectMake(4 * width, 0, width, height)];

     
	[self addSubview:s1];
	[self addSubview:s2];
	[self addSubview:s3];
	[self addSubview:s4];
	[self addSubview:s5];
	
	CGRect frame = [self frame];
	frame.size.width = width * 5;
	frame.size.height = height;
	[self setFrame:frame];
}

- (void)buttonTouched:(UIButton *)sneder
{
    if (sneder == s1) {
        [self displayRating:1];
    }
    if (sneder == s2) {
        [self displayRating:2];
    }
    if (sneder == s3) {
        [self displayRating:3];
    }
    if (sneder == s4) {
        [self displayRating:4];
    }
    if (sneder == s5) {
        [self displayRating:5];
    }
    
}

-(void)displayRating:(float)rating
{
	[s1 setSelected:NO];
    [s2 setSelected:NO];
    [s3 setSelected:NO];
    [s4 setSelected:NO];
    [s5 setSelected:NO];
	
	
	if (rating >= 1) {
		[s1 setSelected:YES];
	}
	if (rating >= 2) {
		[s2 setSelected:YES];
	}
	if (rating >= 3) {
		[s3 setSelected:YES];
	}
	if (rating >= 4) {
		[s4 setSelected:YES];
	}
	if (rating >= 5) {
		[s5 setSelected:YES];
	}
	
	starRating = rating;
	lastRating = rating;
}

- (float)rating
{
	return starRating;
}

@end
