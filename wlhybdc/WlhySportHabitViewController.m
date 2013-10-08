//
//  WlhySportHabitViewController.m
//  wlhybdc
//
//  Created by ios on 13-8-12.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhySportHabitViewController.h"

#import "WlhyMuitableSelectView.h"


@interface WlhySportHabitViewController ()

@property (strong, nonatomic) IBOutlet UISegmentedControl *sportTimesSegment;
@property (strong, nonatomic) IBOutlet WlhyMuitableSelectView *sportPeriodsView;
@property (strong, nonatomic) IBOutlet WlhyMuitableSelectView *sportItemsView;



@end

@implementation WlhySportHabitViewController

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

    self.title = @"运动习惯维护";
    
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
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"commonBackground.png"]]];
    
    //右侧按钮：：
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setContentMode:UIViewContentModeScaleToFill];
    [rightButton setTitle:@"提交" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_0.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_1.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(self.view.frame.size.width - 70, 0, 66, 40);
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        self.sportTimesSegment = nil;
        self.sportPeriodsView = nil;
        self.sportItemsView = nil;
        self.isForMakeUpInfo = nil;
    }
}

#pragma mark - Private Methond

- (void)setUI
{
    
    UsersExt *userExt = [[DBM dbm] usersExt];
    
    [self.sportTimesSegment setSelectedSegmentIndex:[userExt.sportTimes integerValue]-1];
    [self.sportPeriodsView setSelectedIndexs:[NSMutableArray arrayWithArray:[userExt.sportPeriods componentsSeparatedByString:@","]]];
    [self.sportItemsView setSelectedIndexs:[NSMutableArray arrayWithArray:[userExt.sportItems componentsSeparatedByString:@","]]];
    
    NSLog(@"%@", [userExt.sportPeriods componentsSeparatedByString:@","]);
    
}

#pragma mark - 

- (void)rightItemTouched:(id)sender
{
    NSLog(@"rightItemTouched");
    
    /*
     sportEquips
     sportPeriods
     sportTimes
     sportItems
     */
    
    NSLog(@"selectedIndexString1 :: %@", [self.sportPeriodsView selectedIndexString]);
    NSLog(@"selectedIndexString2 :: %@", [self.sportItemsView selectedIndexString]);
    
    UsersExt *usersExt = [DBM dbm].usersExt;
    
    if (usersExt) {
        [self sendRequest:
         
         @{@"memberId":[DBM dbm].currentUsers.memberId,
         @"pwd":[DBM dbm].currentUsers.pwd,
         @"sportPeriods": [self.sportPeriodsView selectedIndexString],
         @"sportTimes": [NSString stringWithFormat:@"%i", [self.sportTimesSegment selectedSegmentIndex] + 1],
         @"sportItems": [self.sportItemsView selectedIndexString],
         
         }
         
                   action:wlModifyMemberInfoRequest
            baseUrlString:wlServer];
    }
}

- (void)back:(id)sender
{
    if (_isForMakeUpInfo) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - processRequest

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"%@,-----,%@",info,error);
    
    if(!error){
        if([[info objectForKey:@"errorCode"] integerValue] == 0){
            //个人信息修改成功：：1.修改本地保存的用户数据    2.返回上一页
            [self showText:@"信息保存成功"];
            [self updateLocalData];
            [self performSelector:@selector(handlerVCChange:) withObject:nil afterDelay:1.5f];
        }
        
        [self showText:[info objectForKey:@"errorDesc"]];
        
    }else{
        [self showText:@"连接服务器失败，请稍后再试..."];
    }
}

- (void)handlerVCChange:(id)sender
{
    if (_isForMakeUpInfo) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//个人信息提交成功后，将本地数据同步更新：：
- (void)updateLocalData
{
    DBM *dbm = [DBM dbm];
    
    UsersExt *userExt = [[DBM dbm] getUsersExtByMemberId:dbm.currentUsers.memberId];
    if(!userExt){
        userExt = [dbm createNewRecord:@"UsersExt"];
    }
    
    userExt.sportPeriods = [self.sportPeriodsView selectedIndexString];
    userExt.sportItems = [self.sportItemsView selectedIndexString];
    userExt.sportTimes = [NSString stringWithFormat:@"%i", [self.sportTimesSegment selectedSegmentIndex] + 1];
    
    dbm.usersExt = userExt;
    [dbm saveContext];
    
    NSLog(@"userExt :: %@", userExt);

}

@end
