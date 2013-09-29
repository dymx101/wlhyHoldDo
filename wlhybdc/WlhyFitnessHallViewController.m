//
//  WlhyFitnessHallViewController.m
//  wlhybdc
//
//  Created by ios on 13-7-11.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyFitnessHallViewController.h"

#import <CoreLocation/CoreLocation.h>

#pragma mark - Class WlhyHallMemberCell

@interface WlhyHallMemberCell : UITableViewCell

@property(strong, nonatomic) IBOutlet UIImageView *memberThumbImageView;
@property(strong, nonatomic) IBOutlet UIImageView *memberSexImageView;
@property(strong, nonatomic) IBOutlet UILabel *memberNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *manifestoLabel;
@property(strong, nonatomic) IBOutlet UILabel *distanceCountLabel;
@property(strong, nonatomic) IBOutlet UILabel *statusLabel;
@property(strong, nonatomic) IBOutlet UILabel *ageLabel;
@property(strong, nonatomic) IBOutlet UILabel *calCountLabel;
@property(strong, nonatomic) IBOutlet UILabel *timeCountLabel;
@property(strong, nonatomic) IBOutlet UILabel *rankLabel;

@end


@implementation WlhyHallMemberCell

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

//=================================================================================
//=================================================================================

const int pageSize = 10;

#pragma mark - Class WlhyFitnessHallViewController

@interface WlhyFitnessHallViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>
{
    float x;
    float y;
    
    int currentPage;
    BOOL shouldLoadMore;
    
}

@property(nonatomic, strong) NSMutableArray *hallMemberArray;
@property(nonatomic, strong) NSIndexPath *currentIndexPath;

@property(nonatomic, strong) IBOutlet UITableView *hallMemberTableView;
@property(nonatomic, strong) IBOutlet UIButton *nearMemberButton;

@property(nonatomic, strong) IBOutlet UIImageView *memberHeadImageView;
@property(nonatomic, strong) IBOutlet UILabel *memberNameLabel;
@property(nonatomic, strong) IBOutlet UILabel *memberTimeLabel;
@property(nonatomic, strong) IBOutlet UILabel *memberDistanceLabel;
@property(nonatomic, strong) IBOutlet UILabel *memberEnergyLabel;

@property(nonatomic, strong) IBOutlet UIImageView *rivalHeadImageView;
@property(nonatomic, strong) IBOutlet UILabel *rivalNameLabel;
@property(nonatomic, strong) IBOutlet UILabel *rivalTimeLabel;
@property(nonatomic, strong) IBOutlet UILabel *rivalDistanceLabel;
@property(nonatomic, strong) IBOutlet UILabel *rivalEnergyLabel;

@property(nonatomic, strong) IBOutlet UILabel *distanceTogetherLabel;
@property(nonatomic, strong) IBOutlet UILabel *clubRankLabel;
@property(nonatomic, strong) IBOutlet UILabel *totalRankLabel;

@property(strong, nonatomic) CLLocationManager *locationManager;

@property(strong, nonatomic) UIImageView *backgroundImageView;  //不删

@end

@implementation WlhyFitnessHallViewController

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
    
    self.title = @"健身大厅";
    
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
    
    
    if ([CLLocationManager locationServicesEnabled] && _locationManager == nil) {//判断手机是否可以定位
        _locationManager = [[CLLocationManager alloc] init];//初始化位置管理器
    }
    [_locationManager setDelegate:self];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];//设置精度
    _locationManager.distanceFilter = 1000.0f;//设置距离筛选器
    
    _hallMemberTableView.hidden = YES;
    _nearMemberButton.hidden = YES;
    
    _hallMemberArray = [NSMutableArray array];
    currentPage = 0;
    _currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    }
    if (![[self.view subviews] containsObject:_backgroundImageView]) {
        [self.view addSubview:_backgroundImageView];
    }
    
    if ([deviceType() isEqualToString:@"OldScreen"]) {
        [_backgroundImageView setImage:[UIImage imageNamed:@"jskt_bg.jpg"]];
    } else {
        [_backgroundImageView setImage:[UIImage imageNamed:@"jskt_bg1008.jpg"]];
    }
    [self.view sendSubviewToBack:_backgroundImageView];
    
    
    if (_hallMemberArray.count <= 0) {
        [self showText:@"正在获取您的位置信息"];
        [_locationManager startUpdatingLocation];//启动位置管理器
    }

    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
    }
    self.hallMemberArray = nil;
    self.currentIndexPath = nil;
    self.hallMemberTableView = nil;
    self.nearMemberButton = nil;
    self.memberHeadImageView = nil;
    self.memberNameLabel = nil;
    self.memberTimeLabel = nil;
    self.memberDistanceLabel = nil;
    self.memberEnergyLabel = nil;
    self.rivalHeadImageView = nil;
    self.rivalNameLabel = nil;
    self.rivalTimeLabel = nil;
    self.rivalDistanceLabel = nil;
    self.rivalEnergyLabel = nil;
    self.distanceTogetherLabel = nil;
    self.clubRankLabel = nil;
    self.totalRankLabel = nil;
    self.locationManager = nil;
    self.backgroundImageView = nil;
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - location Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    [_locationManager stopUpdatingLocation];
    
    x = newLocation.coordinate.latitude;
    y = newLocation.coordinate.longitude;
    
    //健身大厅成员列表：：
    /*
     memberid
     pwd
     pageSize
     page
     longitude
     latitude
     */
    [self sendRequest:
     @{
     @"memberid": [DBM dbm].currentUsers.memberId,
     @"pwd": [DBM dbm].currentUsers.clearPwd,
     @"longitude": [NSNumber numberWithFloat:x],
     @"longitude": [NSNumber numberWithFloat:y],
     @"pageSize": [NSNumber numberWithInt:pageSize],
     @"page": [NSNumber numberWithInt:++currentPage]
     }
     
               action:wlGetHallMemberListRequest
        baseUrlString:wlServer];
    
    //我再健身大厅中的基本信息：：
    /*
     memberId
     pwd
     longitude
     latitude
     */
    
    [self sendRequest:
     @{@"memberId": [DBM dbm].currentUsers.memberId,
     @"pwd": [DBM dbm].currentUsers.pwd,
     @"longitude": [NSNumber numberWithFloat:x],
     @"longitude": [NSNumber numberWithFloat:y]
     }
     
               action:wlGetHallMemberRequest
        baseUrlString:wlServer];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error :: %@", error);
    
    if ([error code] == 1) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"进入健身大厅需要获取您的位置信息，请前往【系统设置-隐私-定位服务】设置"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:nil, nil];
        [alert setTag:1200];
        [alert show];
    } else if ([error code] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"手机定位失败，请在【系统设置-隐私-定位服务】中检查是否已开启了位置服务"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:nil, nil];
        [alert setTag:1201];
        [alert show];
    }
}

#pragma mark - alert Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == 1200) {
        if (buttonIndex == 0) {
            [self back:nil];
        }
    } else if ([alertView tag] == 1201) {
        if (buttonIndex == 0) {
            [self back:nil];
        }
    }
}

#pragma mark ---  net response function
-(void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"%@,-----,%@",info,error);
    
    if ([action isEqualToString:wlGetHallMemberListRequest]) {
        if(info){
            if([[info objectForKey:@"errorCode"] intValue] == 0){
                //刷新列表：：
                [_hallMemberArray addObjectsFromArray:[info objectForKey:@"arList"]];
                shouldLoadMore = currentPage < [[info objectForKey:@"totalPageCount"] intValue];
                [_hallMemberTableView reloadData];

                
            }else {
                [self showText:[info objectForKey:@"errorDesc"]];
            }
        }else{
            [self showText:@"连接服务器失败！"];
        }
        
    } else if ([action isEqualToString:wlGetHallMemberRequest]) {
        if(info){
            if([[info objectForKey:@"errorCode"] intValue] == 0){
                [self setUIWithInfo:info];
            }else {
                [self showText:[info objectForKey:@"errorDesc"]];
            }
        }else{
            [self showText:@"连接服务器失败！"];
        }
    }
    
    
}

- (void)setUIWithInfo:(NSDictionary *)info
{
    /*
     @property(nonatomic, strong) IBOutlet UIButton *nearMemberButton;
     
     @property(nonatomic, strong) IBOutlet UIImageView *memberHeadImageView;
     @property(nonatomic, strong) IBOutlet UILabel *memberNameLabel;
     @property(nonatomic, strong) IBOutlet UILabel *memberTimeLabel;
     @property(nonatomic, strong) IBOutlet UILabel *memberDistanceLabel;
     @property(nonatomic, strong) IBOutlet UILabel *memberEnergyLabel;
     
     @property(nonatomic, strong) IBOutlet UIImageView *rivalHeadImageView;
     @property(nonatomic, strong) IBOutlet UILabel *rivalNameLabel;
     @property(nonatomic, strong) IBOutlet UILabel *rivalTimeLabel;
     @property(nonatomic, strong) IBOutlet UILabel *rivalDistanceLabel;
     @property(nonatomic, strong) IBOutlet UILabel *rivalEnergyLabel;
     
     @property(nonatomic, strong) IBOutlet UILabel *distanceTogetherLabel;
     @property(nonatomic, strong) IBOutlet UILabel *clubRankLabel;
     @property(nonatomic, strong) IBOutlet UILabel *totalRankLabel;
     */
    
    /*
     {
     errorCode = 0;
     errorDesc = "\U67e5\U8be2\U5065\U8eab\U82f1\U96c4\U699c\U6210\U529f";
     fitnessArmorys =     (
     {
     MANIFESTO = "Hi,\U52a0\U6cb9\U5662\Uff01";
     MEMBERID = 357;
     NAME = "\U6167\U52a8\U7c890940";
     PICPATH = "";
     RANK = "\U7b2c1\U540d";
     SEX = 2;
     TOTALDISTANCE = "2.12";
     TOTALENERGY = "94.34";
     TOTALTIME = 1500;
     }
     );
     myTotaldistance = 0;
     myTotalenergy = 0;
     myTotaltime = 2;
     "rank_all" = 21;
     "rank_comp" = 10;
     "totaldistance_comp" = "5.720000000000001";
     },-----,(null)
     */
    
    _hallMemberTableView.hidden = NO;
    _nearMemberButton.hidden = NO;
    NSDictionary *rivalInfo = [[info objectForKey:@"fitnessArmorys"] objectAtIndex:0];
    
    _memberNameLabel.text = [DBM dbm].usersExt.name;
    _memberTimeLabel.text = [[info objectForKey:@"myTotaltime"] stringValue];
    _memberDistanceLabel.text = [[info objectForKey:@"myTotaldistance"] stringValue];
    _memberEnergyLabel.text = [[info objectForKey:@"myTotalenergy"] stringValue];
    
    _rivalNameLabel.text = [rivalInfo objectForKey:@"NAME"];
    _rivalTimeLabel.text = [[rivalInfo objectForKey:@"TOTALTIME"] stringValue];
    _rivalDistanceLabel.text = [[rivalInfo objectForKey:@"TOTALDISTANCE"] stringValue];
    _rivalEnergyLabel.text = [[rivalInfo objectForKey:@"TOTALENERGY"] stringValue];
    
    _distanceTogetherLabel.text = [NSString stringWithFormat:@"%.2f", [[info objectForKey:@"totaldistance_comp"] floatValue]];
    _clubRankLabel.text = [info objectForKey:@"rank_comp"];
    _totalRankLabel.text = [info objectForKey:@"rank_all"];
    _nearMemberButton.titleLabel.text = [[info objectForKey:@"onlineNum"] stringValue];
    
    //头像：：
    NSString *picPath = [rivalInfo objectForKey:@"PICPATH"];
    //对手头像：：
    if ([picPath isEqualToString:@""]) {
        UIImage *headImage = ((int)[rivalInfo objectForKey:@"SEX"] == 2) ? [UIImage imageNamed:@"head_f.png"] : [UIImage imageNamed:@"head_m.png"];
        [_rivalHeadImageView setImage:headImage];
        
    } else {
        [_rivalHeadImageView setImageWithURL:[NSURL URLWithString:picPath]];
    }
    
    //我的头像：：
    picPath = [DBM dbm].usersExt.picPath;
    if ([picPath isEqualToString:@""]) {
        UIImage *headImage = ([[DBM dbm].usersExt.sex intValue] == 0) ? [UIImage imageNamed:@"head_m.png"] : [UIImage imageNamed:@"head_f.png"];
        [_memberHeadImageView setImage:headImage];
        
    } else {
        [_memberHeadImageView setImageWithURL:[NSURL URLWithString:picPath]];
    }
    
    [_hallMemberTableView reloadData];
}

#pragma mark - tableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == _hallMemberArray.count) {
        return 40.0f;
    }
    return 76.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _hallMemberArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    if (_hallMemberArray.count <= 0) {
        static NSString *CellIdentifier = @"HallLoadMoreCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = @"暂无健身大厅会员信息";
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        
        return cell;
    }
    
    //最后一行：：
    if (row == _hallMemberArray.count) {
        _currentIndexPath = indexPath;
        static NSString *CellIdentifier = @"HallLoadMoreCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.userInteractionEnabled = YES;
        if (shouldLoadMore) {
            cell.textLabel.text = @"点击查看更多";
        } else {
            cell.textLabel.text = @"没有更多会员信息了";
            cell.userInteractionEnabled = NO;
        }
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"WlhyHallMemberCell";
        WlhyHallMemberCell *cell = (WlhyHallMemberCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[WlhyHallMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        NSDictionary *memberInfo = [_hallMemberArray objectAtIndex:row];
        
        /*
         {
         age = 24;
         hyjl = "";
         isonline = 1;
         manifesto = "\U4e00\U8d77\U6765\U5065\U8eab\U2026\U2026";
         memberid = 275;
         name = "\U4f1a\U5458\U840c";
         picpath = "http://www.holddo.com:80/bdcserver/img/member/30000000001.jpg";
         sex = 2;
         rank = 5;
         totaldistance = "1.3";
         totalenergy = "57.85";
         totaltime = 660;
         }
         */
        
        if (memberInfo.count <= 0) {
            return NULL;
        }
        cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        cell.memberNameLabel.text = [memberInfo objectForKey:@"name"];
        cell.ageLabel.text = [NSString stringWithFormat:@"%@岁",
                              [memberInfo objectForKey:@"age"]];
        cell.statusLabel.text = ([[memberInfo objectForKey:@"isonline"] intValue] == 1) ? @"在线" : @"离线";
        cell.distanceCountLabel.text = [NSString stringWithFormat:@"%@ km",
                                        [memberInfo objectForKey:@"totaldistance"]];
        cell.calCountLabel.text = [NSString stringWithFormat:@"%@",
                                   [memberInfo objectForKey:@"totalenergy"]];
        cell.timeCountLabel.text = [NSString stringWithFormat:@"%@",
                                    [memberInfo objectForKey:@"totaltime"]];
        cell.manifestoLabel.text = [memberInfo objectForKey:@"manifesto"];
        
        
        NSString *picPath = [memberInfo objectForKey:@"picpath"];
        if ([picPath isEqualToString:@""]) {
            UIImage *headImage = ((int)[memberInfo objectForKey:@"SEX"] == 2) ? [UIImage imageNamed:@"head_f.png"] : [UIImage imageNamed:@"head_m.png"];
            [cell.memberThumbImageView setImage:headImage];
            
        } else {
            [cell.memberThumbImageView setImageWithURL:[NSURL URLWithString:picPath]];
        }
        
        cell.memberThumbImageView.layer.cornerRadius = 4;
        cell.memberThumbImageView.layer.borderWidth = 2;
        cell.memberThumbImageView.layer.borderColor = [UIColor colorWithRed:0.3 green:0.3 blue:1.6 alpha:0.4].CGColor;
        
        NSString *sexImageName = ([[memberInfo objectForKey:@"sex"] intValue] == 1) ? @"maleIcon.png" : @"fmaleIcon.png";
        [cell.memberSexImageView setImage:[UIImage imageNamed:sexImageName]];
        if ([[memberInfo objectForKey:@"sex"] intValue] == 0) {
            cell.memberSexImageView.hidden = YES;
        }
        cell.rankLabel.hidden = YES;
        if ([[memberInfo objectForKey:@"rank"] intValue] == 1) {
            cell.rankLabel.hidden = NO;
            cell.rankLabel.textColor = [UIColor colorWithRed:0.8 green:0.4 blue:0.4 alpha:1.0];
            cell.rankLabel.text = @"冠军";
        } else if ([[memberInfo objectForKey:@"rank"] intValue] == 2) {
            cell.rankLabel.hidden = NO;
            cell.rankLabel.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.4 alpha:1.0];
            cell.rankLabel.text = @"亚军";
        } else if ([[memberInfo objectForKey:@"rank"] intValue] == 3) {
            cell.rankLabel.hidden = NO;
            cell.rankLabel.textColor = [UIColor colorWithRed:0.4 green:0.8 blue:0.4 alpha:1.0];
            cell.rankLabel.text = @"季军";
        }
        
        return cell;
    }

    
    //其他行：：
    
    
    /*
     {
     age = 33;
     hyjl = "";
     isonline = 1;
     manifesto = "";
     memberid = 288;
     name = "\U4f1a\U54580807";
     picpath = "";
     sex = 2;
     totaldistance = "1.32";
     totalenergy = "49.93";
     totaltime = 660;
     
     }
     */
    
    /*
     @property(strong, nonatomic) IBOutlet UIImageView *memberThumbImageView;
     @property(strong, nonatomic) IBOutlet UIImageView *memberSexImageView;
     @property(strong, nonatomic) IBOutlet UILabel *memberNameLabel;
     @property(strong, nonatomic) IBOutlet UILabel *manifestoLabel;
     @property(strong, nonatomic) IBOutlet UILabel *distanceCountLabel;
     @property(strong, nonatomic) IBOutlet UILabel *statusLabel;
     @property(strong, nonatomic) IBOutlet UILabel *ageLabel;
     @property(strong, nonatomic) IBOutlet UILabel *calCountLabel;
     @property(strong, nonatomic) IBOutlet UILabel *timeCountLabel;
     @property(strong, nonatomic) IBOutlet UILabel *rankLabel;
    */
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _hallMemberArray.count) {
        //正在加载：：
        UITableViewCell *loadMoreCell = [tableView cellForRowAtIndexPath:indexPath];
        loadMoreCell.textLabel.text = @"正在加载...";
        
        //健身大厅成员列表：：
        /*
         memberid
         pwd
         pageSize
         page
         longitude
         latitude
         */
        [self sendRequest:
         @{
         @"memberid": [DBM dbm].currentUsers.memberId,
         @"pwd": [DBM dbm].currentUsers.clearPwd,
         @"longitude": [NSNumber numberWithFloat:x],
         @"longitude": [NSNumber numberWithFloat:y],
         @"pageSize": [NSNumber numberWithInt:pageSize],
         @"page": [NSNumber numberWithInt:++currentPage]
         }
         
                   action:wlGetHallMemberListRequest
            baseUrlString:wlServer];
        
    }
}


#pragma mark -ButtonHandler

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *destVC = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"WlhyNearMemberSegue"]) {
        if ([destVC respondsToSelector:@selector(setX:)]) {
            [destVC setValue:[NSNumber numberWithFloat:x] forKey:@"x"];
        }
        if ([destVC respondsToSelector:@selector(setY:)]) {
            [destVC setValue:[NSNumber numberWithFloat:y] forKey:@"y"];
        }
    }
}

@end
