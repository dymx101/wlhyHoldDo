//
//  WlhyRepairsEquipViewController.m
//  wlhybdc
//
//  Created by Hello on 13-8-27.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyRepairsEquipViewController.h"

#import "FTPHelper.h"
#import "WlhyImageScrollView.h"

@interface WlhyRepairsEquipViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, FTPHelperDelegate, WlhyImageScrollViewDelegate, UIActionSheetDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet WlhyUITextFieldDelegate *wlhyTextDelegate;

@property(strong, nonatomic) NSMutableArray *nameArray;
@property(strong, nonatomic) UIImagePickerController *imagePickerVC;
@property(strong, nonatomic) UIScrollView *bigPicScrollView;
@property(strong, nonatomic) IBOutlet WlhyImageScrollView *picScrollView;
@property(strong, nonatomic) IBOutlet WlhyTextField *phoneTextField;
@property(strong, nonatomic) IBOutlet UITextView *contentTextView;

- (IBAction)cancleInput:(id)sender;

@end

@implementation WlhyRepairsEquipViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"器械报修";
    
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
    
    //右侧按钮：：
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setContentMode:UIViewContentModeScaleToFill];
    [rightButton setTitle:@"提交" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_0.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_1.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(self.view.frame.size.width - 70, 0, 66, 40);
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    _phoneTextField.text = [DBM dbm].currentUsers.phone;
    _picScrollView.delegate = self;
    
    _contentTextView.layer.cornerRadius = 4;
    _contentTextView.layer.borderWidth = 1;
    _contentTextView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12].CGColor;
    _contentTextView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.75];
    
    _nameArray = [NSMutableArray array];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.view = nil;
    self.wlhyTextDelegate = nil;
    self.nameArray = nil;
    self.imagePickerVC = nil;
    self.bigPicScrollView = nil;
    self.picScrollView = nil;
    self.phoneTextField = nil;
    self.contentTextView = nil;
    self.barDecode = nil;
}

#pragma mark - button Handler

- (void)rightItemTouched:(id)sender
{
    NSLog(@"rightItemTouched");
    
    [self cancleInput:nil];
    
    if (![_phoneTextField validate]) {
        [self showText:@"手机号码填写有误"];
        return;
    }
    if (_contentTextView.text.length <= 0) {
        [self showText:@"故障描述填写有误"];
        return;
    }
    
    NSMutableString *picPath = [NSMutableString string];
    for (int i = 0; i < _nameArray.count; i++) {
        if (i == 0) {
            [picPath appendFormat:@"equip/repair/%@", [_nameArray objectAtIndex:i]];
        } else {
            [picPath appendFormat:@",equip/repair/%@", [_nameArray objectAtIndex:i]];
        }
    }
    
    [self sendFile];    //上传报修图片
    
    /*
     memberid	会员id
     pwd	登录密码
     barcodeid	二维码id
     phone	报修人电话（会员手机号）
     repairDescription	报修问题文字描述
     picPaths	损坏部位图片路径，多张用逗号隔开
     */
    
    
    [self sendRequest:
     
     @{@"memberid": ([DBM dbm].currentUsers.memberId == NULL) ? @"0" : [DBM dbm].currentUsers.memberId,
     @"pwd": ([DBM dbm].currentUsers.clearPwd == NULL) ? @"" : [DBM dbm].currentUsers.clearPwd,
     @"barcodeid": _barDecode,
     @"phone": _phoneTextField.text,
     @"repairDescription": _contentTextView.text,
     @"picPaths": picPath
     }
     
               action:wlRepairsEquipRequest
        baseUrlString:wlServer];
    
}

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"%@,-----,%@",info,error);
    
    if(!error){
        
        if(0 == [[info objectForKey:@"errorCode"] integerValue]) {
            [self showText:[info objectForKey:@"errorDesc"]];
            [self performSelector:@selector(back:) withObject:nil afterDelay:1.5f];
            
        } else {
            [self showText:[info objectForKey:@"errorDesc"]];
        }
        
    }else{
        [self showText:@"连接服务器失败，请稍后再试..."];
    }
}


- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancleInput:(id)sender
{
    [self.view endEditing:NO];
}

#pragma mark - get Pic

- (void)takeByCamera
{
    NSLog(@"takeByCamera");
    
    if (_imagePickerVC == nil) {
        _imagePickerVC = [[UIImagePickerController alloc] init];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        _imagePickerVC.sourceType =  UIImagePickerControllerSourceTypeCamera;
        _imagePickerVC.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:_imagePickerVC.sourceType];
    }
    
    _imagePickerVC.delegate = self;
    _imagePickerVC.allowsEditing = YES;
    [self presentModalViewController:_imagePickerVC animated:YES];
}

- (void)takeByPhotoLibrary
{
    NSLog(@"takeByPhotoLibrary");
    
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

#pragma mark - UIImagePickerController Delegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    picker = nil;
    
    UIImage *pickerImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    NSData *dataImg = UIImageJPEGRepresentation(pickerImage, 0.3f);
    NSString *picName = [[NSString alloc] initWithFormat:@"%@%@.jpg", _barDecode, getDateStringWithNSDateAndDateFormat([NSDate date], @"yyyyMMddhhmmss")];
    
    [_picScrollView.addedPicArray addObject:dataImg];
    [_nameArray addObject:picName];
    
    [_picScrollView refreshScrollView];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
    picker = nil;
}

//send File

- (void)sendFile
{
	[self setFTP];
    
    for (int i = 0; i < _picScrollView.addedPicArray.count; i++) {
        [FTPHelper uploadByData:[_picScrollView.addedPicArray objectAtIndex:i] fileName:[_nameArray objectAtIndex:i]];
    }
}

 
-(void)setFTP
{
    [FTPHelper sharedInstance].delegate = self;
	
	//最好改用Preference Setting
    [FTPHelper sharedInstance].urlString = @"ftp://www.holddo.com/equip/repair/";
	[FTPHelper sharedInstance].uname = [DBM dbm].currentUsers.ftpAccount;
	[FTPHelper sharedInstance].pword = [DBM dbm].currentUsers.ftpPwd;
	
}


#pragma mark - FTP Delegate

// Successes
- (void) receivedListing: (NSDictionary *) listing;
{
    NSLog(@"listing");
}
- (void) downloadFinished
{
    NSLog(@"finish");
}
- (void) dataUploadFinished: (NSNumber *) bytes
{
    NSLog(@"data upload finish :: %@", bytes);
    [self showText:@"报修图片上传成功"];
}
- (void) progressAtPercent: (NSNumber *) aPercent
{
    NSLog(@"percent :: %f", [aPercent floatValue]);
}


// Failures
- (void) listingFailed
{
}
- (void) dataDownloadFailed: (NSString *) reason
{
}
- (void) dataUploadFailed: (NSString *) reason
{
}
- (void) credentialsMissing
{
}

#pragma mark - Image ScrollView Delegate

- (void)addPic
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选取坏点图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照" , @"系统相册", nil];
    [actionSheet showInView:self.view];
}

- (void)showBigPicAtIndex:(NSInteger)index
{
    if (_bigPicScrollView == nil) {
        _bigPicScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    }
    
    if (![[self.view subviews] containsObject:_bigPicScrollView]) {
        [self.view addSubview:_bigPicScrollView];
    }
    
    _bigPicScrollView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    _bigPicScrollView.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollImageTap:)];
    [_bigPicScrollView addGestureRecognizer:tap];
    
    
    UIImage *image = [UIImage imageWithData:[_picScrollView.addedPicArray objectAtIndex:index]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    
    
    [_bigPicScrollView addSubview:imageView];
    
    [_bigPicScrollView setContentSize:imageView.frame.size];
    [_bigPicScrollView setZoomScale:0.3 animated:YES];
}

- (void)removePicAtIndex:(NSInteger)index
{
    [_picScrollView.addedPicArray removeObjectAtIndex:index];
    [_picScrollView refreshScrollView];
    [_nameArray removeObjectAtIndex:index];
}

- (void)scrollImageTap:(id)sender
{
    [_bigPicScrollView removeFromSuperview];
    _bigPicScrollView = nil;
}

#pragma mark - actionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet : %i", buttonIndex);
    
    switch (buttonIndex) {
        case 0:
            [self takeByCamera];
            break;
        case 1:
            [self takeByPhotoLibrary];
            break;
        default:
            break;
    }
}

@end
