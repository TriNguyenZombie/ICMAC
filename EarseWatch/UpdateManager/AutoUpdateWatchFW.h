//
//  AutomaticUpdateFirmware.h
//  iCombine Watch
//
//  Created by Duyet Le on 9/14/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface AutoUpdateWatchFW : NSViewController
{
    NSTextField *titleWindow;
    
    int proccessWidthMax;
  
    int numRowNew;
    NSMutableDictionary *dicMacFWNew;
    NSMutableDictionary *dicMacFWCurent;
    NSMutableArray *arrayUpdate;
    BOOL enableButtonUpdate;
    NSArray *arrkeyNew;
    NSThread *threadUpdate;
    
    NSMutableArray *listFileDownloaded;
    NSTextField *testText;
    
    NSTextField *proccessbarRun;
    NSTextField *proccessbarText;
    NSTextField *lbUpdating;
    NSTextField *ProccessbarBG;
}
-(void) runUpdate;
- (NSWindow *)showWindow;
- (instancetype)init;
@end

NS_ASSUME_NONNULL_END
