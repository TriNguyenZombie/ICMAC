//
//  DatabaseCom.h
//  EarseMac
//
//  Created by TriNguyen on 5/6/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface DatabaseCom : NSObject {
}
@property RLMRealm *realm;

@end

NS_ASSUME_NONNULL_END
