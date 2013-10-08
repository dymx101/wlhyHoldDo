//
//  WlhyAccountInfoViewController.m
//  wlhybdc
//
//  Created by ios on 13-8-16.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyAccountInfoViewController.h"


#pragma mark - Class WlhyFitnessCardCell

@interface WlhyFitnessCardCell : UITableViewCell

@property(strong, nonatomic) IBOutlet UIView *cellBackgroundView;

@property(strong, nonatomic) IBOutlet UILabel *clubNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *cardIdLabel;
@property(strong, nonatomic) IBOutlet UILabel *cardTypeLabel;
@property(strong, nonatomic) IBOutlet UILabel *serviceNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *activeTimeLabel;
@property(strong, nonatomic) IBOutlet UILabel *expireTimeLabel;
@property(strong, nonatomic) IBOutlet UILabel *useTimesLabel;

@end


@implementation WlhyFitnessCardCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

//=========================================================================================
//=========================================================================================

#pragma mark - Class WlhyAccountInfoViewController


@interface WlhyAccountInfoViewController ()


@property(strong, nonatomic) NSArray *currentCardArray;
@property(strong, nonatomic) NSArray *historyCardArray;

@end

@implementation WlhyAccountInfoViewController

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
    
    
    self.title = @"我的账户信息";
    
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
    [rightButton setTitle:@"激活" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_0.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_1.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(self.view.frame.size.width - 70, 0, 66, 40);
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [self sendRequest:
     
     @{@"memberId": [DBM dbm].currentUsers.memberId,
     @"pwd": [DBM dbm].currentUsers.pwd,
     }
     
               action:wlGetAccountInfoRequest
        baseUrlString:wlServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        self.currentCardArray = nil;
        self.historyCardArray = nil;
    }
    
}

#pragma mark - VC Change

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightItemTouched:(id)sender
{
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyRechargeViewController"];
    if ([destVC respondsToSelector:@selector(setRechargeVCPurpose:)]) {
        [destVC setValue:[NSNumber numberWithInt:0] forKey:@"rechargeVCPurpose"];
    }
    [self.navigationController pushViewController:destVC animated:NO];
}


#pragma mark - processRequest

-(void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"%@---%@",info,error);
    
    if(!error){
        if([[info objectForKey:@"errorCode"] integerValue] ==0){
            _currentCardArray = [info objectForKey:@"memberCurServiceList"];
            _historyCardArray = [info objectForKey:@"memberRechargeList"];
            
            [self.tableView reloadData];
            
        }else {
            [self showText:[info objectForKey:@"errorDesc"]];
        }
    }else{
        [self showText:@"连接服务器失败！"];
    }
    
}

/*
 {
 errorCode = 0;
 errorDesc = "\U67e5\U8be2\U4f1a\U5458\U8d26\U6237\U4fe1\U606f\U6210\U529f";
 memberCurServiceList =     (
 {
 TIMETYPE = 2;
 barcodeId = 13082101000001;
 club = "wangm\U6d4b\U8bd5\U4ff1\U4e50\U90e8";
 equipTypeName = "";
 expireTime = "2016-05-17";
 indexId = 465;
 lastTime = "2016-04-18";
 memeberId = 0;
 rechargeMoney = 50;
 rechargeTime = "2013-08-21 18:45:22";
 serviceTypeId = 1;
 serviceTypeName = "\U51cf\U80a5";
 serviceuserType = "";
 state = 1;
 useDTimes = 0;
 useTimes = 0;
 },
 {
 TIMETYPE = 3;
 barcodeId = 13073004000009;
 club = "wangm\U6d4b\U8bd5\U4ff1\U4e50\U90e8";
 equipTypeName = "";
 expireTime = "2013-10-30";
 indexId = 390;
 lastTime = "2013-08-02";
 memeberId = 0;
 rechargeMoney = 50;
 rechargeTime = "2013-08-02 15:14:07";
 serviceTypeId = 5;
 serviceTypeName = "\U5065\U8eab\U7ba1\U7406";
 serviceuserType = "";
 state = 1;
 useDTimes = 0;
 useTimes = 0;
 }
 );
 memberFinishedServiceList =     (
 );
 memberRechargeList =     (
 {
 TIMETYPE = 2;
 barcodeId = 13082101000001;
 club = "wangm\U6d4b\U8bd5\U4ff1\U4e50\U90e8";
 equipTypeName = "";
 expireTime = "2016-05-17";
 indexId = 465;
 lastTime = "2016-04-18";
 memeberId = 0;
 rechargeMoney = 50;
 rechargeTime = "2013-08-21 18:45:22";
 serviceTypeId = 1;
 serviceTypeName = "\U51cf\U80a5";
 serviceuserType = "";
 state = 1;
 useDTimes = 0;
 useTimes = 0;
 }

*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return;
    
    switch (section) {
        case 0:
            return nil;
            break;
            
        case 1:
            return nil;
            break;
            
        default:
            break;
    }
    
    return nil;
}
*/
 
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"正在使用的服务卡";
            break;
            
        case 1:
            return @"我的服务卡记录";
            break;
            
        default:
            break;
    }
    
    return NULL;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return _currentCardArray.count;
            break;
        
        case 1:
            return _historyCardArray.count;
            break;
            
        default:
            break;
    }
    
    return NULL;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 153.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    
    NSDictionary *cardInfo = [NSDictionary dictionary];
    
    switch (section) {
        case 0:
            cardInfo = [_currentCardArray objectAtIndex:row];
            break;
        
        case 1:
            cardInfo = [_historyCardArray objectAtIndex:row];
            break;
            
        default:
            break;
    }
    
//    NSString *CellIdentifier = [NSString stringWithFormat:@"WlhyFitnessCardCell%i%i", section, row];
    static NSString *CellIdentifier = @"WlhyFitnessCardCell";
    
    WlhyFitnessCardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[WlhyFitnessCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    /*
     @property(strong, nonatomic) IBOutlet UILabel *clubNameLabel;
     @property(strong, nonatomic) IBOutlet UILabel *cardIdLabel;
     @property(strong, nonatomic) IBOutlet UILabel *cardTypeLabel;
     @property(strong, nonatomic) IBOutlet UILabel *serviceNameLabel;
     @property(strong, nonatomic) IBOutlet UILabel *activeTimeLabel;
     @property(strong, nonatomic) IBOutlet UILabel *expireTimeLabel;
     @property(strong, nonatomic) IBOutlet UILabel *useTimesLabel;
    */
    
    /*
     {
     TIMETYPE = 3;
     barcodeId = 13073004000009;
     club = "wangm\U6d4b\U8bd5\U4ff1\U4e50\U90e8";
     equipTypeName = "";
     expireTime = "2013-10-30";
     indexId = 390;
     lastTime = "2013-08-02";
     memeberId = 0;
     rechargeMoney = 50;
     rechargeTime = "2013-08-02 15:14:07";
     serviceTypeId = 5;//
     serviceTypeName = "\U5065\U8eab\U7ba1\U7406";
     serviceuserType = "";
     state = 1;
     useDTimes = 0;
     useTimes = 0;
     }
    */
    
    
    
    cell.cellBackgroundView.layer.cornerRadius = 5;
    cell.cellBackgroundView.layer.borderWidth = 1;
    cell.cellBackgroundView.layer.borderColor = [UIColor colorWithRed:0.4 green:0.5 blue:6 alpha:0.23].CGColor;
    cell.cellBackgroundView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    
    NSLog(@"cardInfo :: %@", cardInfo);
    
    /*
     serviceTypeId::
     
     1	减肥
     2	血压管理
     3	血糖管理
     4	血脂管理
     5	健身管理
     9	心脏病管理
     */
    
    NSString *cardType = @"";
    
    switch ([[cardInfo objectForKey:@"serviceTypeId"] integerValue]) {
        case 1:
            cardType = @"减肥卡";
            break;
        case 2:
            cardType = @"血压管理";
            break;
        case 4:
            cardType = @"血脂管理";
            break;
        case 5:
            cardType = @"健康管理";
            break;
        case 9:
            cardType = @"心脏病管理";
            break;
        default:
            break;
    }
    
    
    cell.clubNameLabel.text = [cardInfo objectForKey:@"club"];
    cell.cardIdLabel.text = [cardInfo objectForKey:@"barcodeId"];
    cell.cardTypeLabel.text = cardType;
    cell.serviceNameLabel.text = [cardInfo objectForKey:@"serviceTypeName"];
    cell.activeTimeLabel.text = [cardInfo objectForKey:@"rechargeTime"];
    cell.expireTimeLabel.text = [cardInfo objectForKey:@"expireTime"];
    cell.useTimesLabel.text = [[cardInfo objectForKey:@"useTimes"] stringValue];
    
    return cell;
}

@end
