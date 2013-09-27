//
//  WlhyPickerViewController.h
//  wlhybdc
//
//  Created by linglong meng on 12-10-17.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WlhyPickerViewController: UIViewController

@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property(nonatomic,strong)NSMutableArray* dataArrays;
@property(nonatomic,strong)NSMutableArray* selectedData;
@property(nonatomic,strong)void (^didOkAction)(void);

- (IBAction)okAction:(id)sender;

@end
