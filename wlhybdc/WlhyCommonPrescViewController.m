//
//  WlhyCommonPrescViewController.m
//  wlhybdc
//
//  Created by ios on 13-8-2.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyCommonPrescViewController.h"


@interface WlhyCommonPrescViewController ()

@property(strong, nonatomic) NSDictionary *presc1;
@property(strong, nonatomic) NSDictionary *presc2;
@property(strong, nonatomic) NSDictionary *presc3;
@property(strong, nonatomic) NSDictionary *presc4;

- (IBAction)buttonTouched:(id)sender;

@end

@implementation WlhyCommonPrescViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    
    if (self.view.window == nil) {
        self.view = nil;
    }
    self.presc1 = nil;
    self.presc2 = nil;
    self.presc3 = nil;
    self.presc4 = nil;
}

#pragma mark - IBAction

- (IBAction)buttonTouched:(id)sender
{
    int buttonTag = [(UIButton *)sender tag];

    NSDictionary *prescDic;
    NSString *jsonString = @"";
    
    NSError *error;
    
    switch (buttonTag) {
        case 100:
            jsonString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"presc1" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
            prescDic = JSONObjectFromString(jsonString);
            break;
            
        case 101:
            jsonString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"presc2" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
            prescDic = JSONObjectFromString(jsonString);
            break;
            
        case 102:
            jsonString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"presc3" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
            prescDic = JSONObjectFromString(jsonString);
            break;
            
        case 103:
            jsonString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"presc4" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
            prescDic = JSONObjectFromString(jsonString);
            break;
            
        default:
            break;
    }
    
    /*
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *flagDic = [NSDictionary dictionary];
    NSString *prescKey = [NSString stringWithFormat:@"%@+commonPresc%i",
                          [DBM dbm].currentUsers.memberId, buttonTag - 100];
    
    NSDictionary *existedPresc = [userDefaults dictionaryForKey:prescKey];
    
    NSLog(@"existedPresc :: %@", existedPresc);
    
    if (existedPresc) {
        if ([existedPresc objectForKey:@"flagInfo"] != NULL) {
            //已存在之前的该器械的处方执行信息，且执行日期不是当天，则删除：：
            NSString *storeTime = [self getDateStringWithNSDate:
                                   [[existedPresc objectForKey:@"flagInfo"] objectForKey:@"storeTime"]
                                                  andDateFormat:@"yyyy-MM-dd"];
            
            NSLog(@"storeTime   %@", [[existedPresc objectForKey:@"flagInfo"] objectForKey:@"storeTime"]);
            NSLog(@"storeTimeStr%@", storeTime);
            NSLog(@"localNow    %@", [self getDateStringWithNSDate:localNow() andDateFormat:@"yyyy-MM-dd"]);
            
            if (![storeTime isEqualToString:[self getDateStringWithNSDate:localNow() andDateFormat:@"yyyy-MM-dd"]]) {
                [userDefaults removeObjectForKey:prescKey];
            }
        }
    } else {
        //之前没有该器械的处方执行信息：：这是一个全新的处方
        [userDefaults setObject:
         
         @{@"dataSource":prescDic,
         @"flagInfo":   flagDic}
         
                         forKey:prescKey];
        
        [userDefaults synchronize];
    }
    */
    
    UIViewController *destVC = [self.storyboard
                                instantiateViewControllerWithIdentifier:@"WlhyRunPrescriptionViewController"];
    if ([destVC respondsToSelector:@selector(setCommonPrescTag:)]) {
        [destVC setValue:[NSNumber numberWithInt:buttonTag-100] forKey:@"commonPrescTag"];
    }
    if ([destVC respondsToSelector:@selector(setBarDecode:)]) {
        NSLog(@"_barDecode :: %@", _barDecode);
        [destVC setValue:_barDecode forKey:@"barDecode"];
    }
    
    [self.navigationController pushViewController:destVC animated:NO];
}


@end
