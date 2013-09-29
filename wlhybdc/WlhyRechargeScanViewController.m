//
//  WlhyRechargeScanViewController.m
//  wlhybdc
//
//  Created by Hello on 13-9-9.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyRechargeScanViewController.h"

#import "ZBarReaderView.h"

@interface WlhyRechargeScanViewController () <ZBarReaderViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>


@property(strong, nonatomic) ZBarReaderView *readerView;
@property(strong, nonatomic) UIImagePickerController *imagePickerVC;

@property(strong, nonatomic) IBOutlet UIButton *button1;
@property(strong, nonatomic) IBOutlet UIButton *button2;
@property(strong, nonatomic) IBOutlet UIButton *button3;
@property(strong, nonatomic) IBOutlet UIButton *button4;

@property(strong, nonatomic) IBOutlet UIView *inputView;
@property(strong, nonatomic) IBOutlet UITextField *inputField1;
@property(strong, nonatomic) IBOutlet UITextField *inputField2;

@property(strong, nonatomic) IBOutlet UIView *buttonsView;
@property(strong, nonatomic) IBOutlet UIImageView *scanBackgroundImageView;  //不删

- (IBAction)button1Tapped:(id)sender;
- (IBAction)button2Tapped:(id)sender;
- (IBAction)button3Tapped:(id)sender;
- (IBAction)button4Tapped:(id)sender;

- (IBAction)inputOK:(id)sender;

@end



@implementation WlhyRechargeScanViewController

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
    
    UIImage * navbkg = [UIImage imageNamed:@"nav_bg.png"];   //main_img.png  top_bg.png
    UIImageView *titleView = [[UIImageView alloc] initWithImage:navbkg];
    [self.navigationItem setTitleView:titleView];
    
    [self.view removeAllSubViews];
    [self.view addSubview:_scanBackgroundImageView];
    _readerView = [ZBarReaderView new]; // 初始化
    _readerView.readerDelegate = self;       // 设置delegate
    _readerView.allowsPinchZoom = NO;       // 不使用Pinch手势变焦
    [self.view insertSubview:_readerView belowSubview:_scanBackgroundImageView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    _readerView.frame = self.view.frame;
    if (![self.view.subviews containsObject:_buttonsView]) {
        [self.view addSubview:_buttonsView];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_readerView start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_readerView stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        [self setDelegate:nil];
        
        self.readerView = nil;
        self.imagePickerVC = nil;
        
        self.button1 = nil;
        self.button2 = nil;
        self.button3 = nil;
        self.button4 = nil;
        
        self.inputView = nil;
        self.inputField1 = nil;
        self.inputField2 = nil;
        self.buttonsView = nil;
        self.scanBackgroundImageView = nil;

    }
    
}


#pragma mark - readerView Delegate

- (void)readerView: (ZBarReaderView*) readerView
    didReadSymbols: (ZBarSymbolSet*) symbols
         fromImage: (UIImage*) image
{
    [_readerView stop];
    
    // 得到扫描的条码内容
    const zbar_symbol_t *symbol = zbar_symbol_set_first_symbol(symbols.zbarSymbolSet);
    if (zbar_symbol_get_type(symbol) == ZBAR_QRCODE) {  // 是否QR二维码
        
        NSString *symbolStr = [NSString stringWithUTF8String: zbar_symbol_get_data(symbol)];
        if([symbolStr canBeConvertedToEncoding:NSShiftJISStringEncoding]){
            symbolStr = [NSString stringWithCString:[symbolStr cStringUsingEncoding:NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
        }
        [_delegate finishGetCardCode:symbolStr vCode:nil];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)readerViewDidStart: (ZBarReaderView*) readerView
{
    
}

- (void)readerView: (ZBarReaderView*) readerView
  didStopWithError: (NSError*) error
{
    [_delegate failedGetBarCode:error];
    
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - UIImagePickerController Delegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //        UIImage *pickerImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        UIImage *pickerImage = [UIImage imageNamed:@"equip.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(44, 89, 233, 233)];
        [imageView setImage:pickerImage];
        [self.view addSubview:imageView];
        
        ZBarImageScanner *scanner = [ZBarImageScanner new];
        [scanner setSymbology: ZBAR_I25
                       config: ZBAR_CFG_ENABLE
                           to: 0];
        [scanner scanImage:[[ZBarImage alloc] initWithCGImage:[UIImage imageNamed:@"equip.png"].CGImage]];
        
        ZBarSymbolSet *symbols = scanner.results;
        NSLog(@"symbols :: %@", symbols);
        const zbar_symbol_t *symbol = zbar_symbol_set_first_symbol(symbols.zbarSymbolSet);
        NSLog(@"symbol :: %@", symbol); //到此处出错
        
        if (!symbol) {
            [self showText:@"不是有效的二维码图片"];
        } else if (zbar_symbol_get_type(symbol) == ZBAR_QRCODE) {  // 是否QR二维码
            NSString *symbolStr = [NSString stringWithUTF8String: zbar_symbol_get_data(symbol)];
            if([symbolStr canBeConvertedToEncoding:NSShiftJISStringEncoding]){
                symbolStr = [NSString stringWithCString:[symbolStr cStringUsingEncoding:NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
            }
            [_delegate finishGetCardCode:symbolStr vCode:nil];
            [self dismissModalViewControllerAnimated:YES];
        }
    }];
    picker = nil;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
    picker = nil;
    
    [self button1Tapped:nil];
}



#pragma mark - button Handler

//摄像头扫描：：
- (IBAction)button1Tapped:(id)sender
{
    [self.view removeAllSubViews];
    
    if (!_readerView) {
        _readerView = [ZBarReaderView new]; // 初始化
    }
    
    _readerView.readerDelegate = self;       // 设置delegate
    _readerView.allowsPinchZoom = NO;       // 不使用Pinch手势变焦
    [self.view addSubview:_scanBackgroundImageView];
    [self.view insertSubview:_readerView belowSubview:_scanBackgroundImageView];
    if (![self.view.subviews containsObject:_buttonsView]) {
        [self.view addSubview:_buttonsView];
    }
    _readerView.frame = self.view.frame;
    [_readerView stop];
    [_readerView flushCache];
    [_readerView start];
    
    _button1.selected = YES;
    _button2.selected = NO;
    _button3.selected = NO;
    _button4.selected = NO;
    
}

//从系统相册选取：：
- (IBAction)button2Tapped:(id)sender
{
    [self.view removeAllSubViews];
    if (![self.view.subviews containsObject:_buttonsView]) {
        [self.view addSubview:_buttonsView];
    }
    
    _button2.selected = YES;
    _button1.selected = NO;
    _button3.selected = NO;
    _button4.selected = NO;
    
    [_readerView stop];
    _readerView = nil;
    
    if (_imagePickerVC == nil) {
        _imagePickerVC = [[UIImagePickerController alloc] init];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        _imagePickerVC.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePickerVC.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:_imagePickerVC.sourceType];
    }
    
    _imagePickerVC.delegate = self;
    _imagePickerVC.allowsEditing = YES;
    [self presentModalViewController:_imagePickerVC animated:YES];
}

//从手动输入：：
- (IBAction)button3Tapped:(id)sender
{
    [self.view removeAllSubViews];
    if (![self.view.subviews containsObject:_buttonsView]) {
        [self.view addSubview:_buttonsView];
    }
    
    if (!_inputView) {
        _inputView = [[UIView alloc] init];
    }
    
    if (![self.view.subviews containsObject:_inputView]) {
        [self.view addSubview:_inputView];
    }
    
    
    _button3.selected = YES;
    _button1.selected = NO;
    _button2.selected = NO;
    _button4.selected = NO;
    
    
    [_readerView stop];
    _readerView = nil;
}

//取消：：
- (IBAction)button4Tapped:(id)sender
{
    [self.view removeAllSubViews];
    if (![self.view.subviews containsObject:_buttonsView]) {
        [self.view addSubview:_buttonsView];
    }
    
    _button4.selected = YES;
    _button1.selected = NO;
    _button2.selected = NO;
    _button3.selected = NO;
    
    [_readerView stop];
    _readerView = nil;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [_delegate cancelZBarScan:self];
    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)inputOK:(id)sender
{
    [_inputView endEditing:NO];
    if (_inputField1.text.length <= 0 || _inputField2.text.length <= 0) {
        [self showText:@"请检查您的输入"];
        return;
    }
    
    [_delegate finishGetCardCode:_inputField1.text vCode:_inputField2.text];
    [self dismissModalViewControllerAnimated:YES];
}

@end
