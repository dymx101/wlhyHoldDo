//
//  WlhyMemberFitnessCountViewController.m
//  wlhybdc
//
//  Created by linglong meng on 12-11-14.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyFitnessCountViewController.h"

@interface WlhyFitnessCountViewController ()
{
    NSDate  * _queryStartDate;
    NSDate  * _queryEndDate;
}

@property(strong, nonatomic) NSDate *startDate;
@property(strong, nonatomic) NSDate *endDate;

@property (strong, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalDistanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *avgSpeedLabel;
@property (strong, nonatomic) IBOutlet UILabel *showDateLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *dateSpanSegment;


@property(strong, nonatomic) IBOutlet UIButton *buttonA;
@property(strong, nonatomic) IBOutlet UIButton *buttonB;
@property(strong, nonatomic) IBOutlet UIButton *buttonC;

@property(strong, nonatomic) NSMutableArray *equipTagArray;

- (IBAction)changeDateSpanAction:(id)sender;

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

    self.title = @"健身信息统计";
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _startDate = localNow();
    _endDate=_queryStartDate;
    [self requestData:[self formatDate:_queryStartDate] endDate:[self formatDate:_queryEndDate]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{

    [self setTotalTimeLabel:nil];
    [self setTotalDistanceLabel:nil];
    [self setAvgSpeedLabel:nil];
    [self setShowDateLabel:nil];
    [self setDateSpanSegment:nil];
    [super viewDidUnload];
}

#pragma mark - IBAction 

- (IBAction)changeDateSpanAction:(id)sender
{    
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:0];
    [comps setYear:0];
    [comps setMonth:0];
    
    if([sender isKindOfClass:[UIButton class]]){
        if([sender tag]==-1){
            [comps setDay:-1];
            _queryStartDate =[calendar dateByAddingComponents:comps toDate:_queryStartDate options:0];
        }else if ([sender tag] ==1){
            [comps setDay:1];
            _queryEndDate =[calendar dateByAddingComponents:comps toDate:_queryEndDate options:0];
        }
    }else if([sender isKindOfClass:[UISegmentedControl class]]){
        NSLog(@"%d",[sender selectedSegmentIndex]);
        switch ([sender selectedSegmentIndex]) {
            case 0: //日
                _queryEndDate=localNow();
                _queryStartDate=_queryEndDate;
                break;
            case 1: // 周
                _queryEndDate = localNow();
                [comps setDay:-7];
                _queryStartDate = [calendar dateByAddingComponents:comps toDate:_queryEndDate options:0];
                break;
            case 2: //月
                _queryEndDate = localNow();
                [comps setMonth:-1];
                _queryStartDate = [calendar dateByAddingComponents:comps toDate:_queryEndDate options:0];
                break;
            case 3:{
                UIViewController * v = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyDatePickerViewController"];
                UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"选取自定义时间" message:@"\n\n\n\n\n" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [v loadView];
                [v viewDidLoad];
                [alert addSubview:[v.view viewWithTag:1001]];
                [alert addSubview:[v.view viewWithTag:1002]];
                [alert show];
                return;
            }
            default:
                break;
        }
    }
    [self requestData:[self formatDate:_queryStartDate] endDate:[self formatDate:_queryEndDate]];
    
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex ==1){
        id v1 = [alertView viewWithTag:1001];
        id v2 = [alertView viewWithTag:1002];
        NSString* str1 = [v1 text];
        NSString* str2 = [v2 text];
        if(IsEmptyString(str1)||IsEmptyString(str2)){
            [self showText:@"请输入开始时间和结束时间"];
            self.dateSpanSegment.selectedSegmentIndex=-1;
            return;
        }
        [self requestData:WlhyString(str1) endDate:WlhyString(str2)];
    }
}

-(void)requestData:(NSString*)startDate endDate:(NSString*)endDate
{
    Users* u = [DBM dbm].currentUsers;
    [self sendRequest:
     
     @{@"memberId":[NSString stringWithFormat:@"%@", u.memberId],
          @"pwd":[NSString stringWithFormat:@"%@",u.pwd],
          @"startTime":WlhyString(startDate),
          @"endTime":WlhyString(endDate)
          }
               action:wlGetMemberFitnessCount
        baseUrlString:wlServer];
    
    self.showDateLabel.text=[NSString stringWithFormat:@"%@ ~ %@",[self formatDate:_queryStartDate],[self formatDate:_queryEndDate]];
}


-(void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    if(!error){
        NSLog(@"%@",info);
        NSInteger errorCode = [[info objectForKey:@"errorCode"] integerValue];
        if(errorCode ==0){
            self.totalTimeLabel.text=[NSString stringWithFormat:@"%@",[info objectForKey:@"totalTime"]];
            self.totalDistanceLabel.text=[NSString stringWithFormat:@"%@",[info objectForKey:@"totalDistance"]];
            self.avgSpeedLabel.text=[NSString stringWithFormat:@"%@",[info objectForKey:@"avgSpeed"]];
            NSLog(@"%@,---,%@",self.totalTimeLabel,self.totalTimeLabel.text);
        }else{
            self.totalTimeLabel.text=@"";
            self.totalDistanceLabel.text=@"";
            self.avgSpeedLabel.text=@"";
        }
        [self showText:[NSString stringWithFormat:@"%@",[info objectForKey:@"errorDesc"] ]];

    }else{
        [self showText:@"连接服务器失败，请稍后再试"];
    }
}


- (NSString*)formatDate:(NSDate*)date
{
    NSDateFormatter * f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"YYYY-MM-dd"];
    return [f stringFromDate:date];
}



@end
