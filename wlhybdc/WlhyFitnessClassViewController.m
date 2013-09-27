//
//  WlhyFitnessClassViewController.m
//  wlhybdc
//
//  Created by ios on 13-7-10.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyFitnessClassViewController.h"

@interface WlhyFitnessClassCell : UITableViewCell


@property(strong, nonatomic) IBOutlet UIImageView *classThumbImageView;
@property(strong, nonatomic) IBOutlet UILabel *classNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *teacherNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *scanCountLabel;
@property(strong, nonatomic) IBOutlet UILabel *startTimeLabel;
@property(strong, nonatomic) IBOutlet UILabel *endTimeLabel;

@end



@implementation WlhyFitnessClassCell

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

//=============================================================================================
//=============================================================================================



@interface WlhyFitnessClassViewController ()

@property(strong, nonatomic) UIImageView *backgroundImageView;

@property(strong, nonatomic) NSArray *fitnessClassesArray;

@end

@implementation WlhyFitnessClassViewController

@synthesize fitnessClassesArray = _fitnessClassesArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - VC life

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"健身课堂";
    
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



- (void)viewDidAppear:(BOOL)animated
{
    [self sendRequest:
     
     @{@"memberId":[DBM dbm].currentUsers.memberId,
     @"pwd":[DBM dbm].currentUsers.pwd}
     
               action:wlGetFitnessClassRequest
        baseUrlString:wlServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -  net response function

-(void)processRequest:(NSString *)action info:(NSDictionary *)info error:(NSError *)error
{
    if(!error){
        NSLog(@"%@",info);
        NSNumber* errorCode = [info objectForKey:@"errorCode"];
        if(errorCode.intValue == 0){
            
            NSLog(@"info :: %@", info);
            NSLog(@"classes number :: %i", [[info objectForKey:@"historyFitnessClasses"] count]);
            _fitnessClassesArray = [info objectForKey:@"historyFitnessClasses"];
            [self.tableView reloadData];
            
            
        }else {
            [self showText:[info objectForKey:@"errorDesc"]];
        }
    }else{
        [self showText:@"连接服务器失败！"];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_fitnessClassesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     {
     classAbout = "\U4e0d\U7528\U8282\U98df\Uff0c\U4e0d\U9700\U5403\U836f\Uff0c\U5982\U4f55\U4fdd\U6301\U4e00\U4e2a\U5b8c\U7f8e\U7684\U8eab\U6750\Uff0c\U53ea\U6709\U8fd0\U52a8\U624d\U662f\U5065\U5eb7\U51cf\U80a5\U7684\U552f\U4e00\U9014\U5f84\Uff0c\U6b22\U8fce\U5927\U5bb6\U6765\U542c\U53d6\U4e2d\U5927\U5065\U5eb7\U4e13\U5bb6\U7684\U8bb2\U5ea7\U3002";
     className = "\U5982\U4f55\U5065\U5eb7\U51cf\U80a5";
     classTime = "2013-06-05 20:54:53";
     classType = "\U5065\U8eab";
     expertAbout = "\U7855\U58eb\Uff0c\U4e2d\U56fd\U5065\U8eab\U4ea7\U4e1a\U6280\U672f\U521b\U65b0\U6218\U7565\U8054\U76df\U59d4\U5458\Uff0c\U56fd\U5bb6\U4f53\U80b2\U603b\U5c40\U4f53\U80b2\U79d1\U5b66\U7814\U7a76\U6240\U5de5\U7a0b\U5e08\Uff0c\U5728\U751f\U6d3b\U65b9\U5f0f\U5e72\U9884\U4f53\U91cd\U3001\U964d\U4f4e\U8840\U538b\U65b9\U9762\U5177\U6709\U4e30\U5bcc\U7684\U7ecf\U9a8c\U3002";
     expertName = "\U5f20\U660e\U541b";
     expertPic = "http://42.121.106.113:80/bdcServer/img/files/img/zzj.jpg";
     expertPost = "\U8fd0\U52a8\U5065\U5eb7\U7ba1\U7406\U5e08";
     indexid = 27;
     joinPersionNum = 0;
     remainDay = "-838:59:59";
     sex = 1;
     views = 1;
     }
    */
    
    NSUInteger row = [indexPath row];
    static NSString *CellIdentifier = @"FitnessClassCell";
    
    WlhyFitnessClassCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell.classThumbImageView setImageWithURL:[NSURL URLWithString:
                                            [[_fitnessClassesArray objectAtIndex:row] objectForKey:@"expertPic"]]];
    cell.teacherNameLabel.text = [[_fitnessClassesArray objectAtIndex:row] objectForKey:@"expertName"];
    cell.classNameLabel.text = [[_fitnessClassesArray objectAtIndex:row] objectForKey:@"className"];
    cell.scanCountLabel.text = [NSString stringWithFormat:@"%@", [[_fitnessClassesArray objectAtIndex:row] objectForKey:@"views"]];
    cell.startTimeLabel.text = [[_fitnessClassesArray objectAtIndex:row] objectForKey:@"classTime"];
    cell.endTimeLabel.text = [[_fitnessClassesArray objectAtIndex:row] objectForKey:@"remainDay"];
    
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
}

@end
