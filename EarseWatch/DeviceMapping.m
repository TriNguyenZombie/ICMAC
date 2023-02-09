//
//  DeviceMapping.m
//  EarseMac
//
//  Created by TriNguyen on 5/16/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import "DeviceMapping.h"


@implementation DeviceMapping
- (NSString *)description {
    return [NSString stringWithFormat:@"noID: %@ icapture_pn: %@ product_name: %@  capacity: %@  color: %@  carrier: %@  country: %@ region_code: %@ external_model: %@,",
            self.noID,
            self.icapture_pn,
            self.product_name,
            self.capacity,
            self.color,
            self.carrier,
            self.country,
            self.region_code,
            self.external_model];

}

+ (NSString *)primaryKey {
    return @"noID";
}

@end
