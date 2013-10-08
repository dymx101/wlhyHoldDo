//
//  WlhyMemberFitnessCountViewController.m
//  wlhybdc
//
//  Created by linglong meng on 12-11-14.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyFitnessCountViewController.h"

#import "DatePickerView.h"

#define PBJ_Count_URL @"/bdcServer/services/memberCount/getMemberFitnessCount";
#define DC_Count_URL @"/bdcServer/services/memberCount/getMemberDancheCount";
#define TYJ_Count_URL @"/bdcServer/services/memberCount/getMemberTuoyuanjiCount";
#define LL_Count_URL @"/bdcServer/services/memberCount/getMemberLxxlqCount";


@interface WlhyFitnessCountViewController () <DatePickerViewDelegate>
{
    
}


@property(strong, nonatomic) NSDate *checkStartDate;
@property(strong, nonatomic) NSDate *checkEndDate;
@property(strong, nonatomic) NSDate *startDate;
@property(strong, nonatomic) NSDate *endDate;
@property(strong, nonatomic) NSArray *equipTypeArray;
@property(assign, nonatomic) EquipType equipType;
@property(strong, nonatomic) NSDictionary *paoBuJiCountInfo;
@property(strong, nonatomic) NSDictionary *danCheCountInfo;
@property(strong, nonatomic) NSDictionary *tuoYuanJiCountInfo;
@property(strong, nonatomic) NSDictionary *liLiangCountInfo;
@property(strong, nonatomic) NSDictionary *currentCountInfo;

@property(strong, nonatomic) IBOutlet UILabel *startDateLabel;
@property(strong, nonatomic) IBOutlet UILabel *endDateLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *dateSpanSegment;
@property (strong, nonatomic) IBOutlet UISegmentedControl *equipTypeSegment;

@property (strong, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalDistanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *avgSpeedLabel;



- (IBAction)changeDateSpanAction:(id)sender;
- (IBAction)leftArrowAction:(id)sender;
- (IBAction)rightArrowAction:(id)sender;
- (IBAction)equipTypeSegmentAction:(id)sender;


@end


@implementation WlhyFitnessCountViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - VC life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.title = @"健身信息统计";
    
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
    
    _equipType = EquipTypePaoBuJi;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    /* 1001 跑步机 1002 单车 1003 力量训练器 1004 血压计 1005 体重秤 1006 椭圆机*/
    
    if (!_equipTypeArray) {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *equipTypeKey = [NSString stringWithFormat:@"%@+equipTypeScanned",
                                  [DBM dbm].currentUsers.memberId];
        _equipTypeArray = [NSMutableArray arrayWithArray:[userDefaults arrayForKey:equipTypeKey]];
    }
    NSLog(@"_equipTypeArray :: %@", _equipTypeArray);
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _startDate = localNow();
    _endDate = localNow();
    _checkStartDate = localNow();
    _checkEndDate = localNow();
    
    [self updateCheckDateDisplay];
    [self requestData:[self formatDate:_startDate] endDate:[self formatDate:_endDate] equipType:EquipTypePaoBuJi];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        [self setTotalTimeLabel:nil];
        [self setTotalDistanceLabel:nil];
        [self setAvgSpeedLabel:nil];
        [self setDateSpanSegment:nil];
    }
    
}

- (void)back:(id)sneder
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - IBAction 

- (IBAction)changeDateSpanAction:(id)sender
{    
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:0];
    [comps setYear:0];
    [comps setMonth:0];
    
        
    switch ([sender selectedSegmentIndex]) {
        case 0: //日
            _checkEndDate=localNow();
            _checkStartDate=_checkEndDate;
            break;
        case 1: // 周
            _checkEndDate = localNow();
            [comps setDay:-7];
            _checkStartDate = [calendar dateByAddingComponents:comps toDate:_checkEndDate options:0];
            break;
        case 2: //月
            _checkEndDate = localNow();
            [comps setMonth:-1];
            _checkStartDate = [calendar dateByAddingComponents:comps toDate:_checkEndDate options:0];
            break;
        case 3:{
            //弹出自定义日期的 DatePickerView::
            DatePickerView *datePickerView = [[DatePickerView alloc] initWithFrame:self.view.frame];
            datePickerView.delegate = self;
            [self.view addSubview:datePickerView];
            
            return;
        }
        default:
            break;
    }
    
    [self updateCheckDateDisplay];
    [self requestData:[self formatDate:_checkStartDate] endDate:[self formatDate:_checkEndDate] equipType:_equipType];
    
}

- (IBAction)leftArrowAction:(id)sender
{

    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:0];
    [comps setYear:0];
    [comps setMonth:0];
    [comps setDay:-1];
    _checkStartDate =[calendar dateByAddingComponents:comps toDate:_checkStartDate options:0];

    [self updateCheckDateDisplay];
    [self requestData:[self formatDate:_checkStartDate] endDate:[self formatDate:_checkEndDate] equipType:_equipType];
}

- (IBAction)rightArrowAction:(id)sender
{
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:0];
    [comps setYear:0];
    [comps setMonth:0];
    [comps setDay:1];
    _checkEndDate =[calendar dateByAddingComponents:comps toDate:_checkEndDate options:0];
    
    [self updateCheckDateDisplay];
    [self requestData:[self formatDate:_checkStartDate] endDate:[self formatDate:_checkEndDate] equipType:_equipType];
}

- (IBAction)equipTypeSegmentAction:(id)sender
{
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    switch (segment.selectedSegmentIndex) {
        case 0:
            _equipType = EquipTypePaoBuJi;
            [self requestData:[self formatDate:_checkStartDate] endDate:[self formatDate:_checkEndDate] equipType:EquipTypePaoBuJi];
            break;
        
        case 1:
            _equipType = EquipTypeDanChe;
            [self requestData:[self formatDate:_checkStartDate] endDate:[self formatDate:_checkEndDate] equipType:EquipTypeDanChe];
            break;
            
        case 2:
            _equipType = EquipTypeTuoYuanJi;
            [self requestData:[self formatDate:_checkStartDate] endDate:[self formatDate:_checkEndDate] equipType:EquipTypeTuoYuanJi];
            break;
            
        case 3:
            _equipType = EquipTypeLiLiangXunLianQi;
            [self requestData:[self formatDate:_checkStartDate] endDate:[self formatDate:_checkEndDate] equipType:EquipTypeLiLiangXunLianQi];
            break;
            
        default:
            break;
    }
    
}



#pragma mark - process Request

-(void)requestData:(NSString*)startDate endDate:(NSString*)endDate equipType:(EquipType)kEquipType
{
    NSString *equipAction;
    switch (kEquipType) {
        case EquipTypePaoBuJi:
            equipAction = PBJ_Count_URL;
            break;
            
        case EquipTypeDanChe:
            equipAction = DC_Count_URL;
            break;
            
        case EquipTypeTuoYuanJi:
            equipAction = TYJ_Count_URL;
            break;
            
        case EquipTypeLiLiangXunLianQi:
            equipAction = LL_Count_URL;
            break;
            
        default:
            break;
    }
    
    [self sendRequest:
     
     @{
     @"memberId": [DBM dbm].currentUsers.memberId,
     @"pwd": [DBM dbm].currentUsers.pwd,
     @"startTime":WlhyString(startDate),
     @"endTime":WlhyString(endDate)
     }
     
               action:equipAction
        baseUrlString:wlServer];
    
}


-(void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"info :: %@ --- error :: %@", info, error);
    
    if(info){
        if([[info objectForKey:@"errorCode"] integerValue] == 0){
            
            switch (_equipType) {
                case EquipTypePaoBuJi:
                    _paoBuJiCountInfo = info;
                    break;
                
                case EquipTypeDanChe:
                    _danCheCountInfo = info;
                    break;
                    
                case EquipTypeTuoYuanJi:
                    _tuoYuanJiCountInfo = info;
                    break;
                    
                case EquipTypeLiLiangXunLianQi:
                    _liLiangCountInfo = info;
                    break;
                    
                default:
                    break;
            }
            
            [self updateDispalyWithCountInfo:info];
            
            
        } else {
            self.totalTimeLabel.text=@"";
            self.totalDistanceLabel.text=@"";
            self.avgSpeedLabel.text=@"";
            [self showText:[info objectForKey:@"errorDesc"]];
        }

    }else{
        [self showText:@"连接服务器失败，请稍后再试"];
    }
}

#pragma mark - Delegate

- (void)didCancelDatePickerView:(DatePickerView *)kPickerView
{
    [kPickerView removeFromSuperview];
    kPickerView = nil;
    _dateSpanSegment.selectedSegmentIndex=-1;
}

- (void)didEnsureDatePickerView:(DatePickerView *)kPickerView WithstartDate:(NSString *)kStartDate endDate:(NSString *)kEndDate
{
    NSDateFormatter * f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"YYYY-MM-dd"];
    _checkStartDate = [f dateFromString:kStartDate];
    _checkEndDate = [f dateFromString:kEndDate];
    
    [self updateCheckDateDisplay];
    [self requestData:[self formatDate:_checkStartDate] endDate:[self formatDate:_checkEndDate] equipType:_equipType];
    
    [kPickerView removeFromSuperview];
    kPickerView = nil;
    _dateSpanSegment.selectedSegmentIndex=-1;
}


#pragma mark- Private Methond

- (NSString*)formatDate:(NSDate*)date
{
    NSDateFormatter * f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"YYYY-MM-dd"];
    return [f stringFromDate:date];
}

- (void)updateDispalyWithCountInfo:(NSDictionary *)countInfo
{
    /*
     {
     actualEnergy = "100.1";
     avgSpeed = "0.1";
     avgSpeedMap =     {
     "2013-10-08" = "0.1";
     };
     errorCode = 0;
     errorDesc = "\U5065\U8eab\U7ed3\U679c\U7edf\U8ba1\U6210\U529f";
     evaluate = "\U4f18";
     runResult = 87;
     runResultMap =     {
     "2013-10-08" = 87;
     };
     totalDistance = "1.48";
     totalDistanceMap =     {
     "2013-10-08" = "1.48";
     };
     totalEnergyMap =     {
     "2013-10-08" = "100.1";
     };
     totalTime = 1001;
     totalTimeMap =     {
     "2013-10-08" = 1001;
     };
     }
     */
    
    self.totalTimeLabel.text=[NSString stringWithFormat:@"%@",[countInfo objectForKey:@"totalTime"]];
    self.totalDistanceLabel.text=[NSString stringWithFormat:@"%@",[countInfo objectForKey:@"totalDistance"]];
    self.avgSpeedLabel.text=[NSString stringWithFormat:@"%@",[countInfo objectForKey:@"avgSpeed"]];

}

- (void)updateCheckDateDisplay
{
    _startDateLabel.text = [self formatDate:_checkStartDate];
    _endDateLabel.text = [self formatDate:_checkEndDate];
}

@end
