//
//  UIViewController+WlhyNetwork.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-11.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "UIViewController+WlhyNetwork.h"

#import "AFHTTPClient.h"
#import "AHReach.h"
#import "AFNetworkActivityIndicatorManager.h"

#import "MBProgressHUD.h"
#import "WlhyNetworkCommunication.h"


#import <objc/message.h>

@implementation UIViewController (WlhyNetwork)

-(void)showText:(NSString *)text{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	
	// Configure for text only and offset down
	hud.mode = MBProgressHUDModeText;
	hud.labelText = text;
	hud.margin = 10.f;
	hud.yOffset = 0.f;
	hud.removeFromSuperViewOnHide = YES;
	
	[hud hide:YES afterDelay:1.5];
}

-(void)showWithLabel:(NSString *)text
{
    MBProgressHUD * hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hub.labelText=text;
}

-(void)removeHub:(BOOL)allHub
{
    [self performSelector:@selector(delayRemoveHub:) withObject:[NSNumber numberWithBool:allHub] afterDelay:1.0f];
}

-(void)delayRemoveHub:(NSNumber*)allHub
{
    if([allHub boolValue]){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }else{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

 

-(AFJSONRequestOperation*)sendRequest:(NSDictionary *)params action:(NSString *)anAction
{

//    [self showWithLabel:@"正在检查网络..."];
//    if(![[AHReach reachForHost:wlServer] isReachable]){
//        Alert(@"无法连接到服务器，请确认是否打开网络连接.");
//        [self removeHub:YES];
//        return nil;
//    }
//    [self removeHub:YES];
    if(!params || IsEmptyString(anAction)){
        return nil;
    }
    
    NSLog(@"sendRequest action :: -----------%@",anAction);
    NSLog(@"sendRequest params :: -----------%@",params);
    
    AFHTTPClient* client  =[AFHTTPClient clientWithBaseURL:[NSURL URLWithString: wlServer]];
    NSLog(@"111-%d",client.networkReachabilityStatus);
     [self showWithLabel:@"正在查询，请稍后"];
    client.parameterEncoding=AFJSONParameterEncoding;
    NSURLRequest * request = [client requestWithMethod:@"POST" path:anAction parameters:params];
    
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self delayRemoveHub:@YES];
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        
        NSLog(@"sendRequest action :: -----------%@",anAction);
        [self processRequest:anAction info:JSON error:nil];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        [self delayRemoveHub:@YES];
        [[AFNetworkActivityIndicatorManager sharedManager]decrementActivityCount];
        
        NSLog(@"action after Request :: -----------%@",anAction);
        [self processRequest:anAction info:JSON error:error];
    }];
    [operation start];
    [AFNetworkActivityIndicatorManager sharedManager].enabled=YES;
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    return operation;
}


-(AFJSONRequestOperation*)sendRequest:(NSDictionary *)params action:(NSString *)anAction baseUrlString:(NSString*)baseUrlString
{
    if(!params || IsEmptyString(anAction)){
        return nil;
    }
    
    NSLog(@"sendRequest action :: -----------%@",anAction);
    NSLog(@"sendRequest params :: -----------%@",params);
    
    AFHTTPClient* client  =[AFHTTPClient clientWithBaseURL:[NSURL URLWithString: baseUrlString]];
    NSLog(@"111-%d",client.networkReachabilityStatus);
    [self showWithLabel:@"正在查询，请稍后"];
    client.parameterEncoding=AFJSONParameterEncoding;
    NSURLRequest * request = [client requestWithMethod:@"POST" path:anAction parameters:params];
    
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self delayRemoveHub:@YES];
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        
        NSLog(@"sendRequest action :: -----------%@",anAction);
        [self processRequest:anAction info:JSON error:nil];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self delayRemoveHub:@YES];
        [[AFNetworkActivityIndicatorManager sharedManager]decrementActivityCount];
        
        NSLog(@"action after Request :: -----------%@",anAction);
        [self processRequest:anAction info:JSON error:error];
    }];
    [operation start];
    [AFNetworkActivityIndicatorManager sharedManager].enabled=YES;
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    return operation;
}

- (void)processRequest:(NSString*) action info:(NSDictionary*)info error:(NSError*)error
{
    
}

- (void)addSubViewController:(UIViewController*) viewController toView:(UIView *)view{
   
    [self addChildViewController:viewController];
    viewController.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    [view addSubview:viewController.view];
    
    [viewController didMoveToParentViewController:self];
    
}

@end
