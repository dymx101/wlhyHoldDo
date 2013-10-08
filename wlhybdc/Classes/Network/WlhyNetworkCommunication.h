//
//  WlhyNetworkCommunication.h
//  wlhybdc
//
//  Created by linglong meng on 12-10-11.
//  Copyright (c) 2012年 linglong meng. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const wlvCode;
extern NSString* const wlServer;
extern NSString* const brmServer;
extern NSString* const wlRegist;
extern NSString* const wlLogin;
extern NSString* const wlLogoutRequest;
extern NSString* const wlGetPrescriptionOverviewRequest;
extern NSString* const wlGetMemberPwdRequest;
extern NSString* const wlGetPrescriptionContentsRequest;
extern NSString* const wlUploadMemberAvatar;
extern NSString* const wlUpdateManifestoRequest;
extern NSString* const wlInsertPrescriptionResult;
extern NSString* const wlRechargeMember;
extern NSString* const wlGetMemberInfoRequest;
extern NSString* const wlGetFrontDeskInfo;
extern NSString* const wlInsertAdviceInfo;
extern NSString* const wlModifyPhoneRequest;
extern NSString* const wlModifyMemberPwdRequest;
extern NSString* const wlModifyMemberInfoRequest;
extern NSString* const wlModifyFitnessGoalRequest;
extern NSString* const wlGetFitnessClassRequest;
extern NSString* const wlGetAccountInfoRequest;
extern NSString* const wlGetHallMemberRequest;
extern NSString* const wlGetHallMemberListRequest;
extern NSString* const wlGetNearMemberRequest;
extern NSString* const wlGetMessageInfoRequest;
extern NSString* const wlGetEqipInfoRequest;
extern NSString* const wlGetTrainListRequest;
extern NSString* const wlGetAllTrainRequest;
extern NSString* const wlChangeTrainRequest;
extern NSString* const wlBindTrainRequest;
extern NSString* const wlGetTrainInfoRequest;
extern NSString* const wlCommentServerPersonRequest;
extern NSString* const wlGetCertainTrainInfoRequest;
extern NSString* const wlUserRechargeRequest;
extern NSString* const wlGetNoCommentPrescriptionRequest;
extern NSString* const wlGetPrescContentsRequest;
extern NSString* const wlGetWeekPrescRequest;
extern NSString* const wlUpdateExerciseFeelings;

extern NSString* const wlBuyEquipRequest;
extern NSString* const wlEvaluateEquipRequest;
extern NSString* const wlRepairsEquipRequest;
extern NSString* const wlGetEquipEvaluateListRequest;
extern NSString* const wlGetUsedEquipListRequest;
extern NSString* const wlGetAuthedEquipListRequest;
extern NSString* const wlGrantEquipToOtherRequest;
extern NSString* const wlGetOwnedEquipListRequest;

extern NSString* const wlGetHeightHistoryRequest;
extern NSString* const wlGetWeightHistoryRequest;
extern NSString* const wlGetWaistHistoryRequest;

extern NSString* const brmAuthServletApi;
extern NSString* const wlBindEquipRequest;

extern NSString* const bdrCmdSendApi;

extern NSString* const iFlyAPPID;

@interface WlhyNetworkCommunication : NSObject


+ (id)defaultNetWork;

- (NSString*)processSelect:(NSString*)action;

@end
