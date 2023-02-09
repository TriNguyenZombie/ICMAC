//
//  UpdateViewController.m
//  iCombineMac
//
//  Created by TriNguyen on 30/08/2022.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import <CommonCrypto/CommonCrypto.h>
#import <SSZipArchive.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <AFNetworking.h>
#import <curl/curl.h>
#include "define_gds.h"
#include "DeviceMapping.h"
#include "LinkServer.h"
#include "UserLogin.h"
#import "DatabaseCom.h"
#import "DeviceInfo.h"
#import "AFNetworking.h"
#import "UpdateViewController.h"
#import "UITextFieldCell.h"
#include <sys/sysctl.h>

#define IPSW_LINK_DOWNLOAD_CDN @""

@interface UpdateViewController()

@end

@implementation UpdateViewController
- (id)initWithFrame: (CGRect)frameRect
{
    self = [super init];
    self->tokenID = @"";
    delegate.isDownload = false;
    NSLog(@"[UpdateViewController] info: %@", dicInfor);
    NSColor *colorCFBG = [NSColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0];
    self.view = [[NSView alloc] init];
    self.view.frame = frameRect;
    self.view.layer.borderColor = NSColor.redColor.CGColor;
    self.view.layer.borderWidth = 0;
    self.view.layer.backgroundColor = colorCFBG.CGColor;
    int width = frameRect.size.width;
    int height = frameRect.size.height;
    self.view.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    
    delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    int widthHeader = width;
    int heightHeader = frameRect.size.height/15;
    int xCoordinateHeader = 0;
    int yCoordinateHeader = height - heightHeader;
    
    NSView *viewHeader = [[NSView alloc] initWithFrame:NSMakeRect(xCoordinateHeader, yCoordinateHeader, widthHeader, heightHeader)];
    viewHeader.wantsLayer = YES;
    viewHeader.layer.backgroundColor = delegate.colorBanner.CGColor;
    viewHeader.layer.borderColor = NSColor.redColor.CGColor;
    viewHeader.layer.borderWidth = 0;
    
    [self.view addSubview:viewHeader];
    
    NSTextField *txtHeader = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, widthHeader, heightHeader)];
    txtHeader.cell = [[NSTextFieldCell alloc] init];
    [viewHeader addSubview:txtHeader];
    
    txtHeader.alignment = NSTextAlignmentLeft;
    txtHeader.cell = [[NSTextFieldCell alloc] init];
    txtHeader.font = [NSFont fontWithName:@"Roboto-Regular" size:18];
    txtHeader.backgroundColor = [NSColor clearColor];
    txtHeader.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtHeader.textColor = [NSColor whiteColor];
    txtHeader.stringValue = @"   MacOS firmware update";
    txtHeader.layer.backgroundColor = delegate.colorBanner.CGColor;
    
    NSButton *btCloseHeader = [[NSButton alloc] initWithFrame:NSMakeRect(widthHeader - (heightHeader) - (heightHeader/10), 0, heightHeader, heightHeader)];
    btCloseHeader.title = @"";
    btCloseHeader.image = [NSImage imageNamed:@"CloseWhite.png"];
    [[btCloseHeader cell] setBackgroundColor:delegate.colorBanner];
    btCloseHeader.wantsLayer = YES;
    [btCloseHeader setBordered:NO];
    [btCloseHeader setToolTip:@"Close"];
    [btCloseHeader setTarget:self];
    [btCloseHeader setAction:@selector(btCloseClick:)];
    [viewHeader addSubview:btCloseHeader];
    
    NSLog(@"Header height: %f", viewHeader.frame.size.height);
    NSLog(@"Header width: %f", viewHeader.frame.size.width);
    
    NSView *viewCenter = [[NSView alloc] initWithFrame:NSMakeRect(xCoordinateHeader, 0, width, height - heightHeader)];
    viewCenter.wantsLayer = TRUE;
    viewCenter.layer.borderColor = NSColor.redColor.CGColor;
    viewCenter.layer.borderWidth = 0;
    [self.view addSubview:viewCenter];
    
    NSView *viewFooter = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, width, heightHeader*2)];
    viewFooter.wantsLayer = TRUE;
    viewFooter.layer.borderColor = NSColor.redColor.CGColor;
    viewFooter.layer.borderWidth = 0;
    [viewCenter addSubview:viewFooter];
    
    btUpdate = [[NSButton alloc] initWithFrame:NSMakeRect(width/4, 0, width/4 - 20, heightHeader*2)];
    btUpdate.image = [NSImage imageNamed:@"update_press.png"];
    [[btUpdate cell] setBackgroundColor:[NSColor clearColor]];
    btUpdate.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    [btUpdate setBordered:NO];
    btUpdate.layer.borderColor = [NSColor clearColor].CGColor;
    btUpdate.layer.borderWidth = 0;
    btUpdate.layer.cornerRadius = 4.0;
    [btUpdate setToolTip:@"Update"];
    [btUpdate setTarget:self];
    [btUpdate setAction:@selector(btUpdateClick:)];
    [viewFooter addSubview:btUpdate];
    
    NSButton *btClose = [[NSButton alloc] initWithFrame:NSMakeRect(2*width/4, 0, width/4 - 20, heightHeader*2)];
    btClose.image = [NSImage imageNamed:@"Close_press.png"];
    [[btClose cell] setBackgroundColor:[NSColor clearColor]];
    btClose.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    [btClose setBordered:NO];
    btClose.layer.borderColor = [NSColor clearColor].CGColor;
    btClose.layer.borderWidth = 0;
    btClose.layer.cornerRadius = 4.0;
    [btClose setToolTip:@"Close"];
    [btClose setTarget:self];
    [btClose setAction:@selector(btCloseClick:)];
    [viewFooter addSubview:btClose];
    
    NSView *viewSubCenter = [[NSView alloc] initWithFrame:NSMakeRect(0, heightHeader*2, width, height - heightHeader*3)];
    viewSubCenter.wantsLayer = TRUE;
    viewSubCenter.layer.borderColor = NSColor.redColor.CGColor;
    viewSubCenter.layer.borderWidth = 0;
    [viewCenter addSubview:viewSubCenter];
    
    NSView *viewSubCenterLeft = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, width/2, height - heightHeader*3)];
    viewSubCenterLeft.wantsLayer = TRUE;
    viewSubCenterLeft.layer.borderColor = NSColor.redColor.CGColor;
    viewSubCenterLeft.layer.borderWidth = 0;
    [viewSubCenter addSubview:viewSubCenterLeft];
    
    NSView *viewSubLeft = [[NSView alloc] initWithFrame:NSMakeRect(10, height/10, width/2 - 20, (height - heightHeader*4) - 2*height/15)];
    viewSubLeft.wantsLayer = TRUE;
    viewSubLeft.layer.borderColor = [NSColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0].CGColor;
    viewSubLeft.layer.borderWidth = 1;
    [viewSubCenterLeft addSubview:viewSubLeft];
    
    double positionY = viewSubCenterLeft.frame.size.height - height/9;
    NSTextField *txtHeaderSubLeft = [[NSTextField alloc] initWithFrame:NSMakeRect(20, positionY, 120, 20)];
    txtHeaderSubLeft.alignment = NSTextAlignmentCenter;
    txtHeaderSubLeft.cell = [[UITextFieldCell alloc] init];
    txtHeaderSubLeft.stringValue = @"Current version";
    [txtHeaderSubLeft setEditable:NO];
    txtHeaderSubLeft.font = [NSFont fontWithName:@"Roboto-Medium" size:16];
    txtHeaderSubLeft.backgroundColor = colorCFBG;
    txtHeaderSubLeft.drawsBackground = YES;
    txtHeaderSubLeft.textColor = [NSColor orangeColor];
    [viewSubCenterLeft addSubview:txtHeaderSubLeft];
    
    NSView *groupSoftware = [[NSView alloc] initWithFrame:NSMakeRect(0, viewSubLeft.frame.size.height*3/4, viewSubLeft.frame.size.width, viewSubLeft.frame.size.height/4)];
    groupSoftware.wantsLayer = TRUE;
    groupSoftware.layer.borderColor = NSColor.blueColor.CGColor;
    groupSoftware.layer.borderWidth = 0;
    groupSoftware.layer.backgroundColor = NSColor.clearColor.CGColor;
    [viewSubLeft addSubview:groupSoftware];
    
    NSTextField *softwareVersion = [[NSTextField alloc] initWithFrame:NSMakeRect(30, groupSoftware.frame.size.height/3, groupSoftware.frame.size.width/2, 20)];
    softwareVersion.alignment = NSTextAlignmentCenter;
    softwareVersion.cell = [[UITextFieldCell alloc] init];
    softwareVersion.stringValue = @"IPSW";
    [softwareVersion setEditable:NO];
    softwareVersion.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    softwareVersion.backgroundColor = colorCFBG;
    softwareVersion.drawsBackground = YES;
    softwareVersion.textColor = [NSColor blackColor];
    [groupSoftware addSubview:softwareVersion];
    
    softwareVersionNumber = [[NSTextField alloc] initWithFrame:NSMakeRect(groupSoftware.frame.size.width/2 + 60, groupSoftware.frame.size.height/3, groupSoftware.frame.size.width/2, 20)];
    softwareVersionNumber.alignment = NSTextAlignmentCenter;
    softwareVersionNumber.cell = [[UITextFieldCell alloc] init];
    [softwareVersionNumber setEditable:NO];
    softwareVersionNumber.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    softwareVersionNumber.backgroundColor = colorCFBG;
    softwareVersionNumber.drawsBackground = YES;
    softwareVersionNumber.stringValue = @"N/A";
    softwareVersionNumber.textColor = [NSColor blackColor];
    [groupSoftware addSubview:softwareVersionNumber];
    
    NSView *viewSubCenterRight = [[NSView alloc] initWithFrame:NSMakeRect(width/2, 0, width/2, height - heightHeader*3)];
    viewSubCenterRight.wantsLayer = TRUE;
    viewSubCenterRight.layer.borderColor = NSColor.blueColor.CGColor;
    viewSubCenterRight.layer.borderWidth = 0;
    [viewSubCenter addSubview:viewSubCenterRight];
    
    NSView *viewSubRight = [[NSView alloc] initWithFrame:NSMakeRect(10, height/10, width/2 - 20, (height - heightHeader*4) - 2*height/15)];
    viewSubRight.wantsLayer = TRUE;
    viewSubRight.layer.borderColor = [NSColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0].CGColor;
    viewSubRight.layer.borderWidth = 1;
    [viewSubCenterRight addSubview:viewSubRight];
    
    checkBox = [[NSButton alloc] initWithFrame:NSMakeRect(30, positionY, 120, 20)];
    [checkBox setButtonType:NSSwitchButton];
    checkBox.image = [NSImage imageNamed:@"BoxChecked.png"];
    [checkBox setAction:@selector(updateState:)];
    [checkBox setTitle:@" New version"];
    NSMutableAttributedString *atribute = [delegate setColorTitleFor:checkBox color:[NSColor blueColor] Font: [NSFont fontWithName:@"Roboto-Medium" size:16]];
    [checkBox setAttributedTitle:atribute];
    checkBox.font = [NSFont fontWithName:@"Roboto-Medium" size:16];
    [checkBox setBezelStyle:0];
    [checkBox setState:1];
    checkBox.tag = 1;
    [checkBox setWantsLayer:YES];
    checkBox.layer.backgroundColor = colorCFBG.CGColor;
    [viewSubCenterRight addSubview:checkBox];
    
    NSView *groupSoftwareNewVer = [[NSView alloc] initWithFrame:NSMakeRect(0, viewSubRight.frame.size.height*3/4, viewSubRight.frame.size.width, viewSubRight.frame.size.height/4)];
    groupSoftwareNewVer.wantsLayer = TRUE;
    groupSoftwareNewVer.layer.borderColor = NSColor.blueColor.CGColor;
    groupSoftwareNewVer.layer.borderWidth = 0;
    groupSoftwareNewVer.layer.backgroundColor = NSColor.clearColor.CGColor;
    [viewSubRight addSubview:groupSoftwareNewVer];
    
    checkBoxSW = [[NSButton alloc] initWithFrame:NSMakeRect(30, groupSoftwareNewVer.frame.size.height/3, groupSoftwareNewVer.frame.size.width/2, 20)];
    [checkBoxSW setButtonType:NSSwitchButton];
    checkBoxSW.image = [NSImage imageNamed:@"BoxChecked.png"];
    [checkBoxSW setTitle:@" IPSW"];
    atribute = [delegate setColorTitleFor:checkBoxSW color:[NSColor blackColor] size:16];
    [checkBoxSW setAttributedTitle:atribute];
    checkBoxSW.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    [checkBoxSW setBezelStyle:0];
    [checkBoxSW setState:1];
    [checkBoxSW setWantsLayer:YES];
    checkBoxSW.layer.backgroundColor = colorCFBG.CGColor;
    [groupSoftwareNewVer addSubview:checkBoxSW];
    
    softwareNewVersionNumber = [[NSTextField alloc] initWithFrame:NSMakeRect(groupSoftwareNewVer.frame.size.width/2 + 60, groupSoftwareNewVer.frame.size.height/3, groupSoftwareNewVer.frame.size.width/2, 20)];
    softwareNewVersionNumber.alignment = NSTextAlignmentCenter;
    softwareNewVersionNumber.cell = [[UITextFieldCell alloc] init];
    softwareNewVersionNumber.stringValue = @"N/A";
    [softwareNewVersionNumber setEditable:NO];
    softwareNewVersionNumber.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    softwareNewVersionNumber.backgroundColor = colorCFBG;
    softwareNewVersionNumber.drawsBackground = YES;
    softwareNewVersionNumber.textColor = [NSColor blackColor];
    [groupSoftwareNewVer addSubview:softwareNewVersionNumber];
    
    timerUpdateState = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(updateState:) userInfo:nil repeats:YES];
    
//    timerUpdateUI = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
//    timerUpdateUI = [NSTimer scheduledTimerWithTimeInterval: 0.0
//                          target: self
//                          selector:@selector(updateUI)
//                          userInfo: nil repeats:YES];
    
    NSThread* evtThread = [ [NSThread alloc] initWithTarget:self
                                                   selector:@selector(updateUI)
                                                     object:nil];
    
    [evtThread start ];
    
    return self;
}

- (void) updateUI
{
    NSLog(@"[updateUI] ------ start update interface ------");
    
    size_t len = 0;
    sysctlbyname("hw.model", NULL, &len, NULL, 0);
    if(len)
    {
        char *model = malloc(len*sizeof(char));
        sysctlbyname("hw.model", model, &len, NULL, 0);
        printf("%s\n", model);
        self->macProductName = [NSString stringWithFormat:@"%s", model];
        free(model);
    }
    
    self->macProductName = [self->macProductName lowercaseString];
    NSLog(@"[%s][INFO] self->macProductName: %@", __func__, self->macProductName);
    
    [self getTokenID];
    NSLog(@"[updateUI] token key ID: %@", self->tokenID);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathChecksum = [NSString stringWithFormat: @"%@/EarseMac/Lib/config/ipsw_info.config", documentsDirectory];
    NSString *pathFileConfigDownload = [NSString stringWithFormat: @"%@/EarseMac/NewSoftware/ipsw_info.config", documentsDirectory];
    
    if ([fileManager fileExistsAtPath: pathChecksum] == false){
        NSLog(@"File ipsw_info.config is not exist");
        self->currentVersion = @"N/A";
        self->currentFileName = @"N/A";
        self->currentChecksum = @"N/A";
    }
    else
    {
        NSLog(@"File ipsw_info.config is exist");
        
        NSString* content = [NSString stringWithContentsOfFile:pathChecksum encoding:NSUTF8StringEncoding error:NULL];
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"[updateUI] json data: %@", json);
        self->currentVersion = json[self->macProductName][@"version_ipsw"];
        NSLog(@"[updateUI] currentVersion of ipsw: %@", self->currentVersion);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self->softwareVersionNumber.stringValue = self->currentVersion;
    });
    
    self->isAllowDownload = [self getConfig:pathFileConfigDownload];
    softwareNewVersionNumber.stringValue = self->ipsw_version;
    if(self->isAllowDownload == true)
    {
        NSLog(@"The latest software: [%@][%@]", self->currentVersion, self->ipsw_version);
        btUpdate.enabled = false;
    }
    else
    {
        btUpdate.enabled = true    ;
    }
}

- (void)updateState:(NSButton *)sender
{
    if(checkBox.state == 0)
    {
        checkBox.image = [NSImage imageNamed:@"BoxUncheck.png"];
        checkBoxSW.enabled = false;
        checkBoxFW.enabled = false;
        checkBoxFW1.enabled = false;
        checkBoxFW2.enabled = false;
    }
    else
    {
        checkBox.image = [NSImage imageNamed:@"BoxChecked.png"];
        checkBoxSW.enabled = true;
        checkBoxFW.enabled = true;
        checkBoxFW1.enabled = true;
        checkBoxFW2.enabled = true;
    }
    
    if(checkBoxSW.state == 0)
    {
        checkBoxSW.image = [NSImage imageNamed:@"BoxUncheck.png"];
    }
    else
    {
        checkBoxSW.image = [NSImage imageNamed:@"BoxChecked.png"];
    }
    
    if(checkBoxFW.state == 0)
    {
        checkBoxFW.image = [NSImage imageNamed:@"BoxUncheck.png"];
        checkBoxFW1.enabled = false;
        checkBoxFW2.enabled = false;
    }
    else
    {
        checkBoxFW.image = [NSImage imageNamed:@"BoxChecked.png"];
    }
    
    if(checkBoxFW1.state == 0)
    {
        checkBoxFW1.image = [NSImage imageNamed:@"BoxUncheck.png"];
    }
    else
    {
        checkBoxFW1.image = [NSImage imageNamed:@"BoxChecked.png"];
    }
    
    if(checkBoxFW2.state == 0)
    {
        checkBoxFW2.image = [NSImage imageNamed:@"BoxUncheck.png"];
    }
    else
    {
        checkBoxFW2.image = [NSImage imageNamed:@"BoxChecked.png"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)loadView
{
    [super loadView];
}

- (NSWindow *)showWindow
{
    NSWindow *window = [NSWindow windowWithContentViewController:self];
    [window center];
    [window setBackgroundColor:[NSColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0]];
    [window setContentSize:NSSizeFromCGSize(CGSizeMake(self.view.frame.size.width, self.view.frame.size.height))];
    window.title = @"iCombine Mac";
    window.contentViewController = self;
    [window setLevel:NSNormalWindowLevel];
    [window setStyleMask: NSWindowStyleMaskBorderless];
    NSWindowController *windowControllerIF = [[NSWindowController alloc] initWithWindow:window];
    [windowControllerIF.window makeKeyAndOrderFront:self];
    [windowControllerIF showWindow:nil];
    return window;
}

- (void) btCloseClick:(id)sender
{
    [self.view.window close];
    [timerUpdateState invalidate];
    [timerUpdateUI invalidate];
}

- (void) btUpdateClick:(id)sender
{
    delegate.isDownload = true;
    NSThread* evtThread = [ [NSThread alloc] initWithTarget:self
                                                   selector:@selector(downloadFirmware)
                                                     object:nil];
    
    [evtThread start ];
}

- (void)downloadFirmware
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //    NSString *pathConfig = [NSString stringWithFormat: @"%@/EarseMac/NewSoftware/ipsw_info.config", documentsDirectory];
    if (self->isAllowDownload == true)
    {
        NSString *pathIPSW = [NSString stringWithFormat: @"%@/EarseMac/%@", documentsDirectory, self->ipsw_name];
        if([self->tokenID isEqual:@""])
        {
            NSLog(@"[downloadFirmware] Cannot download file!");
            return;
        }
        else{
            NSLog(@"[downloadFirmware] Continue to download file");
            NSString *command = [NSString stringWithFormat: @"curl -H \"X-Auth-Token: %@\" https://storage101.dfw1.clouddrive.com/v1/MossoCloudFS_6d2201cb-63f4-47a5-97f4-08c7ff9621ba/Macbook_Erasure/IPSW/%@ --output %@", self->tokenID, self->ipsw_name, pathIPSW];
            [self runCommand:command];
            
            command = [NSString stringWithFormat: @"md5 %@/EarseMac/%@", documentsDirectory, self->ipsw_name];
            
            NSString *md5sum = [self runCommand:command];
            NSLog(@"MD5 file ipsw: %@", md5sum);
            if([md5sum containsString:self->ipsw_checksum])
            {
                command = [NSString stringWithFormat: @"cp -f %@/EarseMac/NewSoftware/ipsw_info.config %@/EarseMac/Lib/config/", documentsDirectory, documentsDirectory];
                [self runCommand:command];
            }
        }
    }
}

- (void)getTokenID
{
    NSString *url = [NSString stringWithFormat:@"%@", @"https://identity.api.rackspacecloud.com/v2.0/tokens"];
    NSLog(@"[getTokenID] url: %@", url);
    
    NSString *dataString = [NSString stringWithFormat: @"{\"auth\":{\"RAX-KSKEY:apiKeyCredentials\":{\"apiKey\":\"608720ab85c3498c82f5fda650f9a079\", \"username\":\"greycdn.user\"}}}"];
    NSLog(@"[getTokenID] Data send to CDN: %@", dataString);
    
    NSData *data_org = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"[getTokenID] Data send [byte]: %@", data_org);
    
    NSString * prams = [[NSString alloc] initWithData:data_org encoding:NSUTF8StringEncoding];
    prams = [prams stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSURL *urlString = [NSURL URLWithString:url];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:urlString];
    NSData *requestData = [prams dataUsingEncoding:NSUTF8StringEncoding];
    if (prams.length>0) {
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
        [urlRequest setHTTPBody: requestData];
    }
    
    NSURLSessionDataTask * dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString* myString;
        myString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"[getTokenID] Data from CDN: \n%@\n",myString);
        if (data.length > 0 && error == nil)
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData: data options:0 error:NULL];
            NSMutableArray *arrDic = [dict valueForKey: @"access"];
            NSMutableDictionary *tokenDic = [arrDic valueForKey:@"token"];
            self->tokenID = [tokenDic valueForKey:@"id"];
            NSLog(@"[getTokenID] Token ID: %@", self->tokenID);
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *pathFileConfig = [NSString stringWithFormat: @"%@/EarseMac/NewSoftware/ipsw_info.config", documentsDirectory];
            
            NSLog(@"[getTokenID] Path ipsw_info.config: %@", pathFileConfig);
            
            NSString *command = [NSString stringWithFormat: @"curl -H \"X-Auth-Token: %@\" https://storage101.dfw1.clouddrive.com/v1/MossoCloudFS_6d2201cb-63f4-47a5-97f4-08c7ff9621ba/Macbook_Erasure/IPSW/ipsw_info.config --output %@", self->tokenID, pathFileConfig];
            
            [self runCommand: command];
        }
    }];
    [dataTask resume];
    sleep(5);
}

- (NSString *)runCommand:(NSString *)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"[runCommand] Command string: \n%@\n", commandToRun);
    [task setArguments:arguments];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    NSData *data = [file readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}

- (bool) getConfig:(NSString*)pathFileConfig{
    bool result = false;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:pathFileConfig] == false)
    {
        self->ipsw_version = @"N/A";
        self->ipsw_name =  @"N/A";
        self->ipsw_checksum =  @"N/A";
    }
    else
    {
        NSString* content = [NSString stringWithContentsOfFile:pathFileConfig encoding:NSUTF8StringEncoding error:NULL];
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        self->ipsw_version = json[self->macProductName][@"version_ipsw"];
        self->ipsw_name = json[self->macProductName][@"file_name"];
        self->ipsw_checksum = json[self->macProductName][@"checksum"];
        
        NSLog(@"[getConfig] version_ipsw: %@", self->ipsw_version);
        NSLog(@"[getConfig] file_name: %@", self->ipsw_name);
        NSLog(@"[getConfig] checksum: %@", self->ipsw_checksum);
        
        if(self->currentVersion != self->ipsw_version && self->currentFileName != self->ipsw_name && self->currentChecksum != self->ipsw_checksum)
        {
            result = true;
        }
    }
    
    NSLog(@"[getConfig] get config: [%i]", result);
    return result;
}

@end
