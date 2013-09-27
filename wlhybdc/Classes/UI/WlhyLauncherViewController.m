//
//  WlhyLauncherViewController.m
//  wlhybdc
//
//  Created by linglong meng on 12-11-20.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyLauncherViewController.h"
#import "WlhyLauncherViewModel.h"



#import "NimbusBadge.h"

@implementation BadgedLauncherViewObject

@synthesize badgeNumber = _badgeNumber;

- (id)initWithTitle:(NSString *)title image:(UIImage *)image badgeNumber:(NSInteger)badgeNumber tager:(NSString *)tager {
    if ((self = [super initWithTitle:title image:image])) {
        _badgeNumber = badgeNumber;
        self.targer = tager;
    }
    return self;
}

+ (id)objectWithTitle:(NSString *)title image:(UIImage *)image badgeNumber:(NSInteger)badgeNumber tager:(NSString *)tager {
    return [[self alloc] initWithTitle:title image:image badgeNumber:badgeNumber tager:tager];
}

- (Class)buttonViewClass {
    return [BadgedLauncherButtonView class];
}

@end

@implementation BadgedLauncherButtonView

@synthesize badgeView = _badgeView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
        _badgeView = [[NIBadgeView alloc] initWithFrame:CGRectZero];
        _badgeView.backgroundColor = [UIColor clearColor];
        _badgeView.hidden = YES;
        
        // This ensures that the badge will not eat taps.
        _badgeView.userInteractionEnabled = NO;
        
        [self addSubview:_badgeView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //self.label.frame=CGRectZero;
    self.button.frame =UIEdgeInsetsInsetRect(self.bounds, self.contentInset);
    [self.badgeView sizeToFit];
    // Find the image's top right corner.
    CGPoint imageTopRight = CGPointMake(floorf((self.button.frame.size.width)), 0);
    
    // Center the badge on the image's top right corner.
    self.badgeView.frame = CGRectMake(floorf(imageTopRight.x - 40),
                                      floorf(imageTopRight.y + 10),
                                      self.badgeView.frame.size.width, self.badgeView.frame.size.height);

//    [self.button setImage:[self.button imageForState:UIControlStateNormal] forState:UIControlStateNormal];

}

- (void)shouldUpdateViewWithObject:(BadgedLauncherViewObject *)object
{
    [super shouldUpdateViewWithObject:object];
    NSLog(@"%@",NSStringFromCGSize(object.image.size));
    
    NSInteger badgeNumber = boundi(object.badgeNumber, 0, 100);
    if (object.badgeNumber > 0) {
        if (badgeNumber < 100) {
            self.badgeView.text = [NSString stringWithFormat:@"%d", badgeNumber];
        } else {
            self.badgeView.text = @"99+";
        }
        self.badgeView.hidden = NO;
        
    } else {
        self.badgeView.hidden = YES;
    }
}

@end


//////////////////////////////////////////////////////////////////////////
// 


@interface WlhyLauncherViewController()<NILauncherViewModelDelegate>

@property (nonatomic, readwrite, retain) NILauncherViewModel* model;
@end

@implementation WlhyLauncherViewController

@synthesize model=_model;


-(id)init
{
    self = [super init];
    if(self){
        _model = [[WlhyLauncherViewModel alloc] initWithArrayOfPages:@[
                  @[
                  [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"qtjd0.png"] badgeNumber:0 tager:@"WlhyWaiterServiceViewController"],/*前台接待*/
                  [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"jssj0.png"] badgeNumber:0 tager:@"WlhyPrivateTrainViewController"],/*健身私教*/
                  [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"xxtx0.png"] badgeNumber:0 tager:@"WlhyMessageReminderViewController"],/*消息提醒*/
                  [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"grzx0.png"] badgeNumber:0 tager:@"WlhyUserCenterViewController"],/*个人中心*/
                  [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"hdsc0.png"] badgeNumber:0 tager:@"WlhyHoldDoStoreViewController"],/*慧动商城*/
                  [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"jsdt0.png"] badgeNumber:0 tager:@"WlhyFitnessHallViewController"]/*健身大厅*/
                  ],
        
                  @[
                  [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"jhfw0.png"] badgeNumber:0 tager:@"WlhyRechargeViewController"],/*激活服务*/
                  [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"qcxx0.png"] badgeNumber:0 tager:@"WlhyEquipInfoViewController"],/*器材信息*/
                  [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"gyhd0.png"] badgeNumber:0 tager:@"WlhyAboutHoldDoViewController"],/*关于慧动*/
                  ]
                  ]
                                                            delegate:self];
        
        
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.launcherView.backgroundColor=[UIColor clearColor];
    self.launcherView.contentInsetForPages=UIEdgeInsetsMake(0, 0, 0, 0);
    self.launcherView.buttonSize=CGSizeMake(90, 90);
    self.launcherView.dataSource=_model;
}


#pragma mark - NILauncherView Model Delegate

- (void)launcherViewModel:(NILauncherViewModel *)launcherViewModel
      configureButtonView:(UIView<NILauncherButtonView> *)buttonView
          forLauncherView:(NILauncherView *)launcherView
                pageIndex:(NSInteger)pageIndex
              buttonIndex:(NSInteger)buttonIndex
                   object:(id<NILauncherViewObject>)object
{
    
    // The NILauncherViewObject object always creates a NILauncherButtonView so we can safely cast
    // here and update the label's style to add the nice blurred shadow we saw in the
    // BasicInstantiation example.
    NILauncherButtonView* launcherButtonView = (NILauncherButtonView *)buttonView;
    launcherButtonView.label.layer.shadowColor = [UIColor redColor].CGColor;
    launcherButtonView.label.layer.shadowOffset = CGSizeMake(0, 1);
    launcherButtonView.label.layer.shadowOpacity = 1;
    launcherButtonView.label.layer.shadowRadius = 1;
}

-(void)launcherView:(NILauncherView *)launcherView didSelectItemOnPage:(NSInteger)page atIndex:(NSInteger)index
{
    id<NILauncherViewObject> object = [self.model objectAtIndex:index pageIndex:page];
    
    if([object isKindOfClass:[BadgedLauncherViewObject class]]){
        BadgedLauncherViewObject* obj = (BadgedLauncherViewObject*)object;
        if(!IsEmptyString(obj.targer)){
            postNotification(wlhyShowViewControllerNotification, @{@"Identifier":obj.targer,@"push":@YES});
        }
    }
}

- (void)updateBadgeNumbers:(NSArray *)badgeNumbers
{
    
    _model = [[WlhyLauncherViewModel alloc] initWithArrayOfPages:@[
              @[
              [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"qtjd0.png"] badgeNumber:[[badgeNumbers objectAtIndex:0] intValue] tager:@"WlhyWaiterServiceViewController"],/*前台接待*/
              [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"jssj0.png"] badgeNumber:[[badgeNumbers objectAtIndex:1] intValue] tager:@"WlhyPrivateTrainViewController"],/*健身私教*/
              [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"xxtx0.png"] badgeNumber:[[badgeNumbers objectAtIndex:2] intValue] tager:@"WlhyMessageReminderViewController"],/*消息提醒*/
              [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"grzx0.png"] badgeNumber:0 tager:@"WlhyUserCenterViewController"],/*个人中心*/
              [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"hdsc0.png"] badgeNumber:0 tager:@"WlhyHoldDoStoreViewController"],/*慧动商城*/
              [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"jsdt0.png"] badgeNumber:0 tager:@"WlhyFitnessHallViewController"]/*健身大厅*/
              ],
              
              @[
              [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"jhfw0.png"] badgeNumber:0 tager:@"WlhyRechargeViewController"],/*激活服务*/
              [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"qcxx0.png"] badgeNumber:0 tager:@"WlhyEquipInfoViewController"],/*器材信息*/
              [BadgedLauncherViewObject objectWithTitle:@"" image:[UIImage imageNamed:@"gyhd0.png"] badgeNumber:0 tager:@"WlhyAboutHoldDoViewController"],/*关于慧动*/
              ]
              ]
                                                        delegate:self];
    self.launcherView.dataSource=_model;
    [self.launcherView reloadData];
}

@end
