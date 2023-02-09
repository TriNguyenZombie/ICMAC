//
//  DeviceMapping.h
//  EarseMac
//
//  Created by TriNguyen on 5/16/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN
@interface DeviceMapping : RLMObject
@property NSString    *ID;
@property NSString    *noID;
@property NSString    *icapture_pn;
@property NSString    *product_name;
@property NSString    *capacity;
@property NSString    *color;
@property NSString    *carrier;
@property NSString    *country;
@property NSString    *region_code;
@property NSString    *external_model;


@end

NS_ASSUME_NONNULL_END
RLM_ARRAY_TYPE(DeviceMapping) // define RLMArray<Person>
