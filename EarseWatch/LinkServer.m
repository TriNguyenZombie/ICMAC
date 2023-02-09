//
//  LinkServer.m
//  EarseMac
//
//  Created by TriNguyen on 5/17/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import "LinkServer.h"

@implementation LinkServer

- (NSString *)description {
    return [NSString stringWithFormat:@"ID: %@ linkServer: %@",
            self.ID,
            self.linkServer];

}

+ (NSString *) primaryKey {
    return @"ID";
}

@end
