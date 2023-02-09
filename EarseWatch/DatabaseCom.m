//
//  DatabaseCom.m
//  EarseMac
//
//  Created by TriNguyen on 5/6/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import "DatabaseCom.h"

@implementation DatabaseCom
- (id)init
{
    self  = [super init];
    _realm = [RLMRealm defaultRealm];
    return self;
}




@end
