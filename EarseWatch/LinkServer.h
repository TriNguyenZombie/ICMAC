//
//  LinkServer.h
//  EarseMac
//
//  Created by TriNguyen on 5/17/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface LinkServer : RLMObject

@property NSString    *ID;
@property NSString    *linkServer;

@end

NS_ASSUME_NONNULL_END
