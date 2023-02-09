//
//  UpdateViewController.h
//  iCombineMac
//
//  Created by TriNguyen on 30/08/2022.
//  Copyright © 2022 Greystone. All rights reserved.
//

#ifndef UpdateViewController_h
#define UpdateViewController_h
#import "AppDelegate.h"
#import <Cocoa/Cocoa.h>
#import "FTPKit/FTPKit.h"

@interface UpdateViewController : NSViewController <NSTextFieldDelegate,NSTextFieldDelegate> {
    int height;
    int width;
    int xCoordinate;
    int yCoordinate;
    
    bool isDownloadedFW;
    bool isDownloadedSW;
    bool isDownloadingFW;
    bool isDownloadingSW;
    
    NSButton *checkBoxSW;
    NSButton *checkBoxFW;
    NSButton *checkBoxFW1;
    NSButton *checkBoxFW2;
    NSButton *checkBox;
    
    NSTextField *softwareNewVersionNumber;
    NSTextField *softwareVersionNumber;
    
    FTPClient *ftp;
    NSString *downloadSQLFolderPath;
    NSString *fileContents;
    NSArray *lines;
    NSString *linkDownloadFWTemp;
    NSString *linkDownloadFW;
    NSURL *URL_DownloadFW;
    NSURLRequest *requestDownloadFW;
    NSURLSessionDownloadTask *downloadTaskFW;
    NSString *downloadStatus;
    NSURL *URL_DownloadSW;
    NSURL *URL_DownloadIPSW;
    NSURLRequest *requestDownloadSW;
    NSURLRequest *requestDownloadIPSW;
    NSString *tokenID;
    NSString *macProductName;
    NSString *ipsw_name;
    NSString *ipsw_checksum;
    NSString *ipsw_version;
    
    NSString *currentVersion;
    NSString *currentFileName;
    NSString *currentChecksum;
    
    bool isAllowDownload;
    NSButton *btUpdate;

    NSURLSessionDownloadTask *downloadTaskSW;
    NSURLSessionDownloadTask *downloadTaskIPSW;
    
    AppDelegate *delegate;
    
    NSTimer *timerUpdateState;
    NSTimer *timerUpdateUI;
    NSMutableDictionary *dicInfor;
}

@property(nonatomic, strong)NSMutableArray *results;
@property(nonatomic, strong)NSMutableString *parsedString;
@property(nonatomic, strong)NSXMLParser *xmlParser;

- (NSWindow *)showWindow;
- (void)getTokenID;
- (void)updateUI;
- (NSString *)runCommand:(NSString *)commandToRun;
- (id)initWithFrame:(CGRect)frameRect;
- (void)downloadFirmware;
- (bool)getConfig:(NSString*)pathFileXML;
@end

#endif /* UpdateViewController_h */
