//
//  UserLogin.h
//  iCombine Watch
//
//  Created by TriNguyen on 5/26/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
NS_ASSUME_NONNULL_BEGIN

@interface UserLogin : RLMObject
//{"cloudid":"2664","username":"tuyennguyen","password":"x5fWO7rVPnlavnlbR7vnPg==","isdelete":null,"privilege":"Supervisor"}
@property NSString    *cloudid;
@property NSString    *username;
@property NSString    *password;
@property NSString    *isdelete;
@property NSString    *privilege;

@end

NS_ASSUME_NONNULL_END
