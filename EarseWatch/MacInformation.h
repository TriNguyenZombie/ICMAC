//
//  MacInformation.h
//  iCombineMac
//
//  Created by TriNguyen on 8/31/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface MacInformation : RLMObject

/*
 {
     ECID = 0xA582E20F1A526;
     UDID = 49f7b7ed304bca488d0b1732f1e1622ba39d9d57;
     deviceType = "iPhone9,3";
     locationID = 336736256;
     name = "iPhone9,3";
     "send_start" = 1;
     serial = 49f7b7ed304bca488d0b1732f1e1622ba39d9d57;
     "time_start" = "2022-08-31 10:46:58";
 }
 */
// Add properties here to define the model
@property NSString    *ID;
@property NSString    *cellID;
@property NSString    *mECID;
@property NSString    *mUDID;
@property NSString    *productName;
@property NSString    *mSerialNumber;
@property NSString    *timeStart;
@property NSString    *timeEnd;
@property NSString    *resulfOfErasureText;
@property int         resulfOfErasureValue;
@property int         needToSendGCS;

@property NSString    *locationText;
@property NSString    *batchNoText;
@property NSString    *lineNoText;
@property NSString    *userText;
@property NSString    *workAreaText;
@property NSString    *transaction_ID;



@end

RLM_ARRAY_TYPE(MacInformation)

