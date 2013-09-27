//
//  WlhyStrengthPrescriptionViewController.m
//  wlhybdc
//
//  Created by ios on 13-8-2.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyStrengthPrescriptionViewController.h"

typedef enum {
    AuthNormal = 0,
    AuthNoSign = 1,
    AuthNoAccess = 2,
    AuthNoBinding = 3,
    AuthUnknown = 4
}AuthStatus;

@interface WlhyStrengthPrescriptionViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate>
{
    NSInteger openSectionNumber;
    AuthStatus authStatus;
    
}

@property(strong, nonatomic) NSDictionary *prescInfo;

@property(strong, nonatomic) NSArray *sectionTitleArr;
@property(strong, nonatomic) NSMutableArray *sectionTapArray;

//headerView
@property(strong, nonatomic) IBOutlet UILabel *projectNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *prescGoalLabel;
@property(strong, nonatomic) IBOutlet UILabel *sportTypeLabel;
@property(strong, nonatomic) IBOutlet UILabel *goalEnergyLabel;
@property(strong, nonatomic) IBOutlet UIImageView *equipImageView;

@property(strong, nonatomic) IBOutlet UITextField *inputField;
@property(strong, nonatomic) UIView *bigAuthView;
@property(strong, nonatomic) IBOutlet UIView *smallAuthView;

- (void)cancelInput:(id)sender;
- (IBAction)ensureAuth:(id)sender;
- (IBAction)cancelAuth:(id)sender;


- (IBAction)doSportHandler:(id)sender;

@end

@implementation WlhyStrengthPrescriptionViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

#pragma mark - VC life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"今日处方";
    
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
    
    
    _sectionTitleArr = [NSArray arrayWithObjects: @"运动步骤", @"运动作用", @"注意事项", nil];
    _sectionTapArray = [NSMutableArray arrayWithObjects:
                        [NSNumber numberWithBool:NO],
                        [NSNumber numberWithBool:NO],
                        [NSNumber numberWithBool:NO],nil];
    
    authStatus = AuthUnknown;
    
    _smallAuthView.layer.cornerRadius = 4;
    _smallAuthView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.85];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    if ([_temporaryTrainID integerValue] != -1 && _isBackFromTrainSelection) {
        UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyStrengthSportViewController"];
        if ([destVC respondsToSelector:@selector(setBarDecode:)]) {
            [destVC setValue:_barDecode forKey:@"barDecode"];
        }
        if ([destVC respondsToSelector:@selector(setTrainID:)]) {
            [destVC setValue:_temporaryTrainID forKey:@"trainID"];
        }
        [self.navigationController pushViewController:destVC animated:YES];
        return;
    }
    
    
    NSLog(@"_barDecode :: %@", _barDecode);
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *prescKey = @"";
    
    prescKey = [NSString stringWithFormat:@"%@+%@",
                [DBM dbm].currentUsers.memberId, _barDecode];
    
    NSDictionary *d = [userDefaults dictionaryForKey:prescKey];
    _prescInfo = [d objectForKey:@"dataSource"];
    
    //发送使用权限请求：：
    [self sendRequest:
     
     @{@"memberid":[DBM dbm].currentUsers.memberId,
     @"barcodeid":_barDecode
     }
     
               action:brmAuthServletApi
        baseUrlString:brmServer];
    
    [self setUIWithPrescInfo];
}



- (void)viewDidUnload
{
    self.barDecode = nil;
    self.prescriptionId = nil;
    self.prescInfo = nil;
    self.sectionTitleArr = nil;
    self.sectionTapArray = nil;
    self.projectNameLabel = nil;
    self.prescGoalLabel = nil;
    self.sportTypeLabel = nil;
    self.goalEnergyLabel = nil;
    self.equipImageView = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - setUI

- (void)setUIWithPrescInfo
{
    //headerView::
    _projectNameLabel.text = WlhyString([_prescInfo objectForKey:@"name"]);
    _prescGoalLabel.text = WlhyString([_prescInfo objectForKey:@"exerciseGoals"]);
    _sportTypeLabel.text = WlhyString([_prescInfo objectForKey:@"sportPattern"]);
    _goalEnergyLabel.text = [NSString stringWithFormat:@"%@ Kcal", [_prescInfo objectForKey:@"goalEnergyConsumption"]];
    
    
    for (UIView *temp in [_equipImageView subviews]) {
        [temp removeFromSuperview];
    }
    
    NSString *picUrlString = [_prescInfo objectForKey:@"gifPath"];
    if (picUrlString) {
        [_equipImageView setImageWithURL:[NSURL URLWithString:[_prescInfo objectForKey:@"gifPath"]]];
    } else {
        [_equipImageView setImage:[UIImage imageNamed:@"jrcf_ll_img.jpg"]];
    }
    
    
    [self.tableView reloadData];
}

- (void)backToHome:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}



#pragma mark - table View delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sectionTitleArr count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section >= 3) {
        return nil;
    }
    
    UIView * mySectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 33)];
    UIButton * myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.frame = CGRectMake(2, 0, 315, 33);
    myButton.tag = 100 + section;
    myButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [myButton setImage:[UIImage imageNamed:@"jrcf_list_3.png"] forState:UIControlStateNormal];
    [myButton setImage:[UIImage imageNamed:@"jrcf_list_1.png"] forState:UIControlStateHighlighted];
    [myButton setImage:[UIImage imageNamed:@"jrcf_first_up_0.png"] forState:UIControlStateSelected];
    [myButton setSelected:[[_sectionTapArray objectAtIndex:section] boolValue]];
    myButton.titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    [myButton addTarget:self action:@selector(tapHeader:) forControlEvents:UIControlEventTouchUpInside];
    [mySectionView addSubview:myButton];
    
    UILabel * myLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 150, 21)];
    myLabel.font = [UIFont systemFontOfSize:15.0];
    myLabel.backgroundColor = [UIColor clearColor];
    myLabel.text = [_sectionTitleArr objectAtIndex:section];
    [mySectionView addSubview:myLabel];
    
    
    return mySectionView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //判断section的展开收起状态
    //返回cell数量::
    
    NSArray *prescStepArray = [_prescInfo objectForKey:@"sportSteps"];
    
    if ([[_sectionTapArray objectAtIndex:section] boolValue]) {
        if (section == 0) {
            return prescStepArray.count;
        }else {
            return 1;
        }
    }else {
        return 0;
    }
    
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *currentCell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return currentCell.frame.size.height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     {
     bdrConnPath = "http://218.245.5.74:8888";
     companyid = 001004003;
     equipType = 1003;
     errorCode = 0;
     errorDesc = "\U83b7\U5f97\U5904\U65b9\U6210\U529f";
     exeResult = "";
     exerciseGoals = "\U63d0\U9ad8\U5fc3\U80ba\U529f\U80fd";
     generation = 3;
     gifPath = "http://www.holddo.com/bdcServer/img/equip/001004003_LL130905001_1378349349265.png";
     goalEnergyConsumption = 601;
     name = "\U529b\U91cf\U8bad\U7ec3\U5668";
     note = "\U8010\U529b\U8bad\U7ec3\U8981\U91cf\U529b\U800c\U884c\Uff0c\U6ce8\U610f\U6b21\U6570\U8981\U5408\U7406\Uff0c\U6839\U636e\U81ea\U5df1\U80fd\U627f\U62c5\U7684\U6700\U5927\U91cd\U91cf\U768440~60%\U8fdb\U884c\U8c03\U6574\Uff0c\U6bcf\U7ec4\U65f6\U95f4\U95f4\U9694\U572830\U79d2\U5de6\U53f3.";
     prescriptionId = "1d2a9fda-7bc4-44bf-80c2-b6d0e79b9f6f";
     prescriptionValue = "\U901a\U8fc7\U529b\U91cf\U8010\U529b\U7684\U8bad\U7ec3\Uff0c\U80fd\U589e\U957f\U8010\U529b\Uff0c\U63d0\U9ad8\U808c\U8089\U6027\U80fd\Uff0c\U589e\U5f3a\U4f53\U8d28\U6c34\U5e73\U3002";
     sfxx = 1;
     slopeUnits = "";
     sportPattern = "\U6301\U7eed\U8fd0\U52a8";
     sportShowType = 1;
     sportSteps =     (
     {
     bigStep = "";
     contents = "";
     frequency = 20;
     resttime = 30;
     slope = "";
     smallStep = "";
     speed = "";
     step = 1;
     strength = 1;
     time = "0.5";
     title = "\U7b2c\U4e00\U7ec4";
     },
     {
     bigStep = "";
     contents = "";
     frequency = 30;
     resttime = 30;
     slope = "";
     smallStep = "";
     speed = "";
     step = 2;
     strength = 2;
     time = "0.5";
     title = "\U7b2c\U4e8c\U7ec4";
     },
     {
     bigStep = "";
     contents = "";
     frequency = 20;
     resttime = 30;
     slope = "";
     smallStep = "";
     speed = "";
     step = 3;
     strength = 3;
     time = "0.5";
     title = "\U7b2c\U4e09\U7ec4";
     },
     {
     bigStep = "";
     contents = "";
     frequency = 30;
     resttime = 30;
     slope = "";
     smallStep = "";
     speed = "";
     step = 4;
     strength = 4;
     time = "0.5";
     title = "\U7b2c\U56db\U7ec4";
     }
     );
     },-----,(null)
     */
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSArray *prescStepArray = [_prescInfo objectForKey:@"sportSteps"];
    NSDictionary *prescStepItemInfo = [prescStepArray objectAtIndex:row];
    
    
    CGSize autoSize;
    NSString *textContent = @"";
    
    switch (section) {
            
        case 0:
            //运动步骤：：
            textContent = [NSString stringWithFormat:@"第%@组：运动%@次，%@分钟，休息%@秒，强度%@",
                           [prescStepItemInfo objectForKey:@"step"],
                           [prescStepItemInfo objectForKey:@"frequency"],
                           [prescStepItemInfo objectForKey:@"time"],
                           [prescStepItemInfo objectForKey:@"resttime"],
                           [prescStepItemInfo objectForKey:@"strength"]];
            break;
        case 1:
            //运动价值：：
            textContent = [_prescInfo objectForKey:@"prescriptionValue"];
            break;
        case 2:
            //注意事项：：
            textContent = [_prescInfo objectForKey:@"note"];
            break;
        default:
            break;
    }
    
    NSLog(@"textContent :: %@", textContent);
    
    float cellLabelWidth = self.view.frame.size.width - 30;
    autoSize = [textContent sizeWithFont:[UIFont systemFontOfSize:12]
                       constrainedToSize:CGSizeMake(cellLabelWidth, 500)
                           lineBreakMode:NSLineBreakByWordWrapping];
    
    
    UILabel *cellLabel;
    UIImageView *cellBGImageView;
    
    NSString *CellIdentifier  = [NSString stringWithFormat:@"PrescInfoCell%i-%i", section, row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        
        cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 295, autoSize.height)];
        cellLabel.numberOfLines = 0;
        cellLabel.font = [UIFont systemFontOfSize:12];
        cellLabel.backgroundColor = [UIColor clearColor];
        cellLabel.textColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.6];
        [cell addSubview:cellLabel];
        
        //添加背景图片：：
        cellBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 315, autoSize.height)];
        [cellBGImageView setContentMode:UIViewContentModeScaleToFill];
        [cellBGImageView setImage:[UIImage imageNamed:@"bg.png"]];
        [cell insertSubview:cellBGImageView atIndex:0];
    }
    
    cellLabel.text = textContent;
    [cellLabel setFrame:CGRectMake(25, 0, 285, autoSize.height)];
    
    [cellBGImageView setFrame:CGRectMake(2, 0, 315, autoSize.height)];
    
    [cell setFrame:CGRectMake(0, 0, self.view.frame.size.width, autoSize.height)];
    return cell;
}

#pragma mark - tapHeader

- (void)tapHeader:(UIButton *)sender
{
    sender.selected = !sender.selected;
    openSectionNumber = sender.tag - 100;
    
    [_sectionTapArray replaceObjectAtIndex:openSectionNumber
                                withObject:[NSNumber numberWithBool:![[_sectionTapArray objectAtIndex:openSectionNumber] boolValue]]];
    
    [self.tableView reloadData];
}

#pragma mark - Process Request

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"back action :: %@", action);
    NSLog(@"info :: %@ , error :: %@", info, error);
    
    
    //权限验证请求答复：：
    if ([action isEqualToString:brmAuthServletApi]) {
        if(info){
            authStatus = [[info objectForKey:@"errorcode"] intValue];
            if (authStatus == AuthNormal && [[info objectForKey:@"bdrConnPath"] isEqualToString:@""]) {
                authStatus = AuthNoSign;
            }
            
        }else{
            [self showText:@"连接服务器失败！"];
        }
    }
    
    
    //权限验证亲好跪求得到恢复：：
    if ([action isEqualToString:wlBindEquipRequest]) {
        
        /*
         0：绑定成功
         1: 登录密码验证失败,无法绑定
         3：授权码不正确
         99：绑定失败，异常
         */
        
        /*
         {
         errorCode = 1;
         errorDesc = "\U767b\U5f55\U5bc6\U7801\U9a8c\U8bc1\U5931\U8d25,\U65e0\U6cd5\U7ed1\U5b9a";
         } , error :: (null)
         */
        
        if(info){
            if([[info objectForKey:@"errorCode"] intValue] == 0) {
                [self showText:@"器械权限绑定成功"];
                authStatus = AuthNormal;
            } else {
                [self showText:[info objectForKey:@"errorDesc"]];
            }
        }else{
            [self showText:@"连接服务器失败！"];
        }
    }
    
    if ([action isEqualToString:wlGetTrainInfoRequest]) {
        if(!error){
            if([[info objectForKey:@"errorCode"] integerValue] == 0){
                if ([[info objectForKey:@"isonline"] isEqualToString:@"在线"]) {
                    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyStrengthSportViewController"];
                    if ([destVC respondsToSelector:@selector(setBarDecode:)]) {
                        [destVC setValue:_barDecode forKey:@"barDecode"];
                    }
                    if ([destVC respondsToSelector:@selector(setTrainID:)]) {
                        [destVC setValue:[DBM dbm].usersExt.servicePersonId forKey:@"trainID"];
                    }
                    [self.navigationController pushViewController:destVC animated:YES];
                    return;
                } else if ([[info objectForKey:@"isonline"] isEqualToString:@"离线"]) {
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"提示"
                                          message:@"您的私教不在线，\n是否要选择其他私教？"
                                          delegate:self
                                          cancelButtonTitle:@"否"
                                          otherButtonTitles:@"是", nil];
                    [alert setTag:1206];
                    [alert show];
                }
                
            }else if([[info objectForKey:@"errorCode"] integerValue] == 2){
                //未查询到私教：：
                [self showText:@"未查询到您的健身私教"];
            }
        }else{
            [self showText:@"连接服务器失败！"];
        }
        
    }
}


#pragma mark - alertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1205) {
        if (buttonIndex == 0) {
            //不需要在线指导：：
            UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyStrengthSportViewController"];
            if ([destVC respondsToSelector:@selector(setBarDecode:)]) {
                [destVC setValue:_barDecode forKey:@"barDecode"];
            }
            if ([destVC respondsToSelector:@selector(setTrainID:)]) {
                [destVC setValue:[NSNumber numberWithInt:-1] forKey:@"trainID"];
            }
            [self.navigationController pushViewController:destVC animated:YES];
        } else if (buttonIndex == 1) {
            //需要在线指导：：
            [self sendRequest:
             
             @{
             @"memberId":[DBM dbm].currentUsers.memberId,
             @"pwd":[DBM dbm].currentUsers.pwd,
             @"servicePersonId": [DBM dbm].usersExt.servicePersonId}
             
                       action:wlGetTrainInfoRequest
                baseUrlString:wlServer];
        }
    } else if (alertView.tag == 1206) {
        if (buttonIndex == 0) {
            //不需要其他私教：：
            UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyStrengthSportViewController"];
            if ([destVC respondsToSelector:@selector(setBarDecode:)]) {
                [destVC setValue:_barDecode forKey:@"barDecode"];
            }
            if ([destVC respondsToSelector:@selector(setTrainID:)]) {
                [destVC setValue:[NSNumber numberWithInt:-1] forKey:@"trainID"];
            }
            [self.navigationController pushViewController:destVC animated:YES];
        } else if (buttonIndex == 1) {
            //需要其他私教：：
            UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyRechargeViewController"];
            if ([destVC respondsToSelector:@selector(setRechargeVCPurpose:)]) {
                [destVC setValue:[NSNumber numberWithInt:2] forKey:@"rechargeVCPurpose"];
            }
            [self.navigationController pushViewController:destVC animated:YES];
        }
    }
}



#pragma mark - IBAction

- (IBAction)doSportHandler:(id)sender
{
    
    if (authStatus == AuthNoAccess) {
        [self showText:@"对不起，您没有该器械的使用权限"];
        return;
    } else if (authStatus == AuthNoSign) {
        [self showText:@"资源尚未注册"];
        return;
    } else if (authStatus == AuthNoBinding) {
        //提示用户进行权限绑定：：
        if (!_bigAuthView) {
            _bigAuthView = [[UIView alloc] initWithFrame:self.view.frame];
            [_bigAuthView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.85]];
            [_bigAuthView removeAllSubViews];
            [_smallAuthView setFrame:CGRectMake(10, 50, 300, 146)];
            [_bigAuthView addSubview:_smallAuthView];
        }
        [self.view addSubview:_bigAuthView];
        return;
    } else if (authStatus == AuthNormal) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您是否需要健身私教实时指导？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        [alert setTag:1205];
        [alert show];
        
    } else {
        return;
    }
    
}

- (IBAction)ensureAuth:(id)sender
{
    if (_inputField.text.length <= 0) {
        [self showText:@"授权码不能为空"];
        return;
    }
    
    //发送绑定请求：：
    
    /*
     memberid
     pwd
     barcodeid
     grantcode
     */
    
    [self sendRequest:
     
     @{
     @"memberid": [DBM dbm].currentUsers.memberId,
     @"pwd": [DBM dbm].currentUsers.clearPwd,
     @"barcodeid": _barDecode,
     @"grantcode": _inputField.text
     }
     
               action:wlBindEquipRequest
        baseUrlString:wlServer];
    
    [_bigAuthView removeFromSuperview];
}


- (IBAction)cancelAuth:(id)sender
{
    [_bigAuthView removeFromSuperview];
}

- (void)cancelInput:(id)sender
{
    [_inputField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
