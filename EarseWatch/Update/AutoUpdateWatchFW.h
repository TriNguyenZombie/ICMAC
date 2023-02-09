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
    NSMutableArray *arrayListUpdate;
    BOOL enableButtonUpdate;
    NSArray *arrkeyNew;
    NSThread *threadUpdate;
    
    NSButton *btUpdate;
    NSButton *cbtem;
    
    NSButton *btnUpdate;
    NSButton *btnClose;
    NSButton *cbSelectAll;
    
    NSColor *colorBanner;
    
    NSMutableArray *listFileDownloaded;
    
    NSTextField *testText;
    NSTextField *proccessbarRun;
    NSTextField *proccessbarText;
    NSTextField *lbUpdating;
    NSTextField *ProccessbarBG;
    NSTextField *lbNewVersion;
    
    NSScrollView *scrollContainer;
    NSView *viewNewVersion;
    
    NSMutableDictionary *dicItem;
    NSMutableDictionary *dicItemNewVersion;
    NSMutableDictionary *dicSupport;
    NSMutableDictionary *dicSupportChecksum;
    
    NSString *key;
    NSString *tokenID;
    
    NSTimer *timerUpdateUI;
}
- (void)runUpdate;
- (void)updateState;
- (NSWindow *)showWindow;
- (NSString *)runCommand:(NSString *)commandToRun;
- (instancetype)init;
- (void)getTokenAndDownloadChecksumFile;
- (void)readFileChecksum;
- (void)checkNewVersion;
@end

NS_ASSUME_NONNULL_END
