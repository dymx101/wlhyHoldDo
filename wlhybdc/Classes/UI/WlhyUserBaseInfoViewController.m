//
//  WlhyUserBaseInfoViewController.m
//  wlhybdc
//
//  Created by linglong meng on 12-11-5.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyUserBaseInfoViewController.h"

#import "WlhyPopView.h"
#import "AFHTTPClient.h"
#import "TSLocateView.h"
#import "WlhyXMPP.h"

#define kDuration 0.3

@interface WlhyUserBaseInfoViewController ()<UITextFieldDelegate, UIActionSheetDelegate>
{
    CGRect _preRect;
    BOOL _isShowkeyBord;
    float originalHeight;
    float originalWeight;
    float originalWaist;
}

@property(strong, nonatomic) NSDictionary *baseInfo;


@property(strong, nonatomic) WlhyXMPP *wlhyXmpp;

@property (strong, nonatomic) IBOutlet UILabel *memberIdLabel;

@property (strong, nonatomic) IBOutlet UILabel *telphoneLabel;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *cityTextField;
@property (strong, nonatomic) IBOutlet UISegmentedControl *sexSegmente;

@property (strong, nonatomic) IBOutlet UITextField *heightTextField;
@property (strong, nonatomic) IBOutlet UITextField *weightTextField;
@property (strong, nonatomic) IBOutlet UITextField *waistTextField;

@property (strong, nonatomic) IBOutlet UITextField *birthdayTextField;

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property(strong, nonatomic) TSLocateView *cityPickerView;

// -- action

- (IBAction)cancleInputAction:(id)sender;

@end

@implementation WlhyUserBaseInfoViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordVillShow:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

#pragma mark - VC life

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"我的个人资料";
    
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
    
    self.birthdayTextField.delegate = self;
    self.birthdayTextField.inputView = self.datePicker;
    
    
    _cityPickerView = [[TSLocateView alloc] initWithTitle:@"选择城市" delegate:self];
    self.cityTextField.delegate = self;
    self.cityTextField.inputView = _cityPickerView;
    
    _heightTextField.keyboardType = UIKeyboardTypeDecimalPad;
    _weightTextField.keyboardType = UIKeyboardTypeDecimalPad;
    _waistTextField.keyboardType = UIKeyboardTypeDecimalPad;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.view = nil;
    self.memberIdLabel = nil;
    self.telphoneLabel = nil;
    self.nameTextField = nil;
    self.cityTextField = nil;
    self.sexSegmente = nil;
    self.heightTextField = nil;
    self.weightTextField = nil;
    self.waistTextField = nil;
    self.birthdayTextField = nil;
    self.datePicker = nil;
    
    
    self.baseInfo = nil;
    self.cityPickerView = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (BOOL)isHeightChanged
{
    return [_heightTextField.text floatValue] != originalHeight;
}

- (BOOL)isWeightChanged
{
    return [_weightTextField.text floatValue] != originalWeight;
}

- (BOOL)isWaistChanged
{
    return [_waistTextField.text floatValue] != originalWaist;
}


- (void)back:(id)sender
{
    if (_isForMakeUpInfo) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightItemTouched:(id)sender
{
    //提交信息：：
    
    /*
     memberId
     pwd
     name
     sex
     city
     height
     weight
     birthday
     waist
     isModifyBaseInfo
     updateFlag
     */
    
    [self cancleInputAction:nil];
    
    if ([_datePicker.date compare:localNow()] == NSOrderedDescending) {
        //选择的生日比此刻时间还晚：：
        [self showText:@"您填写的生日有误，请确认"];
        return;
    }
    
    //判断是否越界：：
    if ([_heightTextField.text floatValue] < 50.0 || [_heightTextField.text floatValue] > 250.0) {
        [self showText:@"身高填写有误，请检查"];
        return;
    }
    if ([_weightTextField.text floatValue] < 10.0 || [_weightTextField.text floatValue] > 300.0) {
        [self showText:@"体重填写有误，请检查"];
        return;
    }
    if ([_waistTextField.text floatValue] < 40.0 || [_waistTextField.text floatValue] > 200.0) {
        [self showText:@"腰围填写有误，请检查"];
        return;
    }
    
    
    if ([self isHeightChanged] || [self isWeightChanged] || [self isWaistChanged]) {
        
        NSMutableString *content = [NSMutableString stringWithString:@"我修改了身体指标：\n"];
        if ([self isHeightChanged]) {
            [content appendFormat:@"身高从 %.2f cm修改为 %@ cm；\n", originalHeight, _heightTextField.text];
        }
        if ([self isWeightChanged]) {
            [content appendFormat:@"体重从 %.2f kg修改为 %@ kg；\n", originalWeight, _weightTextField.text];
        }
        if ([self isWaistChanged]) {
            [content appendFormat:@"腰围从 %.2f cm修改为 %@ cm；", originalWaist, _waistTextField.text];
        }
        
        //向私教发送修改通知：：
        [[WlhyXMPP WlhyXMPP] connect];
        [_wlhyXmpp setMateToMyTrain];
        [[WlhyXMPP WlhyXMPP] sendMessage:content];
    }

    _baseInfo = @{
                  @"memberId":[DBM dbm].currentUsers.memberId,
                  @"pwd":[DBM dbm].currentUsers.pwd,
                  @"name": self.nameTextField.text,
                  @"sex": [NSString stringWithFormat:@"%i", self.sexSegmente.selectedSegmentIndex],
                  @"city": self.cityTextField.text,
                  @"height": self.heightTextField.text,
                  @"weight": self.weightTextField.text,
                  @"birthday": _birthdayTextField.text,      //getDateStringWithNSDateAndDateFormat(birthDate, @"yyyy-MM-dd"),
                  @"waist": self.waistTextField.text,
                  @"isModifyBaseInfo": @"1",
                  @"updateFlag": @"111",
                  };
    
    [self sendRequest:_baseInfo
               action:wlModifyMemberInfoRequest
        baseUrlString:wlServer];
    
}

#pragma mark - processRequest

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"%@,-----,%@",info,error);
    
    if(!error){
        if ([action isEqualToString:wlModifyMemberInfoRequest]) {
            
        }
        if([[info objectForKey:@"errorCode"] integerValue] == 0){
            //个人信息修改成功：：1.修改本地保存的用户数据    2.返回上一页
            [self showText:@"信息保存成功"];
            [self updateLocalData];
            
            [self performSelector:@selector(handlerVCChange:) withObject:nil afterDelay:1.5f];
        } else {
            [self showText:[info objectForKey:@"errorDesc"]];
        }
        
    }else{
        [self showText:@"连接服务器失败，请稍后再试..."];
    }
}


- (void)handlerVCChange:(id)sender
{
    if (_isForMakeUpInfo) {
        UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhySportHabitViewController"];
        if([destVC respondsToSelector:@selector(setIsForMakeUpInfo:)]){
            [destVC setValue:@YES forKey:@"isForMakeUpInfo"];
            [self.navigationController pushViewController:destVC animated:YES];
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - set UI

- (void)setUI
{
    Users * users = [[DBM dbm] currentUsers];
    NSString * title =@"";
    if(users){
        if(!IsEmptyString( users.userName)){
            title=users.userName;
        }else {
            title = [users.memberId stringValue];
        }
    }
    
    UsersExt *userExt = [[DBM dbm] usersExt];
    self.nameTextField.text=WlhyString(title);
    self.memberIdLabel.text=[users.memberId stringValue];
    self.telphoneLabel.text=userExt.phone;
    self.cityTextField.text = userExt.city;
    [self.sexSegmente setSelectedSegmentIndex:[userExt.sex integerValue]];
    self.heightTextField.text=[userExt.height stringValue];
    self.weightTextField.text=[userExt.weight stringValue];
    self.waistTextField.text=[userExt.waist stringValue];
    self.birthdayTextField.text=[userExt birthday];
    
    originalHeight = [userExt.height floatValue];
    originalWeight = [userExt.weight floatValue];
    originalWaist = [userExt.waist floatValue];
    
}

//个人信息提交成功后，将本地数据同步更新：：
- (void)updateLocalData
{
    DBM *dbm = [DBM dbm];
    
    UsersExt *userExt = [[DBM dbm] getUsersExtByMemberId:dbm.currentUsers.memberId];
    if(!userExt){
        userExt = [dbm createNewRecord:@"UsersExt"];
    }
    
    [dbm saveRecord:userExt info:_baseInfo];
    
    dbm.usersExt = userExt;
    dbm.currentUsers.userName = userExt.name;
    [dbm saveContext];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _cityPickerView = (TSLocateView *)actionSheet;
    TSLocation *location = _cityPickerView.locate;
    
    //You can uses location to your application.
    if(buttonIndex == 0) {
        NSLog(@"Cancel");
    }else {
        NSLog(@"Select");
        _cityTextField.text = location.city;
        NSLog(@"city:%@ lat:%f lon:%f", location.city, location.latitude, location.longitude);
    }
    
    [self.view endEditing:NO];
}


#pragma mark - keyBoard

- (void)keybordVillShow:(NSNotification*)notif
{
    if(_isShowkeyBord){
        return;
    }
    _isShowkeyBord=YES;
    _preRect = self.tableView.frame;
    UIView * fistResponderView = [self.tableView findFirstResponder];
    if(!fistResponderView){
        return;
    }
    // 判断是否遮挡
    CGRect keybordFrame ;
    [[notif.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keybordFrame];
    
    if(fistResponderView.frame.origin.y  + fistResponderView.frame.size.height + keybordFrame.size.height<= self.view.frame.size.height){
        return;
    }
    
    // find table cell
    UIView* superView = nil;
    do{
        superView = fistResponderView.superview;
        if([superView isKindOfClass:[UITableViewCell class]]){
            break;
        }
        superView = superView.superview;
    }while( superView);
    if(!superView){
        return;
    }
    NSIndexPath* indexPath = [self.tableView indexPathForCell:(UITableViewCell*)superView];
    if(!indexPath){
        return;
    }
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
}



#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == self.birthdayTextField){
        if(IsEmptyString(textField.text)){
            NSDateFormatter * f = [[NSDateFormatter alloc] init];
            [f setDateFormat:@"YYYY-MM-dd"];
            textField.text=[f stringFromDate:self.datePicker.date];
        }
    }
    if (textField == _cityTextField) {
        if (_cityPickerView == nil) {
            _cityPickerView = [[TSLocateView alloc] initWithTitle:@"选择城市" delegate:self];
            self.cityTextField.delegate = self;
            self.cityTextField.inputView = _cityPickerView;
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == self.birthdayTextField){
        
        NSDateFormatter * f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"YYYY-MM-dd"];
        textField.text=[f stringFromDate:self.datePicker.date];
    }
    if (textField == _cityTextField) {
        NSLog(@"view Height :: %f", self.view.frame.size.height);
        
        CATransition *animation = [CATransition  animation];
        animation.delegate = self;
        animation.duration = kDuration;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromBottom;
        [_cityPickerView setAlpha:0.01f];
        [_cityPickerView.layer addAnimation:animation forKey:@"TSLocateView"];
        
        [self performSelector:@selector(removeCityPickerView:) withObject:nil afterDelay:kDuration];
        
    }
    
}

- (void)removeCityPickerView:(id)sender
{
    [_cityPickerView removeFromSuperview];
    _cityPickerView = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *destVC = segue.destinationViewController;
    
    if (destVC && [destVC respondsToSelector:@selector(setScanParam:)]) {
        [destVC setValue:segue.identifier forKey:@"scanParam"];
    }
}

- (IBAction)cancleInputAction:(id)sender
{
    [self.view endEditing:NO];
}


@end
