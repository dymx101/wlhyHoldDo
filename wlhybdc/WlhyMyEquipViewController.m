//
//  WlhyMyEquipViewController.m
//  wlhybdc
//
//  Created by Hello on 13-9-11.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyMyEquipViewController.h"

@interface WlhyOwnedEquipCell : UITableViewCell


@property(strong, nonatomic) IBOutlet UIImageView *equipImageView;
@property(strong, nonatomic) IBOutlet UILabel *equipNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *barDecodeLabel;
@property(strong, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property(strong, nonatomic) IBOutlet UILabel *equipTimeLabel;

@property(assign, nonatomic) WlhyMyEquipViewController *parentVC;

- (IBAction)grantButtonTapped:(id)sender;

@end



@implementation WlhyOwnedEquipCell

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

- (IBAction)grantButtonTapped:(id)sender
{
    [_parentVC gotoGrantVC:_barDecodeLabel.text];
}

@end


@interface WlhyMemberEquipCell : UITableViewCell


@property(strong, nonatomic) IBOutlet UIImageView *equipImageView;
@property(strong, nonatomic) IBOutlet UILabel *equipNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *barDecodeLabel;
@property(strong, nonatomic) IBOutlet UILabel *equipTimeLabel;

@end

//================================================================================
//================================================================================


@implementation WlhyMemberEquipCell

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


//================================================================================
//================================================================================



@interface WlhyMyEquipViewController ()

@property(strong, nonatomic) NSArray *ownedEquipArray;
@property(strong, nonatomic) NSArray *authedEquipArray;
@property(strong, nonatomic) NSArray *usedEquipArray;

@end

@implementation WlhyMyEquipViewController

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

    self.title = @"我的设备";
    
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
    
    /*
     memberid
     pwd
    */
    
    //我拥有的器械：：
    if (!_ownedEquipArray) {
        [self sendRequest:
         
         @{
         @"memberid": [DBM dbm].currentUsers.memberId,
         @"pwd": [DBM dbm].currentUsers.clearPwd
         }
         
                   action:wlGetOwnedEquipListRequest
            baseUrlString:wlServer];
    }
    
    //我有权使用的器械：：
    if (!_authedEquipArray) {
        [self sendRequest:
         
         @{
         @"memberid": [DBM dbm].currentUsers.memberId,
         @"pwd": [DBM dbm].currentUsers.clearPwd
         }
         
                   action:wlGetAuthedEquipListRequest
            baseUrlString:wlServer];
    }
    
    //我使用过的的器械：：
    if (!_usedEquipArray) {
        [self sendRequest:
         
         @{
         @"memberid": [DBM dbm].currentUsers.memberId,
         @"pwd": [DBM dbm].currentUsers.clearPwd
         }
         
                   action:wlGetUsedEquipListRequest
            baseUrlString:wlServer];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if (self.view.window == nil) {
        self.view = nil;
        self.ownedEquipArray = nil;
        self.authedEquipArray = nil;
        self.usedEquipArray = nil;
    }
    

}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Process Request

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"back action :: %@", action);
    NSLog(@"info :: %@ , error :: %@", info, error);
    
    if ([action isEqualToString:wlGetOwnedEquipListRequest]) {
        /*
         {
         bars =     (
         {
         barcodeid = 0001000000500007;
         effecttime = "2013-09-05 18:32:54";
         "eq_equiptypeid" = 1006;
         expirytime = "2222-01-01";
         },
         {
         barcodeid = 0001000000500008;
         effecttime = "2013-09-05 18:33:30";
         "eq_equiptypeid" = 1006;
         expirytime = "2222-01-01";
         }
         );
         errorCode = 0;
         errorDesc = "\U67e5\U8be2\U6210\U529f";
         } , error :: (null)
         */
        
        if(info){
            if([[info objectForKey:@"errorCode"] intValue] == 0) {
                _ownedEquipArray = [info objectForKey:@"bars"];
            } else {
                [self showText:[info objectForKey:@"errorDesc"]];
            }
            
        }else{
            [self showText:@"连接服务器失败！"];
        }
    }

    if ([action isEqualToString:wlGetAuthedEquipListRequest]) {
        /*
         {
         bars =     (
         {
         barcodeid = 0001000000500007;
         effecttime = "2013-09-05 18:32:54";
         "eq_equiptypeid" = 1006;
         expirytime = "2222-01-01";
         },
         {
         barcodeid = 0001000000500008;
         effecttime = "2013-09-05 18:33:30";
         "eq_equiptypeid" = 1006;
         expirytime = "2222-01-01";
         }
         );
         errorCode = 0;
         errorDesc = "\U67e5\U8be2\U6210\U529f";
         } , error :: (null)
         */
        if(info){
            if([[info objectForKey:@"errorCode"] intValue] == 0) {
                _authedEquipArray = [info objectForKey:@"bars"];
            } else {
                [self showText:[info objectForKey:@"errorDesc"]];
            }
        }else{
            [self showText:@"连接服务器失败！"];
        }
    }
    
    if ([action isEqualToString:wlGetUsedEquipListRequest]) {
        /*
         {
         bars =     (
         );
         errorCode = 0;
         errorDesc = "\U67e5\U8be2\U6210\U529f";
         } , error :: (null)
        */
        if(info){
            if([[info objectForKey:@"errorCode"] integerValue] == 0){
                _usedEquipArray = [info objectForKey:@"bars"];
                
            } else {
                [self showText:[info objectForKey:@"errorDesc"]];
            }
        }else{
            [self showText:@"连接服务器失败！"];
        }
        
    }
    
    [self.tableView reloadData];
}

#pragma mark - tableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *titleName;
    switch (section) {
        case 0:
            titleName = @"我拥有的设备";
            break;
            
        case 1:
            titleName = @"我有权使用的设备";
            break;
            
        case 2:
            titleName = @"我使用过的设备";
            break;
            
        default:
            break;
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 200, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    titleLabel.text = titleName;
    
    UIImageView *sectionHeaderBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MyEquipHeaderBG.png"]];
    [sectionHeaderBGImageView setFrame:CGRectMake(0, 0, 320, 40)];
    sectionHeaderBGImageView.alpha = 0.8f;

    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [sectionHeaderView addSubview:sectionHeaderBGImageView];
    [sectionHeaderView addSubview:titleLabel];
    
    return sectionHeaderView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return _ownedEquipArray.count;
            break;
        
        case 1:
            return _authedEquipArray.count;
            break;
            
        case 2:
            return _usedEquipArray.count;
            break;
            
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 116.0f;
            break;
            
        case 1:
            return 88.0f;
            break;
            
        case 2:
            return 88.0f;
            break;
            
        default:
            return 0;
            break;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    static NSString *CellIdentifier;

    if (section == 0) {
        
        NSDictionary *equipInfo = [_ownedEquipArray objectAtIndex:row];
        
        CellIdentifier = @"WlhyOwnedEquipCell";
        WlhyOwnedEquipCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[WlhyOwnedEquipCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        /*
         {
         barcodeid = 0001000000500007;
         effecttime = "2013-09-05 18:32:54";
         "eq_equiptypeid" = 1006;
         expirytime = "2222-01-01";
         }
        */
        
        cell.equipTimeLabel.text = [equipInfo objectForKey:@"expirytime"];
        cell.phoneNumberLabel.text = @"-";
        cell.barDecodeLabel.text = [equipInfo objectForKey:@"barcodeid"];
        cell.equipNameLabel.text = [self getEquipNameWithTypeID:[equipInfo objectForKey:@"eq_equiptypeid"]];
        cell.parentVC = self;
        cell.equipImageView.layer.borderWidth = 2;
        cell.equipImageView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
        [cell.equipImageView setImage:[UIImage imageNamed:[self getEquipImageNameWithTypeID:[equipInfo objectForKey:@"eq_equiptypeid"]]]];
        
        return cell;
    } else if (section == 1) {
        
        NSDictionary *equipInfo = [_authedEquipArray objectAtIndex:row];
        
        CellIdentifier = @"WlhyMemberEquipCell";
        WlhyMemberEquipCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[WlhyMemberEquipCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        /*
         {
         barcodeid = 0001000000500007;
         effecttime = "2013-09-05 18:32:54";
         "eq_equiptypeid" = 1006;
         expirytime = "2222-01-01";
         }
         */
        
        cell.equipTimeLabel.text = [equipInfo objectForKey:@"expirytime"];
        cell.barDecodeLabel.text = [equipInfo objectForKey:@"barcodeid"];
        cell.equipNameLabel.text = [self getEquipNameWithTypeID:[equipInfo objectForKey:@"eq_equiptypeid"]];
        
        cell.equipImageView.layer.borderWidth = 2;
        cell.equipImageView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
        [cell.equipImageView setImage:[UIImage imageNamed:[self getEquipImageNameWithTypeID:[equipInfo objectForKey:@"eq_equiptypeid"]]]];
        
        return cell;
    } else if (section == 2) {
        
        NSDictionary *equipInfo = [_usedEquipArray objectAtIndex:row];
        
        CellIdentifier = @"WlhyMemberEquipCell";
        WlhyMemberEquipCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[WlhyMemberEquipCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        /*
         {
         barcodeid = 0001000000500007;
         effecttime = "2013-09-05 18:32:54";
         "eq_equiptypeid" = 1006;
         expirytime = "2222-01-01";
         }
         */
        
        cell.equipTimeLabel.text = [equipInfo objectForKey:@"expirytime"];
        cell.barDecodeLabel.text = [equipInfo objectForKey:@"barcodeid"];
        cell.equipNameLabel.text = [self getEquipNameWithTypeID:[equipInfo objectForKey:@"eq_equiptypeid"]];
        
        cell.equipImageView.layer.borderWidth = 2;
        cell.equipImageView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
        [cell.equipImageView setImage:[UIImage imageNamed:[self getEquipImageNameWithTypeID:[equipInfo objectForKey:@"eq_equiptypeid"]]]];
        
        return cell;
    } else {
        return nil;
    }
    
}

- (NSString *)getEquipNameWithTypeID:(NSString *)typeID
{
    if ([typeID isEqualToString:@"1001"]) {
        return @"跑步机";
    } else if ([typeID isEqualToString:@"1002"]) {
        return @"单车";
    } else if ([typeID isEqualToString:@"1003"]) {
        return @"力量训练器";
    } else if ([typeID isEqualToString:@"1004"]) {
        return @"血压计";
    } else if ([typeID isEqualToString:@"1005"]) {
        return @"体重称";
    } else if ([typeID isEqualToString:@"1006"]) {
        return @"椭圆机";
    } else {
        return nil;
    }
}

- (NSString *)getEquipImageNameWithTypeID:(NSString *)typeID
{
    if ([typeID isEqualToString:@"1001"]) {
        return @"jrcf_pbj_img.jpg";
    } else if ([typeID isEqualToString:@"1002"]) {
        return @"jrcf_dc_img.jpg";
    } else if ([typeID isEqualToString:@"1003"]) {
        return @"jrcf_ll_img.jpg";
    } else if ([typeID isEqualToString:@"1004"]) {
        return @"jrcf_xyj_img.jpg";
    } else if ([typeID isEqualToString:@"1005"]) {
        return @"jrcf_tzc_img.jpg";
    } else if ([typeID isEqualToString:@"1006"]) {
        return @"jrcf_tyj_img.jpg";
    } else {
        return nil;
    }
}

- (void)gotoGrantVC:(NSString *)barDecode
{
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyGrantEquipViewController"];
    if ([destVC respondsToSelector:@selector(setBarDecode:)]) {
        [destVC setValue:barDecode forKey:@"barDecode"];
    }
    [self.navigationController pushViewController:destVC animated:YES];
}

@end
