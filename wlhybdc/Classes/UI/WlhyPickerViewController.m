//
//  WlhyPickerViewController.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-17.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyPickerViewController.h"

@interface WlhyPickerViewController()<UIPickerViewDataSource,UIPickerViewDelegate>

@end

@implementation WlhyPickerViewController
@synthesize dataArrays=_dataArrays;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if((self=[super initWithCoder:aDecoder])){
        self.dataArrays=[NSMutableArray arrayWithArray:@[@[@"男",@"女"],@[@11,@22],@[@33,@44],@[]]];//@[@"男",@"女"],@[]];
        self.selectedData=[NSMutableArray arrayWithCapacity:self.dataArrays.count];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.pickerView.dataSource=self;
    self.pickerView.delegate=self;
    self.view.frame=self.pickerView.frame;
}


-(void)setdataArrays:(NSMutableArray *)dataArrays
{
    if(_dataArrays != dataArrays){
        if(!_dataArrays){
            _dataArrays=[NSMutableArray arrayWithCapacity:[dataArrays count]];
        }else{
            [_dataArrays removeAllObjects];
        }
        for (NSArray* v in dataArrays) {
            if(v.count){
                [_dataArrays addObject:v];
            }
        }
        NSLog(@"%d,%d",_dataArrays.count,dataArrays.count);
        
        [self.selectedData removeAllObjects];
        
        for(int i = 0; i< _dataArrays.count;i++){
            if([[_dataArrays objectAtIndex:i] count]){
                [self.selectedData addObject:[_dataArrays objectAtIndex:0]];
            }
        }
        
        [self.pickerView reloadAllComponents];
    }
}

#pragma mark -- UIPickerViewdataArrays


-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return [self.dataArrays count];
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(self.dataArrays.count==0){
        return 0;
    }else{
        return [[self.dataArrays objectAtIndex:component] count];
    }
}


#pragma mark --UIPickerViewDelegate

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    id v = [[self.dataArrays objectAtIndex:component] objectAtIndex:row];
    if(![v isKindOfClass:[NSString class]]){
        v= [NSString stringWithFormat:@"%@",v];
    }
    return v;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSString* s = [[self.dataArrays objectAtIndex:component] objectAtIndex:row];
    
    while(self.selectedData.count < component+1){
        
        [self.selectedData addObject:[[self.dataArrays objectAtIndex:self.selectedData.count]objectAtIndex:[pickerView selectedRowInComponent:self.selectedData.count]]] ;
    }
    [self.selectedData replaceObjectAtIndex:component withObject:s];
}
- (void)viewDidUnload {
    [self setPickerView:nil];
    [super viewDidUnload];
}
- (IBAction)okAction:(id)sender {
    if(self.didOkAction){
        self.didOkAction();
    }
}
@end
