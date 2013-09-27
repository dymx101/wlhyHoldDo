//
//  CommentTrainView.m
//  wlhybdc
//
//  Created by Hello on 13-9-22.
//  Copyright (c) 2013年 linglong meng. All rights reserved.
//

#import "CommentTrainView.h"


@interface CommentTrainView () <UITableViewDataSource, UITextViewDelegate, UITableViewDelegate, UIGestureRecognizerDelegate>
{
    NSInteger selectedRow;
    float spaceToViewBottom;
}

@property (strong, nonatomic) IBOutlet UIView *commentBGView;
@property (strong, nonatomic) IBOutlet UITableView *indexTableView;
@property (strong, nonatomic) IBOutlet UITextView *contentTextView;


- (IBAction)OKButtonTapped:(id)sender;
- (IBAction)cancelInput:(id)sender;

@end



@implementation CommentTrainView

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"CommentTrainView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        _commentBGView.layer.cornerRadius = 4;
        _commentBGView.layer.borderWidth = 1;
        _commentBGView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12].CGColor;
        
        _indexTableView.layer.cornerRadius = 4;
        _indexTableView.layer.borderWidth = 1;
        _indexTableView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12].CGColor;
        
        _contentTextView.layer.cornerRadius = 4;
        _contentTextView.layer.borderWidth = 1;
        _contentTextView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12].CGColor;

        spaceToViewBottom = self.frame.size.height - (_commentBGView.frame.origin.y + _commentBGView.frame.size.height) + 50;
        
        selectedRow = 0;
        
    }
    return self;
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordHiden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
}



#pragma mark - tableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 34;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSString *text = @"";
    
    switch (row) {
        case 0:
            text = @"非常满意";
            break;
        
        case 1:
            text = @"比较满意";
            break;
            
        case 2:
            text = @"一般";
            break;
            
        case 3:
            text = @"不太满意";
            break;
            
        default:
            break;
    }
    
    
    static NSString *CellIdentifier = @"CommentTrainCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (row == selectedRow) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.text = text;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    
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


- (IBAction)OKButtonTapped:(id)sender
{
    [_commentBGView endEditing:NO];
    [_delegate finishCommentList:selectedRow content:_contentTextView.text];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (IBAction)cancelInput:(id)sender
{
    [_contentTextView resignFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [_contentTextView resignFirstResponder];
}

#pragma mark - gestureRecognizer Delegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        //如果当前是tableView
        //做自己想做的事
        return NO;
    }
    return YES;
}

#pragma mark - keybord show

static BOOL isKeyBordShow = NO;
static CGFloat keybordHight = 0.0f;

-(void)keybordShow:(NSNotification*)notif
{
    if(!isKeyBordShow){
        CGRect keybordRect;
        [[notif.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keybordRect];
        keybordHight = CGRectGetHeight(keybordRect);
        CGRect rect = _commentBGView.frame;
        rect.origin.y -= keybordHight - spaceToViewBottom;
        [UIView animateWithDuration:0.25 animations:^{
            _commentBGView.frame = rect;
        } completion:nil];
        isKeyBordShow=YES;
    }
    
}
-(void)keybordHiden:(NSNotification*)notif
{
    if(isKeyBordShow){
        CGRect rect = _commentBGView.frame;
        rect.origin.y += keybordHight - spaceToViewBottom;
        [UIView animateWithDuration:0.25 animations:^{
            _commentBGView.frame = rect;
        } completion:nil];
        isKeyBordShow=NO;
    }
}
-(void)keyboardChangeFrame:(NSNotification*)notif
{
    if(isKeyBordShow){
        CGRect keybordRect;
        [[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keybordRect];
        //NSLog(@"%@",notif);
        CGFloat keybordnewHight = CGRectGetHeight(keybordRect);
        if(keybordnewHight != keybordHight){
            
            CGRect rect = _commentBGView.frame;
            rect.origin.y += keybordHight-keybordnewHight;
            keybordHight = keybordnewHight;
            [UIView animateWithDuration:0.25 animations:^{
                _commentBGView.frame = rect;
            } completion:nil];
        }
    }
}


@end
