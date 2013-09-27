//
//  AOScrollerView.m
//  AOImageViewDemo
//
//  Created by akria.king on 13-4-2.
//  Copyright (c) 2013年 akria.king. All rights reserved.
//

#import "AOScrollerView.h"


@interface AOScrollerView ()
{
    int pageNumer;//页码
    int switchDirection;//方向
    NSMutableArray *imageNameArr;//图片数组
    NSMutableArray *titleStrArr;//标题数组
    
    UIScrollView *imageSV;//滚动视图
    int page;//页码
}

@end


@implementation AOScrollerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setNameArr:(NSMutableArray *)imageArr titleArr:(NSMutableArray *)titleArr
{
 
    page=0;//设置当前页为1
    
    imageNameArr = imageArr;
    titleStrArr=titleArr;
    
    int imageCount = [imageNameArr count];
    
    [imageSV removeFromSuperview];
    for (UIView *tempView in [imageSV subviews]) {
        [tempView removeFromSuperview];
    }
    
    if (imageSV == nil) {
        imageSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    
    imageSV.directionalLockEnabled = YES;//锁定滑动的方向
    imageSV.pagingEnabled = YES;//滑到subview的边界
    
    imageSV.showsVerticalScrollIndicator = NO;//不显示垂直滚动条
    imageSV.showsHorizontalScrollIndicator = NO;//不显示水平滚动条
    
    
    CGSize newSize = CGSizeMake(self.frame.size.width * imageCount,  imageSV.frame.size.height);//设置scrollview的大小
    [imageSV setContentSize:newSize];
    [self addSubview:imageSV];
    //*********************************
    //添加图片视图
    for (int i=0; i<imageCount; i++) {
        NSString *str = @"";
        if (i<titleStrArr.count) {
            
            str=[titleStrArr objectAtIndex:i];
        }
        //创建内容对象
        AOImageView *imageView = [[AOImageView alloc]
                                  initWithImageName:[imageArr objectAtIndex:i]
                                  title:str
                                  x:self.frame.size.width*i
                                  y:0
                                  width: self.frame.size.width
                                  height:imageSV.frame.size.height];
        //制定AOView委托
        imageView.uBdelegate=self;
        //设置视图标示
        imageView.tag=i;
        //添加视图
        [imageSV addSubview:imageView];
    }
    
    if (imageCount > 1) {
        [NSTimer scheduledTimerWithTimeInterval:4.5 target:self selector:@selector(changeView) userInfo:nil repeats:YES];
    }
    
}

//NSTimer方法
- (void)changeView
{
    //修改页码
    if (page == 0) {
        switchDirection = rightDirection;
    }else if(page == imageNameArr.count-1){
        switchDirection = leftDirection;
    }
    if (switchDirection == rightDirection) {
        page ++;
    }else if (switchDirection == leftDirection){
        page --;
    }

    //page++;
//    //判断是否大于上线
//    if (page==imageNameArr.count) {
//        //重置页码
//        page=0;
//    }
    //设置滚动到第几页
    [imageSV setContentOffset:CGPointMake(self.frame.size.width*page, 0) animated:YES];
    
    
    
}


#pragma UBdelegate

-(void)click:(int)vid
{
    //调用委托实现方法
    [self.vDelegate buttonClick:vid];
}
@end
