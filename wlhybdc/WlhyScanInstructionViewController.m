//
//  WlhyScanInstructionViewController.m
//  wlhybdc
//
//  Created by Hello on 13-9-2.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyScanInstructionViewController.h"

#import "SGdownloader.h"
#import "FileManage.h"

@interface WlhyScanInstructionViewController () <SGdownloaderDelegate, UIWebViewDelegate>

@property(strong, nonatomic) SGdownloader *downLoader;
@property(strong, nonatomic) FileManage *fileManage;

@property(strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WlhyScanInstructionViewController

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
	
    self.title = @"器械使用说明书";
    
    //自定义返回：：
    self.navigationItem.hidesBackButton = YES;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setContentMode:UIViewContentModeScaleToFill];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back_1.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 62, 40);
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
    _fileManage = [FileManage fileManage];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *instructionFileName = [_instructionPath substringFromIndex:51];
    NSString *instructionFilePath = [[FileManage documentsPath] stringByAppendingPathComponent:instructionFileName];
    
    if ([_fileManage getDataFromFile:instructionFilePath] == nil) {
        //没有本地数据，则开始下载：：
        if (_downLoader == nil) {
            _downLoader = [[SGdownloader alloc] initWithURL:[NSURL URLWithString:_instructionPath] timeout:20];
        }
        [_downLoader startWithDelegate:self];
        
    } else {
        //有已经下载好的本地说明书：：
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:instructionFilePath]]];
    }
}

- (void)viewDidUnload
{
    self.instructionPath = nil;
    self.fileManage = nil;
    self.webView = nil;
    self.downLoader = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - SGDownload Delegate

-(void)SGDownloadProgress:(float)progress Percentage:(NSInteger)percentage
{
    [self showText:@"正在下载使用说明书"];
}
-(void)SGDownloadFinished:(NSData*)fileData
{
    [self showText:@"电子使用说明书下载成功"];
    
    NSString *instructionFileName = [_instructionPath substringFromIndex:51];
    NSString *instructionFilePath = [[FileManage documentsPath] stringByAppendingPathComponent:instructionFileName];
    [_fileManage writeData:fileData toFile:instructionFilePath];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:instructionFilePath]]];
    
}
-(void)SGDownloadFail:(NSError*)error
{
    [self showText:@"电子使用说明书下载失败"];
}



@end
