//
//  AboutViewController.h
//  iCombine Watch
//
//  Created by TriNguyen on 5/31/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
NS_ASSUME_NONNULL_BEGIN

@interface AboutViewController : NSViewController <NSTextFieldDelegate,NSTextFieldDelegate> {
    int height;
    int width;
    int xCoordinate;
    int yCoordinate;
    NSMutableDictionary *dicInfor;
}
- (id)initWithFrame:(CGRect)frameRect data:(NSMutableDictionary*)dic hwVersion:(NSString*)hwVersion fwVersion:(NSString*)fwVersion customerName:(NSString*)customerName;
- (NSWindow *)showWindow;
@end

NS_ASSUME_NONNULL_END
