//
//  SettingsView.h
//  iCombine Watch
//
//  Created by Duyet Le on 6/10/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingsView : NSViewController
{
    NSString *strLocation;
    NSString *strLocationMannualFileName;
    NSString *strServer;
//    NSString *strTimeoutProccessTest;
//    NSString *strTimeoutProccessErase;
    NSString *strElapsedTime;
    NSString *strErasure_method;
    NSString *strEmailAddress;
    NSString *strTimeout;
    NSString *Recurrences;
    
    NSMutableDictionary *dicInfoSave;
    int leftTitleGroup;
    
    NSEvent *mouseEventMonitor;
}
- (id)initWithFrame:(CGRect)frame;
- (NSWindow *)showWindow;
@end

NS_ASSUME_NONNULL_END
