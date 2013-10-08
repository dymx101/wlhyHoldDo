//
//  WlhyRechargeViewController.m
//  wlhybdc
//
//  Created by linglong meng on 12-11-1.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyRechargeViewController.h"

#import "WlhyRechargeScanViewController.h"
#import "WlhyServiceClauseViewController.h"


@interface WlhyPrivateTrainCell : UITableViewCell

@property(strong, nonatomic) IBOutlet UIImageView *trainThumbImageView;
@property(strong, nonatomic) IBOutlet UIImageView *trainSexImageView;
@property(strong, nonatomic) IBOutlet UILabel *trainNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *trainAgeLabel;
@property(strong, nonatomic) IBOutlet UILabel *trainStatusLabel;
@property(strong, nonatomic) IBOutlet UILabel *trainHonorLabel;
@property(strong, nonatomic) IBOutlet UILabel *trainIntroductionLabel;
@property(strong, nonatomic) IBOutlet UILabel *trainWorkTimeLabel;

@end


@implementation WlhyPrivateTrainCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end


//==================================================================================================
//==================================================================================================


@interface WlhyRechargeViewController () <WlhyServiceClauseViewControllerDelegate, WlhyRechargeZBarDelegate, UITableViewDelegate, UITableViewDataSource>


@property(strong, nonatomic) NSArray *trainArray;


@end



@implementation WlhyRechargeViewController



- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

#pragma mark -VC life

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"私教列表";
    
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
    
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_rechargeVCPurpose == RechargeVCPurposeChangeTrain || _rechargeVCPurpose == RechargeVCPurposeSportGuide) {
        //无需扫描二维码，直接请求私教列表：：
        
        if (_trainArray) {
            return;
        }
        
        [self sendRequest:
         
         @{
         @"deptid": [DBM dbm].usersExt.deptid}
         
                   action:wlGetTrainListRequest
            baseUrlString:wlServer];
        
    } else if (_rechargeVCPurpose == RechargeVCPurposeRecharge) {
        //二维码扫描：：
        
        if (_trainArray) {
            return;
        }
        
        UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyServiceClauseViewController"];
        if ([destVC respondsToSelector:@selector(setDelegate:)]) {
            [destVC setValue:self forKey:@"delegate"];
        }
        [self presentModalViewController:destVC animated:YES];
    } else if (_rechargeVCPurpose == RechargeVCPurposeScanList) {
        //二维码扫描：：
        
        if (_trainArray) {
            return;
        }
        
        [self sendRequest:
         
         @{
         @"memberId": [DBM dbm].currentUsers.memberId,
         @"pwd": [DBM dbm].currentUsers.pwd
         }
         
                   action:wlGetAllTrainRequest
            baseUrlString:wlServer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        self.trainArray = nil;
    }
    
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - ZBar Delegate

- (void)finishGetCardCode:(NSString *)barString vCode:(NSString *)vString
{
    /*
     memberId
     pwd
     barcodeId
     barcodeType     二维码id类型，1密文；2明文 （1时barcodeId送密文，2时barcodeId送明文）
     checkcode
    */
    
    NSNumber *barcodeType = [NSNumber numberWithInt:2];
    if (!vString) {
        barcodeType = [NSNumber numberWithInt:1];
        vString = @"";
    }
    
    //充值卡扫描成功，用获得的数据去充值：：
    [self sendRequest:
     
     @{
     @"memberId":[DBM dbm].currentUsers.memberId,
     @"pwd":[DBM dbm].currentUsers.pwd,
     @"barcodeId": barString,
     @"barcodeType": barcodeType,
     @"checkcode": vString
     }
     
               action:wlUserRechargeRequest
        baseUrlString:wlServer];
    
}

- (void)failedGetBarCode:(NSError *)error
{
    
}

- (void)cancelZBarScan:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - service Clause Delegate

- (void)agreeServiceClause
{
     UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyRechargeScanViewController"];
     if ([destVC respondsToSelector:@selector(setPurposeTag:)]) {
     [destVC setValue:[NSNumber numberWithInt:0] forKey:@"purposeTag"];
     }
     if ([destVC respondsToSelector:@selector(setDelegate:)]) {
     [destVC setValue:self forKey:@"delegate"];
     }
     
     [self presentModalViewController:destVC animated:YES];
}

- (void)disagreeServiceClause
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - net reponse

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"info :: %@ --- error :: %@", info, error);
    
    
    if(info){
        
        NSNumber* errorCode = [info objectForKey:@"errorCode"];
        
        if ([action isEqualToString:wlUserRechargeRequest]) {
            if(errorCode.intValue == 0){
                //激活成功：：
                
                /*
                 {
                 clubid = 001003015;
                 clubname = "\U6d4b\U8bd5\U4ff1\U4e50\U90e8";
                 errorCode = 0;
                 errorDesc = "\U5145\U503c\U6210\U529f";
                 memberRechargeList =     (
                 );
                 rechargeBarcodeInfo =     {
                 activestatus = 1;
                 affiliation = "";
                 barcodedes = "xrB3FKeBEgkPH7pY8bM6oA==";
                 barcodeid = 13071201000010;
                 barcodestatusid = 6;
                 barkey = "-84,-19,0,5,116,0,6,98,86,112,82,48,49";
                 batchid = 13071201;
                 chargecount = 1;
                 clubid = 001003015;      001003015
                 clubname = "\U6d4b\U8bd5\U4ff1\U4e50\U90e8";
                 companyid = 001003015;
                 effectivecount = "";
                 effectivedate = 0;
                 expertid = "";
                 expirationdate = "2015-07-12";
                 expireTime = "2016-08-21";
                 functype = 1;
                 ip = "192.168.1.127";
                 isvip = 0;
                 lastTime = "2016-07-23";
                 opertime = "2013-07-12 08:53:29";
                 operuserid = 10004939;
                 producttime = "2013-07-12 08:53:29";
                 remark = "";
                 selltime = "";
                 selltype = "";
                 servicestar = 41;
                 serviceusertype = 41;
                 statusid = 1;
                 timetype = 2;
                 };
                 serviceAccount = "";
                 servicePersonId = "";
                 serviceuserType = 41;
                 }
                 */
                
                //充值成功的回复,用返回的俱乐部id请求私教列表：：
                [self sendRequest:
                 
                 @{@"memberId":[DBM dbm].currentUsers.memberId,
                 @"pwd":[DBM dbm].currentUsers.pwd,
                 @"deptid": [info objectForKey:@"clubid"]}
                 
                           action:wlGetTrainListRequest
                    baseUrlString:wlServer];
                
            } else if (errorCode.intValue == 2) {
                //已被使用过::
                [self handlerCardBeUsed:info];
            }
        } else if ([action isEqualToString:wlGetTrainListRequest] || [action isEqualToString:wlGetAllTrainRequest]) {
            
            if ([errorCode intValue] == 0) {
                //获取私教列表成功的回复,用返回的列表数据布局私教tableview：：
                
                _trainArray = [info objectForKey:@"servicePersonList"];
                [self.tableView reloadData];
                
                /*
                 {
                 errorCode = 0;
                 errorDesc = "\U4e3a\U4ec0\U4e48\U9700\U8981\U5065\U8eab\U79c1\U6559\Uff1f\U5065\U8eab\U79c1\U6559\U5c06\U4e3a\U60a8\U7684\U5065\U8eab\U5e26\U6765\Uff1a<br>\Uff081\Uff09\U5b9e\U65f6\U3001\U4e13\U4e1a\U7684\U6307\U5bfc<br>\Uff082\Uff09\U6301\U7eed\U7684\U7763\U4fc3\U4e0e\U63a8\U52a8<br>\Uff083\Uff09\U4e2a\U6027\U5316\U5065\U8eab\U670d\U52a1\U9700\U6c42\U7684\U6ee1\U8db3<br>\Uff083\Uff09\U60a8\U5065\U8eab\U4e4b\U8def\U7684\U6700\U4f73\U642d\U6863\U3002";
                 servicePersonList =     (
                 {
                 EMail = "123456@qq.com";
                 account = 12345678912;
                 activity = 0;
                 age = 24;
                 blog = "\U554a\U662f\U7684\U53d1\U5c31\U5c31";
                 channel = 123456789;
                 city = "";
                 contactWay = "";
                 deptName = "wangm\U6d4b\U8bd5\U4ff1\U4e50\U90e8";
                 deptid = 001003015;
                 eMail = "123456@qq.com";
                 educational = 1;
                 enabled = "";
                 experience = "\U6211\U5934\U4e2a\U6492\U63d0\U5c31\U597d";
                 honor = "\U554a\U662f\U7684\U5c31\U770b\U770b\U7684\U7684\U53d1\U5403\U4e2a\U597d\U5c31\U5c31";
                 integral = 0;
                 introduction = "\U53bb\U997f\U53d1\U5c31\U770b\U770b\U4e2a\U7684\U662f";
                 isonline = 1;
                 level = 0;
                 locked = "";
                 nickname = "\U79c1\U6559\U8c6a";
                 password = "";
                 picture = "http://www.holddo.com:80/bdcServer/img/personaltrainer/12345678912.jpg";
                 province = "";
                 remark = "";
                 sex = 1;
                 specialSkill = "";
                 userId = 171;
                 userName = "\U8c6a";
                 userQQ = 123456789;
                 userStaticTel = "";
                 userTel = "";
                 userType = 0;
                 worktime = "";
                 }
                 );
                 } --- error :: (null)
                 */
                
        
            } else if ([errorCode intValue] == 2) {
                //私教全忙：：
                [self showText:[info objectForKey:@"errorDesc"]];
                
            } else {
                [self showText:[info objectForKey:@"errorDesc"]];
            }
                
        }
            
    } else {
        //接收数据出错：：
        if ([action isEqualToString:wlUserRechargeRequest]) {
            //充值请求发生未知错误：：
            [self handlerRechargeError];
        } else {
            [self showText:@"连接服务器失败！"];
        }
    
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _trainArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger row = [indexPath row];
    NSDictionary *trainInfo = [_trainArray objectAtIndex:row];
    
    static NSString *CellIdentifier = @"WlhyPrivateTrainCell";
    WlhyPrivateTrainCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[WlhyPrivateTrainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.trainNameLabel.text = [trainInfo objectForKey:@"userName"];
    cell.trainAgeLabel.text = [NSString stringWithFormat:@"%@岁", [trainInfo objectForKey:@"age"]];
    cell.trainHonorLabel.text = [trainInfo objectForKey:@"honor"];
    cell.trainIntroductionLabel.text = [trainInfo objectForKey:@"introduction"];
    cell.trainWorkTimeLabel.text = [trainInfo objectForKey:@"worktime"];
    
    cell.trainStatusLabel.text = ([[trainInfo objectForKey:@"isonline"] integerValue] == 1) ? @"在线" : @"离线";
    cell.trainStatusLabel.textColor = [UIColor darkGrayColor];
    if ([[trainInfo objectForKey:@"isonline"] integerValue] != 1) {
        cell.trainStatusLabel.textColor = AlertColor;
    }
    
    NSString *picPath = [trainInfo objectForKey:@"picture"];
    __block WlhyPrivateTrainCell *thisCell = cell;
    [cell.trainThumbImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:picPath]]
                                     placeholderImage:[UIImage imageNamed: ((int)[trainInfo objectForKey:@"SEX"] == 2) ? @"head_f.png" : @"head_m.png"]
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  [thisCell.trainThumbImageView setImage:image];
                                              }
                                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                  if ([[trainInfo objectForKey:@"SEX"] intValue] == 1) {
                                                      [thisCell.trainThumbImageView setImage:[UIImage imageNamed:@"head_m.png"]];
                                                  } else {
                                                      [thisCell.trainThumbImageView setImage:[UIImage imageNamed:@"head_f.png"]];
                                                  }
                                              }];
    cell.trainThumbImageView.layer.cornerRadius = 4;
    cell.trainThumbImageView.layer.borderWidth = 2;
    cell.trainThumbImageView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    
    cell.trainSexImageView .hidden = NO;
    if (([[trainInfo objectForKey:@"sex"] integerValue] == 1)) {
        NSString *sexPicString = @"maleIcon.png";
        [cell.trainSexImageView setImage:[UIImage imageNamed:sexPicString]];
    } else if (([[trainInfo objectForKey:@"sex"] integerValue] == 2)) {
        NSString *sexPicString = @"fmaleIcon.png";
        [cell.trainSexImageView setImage:[UIImage imageNamed:sexPicString]];
    } else {
        cell.trainSexImageView .hidden = YES;
    }
    
    /*
     {
     errorCode = 0;
     errorDesc = "\U4e3a\U4ec0\U4e48\U9700\U8981\U5065\U8eab\U79c1\U6559\Uff1f\U5065\U8eab\U79c1\U6559\U5c06\U4e3a\U60a8\U7684\U5065\U8eab\U5e26\U6765\Uff1a<br>\Uff081\Uff09\U5b9e\U65f6\U3001\U4e13\U4e1a\U7684\U6307\U5bfc<br>\Uff082\Uff09\U6301\U7eed\U7684\U7763\U4fc3\U4e0e\U63a8\U52a8<br>\Uff083\Uff09\U4e2a\U6027\U5316\U5065\U8eab\U670d\U52a1\U9700\U6c42\U7684\U6ee1\U8db3<br>\Uff083\Uff09\U60a8\U5065\U8eab\U4e4b\U8def\U7684\U6700\U4f73\U642d\U6863\U3002";
     servicePersonList =     (
     {
     EMail = "";
     account = 16600000010;
     activity = 0;
     age = 26;
     blog = "";
     channel = "";
     city = "";
     contactWay = "";
     deptName = "wangm\U6d4b\U8bd5\U4ff1\U4e50\U90e8";
     deptid = 001003015;
     eMail = "";
     educational = 4;
     enabled = "";
     experience = "";
     honor = "";
     integral = 0;
     introduction = "";
     level = 2;
     locked = "";
     nickname = "\U79c1\U6559test";
     password = "";
     picture = "http://www.holddo.com:80/bdcServer/img/personaltrainer/ ";
     province = "";
     remark = "";
     sex = 2;
     specialSkill = "";
     userId = 190;
     userName = Test0903;
     userQQ = "";
     userStaticTel = "";
     userTel = "";
     userType = 0;
     worktime = "";
     }
     );
     } --- error :: (null)
     */
    
    return cell;
}

#pragma mark - tableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     {
     account = 99999999999;
     city = "";
     contactWay = "";
     deptName = "\U6d4b\U8bd5\U4ff1\U4e50\U90e8";
     deptid = 001003015;
     eMail = "";
     enabled = "";
     locked = "";
     password = "";
     picture = " ";
     province = "";
     remark = "";
     sex = 1;
     specialSkill = "";
     userId = 19;
     userName = sdsd;
     userQQ = "";
     userStaticTel = "";
     userTel = "";
     userType = 1;
     }
    */
    
    NSInteger row = [indexPath row];
    
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyTrainInfoViewController"];
    if(destVC && [destVC respondsToSelector:@selector(setTrainID:)]){
        
        NSNumber *idNumber = [NSNumber numberWithInteger:
                              [[[_trainArray objectAtIndex:row] objectForKey:@"userId"] integerValue]];
        [destVC setValue:idNumber forKey:@"trainID"];
        [destVC setValue:[NSNumber numberWithInt:_rechargeVCPurpose] forKey:@"rechargeVCPurpose"];
        
        [self.navigationController pushViewController:destVC animated:YES];
    }
    
}


#pragma mark - IBAnction

- (void)handlerRechargeError
{
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyRechargeErrorViewController"];
    if (destVC) {
        if ([destVC respondsToSelector:@selector(setDesc:)]) {
            [destVC setValue:@"未查询到该服务卡的二维码，详情请咨询前台或您的健身私教。" forKey:@"desc"];
        }
        [self.navigationController pushViewController:destVC animated:NO];
    }
}

- (void)handlerCardBeUsed:(NSDictionary *)info
{
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyRechargeErrorViewController"];
    if (destVC) {
        if ([destVC respondsToSelector:@selector(setDesc:)]) {
            [destVC setValue:[info objectForKey:@"errorDesc"] forKey:@"desc"];
        }
        [self.navigationController pushViewController:destVC animated:NO];
    }
}


@end
