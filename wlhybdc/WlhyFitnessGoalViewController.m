//
//  WlhyFitnessGoalViewController.m
//  wlhybdc
//
//  Created by Hello on 13-9-24.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyFitnessGoalViewController.h"

@interface WlhyFitnessGoalViewController ()
{
    int selectedRow;
}

@end

@implementation WlhyFitnessGoalViewController

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

    self.title = @"我的健身目标";
    
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
    [rightButton setTitle:@"提交" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_0.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_1.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(self.view.frame.size.width - 70, 0, 66, 40);
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    selectedRow = [[DBM dbm].usersExt.jsmd intValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
    }
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightItemTouched:(id)sender
{
    /*
     memberid
     pwd
     jsmdCode
     */
    [self sendRequest:
     
     @{
     @"memberid": [DBM dbm].currentUsers.memberId,
     @"pwd": [DBM dbm].currentUsers.clearPwd,
     @"jsmdCode": [NSNumber numberWithInt:selectedRow]
     }
     
               action:wlModifyFitnessGoalRequest
        baseUrlString:wlServer];
    
}

#pragma mark - processRequest

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"%@,-----,%@",info,error);
    
    if ([action isEqualToString:wlModifyFitnessGoalRequest]) {
        if(info){
            if([[info objectForKey:@"errorCode"] integerValue] == 0){
                //个人信息修改成功：：1.修改本地保存的用户数据    2.返回上一页
                [self showText:@"信息保存成功"];
                [self updateLocalData];
                [self performSelector:@selector(back:) withObject:nil afterDelay:1.5f];
            } else {
                [self showText:[info objectForKey:@"errorDesc"]];
            }
            
        }else{
            [self showText:@"连接服务器失败"];
        }
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
    userExt.jsmd = [NSNumber numberWithInt:selectedRow];
    
    dbm.usersExt = userExt;
    [dbm saveContext];
}

#pragma mark - tableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSString *text = @"";
    
    switch (row) {
        case 0:
            text = @"健身";
            break;
            
        case 1:
            text = @"减肥";
            break;
            
        case 2:
            text = @"提高心肺功能";
            break;
            
        case 3:
            text = @"增肌";
            break;
            
        default:
            break;
    }
    
    
    static NSString *CellIdentifier = @"FitnessGoalCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.text = text;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    
    if (row == selectedRow) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectedRow != indexPath.row)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    selectedRow = indexPath.row;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
