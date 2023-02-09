//
//  MacInformation.m
//  iCombineMac
//
//  Created by TriNguyen on 8/31/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import "MacInformation.h"

/*
 @property NSString    *ID;
 @property NSString    *cellID;
 @property NSString    *mECID;
 @property NSString    *mUDID;
 @property NSString    *productName;
 @property NSString    *mSerialNumber;
 @property NSString    *timeStart;
 @property NSString    *timeEnd;
 */
@implementation MacInformation
- (NSString *)description {
    return [NSString stringWithFormat:@"ID: %@ cellID: %@ mECID: %@  mUDID: %@  productName: %@  mSerialNumber: %@  timeStart: %@ timeEnd: %@ resulfOfErasure: %@  resulfOfErasureValue: %d needToSend: %d",
            self.ID,
            self.cellID,
            self.mECID,
            self.mUDID,
            self.productName,
            self.mSerialNumber,
            self.timeStart,
            self.timeEnd,
            self.resulfOfErasureText,
            self.resulfOfErasureValue,
            self.needToSendGCS];

}

+ (NSString *)primaryKey {
    return @"ID";
}

@end
