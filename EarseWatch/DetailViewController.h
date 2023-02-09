//
//  DeviceInfomation.h
//  EarseMac
//
//  Created by Duyet Le on 1/13/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import "LoginViewcontroller.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailViewController : LoginViewcontroller
{
    NSMutableDictionary *dicInfor;
}
- (id)initWithFrame:(CGRect)frameRect data:(NSMutableDictionary*)dic;
- (NSWindow *)showWindow;
@end

NS_ASSUME_NONNULL_END
