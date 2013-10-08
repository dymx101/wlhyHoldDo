//
//  WlhyWeekPrescriptionViewController.m
//  wlhybdc
//
//  Created by ios on 13-7-30.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyWeekPrescriptionViewController.h"


@interface WlhyWeekPrescriptionCell : UITableViewCell

@property(strong, nonatomic) IBOutlet UILabel *dayLabel;
@property(strong, nonatomic) IBOutlet UILabel *equipNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *sportTypeLabel;
@property(strong, nonatomic) IBOutlet UILabel *goalEnergyLabel;

@end


@implementation WlhyWeekPrescriptionCell

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


//=============================================================
//=============================================================


@interface WlhyWeekPrescriptionViewController ()

@property(strong, nonatomic) NSArray *prescArray;

@property(strong, nonatomic) IBOutlet UIView *sectionHeaderView;

@end

@implementation WlhyWeekPrescriptionViewController

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

    self.title = @"处方概要";
    
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
    
    [self sendRequest:
     
     @{
     @"memberId":[DBM dbm].currentUsers.memberId,
     @"pwd":[DBM dbm].currentUsers.pwd
     }
     
               action:wlGetWeekPrescRequest
        baseUrlString:wlServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        self.prescArray = nil;
        self.sectionHeaderView = nil;
    }
    
}

-(void)back:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - processRequest

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"back action :: %@", action);
    NSLog(@"%@,-----,%@",info,error);
    
    if(!error){
        if([[info objectForKey:@"errorCode"] integerValue] == 0){
            /*
             
             {
             errorCode = 0;
             errorDesc = "\U83b7\U5f97\U4e00\U5468\U5904\U65b9\U6210\U529f";
             list =     (
             {
             day = 1;
             equipType = "\U8dd1\U6b65\U673a";
             goalEnergyConsumption = "53.1";
             restflag = "\U4e0d\U4f11\U606f";
             sportPattern = "\U6301\U7eed\U8fd0\U52a8";
             },
             {
             day = 2;
             equipType = "\U8dd1\U6b65\U673a";
             goalEnergyConsumption = "57.5";
             restflag = "\U4e0d\U4f11\U606f";
             sportPattern = "\U95f4\U6b47\U8fd0\U52a8";
             },
             {
             day = 3;
             equipType = "\U8dd1\U6b65\U673a";
             goalEnergyConsumption = "55.3";
             restflag = "\U4e0d\U4f11\U606f";
             sportPattern = "\U95f4\U6b47\U8fd0\U52a8";
             },
             {
             day = 4;
             equipType = "\U8dd1\U6b65\U673a";
             goalEnergyConsumption = "66.4";
             restflag = "\U4e0d\U4f11\U606f";
             sportPattern = "\U95f4\U6b47\U8fd0\U52a8";
             },
             {
             day = 5;
             equipType = "\U8dd1\U6b65\U673a";
             goalEnergyConsumption = "57.5";
             restflag = "\U4e0d\U4f11\U606f";
             sportPattern = "\U95f4\U6b47\U8fd0\U52a8";
             },
             {
             day = 6;
             equipType = "\U8dd1\U6b65\U673a";
             goalEnergyConsumption = "57.5";
             restflag = "\U4e0d\U4f11\U606f";
             sportPattern = "\U95f4\U6b47\U8fd0\U52a8";
             },
             {
             day = 7;
             equipType = "\U8dd1\U6b65\U673a";
             goalEnergyConsumption = "57.5";
             restflag = "\U4e0d\U4f11\U606f";
             sportPattern = "\U95f4\U6b47\U8fd0\U52a8";
             }
             );
             prescriptionId = "f5c73fb2-f226-4109-8e9d-c7680c99547f";
             },-----,(null)
             */
            
            _prescArray = [info objectForKey:@"list"];
            [self.tableView reloadData];
            
        } else{
            [self showText:[info objectForKey:@"errorDesc"]];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 35.0;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return _sectionHeaderView;
    }
    return NULL;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _prescArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    
    static NSString *CellIdentifier = @"WlhyWeekPrescriptionCell";
    WlhyWeekPrescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *dayPresc = [_prescArray objectAtIndex:row];
    /*
     {
     day = 7;
     equipType = "\U8dd1\U6b65\U673a";
     goalEnergyConsumption = "57.5";
     restflag = "\U4e0d\U4f11\U606f";
     sportPattern = "\U95f4\U6b47\U8fd0\U52a8";
     }
    */
    
    switch ([[dayPresc objectForKey:@"day"] integerValue]) {
        case 1:
            cell.dayLabel.text = @"星期一";
            break;
        case 2:
            cell.dayLabel.text = @"星期二";
            break;
        case 3:
            cell.dayLabel.text = @"星期三";
            break;
        case 4:
            cell.dayLabel.text = @"星期四";
            break;
        case 5:
            cell.dayLabel.text = @"星期五";
            break;
        case 6:
            cell.dayLabel.text = @"星期六";
            break;
        case 7:
            cell.dayLabel.text = @"星期日";
            break;
        default:
            break;
    }
    
    cell.equipNameLabel.text = [dayPresc objectForKey:@"equipType"];
    cell.sportTypeLabel.text = [dayPresc objectForKey:@"sportPattern"];
    cell.goalEnergyLabel.text = [NSString stringWithFormat:@"%@Kcal", [dayPresc objectForKey:@"goalEnergyConsumption"]];
    
    return cell;
}


@end
