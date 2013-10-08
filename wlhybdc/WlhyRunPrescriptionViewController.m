 //
//  WlhyRunPrescriptionViewController.m
//  wlhybdc
//
//  Created by ios on 13-7-31.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyRunPrescriptionViewController.h"


typedef enum {
    AuthNormal = 0,
    AuthNoSign = 1,
    AuthNoAccess = 2,
    AuthNoBinding = 3,
    AuthUnknown = 4
}AuthStatus;


@interface WlhyRunPrescriptionViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate>
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

@property(strong, nonatomic) IBOutlet UIView *commonPrescView;

@property(strong, nonatomic) IBOutlet UITextField *inputField;
@property(strong, nonatomic) UIView *bigAuthView;
@property(strong, nonatomic) IBOutlet UIView *smallAuthView;

- (void)cancelInput:(id)sender;
- (IBAction)ensureAuth:(id)sender;
- (IBAction)cancelAuth:(id)sender;


- (IBAction)doSportHandler:(id)sender;

@end



@implementation WlhyRunPrescriptionViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _commonPrescTag = [NSNumber numberWithInt:-1];
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
    _temporaryTrainID = [NSNumber numberWithInt:-1];
    
    _smallAuthView.layer.cornerRadius = 4;
    _smallAuthView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.85];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    if ([_temporaryTrainID integerValue] != -1 && _isBackFromTrainSelection) {
        UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyRunSportViewController"];
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
    
    UIViewController *commonPrescVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyCommonPrescViewController"];
    if ([commonPrescVC respondsToSelector:@selector(setBarDecode:)]) {
        [commonPrescVC setValue:_barDecode forKey:@"barDecode"];
        [self addSubViewController:commonPrescVC toView:_commonPrescView];
        
    }
    
    if ([_commonPrescTag intValue] >= 0) {
        //通用处方：：
        [self getCommonPresc];
        
    } else {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *prescKey = @"";
        
        prescKey = [NSString stringWithFormat:@"%@+%@",
                    [DBM dbm].currentUsers.memberId, _barDecode];
        
        NSDictionary *d = [userDefaults dictionaryForKey:prescKey];
        _prescInfo = [d objectForKey:@"dataSource"];
    }
    
    //发送使用权限请求：：
    [self sendRequest:
     
     @{@"memberid":[DBM dbm].currentUsers.memberId,
     @"barcodeid":_barDecode
     }
     
               action:brmAuthServletApi
        baseUrlString:brmServer];
    
    [self setUIWithPrescInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        self.prescInfo = nil;
        self.sectionTitleArr = nil;
        self.sectionTapArray = nil;
        self.projectNameLabel = nil;
        self.prescGoalLabel = nil;
        self.sportTypeLabel = nil;
        self.goalEnergyLabel = nil;
        self.equipImageView = nil;
        self.commonPrescView = nil;
        self.bigAuthView = nil;
    }
}

- (void)back:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - setUI

- (void)getCommonPresc
{
    NSDictionary *prescDic;
    NSString *jsonString = @"";
    
    NSError *error;

    switch ([_commonPrescTag intValue]) {
        case 0:
            jsonString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"presc1" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
            prescDic = JSONObjectFromString(jsonString);
            break;
            
        case 1:
            jsonString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"presc2" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
            prescDic = JSONObjectFromString(jsonString);
            break;
            
        case 2:
            jsonString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"presc3" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
            prescDic = JSONObjectFromString(jsonString);
            break;
            
        case 3:
            jsonString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"presc4" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
            prescDic = JSONObjectFromString(jsonString);
            break;
            
        default:
            break;
    }
    
    _prescInfo = prescDic;
    NSLog(@"prescInfo :: %@", _prescInfo);
    
    /*
     NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
     NSDictionary *flagDic = [NSDictionary dictionary];
     NSString *prescKey = [NSString stringWithFormat:@"%@+%@+%i",
     [DBM dbm].currentUsers.memberId, _barDecode ,commonPrescTag];
     
     NSLog(@"common prescKey :: %@", prescKey);
     
     NSDictionary *existedPresc = [userDefaults dictionaryForKey:prescKey];
     
     if (existedPresc) {
     if ([existedPresc objectForKey:@"flagInfo"] != NULL) {
     //已存在之前的该器械的处方执行信息，且执行日期不是当天，则删除：：
     NSString *storeTime = [self getDateStringWithNSDate:
     [[existedPresc objectForKey:@"flagInfo"] objectForKey:@"storeTime"]
     andDateFormat:@"yyyy-MM-dd"];
     
     NSLog(@"storeTime   %@", [[existedPresc objectForKey:@"flagInfo"] objectForKey:@"storeTime"]);
     NSLog(@"storeTimeStr%@", storeTime);
     NSLog(@"localNow    %@", [self getDateStringWithNSDate:localNow() andDateFormat:@"yyyy-MM-dd"]);
     
     if (storeTime != nil &&
     ![storeTime isEqualToString:[self getDateStringWithNSDate:localNow() andDateFormat:@"yyyy-MM-dd"]]) {
     [userDefaults removeObjectForKey:prescKey];
     }
     }
     } else {
     //之前没有该器械的处方执行信息：：这是一个全新的处方
     [userDefaults setObject:
     
     @{@"dataSource":_prescInfo,
     @"flagInfo":   flagDic}
     
     forKey:prescKey];
     
     [userDefaults synchronize];
     }
     */
}

- (void)setUIWithPrescInfo
{
    //headerView::
    _projectNameLabel.text = WlhyString([_prescInfo objectForKey:@"name"]);
    _prescGoalLabel.text = WlhyString([_prescInfo objectForKey:@"exerciseGoals"]);
    _sportTypeLabel.text = WlhyString([_prescInfo objectForKey:@"sportPattern"]);
    _goalEnergyLabel.text = [NSString stringWithFormat:@"%@ Kcal", [_prescInfo objectForKey:@"goalEnergyConsumption"]];
    
    NSString *picUrlString = [_prescInfo objectForKey:@"gifPath"];
    if (![picUrlString isEqualToString:@""]) {
        [_equipImageView setImageWithURL:[NSURL URLWithString:[_prescInfo objectForKey:@"gifPath"]]];
    } else {
        [_equipImageView setImage:[UIImage imageNamed:@"jrcf_pbj_img.jpg"]];
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
     //有处方：：
     {
     bdrConnPath = "http://42.121.106.113:8888";
     equipType = 1001;
     errorCode = 0;
     errorDesc = "\U83b7\U5f97\U5904\U65b9\U6210\U529f";
     exeResult = "";
     exerciseGoals = "\U63d0\U9ad8\U5fc3\U80ba\U529f\U80fd";
     generation = 3;
     gifPath = "http://42.121.106.113/bdcServer/img/files/img/1.jpg";
     goalEnergyConsumption = "55.3";
     name = "\U8dd1\U6b65\U673a";
     note = "\U4e0d\U8981\U5728\U996d\U524d\U8fd0\U52a8\Uff0c\U4ee5\U907f\U514d\U4f4e\U8840\U7cd6\U7684\U53d1\U751f\U3002";
     prescriptionId = "f5c73fb2-f226-4109-8e9d-c7680c99547f";
     prescriptionValue = "\U8dd1\U6b65\U673a\U8fdb\U884c\U953b\U70bc\U5177\U6709\U89c4\U5f8b\U6027\U3001\U6301\U7eed\U6027\U7b49\U7279\U5f81\Uff0c\U53d7\U5916\U90e8\U73af\U5883\U5982\U5929\U6c14\U7b49\U5f71\U54cd\U8f83\U5c0f\U3002";
     slopeUnits = "";
     sportPattern = "\U95f4\U6b47\U8fd0\U52a8";
     sportShowType = 1;
     sportSteps =     (
     {
     bigStep = 1;
     contents = "";
     frequency = "";
     resttime = "";
     slope = 3;
     smallStep = 1;
     speed = 3;
     step = "";
     strength = "";
     time = 2;
     title = "";
     },
     {
     bigStep = 1;
     contents = "";
     frequency = "";
     resttime = "";
     slope = 5;
     smallStep = 2;
     speed = 5;
     step = "";
     strength = "";
     time = 2;
     title = "";
     }
     );
     }
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
            textContent = [NSString stringWithFormat:@"第%@阶段：以 %@(km/h)的速度运动%@分钟",
                           [prescStepItemInfo objectForKey:@"bigStep"],
                           [prescStepItemInfo objectForKey:@"speed"],
                           [prescStepItemInfo objectForKey:@"time"]];
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
                    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyRunSportViewController"];
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
            UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyRunSportViewController"];
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
            UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyRunSportViewController"];
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
