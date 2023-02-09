//
//  DeviceInfo.m
//  EarseMac
//
//  Created by TriNguyen on 5/4/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import "DeviceInfo.h"

@implementation DeviceInfo
- (NSString *)description {
    return [NSString stringWithFormat:@"modelNumber: %@ serialNumber: %@ productName: %@  modelName: %@  productType: %@  productVersion: %@  createTime: %@ cellID: %@ ID: %@ regionInfo: %@ resultOfErasure: %d",
            self.modelNumber,
            self.serialNumber,
            self.productName,
            self.modelName,
            self.productType,
            self.productVersion,
            self.createTime,
            self.cellID,
            self.ID,
            self.regionInfo,
            self.resultOfErasure];

}

+ (NSString *)primaryKey {
    return @"ID";
}

@end
