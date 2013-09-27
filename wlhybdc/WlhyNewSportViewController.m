//
//  WlhyNewSportViewController.m
//  wlhybdc
//
//  Created by ios on 13-7-24.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyNewSportViewController.h"

#import "WlhyZBarViewController.h"


@interface WlhyNewSportViewController () <WlhyZBarDelegate>
{
    EquipType equipType;
}


@property(strong, nonatomic) WlhyZBarViewController *readerVC;
@property(strong, nonatomic) NSDictionary *prescInfo;
@property(strong, nonatomic) NSString *barDecodeString;


@end

//-----------------------------------------------------------------

@implementation WlhyNewSportViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - VC lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"今日处方";
    
    //自定义返回：：
    self.navigationItem.hidesBackButton = YES;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyZBarViewController"];
    if ([destVC respondsToSelector:@selector(setPurposeTag:)]) {
        [destVC setValue:[NSNumber numberWithInt:2] forKey:@"purposeTag"];
    }
    if ([destVC respondsToSelector:@selector(setDelegate:)]) {
        [destVC setValue:self forKey:@"delegate"];
    }
    
    [self presentModalViewController:destVC animated:YES];
}

- (void)viewDidUnload
{
    self.readerVC = nil;
    self.prescInfo = nil;
    self.barDecodeString = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ZBar Delegate

- (void)finishGetBarCode:(NSString *)barString
{
    _barDecodeString = barString;
    if ([_barDecodeString hasPrefix:@"DECODE:"]) {
        _barDecodeString = [_barDecodeString substringWithRange:NSMakeRange(7, 16)];   //0001000000290001
    }
    
    //通过器械二维码请求器械使用说明：：
    
    [self sendRequest:
     
     @{@"memberId":[DBM dbm].currentUsers.memberId,
     @"pwd":[DBM dbm].currentUsers.pwd,
     @"barcodeId":_barDecodeString}
     
               action:wlGetPrescriptionContentsRequest
        baseUrlString:wlServer];
    
    // 扫描界面退出
    [_readerVC dismissModalViewControllerAnimated: YES];
}

- (void)failedGetBarCode:(NSError *)error
{
    
}

- (void)cancelZBarScan:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - processRequest

- (void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    NSLog(@"action :: %@", action);
    NSLog(@"%@,-----,%@",info,error);
    
    if(!error){
        
        equipType = [[_prescInfo objectForKey:@"equipType"] integerValue];
        
        if([[info objectForKey:@"errorCode"] integerValue] == 0){
            
            if ([[info objectForKey:@"sfxx"] integerValue] == 0) {
                [self handlerNoPrescWithInfo:info];
                
            } else {
                //有处方：：
                _prescInfo = info;
                equipType = [[_prescInfo objectForKey:@"equipType"] integerValue];
                
                //保存处方到本地：：
                [self handlerLocalPresc];
                
                [self pushViewControllerWithPrescInfo];
            }
            
            
        }else if ([[info objectForKey:@"errorCode"] integerValue] == 1) {
            //服务未激活：：
            [self handlerNoPrescWithInfo:info];
        }
        else if ([[info objectForKey:@"errorCode"] integerValue] == 2) {
            //没有处方：：
            [self handlerNoPrescWithInfo:info];
        }else{
            [self showText:[info objectForKey:@"errorDesc"]];
        }
        
    }else{
        [self showText:@"连接服务器失败，请稍后再试..."];
    }
    
    // 扫描界面退出
    [_readerVC dismissModalViewControllerAnimated: YES];
}

- (NSString *)getDateStringWithNSDate:(NSDate *)date andDateFormat:(NSString *)dateFormat
{
    if (dateFormat == NULL) {
        dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

- (void)handlerLocalPresc
{
    NSLog(@"localNow :: %@", localNow());
    
    if(!_prescInfo){
        return;
    }
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *flagDic = [NSDictionary dictionary];
    NSString *prescKey = [NSString stringWithFormat:@"%@+%@",
                                 [DBM dbm].currentUsers.memberId, _barDecodeString];
    
    NSLog(@"prescKey :: %@", prescKey);
    
    NSDictionary *existedPresc = [userDefaults dictionaryForKey:prescKey];
    
    NSLog(@"existedPresc :: %@", existedPresc);
    
    if (existedPresc) {
        flagDic = [existedPresc objectForKey:@"flagInfo"];
        if (flagDic.count > 0) {
            //已存在之前的该器械的处方执行信息，且执行日期不是当天，则删除：：
            NSLog(@"flagDic :: %@", flagDic);
            NSString *storeTime = getDateStringWithNSDateAndDateFormat([flagDic objectForKey:@"storeTime"], @"yyyy-MM-dd");
            
            NSLog(@"storeTimeStr%@", storeTime);
            NSLog(@"localNow    %@", getDateStringWithNSDateAndDateFormat(localNow(), @"yyyy-MM-dd"));
            
            if (![storeTime isEqualToString:getDateStringWithNSDateAndDateFormat(localNow(), @"yyyy-MM-dd")]) {
                [userDefaults removeObjectForKey:prescKey];
                [userDefaults setObject:
                 
                 @{@"dataSource":_prescInfo,
                 @"flagInfo":   flagDic}
                 
                                 forKey:prescKey];
                [userDefaults synchronize];
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
}

#pragma mark - show different display With Info

- (void)pushViewControllerWithPrescInfo
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

    
    
    NSString *VCIdentifier;
    
    NSLog(@"equipType :: %i", equipType);
    
    switch (equipType) {
        case EquipTypePaoBuJi:
            VCIdentifier = @"WlhyRunPrescriptionViewController";
            break;
        case EquipTypeDanChe:
            VCIdentifier = @"WlhyBikePrescriptionViewController";
            break;
        case EquipTypeLiLiangXunLianQi:
            VCIdentifier = @"WlhyStrengthPrescriptionViewController";
            break;
        case EquipTypeTuoYuanJi:
            VCIdentifier = @"WlhyTyjPrescriptionViewController";
            break;
        default:
            return;
            break;
    }
    
    if (VCIdentifier == nil) {
        return;
    }
    
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:VCIdentifier];
    if (destVC) {
        if ([destVC respondsToSelector:@selector(setBarDecode:)]) {
            [destVC setValue:_barDecodeString forKey:@"barDecode"];
        }
        if ([destVC respondsToSelector:@selector(setCommonPrescTag:)]) {
            [destVC setValue:[NSNumber numberWithInt:-1] forKey:@"commonPrescTag"];
        }
        
        [self.navigationController pushViewController:destVC animated:NO];
    }
    
}

//处理没有处方：：
- (void)handlerNoPrescWithInfo:(NSDictionary *)info
{
    
    NSLog(@"info :: %@", info);
    
    if (![info objectForKey:@"equipType"] || [[info objectForKey:@"equipType"] isEqualToString:@""]) {
        //二维码无效：：
        [self showText:@"无效的器械二维码"];
        [self performSelector:@selector(back:) withObject:nil afterDelay:1.5];
        return;
    }
    
    /*
     //没有处方：：
     {
     bdrConnPath = "http://42.121.106.113:8888";
     equipType = 1001;
     errorCode = 2;
     errorDesc = "\U5904\U65b9\U5236\U5b9a\U4e2d\Uff0c1-2\U4e2a\U5de5\U4f5c\U65e5\U540e\U751f\U6548\Uff0c\U5177\U4f53\U4e8b\U5b9c\U8bf7\U54a8\U8be2\U60a8\U7684\U79c1\U6559";
     generation = 3;
     }
     */
    
    equipType = [[info objectForKey:@"equipType"] integerValue];
    
    NSString *VCIdentifier = @"";
    
    NSLog(@"equipType :: %i", equipType);
    
    switch (equipType) {
        case EquipTypePaoBuJi:
            VCIdentifier = @"WlhyNoRunPrescriptionViewController";
            break;
        case EquipTypeDanChe:
            VCIdentifier = @"WlhyNoBikePrescriptionViewController";
            break;
        case EquipTypeLiLiangXunLianQi:
            VCIdentifier = @"WlhyNoBikePrescriptionViewController";
            break;
        default:
            VCIdentifier = @"WlhyNoBikePrescriptionViewController";
            break;
    }
    
    if (VCIdentifier == nil) {
        [self showText:@"暂无该器械"];
        return;
    }
    
    NSLog(@"VCIdentifier:: %@", VCIdentifier);
    
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:VCIdentifier];
    if (destVC) {
        if ([destVC respondsToSelector:@selector(setDesc:)]) {
            [destVC setValue:[info objectForKey:@"errorDesc"] forKey:@"desc"];
        }
        [self.navigationController pushViewController:destVC animated:NO];
    }
    
}

- (void)back:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)scanHandler:(id)sender
{
    return;
}

@end
