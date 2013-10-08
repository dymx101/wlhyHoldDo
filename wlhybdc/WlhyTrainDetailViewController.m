//
//  WlhyTrainDetailViewController.m
//  wlhybdc
//
//  Created by Hello on 13-9-11.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyTrainDetailViewController.h"

@interface WlhyTrainDetailViewController () <UIActionSheetDelegate>

@property(strong, nonatomic) IBOutlet UIImageView *headImageView;
@property(strong, nonatomic) IBOutlet UIImageView *sexIconImageView;
@property(strong, nonatomic) IBOutlet UILabel *nameLabel;
@property(strong, nonatomic) IBOutlet UILabel *ageLabel;
@property(strong, nonatomic) IBOutlet UILabel *educationLevelLabel;
@property(strong, nonatomic) IBOutlet UIButton *mobileTelButtton;
@property(strong, nonatomic) IBOutlet UILabel *QQLabel;
@property(strong, nonatomic) IBOutlet UIButton *emailLabel;
@property(strong, nonatomic) IBOutlet UILabel *experienceLabel;
@property(strong, nonatomic) IBOutlet UILabel *honorLabel;

- (IBAction)telButtonTapped:(id)sender;

@end

@implementation WlhyTrainDetailViewController

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

    self.title = @"私教详情";
    
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
    
    NSLog(@"_trainInfo :: %@", _trainInfo);
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /*
     {
     account = 33500000000;
     activity = 0;
     age = 25;
     blog = 33500000000;
     channel = 33500000000;
     deptName = "wangm\U6d4b\U8bd5\U4ff1\U4e50\U90e8";
     deptid = 001003015;
     eMail = 33500000000;
     educational = 4;
     errorCode = 0;
     errorDesc = "\U67e5\U8be2\U5065\U8eab\U79c1\U6559\U8be6\U7ec6\U4fe1\U606f\U6210\U529f";
     experience = "\U79c1\U65590815";
     honor = "\U79c1\U65590815";
     integral = 0;
     introduction = "\U79c1\U65590815";
     isonline = "\U79bb\U7ebf";
     level = 0;
     nickname = "\U79c1\U65590815";
     picture = "http://www.holddo.com:80/bdcServer/img/personaltrainer/33500000000.jpg";
     remark = "\U79c1\U65590815";
     sex = 2;
     specialSkill = 4;
     userId = 181;
     userName = "\U79c1\U65590815";
     userQQ = 33500000000;
     userStaticTel = "";
     userTel = 33500000000;
     userType = 41;
     worktime = "8:30-17:30";
     }
    */
    
    int sexInt = [[_trainInfo objectForKey:@"sex"] intValue];
    __block WlhyTrainDetailViewController *this = self;
    NSString *picString = [_trainInfo objectForKey:@"picture"];
    
    [_headImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:picString]] placeholderImage:[UIImage imageNamed:picString] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [this.headImageView setImage:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        if (sexInt == 0) {
            [this.headImageView setImage:[UIImage imageNamed:@"head_f.png"]];
        } else {
            [this.headImageView setImage:[UIImage imageNamed:@"head_sj.png"]];
        }
    }];
    
    
    NSString *sexImageName = ((int)[_trainInfo objectForKey:@"SEX"] == 1) ? @"maleIcon.png" : @"fmaleIcon.png";
    [_sexIconImageView setImage:[UIImage imageNamed:sexImageName]];
    if ((int)[_trainInfo objectForKey:@"SEX"] == 0) {
        _sexIconImageView.hidden = YES;
    }
    
    _nameLabel.text = [_trainInfo objectForKey:@"nickname"];
    _ageLabel.text = [_trainInfo objectForKey:@"age"];
    _educationLevelLabel.text = @"";
    _QQLabel.text = [_trainInfo objectForKey:@"userQQ"];
    [_mobileTelButtton setTitle:[_trainInfo objectForKey:@"userTel"] forState:UIControlStateNormal];
    [_mobileTelButtton setTitle:[_trainInfo objectForKey:@"userTel"] forState:UIControlStateHighlighted];
    [_emailLabel setTitle:[_trainInfo objectForKey:@"eMail"] forState:UIControlStateNormal];
    [_emailLabel setTitle:[_trainInfo objectForKey:@"eMail"] forState:UIControlStateHighlighted];
    _experienceLabel.text = [_trainInfo objectForKey:@"experience"];
    _honorLabel.text = [_trainInfo objectForKey:@"honor"];
    
    /*
     @property(strong, nonatomic) IBOutlet UIImageView *headImageView;
     @property(strong, nonatomic) IBOutlet UIImageView *sexIconImageView;
     @property(strong, nonatomic) IBOutlet UILabel *nameLabel;
     @property(strong, nonatomic) IBOutlet UILabel *ageLabel;
     @property(strong, nonatomic) IBOutlet UILabel *educationLevelLabel;
     @property(strong, nonatomic) IBOutlet UIButton *mobileTelButtton;
     @property(strong, nonatomic) IBOutlet UIButton *QQButtton;
     @property(strong, nonatomic) IBOutlet UIButton *emailLabel;
     @property(strong, nonatomic) IBOutlet UILabel *experienceLabel;
     @property(strong, nonatomic) IBOutlet UILabel *honorLabel;
    */
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        self.headImageView = nil;
        self.sexIconImageView = nil;
        self.nameLabel = nil;
        self.ageLabel = nil;
        self.educationLevelLabel = nil;
        self.mobileTelButtton = nil;
        self.QQLabel = nil;
        self.emailLabel = nil;
        self.experienceLabel = nil;
        self.honorLabel = nil;
        
        self.trainInfo = nil;
    }
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)telButtonTapped:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    if (![btn.currentTitle hasPrefix:@"1"]) {
        //return;
    }
    int tag = btn.tag;
    
    if (tag == 1300) {
        //手机号码按钮：：
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:[NSString stringWithFormat:@"联系 %@", btn.currentTitle]
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"呼叫",@"发短信", nil];
        [actionSheet showInView:self.view];
        
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
        [self callPhone:[_trainInfo objectForKey:@"userTel"]];
    } else if (buttonIndex == 1) {
        [self sendMessageToPhone:[_trainInfo objectForKey:@"userTel"]];
    }
}

- (void)callPhone:(NSString *)phoneNumber
{
    NSString *callTelString = [NSString stringWithFormat:@"tel://%@", phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callTelString]];
}

- (void)sendMessageToPhone:(NSString *)phoneNumber
{
    NSString *callTelString = [NSString stringWithFormat:@"sms://%@", phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callTelString]];
}

@end
