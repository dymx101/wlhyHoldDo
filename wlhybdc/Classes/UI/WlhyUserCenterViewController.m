//
//  WlhyUserCenterViewController.m
//  wlhybdc
//
//  Created by linglong meng on 12-11-12.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyUserCenterViewController.h"

#import "WlhyFloatView.h"
#import "FTPHelper.h"
#import "WlhyXMPP.h"

@interface WlhyUserCenterViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FTPHelperDelegate, NSURLConnectionDataDelegate>

@property(strong, nonatomic) UIImage *pickerImage;
@property(strong, nonatomic) NSMutableData *imageData;
@property(strong, nonatomic) UIImagePickerController *imagePickerVC;

@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *memberLevelLabel;
@property (strong, nonatomic) IBOutlet UILabel *intergralLabel;
@property (strong, nonatomic) IBOutlet UILabel *userStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *HDILabel;
@property (strong, nonatomic) IBOutlet UILabel *manifestoLabel;

@property (strong, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalEnergy;

@property (strong, nonatomic) IBOutlet UIImageView *isVipImage;

@property (strong, nonatomic) IBOutlet WlhyFloatView *serviceStarImages;


- (IBAction)imageTouched:(id)sender;
- (IBAction)logout:(id)sender;

@end

@implementation WlhyUserCenterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - VC lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"个人中心";
    
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
    [rightButton setTitle:@"账户" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_0.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_1.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(self.view.frame.size.width - 70, 0, 66, 40);
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self getHeadPic];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    DBM *dbm =[DBM dbm];
    NSString* name = dbm.currentUsers.userName;
    if(IsEmptyString(name)){
        name = [dbm.currentUsers.memberId stringValue];
    }
    self.nameLabel.text=WlhyString(WlhyString(name));
    
    NSNumber * mbl = dbm.usersExt.memLevel;
    NSString * str = @"0";
    if(mbl){
        str = [mbl stringValue];
    }
    self.memberLevelLabel.text=str;
    self.intergralLabel.text=WlhyString(dbm.usersExt.integral);
    self.totalTimeLabel.text=WlhyString(dbm.usersExt.totalTime);
    self.totalEnergy.text=WlhyString([NSString stringWithFormat:@"%.2f", [dbm.usersExt.totalEnergy floatValue]]);
    self.userStatusLabel.text= [self getMemberStatus];
    self.HDILabel.text= WlhyString(dbm.usersExt.hdi);
    
    self.manifestoLabel.numberOfLines = 0;
    NSString *manifesto = WlhyString(dbm.usersExt.manifesto);
    if (manifesto.length <= 0) {
        manifesto = @"编辑您的健身宣言";
    }
    CGSize autoSize = [manifesto sizeWithFont:[UIFont systemFontOfSize:11.0f]
                             constrainedToSize:CGSizeMake(self.manifestoLabel.frame.size.width, 40.0)
                                 lineBreakMode:UILineBreakModeWordWrap];
    self.manifestoLabel.frame = CGRectMake(self.manifestoLabel.frame.origin.x,
                                           75.0,
                                           self.manifestoLabel.frame.size.width,
                                           autoSize.height);
    self.manifestoLabel.text = manifesto;
    
    self.isVipImage.hidden = ![dbm.usersExt.isVip boolValue];
    int star = [dbm.usersExt.serviceStar integerValue];
    for(UIView *v in self.serviceStarImages.subviews){
        [v removeFromSuperview];
        
    }
    if(star >=41 && star <=43){
        star -=40;
        for (int i = 0; i < star; i++) {
            UIImageView * view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dj_img"]];
            [self.serviceStarImages addSubview:view];
        }
        [self.serviceStarImages setNeedsLayout];
    }
    
}

- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
    }
    self.headImageView = nil;
    self.nameLabel = nil;
    self.memberLevelLabel = nil;
    self.intergralLabel = nil;
    self.userStatusLabel = nil;
    self.HDILabel = nil;
    self.manifestoLabel = nil;
    self.totalTimeLabel = nil;
    self.totalEnergy = nil;
    self.isVipImage = nil;
    self.serviceStarImages = nil;
    
    self.imagePickerVC = nil;
    self.pickerImage = nil;
    self.imageData = nil;
    
}

- (IBAction)imageTouched:(id)sender
{
    NSLog(@"sender :: %@", sender);
    
    //更换头像：：
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"更换头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照" , @"系统相册", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)logout:(id)sender
{
    /*
     memberId
     Imei
     pwd
     */
    
    if ([DBM dbm].isLogined == NO) {
        //还未登陆，无法执行注销：：
        return;
    }
    
    [self sendRequest:
     
     @{
     @"memberId": [DBM dbm].currentUsers.memberId,
     @"Imei": [OpenUDID value],
     @"pwd": [DBM dbm].currentUsers.pwd
     }
     
               action:wlLogoutRequest
        baseUrlString:wlServer];
    
}


#pragma mark - processRequest

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_headImageView setImage:[UIImage imageWithData:_imageData]];
}

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"%@,-----,%@", info, error);
    
    if(!error){
        if ([action isEqualToString:wlLogoutRequest]) {
            
            if([[info objectForKey:@"errorCode"] integerValue] == 0){
                
                [self showText:@"账号已注销"];
                
                Users *obj = [[DBM dbm] getUserByMemberId: [[DBM dbm].currentUsers.memberId stringValue]];
                [obj setValue:[NSNumber numberWithBool: NO] forKey:@"autologin"];
                [[DBM dbm] saveContext];
                
                [[WlhyXMPP WlhyXMPP] disconnect];
                
                [DBM dbm].isLogined = NO;
                [DBM dbm].currentUsers = nil;
                [DBM dbm].usersExt = nil;
                [DBM dbm].prescription = nil;
                [DBM dbm].currentUsers.autologin = [NSNumber numberWithBool:NO];
                
                [self performSelector:@selector(pushLoginVC:) withObject:nil afterDelay:1.0f];
            } else {
                [self showText:[info objectForKey:@"errorDesc"]];
            }
        }
        
    }else{
        [self showText:@"连接服务器失败，请稍后再试..."];
    }
}

- (void)pushLoginVC:(id)sender
{
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyLoginViewController"];
    if (destVC) {
        [self.navigationController pushViewController:destVC animated:YES];
    }
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

#pragma mark - Avatar

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
    
    NSLog(@"image info :: %@", info);
    
    _pickerImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    _pickerImage = [_pickerImage transformToSize:CGSizeMake(240.0, 240.0)];
    NSData *dataImg = UIImageJPEGRepresentation(_pickerImage, 0.3f);
    NSString *picName = [[NSString alloc] initWithFormat:@"%@.jpg", [DBM dbm].currentUsers.phone];
    [self sendFileByData:dataImg fileName:picName];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
    picker = nil;
}
-(void)sendFileByData:(NSData *)fileData fileName:(NSString *)name
{
	[self setFTP];
	[FTPHelper uploadByData:fileData fileName:name];
}
-(void)setFTP
{
    [FTPHelper sharedInstance].delegate = self;
	
	//最好改用Preference Setting
    [FTPHelper sharedInstance].urlString = @"ftp://www.holddo.com/member/";
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
    [self showText:@"头像更换成功"];
    //picPath = "http://www.holddo.com:80/bdcServer/img/member/12345678963.jpg";
    [DBM dbm].usersExt.picPath = [NSString stringWithFormat:@"http://www.holddo.com:80/bdcServer/img/member/%@.jpg",
                                  [DBM dbm].usersExt.phone];
    [self getHeadPic];
}
- (void) progressAtPercent: (NSNumber *) aPercent
{
    NSLog(@"percent");
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



#pragma mark - Private

- (void)getHeadPic
{
    
    NSString *picString = [DBM dbm].usersExt.picPath;
    
    if (picString == nil || [picString isEqualToString:@""]) {
        if ([[DBM dbm].usersExt.sex intValue] == 1) {
            [_headImageView setImage:[UIImage imageNamed:@"head_m.png"]];
        } else {
            [_headImageView setImage:[UIImage imageNamed:@"head_f.png"]];
        }
    } else {
        
        if (!_imageData) {
            _imageData = [NSMutableData data];
        }
        NSURL *picURL = [NSURL URLWithString:picString];
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:picURL
                                                      cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                  timeoutInterval:7];
        [NSURLConnection connectionWithRequest:imageRequest delegate:self];
    }
    
}

- (NSString *)getMemberStatus
{
    NSString *memberStatus = [[DBM dbm] usersExt].memberStatus;
    if ([memberStatus intValue] == 1) {
        return @"正常";
    } else if ([memberStatus intValue] == 2) {
        return @"服务已到期";
    }
    return @"服务未激活";
}

- (void)rightItemTouched:(id)sender
{
    NSLog(@"rightItemTouched");
    
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyAccountInfoViewController"];
    if (destVC) {
        [self.navigationController pushViewController:destVC animated:NO];
    }
    
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
