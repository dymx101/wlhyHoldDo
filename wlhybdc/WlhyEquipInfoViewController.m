//
//  WlhyEquipInfo1ViewController.m
//  wlhybdc
//
//  Created by Hello on 13-8-27.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "WlhyEquipInfoViewController.h"

#import "WlhyZBarViewController.h"
#import "AOScrollerView.h"
#import "RatingView.h"



#pragma mark - Class WlhyHallMemberCell

@interface WlhyEquipImageShowCell : UITableViewCell

@property(strong, nonatomic) IBOutlet AOScrollerView *equipImagesScrollView;
@property(strong, nonatomic) IBOutlet UIImageView *errorImageView;


@end


@implementation WlhyEquipImageShowCell

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

//=================================================================================
//=================================================================================


@interface WlhyEquipInfoCell : UITableViewCell


@property(strong, nonatomic) IBOutlet UILabel *errorDescLabel;
@property(strong, nonatomic) IBOutlet UIView *equipInfoView;
@property(strong, nonatomic) IBOutlet UILabel *companyNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *equipModelLabel;
@property(strong, nonatomic) IBOutlet UILabel *equipLifeLabel;
@property(strong, nonatomic) IBOutlet UILabel *unionLabel;
@property(strong, nonatomic) IBOutlet UITextView *equipIntroTextView;
@property(strong, nonatomic) IBOutlet UIButton *instructionButton;
@property(strong, nonatomic) IBOutlet UILabel *contractNameLabel;
@property(strong, nonatomic) IBOutlet UILabel *telNumberLabel;

@end


@implementation WlhyEquipInfoCell

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

//=================================================================================
//=================================================================================


@interface WlhyEquipButtonCell : UITableViewCell


@property(strong, nonatomic) IBOutlet UIButton *evaluateButton;
@property(strong, nonatomic) IBOutlet UIButton *repairsButton;

@end


@implementation WlhyEquipButtonCell

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

//=================================================================================
//=================================================================================


@interface WlhyEquipEvaluateCountCell : UITableViewCell


@property(strong, nonatomic) IBOutlet UILabel *evaluate1Label;
@property(strong, nonatomic) IBOutlet UILabel *evaluate2Label;
@property(strong, nonatomic) IBOutlet UILabel *evaluate3Label;

@end


@implementation WlhyEquipEvaluateCountCell

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

//=================================================================================
//=================================================================================



@interface WlhyEquipEvaluateCell : UITableViewCell

@property(strong, nonatomic) IBOutlet UIImageView *headPicImageView;
@property(strong, nonatomic) IBOutlet RatingView *ratingView;
@property(strong, nonatomic) IBOutlet UILabel *nameLabel;
@property(strong, nonatomic) IBOutlet UILabel *timeLabel;
@property(strong, nonatomic) IBOutlet UILabel *contentLabel;

@end


@implementation WlhyEquipEvaluateCell

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


//===============================================================================================
//===============================================================================================

const int equipPageSize = 5;

@interface WlhyEquipInfoViewController () <WlhyZBarDelegate, ValueClickDelegate, UITableViewDelegate, UITableViewDataSource>
{
    BOOL shouldLoadMore;
    int currentPage;
    int evaluate1Count;
    int evaluate2Count;
    int evaluate3Count;
}

@property(strong, readonly, nonatomic) WlhyZBarViewController *readerVC;


@property(strong, nonatomic) NSDictionary *equipInfo;
@property(strong, nonatomic) NSMutableArray *equipPicArray;
@property(strong, nonatomic) NSString *instructionPath;
@property(strong, nonatomic) NSMutableArray *evaluateArray;



@end

@implementation WlhyEquipInfoViewController

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
    
    self.title = @"器械信息";
    
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
    [rightButton setTitle:@"购买" forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_0.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"right_img_1.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightItemTouched:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(self.view.frame.size.width - 70, 0, 66, 40);
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;

    
    _equipPicArray = [NSMutableArray array];
    _evaluateArray = [NSMutableArray array];
    currentPage = 0;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_barDecode || _barDecode.length <= 0) {
        UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyZBarViewController"];
        if ([destVC respondsToSelector:@selector(setPurposeTag:)]) {
            [destVC setValue:[NSNumber numberWithInt:1] forKey:@"purposeTag"];
        }
        if ([destVC respondsToSelector:@selector(setDelegate:)]) {
            [destVC setValue:self forKey:@"delegate"];
        }
        
        [self presentModalViewController:destVC animated:YES];
    } else if (_barDecode && _equipInfo.count <= 0) {
        if ([_barDecode hasPrefix:@"DECODE:"]) {
            _barDecode = [_barDecode substringWithRange:NSMakeRange(7, 16)];   //0001000000290001
        }
        
        [self sendRequest:
         
         @{
         @"barcodeId":_barDecode
         }
         
                   action:wlGetEqipInfoRequest
            baseUrlString:wlServer];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.view.window == nil) {
        self.view = nil;
        self.equipInfo = nil;
        self.equipPicArray = nil;
        self.instructionPath = nil;
        self.evaluateArray = nil;
    }
    
}

#pragma mark - button Handler

- (void)rightItemTouched:(id)sender
{
    
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyBuyEquipViewController"];
    if (destVC && [destVC respondsToSelector:@selector(setBarDecode:)]) {
        [destVC setValue:_barDecode forKey:@"barDecode"];
    }
    [self.navigationController pushViewController:destVC animated:YES];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - ZBar Delegate

- (void)finishGetBarCode:(NSString *)barString
{
    _barDecode = barString;
    if ([_barDecode hasPrefix:@"DECODE:"]) {
        _barDecode = [_barDecode substringWithRange:NSMakeRange(7, 16)];   //0001000000290001
    }
    
    [self sendRequest:
     
     @{@"barcodeId":_barDecode}
     
               action:wlGetEqipInfoRequest
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
        
        if ([action isEqualToString:wlGetEqipInfoRequest]) {
            
            if(0 == [[info objectForKey:@"errorCode"] integerValue]) {
                
                /*
                 {
                 barcodeid = 0001000000090000;
                 contact = "\U7126\U5764";
                 deptname = "\U6167\U52a8\U5065\U8eab";
                 dtailmsg = "\U7269\U8054\U7f5130.\U4ee3\U4e91\U8dd1\U6b65\U673a";
                 equipmodelname = "ZK-8301";
                 errorCode = 0;
                 errorDesc = "\U67e5\U8be2\U8bbe\U5907\U6210\U529f";
                 httppre = "http://www.holddo.com:80/bdcServer/img";
                 intropath = "/equip/intro/001005001_ZK-8301.doc";
                 isunit = "\U975e\U8054\U76df\U5355\U4f4d";
                 phone = 15866683903;
                 picpath = "/equip/001005001_ZK-8301_1378286382484.jpg,/equip/001005001_ZK-8301_1378347520859.jpg";
                 synx = 10;
                 },-----,(null)
                 */

                
                _equipInfo = info;
                _instructionPath = [NSString stringWithFormat:@"%@%@",
                                    [_equipInfo objectForKey:@"httppre"],
                                    [_equipInfo objectForKey:@"intropath"]];
                
                [_equipPicArray removeAllObjects];
                NSString *picString = [_equipInfo objectForKey:@"picpath"];
                NSArray *picStringElements = [picString componentsSeparatedByString:@","];
                for (NSString *tempString in picStringElements) {
                    NSString *str = [NSString stringWithFormat:@"%@%@", [_equipInfo objectForKey:@"httppre"], tempString];
                    [_equipPicArray addObject:str];
                }
                
                [self.tableView reloadData];
                
                //请求器械评价列表：：
                /*
                 memberid
                 pwd
                 barcodeid
                 pageSize
                 page
                 */
                
                
                [self sendRequest:
                 
                 @{
                 @"memberid": ([DBM dbm].currentUsers.memberId == NULL) ? @"0" : [DBM dbm].currentUsers.memberId,
                 @"pwd": ([DBM dbm].currentUsers.clearPwd == NULL) ? @"" : [DBM dbm].currentUsers.clearPwd,
                 @"barcodeid": _barDecode,
                 @"pageSize": [NSNumber numberWithInt:equipPageSize],
                 @"page": [NSNumber numberWithInt:++currentPage]
                 }
                 
                           action:wlGetEquipEvaluateListRequest
                    baseUrlString:wlServer];
                
                
            } else if ([[info objectForKey:@"errorCode"] integerValue] == 1) {
                [self showText:[info objectForKey:@"errorDesc"]];
                //请求器械信息失败：：
                
            } else{
                [self showText:[info objectForKey:@"errorDesc"]];
            }
            
            
        } else if ([action isEqualToString:wlGetEquipEvaluateListRequest]) {
            if([[info objectForKey:@"errorCode"] integerValue] == 0) {
                //请求器械评价列表 成功：：
                /*
                 {
                 arList =     (
                 {
                 context = 1234567890000000;
                 createtime = "2013-08-23 11:05:06";
                 name = "\U4eba\U5230\U4e2d\U5e74";
                 picpath = "http://www.holddo.com:80/bdcServer/img/member/18701012907.jpg";
                 sex = 1;
                 starlevel = 4;
                 },
                 {
                 context = "\U745e\U5178\U961f\U5c0f\U5b69\U513f";
                 createtime = "2013-08-30 13:58:29";
                 name = "\U65b0\U5bbe\U4f60\U61c2\U7684";
                 picpath = "http://www.holddo.com:80/bdcServer/img/member/12345678957.jpg";
                 sex = 1;
                 starlevel = 3;
                 }
                 );
                 currentPage = 1;
                 errorCode = 0;
                 errorDesc = "";
                 star1Count = 1;
                 star2Count = 0;
                 star3Count = 4;
                 star4Count = 1;
                 star5Count = 0;
                 totalPageCount = 2;
                 totalRowCount = 6;
                 },-----,(null)
                 */
                
                [_evaluateArray addObjectsFromArray:[info objectForKey:@"arList"]];
                shouldLoadMore = currentPage < [[info objectForKey:@"totalPageCount"] integerValue];
                [self.tableView reloadData];
            } else {
                [self showText:[info objectForKey:@"errorDesc"]];
            }
        }
    }else{
        [self showText:@"连接服务器失败，请稍后再试..."];
    }
}

#pragma mark - Tableview Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    } else if (section == 1) {
        return 40;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NULL;
    } else if (section == 1) {
        return @"评价信息";
    }
    return NULL;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return 3;
    } else if (section == 1) {
        if (_evaluateArray.count <= 0) {
            return 1;
        }
        return _evaluateArray.count + 2;
    }
    return NULL;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0) {
        if (row == 0) {
            return 169;
        } else if (row == 1) {
            return 154;
        } else if (row == 2) {
            return 56;
        }
    } else if (section == 1) {
        if (_evaluateArray.count <= 0) {
            return 40;
        }
        if (row == 0) {
            return 50;
        } else if (row == _evaluateArray.count + 1) {
            return 40;
        } else {
            return 84;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0) {
        if (row == 0) {
            WlhyEquipImageShowCell *cell = [tableView dequeueReusableCellWithIdentifier: @"WlhyEquipImageShowCell"];
            if (cell == nil)
            {
                cell = [[WlhyEquipImageShowCell alloc] initWithStyle: UITableViewCellStyleValue1
                                                     reuseIdentifier: @"WlhyEquipImageShowCell"];
            }
            //添加器械的滚动图片：：
            if (_equipPicArray.count <= 0) {
                cell.errorImageView.hidden = NO;
                cell.equipImagesScrollView.hidden = YES;
            } else {
                cell.errorImageView.hidden = YES;
                cell.equipImagesScrollView.hidden = NO;
            }
            [cell.equipImagesScrollView setNameArr:_equipPicArray titleArr:nil];
            cell.equipImagesScrollView.vDelegate = self;
            return cell;
        } else if (row == 1) {
            WlhyEquipInfoCell *cell = [tableView dequeueReusableCellWithIdentifier: @"WlhyEquipInfoCell"];
            if (cell == nil)
            {
                cell = [[WlhyEquipInfoCell alloc] initWithStyle: UITableViewCellStyleValue1
                                                     reuseIdentifier: @"WlhyEquipInfoCell"];
            }
            
            cell.companyNameLabel.text = [_equipInfo objectForKey:@"deptname"];
            cell.contractNameLabel.text = [_equipInfo objectForKey:@"contact"];
            cell.telNumberLabel.text = [_equipInfo objectForKey:@"phone"];
            cell.equipModelLabel.text = [_equipInfo objectForKey:@"equipmodelname"];
            cell.equipLifeLabel.text = [_equipInfo objectForKey:@"synx"];
            cell.unionLabel.text = [_equipInfo objectForKey:@"isunit"];
            cell.equipIntroTextView.text = [_equipInfo objectForKey:@"dtailmsg"];
            
            return cell;
        } else if (row == 2) {
            WlhyEquipButtonCell *cell = (WlhyEquipButtonCell *)[tableView dequeueReusableCellWithIdentifier: @"WlhyEquipButtonCell"];
            if (cell == nil)
            {
                cell = [[WlhyEquipButtonCell alloc] initWithStyle: UITableViewCellStyleValue1
                                                reuseIdentifier: @"WlhyEquipButtonCell"];
            }
            return cell;
        }
        
    } else if (section == 1) {
        
        if (_evaluateArray.count <= 0) {
            UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"cell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            }
            cell.textLabel.text = @"暂无评价信息";
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
            
            return cell;
        }
        
        
        if (row == 0) {
            //好评率等：：
            WlhyEquipEvaluateCountCell *cell = (WlhyEquipEvaluateCountCell *)[tableView
                                                            dequeueReusableHeaderFooterViewWithIdentifier:@"WlhyEquipEvaluateCountCell"];
            if (cell == nil) {
                cell = [[WlhyEquipEvaluateCountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WlhyEquipEvaluateCountCell"];
            }
            cell.evaluate1Label.text = @"1";
            cell.evaluate2Label.text = @"2";
            cell.evaluate3Label.text = @"3";
            
            return cell;
        } else if (row == _evaluateArray.count + 1) {
            //最后一行
            NSString *CellIdentifier = @"EvaluateLoadMoreCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (shouldLoadMore) {
                cell.textLabel.text = @"点击查看更多";
            } else {
                cell.textLabel.text = @"没有更多评价信息了";
                cell.userInteractionEnabled = NO;
            }
            
            return cell;
        } else {
            //评价列表：：
            NSDictionary *evaluateDic = [_evaluateArray objectAtIndex:row - 1];
            
            WlhyEquipEvaluateCell *cell = (WlhyEquipEvaluateCell *)[tableView dequeueReusableCellWithIdentifier:@"WlhyEquipEvaluateCell"];
            [cell.headPicImageView setImageWithURL:[NSURL URLWithString:[evaluateDic objectForKey:@"picpath"]]
                                  placeholderImage:[UIImage imageNamed:@"head_m.png"]];
            
            cell.nameLabel.text = [evaluateDic objectForKey:@"name"];
            cell.timeLabel.text = [[evaluateDic objectForKey:@"createtime"] substringToIndex:10];
            [cell.ratingView setImagesDeselected:@"star0.png" partlySelected:@"star1.png" fullSelected:@"star2.png"];
            [cell.ratingView displayRating:[[evaluateDic objectForKey:@"starlevel"] floatValue]];
            
            cell.contentLabel.numberOfLines = 0;
            NSString *contentString = [evaluateDic objectForKey:@"context"];
            CGSize autoSize = [contentString sizeWithFont:[UIFont systemFontOfSize:12.0f]
                                        constrainedToSize:CGSizeMake(cell.contentLabel.frame.size.width, 100.0)
                                            lineBreakMode:UILineBreakModeWordWrap];
            cell.contentLabel.frame = CGRectMake(cell.contentLabel.frame.origin.x,
                                                 34.0,
                                                 cell.contentLabel.frame.size.width,
                                                 autoSize.height);
            cell.contentLabel.text = contentString;
            
            
            return cell;
        }
    }
    return NULL;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return;
    }
    if (indexPath.row == _evaluateArray.count + 1) {
        //正在加载：：
        UITableViewCell *loadMoreCell = [tableView cellForRowAtIndexPath:indexPath];
        loadMoreCell.textLabel.text = @"正在加载...";
        
        //健身大厅成员列表：：
        /*
         memberid
         pwd
         pageSize
         page
         longitude
         latitude
         */
        [self sendRequest:
         
         @{
         @"memberid": ([DBM dbm].currentUsers.memberId == NULL) ? @"0" : [DBM dbm].currentUsers.memberId,
         @"pwd": ([DBM dbm].currentUsers.clearPwd == NULL) ? @"" : [DBM dbm].currentUsers.clearPwd,
         @"barcodeid": _barDecode,
         @"pageSize": [NSNumber numberWithInt:equipPageSize],
         @"page": [NSNumber numberWithInt:++currentPage]
         }
         
                   action:wlGetEquipEvaluateListRequest
            baseUrlString:wlServer];
        
    }
}

#pragma mark - pdf Manager

- (IBAction)scanInstructionBook:(id)sender
{
    if ([_instructionPath isEqualToString:@"http://www.holddo.com:80/bdcServer/img"]) {
        [self showText:@"未查询到该器械的使用说明书"];
        return;
    }
    
    UIViewController *destVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WlhyScanInstructionViewController"];
    if ([destVC respondsToSelector:@selector(setInstructionPath:)]) {
        [destVC setValue:_instructionPath forKey:@"instructionPath"];
        [self.navigationController pushViewController:destVC animated:YES];
    }
}


//滚动图片点击响应：：

-(void)buttonClick:(int)vid
{
    NSLog(@"click");
    return;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    UIViewController *destVC = segue.destinationViewController;
    if ([destVC respondsToSelector:@selector(setBarDecode:)]) {
        [destVC setValue:_barDecode forKey:@"barDecode"];
    }
}

@end
