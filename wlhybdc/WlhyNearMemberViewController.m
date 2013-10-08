//
//  WlhyNearMemberViewController.m
//  wlhybdc
//
//  Created by ios on 13-7-11.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyNearMemberViewController.h"


@interface WlhyNearMemberCell : UITableViewCell

@property(strong, nonatomic) IBOutlet UIImageView *memberThumbImageView;
@property(strong, nonatomic) IBOutlet UILabel *memberNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *calCountLabel;
@property(strong, nonatomic) IBOutlet UILabel *timeCountLabel;
@property(strong, nonatomic) IBOutlet UILabel *distanceCountLabel;
@property(strong, nonatomic) IBOutlet UILabel *memberCityLabel;
@property(strong, nonatomic) IBOutlet UILabel *memberSexLabel;
@property(strong, nonatomic) IBOutlet UILabel *memberManifestoLabel;


@end


@implementation WlhyNearMemberCell

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


//=============================================================================================
//=============================================================================================


@interface WlhyNearMemberViewController ()

@property(strong, nonatomic) NSArray *nearMemberArray;

@end

@implementation WlhyNearMemberViewController

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

    self.title = @"附近会员";
    
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
    [super viewWillAppear:animated];

    NSLog(@"%f , %f", [_x floatValue], [_y floatValue]);
    
    
    /*
     memberId
     pwd
     x
     y
    */
        
    [self sendRequest:
     
     @{
     @"memberId": [DBM dbm].currentUsers.memberId,
     @"pwd": [DBM dbm].currentUsers.pwd,
     @"x": _x,
     @"y": _y
     }
     
               action:wlGetNearMemberRequest
        baseUrlString:wlServer];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        self.nearMemberArray = nil;
    }
    
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark ---  net response function

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"%@,-----,%@",info,error);
    
    if(!error){
        if([[info objectForKey:@"errorCode"] integerValue] == 0){
            
            /*
             {
             errorCode = 0;
             errorDesc = "\U67e5\U8be2\U4f1a\U5458\U4fe1\U606f\U6210\U529f";
             memberFitnessInfos =     (
             {
             BIRTHDAY = "2013-08-07";
             BMI = "10.6";
             CITY = "\U5317\U4eac";
             DISTANCE = 0;
             NAME = "\U5427\U59d0\U59d0";
             PICPATH = "http://www.holddo.com:80/bdcServer/img/member/18953112155.jpg";
             PROVINCE = "";
             SEX = "\U7537";
             TOTALDISTANCE = 0;
             TOTALENERGY = 0;
             TOTALTIME = 0;
             memberid = 289;
             phone = 18953112155;
             },
             {
             BIRTHDAY = "1990-08-12";
             BMI = "16.3";
             CITY = "\U5317\U4eac";
             DISTANCE = 0;
             NAME = "\U79ef\U6781";
             PICPATH = "";
             PROVINCE = "";
             SEX = "\U7537";
             TOTALDISTANCE = 0;
             TOTALENERGY = 0;
             TOTALTIME = 0;
             memberid = 298;
             phone = 15253194849;
             },
             {
             BIRTHDAY = "";
             BMI = "18.6";
             CITY = "\U5317\U4eac";
             DISTANCE = 0;
             NAME = "\U6167\U8dd1\U65b0\U5175";
             PICPATH = "http://www.holddo.com:80/bdcServer/img/member/16600000001.jpg";
             PROVINCE = "";
             SEX = "\U5973";
             TOTALDISTANCE = 0;
             TOTALENERGY = 0;
             TOTALTIME = 0;
             memberid = 324;
             phone = 16600000001;
             }
             );
             },-----,(null)
             
            */
            
            _nearMemberArray = [info objectForKey:@"memberFitnessInfos"];
            [self.tableView reloadData];
        }
    }else{
        [self showText:@"连接服务器失败，请稍后再试..."];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _nearMemberArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     {
     BIRTHDAY = "";
     BMI = "18.6";
     CITY = "\U5317\U4eac";
     DISTANCE = 0;
     NAME = "\U6167\U8dd1\U65b0\U5175";
     PICPATH = "";
     PROVINCE = "";
     SEX = "\U5973";
     TOTALDISTANCE = 0;
     TOTALENERGY = 0;
     TOTALTIME = 0;
     memberid = 324;
     phone = 16600000001;
     }
     */
    
    /*
     @property(strong, nonatomic) IBOutlet UIImageView *memberThumbImageView;
     @property(strong, nonatomic) IBOutlet UILabel *memberNameLabel;
     @property(strong, nonatomic) IBOutlet UILabel *calCountLabel;
     @property(strong, nonatomic) IBOutlet UILabel *timeCountLabel;
     @property(strong, nonatomic) IBOutlet UILabel *distanceCountLabel;
     @property(strong, nonatomic) IBOutlet UILabel *memberCityLabel;
     @property(strong, nonatomic) IBOutlet UILabel *memberSexLabel;
     @property(strong, nonatomic) IBOutlet UILabel *memberManifestoLabel;
    */
    
    NSInteger row = [indexPath row];
    NSDictionary *memberInfo = [_nearMemberArray objectAtIndex:row];
    
    WlhyNearMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NearMemberCell"];
    cell.memberNameLabel.text = [memberInfo objectForKey:@"NAME"];
    cell.memberSexLabel.text = [memberInfo objectForKey:@"SEX"];
    cell.timeCountLabel.text = [[memberInfo objectForKey:@"TOTALTIME"] stringValue];
    cell.distanceCountLabel.text = [[memberInfo objectForKey:@"TOTALDISTANCE"] stringValue];
    cell.calCountLabel.text = [[memberInfo objectForKey:@"TOTALENERGY"] stringValue];
    cell.memberCityLabel.text = [memberInfo objectForKey:@"CITY"];
    
    
    //头像：：
    NSString *picPath = [memberInfo objectForKey:@"PICPATH"];
    if ([picPath isEqualToString:@""]) {
        UIImage *headImage = ([[memberInfo objectForKey:@"SEX"] isEqualToString:@"男"]) ? [UIImage imageNamed:@"head_m.png"] : [UIImage imageNamed:@"head_f.png"];
        [cell.memberThumbImageView setImage:headImage];
        
    } else {
        [cell.memberThumbImageView setImageWithURL:[NSURL URLWithString:picPath]];
    }
    
    
    return cell;
}

@end
