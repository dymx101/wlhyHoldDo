//
//  WlhyVisitorViewController.m
//  wlhybdc
//
//  Created by ios on 13-8-10.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyVisitorViewController.h"

#import "ZBarReaderView.h"


@interface WlhyVisitorViewController () <ZBarReaderViewDelegate>

@property(strong, nonatomic) ZBarReaderView *readerView;

@property(strong, nonatomic) NSString *barDecode;


@end

@implementation WlhyVisitorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!_readerView) {
        _readerView = [ZBarReaderView new]; // 初始化
        [self.view addSubview:_readerView];
    }
    
    int h = 250;
    if ([deviceType() isEqualToString:@"NewScreen"]) {
        h = 345;
    }
    [_readerView setFrame:CGRectMake(0, 83, 320, h)];
    
    _readerView.readerDelegate = self;       // 设置delegate
    _readerView.allowsPinchZoom = NO;       // 不使用Pinch手势变焦
    
    [_readerView start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    [_readerView stop];
    
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        self.readerView = nil;
        self.barDecode = nil;
    }
}

#pragma mark - ZBarReaderView delegate

- (void) readerView: (ZBarReaderView*) readerView
     didReadSymbols: (ZBarSymbolSet*) symbols
          fromImage: (UIImage*) image
{
    
    for (ZBarSymbol *symbol in symbols) {
        _barDecode = symbol.data;
        break;
    }
    
    [self.readerView stop];
    
    if([_barDecode canBeConvertedToEncoding:NSShiftJISStringEncoding]){
        _barDecode = [NSString stringWithCString:[_barDecode cStringUsingEncoding:NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
    }
    
    //扫描到了二维码，跳到器械信息界面：：
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyEquipInfoViewController"];
    if ([destVC respondsToSelector:@selector(setBarDecode:)]) {
        [destVC setValue:_barDecode forKey:@"barDecode"];
    }
    [self.navigationController pushViewController:destVC animated:YES];
    return;
}

- (void) readerView: (ZBarReaderView*) readerView
   didStopWithError: (NSError*) error
{
    [self showText:@"二维码扫描失败"];
}

#pragma mark - StoryBoard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *destVC = segue.destinationViewController;
    [destVC setValue:@YES forKey:@"isFromVisitorVC"];
}


@end
