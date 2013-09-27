//
//  WlhyImageScrollView.h
//  HorizontalScrollViewDemo
//
//  Created by Hello on 13-9-2.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol WlhyImageScrollViewDelegate <NSObject>

- (void)addPic;
- (void)removePicAtIndex:(NSInteger)index;
- (void)showBigPicAtIndex:(NSInteger)index;

@end




@interface WlhyImageScrollView : UIView


@property (strong, nonatomic) NSMutableArray *addedPicArray;
@property (strong, nonatomic) id <WlhyImageScrollViewDelegate> delegate;

- (void)refreshScrollView;
- (void)clearPics:(id)sender;


@end
