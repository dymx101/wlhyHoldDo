//
//  WlhyNetworkCommunication.m
//  wlhybdc
//
//  Created by linglong meng on 12-10-11.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import "WlhyNetworkCommunication.h"
#import "AFJSONRequestOperation.h"

//@"http://42.121.106.113:1111";
//@"http://192.168.1.103:8080";
//@"http://218.245.5.79:80"
//@"http://192.168.1.80:8080" 战

NSString* const wlServer = @"http://192.168.1.80:8080";
NSString* const brmServer = @"http://218.245.5.78:80";

NSString* const wlvCode= @"/bdcServer/services/register/registerGetVcodeRequest";
NSString* const wlRegist= @"/bdcServer/services/register/registerSubmitInfoRequest";
NSString* const wlLogin = @"/bdcServer/services/login/loginRequest";
NSString* const wlLogoutRequest = @"/bdcServer/services/login/logoutRequest";
NSString* const wlGetPrescriptionOverviewRequest= @"/bdcServer/services/prescription/getPrescriptionOverviewRequest";
NSString* const wlGetMemberPwdRequest= @"/bdcServer/services/member/getMemberPwdRequest";
NSString* const wlGetPrescriptionContentsRequest= @"/bdcServer/services/prescription/getPrescriptionContentsRequest";
NSString* const wlInsertPrescriptionResult = @"/bdcServer/services/prescription/insertPrescriptionResult";
NSString* const wlUploadMemberAvatar = @"/bdcServer/services/member/uploadMemberAvatar";

NSString* const wlRechargeMember= @"/bdcServer/services/memberAccount/rechargeMember";
NSString* const wlGetMemberInfoRequest= @"/bdcServer/services/member/getMemberInfoRequest";
NSString* const wlGetMemberFitnessCount = @"/bdcServer/services/memberCount/getMemberFitnessCount";
NSString* const wlGetAccountInfoRequest = @"/bdcServer/services/memberAccount/getMemberAccountArray";
NSString* const wlUpdateManifestoRequest = @"/bdcServer/services/member/updateMemberManifesto";
NSString* const wlGetFrontDeskInfo= @"/bdcServer/services/common/getFrontDeskInfo";
NSString* const wlInsertAdviceInfo= @"/bdcServer/services/member/insertAdviceInfo";
NSString* const wlModifyMemberPwdRequest= @"/bdcServer/services/member/modifyMemberPwdRequest";
NSString* const wlModifyPhoneRequest= @"/bdcServer/services/member/modifyMemberPhoneRequest";
NSString* const wlModifyMemberInfoRequest = @"/bdcServer/services/member/modifyMemberInfoRequest";
NSString* const wlModifyFitnessGoalRequest = @"/bdcServer/services/member/memberUpdateJsmd";
NSString* const wlGetFitnessClassRequest= @"/bdcServer/services/fitnessHall/getFitnessClasses";
NSString* const wlGetHallMemberRequest = @"/bdcServer/services/fitnessHall/getFitnessArmory";
NSString* const wlGetHallMemberListRequest = @"/bdcServer/services/fitnessHall/getFitnessArmoryList";
NSString* const wlGetNearMemberRequest = @"/bdcServer/services/fitnessHall/getMemberFitnessInfo";
NSString* const wlGetMessageInfoRequest = @"/bdcServer/services/member/getMemberMessageInfo";
NSString* const wlGetEqipInfoRequest = @"/bdcServer/services/common/getEqipRequest";
NSString* const wlUserRechargeRequest = @"/bdcServer/services/memberAccount/rechargeMember";
NSString* const wlGetTrainListRequest = @"/bdcServer/services/common/getServicePersonList";
NSString* const wlBindTrainRequest = @"/bdcServer/services/common/memberBandPersonaltrainer";
NSString* const wlChangeTrainRequest = @"/bdcServer/services/member/insertMemberTrainerChg";
NSString* const wlGetTrainInfoRequest = @"/bdcServer/services/common/getServicePersonInfo";
NSString* const wlCommentServerPersonRequest = @"/bdcServer/services/member/submitServiceSatisfaction";
NSString* const wlGetCertainTrainInfoRequest = @"/bdcServer/services/common/getServicePersonInfoByPersonaltrainerId";
NSString* const wlGetNoCommentPrescriptionRequest = @"/bdcServer/services/comment/getNoCommentPrescription";    //未评价的处方
NSString* const wlGetPrescContentsRequest = @"/bdcServer/services/prescription/getPrescriptionContentsRequest";
NSString* const wlGetWeekPrescRequest = @"/bdcServer/services/prescription/getPrescriptionContentsOfWeek";
NSString* const wlUpdateExerciseFeelings = @"/bdcServer/services/member/updateExerciseFeelings";

NSString* const wlBuyEquipRequest = @"/bdcServer/services/other/equipOrder";
NSString* const wlEvaluateEquipRequest = @"/bdcServer/services/euip/equipAppraise";
NSString* const wlRepairsEquipRequest = @"/bdcServer/services/euip/equipRepair_sub";
NSString* const wlGetEquipEvaluateListRequest = @"/bdcServer/services/euip/getEquipAppraiseList";
NSString* const wlGetOwnedEquipListRequest = @"/bdcServer/services/member/memberMyBarcodes";
NSString* const wlGetAuthedEquipListRequest = @"/bdcServer/services/member/memberMyCanuseBarcodes";
NSString* const wlGetUsedEquipListRequest = @"/bdcServer/services/member/memberMyUsedBarcodes";
NSString* const wlGrantEquipToOtherRequest = @"/bdcServer/services/member/memberGrantToOther";

NSString* const wlGetHeightHistoryRequest = @"/bdcServer/services/member/getHeightHis";
NSString* const wlGetWeightHistoryRequest = @"/bdcServer/services/member/getWeightHis";
NSString* const wlGetWaistHistoryRequest = @"/bdcServer/services/member/getWaistHis";

NSString* const wlBindEquipRequest = @"/bdcServer/services/member/scanBandBarcode";
NSString* const brmAuthServletApi = @"/brm/AuthServletApi";


NSString* const bdrCmdSendApi = @"/BdrServer/CmdSendApi";

NSString* const iFlyAPPID = @"51f8a30b";


static WlhyNetworkCommunication* _gNetwork=nil;


@interface WlhyNetworkCommunication()
{
    NSDictionary * _actionSelMap;
}


@end

@implementation WlhyNetworkCommunication


-(id)init
{
    self = [super init];
    if(self){
        [self initActionSelMap];
    }
    return self;
}

-(void)initActionSelMap
{
    if(!_actionSelMap){
        _actionSelMap = @{
        wlvCode : @"processVCode:",
        wlRegist: @"processRegistAction:",
        wlLogin: @"processLoginAction:"
        };
    }
}


+(id)defaultNetWork
{
    if(!_gNetwork){
        _gNetwork=[[self alloc] init];
        
    }
    return _gNetwork;
}


-(NSString*)processSelect:(NSString *)action
{
    return [_actionSelMap objectForKey:action];
}

@end
