//
//  DetaiViewController.m
//  EarseMac
//
//  Created by Greystone on 12/20/21.
//  Copyright © 2021 Greystone. All rights reserved.
//
#define MAX_ULONG 4294967295
#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#import "MainViewController.h"
#import "AppDelegate.h"
#import "LoginViewcontroller.h"
#import "CellTableClass.h"
#import "UITextFieldCell.h"
#import "DetailViewController.h"
#import "PrinterSetting.h"
#import "UIAlertView.h"
#import "ReportViewController.h"
#import "AboutViewController.h"
#import "UpdateViewController.h"
#import "SettingsView.h"
#import "LibUSB/ProccessUSB.h"
#import "ProtocolHW.h"
#import "UIButton.h"
#import <Realm/Realm.h>
#import "DeviceInfo.h"
#import "MacInformation.h"
#import "AFNetworking.h"
#import <CommonCrypto/CommonCrypto.h>
#import "DatabaseCom.h"
#import <SSZipArchive.h>
#import "FTPKit/FTPKit.h"
#include "DeviceMapping.h"
#include "LinkServer.h"
#include "UserLogin.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "Utilities/MyConstants.h"
#import "Update/AutoUpdateWatchFW.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize libusb;
@synthesize tableView;
@synthesize printSetting;
@synthesize windowController;
@synthesize txtItemID;
//@synthesize lbPleaseScanItemID;
NSTextField *lbConnectGCSLabel;

NSString* stringVlItemIDTemp = @"";
NSString* stationSN = @"";
NSString* userName = @"";
NSString* macAddress = @"";



//NSString* linkServer = @"http://gsitest.greystonedatatech.com/gsicloud/public/";
//NSString* linkServerBackup = @"http://gsitest.greystonedatatech.com/gsicloud/public/";

NSString* linkServer = @"http://pushing3.greystonedatatech.com/";
NSString* linkServerBackup = @"http://pushing3.greystonedatatech.com/";




NSMutableArray *arrPushingListMain;
NSString* operatingSystemVersionString = @"Mac OS";


NSString* colorDevice = @"N/A";
NSString* capacityDevice = @"N/A";
NSString* carrierDevice = @"N/A";
NSString* customerName = @"N/A";

int fontSizeCell = 18;

- (void)loadView
{
    libusb = nil;
    dicDataCellBK = [[NSMutableDictionary alloc] init];
    NSRect rect = [NSScreen mainScreen].frame;
    self.view = [[NSView alloc] initWithFrame:rect];
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor redColor].CGColor;
    self.view.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
}

- (void)runLogout
{
    if(mProtocolHW == nil) {
        mProtocolHW = [[ProtocolHW alloc] init];
    }
    while (TRUE) {
        NSLog(@"runLogout() =========");
        for (int i = 0; i < self->arrayBoard.count; i++)
        {
            NSMutableDictionary *dic = (NSMutableDictionary *)self->arrayBoard[i];
            // pro = [[ProtocolHW alloc] init];
            NSString *UniqueDeviceID = [dic objectForKey:@"UniqueDeviceID"];
            
            Byte arr[8]= {LED_OFF, LED_OFF, LED_OFF, LED_OFF, LED_OFF,LED_OFF,LED_OFF,LED_OFF};
            
            NSLog(@"%s ledControl call.",__func__);
            if ([mProtocolHW ledControl:UniqueDeviceID ledArr:arr] == 0) {
                NSLog(@"%s ledControl: FALSE.",__func__);
                turnOffLED = FALSE;
            }
        }
        
        
        if (turnOffLED) {
            AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
            [delegate logout];
            break;
        }
        sleep(1);
    }
}

BOOL turnOffLED = TRUE;
- (void)btLogoutClick:(id)sender
{
    NSLog(@"%s",__func__);
    
    NSMutableArray *arrButtons = [NSMutableArray arrayWithObjects:@"Yes",@"No",nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithFrame:NSMakeRect(0, 0, 400, 200)
                                                      title:@"Warning"
                                                     conten:@"Are you sure you want to logout?"
                                                       icon:[NSImage imageNamed:@"Warning"]
                                                    buttons:arrButtons
                                                        tag:10
                                                       Root:self seletor:@selector(messageSelect:)];
    [alert showWindow];
    
}

- (void) btRestartClick:(id)sender
{
    
    NSLog(@"%s",__func__);
    
    NSMutableArray *arrButtons = [NSMutableArray arrayWithObjects:@"Yes",@"No",nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithFrame:NSMakeRect(0, 0, 400, 200)
                                                      title:@"Warning"
                                                     conten:@"Are you sure you want to restart?"
                                                       icon:[NSImage imageNamed:@"Warning"]
                                                    buttons:arrButtons
                                                        tag:20
                                                       Root:self seletor:@selector(messageSelect:)];
    [alert showWindow];
    
}
- (void) btShutdownClick:(id)sender
{
    NSLog(@"%s",__func__);
    
    NSMutableArray *arrButtons = [NSMutableArray arrayWithObjects:@"Yes",@"No",nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithFrame:NSMakeRect(0, 0, 400, 200)
                                                      title:@"Warning"
                                                     conten:@"Are you sure you want to shutdown?"
                                                       icon:[NSImage imageNamed:@"Warning"]
                                                    buttons:arrButtons
                                                        tag:30
                                                       Root:self seletor:@selector(messageSelect:)];
    [alert showWindow];
    
}
- (void) messageSelect:(NSNumber*)num
{
    if([num intValue] == 10)// logout
    {
        turnOffLED = TRUE;
        [self.view.window toggleFullScreen:Nil];
        [self.view.window toggleToolbarShown:Nil];
        if(timerCheckDevice)
        {
            [timerCheckDevice invalidate];
            timerCheckDevice = nil;
        }
        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        [delegate logout];
        return;;
    }
    if([num intValue] == 20)// Restart
    {
        //sudo shutdown -r now
        NSLog(@"%s",__func__);
        NSString *scriptAction = @"restart"; // @"restart"/@"shut down"/@"sleep"/@"log out"
        NSString *scriptSource = [NSString stringWithFormat:@"tell application \"Finder\" to %@", scriptAction];
        NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:scriptSource];
        NSDictionary *errDict = nil;
        if (![appleScript executeAndReturnError:&errDict]) {
            NSLog(@"%@", errDict);
        }
        return;;
    }
    if([num intValue] == 30)// shutdown
    {
        //sudo shutdown -p now
        NSString *scriptAction = @"shut down"; // @"restart"/@"shut down"/@"sleep"/@"log out"
        NSString *scriptSource = [NSString stringWithFormat:@"tell application \"Finder\" to %@", scriptAction];
        NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:scriptSource];
        NSDictionary *errDict = nil;
        if (![appleScript executeAndReturnError:&errDict]) {
            NSLog(@"%@", errDict);
        }
        return;
    }
}
NSView *viewFile;
bool btFileClicked = FALSE;

NSButton *btLogoutText;
NSButton *btLogoutImage;

NSButton *btShutdownText;
NSButton *btShutdownImage;

NSButton *btRestartText;
NSButton *btRestartImage;

- (void)btFileClick:(id)sender
{
    NSLog(@"%s",__func__);
    viewHelp.hidden = TRUE;
    btHelpClicked = FALSE;
    //    viewTools.hidden = TRUE;
    //    btToolsClicked = FALSE;
    
    if (btFileClicked == FALSE) {
        btFileClicked = TRUE;
        NSRect rect = [NSScreen mainScreen].frame;
        int heightOfButton = rect.size.height/18;
        int xCoordinateFileView = 5;
        int yCoordinateFileView = rect.size.height - heightOfButton*3 - 55;
        NSRect rectFileView = NSMakeRect(xCoordinateFileView, yCoordinateFileView, rect.size.width/6, heightOfButton*3);
        viewFile = [[NSView alloc] initWithFrame:rectFileView];
        viewFile.wantsLayer = YES;
        viewFile.layer.backgroundColor = NSColor.whiteColor.CGColor;
        viewFile.hidden = FALSE;
        NSShadow *dropShadow = [[NSShadow alloc] init];
        [dropShadow setShadowColor:[NSColor blackColor]];
        [dropShadow setShadowOffset:NSMakeSize(0, -5.0)];
        [dropShadow setShadowBlurRadius:5.0];
        [viewFile setShadow:dropShadow];
        NSTrackingArea* trackingArea = [[NSTrackingArea alloc]
                                        initWithRect:[viewFile bounds]
                                        options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                        owner:self userInfo:@"viewFile"];
        [viewFile addTrackingArea:trackingArea];
        [self.view addSubview:viewFile];
        
        //Draw logout button
        NSColor *color = [NSColor blackColor];
        
        NSRect rectLogoutButton = NSMakeRect(0, viewFile.frame.size.height - heightOfButton, rect.size.width/6, heightOfButton);
        NSView *viewLogoutButton = [[NSView alloc] initWithFrame:rectLogoutButton];
        viewLogoutButton.wantsLayer = YES;
        viewLogoutButton.layer.backgroundColor = NSColor.whiteColor.CGColor;
        viewLogoutButton.hidden = FALSE;
        [viewFile addSubview:viewLogoutButton];
        
        int xCoordinateUpdateText = (rect.size.width/6)/5;
        btLogoutText = [[NSButton alloc] initWithFrame:NSMakeRect(xCoordinateUpdateText, 0, rect.size.width/6 - (rect.size.width/6)/5, heightOfButton)];
        btLogoutText.alignment = NSTextAlignmentLeft;
        btLogoutText.font = [NSFont systemFontOfSize:20];
        btLogoutText.title = @"Logout";
        NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[btLogoutText attributedTitle]];
        NSRange titleRange = NSMakeRange(0, [colorTitle length]);
        [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
        [btLogoutText setAttributedTitle:colorTitle];
        [btLogoutText setToolTip:@"Logout"];
        btLogoutText.wantsLayer = YES;
        btLogoutText.layer.backgroundColor = NSColor.whiteColor.CGColor;
        btLogoutText.bordered = NO;
        
        [btLogoutText setTarget:self];
        [btLogoutText setAction:@selector(btLogoutClick:)];
        
        NSTrackingArea* trackingAreaLogoutText = [[NSTrackingArea alloc]
                                                  initWithRect:[btLogoutText bounds]
                                                  options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                  owner:self userInfo:@"btLogoutText"];
        
        [btLogoutText addTrackingArea:trackingAreaLogoutText];
        [viewLogoutButton addSubview:btLogoutText];
        
        btLogoutImage = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, (rect.size.width/6)/5, heightOfButton)];
        
        btLogoutImage.wantsLayer = YES;
        btLogoutImage.layer.backgroundColor = NSColor.whiteColor.CGColor;
        btLogoutImage.bordered = NO;
        //[btAboutImage setImage:[NSImage imageNamed:@"About.png"]];
        btLogoutImage.imagePosition = NSImageAlignCenter;
        btLogoutImage.image = [NSImage imageNamed:@"logout_menu_new.png"];
        btLogoutImage.title = @"";
        [btLogoutImage setTarget:self];
        [btLogoutImage setAction:@selector(btLogoutClick:)];
        
        NSTrackingArea* trackingLogoutImage = [[NSTrackingArea alloc]
                                               initWithRect:[btLogoutImage bounds]
                                               options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                               owner:self userInfo:@"btLogoutImage"];
        [btLogoutImage addTrackingArea:trackingLogoutImage];
        [viewLogoutButton addSubview:btLogoutImage];
        
        //==================================================================================
        //Draw Check OS supported button
        NSRect rectShutdownButton = NSMakeRect(0, viewFile.frame.size.height - 2*heightOfButton, rect.size.width/6, heightOfButton);
        NSView *viewShutdownButton = [[NSView alloc] initWithFrame:rectShutdownButton];
        viewShutdownButton.wantsLayer = YES;
        viewShutdownButton.layer.backgroundColor = NSColor.blueColor.CGColor;
        viewShutdownButton.hidden = FALSE;
        [viewFile addSubview:viewShutdownButton];
        
        int xCoordinateShutdownText = (rect.size.width/6)/5;
        btShutdownText = [[NSButton alloc] initWithFrame:NSMakeRect(xCoordinateShutdownText, 0, rect.size.width/6 - (rect.size.width/6)/5, heightOfButton)];
        btShutdownText.alignment = NSTextAlignmentLeft;
        btShutdownText.font = [NSFont systemFontOfSize:20];
        btShutdownText.title = @"Shutdown";
        NSMutableAttributedString *colorTitleOS = [[NSMutableAttributedString alloc] initWithAttributedString:[btShutdownText attributedTitle]];
        NSRange titleRangeOS = NSMakeRange(0, [colorTitleOS length]);
        [colorTitleOS addAttribute:NSForegroundColorAttributeName value:color range:titleRangeOS];
        [btShutdownText setToolTip:@"Shutdown"];
        btShutdownText.wantsLayer = YES;
        btShutdownText.layer.backgroundColor = NSColor.whiteColor.CGColor;
        btShutdownText.bordered = NO;
        [btShutdownText setTarget:self];
        [btShutdownText setAction:@selector(btShutdownClick:)];
        //
        [btShutdownText setAttributedTitle:colorTitleOS];
        NSTrackingArea* trackingAreaShutdownText = [[NSTrackingArea alloc]
                                                    initWithRect:[btShutdownText bounds]
                                                    options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                    owner:self userInfo:@"btShutdownText"];
        
        [btShutdownText addTrackingArea:trackingAreaShutdownText];
        
        [viewShutdownButton addSubview:btShutdownText];
        
        btShutdownImage = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, (rect.size.width/6)/5, heightOfButton)];
        btShutdownImage.wantsLayer = YES;
        btShutdownImage.layer.backgroundColor = NSColor.whiteColor.CGColor;
        btShutdownImage.bordered = NO;
        //[btAboutImage setImage:[NSImage imageNamed:@"About.png"]];
        btShutdownImage.imagePosition = NSImageAlignCenter;
        btShutdownImage.image = [NSImage imageNamed:@"shutdown.png"];
        btShutdownImage.title = @"";
        [btShutdownImage setTarget:self];
        [btShutdownImage setAction:@selector(btShutdownClick:)];
        NSTrackingArea* trackingAreaShutdownImage = [[NSTrackingArea alloc]
                                                     initWithRect:[btShutdownImage bounds]
                                                     options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                     owner:self userInfo:@"btShutdownImage"];
        
        [btShutdownImage addTrackingArea:trackingAreaShutdownImage];
        [viewShutdownButton addSubview:btShutdownImage];
        //==================================================================================
        //Draw Restart button
        NSRect rectRestartButton = NSMakeRect(0, viewFile.frame.size.height - 3*heightOfButton, rect.size.width/6, heightOfButton);
        NSView *viewRestartButton = [[NSView alloc] initWithFrame:rectRestartButton];
        viewRestartButton.wantsLayer = YES;
        viewRestartButton.layer.backgroundColor = NSColor.greenColor.CGColor;
        viewRestartButton.hidden = FALSE;
        [viewFile addSubview:viewRestartButton];
        
        
        int xCoordinateRestartText = (rect.size.width/6)/5;
        btRestartText = [[NSButton alloc] initWithFrame:NSMakeRect(xCoordinateRestartText, 0, rect.size.width/6 - (rect.size.width/6)/5, heightOfButton)];
        btRestartText.alignment = NSTextAlignmentLeft;
        btRestartText.font = [NSFont systemFontOfSize:20];
        btRestartText.title = @"Restart";
        colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[btRestartText attributedTitle]];
        titleRange = NSMakeRange(0, [colorTitle length]);
        [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
        [btRestartText setToolTip:@"Restart"];
        btRestartText.wantsLayer = YES;
        btRestartText.layer.backgroundColor = NSColor.whiteColor.CGColor;
        btRestartText.bordered = NO;
        
        [btRestartText setAttributedTitle:colorTitle];
        [btRestartText setTarget:self];
        [btRestartText setAction:@selector(btRestartClick:)];
        
        NSTrackingArea* trackingAreaRestartText = [[NSTrackingArea alloc]
                                                   initWithRect:[btRestartText bounds]
                                                   options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                   owner:self userInfo:@"btRestartText"];
        
        [btRestartText addTrackingArea:trackingAreaRestartText];
        [viewRestartButton addSubview:btRestartText];
        
        btRestartImage = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, (rect.size.width/6)/5, heightOfButton)];
        
        btRestartImage.wantsLayer = YES;
        btRestartImage.layer.backgroundColor = NSColor.whiteColor.CGColor;
        btRestartImage.bordered = NO;
        //[btAboutImage setImage:[NSImage imageNamed:@"About.png"]];
        btRestartImage.imagePosition = NSImageAlignCenter;
        btRestartImage.image = [NSImage imageNamed:@"restart.png"];
        btRestartImage.title = @"";
        [btRestartImage setTarget:self];
        [btRestartImage setAction:@selector(btAboutClick:)];
        
        
        NSTrackingArea* trackingAreaRestartImage = [[NSTrackingArea alloc]
                                                    initWithRect:[btRestartImage bounds]
                                                    options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                    owner:self userInfo:@"btRestartImage"];
        
        [btRestartImage addTrackingArea:trackingAreaRestartImage];
        [btRestartImage setTarget:self];
        [btRestartImage setAction:@selector(btRestartClick:)];
        [viewRestartButton addSubview:btRestartImage];
        
        NSRect rectLine = NSMakeRect(0, viewFile.frame.size.height - heightOfButton, rect.size.width/6, 1);
        NSView *viewLine = [[NSView alloc] initWithFrame:rectLine];
        viewLine.wantsLayer = YES;
        viewLine.layer.backgroundColor = NSColor.grayColor.CGColor;
        [viewFile addSubview:viewLine];
        
        rectLine = NSMakeRect(0, viewFile.frame.size.height - 2*heightOfButton, rect.size.width/6, 1);
        viewLine = [[NSView alloc] initWithFrame:rectLine];
        viewLine.wantsLayer = YES;
        viewLine.layer.backgroundColor = NSColor.grayColor.CGColor;
        [viewFile addSubview:viewLine];
        
    } else {
        viewFile.hidden = TRUE;
        btFileClicked = FALSE;
    }
}

//NSView *viewTools;
//bool btToolsClicked = FALSE;
//
//NSButton *btSystemOptionsText;
//NSButton *btSystemOptionsImage;
//
//NSButton *btiDeviceFWText;
//NSButton *btiDeviceFWImage;
//
//- (void)btToolsClick:(id)sender
//{
//    NSLog(@"%s",__func__);
//    viewHelp.hidden = TRUE;
//    btHelpClicked = FALSE;
//    viewFile.hidden = TRUE;
//    btFileClicked = FALSE;
//    if (btToolsClicked == FALSE) {
//        btToolsClicked = TRUE;
//        NSRect rect = [NSScreen mainScreen].frame;
//        int heightOfButton = rect.size.height/18;
//        int xCoordinateToolsView = (rect.size.width/6)/3;
//        int yCoordinateToolsView = rect.size.height - heightOfButton*2 - 55;
//        NSRect rectToolsView = NSMakeRect(xCoordinateToolsView, yCoordinateToolsView, rect.size.width/6, heightOfButton*2);
//        viewTools = [[NSView alloc] initWithFrame:rectToolsView];
//        viewTools.wantsLayer = YES;
//        viewTools.layer.backgroundColor = NSColor.whiteColor.CGColor;
//        viewTools.hidden = FALSE;
//        NSShadow *dropShadow = [[NSShadow alloc] init];
//        [dropShadow setShadowColor:[NSColor blackColor]];
//        [dropShadow setShadowOffset:NSMakeSize(0, -5.0)];
//        [dropShadow setShadowBlurRadius:5.0];
//        [viewTools setShadow:dropShadow];
//        NSTrackingArea* trackingArea = [[NSTrackingArea alloc]
//                                        initWithRect:[viewHelp bounds]
//                                        options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
//                                        owner:self userInfo:@"viewTools"];
//        [viewTools addTrackingArea:trackingArea];
//        [self.view addSubview:viewTools];
//
//        //Draw system option button
//        NSColor *color = [NSColor blackColor];
//
//        NSRect rectSystemOptionButton = NSMakeRect(0, viewTools.frame.size.height - heightOfButton, rect.size.width/6, heightOfButton);
//        NSView *viewSystemOptionButton = [[NSView alloc] initWithFrame:rectSystemOptionButton];
//        viewSystemOptionButton.wantsLayer = YES;
//        viewSystemOptionButton.layer.backgroundColor = NSColor.whiteColor.CGColor;
//        viewSystemOptionButton.hidden = FALSE;
//        [viewTools addSubview:viewSystemOptionButton];
//
//        int xCoordinateSystemOptionText = (rect.size.width/6)/5;
//        btSystemOptionsText = [[NSButton alloc] initWithFrame:NSMakeRect(xCoordinateSystemOptionText, 0, rect.size.width/6 - (rect.size.width/6)/5, heightOfButton)];
//        btSystemOptionsText.alignment = NSTextAlignmentLeft;
//        btSystemOptionsText.font = [NSFont systemFontOfSize:20];
//        btSystemOptionsText.title = @"System options";
//        NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[btSystemOptionsText attributedTitle]];
//        NSRange titleRange = NSMakeRange(0, [colorTitle length]);
//        [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
//        [btSystemOptionsText setToolTip:@"System options"];
//        btSystemOptionsText.wantsLayer = YES;
//        btSystemOptionsText.layer.backgroundColor = NSColor.whiteColor.CGColor;
//        btSystemOptionsText.bordered = NO;
//
//        [btSystemOptionsText setAttributedTitle:colorTitle];
//        [btSystemOptionsText setTarget:self];
//        [btSystemOptionsText setAction:@selector(btSystemOptionsClick:)];
//
//        NSTrackingArea* trackingAreaSystemOptionText = [[NSTrackingArea alloc]
//                                             initWithRect:[btSystemOptionsText bounds]
//                                             options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
//                                             owner:self userInfo:@"btSystemOptionsText"];
//
//        [btSystemOptionsText addTrackingArea:trackingAreaSystemOptionText];
//        [viewSystemOptionButton addSubview:btSystemOptionsText];
//
//        btSystemOptionsImage = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, (rect.size.width/6)/5, heightOfButton)];
//
//        btSystemOptionsImage.wantsLayer = YES;
//        btSystemOptionsImage.layer.backgroundColor = NSColor.whiteColor.CGColor;
//        btSystemOptionsImage.bordered = NO;
//        //[btAboutImage setImage:[NSImage imageNamed:@"About.png"]];
//        btSystemOptionsImage.imagePosition = NSImageAlignCenter;
//        btSystemOptionsImage.image = [NSImage imageNamed:@"system_option.png"];
//        btSystemOptionsImage.title = @"";
//        [btSystemOptionsImage setTarget:self];
//        [btSystemOptionsImage setAction:@selector(btSystemOptionsClick:)];
//
//        NSTrackingArea* trackingAreaSystemOptionImage = [[NSTrackingArea alloc]
//                                             initWithRect:[btSystemOptionsImage bounds]
//                                             options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
//                                             owner:self userInfo:@"btSystemOptionsImage"];
//        [btSystemOptionsImage addTrackingArea:trackingAreaSystemOptionImage];
//
//        [viewSystemOptionButton addSubview:btSystemOptionsImage];
//
//
//        //Draw iDevice firmware
//        NSRect rectiDeviceFWButton = NSMakeRect(0, viewTools.frame.size.height - 2*heightOfButton, rect.size.width/6, heightOfButton);
//        NSView *viewiDeviceFWButton = [[NSView alloc] initWithFrame:rectiDeviceFWButton];
//        viewiDeviceFWButton.wantsLayer = YES;
//        viewiDeviceFWButton.layer.backgroundColor = NSColor.blueColor.CGColor;
//        viewiDeviceFWButton.hidden = FALSE;
//        [viewTools addSubview:viewiDeviceFWButton];
//
//        int xCoordinateiDeviceFWButtonText = (rect.size.width/6)/5;
//        btiDeviceFWText = [[NSButton alloc] initWithFrame:NSMakeRect(xCoordinateiDeviceFWButtonText, 0, rect.size.width/6 - (rect.size.width/6)/5, heightOfButton)];
//        btiDeviceFWText.alignment = NSTextAlignmentLeft;
//        btiDeviceFWText.font = [NSFont systemFontOfSize:20];
//        btiDeviceFWText.title = @"iDevice firmware";
//        NSMutableAttributedString *colorTitleOS = [[NSMutableAttributedString alloc] initWithAttributedString:[btiDeviceFWText attributedTitle]];
//        NSRange titleRangeOS = NSMakeRange(0, [colorTitleOS length]);
//        [colorTitleOS addAttribute:NSForegroundColorAttributeName value:color range:titleRangeOS];
//        [btiDeviceFWText setToolTip:@"iDevice firmware"];
//        btiDeviceFWText.wantsLayer = YES;
//        btiDeviceFWText.layer.backgroundColor = NSColor.whiteColor.CGColor;
//        btiDeviceFWText.bordered = NO;
//
//        [btiDeviceFWText setAttributedTitle:colorTitleOS];
//        //[btAboutText setTarget:self];
//        //[btAboutText setAction:@selector(btFileClick:)];
//        NSTrackingArea* trackingAreaiDeviceFWText = [[NSTrackingArea alloc]
//                                             initWithRect:[btiDeviceFWText bounds]
//                                             options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
//                                             owner:self userInfo:@"btiDeviceFWText"];
//
//        [btiDeviceFWText addTrackingArea:trackingAreaiDeviceFWText];
//
//        [viewiDeviceFWButton addSubview:btiDeviceFWText];
//
//        btiDeviceFWImage = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, (rect.size.width/6)/5, heightOfButton)];
//        btiDeviceFWImage.wantsLayer = YES;
//        btiDeviceFWImage.layer.backgroundColor = NSColor.whiteColor.CGColor;
//        btiDeviceFWImage.bordered = NO;
//        //[btAboutImage setImage:[NSImage imageNamed:@"About.png"]];
//        btiDeviceFWImage.imagePosition = NSImageAlignCenter;
//        btiDeviceFWImage.image = [NSImage imageNamed:@"idevice_fw.png"];
//        btiDeviceFWImage.title = @"";
//        //[btAboutText setTarget:self];
//        //[btAboutText setAction:@selector(btFileClick:)];
//
//        NSTrackingArea* trackingiDeviceFWImage = [[NSTrackingArea alloc]
//                                             initWithRect:[btiDeviceFWImage bounds]
//                                             options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
//                                             owner:self userInfo:@"btiDeviceFWImage"];
//
//        [btiDeviceFWImage addTrackingArea:trackingiDeviceFWImage];
//        [viewiDeviceFWButton addSubview:btiDeviceFWImage];
//
//
//        NSRect rectLine = NSMakeRect(0, viewTools.frame.size.height - heightOfButton, rect.size.width/6, 1);
//        NSView *viewLine = [[NSView alloc] initWithFrame:rectLine];
//        viewLine.wantsLayer = YES;
//        viewLine.layer.backgroundColor = NSColor.grayColor.CGColor;
//        [viewTools addSubview:viewLine];
//
//
//    } else {
//        viewTools.hidden = TRUE;
//        btToolsClicked = FALSE;
//    }
//}

//- (void)btSystemOptionsClick:(id)sender
//{
//    NSLog(@"%s",__func__);
//    SettingsView *settingView = [[SettingsView alloc] initWithFrame:NSMakeRect(0, 0, 750, 850)];
//    [settingView showWindow];
////    viewTools.hidden = TRUE;
////    btToolsClicked = FALSE;
//}


NSView *viewHelp;

NSButton *btAboutImage;
NSButton *btAboutText;

NSButton *btUpdateText;
NSButton *btUpdateImage;

NSButton *btOSSupportedText;
NSButton *btOSSupportedImage;

bool btHelpClicked = FALSE;
- (void)btHelpClick:(id)sender
{
    NSLog(@"%s",__func__);
    //    viewTools.hidden = TRUE;
    //    btToolsClicked = FALSE;
    viewFile.hidden = TRUE;
    btFileClicked = FALSE;
    if (btHelpClicked == FALSE) {
        btHelpClicked = TRUE;
        //Help View
        NSRect rect = [NSScreen mainScreen].frame;
        int heightOfButton = rect.size.height/18;
        int xCoordinateHelpView = (rect.size.width/6)/3;
        int yCoordinateHelpView = rect.size.height - (rect.size.height/6 - heightOfButton)  - 55;
        NSRect rectHelpView = NSMakeRect(xCoordinateHelpView, yCoordinateHelpView, rect.size.width/6, rect.size.height/6 - heightOfButton);
        viewHelp = [[NSView alloc] initWithFrame:rectHelpView];
        viewHelp.wantsLayer = YES;
        viewHelp.layer.backgroundColor = NSColor.whiteColor.CGColor;
        viewHelp.hidden = FALSE;
        NSShadow *dropShadow = [[NSShadow alloc] init];
        [dropShadow setShadowColor:[NSColor blackColor]];
        [dropShadow setShadowOffset:NSMakeSize(0, -5.0)];
        [dropShadow setShadowBlurRadius:5.0];
        
        [viewHelp setShadow:dropShadow];
        
        NSTrackingArea* trackingArea = [[NSTrackingArea alloc]
                                        initWithRect:[viewHelp bounds]
                                        options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                        owner:self userInfo:@"viewHelp"];
        
        [viewHelp addTrackingArea:trackingArea];
        
        [self.view addSubview:viewHelp];
        
        
        //Draw update button
        NSColor *color = [NSColor blackColor];
        
        NSRect rectUpdateButton = NSMakeRect(0, viewHelp.frame.size.height - heightOfButton, rect.size.width/6, heightOfButton);
        NSView *viewUpdateButton = [[NSView alloc] initWithFrame:rectUpdateButton];
        viewUpdateButton.wantsLayer = YES;
        viewUpdateButton.layer.backgroundColor = NSColor.whiteColor.CGColor;
        viewUpdateButton.hidden = FALSE;
        [viewHelp addSubview:viewUpdateButton];
        
        int xCoordinateUpdateText = (rect.size.width/6)/5;
        btUpdateText = [[NSButton alloc] initWithFrame:NSMakeRect(xCoordinateUpdateText, 0, rect.size.width/6 - (rect.size.width/6)/5, heightOfButton)];
        btUpdateText.alignment = NSTextAlignmentLeft;
        btUpdateText.font = [NSFont systemFontOfSize:20];
        btUpdateText.title = @"Update";
        NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[btUpdateText attributedTitle]];
        NSRange titleRange = NSMakeRange(0, [colorTitle length]);
        [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
        [btUpdateText setToolTip:@"Update"];
        btUpdateText.wantsLayer = YES;
        btUpdateText.layer.backgroundColor = NSColor.whiteColor.CGColor;
        btUpdateText.bordered = NO;
        
        [btUpdateText setAttributedTitle:colorTitle];
        //[btAboutText setTarget:self];
        [btUpdateText setAction:@selector(btUpdateClick:)];
        
        NSTrackingArea* trackingAreaUpdateText = [[NSTrackingArea alloc]
                                                  initWithRect:[btUpdateText bounds]
                                                  options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                  owner:self userInfo:@"btUpdateText"];
        
        [btUpdateText addTrackingArea:trackingAreaUpdateText];
        [viewUpdateButton addSubview:btUpdateText];
        
        btUpdateImage = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, (rect.size.width/6)/5, heightOfButton)];
        
        btUpdateImage.wantsLayer = YES;
        btUpdateImage.layer.backgroundColor = NSColor.whiteColor.CGColor;
        btUpdateImage.bordered = NO;
        //[btAboutImage setImage:[NSImage imageNamed:@"About.png"]];
        btUpdateImage.imagePosition = NSImageAlignCenter;
        btUpdateImage.image = [NSImage imageNamed:@"Update.png"];
        btUpdateImage.title = @"";
        //[btAboutText setTarget:self];
        [btUpdateImage setAction:@selector(btUpdateClick:)];
        
        NSTrackingArea* trackingAreaUpdateImage = [[NSTrackingArea alloc]
                                                   initWithRect:[btUpdateImage bounds]
                                                   options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                   owner:self userInfo:@"btUpdateImage"];
        [btUpdateImage addTrackingArea:trackingAreaUpdateImage];
        
        [viewUpdateButton addSubview:btUpdateImage];
        
        //        //Draw Check OS supported button
        //        NSRect rectCheckOSSupportedButton = NSMakeRect(0, viewHelp.frame.size.height - 2*heightOfButton, rect.size.width/6, heightOfButton);
        //        NSView *viewCheckOSSupportedButton = [[NSView alloc] initWithFrame:rectCheckOSSupportedButton];
        //        viewCheckOSSupportedButton.wantsLayer = YES;
        //        viewCheckOSSupportedButton.layer.backgroundColor = NSColor.blueColor.CGColor;
        //        viewCheckOSSupportedButton.hidden = FALSE;
        //        [viewHelp addSubview:viewCheckOSSupportedButton];
        //
        //        int xCoordinateOSSupportedText = (rect.size.width/6)/5;
        //        btOSSupportedText = [[NSButton alloc] initWithFrame:NSMakeRect(xCoordinateOSSupportedText, 0, rect.size.width/6 - (rect.size.width/6)/5, heightOfButton)];
        //        btOSSupportedText.alignment = NSTextAlignmentLeft;
        //        btOSSupportedText.font = [NSFont systemFontOfSize:20];
        //        btOSSupportedText.title = @"Check OS supported";
        //        NSMutableAttributedString *colorTitleOS = [[NSMutableAttributedString alloc] initWithAttributedString:[btOSSupportedText attributedTitle]];
        //        NSRange titleRangeOS = NSMakeRange(0, [colorTitleOS length]);
        //        [colorTitleOS addAttribute:NSForegroundColorAttributeName value:color range:titleRangeOS];
        //        [btOSSupportedText setToolTip:@"Check OS supported"];
        //        btOSSupportedText.wantsLayer = YES;
        //        btOSSupportedText.layer.backgroundColor = NSColor.whiteColor.CGColor;
        //        btOSSupportedText.bordered = NO;
        //
        //        [btOSSupportedText setAttributedTitle:colorTitleOS];
        //        //[btAboutText setTarget:self];
        //        //[btAboutText setAction:@selector(btFileClick:)];
        //        NSTrackingArea* trackingAreaOSSupportedText = [[NSTrackingArea alloc]
        //                                             initWithRect:[btOSSupportedText bounds]
        //                                             options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
        //                                             owner:self userInfo:@"btOSSupportedText"];
        //
        //        [btOSSupportedText addTrackingArea:trackingAreaOSSupportedText];
        //
        //        [viewCheckOSSupportedButton addSubview:btOSSupportedText];
        //
        //        btOSSupportedImage = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, (rect.size.width/6)/5, heightOfButton)];
        //        btOSSupportedImage.wantsLayer = YES;
        //        btOSSupportedImage.layer.backgroundColor = NSColor.whiteColor.CGColor;
        //        btOSSupportedImage.bordered = NO;
        //        //[btAboutImage setImage:[NSImage imageNamed:@"About.png"]];
        //        btOSSupportedImage.imagePosition = NSImageAlignCenter;
        //        btOSSupportedImage.image = [NSImage imageNamed:@"iOS_update.png"];
        //        btOSSupportedImage.title = @"";
        //        //[btAboutText setTarget:self];
        //        //[btAboutText setAction:@selector(btFileClick:)];
        //
        //        NSTrackingArea* trackingAreaOSSupportedImage = [[NSTrackingArea alloc]
        //                                             initWithRect:[btOSSupportedImage bounds]
        //                                             options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
        //                                             owner:self userInfo:@"btOSSupportedImage"];
        //
        //        [btOSSupportedImage addTrackingArea:trackingAreaOSSupportedImage];
        //        [viewCheckOSSupportedButton addSubview:btOSSupportedImage];
        
        
        //Draw About button
        NSRect rectAboutButton = NSMakeRect(0, viewHelp.frame.size.height - 2*heightOfButton, rect.size.width/6, heightOfButton);
        NSView *viewAboutButton = [[NSView alloc] initWithFrame:rectAboutButton];
        viewAboutButton.wantsLayer = YES;
        viewAboutButton.layer.backgroundColor = NSColor.greenColor.CGColor;
        viewAboutButton.hidden = FALSE;
        [viewHelp addSubview:viewAboutButton];
        
        
        int xCoordinateAboutText = (rect.size.width/6)/5;
        btAboutText = [[NSButton alloc] initWithFrame:NSMakeRect(xCoordinateAboutText, 0, rect.size.width/6 - (rect.size.width/6)/5, heightOfButton)];
        btAboutText.alignment = NSTextAlignmentLeft;
        btAboutText.font = [NSFont systemFontOfSize:20];
        btAboutText.title = @"About";
        colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[btAboutText attributedTitle]];
        titleRange = NSMakeRange(0, [colorTitle length]);
        [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
        [btAboutText setToolTip:@"About"];
        btAboutText.wantsLayer = YES;
        btAboutText.layer.backgroundColor = NSColor.whiteColor.CGColor;
        btAboutText.bordered = NO;
        
        [btAboutText setAttributedTitle:colorTitle];
        [btAboutText setTarget:self];
        [btAboutText setAction:@selector(btAboutClick:)];
        
        
        
        NSTrackingArea* trackingAreaAboutText = [[NSTrackingArea alloc]
                                                 initWithRect:[btAboutText bounds]
                                                 options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                 owner:self userInfo:@"btAboutText"];
        
        [btAboutText addTrackingArea:trackingAreaAboutText];
        [viewAboutButton addSubview:btAboutText];
        
        btAboutImage = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, (rect.size.width/6)/5, heightOfButton)];
        
        btAboutImage.wantsLayer = YES;
        btAboutImage.layer.backgroundColor = NSColor.whiteColor.CGColor;
        btAboutImage.bordered = NO;
        //[btAboutImage setImage:[NSImage imageNamed:@"About.png"]];
        btAboutImage.imagePosition = NSImageAlignCenter;
        btAboutImage.image = [NSImage imageNamed:@"About.png"];
        btAboutImage.title = @"";
        [btAboutImage setTarget:self];
        [btAboutImage setAction:@selector(btAboutClick:)];
        
        
        NSTrackingArea* trackingAreaAboutImage = [[NSTrackingArea alloc]
                                                  initWithRect:[btAboutText bounds]
                                                  options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                  owner:self userInfo:@"btAboutImage"];
        
        [btAboutImage addTrackingArea:trackingAreaAboutImage];
        
        [viewAboutButton addSubview:btAboutImage];
        
        NSRect rectLine = NSMakeRect(0, viewHelp.frame.size.height - heightOfButton, rect.size.width/6, 1);
        NSView *viewLine = [[NSView alloc] initWithFrame:rectLine];
        viewLine.wantsLayer = YES;
        viewLine.layer.backgroundColor = NSColor.grayColor.CGColor;
        [viewHelp addSubview:viewLine];
        
        rectLine = NSMakeRect(0, viewHelp.frame.size.height - 2*heightOfButton, rect.size.width/6, 1);
        viewLine = [[NSView alloc] initWithFrame:rectLine];
        viewLine.wantsLayer = YES;
        viewLine.layer.backgroundColor = NSColor.grayColor.CGColor;
        [viewHelp addSubview:viewLine];
        
    } else {
        viewHelp.hidden = TRUE;
        btHelpClicked = FALSE;
    }
}


- (void)btAboutClick:(id)sender
{
    NSLog(@"%s",__func__);
    
    viewHelp.hidden = TRUE;
    btHelpClicked = FALSE;
    
    // NSMutableArray *arrDataPrint = [NSMutableArray array];
    NSMutableDictionary *dic;
    for(int i = 0; i < arrDatabaseCell.count; i++)
    {
        dic = (NSMutableDictionary *)arrDatabaseCell[i];
    }
    NSRect rect = [NSScreen mainScreen].frame;
    int width = rect.size.width/3.5;
    int height = rect.size.height/2;
    int xCoordinate = (rect.size.width-width)/2;
    int yCoordinate = (rect.size.height-height)/2;
    //customerName
    AboutViewController *aboutViewController = [[AboutViewController alloc] initWithFrame:CGRectMake(xCoordinate, yCoordinate, width, height) data:dic hwVersion:hwVersionSendAbout fwVersion:fwVersionSendAbout customerName:customerName];
    [aboutViewController showWindow];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSLog(@"%s viewDidLoad ======>",__func__);
    NSString* operatingSystemVersionStringTemp = [[NSProcessInfo processInfo] operatingSystemVersionString];
    
    NSLog(@"viewDidLoad operatingSystemVersionString => %@" , operatingSystemVersionString);
    operatingSystemVersionString = [NSString stringWithFormat: @"%@ %@", operatingSystemVersionString, operatingSystemVersionStringTemp];
    // Do view setup here.
    NSLog(@"viewDidLoad operatingSystemVersionString => %@" , operatingSystemVersionString);
    
//    NSString *ipswFileName = [self get_ipsw_name];
//    NSLog(@"Ipsw name for erase each device: %@", ipswFileName); // debug 08/02/2023
    
    [self.view.window toggleFullScreen:self];
    [self.view.window toggleToolbarShown:self];
    [NSApplication sharedApplication].presentationOptions  = NSApplicationPresentationAutoHideDock|NSApplicationPresentationAutoHideMenuBar|NSApplicationPresentationAutoHideToolbar;
    numRow = 0;
    numCol = 0;
    
    xoaManual = YES;// lay tu web
    dicInforconfig = [[self getConfig] mutableCopy];
    
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    delegate.isLogout = NO;
    appDelegate = delegate;
    stationSN = delegate.mMacAddress;
    userName = delegate.userName;
    arrPushingListMain = delegate.arrPushingListDelegate;
    macAddress = delegate.mMacAddress2Send;
    
    NSLog(@"%s viewDidLoad ======> MAC Adress (stationSN): %@", __func__, stationSN);
    NSLog(@"%s viewDidLoad ======> arrPushingListMain: %@", __func__, arrPushingListMain);
    NSLog(@"%s viewDidLoad ======> MAC Adress (macAddress): %@", __func__, macAddress);
    
    if(self->protocolHW == nil)
    {
        self->protocolHW = [[ProtocolHW alloc] init];
    }
    
    int hv = 50;
    NSRect rect = [NSScreen mainScreen].frame;
    [self drawFooter:NSMakeRect(0, 0, rect.size.width, hv)];
    [self drawHeader:NSMakeRect(0, rect.size.height - hv, rect.size.width, hv)];
    [self drawMainScreen:NSMakeRect(0, hv, rect.size.width, rect.size.height - 2*hv)];
    
    [self copyFileLib];
    checkInfoFlag = 0;
    
}

- (void)btUpdateClick:(id)sender
{
    NSLog(@"%s [btUpdateClicked] ------------ begin ------------", __func__);
    
//    AutoUpdateWatchFW *autoUpdateWatchFW = [[AutoUpdateWatchFW alloc] init];
//    [autoUpdateWatchFW showWindow];
    
    NSRect rect = [NSScreen mainScreen].frame;
    int width = rect.size.width/2;
    int height = rect.size.height/2;
    UpdateViewController *mUpdateViewController = [[UpdateViewController alloc] initWithFrame:(CGRectMake(0, 0, width, height))];
    [mUpdateViewController showWindow];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    txtItemID.editable = YES;
    
}
-(void)viewWillDisappear:(BOOL)animated{
    
}

- (void)viewDidDisappear {
    NSLog(@"%s viewDidDisappear ==============================> OFF ALL LED and REMOVE BoardButtons Click Observer", __func__);
    operatingSystemVersionString = @"Mac OS";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BoardButtonsClick" object:nil];
}

- (void)viewDidAppear
{
    [super viewWillAppear];
    
    NSWindow *wd = [txtItemID window];
    [wd makeFirstResponder:txtItemID];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(catchEventButtonHardwareClick:) name:@"BoardButtonsClick" object:nil];
    
    threadCheckFW_HW_Version = [[NSThread alloc] initWithTarget:self selector:@selector(runCheckHW_FW_Version) object:nil];
    NSLog(@"%s viewDidAppear ======> threadCheckFW_HW_Version.executing %hhd", __func__, threadCheckFW_HW_Version.executing);
    if (threadCheckFW_HW_Version.executing == FALSE) {
        [threadCheckFW_HW_Version start];
    }
    
    myThread = [[NSThread alloc] initWithTarget:self selector:@selector(runUpdate) object:nil];
    if (myThread.executing == FALSE) {
        [myThread start];
    }
    
    //    myThreadUpdateUI = [[NSThread alloc] initWithTarget:self selector:@selector(runUpdateUI) object:nil];
    //    if (myThreadUpdateUI.executing == FALSE) {
    //        [myThreadUpdateUI start];
    //    }
    
    myThreadRemoveDevice = [[NSThread alloc] initWithTarget:self selector:@selector(checkRemoveDevice) object:nil];
    if (myThreadRemoveDevice.executing == FALSE) {
        [myThreadRemoveDevice start];
    }
    
    checkInfoFlag = 0;
    
}


- (void)copyFileLib
{
    AppDelegate *delegatedir = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSString *pathLib = [delegatedir pathLib];
    NSString *source = [NSString stringWithFormat:@"%@/idevicerestore/src/idevicerestore",pathLib];//URL(string: "file:///Users/xxx/Desktop/Media/")!
    NSString *sourceInfo = [NSString stringWithFormat:@"%@/libimobiledevice/tools/ideviceinfo",pathLib];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:source]==NO)
    {
        NSLog(@"%s khong co file source: %@",__func__,source);
        return;
    }
    NSString *destination;
    NSString *desInfo;
    NSError *err;
    source = [NSString stringWithFormat:@"file://%@",source];
    sourceInfo = [NSString stringWithFormat:@"file://%@",sourceInfo];
    for(int i=0;i<=arrDatabaseCell.count;i++)
    {
        err = nil;
        destination = [NSString stringWithFormat:@"%@%d",source,i];
        desInfo = [NSString stringWithFormat:@"%@%d",sourceInfo,i];
        NSLog(@"%s copy file: %@",__func__,destination);
        
        [[NSFileManager defaultManager] copyItemAtURL:[NSURL URLWithString:source] toURL:[NSURL URLWithString:destination] error:&err];
        NSLog(@"%s coppy file: %@",__func__,desInfo);
        [[NSFileManager defaultManager] copyItemAtURL:[NSURL URLWithString:sourceInfo] toURL:[NSURL URLWithString:desInfo] error:&err];
        
    }
    
}

- (void)createDir :(NSString *)dirName
{
    //NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentPath = [paths objectAtIndex:0];
    NSString *temp = [NSString stringWithFormat: @"%@%@", @"/EarseMac/", dirName];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSURL* pathSaveSW = [[[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] objectAtIndex:0] URLByAppendingPathComponent:temp];
    if(![fm fileExistsAtPath:[pathSaveSW path]]){
        NSLog(@"[createDirForImage] dir doesn't exists");
        NSError *error;
        if (![[NSFileManager defaultManager] fileExistsAtPath:pathSaveSW.path])
        {
            if (![[NSFileManager defaultManager] createDirectoryAtPath:pathSaveSW.path
                                           withIntermediateDirectories:NO
                                                            attributes:nil
                                                                 error:&error])
            {
                NSLog(@"[createDirForImage] Create directory error: %@", error);
            }
        }
    } else {
        NSLog(@"[createDirForImage] dir exists");
    }
}



- (NSString *)runCommand:(NSString *)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"run command:%@", commandToRun);
    [task setArguments:arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}

//- (NSString *)runCommandError:(NSString *)commandToRun
//{
//    NSTask *task = [[NSTask alloc] init];
//    [task setLaunchPath:@"/bin/sh"];
//
//    NSArray *arguments = [NSArray arrayWithObjects:
//                          @"-c" ,
//                          [NSString stringWithFormat:@"%@", commandToRun],
//                          nil];
//    NSLog(@"run command:%@", commandToRun);
//    [task setArguments:arguments];
//
//    NSPipe *pipe = [NSPipe pipe];
//    [task setStandardError:pipe];
//    NSFileHandle *file = [pipe fileHandleForReading];
//
//    [task launch];
//
//    NSData *data = [file readDataToEndOfFile];
//
//    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    return output;
//}

BOOL isDownloadingSW = FALSE;
BOOL isDownloadedSW = FALSE;
BOOL isUnzippedSW = FALSE;

BOOL isDownloadingFW = FALSE;
BOOL isDownloadedFW = FALSE;
BOOL isUnzippedFW = FALSE;

BOOL isDownloadingSQLMapping = FALSE;
BOOL isDownloadedSQLMapping = FALSE;


NSString *fileNameZip = @"sample-zip-file.zip";
NSString *versionSW_DownloadSW = @"";
NSString *versionSW_DownloadFW = @"";

NSMutableArray *arrVersionFW;
- (void) createThreadToUpdateDBDeviceMapping:(NSArray*) lines
{
    NSLog(@"[FTP][SQL] createThreadToUpdateDBDeviceMapping: %lu", (unsigned long)lines.count);
    
    NSThread* threadUpdateDBDeviceMapping = [[NSThread alloc] initWithTarget:self
                                                                    selector:@selector(processUpdateDBDeviceMapping:)
                                                                      object:lines];
    [threadUpdateDBDeviceMapping start];
}

- (void) processUpdateDBDeviceMapping:(NSArray*) lines
{
    NSLog(@"[FTP][SQL] createThreadToUpdateDBDeviceMapping lines: %lu", (unsigned long)lines.count);
    RLMRealm *realm = [RLMRealm defaultRealm];
    for(int i = 14; i < lines.count - 1; i++) {
        if (realm.inWriteTransaction) {
            NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask][arrPushingListMain] inWriteTransaction");
            return;
        }
        NSString *myLine = lines[i];
        myLine = [myLine stringByReplacingOccurrencesOfString:@"INSERT INTO `gds_mobile_table_carrier` VALUES (" withString:@""];
        myLine = [myLine stringByReplacingOccurrencesOfString:@");" withString:@""];
        myLine = [myLine stringByReplacingOccurrencesOfString:@"'" withString:@""];
        NSLog(@"[FTP][SQL] myLine: %@", myLine);
        NSArray *arrayOfComponents = [myLine componentsSeparatedByString:@","];
        
        if ([arrayOfComponents[2] rangeOfString:@"Apple Watch"].location == NSNotFound) {
            NSLog(@"[FTP][SQL] string does not contain Apple Watch");
        } else {
            NSLog(@"[FTP][SQL] string contains Apple Watch!");
            if ([arrayOfComponents[2] rangeOfString:@"Apple Watch"].location != 0) {
                [realm beginWriteTransaction];
                //icapture_pn
                NSString *icapture_pn = arrayOfComponents[1];
                NSString *icapturePNTrimmed = [icapture_pn stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                DeviceMapping *deviceMapping = [[DeviceMapping alloc] init];
                deviceMapping.noID = arrayOfComponents[0];
                deviceMapping.icapture_pn = icapturePNTrimmed;
                deviceMapping.product_name = arrayOfComponents[2];
                deviceMapping.capacity = arrayOfComponents[3];
                deviceMapping.color = arrayOfComponents[4];
                deviceMapping.carrier = arrayOfComponents[5];
                deviceMapping.country = arrayOfComponents[6];
                deviceMapping.region_code = arrayOfComponents[7];
                deviceMapping.external_model = arrayOfComponents[8];
                NSUUID *UUID = [[NSUUID alloc] init];
                NSString *id = [UUID UUIDString];
                deviceMapping.ID = id;
                
                //NSLog(@"[FTP][SQL] deviceMapping.noID: %@", deviceMapping.noID);
                //NSLog(@"[FTP][SQL] deviceMapping.icapture_pn: %@",  deviceMapping.icapture_pn);
                //NSLog(@"[FTP][SQL] deviceMapping.product_name: %@",  deviceMapping.product_name);
                //NSLog(@"[FTP][SQL] deviceMapping.capacity: %@", deviceMapping.capacity);
                //NSLog(@"[FTP][SQL] deviceMapping.color: %@", deviceMapping.color);
                //NSLog(@"[FTP][SQL] deviceMapping.carrier: %@", deviceMapping.carrier);
                //NSLog(@"[FTP][SQL] deviceMapping.country: %@", deviceMapping.country);
                //NSLog(@"[FTP][SQL] deviceMapping.region_code: %@", deviceMapping.region_code);
                //NSLog(@"[FTP][SQL] external_model.external_model: %@", deviceMapping.external_model);
                //NSLog(@"[FTP][SQL] deviceMapping.ID: %@", deviceMapping.ID);
                
                [realm addOrUpdateObject:deviceMapping];
                [realm commitWriteTransaction];
            }
            
        }
    }
    
    NSLog(@"[FTP][SQL] deviceMapping update database DONE!!!");
    sendDeviceMappingVerify = TRUE;
    
}

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
NSURLRequest *requestDownloadSW;
NSURLSessionDownloadTask *downloadTaskSW;

- (void) runDownloadSW_FW
{
    @autoreleasepool {
        [self createDir: @"NewSoftware"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [paths objectAtIndex:0];
        
        NSArray *pathDesktop = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
        NSString *desktopPath = [pathDesktop objectAtIndex:0];
        NSString *rmFilePath = [NSString stringWithFormat: @"rm %@%@", documentPath, @"/EarseMac/NewSoftware/setup.zip"];
        NSString *output = [self runCommand: rmFilePath];
        NSLog(@"[runDownloadSW_FW] rmFilePath: %@", rmFilePath);
        NSLog(@"[runDownloadSW_FW] rmFilePath output: %@", output);
        NSLog(@"[runDownloadSW_FW] desktopPath: %@", desktopPath);
        
        NSString *downloadFolderPath = [NSString stringWithFormat: @"file://%@%@", documentPath, @"/EarseMac/NewSoftware/"];
        NSURL *urlDownloadFolderPath = [NSURL URLWithString:downloadFolderPath];
        AFURLSessionManager *managerAFURLSessionManager;
        AFURLSessionManager *managerAFURLSessionManagerSW;
        while (TRUE)
        {
            // Add new May 5, 2022 Query object via eraseID (ID in database)
            //RLMResults<DeviceInfo*> *watchDeviceQuery = [DeviceInfo objectsWhere:@"eraseVerify = 1"];
            RLMRealm *realm = RLMRealm.defaultRealm;
            [realm refresh];
            RLMResults<MacInformation *> *macDeviceQuery = [[MacInformation allObjects] objectsWhere:@"needToSendGCS = 1"];
            dispatch_queue_t queue = dispatch_queue_create("database_access", 0);
            
            NSLog(@"%sThread 30(s) [runCheckDownloadSW_FW] dictPrepare2Send macDeviceQuery size: %lu", __func__, (unsigned long)macDeviceQuery.count);
            if((unsigned long)macDeviceQuery.count > 0) {
                
                for (int i = 0; i < (unsigned long)macDeviceQuery.count; i++)
                {
                    deviceInfoNeed2SendRefTemp = [RLMThreadSafeReference referenceWithThreadConfined:macDeviceQuery[i]];
                    NSMutableDictionary *dictPrepare2Send = [[NSMutableDictionary alloc]init];
                    [dictPrepare2Send setObject:@"e_mac_ask_change" forKey:@"action"];
                    [dictPrepare2Send setObject:@(30) forKey:@"command"];
                    [dictPrepare2Send setObject:txtLocationInfo.stringValue forKey:@"location"];
                    [dictPrepare2Send setObject:txtUserNameInfo.stringValue forKey:@"user_name"];
                    [dictPrepare2Send setObject:txtWorkAreaInfo.stringValue forKey:@"work_area"];
                    [dictPrepare2Send setObject:txtLineNumberInfo.stringValue forKey:@"line_number"];
                    [dictPrepare2Send setObject:txtBatchInfo.stringValue forKey:@"batch_number"];
                    [dictPrepare2Send setObject:macDeviceQuery[i].cellID forKey:@"port"];
                    [dictPrepare2Send setObject:macDeviceQuery[i].transaction_ID forKey:@"transaction_id"];
                    [dictPrepare2Send setObject:@"Booted" forKey:@"status"];
                    [dictPrepare2Send setObject:macDeviceQuery[i].mSerialNumber forKey:@"serial"];
                    [dictPrepare2Send setObject:macDeviceQuery[i].mECID forKey:@"ecid"];
                    [dictPrepare2Send setObject:macDeviceQuery[i].mSerialNumber forKey:@"macbook_serial"];
                    [dictPrepare2Send setObject:@"" forKey:@"restore_error"];
                    [dictPrepare2Send setObject:@(macDeviceQuery[i].resulfOfErasureValue) forKey:@"restore_status"];
                    [dictPrepare2Send setObject:@"" forKey:@"model"];
                    [dictPrepare2Send setObject:macDeviceQuery[i].timeEnd forKey:@"time_local"];
                    [dictPrepare2Send setObject:macDeviceQuery[i].timeStart forKey:@"time_start"];
                    [dictPrepare2Send setObject:macDeviceQuery[i].timeEnd forKey:@"time_end"];
                    [dictPrepare2Send setObject:@"end" forKey:@"restore_process"];
                    [dictPrepare2Send setObject:stationSN forKey:@"stationsn"];
                    [dictPrepare2Send setObject:@"" forKey:@"provision_uuid"];
                    [dictPrepare2Send setObject:@"" forKey:@"model_need_check_function"];
                    [dictPrepare2Send setObject:VERSION forKey:@"sw_version"];
                    
                    NSError *err;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictPrepare2Send options:NSJSONWritingPrettyPrinted error:&err];
                    NSLog(@"JSON dictPrepare2Send = %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
                    
                    NSString *postDataBase64Encoded = [jsonData base64EncodedStringWithOptions:0];
                    NSLog(@"postDataBase64Encoded = %@", postDataBase64Encoded);
                    
                    int sizeOfarrPushingList = (int) arrPushingListMain.count - 1;
                    NSLog(@"[updateDatabase] sizeOfarrPushingList: %d", sizeOfarrPushingList);
                    linkServer = @"http://pushing9.greystonedatatech.com";
                    
                    
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    if(array.count == 0)
                    {
                        [array addObject:@"http://pushing16.greystonedatatech.com/"];
                        [array addObject:@"http://pushing17.greystonedatatech.com/"];
                        [array addObject:@"http://pushing25.greystonedatatech.com/"];
                        [array addObject:@"http://pushing9.greystonedatatech.com/"];
                        [array addObject:@"http://pushing2.greystonedatatech.com/"];
                        [array addObject:@"http://pushing30.greystonedatatech.com/"];
                        [array addObject:@"http://pushing3.greystonedatatech.com/"];
                    }
                    int sizeArray = (int) array.count - 1;
                    
                    int randomNumber = [self getRandomNumberBetween:0 and:sizeArray];
                    linkServer = array[randomNumber];
                    
                    
                    //                    if (sizeOfarrPushingList > 1) {
                    //                        int randomNumber = [self getRandomNumberBetween:0 and:sizeOfarrPushingList];
                    //                        linkServer = arrPushingListMain[randomNumber];
                    //                    } else if (sizeOfarrPushingList == 1) {
                    //                        linkServer = arrPushingListMain[0];
                    //                    }
                    
                    linkServer = [linkServer stringByAppendingString:@"emac.php"];
                    NSLog(@"[updateDatabase] SERVER LINK: %@", linkServer);
                    
                    // Create the URLSession on the default configuration
                    NSURLSessionConfiguration *defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
                    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration];
                    
                    // Setup the request with URL
                    NSURL *url = [NSURL URLWithString:linkServer];
                    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
                    
                    
                    // Convert POST string parameters to data using UTF8 Encoding
                    [urlRequest setHTTPMethod:@"POST"];
                    [urlRequest setHTTPBody:[postDataBase64Encoded dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    // Create dataTask
                    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        // Handle your response here
                        if (data != nil) {
                            if (data.length > 0) {
                                NSString *jsonResponseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                NSLog(@"JSON RESPONSE OF GSC: %@", jsonResponseString);
                                if (jsonResponseString.length > 0) {
                                    dispatch_async(queue, ^{
                                        @autoreleasepool {
                                            @try {
                                                RLMRealm *realm = [RLMRealm defaultRealm];
                                                deviceInfoNeed2Send = [realm resolveThreadSafeReference:deviceInfoNeed2SendRefTemp];
                                                if (!deviceInfoNeed2Send) {
                                                    return;
                                                }
                                                if(![realm inWriteTransaction]) {
                                                    [realm transactionWithBlock:^{
                                                        deviceInfoNeed2Send.needToSendGCS = SEND_SUCCESSFULLY;
                                                        NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW] dictPrepare2Send Reply STATUS_OK at deviceInfoNeed2Send.ID: %@", deviceInfoNeed2Send.ID);
                                                    }];
                                                }
                                            }
                                            @catch (NSException *exception) {
                                                NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW] dictPrepare2Send Reply NSException exception.reason: %@", exception.reason);
                                            }
                                            @finally {
                                                NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW] dictPrepare2Send Reply Finally condition");
                                            }
                                        }
                                    });
                                }
                            }
                        }
                        
                    }];
                    // Fire the request
                    [dataTask resume];
                    
                    // 1 - define resource URL
                    //                    NSURL *URL = [NSURL URLWithString:linkServer];
                    //                    //2 - create AFNetwork manager
                    //                    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                    //
                    //                    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
                    //                    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
                    //                    manager.requestSerializer = [AFJSONRequestSerializer serializer];
                    //                    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                    //
                    //                    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    //                    //3 - set a body
                    //                    //4 - create request
                    //                    [manager POST: URL.absoluteString
                    //                       parameters: dictPrepare2Send
                    //                         progress: nil
                    //                     //5 - response handling
                    //                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    //                        //NSLog(@"Reply POST JSON: %@", responseObject);
                    //                        NSString *jsonStringResponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                    //                        NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW] dictPrepare2Send jsonStringResponse: %@", jsonStringResponse);
                    //
                    //                        NSData *data = [jsonStringResponse dataUsingEncoding:NSUTF8StringEncoding];
                    //                        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    //                        NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW]  status: %@",[json objectForKey:@"status"]);
                    //                        NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW] stationsn: %@",[json objectForKey:@"stationsn"]);
                    //                        if([json objectForKey:@"stationsn"] != nil) {
                    //                            NSInteger valueStatus = [[json objectForKey:@"status"] integerValue];
                    //                            if(valueStatus == UPDATE_STATUS_OK) {
                    //                                NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW] dictPrepare2Send Reply STATUS_OK");
                    //
                    //                                dispatch_async(queue, ^{
                    //                                    @autoreleasepool {
                    //                                        @try {
                    //                                            RLMRealm *realm = [RLMRealm defaultRealm];
                    //                                            deviceInfoNeed2Send = [realm resolveThreadSafeReference:deviceInfoNeed2SendRefTemp];
                    //                                            if (!deviceInfoNeed2Send) {
                    //                                                return;
                    //                                            }
                    //                                            if(![realm inWriteTransaction]) {
                    //                                                [realm transactionWithBlock:^{
                    //                                                    deviceInfoNeed2Send.eraseVerify = VERIFY_DONE;
                    //                                                    NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW] dictPrepare2Send Reply STATUS_OK at deviceInfoNeed2Send.ID: %@", deviceInfoNeed2Send.ID);
                    //
                    //                                                }];
                    //                                            }
                    //                                        }
                    //                                        @catch (NSException *exception) {
                    //                                            NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW] dictPrepare2Send Reply NSException exception.reason: %@", exception.reason);
                    //                                        }
                    //                                        @finally {
                    //                                            NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW] dictPrepare2Send Reply Finally condition");
                    //                                        }
                    //                                    }
                    //                                });
                    //                            }
                    //                        } else {
                    //                            NSLog(@"[NSURLSessionDataTask] dictPrepare2Send Reply Couldn't parse status");
                    //                        }
                    //                    }
                    //                          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    //                        NSLog(@"[NSURLSessionDataTask] dictPrepare2Send Reply error: %@", error);
                    //                    }
                    //                    ];
                }
            }
            
            if (isDownloadingSQLMapping)
            {
                isDownloadingSQLMapping = FALSE;
                //FTPClient *ftp = [FTPClient clientWithHost:@"cloud.greystonedatatech.com" port:21 username:@"ftpupload" password:@"123Qwe!@#"];
                if (ftp == nil) {
                    ftp = [FTPClient clientWithHost:ftpServer port:ftpPort username:ftpUsername password:ftpPassword];
                }
                // [ftp directoryExistsAtPath:@"/Mini-ZeroIT/Setting" success:^(BOOL exists) {
                
                [ftp directoryExistsAtPath:ftpServerPath success:^(BOOL exists) {
                    if (exists) {
                        NSLog(@"[FTP] Success: 000");
                    } else {
                        NSLog(@"[FTP] Error: Root path '/' must exist");
                    }
                } failure:^(NSError *error) {
                    NSLog(@"[FTP] Error: %@", error.localizedDescription);
                }];
                if (downloadSQLFolderPath == nil) {
                    downloadSQLFolderPath = [NSString stringWithFormat: @"%@%@", documentPath, @"/EarseMac/NewSoftware/gds_mobile_table_carrier.sql"];
                }
                
                NSLog(@"[FTP] downloadSQLFolderPath: %@", downloadSQLFolderPath);
                [ftp downloadFile:@"/Mini-ZeroIT/Setting/gds_mobile_table_carrier.sql" to: downloadSQLFolderPath progress: nil success:^(void) {
                    NSLog(@"[FTP] Success download SQL file");
                    if (fileContents == nil) {
                        fileContents = [NSString stringWithContentsOfFile:downloadSQLFolderPath];
                    }
                    if (lines == nil) {
                        lines = [fileContents componentsSeparatedByString:@"\n"];
                    }
                    NSLog(@"lines: %lu", (unsigned long)lines.count);
                    [self createThreadToUpdateDBDeviceMapping: lines];
                } failure:^(NSError *error) {
                    NSLog(@"[FTP] Error: %@", error.localizedDescription);
                }];
            }
            
            NSLog(@"linkDownloadFW [Firmware]: isDownloadingFW %hd", isDownloadingFW);
//            isDownloadingFW = true;
            
            if (isDownloadingFW)
            {
                isDownloadingFW = FALSE;
                if (managerAFURLSessionManager == nil) {
                    managerAFURLSessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                }
                
                //https://b011086fa2a305b25393-d9a427afbab97d13dae330d7e969a9b9.ssl.cf1.rackcdn.com/Firmware/5.12/FW_VERSION.tar.gz
                linkDownloadFWTemp = @"https://b011086fa2a305b25393-d9a427afbab97d13dae330d7e969a9b9.ssl.cf1.rackcdn.com/Firmware/";
//                NSString *linkDownloadFW = [NSString stringWithFormat:@"%@%@/%@", linkDownloadFWTemp, versionSW_DownloadFW, @"FW_VERSION.tar.gz"];
                NSString *linkDownloadFW = [NSString stringWithFormat:@"%@/%@/%@", linkDownloadFWTemp, @"4.4a", @"FW_VERSION.tar.gz"];
                NSLog(@"linkDownloadFW [Firmware]: %@", linkDownloadFW);
                
                if (URL_DownloadFW == nil) {
                    URL_DownloadFW = [NSURL URLWithString:linkDownloadFW];
                }
                if (requestDownloadFW == nil) {
                    requestDownloadFW = [NSURLRequest requestWithURL:URL_DownloadFW];
                }
                
                NSLog(@"[runDownloadSW_FW] [Firmware] urlDownloadFolderPath 1: %@", urlDownloadFolderPath);
                
                downloadTaskFW = [managerAFURLSessionManager downloadTaskWithRequest:requestDownloadFW progress:^(NSProgress * _Nonnull downloadProgress) {
                    NSLog(@"[runDownloadSW_FW] [Firmware] Progress: %f", downloadProgress.fractionCompleted*100);
                    
                    int percentage = [[NSNumber numberWithFloat:downloadProgress.fractionCompleted*100] intValue];
                    
                    downloadStatus = [NSString stringWithFormat:@"Downloading the new firmware %d%@", percentage, @"%"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        lbConnectGCSLabel.stringValue = downloadStatus;
                        lbConnectGCSLabel.textColor = NSColor.redColor;
                    });
                    
                } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    //NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                    return [urlDownloadFolderPath URLByAppendingPathComponent:[response suggestedFilename]];
                } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error)
                                  {
                    NSLog(@"[runDownloadSW_FW] [Firmware] [response suggestedFilename]: %@", [response suggestedFilename]);
                    fileNameZip = [response suggestedFilename];
                    NSLog(@"[runDownloadSW_FW] [Firmware] File downloaded to: %@", filePath);
                    isDownloadedFW = TRUE;
                }];
                [downloadTaskFW resume];
            }
            
            if (isDownloadedFW)
            {
                if(!isUnzippedFW)
                {
                    NSString *downloadFolderPath = [NSString stringWithFormat: @"%@%@", documentPath, @"/EarseMac/NewSoftware/"];
                    NSString *fileZipPath = [NSString stringWithFormat: @"%@%@", downloadFolderPath, fileNameZip];
                    
                    int status = 1;
                    
                    NSString *commandExtractFirmware = [NSString stringWithFormat:@"tar -xvf %@ -C %@", fileZipPath, downloadFolderPath];
                    [self runCommand:commandExtractFirmware];
                    
                    NSLog(@"------------- [Firmware] status ----------- %d", status);
                    
                    if(status == 0) {
                        NSLog(@"-------------[Firmware] status ----------- 0");
                        NSLog(@"\nrunDownloadSW_FW Unzip [Firmware] unsuccessfully");
                        NSString *downloadStatus = [NSString stringWithFormat:@"Download new firmware unsuccessfully."];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            lbConnectGCSLabel.stringValue = downloadStatus;
                            
                        });
                        isUnzippedSW = FALSE;
                        isDownloadedSW = FALSE;
                        isDownloadingSW = FALSE;
                        
                        isUnzippedFW = FALSE;
                        isDownloadedFW = FALSE;
                        isDownloadingFW = FALSE;
                        
                    }
                    else
                    {
                        NSLog(@"[Firmware]------------- status ----------- 1");
                        
                        NSString *firmwarePath = [NSString stringWithFormat:@"%@FW_VERSION/battery.bin", downloadFolderPath];
                        NSLog(@"[Firmware] firmware path: %@", firmwarePath);
                        
                        if([self->mProtocolHW upgradeFirmware:firmwarePath] == TRUE)
                        {
                            NSString *commandRemoveFileTar = [NSString stringWithFormat:@"rm %@FW_VERSION.tar.gz", downloadFolderPath];
                            NSLog(@"[Firmware]------------- [Firmware] commandRemoveFileTar ----------- %@", commandRemoveFileTar);
                            [self runCommand:commandRemoveFileTar];
                            
                            sleep(1);
                            
                            NSString *commandRemoveFolder = [NSString stringWithFormat:@"rm -Rf %@FW_VERSION", downloadFolderPath];
                            NSLog(@"[Firmware]------------- [Firmware] commandRemoveFolder ----------- %@", commandRemoveFolder);
                            [self runCommand:commandRemoveFolder];
                            
                            sleep(1);
                            
                            NSString *downloadStatus = [NSString stringWithFormat:@"Download new firmware successfully."];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                lbConnectGCSLabel.stringValue = downloadStatus;
                                lbConnectGCSLabel.textColor = NSColor.blueColor;
                            });
                            
                            isUnzippedFW = FALSE;
                            isDownloadedFW = FALSE;
                            isDownloadingFW = FALSE;
                            
                            sleep(3);
                            exit(0);
                        }
                    }
                }
            }
            
            if (isDownloadingSW)
            {
                isDownloadingSW = FALSE;
                if (managerAFURLSessionManagerSW == nil) {
                    managerAFURLSessionManagerSW = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                }
                
                NSString *linkDownloadSWTemp = @"https://b011086fa2a305b25393-d9a427afbab97d13dae330d7e969a9b9.ssl.cf1.rackcdn.com/Software";
                NSString *linkDownloadSW = [NSString stringWithFormat:@"%@/%@/%@", linkDownloadSWTemp, versionSW_DownloadSW, @"setup.zip"];
                NSLog(@"\nlinkDownloadSW: %@", linkDownloadSW);
                
                //DEBUG
                //linkDownloadSW = @"https://www.sample-videos.com/zip/50mb.zip";
                //END DEBUG
                
                if (URL_DownloadSW == nil) {
                    URL_DownloadSW = [NSURL URLWithString:linkDownloadSW];
                }
                if (requestDownloadSW == nil) {
                    requestDownloadSW = [NSURLRequest requestWithURL:URL_DownloadSW];
                }
                
                
                NSLog(@"[runDownloadSW_FW] urlDownloadFolderPath 1: %@", urlDownloadFolderPath);
                downloadTaskSW = [managerAFURLSessionManagerSW downloadTaskWithRequest:requestDownloadSW progress:^(NSProgress * _Nonnull downloadProgress)
                                  {
                    NSLog(@"[runDownloadSW_FW] Progress: %f", downloadProgress.fractionCompleted*100);
                    
                    int percentage = [[NSNumber numberWithFloat:downloadProgress.fractionCompleted*100] intValue];
                    
                    NSString *downloadStatus = [NSString stringWithFormat:@"Downloading the new software %d%@", percentage, @"%"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        lbConnectGCSLabel.stringValue = downloadStatus;
                        lbConnectGCSLabel.textColor = NSColor.redColor;
                        
                    });
                    
                } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    //NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                    return [urlDownloadFolderPath URLByAppendingPathComponent:[response suggestedFilename]];
                } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error)
                                  {
                    NSLog(@"[runDownloadSW_FW] [response suggestedFilename]: %@", [response suggestedFilename]);
                    fileNameZip = [response suggestedFilename];
                    NSLog(@"[runDownloadSW_FW] File downloaded to: %@", filePath);
                    isDownloadedSW = TRUE;
                }];
                [downloadTaskSW resume];
            }
            
            if (isDownloadedSW)
            {
                isDownloadedSW = FALSE;
                if(!isUnzippedSW)
                {
                    NSString *downloadFolderPath = [NSString stringWithFormat: @"%@%@", documentPath, @"/EarseMac/NewSoftware/"];
                    NSLog(@"[Update SW] => downloadFolderPath: %@", downloadFolderPath);
                    NSString *fileZipPath = [NSString stringWithFormat: @"%@%@", downloadFolderPath, fileNameZip];
                    NSLog(@"[Update SW] => fileZipPath: %@", fileZipPath);
                    
                    BOOL success = [SSZipArchive unzipFileAtPath:fileZipPath
                                                   toDestination:desktopPath
                                              preserveAttributes:YES
                                                       overwrite:YES
                                                  nestedZipLevel:0
                                                        password:nil
                                                           error:nil
                                                        delegate:nil
                                                 progressHandler:nil
                                               completionHandler:nil];
                    
                    //                    [self runCommand:[NSString stringWithFormat:@"unzip -o %@ -d %@/", fileZipPath, desktopPath]];
                    //                    NSPipe *pipe = [[NSPipe alloc] init];
                    //                    NSFileHandle *file = pipe.fileHandleForReading;
                    //                    NSTask *task = [[NSTask alloc] init];
                    //                    [task setLaunchPath:@"unzip"];
                    //                    [task setArguments:[NSArray arrayWithObjects:@"-o", @"-d", downloadFolderPath, fileZipPath, nil]];
                    //                    task.standardOutput = pipe;
                    //                    [task launch];
                    //                    if(task.isRunning)
                    //                        [task waitUntilExit];
                    
                    //                    int status = [task terminationStatus];
                    //                    int status = 1;
                    NSLog(@"------------- status ----------- %d", success);
                    
                    if(success == FALSE) {
                        NSLog(@"------------- status = 0 ----------- ");
                        NSLog(@"\nrunDownloadSW_FW Unzip unsuccessfully");
                        NSString *downloadStatus = [NSString stringWithFormat:@"Download new software unsuccessfully."];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            lbConnectGCSLabel.stringValue = downloadStatus;
                        });
                        isUnzippedSW = FALSE;
                        isDownloadedSW = FALSE;
                        isDownloadingSW = FALSE;
                        
                        isUnzippedFW = FALSE;
                        isDownloadedFW = FALSE;
                        isDownloadingFW = FALSE;
                        
                    } else {
                        NSLog(@"------------- status ----------- !0");
                        //                        [self runCommand:[NSString stringWithFormat:@"sudo rm -Rf %@/iCombineMac.app", desktopPath]];
                        //                        [self runCommand:[NSString stringWithFormat:@"sudo cp -Rf %@ %@/%@", , desktopPath, fileNameZip]];
                        NSString *downloadStatus = [NSString stringWithFormat:@"Download new software successfully."];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            lbConnectGCSLabel.stringValue = downloadStatus;
                            lbConnectGCSLabel.textColor = NSColor.blueColor;
                        });
                        sleep(3);
                        exit(0);
                        
                    }
                }
            }
            sleep(10);
        }
    }
}

// Get the INTERNAL ip address

- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

BOOL checkDownload = FALSE;
BOOL sendMachineInfo = FALSE;
BOOL sendMapping = FALSE;
BOOL sendDeviceMappingVerify = FALSE;
BOOL sendLinkServerVerify = FALSE;
BOOL sendUpdateMachineInfo = FALSE;
BOOL sendRequestSyncUserLogin = FALSE;
BOOL sendRequestSyncUserLoginVerify = FALSE;
BOOL sendRequestGet5Fields = FALSE;
BOOL sendRequestVerifyGet5Fields = FALSE;



NSString *ftpServer = @"cloud.greystonedatatech.com";
NSString *ftpServerPath = @"\/Mini-ZeroIT\/Setting";
NSString *ftpClientPath = @"\/ZeroIT";
NSString *ftpUsername = @"ftpupload";
NSString *ftpPassword = @"123Qwe!@#";
NSString *ftpPort = @"21";
NSString *ftpFilename = @"gds_mobile_table_carrier.sql";
NSString *hwVersionSendAbout = @"";
NSString *fwVersionSendAbout = @"";


NSString *jsonStringResponseUserLogin;
NSData *dataUserLogin;
NSString *jsonStringResponseUpdateMachineInfo;
NSData *dataUpdateMachineInfo;
NSString *jsonStringResponseLinkServerVerify;
NSData *dataLinkServerVerify;
NSString *jsonStringResponseDeviceMapping;
NSData *dataDeviceMapping;
NSNumber* mapType;

NSString *jsonStringResponseDeviceMappingVerify;
NSData *dataDeviceMappingVerify;

NSString *jsonStringResponseMachineInfo;
NSData *dataMachineInfo;

NSMutableDictionary *dictDownloadSW_FW;
NSData *jsonDataDownloadSW_FW;

NSString *jsonStringResponseDictDownloadSW_FW;
NSData *dataDictDownloadSW_FW;

NSString *jsonStringResponseSyncUserLoginNew;
NSData *dataSyncUserLoginNew;

NSString *jsonStringResponseGet5Fields;
NSData *dataGet5Fields;

NSString *jsonStringResponseVerifyGet5Fields;
NSData *dataVerifyGet5Fields;


NSMutableArray* arrUserObject;
UserLogin *mUserLogin;
- (void) runCheckDownloadSW_FW {
    @autoreleasepool {
        NSString *hwVersionMain = @"";
        NSString *fwVersionMain = @"";
        arrVersionFW = [[NSMutableArray alloc]init];
        NSMutableDictionary *dictMachineInfo = [[NSMutableDictionary alloc]init];
        [dictMachineInfo removeAllObjects];
        
        if (arrayBoard.count > 0) {
            hwVersionMain = @"";
            fwVersionMain = @"";
            
            for (int i = 0; i < arrayBoard.count; i++)
            {
                NSMutableDictionary *dic = [arrayBoard objectAtIndex:i];
                NSLog(@"[runCheckDownloadSW_FW] dicTemp: %@", dic);
                NSDictionary *version = [dic objectForKey:@"VersionHW"];
                NSString *fwVersion = [version objectForKey:@"firmware"];
                NSString *hwVersion = [version objectForKey:@"hardware"];
                NSLog(@"[runCheckDownloadSW_FW] hwVersion: %@", hwVersion);
                NSLog(@"[runCheckDownloadSW_FW] fwVersion: %@", fwVersion);
                if (fwVersion != nil) {
                    arrVersionFW[i] = fwVersion;
                    
                    if ([fwVersionMain  isEqual: @""])
                    {
                        fwVersionMain = [fwVersionMain stringByAppendingString:fwVersion];
                    }
                    else {
                        fwVersionMain = [fwVersionMain stringByAppendingFormat:@"; %@" , fwVersion];
                    }
                }
                
                if (hwVersion != nil) {
                    if ([hwVersionMain  isEqual: @""])
                    {
                        hwVersionMain = [hwVersionMain stringByAppendingString:hwVersion];
                    }
                    else {
                        hwVersionMain = [hwVersionMain stringByAppendingFormat:@"; %@", hwVersion];
                    }
                }
                
            }
            hwVersionSendAbout = hwVersionMain;
            fwVersionSendAbout = fwVersionMain;
            NSLog(@"[runCheckDownloadSW_FW] hwVersionMain: %@", hwVersionMain);
            NSLog(@"[runCheckDownloadSW_FW] fwVersionMain: %@", fwVersionMain);
        }
        
        // Check model Mac
        //        NSMutableDictionary *dictGetModelMac = [[NSMutableDictionary alloc]init];
        //        [dictGetModelMac setValue:@(30) forKey:@"command"];
        //        [dictGetModelMac setValue:@"e_mac_ask_change" forKey:@"action"];
        //        [dictGetModelMac setValue:@"get" forKey:@"push"];
        //        [dictGetModelMac setValue:@"os_type" forKey:@"macOS"];
        //        [dictGetModelMac setValue:stationSN forKey:@"stationsn"];
        //        [dictGetModelMac setValue:macAddress forKey:@"mac_address"];
        //        [dictGetModelMac setValue:@"N/A" forKey:@"teamviewerID"];
        //        [dictGetModelMac setValue:@"N/A" forKey:@"model_need_check_function"];
        //        [dictGetModelMac setValue:VERSION forKey:@"sw_version"];
        //        [dictGetModelMac setValue:@"iwatch_eraser" forKey:@"machine_type"];
        
        
        // 5 Fields
        NSMutableDictionary *dictGet5Fields = [[NSMutableDictionary alloc]init];
        [dictGet5Fields setValue:@(30) forKey:@"command"];
        [dictGet5Fields setValue:@"icombine_mac_settings" forKey:@"action"];
        [dictGet5Fields setValue:@"get" forKey:@"push"];
        [dictGet5Fields setValue:@"os_type" forKey:@"macOS"];
        [dictGet5Fields setValue:stationSN forKey:@"stationsn"];
        [dictGet5Fields setValue:macAddress forKey:@"mac_address"];
        [dictGet5Fields setValue:@"N/A" forKey:@"teamviewerID"];
        [dictGet5Fields setValue:VERSION forKey:@"sw_version"];
        [dictGet5Fields setValue:@"iwatch_eraser" forKey:@"machine_type"];
        
        //Create machine info package
        NSError *errGet5Fields;
        NSData *jsonGet5Fields = [NSJSONSerialization dataWithJSONObject:dictGet5Fields options:NSJSONWritingPrettyPrinted error:&errGet5Fields];
        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] jsonGet5Fields JSON = %@", [[NSString alloc] initWithData:jsonGet5Fields encoding:NSUTF8StringEncoding]);
        
        // 5 Fields
        NSMutableDictionary *dictVeriryGet5Fields = [[NSMutableDictionary alloc]init];
        [dictVeriryGet5Fields setValue:@(30) forKey:@"command"];
        [dictVeriryGet5Fields setValue:@"icombine_mac_settings" forKey:@"action"];
        [dictVeriryGet5Fields setValue:@"verify" forKey:@"push"];
        [dictVeriryGet5Fields setValue:@"os_type" forKey:@"macOS"];
        [dictVeriryGet5Fields setValue:stationSN forKey:@"stationsn"];
        [dictVeriryGet5Fields setValue:macAddress forKey:@"mac_address"];
        [dictVeriryGet5Fields setValue:@"N/A" forKey:@"teamviewerID"];
        [dictVeriryGet5Fields setValue:VERSION forKey:@"sw_version"];
        [dictVeriryGet5Fields setValue:@"iwatch_eraser" forKey:@"machine_type"];
        
        //Create machine info package
        NSError *errVerifyGet5Fields;
        NSData *jsonVerifyGet5Fields = [NSJSONSerialization dataWithJSONObject:dictGet5Fields options:NSJSONWritingPrettyPrinted error:&errVerifyGet5Fields];
        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] jsonVerifyGet5Fields JSON = %@", [[NSString alloc] initWithData:jsonVerifyGet5Fields encoding:NSUTF8StringEncoding]);
        
        
        //Create update information machine
        NSMutableDictionary *dictUpdateMachineInfo = [[NSMutableDictionary alloc]init];
        [dictUpdateMachineInfo setValue:@(30) forKey:@"command"];
        [dictUpdateMachineInfo setValue:@"mac_address" forKey:@"action"];
        [dictUpdateMachineInfo setValue:@"save" forKey:@"type"];
        [dictUpdateMachineInfo setValue:stationSN forKey:@"stationsn"];
        [dictUpdateMachineInfo setValue:macAddress forKey:@"mac_address"];
        [dictUpdateMachineInfo setValue:@"N/A" forKey:@"teamviewerID"];
        [dictUpdateMachineInfo setValue:[self getIPAddress] forKey:@"ip_address"];
        [dictUpdateMachineInfo setValue:@"iwatch_eraser" forKey:@"machine_type"];
        
        //Create machine info package
        NSError *errUpdateMachineInfo;
        NSData *jsonUpdateMachineInfo = [NSJSONSerialization dataWithJSONObject:dictUpdateMachineInfo options:NSJSONWritingPrettyPrinted error:&errUpdateMachineInfo];
        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] jsonUpdateMachineInfo JSON = %@", [[NSString alloc] initWithData:jsonUpdateMachineInfo encoding:NSUTF8StringEncoding]);
        
        
        //Create device mapping package
        NSMutableDictionary *dictDeviceMapping = [[NSMutableDictionary alloc]init];
        [dictDeviceMapping setValue:@(1) forKey:@"modelsystem"];
        [dictDeviceMapping setValue:@(5) forKey:@"prversion"];
        [dictDeviceMapping setValue:@(16) forKey:@"command"];
        [dictDeviceMapping setValue:@(0) forKey:@"status"];
        [dictDeviceMapping setValue:stationSN forKey:@"stationsn"];
        //[dictDeviceMapping setValue:@"9801A79D664B" forKey:@"stationsn"];
        [dictDeviceMapping setValue:@(99) forKey:@"key"];
        [dictDeviceMapping setValue:@"iwatch_eraser" forKey:@"machine_type"];
        
        //Create device mapping verify package
        NSMutableDictionary *dictDeviceMappingVerify = [[NSMutableDictionary alloc]init];
        [dictDeviceMappingVerify setValue:@(1) forKey:@"modelsystem"];
        [dictDeviceMappingVerify setValue:@(5) forKey:@"prversion"];
        [dictDeviceMappingVerify setValue:@(17) forKey:@"command"];
        [dictDeviceMappingVerify setValue:@(0) forKey:@"status"];
        [dictDeviceMappingVerify setValue:stationSN forKey:@"stationsn"];
        //[dictDeviceMappingVerify setValue:@"9801A79D664B" forKey:@"stationsn"];
        [dictDeviceMappingVerify setValue:@(99) forKey:@"key"];
        [dictDeviceMappingVerify setValue:@"iwatch_eraser" forKey:@"machine_type"];
        [dictDeviceMappingVerify setValue:@(1) forKey:@"type"];
        
        
        //Create link server verify package
        NSMutableDictionary *dictLinkServerVerify = [[NSMutableDictionary alloc]init];
        [dictLinkServerVerify setValue:@(1) forKey:@"modelsystem"];
        [dictLinkServerVerify setValue:@(5) forKey:@"prversion"];
        [dictLinkServerVerify setValue:@(17) forKey:@"command"];
        [dictLinkServerVerify setValue:@(0) forKey:@"status"];
        [dictLinkServerVerify setValue:stationSN forKey:@"stationsn"];
        //[dictLinkServerVerify setValue:@"9801A79D664B" forKey:@"stationsn"];
        [dictLinkServerVerify setValue:@(99) forKey:@"key"];
        [dictLinkServerVerify setValue:@"iwatch_eraser" forKey:@"machine_type"];
        [dictLinkServerVerify setValue:@(0) forKey:@"type"];
        
        NSError *errMappingVerify;
        NSData *jsonDataMappingVerify = [NSJSONSerialization dataWithJSONObject:dictDeviceMappingVerify options:NSJSONWritingPrettyPrinted error:&errMappingVerify];
        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] jsonDataMappingVerify JSON = %@", [[NSString alloc] initWithData:jsonDataMappingVerify encoding:NSUTF8StringEncoding]);
        
        //Create machine info package
        NSError *errMapping;
        NSData *jsonDataMapping = [NSJSONSerialization dataWithJSONObject:dictDeviceMapping options:NSJSONWritingPrettyPrinted error:&errMapping];
        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] jsonDataMapping JSON = %@", [[NSString alloc] initWithData:jsonDataMapping encoding:NSUTF8StringEncoding]);
        
        //Create package to sync users login
        /*
         {"action" : "iwatch_eraser_sync_user","checksum" : 0,"stationsn" : "9801A79D664B","modelsystem" : 1,"machine_type" : "iwatch_eraser","command" : 30,"prversion" : 4,"push" : "get"}
         */
        NSMutableDictionary *dictSyncUsersLogin = [[NSMutableDictionary alloc]init];
        [dictSyncUsersLogin setValue:@(30) forKey:@"command"];
        [dictSyncUsersLogin setValue:@(0) forKey:@"checksum"];
        [dictSyncUsersLogin setValue:stationSN forKey:@"stationsn"];
        [dictSyncUsersLogin setValue:@(1) forKey:@"modelsystem"];
        [dictSyncUsersLogin setValue:@(4) forKey:@"prversion"];
        [dictSyncUsersLogin setValue:@"get" forKey:@"push"];
        [dictSyncUsersLogin setValue:@"iwatch_eraser_sync_user" forKey:@"action"];
        [dictSyncUsersLogin setValue:@"iwatch_eraser" forKey:@"machine_type"];
        
        NSError *errSyncUsersLogin;
        NSData *jsonDataSyncUserLogin = [NSJSONSerialization dataWithJSONObject:dictSyncUsersLogin options:NSJSONWritingPrettyPrinted error:&errSyncUsersLogin];
        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Sync User Login] jsonDataSyncUserLogin JSON = %@", [[NSString alloc] initWithData:jsonDataSyncUserLogin encoding:NSUTF8StringEncoding]);
        
        
        //Create package to sync users login verify
        /*
         {"action" : "iwatch_eraser_sync_user","checksum" : 0,"stationsn" : "9801A79D664B","modelsystem" : 1,"machine_type" : "iwatch_eraser","command" : 30,"prversion" : 4,"push" : "verify","status" : 1}
         */
        NSMutableDictionary *dictSyncUsersLoginVerify = [[NSMutableDictionary alloc]init];
        [dictSyncUsersLoginVerify setValue:@(30) forKey:@"command"];
        [dictSyncUsersLoginVerify setValue:@(0) forKey:@"checksum"];
        [dictSyncUsersLoginVerify setValue:stationSN forKey:@"stationsn"];
        [dictSyncUsersLoginVerify setValue:@(1) forKey:@"modelsystem"];
        [dictSyncUsersLoginVerify setValue:@(4) forKey:@"prversion"];
        [dictSyncUsersLoginVerify setValue:@"verify" forKey:@"push"];
        [dictSyncUsersLoginVerify setValue:@(1) forKey:@"status"];
        [dictSyncUsersLoginVerify setValue:@"iwatch_eraser_sync_user" forKey:@"action"];
        [dictSyncUsersLoginVerify setValue:@"iwatch_eraser" forKey:@"machine_type"];
        
        NSError *errSyncUsersLoginVerify;
        NSData *jsonDataSyncUserLoginVerify = [NSJSONSerialization dataWithJSONObject:dictSyncUsersLogin options:NSJSONWritingPrettyPrinted error:&errSyncUsersLoginVerify];
        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Sync User Login] jsonDataSyncUserLoginVerify JSON = %@", [[NSString alloc] initWithData:jsonDataSyncUserLoginVerify encoding:NSUTF8StringEncoding]);
        NSMutableDictionary *dic;
        NSDictionary *version;
        NSString *fwVersion;
        NSString *hwVersion;
        NSURL *URL;
        AFHTTPSessionManager *manager;
        NSError *err;
        NSData *jsonDataMachineInfo;
        
        while (TRUE)
        {
            NSLog(@"Thread 30(s) Asks server to download SW & FW %lu", (unsigned long)arrayBoard.count);
            if (arrayBoard.count > 0) {
                hwVersionMain = @"";
                fwVersionMain = @"";
                
                for (int i = 0; i < arrayBoard.count; i++)
                {
                    if (dic == nil) {
                        dic = [arrayBoard objectAtIndex:i];
                    }
                    
                    
                    NSLog(@"[runCheckDownloadSW_FW] dicTemp: %@", dic);
                    if (version == nil) {
                        version = [dic objectForKey:@"VersionHW"];
                    }
                    if (fwVersion == nil) {
                        fwVersion = [version objectForKey:@"firmware"];
                    }
                    if (hwVersion == nil) {
                        hwVersion = [version objectForKey:@"hardware"];
                    }
                    NSLog(@"[runCheckDownloadSW_FW] hwVersion: %@", hwVersion);
                    NSLog(@"[runCheckDownloadSW_FW] fwVersion: %@", fwVersion);
                    if (fwVersion != nil) {
                        arrVersionFW[i] = fwVersion;
                        
                        if ([fwVersionMain  isEqual: @""])
                        {
                            fwVersionMain = [fwVersionMain stringByAppendingString:fwVersion];
                        }
                        else {
                            fwVersionMain = [fwVersionMain stringByAppendingFormat:@"; %@" , fwVersion];
                        }
                    }
                    
                    if (hwVersion != nil) {
                        if ([hwVersionMain  isEqual: @""])
                        {
                            hwVersionMain = [hwVersionMain stringByAppendingString:hwVersion];
                        }
                        else {
                            hwVersionMain = [hwVersionMain stringByAppendingFormat:@"; %@", hwVersion];
                        }
                    }
                    
                }
                hwVersionSendAbout = hwVersionMain;
                fwVersionSendAbout = fwVersionMain;
                NSLog(@"[runCheckDownloadSW_FW] hwVersionMain: %@", hwVersionMain);
                NSLog(@"[runCheckDownloadSW_FW] fwVersionMain: %@", fwVersionMain);
            }
            
            
            if (sendRequestSyncUserLoginVerify) {
                //Send package to sync user login verify
                int sizeOfarrPushingList = arrPushingListMain.count - 1;
                NSLog(@"[runCheckDownloadSW_FW] [Sync User Login Verify] sizeOfarrPushingList: %d", sizeOfarrPushingList);
                
                if (sizeOfarrPushingList > 1) {
                    int randomNumber = [self getRandomNumberBetween:0 and:sizeOfarrPushingList];
                    linkServer = arrPushingListMain[randomNumber];
                } else if (sizeOfarrPushingList == 1) {
                    linkServer = arrPushingListMain[0];
                }
                
                NSLog(@"[runCheckDownloadSW_FW] [Sync User Login Verify] linkServer: %@", linkServer);
                
                
              
                
                NSLog(@"[runCheckDownloadSW_FW] [Sync User Login Verify] REAL linkServer: %@", linkServer);
                if (URL == nil) {
                    URL = [NSURL URLWithString:linkServer];
                }
                
                //2 - create AFNetwork manager
                if (manager == nil) {
                    manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                }
                
                //manager.requestSerializer = [AFJSONRequestSerializer serializer];
                //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                //3 - set a body
                //4 - create request
                [manager POST: URL.absoluteString
                   parameters: dictSyncUsersLoginVerify
                     progress: nil
                 //5 - response handling
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    @try {
                        if (jsonStringResponseUserLogin == nil) {
                            jsonStringResponseUserLogin = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                            NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Sync User Login Verify] jsonStringResponseUserLogin: %@", jsonStringResponseUserLogin);
                        }
                        
                        if (dataUserLogin == nil) {
                            dataUserLogin = [jsonStringResponseUserLogin dataUsingEncoding:NSUTF8StringEncoding];
                        }
                        
                        
                        
                        id json = [NSJSONSerialization JSONObjectWithData:dataUserLogin options:0 error:nil];
                        
                        if([json objectForKey:@"stationsn"] != nil) {
                            if ([json objectForKey:@"stationsn"] == stationSN) {
                                if([json objectForKey:@"status"] != nil) {
                                    if([json objectForKey:@"status"] == [NSNumber numberWithInt:1]) {
                                        sendRequestSyncUserLoginVerify = FALSE;
                                        sendRequestSyncUserLogin = FALSE;
                                    }
                                }
                            }
                        }
                        
                    }
                    @catch (NSException *exception) {
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Sync User Login Verify] NSException exception.reason: %@", exception.reason);
                    }
                    @finally {
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Sync User Login Verify] Finally condition");
                    }
                }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"[GetServer][NSURLSessionDataTask] [Sync User Login Verify] error: %@", error);
                }
                ];
            }
            
            //            if (sendRequestVerifyGet5Fields == TRUE) {
            //                int sizeOfarrPushingList = arrPushingListMain.count - 1;
            //                if (sizeOfarrPushingList > 1) {
            //                    int randomNumber = [self getRandomNumberBetween:0 and:sizeOfarrPushingList];
            //                    linkServer = arrPushingListMain[randomNumber];
            //                } else if (sizeOfarrPushingList == 1) {
            //                    linkServer = arrPushingListMain[0];
            //                }
            //                NSLog(@"[runCheckDownloadSW_FW] [Verify Get 5 Fields] linkServer: %@", linkServer);
            //                if (URL == nil) {
            //                    URL = [NSURL URLWithString:linkServer];
            //                }
            //                //2 - create AFNetwork manager
            //                if (manager == nil) {
            //                    manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            //                }
            //
            //                manager.requestSerializer = [AFJSONRequestSerializer serializer];
            //                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            //
            //                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            //                //3 - set a body
            //                //4 - create request
            //                [manager POST: URL.absoluteString
            //                   parameters: dictVeriryGet5Fields
            //                     progress: nil
            //                 //5 - response handling
            //                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //                    @try {
            //
            //                        if (jsonStringResponseGet5Fields == nil) {
            //                            jsonStringResponseVerifyGet5Fields = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            //                        }
            //                        if (dataVerifyGet5Fields == nil) {
            //                            dataVerifyGet5Fields = [jsonStringResponseVerifyGet5Fields dataUsingEncoding:NSUTF8StringEncoding];
            //                        }
            //                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask][Verify Get 5 Fields] jsonStringResponseVerifyGet5Fields: %@", jsonStringResponseVerifyGet5Fields);
            //                        sendRequestVerifyGet5Fields = FALSE
            //                    }
            //                    @catch (NSException *exception) {
            //                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask][Verify Get 5 Fields] NSException exception.reason: %@", exception.reason);
            //                    }
            //                    @finally {
            //                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask][Verify Get 5 Fields] Finally condition");
            //                    }
            //                }
            //                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //                    NSLog(@"[GetServer][NSURLSessionDataTask][Verify Get 5 Fields] error: %@", error);
            //                }
            //                ];
            //            }
            
            
            if (sendRequestGet5Fields == FALSE) {
                sendRequestGet5Fields = TRUE;
                int sizeOfarrPushingList = arrPushingListMain.count - 1;
                if (sizeOfarrPushingList > 1) {
                    int randomNumber = [self getRandomNumberBetween:0 and:sizeOfarrPushingList];
                    linkServer = arrPushingListMain[randomNumber];
                } else if (sizeOfarrPushingList == 1) {
                    linkServer = arrPushingListMain[0];
                }
                NSLog(@"[runCheckDownloadSW_FW] [Get 5 Fields] linkServer: %@", linkServer);
                if (URL == nil) {
                    URL = [NSURL URLWithString:linkServer];
                }
                //2 - create AFNetwork manager
                if (manager == nil) {
                    manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                }
                //manager.requestSerializer = [AFJSONRequestSerializer serializer];
                //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                //3 - set a body
                //4 - create request
                [manager POST: URL.absoluteString
                   parameters: dictGet5Fields
                     progress: nil
                 //5 - response handling
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    @try {
                        
                        if (jsonStringResponseGet5Fields == nil) {
                            jsonStringResponseGet5Fields = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                        }
                        if (dataGet5Fields == nil) {
                            dataGet5Fields = [jsonStringResponseGet5Fields dataUsingEncoding:NSUTF8StringEncoding];
                        }
                        
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask][Get 5 Fields] jsonStringResponseGet5Fields: %@", jsonStringResponseGet5Fields);
                        id json = [NSJSONSerialization JSONObjectWithData:dataGet5Fields options:0 error:nil];
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask][Get 5 Fields] [json objectForKey:@\"data\"]: %@", [json objectForKey:@"data"]);
                        
                        if([json objectForKey:@"data"] != nil)  {
                            @try {
                                NSString *strBatchNumber = [[json objectForKey:@"data"] objectForKey:@"batch_number"];
                                NSString *strWorkArea = [[json objectForKey:@"data"] objectForKey:@"work_area"];
                                NSString *strLineNumber = [[json objectForKey:@"data"] objectForKey:@"line_number"];
                                NSString *strUsername = [[json objectForKey:@"data"] objectForKey:@"user_name"];
                                NSString *strLocation = [[json objectForKey:@"data"] objectForKey:@"location"];
                                if (strBatchNumber != NULL) {
                                    NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW][Get 5 Fields] strBatchNumber: %@", strBatchNumber);
                                } else {
                                    strBatchNumber = @"";
                                }
                                if (strWorkArea != NULL) {
                                    NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW][Get 5 Fields] strWorkArea: %@", strWorkArea);
                                } else {
                                    strWorkArea = @"";
                                }
                                if (strUsername != NULL) {
                                    NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW][Get 5 Fields] strUsername: %@", strUsername);
                                } else {
                                    strUsername = @"";
                                }
                                if (strLocation != NULL) {
                                    NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW][Get 5 Fields] strLocation: %@", strLocation);
                                } else {
                                    strLocation = @"";
                                }
                                if (strLineNumber != NULL) {
                                    NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW][Get 5 Fields] strBatchNumber: %@", strLineNumber);
                                } else {
                                    strLineNumber = @"";
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (![strBatchNumber  isEqual: @""]) {
                                        txtBatchInfo.stringValue = strBatchNumber;
                                        txtBatchInfo.editable = false;
                                    }
                                    if (![strLocation  isEqual: @""]) {
                                        txtLocationInfo.stringValue = strLocation;
                                        txtLocationInfo.editable = false;
                                    }
                                    if (![strWorkArea  isEqual: @""]) {
                                        txtWorkAreaInfo.stringValue = strWorkArea;
                                        txtWorkAreaInfo.editable = false;
                                    }
                                    if (![strLineNumber  isEqual: @""]) {
                                        txtLineNumberInfo.stringValue = strLineNumber;
                                        txtLineNumberInfo.editable = false;
                                    }
                                    if (![strUsername  isEqual: @""]) {
                                        txtUserNameInfo.stringValue = strUsername;
                                        txtUserNameInfo.editable = false;
                                    }
                                });
                                sendRequestVerifyGet5Fields = TRUE;
                            }
                            @catch (NSException *exception) {
                                NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW][Get 5 Fields] Reply NSException exception.reason: %@", exception.reason);
                            }
                            @finally {
                                NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW][Get 5 Fields] Reply Finally condition");
                            }
                        }
                    }
                    @catch (NSException *exception) {
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask][Get 5 Fields] NSException exception.reason: %@", exception.reason);
                    }
                    @finally {
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask][Get 5 Fields] Finally condition");
                    }
                }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"[GetServer][NSURLSessionDataTask][Get 5 Fields] error: %@", error);
                }
                ];
            }
            
            if (!sendRequestSyncUserLogin) {
                sendRequestSyncUserLogin = TRUE;
                //Send package to sync user login
                int sizeOfarrPushingList = arrPushingListMain.count - 1;
                NSLog(@"[runCheckDownloadSW_FW] [Sync User Login] sizeOfarrPushingList: %d", sizeOfarrPushingList);
                
                if (sizeOfarrPushingList > 1) {
                    int randomNumber = [self getRandomNumberBetween:0 and:sizeOfarrPushingList];
                    linkServer = arrPushingListMain[randomNumber];
                } else if (sizeOfarrPushingList == 1) {
                    linkServer = arrPushingListMain[0];
                }
                
                NSLog(@"[runCheckDownloadSW_FW] [Sync User Login] linkServer: %@", linkServer);
                
                
               
                
                NSLog(@"[runCheckDownloadSW_FW] [Sync User Login] REAL linkServer: %@", linkServer);
                
                if (URL == nil) {
                    URL = [NSURL URLWithString:linkServer];
                }
                //2 - create AFNetwork manager
                if (manager == nil) {
                    manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                }
                //manager.requestSerializer = [AFJSONRequestSerializer serializer];
                //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                //3 - set a body
                //4 - create request
                [manager POST: URL.absoluteString
                   parameters: dictSyncUsersLogin
                     progress: nil
                 //5 - response handling
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    @try {
                        
                        if (jsonStringResponseSyncUserLoginNew == nil) {
                            jsonStringResponseSyncUserLoginNew = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                        }
                        if (dataSyncUserLoginNew == nil) {
                            dataSyncUserLoginNew = [jsonStringResponseSyncUserLoginNew dataUsingEncoding:NSUTF8StringEncoding];
                        }
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Sync User Login] jsonStringResponseSyncUserLoginNew: %@", jsonStringResponseSyncUserLoginNew);
                        
                        id json = [NSJSONSerialization JSONObjectWithData:dataSyncUserLoginNew options:0 error:nil];
                        if([json objectForKey:@"data"] != nil) {
                            @try {
                                NSString *strDataUsers = [json objectForKey:@"data"];
                                strDataUsers = [strDataUsers stringByReplacingOccurrencesOfString:@"/\""withString:@"\""];
                                NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Sync User Login] preprocess dataUsers : %@", strDataUsers);
                                NSData *dataUsers = [strDataUsers dataUsingEncoding:NSUTF8StringEncoding];
                                if (arrUserObject == nil) {
                                    arrUserObject = [[NSMutableArray alloc] init];
                                }
                                arrUserObject = [NSJSONSerialization JSONObjectWithData:dataUsers options:NSJSONReadingMutableContainers error:nil];
                                NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Sync User Login] preprocess dataUsers arrUserObject : %@", arrUserObject);
                                for (int i = 0; i < arrUserObject.count; i++) {
                                    NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Sync User Login] preprocess dataUsers arrUserObject : %@", arrUserObject[i]);
                                    
                                    RLMRealm *realm = RLMRealm.defaultRealm;
                                    if (realm.inWriteTransaction) {
                                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask][Sync User Login] inWriteTransaction");
                                        sendRequestSyncUserLoginVerify = FALSE;
                                        return;
                                    }
                                    NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask][Sync User Login] => beginWriteTransaction");
                                    
                                    [realm beginWriteTransaction];
                                    UserLogin *mUserLogin = [[UserLogin alloc] init];
                                    mUserLogin.cloudid = [arrUserObject[i] objectForKey:@"cloudid"];
                                    mUserLogin.username = [arrUserObject[i] objectForKey:@"username"];
                                    mUserLogin.password = [arrUserObject[i] objectForKey:@"password"];
                                    mUserLogin.isdelete = [arrUserObject[i] objectForKey:@"isdelete"];
                                    mUserLogin.privilege = [arrUserObject[i] objectForKey:@"privilege"];
                                    [realm addOrUpdateObject:mUserLogin];
                                    [realm commitWriteTransaction];
                                }
                                sendRequestSyncUserLoginVerify = TRUE;
                            }
                            @catch (NSException *exception) {
                                NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW] [Sync User Login] Reply NSException exception.reason: %@", exception.reason);
                            }
                            @finally {
                                NSLog(@"[NSURLSessionDataTask][runCheckDownloadSW_FW] [Sync User Login] Reply Finally condition");
                            }
                        }
                    }
                    @catch (NSException *exception) {
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Sync User Login] NSException exception.reason: %@", exception.reason);
                    }
                    @finally {
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Sync User Login] Finally condition");
                    }
                }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"[GetServer][NSURLSessionDataTask] [Sync User Login] error: %@", error);
                }
                ];
            }
            
            if (dictMachineInfo == nil) {
                dictMachineInfo = [[NSMutableDictionary alloc]init];
            } else {
                [dictMachineInfo setValue:@"iwatch_eraser" forKey:@"machine_type"];
                [dictMachineInfo setValue:stationSN forKey:@"stationsn"];
                [dictMachineInfo setValue:@(30) forKey:@"command"];
                [dictMachineInfo setValue:@(4) forKey:@"prversion"];
                [dictMachineInfo setValue:VERSION forKey:@"software_version"];
                [dictMachineInfo setValue:fwVersionMain forKey:@"firmware_version"];
                [dictMachineInfo setValue:hwVersionMain forKey:@"hardware_version"];
                [dictMachineInfo setValue:@"machine_version_log" forKey:@"action"];
                [dictMachineInfo setValue:@(0) forKey:@"checksum"];
                [dictMachineInfo setValue:@(1) forKey:@"modelsystem"];
                [dictMachineInfo setValue:@(0) forKey:@"status"];
            }
            
            //        [dictMachineInfo setValue:@"iwatch_eraser" forKey:@"machine_type"];
            //        [dictMachineInfo setValue:stationSN forKey:@"stationsn"];
            //        [dictMachineInfo setValue:@(30) forKey:@"command"];
            //        [dictMachineInfo setValue:@(4) forKey:@"prversion"];
            //        [dictMachineInfo setValue:VERSION forKey:@"software_version"];
            //        [dictMachineInfo setValue:fwVersionMain forKey:@"firmware_version"];
            //        [dictMachineInfo setValue:hwVersionMain forKey:@"hardware_version"];
            //        [dictMachineInfo setValue:@"machine_version_log" forKey:@"action"];
            //        [dictMachineInfo setValue:@(0) forKey:@"checksum"];
            //        [dictMachineInfo setValue:@(1) forKey:@"modelsystem"];
            //        [dictMachineInfo setValue:@(0) forKey:@"status"];
            
            if (jsonDataMachineInfo == nil) {
                jsonDataMachineInfo = [NSJSONSerialization dataWithJSONObject:dictMachineInfo options:NSJSONWritingPrettyPrinted error:&err];
            }
            
            NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] machine info JSON = %@", jsonDataMachineInfo);
            
            if (!sendUpdateMachineInfo) {
                //update information machine
                int sizeOfarrPushingList = arrPushingListMain.count - 1;
                NSLog(@"[runCheckDownloadSW_FW] [Update information machine] sizeOfarrPushingList: %d", sizeOfarrPushingList);
                
                if (sizeOfarrPushingList > 1) {
                    int randomNumber = [self getRandomNumberBetween:0 and:sizeOfarrPushingList];
                    linkServer = arrPushingListMain[randomNumber];
                } else if (sizeOfarrPushingList == 1) {
                    linkServer = arrPushingListMain[0];
                }
                
                NSLog(@"[runCheckDownloadSW_FW] [Update information machine] linkServer: %@", linkServer);
                
                
               
                
                NSLog(@"[runCheckDownloadSW_FW] [Update information machine] REAL linkServer: %@", linkServer);
                
                if (URL == nil) {
                    URL = [NSURL URLWithString:linkServer];
                }
                //2 - create AFNetwork manager
                if (manager == nil) {
                    manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                }
                
                //manager.requestSerializer = [AFJSONRequestSerializer serializer];
                //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                //3 - set a body
                //4 - create request
                [manager POST: URL.absoluteString
                   parameters: dictUpdateMachineInfo
                     progress: nil
                 //5 - response handling
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    @try {
                        if (jsonStringResponseUpdateMachineInfo != nil) {
                            NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Update information machine] jsonStringResponseUpdateMachineInfo: %@", jsonStringResponseUpdateMachineInfo);
                        }
//                        if (jsonStringResponseUpdateMachineInfo == nil) {
//                            jsonStringResponseUpdateMachineInfo = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//                        }
                        jsonStringResponseUpdateMachineInfo = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Update information machine] jsonStringResponseUpdateMachineInfo: %@", jsonStringResponseUpdateMachineInfo);
                        //if (dataUpdateMachineInfo == nil) {
                            dataUpdateMachineInfo = [jsonStringResponseUpdateMachineInfo dataUsingEncoding:NSUTF8StringEncoding];
                        //}
                        //software
                        id json = [NSJSONSerialization JSONObjectWithData:dataUpdateMachineInfo options:0 error:nil];
                        if([json objectForKey:@"status"] != nil) {
                            
                            NSString *status = [json objectForKey:@"status"];
                            if ([status  isEqual: @"OK"]) {
                                //sendMachineInfo = TRUE;
                            }
                        }
                    }
                    @catch (NSException *exception) {
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Update information machine] NSException exception.reason: %@", exception.reason);
                    }
                    @finally {
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Update information machine] Finally condition");
                    }
                }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"[GetServer][NSURLSessionDataTask] [Update information machine] error: %@", error);
                }
                ];
            }
            
            
            if(sendLinkServerVerify) {
                int sizeOfarrPushingList = arrPushingListMain.count - 1;
                NSLog(@"[runCheckDownloadSW_FW] [Link-Server-Verify] sizeOfarrPushingList: %d", sizeOfarrPushingList);
                
                if (sizeOfarrPushingList > 1) {
                    int randomNumber = [self getRandomNumberBetween:0 and:sizeOfarrPushingList];
                    linkServer = arrPushingListMain[randomNumber];
                } else if (sizeOfarrPushingList == 1) {
                    linkServer = arrPushingListMain[0];
                }
                
               
                NSLog(@"[runCheckDownloadSW_FW] [Link-Server-Verify] linkServerBackup: %@", linkServerBackup);
                
                if (URL == nil) {
                    URL = [NSURL URLWithString:linkServer];
                }
                //2 - create AFNetwork manager
                if (manager == nil) {
                    manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                }
                
                //manager.requestSerializer = [AFJSONRequestSerializer serializer];
                //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                //3 - set a body
                //4 - create request
                [manager POST: URL.absoluteString
                   parameters: dictLinkServerVerify
                     progress: nil
                 //5 - response handling
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    @try {
                        if (jsonStringResponseLinkServerVerify == nil) {
                            jsonStringResponseLinkServerVerify = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                        }
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Link-Server-Verify] jsonStringResponseLinkServerVerify: %@", jsonStringResponseLinkServerVerify);
                        if (dataLinkServerVerify == nil) {
                            dataLinkServerVerify = [jsonStringResponseLinkServerVerify dataUsingEncoding:NSUTF8StringEncoding];
                        }
                        //software
                        id json = [NSJSONSerialization JSONObjectWithData:dataLinkServerVerify options:0 error:nil];
                        sendLinkServerVerify = FALSE;
                    }
                    @catch (NSException *exception) {
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Link-Server-Verify] NSException exception.reason: %@", exception.reason);
                    }
                    @finally {
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Link-Server-Verify] Finally condition");
                    }
                }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"[GetServer][NSURLSessionDataTask] [Link-Server-Verify] error: %@", error);
                }
                ];
            }
            
            if (!sendMapping) {
                int sizeOfarrPushingList = arrPushingListMain.count - 1;
                NSLog(@"[runCheckDownloadSW_FW] [Device-Mapping] sizeOfarrPushingList: %d", sizeOfarrPushingList);
                
                if (sizeOfarrPushingList > 1) {
                    int randomNumber = [self getRandomNumberBetween:0 and:sizeOfarrPushingList];
                    linkServer = arrPushingListMain[randomNumber];
                } else if (sizeOfarrPushingList == 1) {
                    linkServer = arrPushingListMain[0];
                }
                
              
                linkServerBackup = linkServer;
                if (URL == nil) {
                    URL = [NSURL URLWithString:linkServer];
                }
                //2 - create AFNetwork manager
                if (manager == nil) {
                    manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                }
                
                //manager.requestSerializer = [AFJSONRequestSerializer serializer];
                //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                //3 - set a body
                //4 - create request
                [manager POST: URL.absoluteString
                   parameters: dictDeviceMapping
                     progress: nil
                 //5 - response handling
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    @try {
                        if (jsonStringResponseDeviceMapping == nil) {
                            jsonStringResponseDeviceMapping = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                        }
                        
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Device-Mapping] jsonStringResponseDeviceMapping: %@", jsonStringResponseDeviceMapping);
                        
                        if (dataDeviceMapping == nil) {
                            dataDeviceMapping = [jsonStringResponseDeviceMapping dataUsingEncoding:NSUTF8StringEncoding];
                        }
                        
                        //software
                        id json = [NSJSONSerialization JSONObjectWithData:dataDeviceMapping options:0 error:nil];
                        
                        
                        if ([json objectForKey:@"type"] != nil) {
                            if (mapType == nil) {
                                mapType = [json objectForKey:@"type"];
                            }
                            
                            int typeIndex = [mapType intValue];
                            //[runCheckDownloadSW_FW][NSURLSessionDataTask] [Device-Mapping] jsonStringResponse: {"stationsn":"9801A79D664B","modelsystem":1,"prversion":5,"command":16,"status":0,"type":1,"filename":"gds_mobile_table_carrier.sql","serverpath":"\/Mini-ZeroIT\/Setting","clientpath":"\/ZeroIT","ftpserver":"cloud.greystonedatatech.com","ftpport":"21","ftpusername":"ftpupload","ftppassword":"123Qwe!@#","checksum":256,"key":99}
                            if (typeIndex == 1) {
                                ftpServer = [json objectForKey:@"ftpserver"];
                                ftpServerPath = [json objectForKey:@"serverpath"];
                                ftpClientPath = [json objectForKey:@"clientpath"];
                                ftpFilename = [json objectForKey:@"filename"];
                                ftpPort = [json objectForKey:@"ftpport"];
                                ftpUsername = [json objectForKey:@"ftpusername"];
                                ftpPassword = [json objectForKey:@"ftppassword"];
                                
                                NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Device-Mapping] ftpServer: %@", ftpServer);
                                NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Device-Mapping] ftpServerPath: %@", ftpServerPath);
                                NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Device-Mapping] ftpClientPath: %@", ftpClientPath);
                                NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Device-Mapping] ftpFilename: %@", ftpFilename);
                                NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Device-Mapping] ftpPort: %@", ftpPort);
                                NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Device-Mapping] ftpUsername: %@", ftpUsername);
                                NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Device-Mapping] ftpPassword: %@", ftpPassword);
                                
                                isDownloadingSQLMapping = TRUE;
                                sendMapping = TRUE;
                            } else if (typeIndex == 0) {
                                if([json objectForKey:@"pushinglist"] != nil) {
                                    arrPushingListMain = [json objectForKey:@"pushinglist"];
                                    //Update Link Database
                                    NSLog(@"[runCheckDownloadSW_FW][GetServer][NSURLSessionDataTask] arrPushingListMain.count: %lu", (unsigned long)arrPushingListMain.count);
                                    if (arrPushingListMain.count > 0) {
                                        //NSError *error = nil;
                                        //RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
                                        //RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:&error];
                                        RLMRealm *realm = [RLMRealm defaultRealm];
                                        for(int i = 0; i < arrPushingListMain.count; i++) {
                                            NSLog(@"[runCheckDownloadSW_FW][GetServer][NSURLSessionDataTask] arrPushingListMain[i] %@", arrPushingListMain[i]);
                                            if (realm.inWriteTransaction) {
                                                NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask][arrPushingListMain] inWriteTransaction");
                                                sendLinkServerVerify = FALSE;
                                                return;
                                            }
                                            [realm beginWriteTransaction];
                                            LinkServer *mLinkServer = [[LinkServer alloc] init];
                                            mLinkServer.ID = [NSString stringWithFormat:@"%i", i];
                                            mLinkServer.linkServer = arrPushingListMain[i];
                                            NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] mLinkServer.ID: %@", mLinkServer.ID);
                                            NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] mLinkServer.linkServer: %@",  mLinkServer.linkServer);
                                            [realm addOrUpdateObject:mLinkServer];
                                            [realm commitWriteTransaction];
                                        }
                                    }
                                    
                                    NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] update Link Server DONE!!!");
                                    sendLinkServerVerify = TRUE;
                                    
                                } else {
                                    NSLog(@"[runCheckDownloadSW_FW][GetServer][NSURLSessionDataTask] Reply Couldn't parse status");
                                }
                            }
                            
                        }
                    }
                    @catch (NSException *exception) {
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Device-Mapping] NSException exception.reason: %@", exception.reason);
                    }
                    @finally {
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Device-Mapping] Finally condition");
                    }
                    
                    
                }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"[GetServer][NSURLSessionDataTask] [Device-Mapping] error: %@", error);
                }
                ];
                
            } else {
                if (sendDeviceMappingVerify) {
                    int sizeOfarrPushingList = arrPushingListMain.count - 1;
                    NSLog(@"[runCheckDownloadSW_FW] [Device-Mapping-Verify] sizeOfarrPushingList: %d", sizeOfarrPushingList);
                    
                    if (sizeOfarrPushingList > 1) {
                        int randomNumber = [self getRandomNumberBetween:0 and:sizeOfarrPushingList];
                        linkServer = arrPushingListMain[randomNumber];
                    } else if (sizeOfarrPushingList == 1) {
                        linkServer = arrPushingListMain[0];
                    }
                    
                   
                    if (URL == nil) {
                        URL = [NSURL URLWithString:linkServer];
                    }
                    //2 - create AFNetwork manager
                    if (manager == nil) {
                        manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                    }
                    
                    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
                    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
                    manager.requestSerializer = [AFJSONRequestSerializer serializer];
                    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                    
                    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    //3 - set a body
                    //4 - create request
                    [manager POST: URL.absoluteString
                       parameters: dictDeviceMappingVerify
                         progress: nil
                     //5 - response handling
                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        @try {
                            if (jsonStringResponseDeviceMappingVerify == nil) {
                                jsonStringResponseDeviceMappingVerify = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                            }
                            NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Device-Mapping-Verify] jsonStringResponseDeviceMappingVerify: %@", jsonStringResponseDeviceMappingVerify);
                            
                            if (dataDeviceMappingVerify == nil) {
                                dataDeviceMappingVerify = [jsonStringResponseDeviceMappingVerify dataUsingEncoding:NSUTF8StringEncoding];
                            }
                            //software
                            id json = [NSJSONSerialization JSONObjectWithData:dataDeviceMappingVerify options:0 error:nil];
                            isDownloadingSQLMapping = FALSE;
                            sendMapping = FALSE;
                            sendDeviceMappingVerify = FALSE;
                        }
                        @catch (NSException *exception) {
                            NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Device-Mapping-Verify] NSException exception.reason: %@", exception.reason);
                        }
                        @finally {
                            NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Device-Mapping-Verify] Finally condition");
                        }
                    }
                          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        NSLog(@"[GetServer][NSURLSessionDataTask] [Device-Mapping-Verify] error: %@", error);
                    }
                    ];
                }
                
                
                if (!sendMachineInfo) {
                    int sizeOfarrPushingList = arrPushingListMain.count - 1;
                    NSLog(@"[runCheckDownloadSW_FW] [Machine Info] sizeOfarrPushingList: %d", sizeOfarrPushingList);
                    
                    if (sizeOfarrPushingList > 1) {
                        int randomNumber = [self getRandomNumberBetween:0 and:sizeOfarrPushingList];
                        linkServer = arrPushingListMain[randomNumber];
                    } else if (sizeOfarrPushingList == 1) {
                        linkServer = arrPushingListMain[0];
                    }
                    
                    NSLog(@"[runCheckDownloadSW_FW] [Machine Info] linkServer: %@", linkServer);
                    
                    
                
                    
                    NSLog(@"[runCheckDownloadSW_FW] [Machine Info] REAL linkServer: %@", linkServer);
                    
                    if (URL == nil) {
                        URL = [NSURL URLWithString:linkServer];
                    }
                    //2 - create AFNetwork manager
                    if (manager == nil) {
                        manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                    }
                    
                    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
                    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
                    manager.requestSerializer = [AFJSONRequestSerializer serializer];
                    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                    
                    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    //3 - set a body
                    //4 - create request
                    [manager POST: URL.absoluteString
                       parameters: dictMachineInfo
                         progress: nil
                     //5 - response handling
                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        @try {
                            if (jsonStringResponseMachineInfo == nil) {
                                jsonStringResponseMachineInfo = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                            }
                            NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Machine Info] jsonStringResponse: %@", jsonStringResponseMachineInfo);
                            if (dataMachineInfo == nil) {
                                dataMachineInfo = [jsonStringResponseMachineInfo dataUsingEncoding:NSUTF8StringEncoding];
                            }
                            //software
                            id json = [NSJSONSerialization JSONObjectWithData:dataMachineInfo options:0 error:nil];
                            if([json objectForKey:@"status"] != nil) {
                                NSString *status = [json objectForKey:@"status"];
                                if ([status  isEqual: @"OK"]) {
                                }
                            }
                        }
                        @catch (NSException *exception) {
                            NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Machine Info] NSException exception.reason: %@", exception.reason);
                        }
                        @finally {
                            NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] [Machine Info] Finally condition");
                        }
                        
                        
                    }
                          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        NSLog(@"[GetServer][NSURLSessionDataTask] [Machine Info] error: %@", error);
                    }
                    ];
                }
            }
            
            if (!checkDownload)
            {
                if (dictDownloadSW_FW == nil) {
                    dictDownloadSW_FW = [[NSMutableDictionary alloc]init];
                } else {
                    [dictDownloadSW_FW removeAllObjects];
                }
                [dictDownloadSW_FW setValue:@(2) forKey:@"command"];
                [dictDownloadSW_FW setValue:@(0) forKey:@"checksum"];
                [dictDownloadSW_FW setValue:@"1.00" forKey:@"apps_version"];
                [dictDownloadSW_FW setValue:fwVersionMain forKey:@"firmware"];
                [dictDownloadSW_FW setValue:hwVersionMain forKey:@"hardware"];
                [dictDownloadSW_FW setValue:VERSION forKey:@"software"];
                [dictDownloadSW_FW setValue:stationSN forKey:@"stationsn"];
                [dictDownloadSW_FW setValue:@"1.0c;" forKey:@"key"];
                [dictDownloadSW_FW setValue:@"" forKey:@"manual_update"];
                [dictDownloadSW_FW setValue:@(1) forKey:@"modelsystem"];
                [dictDownloadSW_FW setValue:@(4) forKey:@"prversion"];
                [dictDownloadSW_FW setValue:@(0) forKey:@"status"];
                [dictDownloadSW_FW setValue:@"iwatch_eraser" forKey:@"machine_type"];
                
                
                //{ "apps_version" : "3.57", "checksum" : 0, "command" : 2, "firmware" : "2.2a;", "hardware" : "1.0c;", "key" : 1152, "machine_type":"iwatch_eraser","manual_update" : "", "modelsystem" : 1, "prversion" : 4, "software" : "STR.A16.88", "stationsn" : "10C37B9DC6DE", "status" : 0 }
                ///DEBUG
                //            [dictDownloadSW_FW setValue:@(2) forKey:@"command"];
                //            [dictDownloadSW_FW setValue:@(0) forKey:@"checksum"];
                //            [dictDownloadSW_FW setValue:@"3.57" forKey:@"apps_version"];
                //            [dictDownloadSW_FW setValue:@"2.2a;" forKey:@"firmware"];
                //            [dictDownloadSW_FW setValue:@"1.0c;" forKey:@"hardware"];
                //            [dictDownloadSW_FW setValue:@"STR.A16.88" forKey:@"software"];
                //            [dictDownloadSW_FW setValue:@"10C37B9DC6DE" forKey:@"stationsn"];
                //            [dictDownloadSW_FW setValue:@"1.0c;" forKey:@"key"];
                //            [dictDownloadSW_FW setValue:@"" forKey:@"manual_update"];
                //            [dictDownloadSW_FW setValue:@(1) forKey:@"modelsystem"];
                //            [dictDownloadSW_FW setValue:@(4) forKey:@"prversion"];
                //            [dictDownloadSW_FW setValue:@(0) forKey:@"status"];
                //            [dictDownloadSW_FW setValue:@"iwatch_eraser" forKey:@"machine_type"];
                ///END DEBUG
                
                if (jsonDataDownloadSW_FW == nil) {
                    jsonDataDownloadSW_FW = [NSJSONSerialization dataWithJSONObject:dictDownloadSW_FW options:NSJSONWritingPrettyPrinted error:&err];
                }
                NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] jsonDataDownloadSW_FW = %@", jsonDataDownloadSW_FW);
                NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] jsonDataDownloadSW_FW JSON = %@", [[NSString alloc] initWithData:jsonDataDownloadSW_FW encoding:NSUTF8StringEncoding]);
                // 1 - define resource URL
                
                int sizeOfarrPushingList = arrPushingListMain.count - 1;
                NSLog(@"[runCheckDownloadSW_FW] sizeOfarrPushingList: %d", sizeOfarrPushingList);
                
                if (sizeOfarrPushingList > 1) {
                    int randomNumber = [self getRandomNumberBetween:0 and:sizeOfarrPushingList];
                    linkServer = arrPushingListMain[randomNumber];
                } else if (sizeOfarrPushingList == 1) {
                    linkServer = arrPushingListMain[0];
                }
              
                if (URL == nil) {
                    URL = [NSURL URLWithString:linkServer];
                }
                //2 - create AFNetwork manager
                if (manager == nil) {
                    manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                }
                
                //manager.requestSerializer = [AFJSONRequestSerializer serializer];
                //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
                manager.requestSerializer = [AFJSONRequestSerializer serializer];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                //3 - set a body
                //4 - create request
                [manager POST: URL.absoluteString
                   parameters: dictDownloadSW_FW
                     progress: nil
                 //5 - response handling
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    @try {
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] responseObject: %@", responseObject);
                        if (jsonStringResponseDictDownloadSW_FW == nil) {
                            NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] jsonStringResponseDictDownloadSW_FW: NULL");
                        } else {
                            NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] jsonStringResponseDictDownloadSW_FW: NON NULL");
                        }
                        jsonStringResponseDictDownloadSW_FW = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                        dataDictDownloadSW_FW = [jsonStringResponseDictDownloadSW_FW dataUsingEncoding:NSUTF8StringEncoding];

                        
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] jsonStringResponseDictDownloadSW_FW %@", jsonStringResponseDictDownloadSW_FW);
                        
                        //software
                        id json = [NSJSONSerialization JSONObjectWithData:dataDictDownloadSW_FW options:0 error:nil];
                        
                        if([json objectForKey:@"customer"] != nil) {
                            customerName = [json objectForKey:@"customer"];
                        }
                        
                        if([json objectForKey:@"software"] != nil) {
                            //VERSION SW == Jul 4 2022
                            NSString *currentVersionSW = VERSION;
                            NSString *assignVersionSW = [json objectForKey:@"software"];
                            NSString *assignVersionFW = [json objectForKey:@"firmware"];
                            
                            versionSW_DownloadSW = assignVersionSW;
                            versionSW_DownloadFW = assignVersionFW;
                            
                            NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] currentVersionSW: %@ assignVersionSW: %@", currentVersionSW, assignVersionSW);
                            
                            if ([[currentVersionSW stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:[assignVersionSW stringByReplacingOccurrencesOfString:@" " withString:@""]] == FALSE)
                            {
                                NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] currentVersionSW: %@ assignVersionSW: =========== version assign%@", currentVersionSW, assignVersionSW);
                                if ([json objectForKey:@"status_update"] != nil)
                                {
                                    NSNumber* mapXNum = [json objectForKey:@"status_update"];
                                    int statusUpdate = [mapXNum intValue];
                                    NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] statusUpdate: %d", statusUpdate);
                                    if (statusUpdate == 1)
                                    {
                                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] Update new SW");
                                        checkDownload = TRUE;
                                        isDownloadingSW = TRUE;
                                    }
                                    else
                                    {
                                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] Don't update new SW");
                                        checkDownload = FALSE;
                                    }
                                }
                            }
                            else
                            {
                                NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] assignVersionFW: =========== version not assign %@", assignVersionFW);
                                if (![assignVersionFW isEqual: @""]) {
                                    for (int index = 0; index <= arrVersionFW.count; index++)
                                    {
                                        if (arrVersionFW[index] != assignVersionFW) {
                                            isDownloadingFW = TRUE;
                                            versionSW_DownloadFW = assignVersionFW;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    @catch (NSException *exception) {
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] NSException exception.reason: %@", exception.reason);
                    }
                    @finally {
                        NSLog(@"[runCheckDownloadSW_FW][NSURLSessionDataTask] Finally condition");
                    }
                }
                      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog(@"[GetServer][NSURLSessionDataTask] Reply error: %@", error);
                }
                ];
                
            }
            sleep(30);
        }
    }
    
}

//ProtocolHW *mProtocolHW;
NSString *UniqueDeviceIDTemp;

- (void)runCheckHW_FW_Version
{
    @autoreleasepool {
        BOOL foudHW_FW_Version = TRUE;
        
        if(mProtocolHW == nil) {
            mProtocolHW = [[ProtocolHW alloc] init];
        }
        
        while (TRUE) {
            NSLog(@"runCheckHW_FW_Version() =========");
            for (int i = 0; i < arrayBoard.count; i++)
            {
                NSMutableDictionary *dic = (NSMutableDictionary *)arrayBoard[i];
                
                NSString *UniqueDeviceID = [dic objectForKey:@"UniqueDeviceID"];
                UniqueDeviceIDTemp = UniqueDeviceID;
                
                NSDictionary *version = [mProtocolHW checkVersion:UniqueDeviceID];
                if(version==nil)
                {
                    [mProtocolHW closeSerialPort];
                    version = [mProtocolHW checkVersion:UniqueDeviceID];
                    if(version==nil)
                        foudHW_FW_Version = FALSE;
                }
                
                if(version!=nil)
                {
                    [dic setObject:version forKey:@"VersionHW"];
                }
                
                Byte arr[8]= {LED_OFF, LED_OFF, LED_OFF, LED_OFF, LED_OFF,LED_OFF,LED_OFF,LED_OFF};
                
//                Byte arr[8]= {LED_GREEN, LED_GREEN, LED_GREEN, LED_GREEN, LED_GREEN, LED_GREEN, LED_GREEN, LED_GREEN};
                
                NSLog(@"%s ledControl call.",__func__);
                [mProtocolHW ledControl:UniqueDeviceID ledArr:arr];
                
                // start get event button on board
                NSThread *myThreadCheckButton = [[NSThread alloc] initWithTarget:mProtocolHW selector:@selector(startCheckButton:) object:UniqueDeviceID];
                [myThreadCheckButton start];
                [dic setObject:mProtocolHW forKey:@"ProtocolHW"];
                [arrayBoard replaceObjectAtIndex:i withObject:dic];
                
                
                //                sleep(3);
                //                Byte arrUSB_State[8] = {USB_POWER_ON, USB_POWER_ON, USB_POWER_ON, USB_POWER_ON, USB_POWER_ON, USB_POWER_ON, USB_POWER_ON, USB_POWER_ON};
                //                [mProtocolHW usbControlTurnON_OFF:UniqueDeviceID usbArr:arrUSB_State];
                //                sleep(2);
                
                
                
            }
            
            NSLog(@"%s runCheckHW_FW_Version ======> foudHW_FW_Version: %hhd", __func__, foudHW_FW_Version);
            foudHW_FW_Version = true;
            if (foudHW_FW_Version == TRUE) {
                NSLog(@"%s runCheckHW_FW_Version ======> myThread.executing %hhd", __func__, myThread.executing);
                threadCheckDownloadSW_FW = [[NSThread alloc] initWithTarget:self selector:@selector(runCheckDownloadSW_FW) object:nil];
                NSLog(@"%s viewDidAppear ======> threadCheckDownloadSW_FW.executing %hhd", __func__, threadCheckDownloadSW_FW.executing);
                if (threadCheckDownloadSW_FW.executing == FALSE) {
                    [threadCheckDownloadSW_FW start];
                }
                
                threadDownloadSW_FW = [[NSThread alloc] initWithTarget:self selector:@selector(runDownloadSW_FW) object:nil];
                NSLog(@"%s viewDidAppear ======> threadDownloadSW_FW.executing %hhd", __func__, threadDownloadSW_FW.executing);
                if (threadDownloadSW_FW.executing == FALSE) {
                    [threadDownloadSW_FW start];
                }
                break;
            }
            AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
            NSLog(@"runCheckHW_FW_Version() ========= %d", delegate.isLogout);
            if(delegate.isLogout == YES)
            {
                break;
            }
            
            sleep(1);
        }
    }
}

- (void)checkRemoveDevice
{
    bool isLogout = NO;
    NSLog(@"%s checkRemoveDevice : %d",__func__,isLogout);
    while (isLogout == NO)
    {
        @autoreleasepool {
            NSString *data = [self runCommandErrNew:@"/usr/local/bin/cfgutil" param:@[@"--format",@"JSON",@"list"]];
            //            data = outputRunCommandErrNew; //cfgutil --format JSON list
            NSLog(@"[checkRemoveDevice]Check unplug devices =======> != CellFinished runCommandErrNew: %@", data);
            for(int i=0; i < arrDatabaseCell.count; i++)
            {
                NSMutableDictionary *dicCell = [arrDatabaseCell objectAtIndex:i];
                //Check reset cell
                int counterDisconnected = [[dicCell objectForKey:@"counterDisconnected"] intValue];
                //NSLog(@"Check unplug devices =======>runCommand ===> != CellFinished Check reset cell counterDisconnected: %d  ECID: %@", counterDisconnected,[dicCell objectForKey:@"ECID"]);
                // NSLog(@"Check unplug devices =======>runCommand ===> != CellFinished Check reset cell ECID: %@", );
                
                if([[dicCell objectForKey:@"status"] intValue] != CellFinished && ![[dicCell objectForKey:@"ECID"]  isEqual: @"None"]) {
                    NSLog(@"[checkRemoveDevice]Check unplug devices =======> != CellFinished ");
                    
                    
                    if ([data rangeOfString:@"\"Devices\":[]"].location !=NSNotFound) {
                        counterDisconnected = [[dicCell objectForKey:@"counterDisconnected"] intValue];
                        counterDisconnected = counterDisconnected + 1;
                        [dicCell setObject:[NSNumber numberWithInt:counterDisconnected] forKey:@"counterDisconnected"];
                    }
                    else
                    {
                        NSString *jsonDeviceList = data;
                        NSData *jsonDataDeviceList = [jsonDeviceList dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *errorDataDeviceList;
                        
                        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonDataDeviceList options:0 error:&errorDataDeviceList];
                        
                        if (errorDataDeviceList) {
                            NSLog(@"[checkRemoveDevice]Check unplug devices =======> != CellFinished Error parsing JSON: %@", errorDataDeviceList);
                        } else {
                            if ([jsonObject isKindOfClass:[NSArray class]]) {
                                NSLog(@"[checkRemoveDevice]Check unplug devices =======> != CellFinished it is an array!");
                                NSArray *jsonArray = (NSArray*)jsonObject;
                                NSLog(@"[checkRemoveDevice]Check unplug devices =======> != CellFinished jsonArray - %@",jsonArray);
                            } else {
                                NSLog(@"[checkRemoveDevice]Check unplug devices =======> != CellFinished it is a dictionary");
                                NSDictionary *jsonDictionary = (NSDictionary*)jsonObject;
                                NSLog(@"[checkRemoveDevice]Check unplug devices =======> != CellFinished jsonDictionary - %@", jsonDictionary.description);
                                
                                //                        NSString *devices = [jsonDictionary objectForKey:@"Devices"];
                                NSArray *deviceList = [jsonDictionary objectForKey:@"Devices"];
                                //NSLog(@"Check unplug devices =======> != CellFinished jsonDictionary - devices: %@", devices);
                                NSLog(@"[checkRemoveDevice]Check unplug devices =======> != CellFinished jsonDictionary - deviceList: %@", deviceList);
                                counterDisconnected = 1;
                                for (int index = 0; index < [deviceList count]; index++) {
                                    
                                    NSString *stringDevice = [NSString stringWithFormat:@"%@",[deviceList objectAtIndex:index]];
                                    NSString *stringDeviceCell =[NSString stringWithFormat:@"%@",[dicCell objectForKey:@"ECID"]];
                                    NSLog(@"[checkRemoveDevice]Check unplug devices =======> != CellFinished jsonDictionary ===> != CellFinished Check reset cell ECID: stringDeviceCell %@", stringDeviceCell);
                                    NSLog(@"[checkRemoveDevice]Check unplug devices =======> != CellFinished jsonDictionary ===> != CellFinished stringDevice: %@", stringDevice);
                                    if ([stringDevice isEqualToString:stringDeviceCell] == true) {
                                        NSLog(@"[checkRemoveDevice]Check unplug devices STILL CONNECT =======> != CellFinished jsonDictionary - stringDevice: %@", stringDevice);
                                        counterDisconnected = 0;
                                        [dicCell setObject:[NSNumber numberWithInt:counterDisconnected] forKey:@"counterDisconnected"];
                                    } else {
                                        //                                NSLog(@"Check unplug devices DISCONNECT =======> != CellFinished jsonDictionary - stringDevice: %@", stringDevice);
                                        //                                countResetDisconnect = countResetDisconnect + 1;
                                        //                                if (countResetDisconnect != [deviceList count]) {
                                        //                                    counterDisconnected = [[dicCell objectForKey:@"counterDisconnected"] intValue];
                                        //                                    counterDisconnected = counterDisconnected + 1;
                                        //                                    [dicCell setObject:[NSNumber numberWithInt:counterDisconnected] forKey:@"counterDisconnected"];
                                        //                                }
                                        
                                    }
                                }
                                if(counterDisconnected == 1)
                                {
                                    counterDisconnected = [[dicCell objectForKey:@"counterDisconnected"] intValue];
                                    counterDisconnected = counterDisconnected + 1;
                                    [dicCell setObject:[NSNumber numberWithInt:counterDisconnected] forKey:@"counterDisconnected"];
                                }
                            }
                        }
                    }
                    NSLog(@"%s Check unplug devices =======>runCommand ===> before %@ counterDisconnected: %d",__func__, [dicCell objectForKey:@"title"], counterDisconnected);
                    
                    counterDisconnected = [[dicCell objectForKey:@"counterDisconnected"] intValue];
                    //NSLog(@"Check unplug devices =======>runCommand ===> != CellFinished counterDisconnected: %d", counterDisconnected);
                    NSLog(@"%s Check unplug devices =======>runCommand ===> %@ counterDisconnected: %d",__func__, [dicCell objectForKey:@"title"], counterDisconnected);
                    
                    if(counterDisconnected > 1)
                    {
                        [self removeDevice:i];
                    }
                    
                }
                usleep(200);
                //End reset cell
            }
            usleep(4000);
            AppDelegate *delegate = (AppDelegate *)appDelegate;
            isLogout = delegate.isLogout;
        }
        
    }
    
}

- (void)runUpdate
{
    bool isLogout = NO;
    NSLog(@"[runUpdate] C1: %d",isLogout);
    
    while (isLogout == NO)
    {
        NSTimeInterval timeBegin = [[NSDate date] timeIntervalSince1970];
        [self scanDevice];
        NSTimeInterval timeEnd = [[NSDate date] timeIntervalSince1970];
        double timescand = timeEnd - timeBegin;
        NSLog(@"timescand: %.2f",timescand);
        @autoreleasepool {
            AppDelegate *delegate = (AppDelegate *)appDelegate;
            isLogout = delegate.isLogout;
        }
        usleep(200);
    }
    NSLog(@"[runUpdate] C2: %d",isLogout);
}

- (void)runUpdateUI
{
    bool isLogout = NO;
    NSLog(@"[runUpdateUI] C1: %d",isLogout);
    while (isLogout == NO)
    {
        @autoreleasepool {
            NSLog(@"%s [runUpdateUI] -=========== updateMainUI ======",__func__);
            if([self updateMainUI] == 1) {
                
            }
            AppDelegate *delegate = (AppDelegate *)appDelegate;
            isLogout = delegate.isLogout;
            usleep(1000);
        }
    }
    NSLog(@" [runUpdateUI] runUpdate C2: %d",isLogout);
}

- (void)scanDevice {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->strBatchNo = txtBatchInfo.stringValue;
        self->strLineNo = txtLineNumberInfo.stringValue;
        self->strWorkArea = txtWorkAreaInfo.stringValue;
        self->strUserName = txtUserNameInfo.stringValue;
        self->strLocation = txtLocationInfo.stringValue;
        NSLog(@"scanDevice strBatchNo: %@", self->strBatchNo);
        NSLog(@"scanDevice strLineNo: %@", self->strLineNo);
        NSLog(@"scanDevice strWorkArea: %@", self->strWorkArea);
        NSLog(@"scanDevice strUserName: %@", self->strUserName);
        NSLog(@"scanDevice strLocation: %@", self->strLocation);
        
    });
    NSLog(@"%s [runUpdateUI] -=========== scanDevice ====== ",__func__);
    NSLog(@"%s [runUpdateUI] -=========== updateMainUI ====== status: 0",__func__);
    NSTimeInterval timeBegin = [[NSDate date] timeIntervalSince1970];
    if([self updateMainUI] == 1)
    {
        NSLog(@"%s [runUpdateUI] -=========== updateMainUI ====== status: 1",__func__);
    }
    NSTimeInterval timeEnd = [[NSDate date] timeIntervalSince1970];
    double timescand = timeEnd - timeBegin;
    NSLog(@"[get List iMac Device By Apple Config] =========== updateMainUI ====== elapsed time: %.2f", timescand);
    @autoreleasepool {
        for(int i=0; i < arrDatabaseCell.count; i++)
        {
            NSMutableDictionary *dicCell = [arrDatabaseCell objectAtIndex:i];
            if([[dicCell objectForKey:@"status"] intValue] == CellReady
               || [[dicCell objectForKey:@"status"] intValue] == CellFinished) {
                int counterFinished = [[dicCell objectForKey:@"counterCellFinished"] intValue];
                if (counterFinished == 0) {
                    counterFinished = counterFinished + 1;
                    [dicCell setObject:[NSNumber numberWithInt:counterFinished] forKey:@"counterCellFinished"];
                    if([[dicCell objectForKey:@"status"] intValue] == CellFinished
                       && [[dicCell objectForKey:@"result"] intValue] == RESULT_PASSED) {
                        NSString *modelMac = [dicCell objectForKey:@"name"];
                        if (modelMac == nil || [modelMac  isEqual: @"(null)"]) {
                            modelMac = [dicCell objectForKey:@"deviceType"];
                            if (modelMac == nil || [modelMac  isEqual: @"(null)"]) {
                                modelMac = @"N/A";
                            }
                        }
                        if ([modelMac  isEqual: @"N/A"]) {
                            NSDictionary *dicInfo = [dicCell objectForKey:@"info"];
                            modelMac = [dicInfo objectForKey:@"deviceType"];
                            if (modelMac == nil || [modelMac  isEqual: @"(null)"] || [modelMac  isEqual: @"N/A"]) {
                                modelMac = [dicInfo objectForKey:@"name"];
                            }
                        }
                        NSString *conten = [NSString stringWithFormat:@"<b>%@<br>State:</b> Booted<br><b>ECID:</b> %@<br></b>",
                                            modelMac, [dicCell objectForKey:@"ECID"]];
                        NSString *name = @"N/A";
                        NSString *mSerial = @"N/A";
                        NSDictionary *dicInfo = [dicCell objectForKey:@"info"];
                        if([dicInfo objectForKey:@"name"]==nil || [[NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"name"]] isEqualToString:@"<null>"])
                            name = [dicInfo objectForKey:@"deviceType"];
                        else  name = [dicInfo objectForKey:@"name"];
                        mSerial = [dicInfo objectForKey:@"serial"];
                        NSString *mSN = @"N/A";
                        mSN = [[dicInfo objectForKey:@"info"] objectForKey:@"serial"];
                        if ([mSerial  isEqual: @""]
                            || [mSerial  isEqual: @"N/A"]) {
                            mSerial = mSN;
                        }
                        
                     
                        conten = [NSString stringWithFormat:@"<b>Product name: %@<br><b>S/N: %@<br>State:</b> Booted<br><b>ECID:</b> %@ <br><b>Erasure status:</b><span style=\"color:green;\"> %@</span></b></b>",
                                  modelMac,
                                  mSerial==Nil?@"N/A":mSerial,
                                  [dicCell objectForKey:@"ECID"],
                                  @"Passed"];
                        
                        NSLog(@"%s CellFinished RESULT_PASSED => conten: %@",__func__, conten);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            int row = [[dicCell objectForKey:@"row"] intValue];
                            int col = [[dicCell objectForKey:@"col"] intValue];
                            [self setTextToCell:col row:row text:conten];
                            [self->tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                                                       columnIndexes:[NSIndexSet indexSetWithIndex:col]];
                        });
                    } else {
                        NSString *modelMac = [dicCell objectForKey:@"name"];
                        
                        if (modelMac == nil || [modelMac  isEqual: @"(null)"]) {
                            modelMac = [dicCell objectForKey:@"deviceType"];
                            if (modelMac == nil || [modelMac  isEqual: @"(null)"]) {
                                modelMac = @"N/A";
                            }
                        }
                        if ([modelMac  isEqual: @"N/A"]) {
                            NSDictionary *dicInfo = [dicCell objectForKey:@"info"];
                            modelMac = [dicInfo objectForKey:@"deviceType"];
                            if (modelMac == nil || [modelMac  isEqual: @"(null)"] || [modelMac  isEqual: @"N/A"]) {
                                modelMac = [dicInfo objectForKey:@"name"];
                            }
                        }
                        NSString *conten = [NSString stringWithFormat:@"<b>%@<br>State:</b> DFU<br><b>ECID:</b> %@<br></b>",
                                            modelMac,[dicCell objectForKey:@"ECID"]];
                        NSString *name = @"N/A";
                        NSString *mSerial = @"N/A";
                        NSDictionary *dicInfo = [dicCell objectForKey:@"info"];
                        if([dicInfo objectForKey:@"name"]==nil || [[NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"name"]] isEqualToString:@"<null>"])
                            name = [dicInfo objectForKey:@"deviceType"];
                        else  name = [dicInfo objectForKey:@"name"];
                        
                        mSerial = [dicInfo objectForKey:@"serial"];
                        conten = [NSString stringWithFormat:@"<b>Product name: %@<br><b>S/N: %@<br>State:</b> DFU<br><b>ECID:</b> %@ <br><b>Erasure status:</b><span style=\"color:red;\"> %@</span></b>",
                                  modelMac,
                                  mSerial==Nil?@"N/A":mSerial,
                                  [dicCell objectForKey:@"ECID"],
                                  @"Failed"];
                        
                       
                        
                        NSLog(@"%s CellFinished RESULT_FAILED => conten: %@",__func__, conten);
                        
                        NSLog(@"%s CellFinished scanDevice: RESULT_FAILED => dicInfo: %@",__func__, dicInfo);
                        NSLog(@"%s CellFinished scanDevice: RESULT_FAILED => dicCell: %@",__func__, dicCell);
                        //Start: Update the erase result to database
                        NSString *eraseID = [dicInfo objectForKey:@"erase_id"];
                        
                        
                        
                        deviceQueryVerifyNothing = [MacInformation objectsWhere:@"ID = %@", eraseID];
                        NSLog(@"%s CellFinished scanDevice: deviceQueryVerifyNothing size: %lu", __func__, (unsigned long)deviceQueryVerifyNothing.count);
                        dispatch_queue_t queue = dispatch_queue_create("database_access", 0);
                        @try {
                            if((unsigned long)deviceQueryVerifyNothing.count > 0) {
                                for (int j = 0; j < (unsigned long)deviceQueryVerifyNothing.count; j++) {
                                    deviceInfoVerifyNothingRef = [RLMThreadSafeReference referenceWithThreadConfined:deviceQueryVerifyNothing[j]];
                                    dispatch_async(queue, ^{
                                        @autoreleasepool {
                                            @try {
                                                RLMRealm *realm = [RLMRealm defaultRealm];
                                                macDeviceInfoVerifyNothing = [realm resolveThreadSafeReference:deviceInfoVerifyNothingRef];
                                                if (!macDeviceInfoVerifyNothing) {
                                                    return;
                                                }
                                                if(![realm inWriteTransaction]) {
                                                    [realm transactionWithBlock:^{
                                                        NSLog(@"Erase Result FAILED ======> before update DATABASE %d", [[dicCell objectForKey:@"result"] intValue]);
                                                        NSDate *dateTmp = [NSDate date];
                                                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                                        [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                                                        NSString *endTime = [dateFormat stringFromDate:dateTmp];
                                                        macDeviceInfoVerifyNothing.userText = self->strUserName;
                                                        macDeviceInfoVerifyNothing.batchNoText = self->strBatchNo;
                                                        macDeviceInfoVerifyNothing.lineNoText = self->strLineNo;
                                                        macDeviceInfoVerifyNothing.workAreaText = self->strWorkArea;
                                                        macDeviceInfoVerifyNothing.locationText = self->strLocation;
                                                        
                                                        [macDeviceInfoVerifyNothing setResulfOfErasureText:ERASURE_FAILED_TEXT];
                                                        [macDeviceInfoVerifyNothing setResulfOfErasureValue:ERASURE_RESULT_FAILED];
                                                        [macDeviceInfoVerifyNothing setNeedToSendGCS:SEND_UNSUCCESSFULLY];
                                                        [macDeviceInfoVerifyNothing setTimeEnd:endTime];
                                                        
                                                    }];
                                                }
                                            }
                                            @catch (NSException *exception) {
                                                NSLog(@"watchDeviceQueryVerifyNothing NSException exception.reason: %@", exception.reason);
                                            }
                                            @finally {
                                                NSLog(@"watchDeviceQueryVerifyNothing Finally condition");
                                            }
                                        }
                                    });
                                }
                                
                                
                            }
                        }
                        @catch (NSException *exception) {
                            NSLog(@"watchDeviceQueryVerifyNothing %@", exception.reason);
                        }
                        @finally {
                            NSLog(@"watchDeviceQueryVerifyNothing Finally condition");
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            int row = [[dicCell objectForKey:@"row"] intValue];
                            int col = [[dicCell objectForKey:@"col"] intValue];
                            [self setTextToCell:col row:row text:conten];
                            [self->tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                                                       columnIndexes:[NSIndexSet indexSetWithIndex:col]];
                        });
                    }
                }
            } else if ([[dicCell objectForKey:@"status"] intValue] == CellRunning) {
                int counterCellRunning = [[dicCell objectForKey:@"counterCellRunning"] intValue];
                if (counterCellRunning == 0) {
                    counterCellRunning = counterCellRunning + 1;
                    [dicCell setObject:[NSNumber numberWithInt:counterCellRunning] forKey:@"counterCellRunning"];
                    
                    
                    NSString *modelMac = [dicCell objectForKey:@"name"];
                    if (modelMac == nil || [modelMac  isEqual: @"(null)"]) {
                        modelMac = [dicCell objectForKey:@"deviceType"];
                        if (modelMac == nil || [modelMac  isEqual: @"(null)"]) {
                            modelMac = @"N/A";
                        }
                    }
                    if ([modelMac  isEqual: @"N/A"]) {
                        NSDictionary *dicInfo = [dicCell objectForKey:@"info"];
                        modelMac = [dicInfo objectForKey:@"deviceType"];
                        if (modelMac == nil || [modelMac  isEqual: @"(null)"] || [modelMac  isEqual: @"N/A"]) {
                            modelMac = [dicInfo objectForKey:@"name"];
                        }
                    }
                    
                    NSString *conten = [NSString stringWithFormat:@"<b>%@<br>State:</b> DFU<br><b>ECID:</b> %@<br></b>",
                                        modelMac, [dicCell objectForKey:@"ECID"]];
                    
                    NSString *name = @"N/A";
                    NSString *mSerial = @"N/A";
                    
                    NSDictionary *dicInfo = [dicCell objectForKey:@"info"];
                    [dicCell setObject:[NSNumber numberWithBool:1] forKey:@"state_dfu"];
                    [dicInfo setValue:[NSNumber numberWithBool:1] forKey:@"state_dfu"];
                    
                    if([dicInfo objectForKey:@"name"]==nil || [[NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"name"]] isEqualToString:@"<null>"])
                        name = [dicInfo objectForKey:@"deviceType"];
                    else  name = [dicInfo objectForKey:@"name"];
                    mSerial = [dicInfo objectForKey:@"serial"];
                    NSString *mSN = @"N/A";
                    mSN = [[dicInfo objectForKey:@"info"] objectForKey:@"serial"];
                    if ([mSerial  isEqual: @""]
                        || [mSerial  isEqual: @"N/A"]) {
                        mSerial = mSN;
                    }
                    conten = [NSString stringWithFormat:@"<b>Product name: %@<br><b>S/N: %@<br>State:</b> DFU<br><b>ECID:</b> %@<br></b>",
                              name,
                              mSerial==Nil?@"N/A": mSerial,
                              [dicCell objectForKey:@"ECID"]];
                    
                }
            }
        }
    }
}

- (NSString *)runCommandError:(NSString *)commandToRun
{
    @autoreleasepool {
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/sh"];
        
        NSArray *arguments = [NSArray arrayWithObjects:
                              @"-c" ,
                              [NSString stringWithFormat:@"%@", commandToRun],
                              nil];
        NSLog(@"run command:%@", commandToRun);
        [task setArguments:arguments];
        
        NSPipe *pipe = [NSPipe pipe];
        [task setStandardError:pipe];
        NSFileHandle *file = [pipe fileHandleForReading];
        
        [task launch];
        
        NSData *data = [file readDataToEndOfFile];
        NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return output;
    }
}

NSString *outputRunCommandErrNew = @"";
- (NSString *) runCommandErrNew:(NSString*)cmd param:(NSArray*)arguments
{
    @autoreleasepool {
        NSLog(@"%s %@ %@",__func__,cmd,arguments);
        NSPipe *pipe = [NSPipe pipe];
        NSFileHandle *file = pipe.fileHandleForReading;
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = cmd;
        if(arguments.count > 0)
            task.arguments = arguments;
        task.standardOutput = pipe;
        [task launch];
        
        NSData *dataPlist = [file readDataToEndOfFile];
        NSString *grepOutput = [[NSString alloc] initWithData: dataPlist encoding: NSUTF8StringEncoding];
        NSLog(@"[strDisconnectNew] %s output: %@",__func__, grepOutput);
        [task waitUntilExit];
        [file closeFile];
        if (![task isRunning])
        {
            int status = [task terminationStatus];
            if (status == 0) {
                NSLog(@"%s[runCommandErrNew] Task succeeded.",__func__);
                task = nil;
                outputRunCommandErrNew = grepOutput;
                return grepOutput;
            } else {
                NSLog(@"%s[runCommandErrNew] Task failed.",__func__);
                task = nil;
                return @"";
            }
        }
        return grepOutput;//grepOutput
    }
}

//- (NSString *)runCommandError:(NSString *)commandToRun
//{
//    NSTask *task = [[NSTask alloc] init];
//    [task setLaunchPath:@"/bin/sh"];
//
//    NSArray *arguments = [NSArray arrayWithObjects:
//                          @"-c" ,
//                          [NSString stringWithFormat:@"%@", commandToRun],
//                          nil];
//    NSLog(@"run command:%@", commandToRun);
//    [task setArguments:arguments];
//
//    NSPipe *pipe = [NSPipe pipe];
//    [task setStandardError:pipe];
//    NSFileHandle *file = [pipe fileHandleForReading];
//
//    [task launch];
//
//    NSData *data = [file readDataToEndOfFile];
//
//    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    return output;
//}

- (NSMutableDictionary *)getConfig
{
    AppDelegate *delegatedir = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSString *pathLib = [delegatedir pathLib];
    NSLog(@"%s pathLib:%@",__func__,pathLib);
    pathLib = [pathLib stringByAppendingString:@"/config/idevice_support.config"];
    NSLog(@"%s pathconfig:%@",__func__,pathLib);
    NSData *dataPlist = [NSData dataWithContentsOfFile:pathLib];
    NSError *error=nil;
    NSPropertyListFormat format;
    NSMutableDictionary* dic = [NSPropertyListSerialization propertyListWithData:dataPlist
                                                                         options:NSPropertyListImmutable
                                                                          format:&format
                                                                           error:&error];
    NSLog( @"Dic Config: %@", dic );
    if(!dic){
        NSLog(@"Error: %@",error);
    }
    return dic;
}

- (void) createDatabase:(int)usbBoard
{
    NSLog(@"[createDatabase] =====================>");
    if(arrDatabaseCell == nil) {
        NSLog(@"[createDatabase] =====================> init ------------------------------");
        arrDatabaseCell = [[NSMutableArray alloc] init];
        [arrDatabaseCell removeAllObjects];
    } else {
        NSLog(@"[createDatabase] =====================> exist ------------------------------");
    }
    
    
    NSMutableDictionary *options;
    NSString *title=@"",*board =@"";
    int dong,cot;
    
    for (int i=0; i<usbBoard; i++)
    {
        NSMutableDictionary *dic;
        if(i==0) board = @"A";
        else if(i==1) board = @"B";
        else if(i==2) board = @"C";
        else if(i==3) board = @"D";
        cot = i;
        
        for (int j=0; j<8; j++)//moi board co 8 port
        {
            dong = j;
            if(usbBoard == 1) // 1 board xuat tren 2 dong 4 cot
            {
                cot = j%numCol;
                dong = (int)j/numCol;
            }
            else if(usbBoard == 2)// 1 board xuat tren 2 cot 4 dong
            {
                dong = j%numRow;
                cot = (int)(j/numRow) + i*2; //moi board co 4 dong 2 cot ,=> 2board co1 4 dong 4 cot
            }
            
            ProccessUSB *libusbtemp= [[ProccessUSB alloc] init];
            title = [NSString stringWithFormat:@"%@%d",board,j+1];
            options = [[NSMutableDictionary alloc] init];
            dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                   [NSNumber numberWithInt:dong],@"row",
                   [NSNumber numberWithInt:cot],@"col",
                   [NSNumber numberWithInt:i*8+j],@"index",
                   title, @"title",
                   @"No device", @"conten",
                   options,@"info",
                   [NSNumber numberWithInt:0],@"update_info",
                   @"",@"UniqueDeviceID",
                   [NSNumber numberWithInt:1],@"CheckboxValue",
                   [NSNumber numberWithInt:CellNoDevice],@"status",// trang thay cell
                   [NSNumber numberWithInt:RESULT_NA],@"result",// ket qua cuoi cung
                   [NSNumber numberWithInt:0],@"TimeProccess",// thoi gian chay erase
                   [NSNumber numberWithInt:0],@"InfoUpdated",// da up date day du hay chua
                   [NSNumber numberWithInt:numboard],@"num_board",// se update lai sau
                   [NSNumber numberWithInt:0],@"counterTrust",
                   [NSNumber numberWithInt:0],@"counterCellFinished",
                   [NSNumber numberWithInt:0],@"counterCellRunning",
                   @"",@"itemID",
                   [NSNumber numberWithInt:0],@"counterDisconnected",
                   [NSNumber numberWithInt:CellNoDevice],@"isWaiting",
                   [NSNumber numberWithInt:0],@"startTimerErase",
                   @"",@"note",
                   libusbtemp,@"ProccessUSB",
                   @"00:00:00", @"elapsedTime",
                   @"None",@"ECID",
                   nil];
            [arrDatabaseCell addObject:dic];
        }
    }
}

-(int)getRandomNumberBetween:(int)from and:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}

DatabaseCom *mDatabaseCom;
RLMThreadSafeReference *deviceInfoNeed2SendRef;
RLMThreadSafeReference *deviceInfoNeed2SendRefTemp;

RLMThreadSafeReference *deviceInfoVerifyNothingRef;

MacInformation *deviceInfoNeed2Send;
DeviceInfo *deviceInfoVerifyNothing;
MacInformation *macDeviceInfoVerifyNothing;

RLMResults<DeviceInfo *> *watchDeviceQueryVerifyNothing;

RLMResults<DeviceMapping *> *watchDeviceQueryMapping;

-(NSDictionary *)getlocationWithBoard:(NSString *)locator
{
    @autoreleasepool {
        
        for(int i=0;i<arrayBoard.count;i++ )
        {
            NSDictionary *dicBoard = [arrayBoard objectAtIndex:i];
            NSString *uuid = [dicBoard objectForKey:@"UniqueDeviceID"];
            NSDictionary *dicLoca = [dicBoard objectForKey:@"location_port"];
            if(dicLoca==nil)
            {
                NSLog(@"locator not found, please config port again ,board %@",dicBoard);
                NSMutableArray *arrButtons = [NSMutableArray arrayWithObjects:@"Close",nil];
                UIAlertView *alert = [[UIAlertView alloc] initWithFrame:NSMakeRect(0, 0, 400, 200)
                                                                  title:@"Warning"
                                                                 conten:@"Locator not found, please config port again"
                                                                   icon:[NSImage imageNamed:@"Warning"]
                                                                buttons:arrButtons
                                                                    tag:10
                                                                   Root:self seletor:@selector(messageSelect:)];
                [alert showWindow];
                
                return nil;
            }
            for(int j = 0;j<dicLoca.allKeys.count;j++)
            {
                NSString *key = dicLoca.allKeys[j];
                NSString *lo = [dicLoca objectForKey:key];
                NSLog(@"%s duyet get location: %@ %ld - %@ %ld",__func__,lo,[lo length],locator,locator.length);
                if([lo isEqualToString:locator]) {
                    NSDictionary *dicnew = [NSDictionary dictionaryWithObjectsAndKeys:uuid,@"UDID",key,@"port",[NSNumber numberWithInt:i],@"board", nil];
                    NSLog(@"%s duyet get location dic:%@",__func__,dicnew);
                    return dicnew;
                }
            }
        }
        return nil;
    }
    
}
-(bool) checkHaveSerial:(NSMutableDictionary *)dicCell
{
    NSMutableDictionary *info = [dicCell objectForKey:@"info"];
    NSString *serial = @"";
    if([info objectForKey:@"serial"])
    {
        serial = [NSString stringWithFormat:@"%@",[info objectForKey:@"serial"]];
        if(serial.length == 12)// serial hop le
        {
            return YES;
        }
    }
    return NO;
}
-(bool) updateMainUI
{
    @autoreleasepool {
        dispatch_queue_t queue = dispatch_queue_create("database_access", 0);
       
        
        if(libusb == nil) libusb = [[ProccessUSB alloc] init];
        int mustReload = 0;
        NSLog(@"%s arrayBoard: %@",__func__, arrayBoard);
        
        //getListiMacDevice
        NSTimeInterval timeBegin = [[NSDate date] timeIntervalSince1970];
        //NSMutableArray *arrDevice = [libusb getListiMacDevice];
        NSMutableArray *arrDevice = [libusb getListiMacDeviceByAppleConfig];
        
        NSTimeInterval timeEnd = [[NSDate date] timeIntervalSince1970];
        double timescand = timeEnd - timeBegin;
        NSLog(@"getListiMacDevice elapsed time: %.2f",timescand);
        
        if(arrDevice == nil)
        {
            NSLog(@"%s arrDevice return nill",__func__);
            return 0;
        }
        NSLog(@"%s arrDevice Mac:%d, list Mac: %@",__func__,(int)arrDevice.count,arrDevice);
        if(arrayBoard == nil || arrayBoard.count==0)
        {
            return 0;
        }
        //if(arrDevice.count == 0) return 0;
        
        checkInfoFlag ++;
        if(checkInfoFlag>=MAX_ULONG)
            checkInfoFlag = 0;
        NSMutableDictionary *dic, *dicCell, *dicInfo;
        NSString *conten = @"";
        int n,capso=-1;
        
        int numDeviceInUpdateMainUI = (int)arrDevice.count;
        NSLog(@"%s numDeviceInUpdateMainUI: %d",__func__,numDeviceInUpdateMainUI);
        
        for (int i = 0; i < numDeviceInUpdateMainUI; i++)
        {
            dic = [arrDevice objectAtIndex:i];
            
            NSString *ECID = [dic objectForKey:@"ECID"];
            if(ECID.length<5)
            {
                continue;
            }
            
            
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%: tim  vi tri tren Board :%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//            NSString *strLocator = [NSString stringWithFormat:@"0x%08x",[[dic objectForKey:@"locationID"] unsignedIntValue]];
//            NSLog(@"%s strLocator:%@",__func__,strLocator);
//
//            NSDictionary *dicLocation = [self getlocationWithBoard:strLocator];
//            NSLog(@"%s dicLocation:%@",__func__, dicLocation);
//
//
//
//            int vttemp = -1;
//            int board = [[dicLocation objectForKey:@"board"] intValue];
//            //NSDictionary *dicnew = [NSDictionary dictionaryWithObjectsAndKeys:uuid,@"UDID",key,@"port", nil];
//            if(dicLocation)
//            {
//                vttemp = [[dicLocation objectForKey:@"port"] intValue];
//            }
//%%%%%%%%%%%%%%%%%%%%
            int board = 0;
            int vttemp = -1;
            
            NSString *ECIDNew = [NSString stringWithFormat:@"%@",[dic objectForKey:@"ECID"]];
            for(int vt=0;vt<arrDatabaseCell.count;vt++)
            {
                NSDictionary *dicCellTemp = [arrDatabaseCell objectAtIndex:vt];
                NSDictionary *dicInfoTemp = [dicCellTemp objectForKey:@"info"];
               // if([[dicCellTemp objectForKey:@"status"] intValue] == CellNoDevice)
                if([dicInfoTemp objectForKey:@"ECID"]==nil)
                {
                    if(vttemp == -1)
                        vttemp = vt;
                }
                else
                {
                    NSString *ECID_Old = [NSString stringWithFormat:@"%@",[dicInfoTemp objectForKey:@"ECID"]];
                    if([ECID_Old isEqualToString:ECIDNew])
                    {
                        vttemp = vt;// da co roi
                        break;
                    }
                }
            }
            NSLog(@"%s board: %d port: %d",__func__,board, vttemp);
            
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%: end tim  vi tri tren Board :%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if(vttemp >= 0)
            {
                dicCell = [arrDatabaseCell objectAtIndex:vttemp];
                NSMutableDictionary *dicInfoTemp = [dicCell objectForKey:@"info"];
                
                NSLog(@"%s [TN-DEBUG] dictmp:%@",__func__, dicInfoTemp);
                
                if([dicInfoTemp objectForKey:@"time_start"])
                {
                    NSString *time_start = [NSString stringWithFormat:@"%@",[dicInfoTemp objectForKey:@"time_start"]];
                    [dic setObject:time_start forKey:@"time_start"];
                }
                
                if([dicInfoTemp objectForKey:@"erase_id"])
                {
                    NSString *erase_id = [NSString stringWithFormat:@"%@",[dicInfoTemp objectForKey:@"erase_id"]];
                    [dic setObject:erase_id forKey:@"erase_id"];
                }
                
                
                NSString *serial = @"";
                if([dicInfoTemp objectForKey:@"serial"])
                {
                    serial = [NSString stringWithFormat:@"%@",[dicInfoTemp objectForKey:@"serial"]];
                    if(serial.length == 12)// serial hop le
                    {
                        [dic setObject:serial forKey:@"serial"];
                    }
                }
                
                
               
                [dicCell setObject:dic forKey:@"info"];
                NSString *strECID = [NSString stringWithFormat:@"%@",[dic objectForKey:@"ECID"]];
                if([self checkHaveSerial:dicCell]==YES)
                {
                    [dicDataCellBK setObject:dic forKey:strECID];
                    // save lai khi hop le cung ECID
                    //[dicDataCellBK removeObjectForKey:strECID];
                    // giai phong khi khac port
                }
                else
                {
                    NSMutableDictionary *infoSave = Nil;
                    if([dicDataCellBK objectForKey:strECID]!=Nil)
                    {
                        infoSave = [dicDataCellBK objectForKey:strECID];
                        [dicCell setObject:infoSave forKey:@"info"];
                    }
                }
            }
            
            
            /// change status and open led
            if (ECID.length > 4)
            {
                if([[dicCell objectForKey:@"status"] intValue] == CellNoDevice)
                {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(vttemp >=0)
                        {
                            [dicCell setObject:[NSNumber numberWithInt:CellHaveDevice] forKey:@"status"];
                            [dicCell setObject:ECID forKey:@"ECID"];
                            
                            NSString *title = [dicCell objectForKey:@"title"];
                            NSLog(@"CellHaveDevice LED_YELLOW title: %@, dic: \n%@",title,dicCell);
                            [self setLedOnBoardOfCell:title color:LED_YELLOW];
                            
                            int row = [[dicCell objectForKey:@"row"] intValue];
                            int col = [[dicCell objectForKey:@"col"] intValue];
                            NSString * htmlString = [NSString stringWithFormat:@"Checking device"];
                            [dicCell setObject:@"Checking device" forKey:@"conten"];
                            [self setTextToCell:col row:row text:htmlString];
                            [self->arrDatabaseCell replaceObjectAtIndex:vttemp withObject:dicCell];
                        }
                        else
                        {
                            NSLog(@"vttemp == -1 locator not found, please check config port")
                        }
                    });
                }
                else
                {
                    //dang lam cho nay
                    NSLog(@"dicCell:%@",dicCell);
                    if([[dicCell objectForKey:@"status"] intValue] != CellFinished)
                    {
                        NSString *str = [dicCell objectForKey:@"conten"];
                        if([[str lowercaseString] rangeOfString:@"Booted"].location != NSNotFound)
                        {
                            NSDictionary *dicInfo = [dicCell objectForKey:@"info"];
                            if([dicInfo objectForKey:@"state_dfu"] != Nil && [[dicInfo objectForKey:@"state_dfu"] intValue] == 1)
                            {
                                NSString *name = @"";
                                if([dicInfo objectForKey:@"name"]==nil || [[NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"name"]] isEqualToString:@"<null>"])
                                    name = [dicInfo objectForKey:@"deviceType"];
                                else  name = [dicInfo objectForKey:@"name"];
                                
                                NSString *conten = [NSString stringWithFormat:@"<b>%@<br>State:</b> %@<br><b>ECID:</b> %@<br></b>",
                                                    name,
                                                    [[dicInfo objectForKey:@"state_dfu"] intValue]==1?@"DFU":@"Booted",
                                                    [dicInfo objectForKey:@"ECID"]];
                                
                                [dicCell setObject:conten forKey:@"conten"];
                                
                                int row = [[dicCell objectForKey:@"row"] intValue];
                                int col = [[dicCell objectForKey:@"col"] intValue];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    [self setTextToCell:col row:row text:conten];
                                    [self->tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                                                               columnIndexes:[NSIndexSet indexSetWithIndex:col]];
                                });
                            }
                        }
                    }
                }
            }
            
            //NSLog(@"%s update cap:%d, row:%d dic:%@,dicCell:%@",__func__,capso,n,dicInfo,dicCell);
            NSLog(@"%s update cap:%d, row:%d dicCell:%@",__func__,capso,n,dicCell);
            //tao conten
            /*
             CellNoDevice    = 0,//den tat           <=> chua co device
             CellHaveDevice  = 1,//den vang          <=> co device dang doc thong tin
             CellReady       = 2,//den xanh          <=> d9a dopc thogn tin thanh cong
             CellRunning     = 3,//den vang          <=> bat dau xoa
             CellChecking    = 4,//den vang          <=> write xong cho doc trang thay
             CellFinished    = 5,// xanh hoac do     <=> ket thuc
             CellCouldNotRead = 6, //do
             */
            NSLog(@"%s update database ===  position %@ status :%@",__func__,[dicCell objectForKey:@"title"],[dicCell objectForKey:@"status"]);
            
            
            if([[dicCell objectForKey:@"status"] intValue] == CellHaveDevice)
            {
                if(dicInfo != Nil)
                {
                    NSString *name = [dicInfo objectForKey:@"ProductType"];
                    NSMutableDictionary *dicconfig = dicInforconfig[name];
                    
                    //                    [realm refresh];
                    RLMResults<DeviceMapping *> *itemDeviceMapping = [DeviceMapping objectsWhere:@"icapture_pn = %@", [NSString stringWithFormat:@"%@%@",dicInfo[@"ModelNumber"],dicInfo[@"RegionInfo"]]];
                    NSLog(@"QUERY COLOR %@", [NSString stringWithFormat:@"%@%@",dicInfo[@"ModelNumber"],dicInfo[@"RegionInfo"]]);
                    NSLog(@"itemDeviceMapping.count: %lu", (unsigned long)itemDeviceMapping.count);
                    
                    
                    if(dicconfig && dicconfig[@"idevice_name"]!=nil)
                    {
                        name = dicconfig[@"idevice_name"];
                        [dicCell setObject:name forKey:@"fullname"];
                    }
                    [dicCell setValue: name forKey:@"modelName"];
                    conten = [NSString stringWithFormat:@"<b>%@<br>ECID:</b> %@",name,[dicInfo objectForKey:@"ECID"]];
                    
                    [dicCell setObject:[NSNumber numberWithInt:1] forKey:@"InfoUpdated"];
                    [dicCell setObject:[NSNumber numberWithLong:checkInfoFlag] forKey:@"update_info"];
                    
                    [dicCell setObject:[NSNumber numberWithLong:CellReady] forKey:@"status"];
                    NSString *title = [dicCell objectForKey:@"title"];
                    NSLog(@"LED_GREEN title: %@, dic: \n%@",title,dicCell);
                    [self setLedOnBoardOfCell:title color:LED_GREEN];
                    
                    
                    //dang them 15-6-2022
                    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                    if([[appDelegate.dicInfoSettingSave objectForKey:@"auto_run_after_plugin_device"] intValue]==1)
                    {
                        
                        if([[dicCell objectForKey:@"status"] intValue] == CellReady)
                        {
                            NSThread *threadEraseDevice = [[NSThread alloc] initWithTarget:self selector:@selector(runEraseWhenReady:) object:dicCell];
                            if (threadEraseDevice.executing == false) {
                                [threadEraseDevice start];
                            }
                        }
                        mustReload = 1;
                    }
                    
                }
                else// ko read dc info
                {
                    
                    NSLog(@"%s dic ko read dc info: %@", __func__, dic);
                    NSString *product = [dic objectForKey:@"product"];
                    if([[product lowercaseString] rangeOfString:@"mac"].location != NSNotFound)
                    {
                        if([[dicCell objectForKey:@"InfoUpdated"] intValue] == 1)
                        {
                            NSLog(@"%s DBInfoUpdated 1", __func__);
                            
                            dicInfo = [dicCell objectForKey:@"info"];
                            NSString *name = [dicInfo objectForKey:@"ProductType"];
                            NSMutableDictionary *dicconfig = dicInforconfig[name];
                            if(dicconfig && dicconfig[@"idevice_name"]!=nil)
                            {
                                name = dicconfig[@"idevice_name"];
                                [dicCell setObject:name forKey:@"fullname"];
                            }
                            conten = [NSString stringWithFormat:@"<b>%@<br>Serial:</b> %@",name,[dicInfo objectForKey:@"SerialNumber"]];
                            if(numRow<8)
                            {
                                conten = [NSString stringWithFormat:@"<b>%@<br>Serial:</b> %@<br><b>Firmware:</b> %@<br><b>Internal name:</b> %@<br><b>Capacity:</b> %@",
                                          name,
                                          [dicInfo objectForKey:@"SerialNumber"],
                                          [dicInfo objectForKey:@"ProductVersion"],
                                          [dicInfo objectForKey:@"ProductType"],
                                          [dicconfig objectForKey:@"capacity"]
                                ];
                            }
                            
                            
                            NSMutableDictionary *dictmp = [[dicCell objectForKey:@"info"] mutableCopy];
                            if([dictmp objectForKey:@"time_start"])
                            {
                                NSString *time_start = [NSString stringWithFormat:@"%@",[dictmp objectForKey:@"time_start"]];
                                [dicInfo setObject:time_start forKey:@"time_start"];
                            }
                            [dicCell setObject:dicInfo forKey:@"info"];
                            [dicCell setObject:[NSNumber numberWithLong:checkInfoFlag] forKey:@"update_info"];
                            
                            
                        }
                        else
                        {
                            NSLog(@"%s DBInfoUpdated != 1 cell status: %d", __func__, [[dicCell objectForKey:@"status"] intValue]);
                            
                            dicInfo = [[dic objectForKey:@"info_ex"] mutableCopy];
                            
                            NSString *name = [dicInfo objectForKey:@"ProductType"];
                            NSMutableDictionary *dicconfig = dicInforconfig[name];
                            if(dicconfig && dicconfig[@"idevice_name"]!=nil)
                            {
                                name = dicconfig[@"idevice_name"];
                                [dicCell setObject:name forKey:@"fullname"];
                            }
                            conten = [NSString stringWithFormat:@"<b>%@<br>Serial:</b> %@<br><b>Firmware:</b> %@<br><b>Internal name:</b> %@<br><b>Capacity:</b> %@",
                                      name,
                                      [dicInfo objectForKey:@"SerialNumber"],
                                      [dicInfo objectForKey:@"ProductVersion"],
                                      [dicInfo objectForKey:@"ProductType"],
                                      [dicconfig objectForKey:@"capacity"]
                            ];
                            
                            int counterTrust = [[dicCell objectForKey:@"counterTrust"] intValue];
                            counterTrust = counterTrust + 1;
                            [dicCell setObject:[NSNumber numberWithInt:counterTrust] forKey:@"counterTrust"];
                            NSLog(@"%s position: %@ counterTrust: %d", __func__, [dicCell objectForKey:@"title"], counterTrust);
                            
                            if (counterTrust > 1) {
                                
                                NSLog(@"%s CellReady ===========> DFU requirement..........position: %@ state_dfu: %d", __func__, [dicCell objectForKey:@"title"], [[dic objectForKey:@"state_dfu"] intValue]);
                                NSLog(@"%s CellReady ===========> DFU requirement..........position: %@ dic: %@", __func__, [dicCell objectForKey:@"title"], dic);
                                //NSLog(@"%s CellReady ===========> DFU requirement..........position: %@ dicCell: %@", __func__, [dicCell objectForKey:@"title"], dicCell);
                                
                                NSString *mECID = [dic objectForKey:@"ECID"];
                                
                                bool isCellDFUMode = [libusb checkDeviceInDFU_Mode: mECID];
                                
                                
                                @try {
                                    NSString *devType = [dic objectForKey:@"deviceType"];
                                    
                                    if (devType != nil
                                        || devType != NULL
                                        || ![devType  isEqual: @""]
                                        || ![devType  isEqual: @"<null>"]) {
                                        NSLog(@"%s CellReady ===========> DFU requirement..........position: %@ dicCell: %@ mECID: %@ devType: %@", __func__, [dicCell objectForKey:@"title"], dicCell, mECID, devType);
                                        if([devType rangeOfString:@"iPhone9,3"].location != NSNotFound
                                           || [devType rangeOfString:@"iPhone7,2"].location != NSNotFound
                                           || [devType rangeOfString:@"iPhone10,6"].location != NSNotFound
                                           || [devType rangeOfString:@"iPhone7,1"].location != NSNotFound
                                           || [devType rangeOfString:@"iPhone8,2"].location != NSNotFound
                                           || [devType rangeOfString:@"iPhone8,1"].location != NSNotFound
                                           ) {
                                            isCellDFUMode = true;
                                        }
                                    }
                                }
                                @catch (NSException *exception) {
                                    NSLog(@"CellReady ===========> devType isCellDFUMode ===> %@", exception.reason);
                                }
                                @finally {
                                    NSLog(@"CellReady ===========>Finally condition");
                                }
                                // Debug July 28, 2022
                                //isCellDFUMode = false;
                                if (isCellDFUMode == false) {
                                    NSString *name = @"N/A";
                                    NSString *mSerial = @"N/A";
                                    if([dic objectForKey:@"name"]==nil || [[NSString stringWithFormat:@"%@",[dic objectForKey:@"name"]] isEqualToString:@"<null>"])
                                        name = [dic objectForKey:@"deviceType"];
                                    else  name = [dic objectForKey:@"name"];
                                    
                                    mSerial = [dic objectForKey:@"serial"];
                                    
                                    NSLog(@"%s CellReady ===========> DFU requirement.......... mSerial: %@", __func__, mSerial);
                                    NSLog(@"%s CellReady ===========> DFU requirement.......... product name: %@", __func__, name);
                                    NSDictionary *dicInfo = [dicCell objectForKey:@"info"];
                                    NSString *mSN = @"N/A";
                                    mSN = [[dicInfo objectForKey:@"info"] objectForKey:@"serial"];
                                    if ([mSerial  isEqual: @""]
                                        || [mSerial  isEqual: @"N/A"]) {
                                        mSerial = mSN;
                                    }
                                    
                                    conten = [NSString stringWithFormat:@"<b>Product name: %@<br><b>S/N: %@<br>State:</b> Booted<br><b>ECID:</b> %@<br><br><br><br><br><p style='color:#E08237; text-align: center;'>Please switch the Mac computer <br>to DFU mode.</br></p></b>",
                                              name,
                                              mSerial==Nil?@"N/A":mSerial,
                                              [dic objectForKey:@"ECID"]];
                                    
                                    int row = [[dicCell objectForKey:@"row"] intValue];
                                    int col = [[dicCell objectForKey:@"col"] intValue];
                                    [self setTextToCell:col row:row text:conten];
                                }
                                else
                                {
                                    
                                    conten = [NSString stringWithFormat:@"<b>%@<br>State:</b> DFU<br><b>ECID:</b> %@<br></b>",
                                              [dic objectForKey:@"name"]==nil?[dic objectForKey:@"deviceType"]:[dic objectForKey:@"name"],
                                              [dic objectForKey:@"ECID"]];
                                    [dicCell setObject:conten forKey:@"conten"];
                                    
                                    // 1 - DFU
                                    NSLog(@"%s CellHaveDevice ===========> remove DFU requirement.......... %d", __func__, [[dic objectForKey:@"state_dfu"] intValue]);
                                    
                                    if([[dic objectForKey:@"state_dfu"] intValue] == 1) {
                                        [dic setObject:[NSNumber numberWithBool:1] forKey:@"state_dfu"];
                                        [dicCell setObject:[NSNumber numberWithBool:1] forKey:@"state_dfu"];
                                        NSDictionary *dicInfo = [dicCell objectForKey:@"info"];
                                        [dicInfo setValue:[NSNumber numberWithBool:1] forKey:@"state_dfu"];
                                    }
                                    @try {
                                        NSLog(@"%s CellHaveDevice ===========> isCellDFUMode: %hd", __func__, isCellDFUMode);
                                        
                                        if (isCellDFUMode == true) {
                                            NSDate *dateTmp = [NSDate date];
                                            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                            [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                                            NSString *dateString = [dateFormat stringFromDate:dateTmp];
                                            NSString *strDateStart = dateString;
                                            NSLog(@"CellHaveDevice ===========> cell: %@ strDateStart: %@", [dicCell objectForKey:@"title"] ,strDateStart);
                                            NSDictionary *dicInfoTemp = [dicCell objectForKey:@"info"];
                                            [dicInfoTemp setValue:strDateStart forKey:@"time_start"];
                                            NSUUID *UUID = [[NSUUID alloc] init];
                                            NSString *idString = [UUID UUIDString];
                                            //Save new Erase ID to dicCell
                                            [dicInfoTemp setValue:idString forKey:@"erase_id"];
                                            
                                            
                                            int randomNumber = [self getRandomNumberBetween:1000 and:9999];
                                            NSString *transaction_id = [NSString stringWithFormat:@"%@%@%ld%d",stationSN,[dicCell objectForKey:@"title"],(long)[[NSDate date] timeIntervalSince1970],randomNumber];
                                            
                                            if([dicInfoTemp objectForKey:@"transaction_id"])
                                            {
                                                transaction_id = [dicInfoTemp objectForKey:@"transaction_id"];
                                            }
                                            else
                                            {
                                                [dicInfoTemp setValue:transaction_id forKey:@"transaction_id"];
                                            }
                                            
                                            [dicCell setObject:dicInfoTemp forKey:@"info"];
                                            //transaction_id = @"F01898EA2953A116758306402029";
                                            
                                            // Query and update the result in another thread
                                            dispatch_async(dispatch_queue_create("background", 0), ^{
                                                @autoreleasepool {
                                                    NSLog(@"%s CellHaveDevice PREPARE SAVE DATABASE ===================", __func__);
                                                    MacInformation *macInfo = [[MacInformation alloc] init];
                                                    macInfo.ID = idString;
                                                    macInfo.transaction_ID = transaction_id;
                                                    macInfo.cellID = [dicCell objectForKey:@"title"];
                                                    if ([dic objectForKey:@"ECID"] != nil) {
                                                        macInfo.mECID = [dic objectForKey:@"ECID"];
                                                    } else {
                                                        macInfo.mECID = @"N/A";
                                                    }
                                                    if ([dic objectForKey:@"UDID"] != nil) {
                                                        macInfo.mUDID = [dic objectForKey:@"UDID"];
                                                    } else {
                                                        macInfo.mUDID = @"N/A";
                                                    }
                                                    if ([dic objectForKey:@"deviceType"] != nil) {
                                                        macInfo.productName = [dic objectForKey:@"deviceType"];
                                                    } else {
                                                        macInfo.productName = @"N/A";
                                                    }
                                                    if ([dic objectForKey:@"serial"] != nil) {
                                                        macInfo.mSerialNumber = [dic objectForKey:@"serial"];
                                                    } else {
                                                        macInfo.mSerialNumber = @"N/A";
                                                    }
                                                    //result text: PASSED, FAILED, N/A
                                                    //result value: 1, 0, 2
                                                    //verify send data to GCS: 2: Chưa gửi, 0: Gửi thành công , 1: Gửi khong thành công
                                                    macInfo.resulfOfErasureText = ERASURE_NA_TEXT;
                                                    macInfo.resulfOfErasureValue = ERASURE_RESULT_NA;
                                                    macInfo.needToSendGCS = SEND_UNKNOWN;
                                                    macInfo.timeEnd = @"N/A";
                                                    macInfo.timeStart = strDateStart;
                                                    macInfo.userText = @"N/A";
                                                    macInfo.batchNoText = @"N/A";
                                                    macInfo.lineNoText = @"N/A";
                                                    macInfo.workAreaText = @"N/A";
                                                    macInfo.locationText = @"N/A";
                                                    
                                                    
                                                    RLMRealm *realm = RLMRealm.defaultRealm;
                                                    if (realm.inWriteTransaction) {
                                                        NSLog(@"CellHaveDevice inWriteTransaction");
                                                        return;
                                                    }
                                                    [realm beginWriteTransaction];
                                                    [realm addObject:macInfo];
                                                    [realm commitWriteTransaction];
                                                }
                                            });
                                            
                                        }
                                    }
                                    @catch (NSException *exception) {
                                        NSLog(@"CellHaveDevice ===========> ===========> devType isCellDFUMode ===> %@", exception.reason);
                                    }
                                    @finally {
                                        NSLog(@"CellHaveDevice ===========> ===========>Finally condition");
                                    }
                                    
                                    
                                    
                                    if([[dicCell objectForKey:@"status"] intValue] == CellHaveDevice)
                                    {
                                        [dicCell setObject:[NSNumber numberWithInt:CellReady] forKey:@"status"];
                                        mustReload = 1;
                                    }
                                    
                                    
                                    if([[dicCell objectForKey:@"status"] intValue] == CellReady)
                                    {
                                        //NSLog(@"%s CellReady ===========> remove DFU requirement..........", __func__);
                                        NSLog(@"%s CellReady ===========> remove DFU requirement.......... %d", __func__, [[dic objectForKey:@"state_dfu"] intValue]);
                                        
                                        NSString *name = @"N/A";
                                        NSString *mSerial = @"N/A";
                                        if([dic objectForKey:@"name"]==nil || [[NSString stringWithFormat:@"%@",[dic objectForKey:@"name"]] isEqualToString:@"<null>"])
                                            name = [dic objectForKey:@"deviceType"];
                                        else  name = [dic objectForKey:@"name"];
                                        
                                        mSerial = [dic objectForKey:@"serial"];
                                        
                                        NSLog(@"%s CellReady ===========> DFU mode.......... mSerial: %@", __func__, mSerial);
                                        NSLog(@"%s CellReady ===========> DFU mode.......... product name: %@", __func__, name);
                                        
                                        
                                        NSDictionary *dicInfo = [dicCell objectForKey:@"info"];
                                        
                                        NSString *mSN = @"N/A";
                                        mSN = [[dicInfo objectForKey:@"info"] objectForKey:@"serial"];
                                        if ([mSerial  isEqual: @""]
                                            || [mSerial  isEqual: @"N/A"]) {
                                            mSerial = mSN;
                                        }
                                        
                                        conten = [NSString stringWithFormat:@"<b>Product name: %@<br><b>S/N: %@<br>State:</b> DFU<br><b>ECID:</b> %@<br></b>",
                                                  name,
                                                  mSerial==Nil?@"N/A": mSerial,
                                                  [dic objectForKey:@"ECID"]];
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            int row = [[dicCell objectForKey:@"row"] intValue];
                                            int col = [[dicCell objectForKey:@"col"] intValue];
                                            [self setTextToCell:col row:row text:conten];
                                            [self setTextToCell:col row:row text:[dicCell objectForKey:@"conten"]];
                                            [self->tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                                                                       columnIndexes:[NSIndexSet indexSetWithIndex:col]];
                                        });
                                        
                                        //Jul 7, 2022 Erase devices
                                        NSThread *threadEraseDevice = [[NSThread alloc] initWithTarget:self selector:@selector(runEraseWhenReady:) object:dicCell];
                                        NSLog(@"%s CellHaveDevice ===========> threadEraseDevice %@ START", __func__, threadEraseDevice.name);
                                        if (threadEraseDevice.executing == false) {
                                            [threadEraseDevice start];
                                            [dicCell setObject:[NSNumber numberWithInt:0] forKey:@"counterTrust"];
                                        }
                                        mustReload = 1;
                                        NSLog(@"%s CellHaveDevice ===========> threadEraseDevice NEXT", __func__);
                                        
                                    }
                                }
                            } else {
                                conten = [NSString stringWithFormat:@"Checking device"];
                            }
                        }
                    }
                    else
                    {
                        conten = [NSString stringWithFormat:@"<b>Mac N/A<br>Serial:</b> N/A"];
                        NSLog(@"%s DBInfoUpdated 2", __func__);
                    }
                
                    mustReload = 1;
                    
                    [dicCell setObject:[NSNumber numberWithLong:checkInfoFlag] forKey:@"update_info"];// de check device van connect
                    
                }
                //conten = [NSString stringWithFormat:@"<p style=\"font-family:'Roboto-Regular';font-size:16px\">%@</p>",conten];
                
                [dicCell setObject:conten forKey:@"conten"];
                // [dicCell setObject:temp forKey:@"UniqueDeviceID"];
                
                //Add new May 5 2022 insert Realm Object
                if([[dicCell objectForKey:@"status"] intValue] == CellReady)
                {
                    NSLog(@"%s usb cap so:%d, item:%d",__func__,capso,n);
                }
                
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAttributedString * attrStr = [self showProccessed:[self countProccessed]];
            self->lbProcessed.attributedStringValue = attrStr;
        });
        
        NSLog(@"%s arrDatabaseCell: %@",__func__,arrDatabaseCell);
        
        return mustReload;
    }
}

- (NSString *) changeDateToString :(NSDate *)date format:(NSString*)Template
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSLocale *locale = [NSLocale currentLocale];
    NSString *dateFormat = @"yyyy-MM-dd hh:mm:ss";//[NSDateFormatter dateFormatFromTemplate:Template options:0 locale:locale];//@"dd-MM-yyyy hh:mm:ss"
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setLocale:locale];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

//-(int)getRandomNumberBetween:(int)from and:(int)to {
//    return (int)from + arc4random() % (to-from+1);
//}

-(int)sendInfoToCloud:(NSMutableDictionary *)dicCell process:(NSString *)process station:(NSString*)stationSerial result:(NSString *)restoreResult transactionID_Database:(NSString *)serialDevice error:(NSString *)strError
{
    
    @autoreleasepool {
        NSString *processTemp = process;
        NSLog(@"[sendInfoToCloud] ------- dicCell: %@", dicCell);
        NSMutableDictionary *dicInfo = [[dicCell objectForKey:@"info"] mutableCopy];
        if(dicInfo==nil)
        {
            NSLog(@"%s dic info null  %@",__func__,dicCell);
            return 0;
        }
        
        NSString *model = @"";
        if([dicInfo objectForKey:@"model"] != Nil)
        {
            model = [dicInfo objectForKey:@"model"];
        }
        NSString *ECID = @"";
        if([dicInfo objectForKey:@"ECID"] != Nil)
        {
            ECID = [dicInfo objectForKey:@"ECID"];
        }
        NSString *serialDevice = @"";
        if([dicInfo objectForKey:@"serial"] != Nil)
        {
            serialDevice = [dicInfo objectForKey:@"serial"];
        }
        else
        {
            NSString *strECID = [NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"ECID"]];
            if([self checkHaveSerial:dicCell]==NO)
            {
                NSMutableDictionary *infoSave = Nil;
                if([dicDataCellBK objectForKey:strECID]!=Nil)
                {
                    infoSave = [dicDataCellBK objectForKey:strECID];
                    if(infoSave)
                        dicInfo = [infoSave mutableCopy];
                    serialDevice = [dicInfo objectForKey:@"serial"];
                }
            }
        }
        if(strError==nil)
            strError = @"";
//        int randomNumber = [self getRandomNumberBetween:1000 and:9999];
        
//        NSString *transaction_id = [NSString stringWithFormat:@"%@%@%ld%d",stationSerial,[dicCell objectForKey:@"title"],(long)[[NSDate date] timeIntervalSince1970],randomNumber];
//        if([dicInfo objectForKey:@"transaction_id"])
//        {
//            transaction_id = [dicInfo objectForKey:@"transaction_id"];
//        }
//        else
//        {
//            [dicInfo setValue:transaction_id forKey:@"transaction_id"];
//            [dicCell setObject:dicInfo forKey:@"info"];
//        }
        
        NSLog(@"[sendInfoToCloud] proccess: %@ ------- dicInfo: %@", process, dicInfo);
        
        NSString *stateDFU = @"Booted";
        if([dicInfo objectForKey:@"state_dfu"])
            stateDFU = [dicInfo objectForKey:@"state_dfu"];
        
        NSMutableDictionary *dicDataSendToGCS = [[NSMutableDictionary alloc] init];
        NSDate *dateTmp = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSString *dateString = [dateFormat stringFromDate:dateTmp];
        [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm"];
        
        NSString *strdate = [self changeDateToString:dateTmp format:@"yyyy-MM-dd HH:mm:ss"];
        strdate = dateString;
        NSLog(@"[sendInfoToCloud] ------- processTemp: %@", processTemp);
        
        if([processTemp isEqualToString:@"start"])
        {
            //start
            NSLog(@"[sendInfoToCloud] START CASE strdate: %@",strdate);
            [dicInfo setObject:strdate forKey:@"time_start"];
            [dicCell setObject:dicInfo forKey:@"info"];
            
            NSString *strStart = [NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"time_start"]==nil?@"":[dicInfo objectForKey:@"time_start"]];
            NSString *cell = [dicCell objectForKey:@"title"];
            NSLog(@"[sendInfoToCloud] START CASE Cell: %@ time_start: %@", cell, strStart);
            
            [dicDataSendToGCS setObject:strStart forKey:@"time_start"];
            [dicDataSendToGCS setObject:@"" forKey:@"time_end"];
        }
        else
        {
            // end
            NSLog(@"[sendInfoToCloud] end strdate:%@",strdate);
            [dicInfo setObject:strdate forKey:@"time_end"];
            NSString *strStart = [NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"time_start"]==nil?@"":[dicInfo objectForKey:@"time_start"]];
            NSLog(@"[sendInfoToCloud] END CASE strStart strdate: %@", strStart);
            NSString *cell = [dicCell objectForKey:@"title"];
            NSLog(@"[sendInfoToCloud] END CASE Cell: %@ time_start: %@ time_end: %@", cell, strStart, strdate);
            [dicDataSendToGCS setObject:strStart forKey:@"time_start"];
            [dicDataSendToGCS setObject:strdate forKey:@"time_end"];
            [dicCell setObject:dicInfo forKey:@"info"];
            
        }
        
        [dicDataSendToGCS setObject:[NSString stringWithFormat:@"%@",[dicCell objectForKey:@"title"]] forKey:@"port"];
        [dicDataSendToGCS setObject:@"e_mac_ask_change" forKey:@"action"];
        [dicDataSendToGCS setObject:[NSNumber numberWithInt:30] forKey:@"command"];
        [dicDataSendToGCS setObject:model forKey:@"model"];//@"macbookpro11,5"
        [dicDataSendToGCS setObject:ECID forKey:@"ecid"];
        [dicDataSendToGCS setObject:stateDFU forKey:@"status"];//DFU or Booted
        [dicDataSendToGCS setObject:restoreResult forKey:@"restore_status"];//1:passed 0: failed "":NA
        [dicDataSendToGCS setObject:process forKey:@"restore_process"];//start or finished
        [dicDataSendToGCS setObject:model forKey:@"model_need_check_function"];
        [dicDataSendToGCS setObject:strError forKey:@"restore_error"];
        [dicDataSendToGCS setObject:@"" forKey:@"provision_uuid"];
        [dicDataSendToGCS setObject:serialDevice forKey:@"macbook_serial"];
        [dicDataSendToGCS setObject:stationSerial forKey:@"stationsn"];
        //[dicDataSendToGCS setObject:transaction_id forKey:@"transaction_id"];
        [dicDataSendToGCS setObject:VERSION forKey:@"sw_version"];
        [dicDataSendToGCS setObject:strdate forKey:@"time_local"];
        
        [dicDataSendToGCS setObject:txtLocationInfo.stringValue forKey:@"location"];
        [dicDataSendToGCS setObject:txtUserNameInfo.stringValue forKey:@"user_name"];
        [dicDataSendToGCS setObject:txtWorkAreaInfo.stringValue forKey:@"work_area"];
        [dicDataSendToGCS setObject:txtLineNumberInfo.stringValue forKey:@"line_number"];
        [dicDataSendToGCS setObject:txtBatchInfo.stringValue forKey:@"batch_number"];
        
        if([dicInfo objectForKey:@"serial"]!=nil)
        {
            NSString *serial = [NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"serial"]];
            [dicDataSendToGCS setObject:serial forKey:@"serial"];
        }
        NSError *err;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicDataSendToGCS options:NSJSONWritingPrettyPrinted error:&err];
        NSString *datastr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%s [GetServer][NSURLSessionDataTask] JSON = %@",__func__, datastr);
        NSString *dataSend = datastr;
        NSLog(@"%s [GetServer][NSURLSessionDataTask] JSON = %@",__func__, dataSend);
        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        NSMutableArray *array = delegate.arrServerLinks;
        //NSMutableArray *array = [[NSMutableArray alloc] init];
        if(array.count == 0)
        {
            NSLog(@"%s array count = 0",__func__);
            array = [[NSMutableArray alloc] init];
            [array addObject:@"http://pushing16.greystonedatatech.com/"];
            [array addObject:@"http://pushing17.greystonedatatech.com/"];
            [array addObject:@"http://pushing25.greystonedatatech.com/"];
            [array addObject:@"http://pushing9.greystonedatatech.com/"];
            [array addObject:@"http://pushing2.greystonedatatech.com/"];
            [array addObject:@"http://pushing30.greystonedatatech.com/"];
            [array addObject:@"http://pushing3.greystonedatatech.com/"];
        }
        
        int vt = 0;
        NSLog(@"%s_duyet_: server link array:\n%@",__func__,array);
        NSLog(@"%s_duyet_: dataSend:\n%@",__func__,dataSend);
        NSString *str =@"";
        for (int i=0; i<array.count; i++)
        {
            vt = rand()%array.count;
            NSString *server = [NSString stringWithFormat:@"%@emac.php",[array objectAtIndex:vt]];
            str = [delegate postToServer:server data:dataSend];
            NSLog(@"%s_duyet_: send result Finished to <%@> result data: %@",__func__,server,str);
            if(str.length > 0)
            {
                NSDictionary *dic = [delegate diccionaryFromJsonString:str];
                
                if(dic!=nil && [[dic objectForKey:@"status"] intValue] == 1)
                {
                    return 1;
                }
            }
        }
        return 0;
    }
    
}


-(void)setTextToCell:(NSInteger)col row:(NSInteger)row text:(NSString*)str
{
    @autoreleasepool {
        dispatch_async(dispatch_get_main_queue(), ^{
            CellTableClass *cellView = (CellTableClass*)[self->tableView viewAtColumn:col row:row makeIfNecessary:YES];
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithHTML:data baseURL:nil documentAttributes:nil];
            [[cellView.tvInfoDevice textStorage] setAttributedString:attributedString];
            cellView.tvInfoDevice.font = [NSFont fontWithName:@"Roboto-Regular" size:fontSizeCell];
        });
    }
}

-(void)setImageToCell:(NSInteger)col row:(NSInteger)row imageName:(NSString*)strImage
{
    CellTableClass *cellView = (CellTableClass*)[self->tableView viewAtColumn:col row:row makeIfNecessary:YES];
    cellView.imgResult.image = [NSImage imageNamed:strImage];
}

- (void) setResult:(int)result dic:(NSMutableDictionary *)dicCell
{
    [dicCell setObject:[NSNumber numberWithInt:result] forKey:@"result"];//0 passed,1 failed
    [dicCell setObject:[NSNumber numberWithInt:CellFinished] forKey:@"status"];
}

- (void) removeDevice:(int)vt
{
    @autoreleasepool {
        NSLog(@"%s PORT: %d",__func__,vt);
        NSMutableDictionary *dicCell = [arrDatabaseCell objectAtIndex:vt];
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        [dicCell setObject:options forKey:@"info"];
        // [dicCell setObject:@"<p style=\"font-family:'Roboto-Regular';font-size:16px\">No device</p>" forKey:@"conten"];
        [dicCell setObject:@"No device" forKey:@"conten"];
        [dicCell setObject:[NSNumber numberWithInt:0] forKey:@"update_info"];
        [dicCell setObject:@"" forKey:@"UniqueDeviceID"];
        [dicCell setObject:[NSNumber numberWithInt:CellNoDevice] forKey:@"status"];
        [dicCell setObject:[NSNumber numberWithInt:RESULT_NA] forKey:@"result"];
        [dicCell setObject:[NSNumber numberWithInt:0] forKey:@"TimeProccess"];
        [dicCell setObject:@"00:00:00" forKey:@"elapsedTime"];
        
        [dicCell setObject:[NSNumber numberWithInt:0] forKey:@"InfoUpdated"];
        //[dicCell setObject:[NSNumber numberWithInt:0] forKey:@"index"];
        [dicCell setObject:[NSNumber numberWithInt:0] forKey:@"counterTrust"];
        [dicCell setObject:[NSNumber numberWithInt:0] forKey:@"counterCellFinished"];
        [dicCell setObject:[NSNumber numberWithInt:0] forKey:@"counterCellRunning"];
        [dicCell setObject:[NSNumber numberWithInt:0] forKey:@"counterDisconnected"];
        [dicCell setObject:[NSNumber numberWithInt:CellNoDevice] forKey:@"isWaiting"];
        [dicCell setObject:[NSNumber numberWithInt:0] forKey:@"startTimerErase"];
        
        [dicCell setObject:@(VERIFY_NOTHING) forKey:@"update_erase_verify"];
        [dicCell setObject:@"" forKey:@"eraseID"];
        [dicCell setObject:@"" forKey:@"itemID"];
        [dicCell setObject:@"N/A" forKey:@"color_device"];
        [dicCell setObject:@"N/A" forKey:@"capacity_device"];
        [dicCell setObject:@"N/A" forKey:@"carrier_device"];
        [dicCell setObject:@"" forKey:@"note"];
        
        NSString *title = [dicCell objectForKey:@"title"];
        NSLog(@"Quyen:%@",[dicCell objectForKey:@"status"]);
        [dicCell removeObjectForKey:@"info"];
        // [dicCell setObject:[NSNumber numberWithInt:CellNoDevice] forKey:@"status"];
        
        [arrDatabaseCell replaceObjectAtIndex:vt withObject:dicCell];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            int row = [[dicCell objectForKey:@"row"] intValue];
            int col = [[dicCell objectForKey:@"col"] intValue];
            [self->tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                                       columnIndexes:[NSIndexSet indexSetWithIndex:col]];
        });
        [self setLedOnBoardOfCell:title color:LED_OFF];
        [self setUSB_State_OnBoardOfCell: title state: USB_POWER_ON];
    }
}


NSButton *btFile;
NSButton *btTools;
NSButton *btHelp;
-(void)drawHeader:(NSRect)rect
{
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    NSView *viewHeader = [[NSView alloc] initWithFrame:rect];
    viewHeader.wantsLayer = YES;
    viewHeader.layer.backgroundColor = delegate.colorBanner.CGColor;
    [self.view addSubview:viewHeader];
    
    //Menu buttons
    NSRect rectMenuButtonView = NSMakeRect(0, rect.size.height - 50, rect.size.width/6, 50);
    NSView *viewMenuButton = [[NSView alloc] initWithFrame:rectMenuButtonView];
    viewMenuButton.wantsLayer = YES;
    viewMenuButton.layer.backgroundColor = delegate.colorBanner.CGColor;
    
    [viewHeader addSubview:viewMenuButton];
    
    
    NSColor *color = [NSColor whiteColor];
    //File
    btFile = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, rectMenuButtonView.size.width/3, 50)];
    btFile.font = [NSFont systemFontOfSize:20];
    btFile.title = @"File";
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[btFile attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
    [btFile setToolTip:@"File"];
    btFile.wantsLayer = NO;
    btFile.layer.backgroundColor = delegate.colorBanner.CGColor;
    btFile.bordered = NO;
    [btFile setAttributedTitle:colorTitle];
    [btFile setTarget:self];
    [btFile setAction:@selector(btFileClick:)];
    
    // Insert code here to initialize your application
    NSTrackingArea* trackingAreaFile = [[NSTrackingArea alloc]
                                        initWithRect:[btFile bounds]
                                        options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                        owner:self userInfo:@"btFile"];
    
    [btFile addTrackingArea:trackingAreaFile];
    
    [viewMenuButton addSubview:btFile];
    //    //Tools
    //    btTools = [[NSButton alloc] initWithFrame:NSMakeRect(rectMenuButtonView.size.width/3, 0, rectMenuButtonView.size.width/3, 50)];
    //    btTools.font = [NSFont systemFontOfSize:20];
    //    btTools.title = @"Tools";
    //    colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[btTools attributedTitle]];
    //    titleRange = NSMakeRange(0, [colorTitle length]);
    //    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
    //    [btTools setToolTip:@"Tools"];
    //    btTools.wantsLayer = YES;
    //    btTools.layer.backgroundColor = delegate.colorBanner.CGColor;
    //    btTools.bordered = NO;
    //    [btTools setAttributedTitle:colorTitle];
    //
    //    [btTools setTarget:self];
    //    [btTools setAction:@selector(btToolsClick:)];
    //
    //    NSTrackingArea* trackingAreaTools = [[NSTrackingArea alloc]
    //                                         initWithRect:[btTools bounds]
    //                                         options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
    //                                         owner:self userInfo:@"btTools"];
    //    [btTools addTrackingArea:trackingAreaTools];
    //
    //    [viewMenuButton addSubview:btTools];
    //Help
    // btHelp = [[NSButton alloc] initWithFrame:NSMakeRect(2*rectMenuButtonView.size.width/3, 0, rectMenuButtonView.size.width/3, 50)];
    btHelp = [[NSButton alloc] initWithFrame:NSMakeRect(rectMenuButtonView.size.width/3, 0, rectMenuButtonView.size.width/3, 50)];
    btHelp.font = [NSFont systemFontOfSize:20];
    btHelp.title = @"Help";
    colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[btHelp attributedTitle]];
    titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
    [btHelp setToolTip:@"Help"];
    btHelp.wantsLayer = YES;
    btHelp.layer.backgroundColor = delegate.colorBanner.CGColor;
    btHelp.bordered = NO;
    [btHelp setTarget:self];
    [btHelp setAction:@selector(btHelpClick:)];
    [btHelp setAttributedTitle:colorTitle];
    
    NSTrackingArea* trackingAreaHelp = [[NSTrackingArea alloc]
                                        initWithRect:[btHelp bounds]
                                        options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                        owner:self userInfo:@"btHelp"];
    [btHelp addTrackingArea:trackingAreaHelp];
    
    [viewMenuButton addSubview:btTools];
    [viewMenuButton addSubview:btHelp];
    
    
    
    
    
    NSTextField *txtHeader = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 0, rect.size.width/2, 50)];
    txtHeader.alignment = NSTextAlignmentLeft;
    txtHeader.cell = [[UITextFieldCell alloc] init];
    txtHeader.stringValue = @"iCombine Watch";
    [txtHeader setEditable:NO];
    txtHeader.backgroundColor = [NSColor clearColor];
    txtHeader.font = [NSFont boldSystemFontOfSize:20];
    txtHeader.drawsBackground = YES;
    txtHeader.textColor = [NSColor whiteColor];
    //[viewHeader addSubview:txtHeader];
    
    
    
    
    NSButton *btLogout = [[NSButton alloc] initWithFrame:NSMakeRect(rect.size.width - 200,5, 190, 40)];
    btLogout.image = [NSImage imageNamed:@"user.png"];
    btLogout.imagePosition = NSImageLeft;
    btLogout.imageScaling = NSImageScaleProportionallyUpOrDown;
    btLogout.title = [NSString stringWithFormat:@" %@",delegate.userName];
    btLogout.alignment = NSTextAlignmentLeft;
    [btLogout.cell setBackgroundColor:delegate.colorBanner];
    NSMutableAttributedString *atribute = [delegate setColorTitleFor:btLogout color:[NSColor whiteColor] size:18];
    [btLogout setAttributedTitle:atribute];
    btLogout.layer.borderWidth = 0.0;
    btLogout.layer.cornerRadius = 4.0;
    btLogout.wantsLayer = YES;
    [btLogout setToolTip:@"Logout"];
    btLogout.bordered = NO;
    [btLogout setTarget:self];
    [btLogout setAction:@selector(btLogoutClick:)];
    [viewHeader addSubview:btLogout];
    
    [viewHeader setNeedsDisplay:YES];
}
-(void)drawFooter:(NSRect)rect
{
    NSView *viewFooter = [[NSView alloc] initWithFrame:rect];
    viewFooter.wantsLayer = YES;
    viewFooter.layer.backgroundColor = [NSColor colorWithRed:0xDA*1.0/255 green:0xDA*1.0/255 blue:0xDA*1.0/255 alpha:1.0].CGColor;
    [self.view addSubview:viewFooter];
    
    NSButton *btLogout = [[NSButton alloc] initWithFrame:NSMakeRect(rect.size.width - 110,5, 100, 40)];
    btLogout.image = [NSImage imageNamed:@"logout.png"];
    btLogout.imagePosition = NSImageLeft;
    btLogout.imageScaling = NSImageScaleProportionallyUpOrDown;
    btLogout.title = @"Logout";
    btLogout.layer.borderColor = [NSColor blackColor].CGColor;
    btLogout.layer.borderWidth = 1.0;
    btLogout.layer.cornerRadius = 4.0;
    btLogout.hidden = YES;
    [btLogout setToolTip:@"Logout"];
    [btLogout setTarget:self];
    [btLogout setAction:@selector(btLogoutClick:)];
    [viewFooter addSubview:btLogout];
    
    int fontsize = 18;
    
    lbConnectGCSLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(10,10, 400, 25)];
    lbConnectGCSLabel.alignment = NSTextAlignmentLeft;
    lbConnectGCSLabel.cell = [[NSTextFieldCell alloc] init];
    lbConnectGCSLabel.font = [NSFont fontWithName:@"HelveticaNeue" size:fontsize];
    lbConnectGCSLabel.stringValue = @"The connection to GCS Server established...";
    //    lbConnectGCSLabel.font = [NSFont systemFontOfSize:fontsize];
    [lbConnectGCSLabel setEditable:NO];
    lbConnectGCSLabel.backgroundColor = [NSColor clearColor];
    lbConnectGCSLabel.drawsBackground = NO;
    lbConnectGCSLabel.bordered = NO;
    lbConnectGCSLabel.textColor = [NSColor blackColor];
    [viewFooter addSubview:lbConnectGCSLabel];
    
    //numDevice = 0;
    
    
    NSAttributedString * attrStr = [self showProccessed:[self countProccessed]];
    
    lbProcessed = [[NSTextField alloc] initWithFrame:NSMakeRect(rect.size.width/2-100,18, 200, 25)];
    lbProcessed.alignment = NSTextAlignmentCenter;
    //    lbProcessed.cell = [[UITextFieldCell alloc] init];
    //    lbProcessed.font = [NSFont systemFontOfSize:fontsize];
    lbProcessed.cell = [[NSTextFieldCell alloc] init];
    lbProcessed.font = [NSFont fontWithName:@"HelveticaNeue" size:fontsize];
    lbProcessed.attributedStringValue = attrStr;
    [lbProcessed setEditable:NO];
    lbProcessed.backgroundColor = [NSColor clearColor];
    lbProcessed.drawsBackground = NO;
    lbProcessed.bordered = NO;
    lbProcessed.textColor = [NSColor blackColor];
    [viewFooter addSubview:lbProcessed];
    
    
    
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSButton *btStation = [[NSButton alloc] initWithFrame:NSMakeRect(rect.size.width-455,5, 450, 40)];
    btStation.title = [NSString stringWithFormat:@"[iCombine Mac Station] - [%@] - [%@]",delegate.mMacAddress,VERSION];
    btStation.font = [NSFont fontWithName:@"Roboto-Medium" size:fontsize];//[NSFont systemFontOfSize:fontsize];
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[btStation attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:67.0/255 green:155.0/255 blue:71.0/255 alpha:1.0] range:titleRange];
    [btStation setAttributedTitle:colorTitle];
    btStation.wantsLayer = YES;
    btStation.layer.borderWidth = 2.0;
    btStation.layer.borderColor = [NSColor colorWithRed:67.0/255 green:155.0/255 blue:71.0/255 alpha:1.0].CGColor;
    btStation.layer.cornerRadius = 4.0;
    [btStation setToolTip:@"Station"];
    [btStation setTarget:self];
    [btStation setAction:@selector(btStationClick:)];
    [viewFooter addSubview:btStation];
}
- (int)countProccessed
{
    int count = 0;
    for (int i=0; i<arrDatabaseCell.count; i++)
    {
        NSMutableDictionary *dic = (NSMutableDictionary *)[arrDatabaseCell objectAtIndex:i];
        if([[dic objectForKey:@"status"] intValue] == CellFinished)
        {
            count++;
        }
    }
    return count;
}

-(NSAttributedString *)showProccessed:(int)numDevice
{
    int fontsize = 18;
    NSString * htmlString = [NSString stringWithFormat:@"<html><body><span style='font-size:%dpx'>Processed </span><span style='font-size:%dpx'><b>%d</b></span><span style='font-size:%dpx'> device</span></body></html>",fontsize,fontsize+4,numDevice,fontsize];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    return attrStr;
}

NSTextField *txtBatchInfo;
NSTextField *txtWorkAreaInfo;
NSTextField *txtLineNumberInfo;
NSTextField *txtUserNameInfo;
NSTextField *txtLocationInfo;
-(void)drawMainScreen:(NSRect)rect
{
    
    NSLog(@"%s Started ==================================================> drawMainScreen ",__func__);
    
    NSColor *colorCFBG = [NSColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0];
    NSView *viewConten = [[NSView alloc] initWithFrame:rect];
    viewConten.wantsLayer = YES;
    viewConten.layer.backgroundColor = [NSColor brownColor].CGColor;
    [self.view addSubview:viewConten];
    //    ======================================================================list button right========================================
    int widthToolCustomField = 300;
    
    NSView *viewPrintToolsCustomField = [[NSView alloc] initWithFrame:NSMakeRect(rect.size.width - widthToolCustomField, 0, widthToolCustomField, rect.size.height)];
    // Debug show backgroud July 18, 2022
    viewPrintToolsCustomField.wantsLayer = YES;
    viewPrintToolsCustomField.layer.backgroundColor = colorCFBG.CGColor;
    //viewPrintToolsCustomField.layer.backgroundColor  = NSColor.redColor.CGColor;
    [viewConten addSubview:viewPrintToolsCustomField];
    
    int spaceUpper2MainView = 35;
    //int spaceUpperDefault = 50;
    int spaceUpperDefault = 35;
    int widthOfLogo = 180;
    //heightOfLogo = 100;
    int heightOfLogo = 170;
    
    NSImageView *imageLogo = [[NSImageView alloc] initWithFrame:NSMakeRect((widthToolCustomField - widthOfLogo)/2 , rect.size.height - heightOfLogo - spaceUpper2MainView, widthOfLogo, heightOfLogo)];
    imageLogo.image = [NSImage imageNamed:@"logoLeft"];
    // Debug show backgroud July 18, 2022
    imageLogo.wantsLayer = YES;
    //imageLogo.layer.backgroundColor  = NSColor.greenColor.CGColor;
    [viewPrintToolsCustomField addSubview:imageLogo];
    
    //    ======================================== group Item ID input
    NSView *groupBoxItemIDInput =[[NSView alloc] initWithFrame:NSMakeRect((widthToolCustomField - 280)/2 , rect.size.height - imageLogo.frame.size.height - spaceUpperDefault - 80, 280, 80)];
    //    groupBoxItemIDInput.wantsLayer = YES;
    //    groupBoxItemIDInput.layer.borderWidth = 0;
    //    groupBoxItemIDInput.layer.borderColor = [NSColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0].CGColor;
    //    groupBoxItemIDInput.layer.backgroundColor =[NSColor clearColor].CGColor;
    //    [viewConfig addSubview:groupBoxItemIDInput];
    //
    //    NSTextField *lbItemID = [[NSTextField alloc] initWithFrame:NSMakeRect(0, groupBoxItemIDInput.frame.size.height - 2*groupBoxItemIDInput.frame.size.height/3, 100, 30)];
    //    lbItemID.alignment = NSTextAlignmentCenter;
    //    lbItemID.cell = [[UITextFieldCell alloc] init];
    //    lbItemID.stringValue = @"Item ID";
    //    [lbItemID setEditable:NO];
    //    lbItemID.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    //    lbItemID.backgroundColor = colorCFBG;
    //    lbItemID.drawsBackground = YES;
    //    lbItemID.textColor = [NSColor blackColor];
    //    [groupBoxItemIDInput addSubview:lbItemID];
    
    //    txtItemID = [[NSTextField alloc] initWithFrame:NSMakeRect((configWidth - 180)/2, groupBoxItemIDInput.frame.size.height - 2*groupBoxItemIDInput.frame.size.height/3, groupBoxItemIDInput.frame.size.width - 80, groupBoxItemIDInput.frame.size.height/3)];
    //    txtItemID.cell = [[NSTextFieldCell alloc] init];
    //    [groupBoxItemIDInput addSubview:txtItemID];
    //    [txtItemID.cell setFocusRingType:NSFocusRingTypeNone];
    //    txtItemID.alignment = NSTextAlignmentLeft;
    //    txtItemID.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    //    txtItemID.bordered = YES;
    //    txtItemID.wantsLayer = YES;
    //    txtItemID.layer.borderColor = [NSColor blackColor].CGColor;
    //    txtItemID.editable = YES;
    //    txtItemID.backgroundColor = [NSColor redColor];
    //    txtItemID.layer.cornerRadius = 5;
    //    txtItemID.layer.borderWidth = 1;
    //    txtItemID.layer.backgroundColor = [NSColor whiteColor].CGColor;
    //    txtItemID.stringValue = @"";
    //    txtItemID.delegate = self;
    
    
    //    lbPleaseScanItemID = [[NSTextField alloc] initWithFrame:NSMakeRect((configWidth - 180)/2, groupBoxItemIDInput.frame.size.height - 3*groupBoxItemIDInput.frame.size.height/3, groupBoxItemIDInput.frame.size.width - 80, 30)];
    //    lbPleaseScanItemID.alignment = NSTextAlignmentCenter;
    //    lbPleaseScanItemID.cell = [[UITextFieldCell alloc] init];
    //    lbPleaseScanItemID.stringValue = @"Please scan Item ID!";
    //    [lbPleaseScanItemID setEditable:NO];
    //    lbPleaseScanItemID.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    //    lbPleaseScanItemID.backgroundColor = colorCFBG;
    //    lbPleaseScanItemID.drawsBackground = YES;
    //    lbPleaseScanItemID.textColor = [NSColor redColor];
    //    lbPleaseScanItemID.alignment = NSTextAlignmentCenter;
    //    [groupBoxItemIDInput addSubview:lbPleaseScanItemID];
    
    
    //    ========================================  Print label Group
    int yCoordinateGBPrintLabel = rect.size.height - spaceUpper2MainView - imageLogo.frame.size.height - spaceUpperDefault - groupBoxItemIDInput.frame.size.height - 120;
    int heightCoordinateGBPrintLabel = 85;
    yCoordinateGBPrintLabel = rect.size.height - spaceUpper2MainView - imageLogo.frame.size.height - spaceUpperDefault - heightCoordinateGBPrintLabel;
    
    int spaceBetweenToolsButtons = 35;
    int heightOfOneToolButton = 35;
    int heightOfGroupBoxPrintLabel = 85;
    
    NSView *groupBoxPrintLabel =[[NSView alloc] initWithFrame:NSMakeRect((widthToolCustomField - 280)/2 , yCoordinateGBPrintLabel, 280, heightOfGroupBoxPrintLabel)];
    groupBoxPrintLabel.wantsLayer = YES;
    groupBoxPrintLabel.layer.borderWidth = 1;
    groupBoxPrintLabel.layer.borderColor = [NSColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0].CGColor;
    groupBoxPrintLabel.layer.backgroundColor =[NSColor clearColor].CGColor;
    [viewPrintToolsCustomField addSubview:groupBoxPrintLabel];
    
    NSTextField *txtHeaderGroupPrintLabel = [[NSTextField alloc] initWithFrame:NSMakeRect((widthToolCustomField - 280), yCoordinateGBPrintLabel + heightOfGroupBoxPrintLabel - 30/2, 100, 30)];
    txtHeaderGroupPrintLabel.alignment = NSTextAlignmentCenter;
    txtHeaderGroupPrintLabel.cell = [[UITextFieldCell alloc] init];
    txtHeaderGroupPrintLabel.stringValue = @"   Print label";
    [txtHeaderGroupPrintLabel setEditable:NO];
    txtHeaderGroupPrintLabel.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtHeaderGroupPrintLabel.backgroundColor = colorCFBG;
    txtHeaderGroupPrintLabel.drawsBackground = YES;
    txtHeaderGroupPrintLabel.textColor = [NSColor blackColor];
    [viewPrintToolsCustomField addSubview:txtHeaderGroupPrintLabel];
    
    
    UIButton *btPrintLabel = [[UIButton alloc] initWithFrame:NSMakeRect(40, heightOfGroupBoxPrintLabel - heightOfOneToolButton - spaceBetweenToolsButtons, 200, heightOfOneToolButton)];
    btPrintLabel.title = @"";
    [[btPrintLabel cell] setBackgroundColor:colorCFBG];
    [btPrintLabel setImage:[NSImage imageNamed:@"bt_print_label_normal.png"]];
    [btPrintLabel sizeToFit];
    btPrintLabel.layer.cornerRadius = 10;
    [btPrintLabel setBordered:NO];
    [btPrintLabel setToolTip:@"Print Label"];
    [btPrintLabel setTarget:self];
    [btPrintLabel setAction:@selector(btPrintLabeltClick:)];
    [groupBoxPrintLabel addSubview:btPrintLabel];
    btPrintLabel.enabled = false;
    
    //    ======================================== Tools Group
    int heightOfToolsAndCustomField = rect.size.height - spaceUpper2MainView - imageLogo.frame.size.height - spaceUpperDefault - spaceUpperDefault - groupBoxPrintLabel.frame.size.height - spaceBetweenToolsButtons;
    
    int mHeightTool = heightOfToolsAndCustomField/2;
    
    int yCoordinate = rect.size.height - spaceUpper2MainView/2 - imageLogo.frame.size.height - spaceUpperDefault - spaceUpperDefault - groupBoxPrintLabel.frame.size.height - mHeightTool;
    NSView *groupBoxTool =[[NSView alloc] initWithFrame:NSMakeRect((widthToolCustomField - 280)/2, yCoordinate, 280, mHeightTool)];
    groupBoxTool.wantsLayer = YES;
    groupBoxTool.layer.borderWidth = 1;
    groupBoxTool.layer.borderColor = [NSColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0].CGColor;
    groupBoxTool.layer.backgroundColor =[NSColor clearColor].CGColor;
    [viewPrintToolsCustomField addSubview:groupBoxTool];
    groupBoxTool.hidden = NO;
    
    NSTextField *txtHeaderGroupTool = [[NSTextField alloc] initWithFrame:NSMakeRect((widthToolCustomField - 280), yCoordinate + mHeightTool - 30/2, 60, 30)];
    txtHeaderGroupTool.alignment = NSTextAlignmentCenter;
    txtHeaderGroupTool.cell = [[UITextFieldCell alloc] init];
    txtHeaderGroupTool.stringValue = @"   Tools";
    [txtHeaderGroupTool setEditable:NO];
    txtHeaderGroupTool.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtHeaderGroupTool.backgroundColor = colorCFBG;
    txtHeaderGroupTool.drawsBackground = YES;
    txtHeaderGroupTool.textColor = [NSColor blackColor];
    [viewPrintToolsCustomField addSubview:txtHeaderGroupTool];
    
    
    
    
    //UIButton *btEraseAll = [[UIButton alloc] initWithFrame:NSMakeRect(40, mHeightTool - 80, 200, 44)];
    
    // Debug show backgroud July 18, 2022
    UIButton *btEraseAll = [[UIButton alloc] initWithFrame:NSMakeRect(40, mHeightTool - spaceBetweenToolsButtons - heightOfOneToolButton, 200, heightOfOneToolButton)];
    
    
    btEraseAll.title = @"";
    [[btEraseAll cell] setBackgroundColor:colorCFBG];
    [btEraseAll setImage:[NSImage imageNamed:@"bt_eraseall_normal.png"]];
    [btEraseAll sizeToFit];
    btEraseAll.layer.cornerRadius = 10;
    [btEraseAll setBordered:NO];
    [btEraseAll setToolTip:@"Start all"];
    [btEraseAll setTarget:self];
    [btEraseAll setAction:@selector(btEraseAllClick:)];
    [groupBoxTool addSubview:btEraseAll];
    btEraseAll.enabled = false;
    
    
    //UIButton *btStopAll = [[UIButton alloc] initWithFrame:NSMakeRect(40, mHeightTool - 150, 200, 44)];
    // Debug show backgroud July 18, 2022
    UIButton *btStopAll = [[UIButton alloc] initWithFrame:NSMakeRect(40, mHeightTool - 2*spaceBetweenToolsButtons - 2*heightOfOneToolButton, 200, heightOfOneToolButton)];
    
    btStopAll.title = @"";
    [[btStopAll cell] setBackgroundColor:colorCFBG];
    [btStopAll setImage:[NSImage imageNamed:@"bt_stopall_normal.png"]];
    [btStopAll sizeToFit];
    btStopAll.layer.cornerRadius = 10;
    [btStopAll setBordered:NO];
    [btStopAll setToolTip:@"Stop all"];
    [btStopAll setTarget:self];
    [btStopAll setAction:@selector(btStopAllClick:)];
    [groupBoxTool addSubview:btStopAll];
    btStopAll.enabled = false;
    
    //UIButton *btRescan = [[UIButton alloc] initWithFrame:NSMakeRect(40, mHeightTool - 220, 200, 44)];
    // Debug show backgroud July 18, 2022
    UIButton *btRescan = [[UIButton alloc] initWithFrame:NSMakeRect(40, mHeightTool - 3*spaceBetweenToolsButtons - 3*heightOfOneToolButton, 200, heightOfOneToolButton)];
    btRescan.title = @"";
    [[btRescan cell] setBackgroundColor:colorCFBG];
    [btRescan setImage:[NSImage imageNamed:@"bt_rescan_device_normal.png"]];
    [btRescan sizeToFit];
    btRescan.layer.cornerRadius = 10;
    [btRescan setBordered:NO];
    [btRescan setToolTip:@"Rescan device"];
    [btRescan setTarget:self];
    [btRescan setAction:@selector(btRescanClick:)];
    [groupBoxTool addSubview:btRescan];
    btRescan.enabled = false;
    
    
    //UIButton *btReports = [[UIButton alloc] initWithFrame:NSMakeRect(40, mHeightTool - 290, 200, 44)];
    // Debug show backgroud July 18, 2022
    UIButton *btReports = [[UIButton alloc] initWithFrame:NSMakeRect(40, mHeightTool - 4*spaceBetweenToolsButtons - 4*heightOfOneToolButton, 200, 44)];
    btReports.title = @"";
    [[btReports cell] setBackgroundColor:colorCFBG];
    [btReports setImage:[NSImage imageNamed:@"bt_report_normal.png"]];
    [btReports sizeToFit];
    btReports.layer.cornerRadius = 10;
    [btReports setBordered:NO];
    [btReports setToolTip:@"Reports"];
    [btReports setTarget:self];
    [btReports setAction:@selector(btReportsClick:)];
    [groupBoxTool addSubview:btReports];
    btReports.enabled = false;
    
    //=================================================== Custom Field =====================================================
    int heightOfCustomField = heightOfToolsAndCustomField/2 + spaceUpperDefault/2 + spaceUpperDefault/3;
    int yCoordinateGroupCustomField = groupBoxTool.frame.origin.y - heightOfCustomField - spaceBetweenToolsButtons/2;
    
    NSView *groupCustomField =[[NSView alloc] initWithFrame:NSMakeRect((widthToolCustomField - 280)/2, yCoordinateGroupCustomField, 280, heightOfCustomField)];
    groupCustomField.wantsLayer = YES;
    groupCustomField.layer.borderWidth = 1;
    groupCustomField.layer.borderColor = [NSColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0].CGColor;
    groupCustomField.layer.backgroundColor =[NSColor clearColor].CGColor;
    [viewPrintToolsCustomField addSubview:groupCustomField];
    groupCustomField.hidden = NO;
    
    NSTextField *txtHeaderCustomField = [[NSTextField alloc] initWithFrame:NSMakeRect((widthToolCustomField - 280), yCoordinateGroupCustomField + heightOfCustomField - 30/2, 120, 30)];
    txtHeaderCustomField.alignment = NSTextAlignmentCenter;
    txtHeaderCustomField.cell = [[UITextFieldCell alloc] init];
    txtHeaderCustomField.stringValue = @"   Custom Fields";
    [txtHeaderCustomField setEditable:NO];
    txtHeaderCustomField.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtHeaderCustomField.backgroundColor = colorCFBG;
    txtHeaderCustomField.drawsBackground = YES;
    txtHeaderCustomField.textColor = [NSColor blackColor];
    [viewPrintToolsCustomField addSubview:txtHeaderCustomField];
    
    
    int spaceBetweenToolsField = 25;
    int spaceBetweenFieldToGroupCustomField = 15;
    
    NSTextField *txtBatch = [[NSTextField alloc] initWithFrame:NSMakeRect(spaceBetweenFieldToGroupCustomField - 5, groupCustomField.frame.size.height - spaceBetweenToolsField - heightOfOneToolButton, groupCustomField.frame.size.width/3, heightOfOneToolButton)];
    txtBatch.alignment = NSTextAlignmentCenter;
    txtBatch.cell = [[UITextFieldCell alloc] init];
    txtBatch.stringValue = @"Batch #";
    [txtBatch setEditable:NO];
    txtBatch.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtBatch.wantsLayer = YES;
    txtBatch.backgroundColor = colorCFBG;
    txtBatch.drawsBackground = YES;
    txtBatch.textColor = [NSColor blackColor];
    [groupCustomField addSubview:txtBatch];
    
    txtBatchInfo = [[NSTextField alloc] initWithFrame:NSMakeRect(spaceBetweenFieldToGroupCustomField + txtBatch.frame.size.width, groupCustomField.frame.size.height - spaceBetweenToolsField - heightOfOneToolButton, 2*groupCustomField.frame.size.width/3 - 2*spaceBetweenFieldToGroupCustomField, heightOfOneToolButton)];
    txtBatchInfo.alignment = NSTextAlignmentCenter;
    txtBatchInfo.cell = [[UITextFieldCell alloc] init];
    [txtBatchInfo.cell setFocusRingType:NSFocusRingTypeNone];
    txtBatchInfo.alignment = NSTextAlignmentLeft;
    txtBatchInfo.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtBatchInfo.bordered = YES;
    txtBatchInfo.wantsLayer = YES;
    txtBatchInfo.layer.borderColor = [NSColor blackColor].CGColor;
    txtBatchInfo.editable = YES;
    txtBatchInfo.layer.cornerRadius = 0;
    txtBatchInfo.layer.borderWidth = 0.5;
    txtBatchInfo.layer.backgroundColor = [NSColor whiteColor].CGColor;
    txtBatchInfo.stringValue = @"";
    [groupCustomField addSubview:txtBatchInfo];
    
    
    NSTextField *txtWorkArea = [[NSTextField alloc] initWithFrame:NSMakeRect(spaceBetweenFieldToGroupCustomField - 5, groupCustomField.frame.size.height - 2*spaceBetweenToolsField - 2*heightOfOneToolButton, groupCustomField.frame.size.width/3, heightOfOneToolButton)];
    txtWorkArea.alignment = NSTextAlignmentCenter;
    txtWorkArea.cell = [[UITextFieldCell alloc] init];
    txtWorkArea.stringValue = @"Work Area";
    [txtWorkArea setEditable:NO];
    txtWorkArea.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtWorkArea.backgroundColor = colorCFBG;
    txtWorkArea.wantsLayer = YES;
    txtWorkArea.drawsBackground = YES;
    txtWorkArea.textColor = [NSColor blackColor];
    [groupCustomField addSubview:txtWorkArea];
    
    txtWorkAreaInfo = [[NSTextField alloc] initWithFrame:NSMakeRect(spaceBetweenFieldToGroupCustomField + txtBatch.frame.size.width, groupCustomField.frame.size.height - 2*spaceBetweenToolsField - 2*heightOfOneToolButton, 2*groupCustomField.frame.size.width/3 - 2*spaceBetweenFieldToGroupCustomField, heightOfOneToolButton)];
    txtWorkAreaInfo.alignment = NSTextAlignmentCenter;
    txtWorkAreaInfo.cell = [[UITextFieldCell alloc] init];
    [txtWorkAreaInfo.cell setFocusRingType:NSFocusRingTypeNone];
    txtWorkAreaInfo.alignment = NSTextAlignmentLeft;
    txtWorkAreaInfo.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtWorkAreaInfo.bordered = YES;
    txtWorkAreaInfo.wantsLayer = YES;
    txtWorkAreaInfo.layer.borderColor = [NSColor blackColor].CGColor;
    txtWorkAreaInfo.editable = YES;
    txtWorkAreaInfo.layer.cornerRadius = 0;
    txtWorkAreaInfo.layer.borderWidth = 0.5;
    txtWorkAreaInfo.layer.backgroundColor = [NSColor whiteColor].CGColor;
    txtWorkAreaInfo.stringValue = @"";
    [groupCustomField addSubview:txtWorkAreaInfo];
    
    NSTextField *txtLineNumber = [[NSTextField alloc] initWithFrame:NSMakeRect(spaceBetweenFieldToGroupCustomField - 5, groupCustomField.frame.size.height - 3*spaceBetweenToolsField - 3*heightOfOneToolButton, groupCustomField.frame.size.width/3, heightOfOneToolButton)];
    txtLineNumber.alignment = NSTextAlignmentCenter;
    txtLineNumber.cell = [[UITextFieldCell alloc] init];
    txtLineNumber.stringValue = @"Line number";
    [txtLineNumber setEditable:NO];
    txtLineNumber.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtLineNumber.backgroundColor = colorCFBG;
    txtLineNumber.drawsBackground = YES;
    txtLineNumber.textColor = [NSColor blackColor];
    [groupCustomField addSubview:txtLineNumber];
    
    txtLineNumberInfo = [[NSTextField alloc] initWithFrame:NSMakeRect(spaceBetweenFieldToGroupCustomField + txtBatch.frame.size.width, groupCustomField.frame.size.height - 3*spaceBetweenToolsField - 3*heightOfOneToolButton, 2*groupCustomField.frame.size.width/3 - 2*spaceBetweenFieldToGroupCustomField, heightOfOneToolButton)];
    txtLineNumberInfo.alignment = NSTextAlignmentCenter;
    txtLineNumberInfo.cell = [[UITextFieldCell alloc] init];
    [txtLineNumberInfo.cell setFocusRingType:NSFocusRingTypeNone];
    txtLineNumberInfo.alignment = NSTextAlignmentLeft;
    txtLineNumberInfo.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtLineNumberInfo.bordered = YES;
    txtLineNumberInfo.wantsLayer = YES;
    txtLineNumberInfo.layer.borderColor = [NSColor blackColor].CGColor;
    txtLineNumberInfo.editable = YES;
    txtLineNumberInfo.layer.cornerRadius = 0;
    txtLineNumberInfo.layer.borderWidth = 0.5;
    txtLineNumberInfo.layer.backgroundColor = [NSColor whiteColor].CGColor;
    txtLineNumberInfo.stringValue = @"";
    [groupCustomField addSubview:txtLineNumberInfo];
    
    
    NSTextField *txtUserName = [[NSTextField alloc] initWithFrame:NSMakeRect(spaceBetweenFieldToGroupCustomField - 5, groupCustomField.frame.size.height - 4*spaceBetweenToolsField - 4*heightOfOneToolButton, groupCustomField.frame.size.width/3, heightOfOneToolButton)];
    txtUserName.alignment = NSTextAlignmentCenter;
    txtUserName.cell = [[UITextFieldCell alloc] init];
    txtUserName.stringValue = @"Username";
    [txtUserName setEditable:NO];
    txtUserName.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtUserName.backgroundColor = colorCFBG;
    txtUserName.drawsBackground = YES;
    txtUserName.textColor = [NSColor blackColor];
    [groupCustomField addSubview:txtUserName];
    
    txtUserNameInfo = [[NSTextField alloc] initWithFrame:NSMakeRect(spaceBetweenFieldToGroupCustomField + txtBatch.frame.size.width, groupCustomField.frame.size.height - 4*spaceBetweenToolsField - 4*heightOfOneToolButton,  2*groupCustomField.frame.size.width/3 - 2*spaceBetweenFieldToGroupCustomField, heightOfOneToolButton)];
    txtUserNameInfo.alignment = NSTextAlignmentCenter;
    txtUserNameInfo.cell = [[UITextFieldCell alloc] init];
    [txtUserNameInfo.cell setFocusRingType:NSFocusRingTypeNone];
    txtUserNameInfo.alignment = NSTextAlignmentLeft;
    txtUserNameInfo.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtUserNameInfo.bordered = YES;
    txtUserNameInfo.wantsLayer = YES;
    txtUserNameInfo.layer.borderColor = [NSColor blackColor].CGColor;
    txtUserNameInfo.editable = YES;
    txtUserNameInfo.layer.cornerRadius = 0;
    txtUserNameInfo.layer.borderWidth = 0.5;
    txtUserNameInfo.layer.backgroundColor = [NSColor whiteColor].CGColor;
    txtUserNameInfo.stringValue = @"";
    [groupCustomField addSubview:txtUserNameInfo];
    
    
    NSTextField *txtLocation = [[NSTextField alloc] initWithFrame:NSMakeRect(spaceBetweenFieldToGroupCustomField - 5, groupCustomField.frame.size.height - 5*spaceBetweenToolsField - 5*heightOfOneToolButton, groupCustomField.frame.size.width/3, heightOfOneToolButton)];
    txtLocation.alignment = NSTextAlignmentCenter;
    txtLocation.cell = [[UITextFieldCell alloc] init];
    txtLocation.stringValue = @"Location";
    [txtLocation setEditable:NO];
    txtLocation.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtLocation.backgroundColor = colorCFBG;
    txtLocation.drawsBackground = YES;
    txtLocation.textColor = [NSColor blackColor];
    [groupCustomField addSubview:txtLocation];
    
    txtLocationInfo = [[NSTextField alloc] initWithFrame:NSMakeRect(spaceBetweenFieldToGroupCustomField + txtBatch.frame.size.width, groupCustomField.frame.size.height - 5*spaceBetweenToolsField - 5*heightOfOneToolButton, 2*groupCustomField.frame.size.width/3 - 2*spaceBetweenFieldToGroupCustomField, heightOfOneToolButton)];
    txtLocationInfo.alignment = NSTextAlignmentCenter;
    txtLocationInfo.cell = [[UITextFieldCell alloc] init];
    [txtLocationInfo.cell setFocusRingType:NSFocusRingTypeNone];
    txtLocationInfo.alignment = NSTextAlignmentLeft;
    txtLocationInfo.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtLocationInfo.bordered = YES;
    txtLocationInfo.wantsLayer = YES;
    txtLocationInfo.layer.borderColor = [NSColor blackColor].CGColor;
    txtLocationInfo.editable = YES;
    txtLocationInfo.layer.cornerRadius = 0;
    txtLocationInfo.layer.borderWidth = 0.5;
    txtLocationInfo.layer.backgroundColor = [NSColor whiteColor].CGColor;
    txtLocationInfo.stringValue = @"";
    [groupCustomField addSubview:txtLocationInfo];
    
    
    
    //======================================================================Table View========================================
    //viewData
    int dWidth = rect.size.width - widthToolCustomField,dHeight = rect.size.height;
    NSView *viewData = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, dWidth, dHeight)];
    viewData.wantsLayer = YES;
    viewData.layer.backgroundColor = colorCFBG.CGColor;//[NSColor greenColor].CGColor;
    [viewConten addSubview:viewData];
    
    if(libusb == nil)
        libusb = [[ProccessUSB alloc] init];
    NSMutableArray *sortedArray = [libusb getListModule];
    NSLog(@"%s arrayBoard:%@",__func__,sortedArray);
//    if(sortedArray.count == 0)
//    {
//        NSAlert *alert = [NSAlert alertWithMessageText:@"iCombine Mac Alert" defaultButton:@"Close" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Module not found"];
//        [alert runModal];
//    }
/////%%%%%%%%%%%%%%%%%%%%%%%%%%%%:             Remove check board module     create module vitur  :%%%%%%%%%%%%%%%%%%%%%%%%%
//   chi cho hien interface 1 module 8 port
    
    NSMutableDictionary *dicModule = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      @"000000000",@"UniqueDeviceID",
                                      [NSNumber numberWithInt:1908],@"bcd_device",
                                      @"3",@"iSerialNumber",
                                      @"VIA Labs, Inc.",@"manufacturer",
                                      [NSNumber numberWithInt:2071],@"pid",
                                      @"8.4",@"path",
                                      @"USB3.0 Hub",@"product",
                                      [NSNumber numberWithInt:8457],@"vid",
                                      nil];
    
    [sortedArray removeAllObjects];
    [sortedArray addObject:dicModule];
  
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    
    NSLog(@"%s sortedArray Board:%@",__func__,sortedArray);
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"path" ascending:YES];
    arrayBoard = [[sortedArray sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    
    
    
    AppDelegate *delegatedir = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSString *pathLib = [delegatedir pathLib];
    pathLib = [pathLib stringByAppendingString:@"/config/port.config"];
    NSLog(@"%s pathconfig:%@",__func__,pathLib);
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pathLib]==YES)
    {
        NSString *data = [NSString stringWithContentsOfFile:pathLib encoding:NSUTF8StringEncoding error:nil];
        NSMutableDictionary *dicData = (NSMutableDictionary *)[delegatedir diccionaryFromJsonString:data];
        NSLog(@"%s port.config pathconfig dicData:%@",__func__,dicData);
        for (int i=0; i<arrayBoard.count; i++)
        {
            NSMutableDictionary *dicboard = [[arrayBoard objectAtIndex:i] mutableCopy];
            NSString *udid = [dicboard objectForKey:@"UniqueDeviceID"];
            NSMutableDictionary *dicPort = [dicData objectForKey:udid];
            if(dicPort!=nil)
            {
                NSLog(@"%s port.config dicPort data: %@",__func__,dicPort);
                [dicboard setValue:dicPort forKey:@"location_port"];
                [arrayBoard replaceObjectAtIndex:i withObject:dicboard];
            }
            else
            {
                NSLog(@"%s port.config dicPort data: nil",__func__);
            }
        }
    }
    else
    {
        NSLog(@"%s Not exists file :%@",__func__,pathLib);
    }
    
    
    
    
    NSLog(@"%s arrayBoard:%@",__func__,sortedArray);
    int numUSBBoard = (int)[arrayBoard count]; //4 or 3 => se tinh lai khi detect num usb board
    NSLog(@"numboard:%d",numUSBBoard);
    // numUSBBoard = 3;
    cellSpacing = 10.0;
    cellHSpacing = cellSpacing;
    if(numUSBBoard == 1)
    {
        //1 port[8 item,4 col,2 row]
        numRow = 2;
        numCol = 4;
    }
    else if(numUSBBoard == 2)
    {
        //2 port[16 item,4 col,4 row]
        numRow = 4;
        numCol = 4;
    }
    else if(numUSBBoard == 3)
    {
        //3 port[24 item,3 col,8 row]
        numRow = 8;
        numCol = 3;
        cellHSpacing = 0;
    }
    else if(numUSBBoard == 4)
    {
        //4 port[32 item,4 col,8 row]
        numRow = 8;
        numCol = 4;
        cellHSpacing = 0;
    }
    numboard = numUSBBoard;
    
    [self createDatabase:numUSBBoard];
    NSLog(@"%s numRow: %d, numCol:%d",__func__,numRow,numCol);
    
    //arrayColumn = [[NSMutableArray alloc] init];//chua dung
    tbHeigh = dHeight-20;
    tableView = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0 , dWidth, tbHeigh)];
    tableView.layer.borderColor = [NSColor blackColor].CGColor;
    tableView.layer.borderWidth = 0.0;
    [tableView setWantsLayer:YES];
    [tableView setHeaderView:nil];
    int tbWidth = dWidth - (numCol+1)*10;
    for (int i=0;i<numCol; i++)
    {
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"Col_%d",i+1]];
        [column setTitle:[NSString stringWithFormat:@"Column %d",i+1]];
        [column setWidth:(tbWidth-20)/numCol];
        
        [tableView addTableColumn:column];
    }
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    // tableView.intercellSpacing = NSSizeFromCGSize(CGSizeMake(0, 9));
    tableView.alignment = NSTextAlignmentCenter;
    tableView.backgroundColor = [NSColor clearColor];
    
    [tableView setIntercellSpacing:NSMakeSize(cellSpacing, cellHSpacing)];
#ifdef NSTableViewStylePlain
    if( @available(macOS 11.0, *))
    {
        tableView.style = NSTableViewStylePlain;
    }
#endif
    tableView.layer.backgroundColor = colorCFBG.CGColor;//[NSColor whiteColor].CGColor;
    
    scrollContainer = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0,  dWidth, dHeight-20)];
    scrollContainer.layer.borderColor = [NSColor clearColor].CGColor;
    [scrollContainer setWantsLayer:YES];
    scrollContainer.layer.borderWidth = 0.0;
    [scrollContainer setDocumentView:tableView];
    [scrollContainer setHasVerticalScroller:NO];
    scrollContainer.backgroundColor = colorCFBG;//[NSColor whiteColor];
    [viewData addSubview:scrollContainer];
    viewData.layer.backgroundColor = colorCFBG.CGColor;//[NSColor whiteColor].CGColor;
    
    isSelectAll = YES;
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    checkBox = [[NSButton alloc] initWithFrame:NSMakeRect(17,viewData.frame.size.height-25, 100, 20)];
    checkBox.image = [NSImage imageNamed:@"BoxChecked.png"];
    checkBox.imagePosition = NSImageLeft;
    checkBox.imageScaling = NSImageScaleProportionallyUpOrDown;
    checkBox.title = @"  Select All";
    checkBox.alignment = NSTextAlignmentLeft;
    [checkBox.cell setBackgroundColor:[NSColor clearColor]];
    NSMutableAttributedString *atribute = [delegate setColorTitleFor:checkBox color:[NSColor blackColor] size:16];
    [checkBox setAttributedTitle:atribute];
    checkBox.layer.borderWidth = 0.0;
    checkBox.layer.cornerRadius = 4.0;
    checkBox.wantsLayer = YES;
    checkBox.bordered = NO;
    checkBox.font = [NSFont fontWithName:@"Roboto-Regular" size:16];;
    [checkBox setTarget:self];
    [checkBox setAction:@selector(cbSelectAllClick:)];
    [viewData addSubview:checkBox];
    
    
}

-(void)drawButtonTool:(NSRect)rect
{
    NSLog(@"[drawButtonsRight] ============> started");
}

-(void)drawCustomField:(NSRect)rect
{
    NSLog(@"[drawStationInfoRight] ============> started");
    
}


- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    //    [self performSelector:@selector(checkEnterTemp:) withObject:[NSNumber numberWithInt:1] afterDelay:0];
}

//- (void)checkEnterTemp:(NSNumber *)num
//{
//    NSLog(@"%s [checkEnterTemp] txtItemID.stringValue: %@", __func__, txtItemID.stringValue);
//    if ([txtItemID.stringValue  isEqual: @""] == FALSE) {
//        lbPleaseScanItemID.stringValue = txtItemID.stringValue;
//        stringVlItemIDTemp = txtItemID.stringValue;
//        NSLog(@"%s [checkEnterTemp] stringVlItemIDTemp: %@", __func__, stringVlItemIDTemp);
//
//        lbPleaseScanItemID.textColor = NSColor.blackColor;
//        txtItemID.stringValue = @"";
//    }
//}


//- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
//{
//    NSLog(@"Selector method is (%@)", NSStringFromSelector( commandSelector ) );
//    if (commandSelector == @selector(insertNewline:)) {
//        //Do something against ENTER key
//        lbPleaseScanItemID.stringValue = txtItemID.stringValue;
//        stringVlItemIDTemp = txtItemID.stringValue;
//        lbPleaseScanItemID.textColor = NSColor.blackColor;
//        txtItemID.stringValue = @"";
//
//    } else if (commandSelector == @selector(deleteForward:)) {
//        //Do something against DELETE key
//
//
//
//    } else if (commandSelector == @selector(deleteBackward:)) {
//        //Do something against BACKSPACE key
//
//    } else if (commandSelector == @selector(insertTab:)) {
//        //Do something against TAB key
//
//    } else if (commandSelector == @selector(cancelOperation:)) {
//        //Do something against Escape key
//    }
//    return YES;
//}

-(void)btStationClick:(id)sender
{
    NSLog(@"%s",__func__);
}
- (void)btReportsClick:(id)sender
{
    //    NSLog(@"%s",__func__);
    //    NSMutableDictionary *dicData = [NSMutableDictionary dictionary];
    //    ReportViewController *reportView = [[ReportViewController alloc] initWithFrame:NSMakeRect(0, 0, 1200, 1000) data:dicData];
    //    [reportView showWindow];
}
- (void)btRescanClick:(id)sender
{
    NSLog(@"btRescanClick ====== ===== %s",__func__);
    //NSThread *threadScan = [[NSThread alloc] initWithTarget:self selector:@selector(scanDevice) object:nil];
    //[threadScan start];
    //[self.tableView reloadData];
}

- (void)btStopAllClick:(id)sender
{
    NSLog(@"%s Current not use!!!1",__func__);
    //    NSMutableDictionary *dicCell;
    //    bool need_reload = NO;
    //
    //    for (int i=0; i<arrDatabaseCell.count; i++)
    //    {
    //        dicCell = [[arrDatabaseCell objectAtIndex:i] mutableCopy];
    //        if(dicCell != Nil)
    //        {
    //            if([[dicCell objectForKey:@"status"] intValue] == CellRunning)
    //            {
    //                [self stopCell:dicCell];
    //                need_reload = YES;
    //            }
    //        }
    //    }
    //
    //    if( need_reload == YES)
    //    {
    //        [tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    //    }
}
- (void)stopCell:(NSMutableDictionary *)dicCell
{
    NSLog(@"%s Started =====================> index: %d", __func__, [[dicCell objectForKey:@"index"] intValue]);
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        NSString *title = [dicCell objectForKey:@"title"];
    //        [self setResult:RESULT_FAILED dic:dicCell];
    //        [self setUSB_State_OnBoardOfCell: title state: USB_POWER_OFF];
    //    });
    
    NSString *title = [dicCell objectForKey:@"title"];
    [self setResult:RESULT_FAILED dic:dicCell];
    [self setUSB_State_OnBoardOfCell: title state: USB_POWER_OFF];
    
}

- (void)stopErase:(NSMutableDictionary *)dicCell
{
    //    ps -e
    //    ps aux
    // killall idevicerestore1
    if(dicCell==nil)
    {
        NSLog(@"%s dicCell == nil thoat",__func__);
        return;
    }
    int i = [[dicCell objectForKey:@"index"] intValue];
    NSString *cmd = @"/usr/bin/killall";
    NSString *param = [NSString stringWithFormat:@"idevicerestore%d",i];
    ProccessUSB *libusbtemp = (ProccessUSB *)[dicCell objectForKey:@"ProccessUSB"];
    bool kq = [libusbtemp actionCommand:cmd param:@[param]];
    if(kq==NO)
    {
        kq = [libusbtemp actionCommand:cmd param:@[param]];
    }
    NSLog(@"%s killall %@ %@",__func__,param,kq?@"Passed":@"Failed");
}

- (void)btEraseAllClick:(id)sender
{
    NSLog(@"%s",__func__);
    NSMutableDictionary *dicCell;
    bool need_reload = NO;
    
    for (int i=0; i<arrDatabaseCell.count; i++)
    {
        dicCell = [[arrDatabaseCell objectAtIndex:i] mutableCopy];
        if(dicCell != Nil)
        {
            
            if([[dicCell objectForKey:@"status"] intValue] == CellReady)
            {
                NSThread *threadEraseDevice = [[NSThread alloc] initWithTarget:self selector:@selector(runEraseWhenReady:) object:dicCell];
                if (threadEraseDevice.executing == false) {
                    [threadEraseDevice start];
                }
            }
            
        }
    }
    
    if( need_reload == YES)
    {
        need_reload = NO;
        [tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}
//pos is vi tri trong arrDatabaseCell
- (bool) eraseWithItem:(NSMutableDictionary *)dicCell pos:(int) vt
{
    @autoreleasepool {
        BOOL need_reload = NO;
        if(dicCell != Nil)
        {
            NSMutableDictionary *dicInfo;
            dicInfo = [dicCell objectForKey:@"info"];
            NSLog(@"%s dicInfo:%@",__func__,dicInfo);
            NSLog(@"%s dicCell:%@",__func__,dicCell);
            NSString *title = [dicCell objectForKey:@"title"];
            [self setLedOnBoardOfCell:title color:LED_YELLOW];
            //NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            
            //Jul 7, 2022 Erase devices
            NSThread *threadEraseForEachDevice = [[NSThread alloc] initWithTarget:self selector:@selector(runEraseForEachDevice:) object:dicCell];
            NSLog(@"%s CellHaveDevice ===========> threadEraseForEachDevice %@", __func__, threadEraseForEachDevice.name);
            if (threadEraseForEachDevice.executing == false) {
                [threadEraseForEachDevice start];
                [dicCell setObject:[NSNumber numberWithInt:0] forKey:@"counterTrust"];
            }
            NSLog(@"CellHaveDevice ======ƒ=====> threadEraseForEachDevice NEXT");
            need_reload = 1;
        }
        NSLog(@"CellHaveDevice ===========> threadEraseForEachDevice RETURN %d", need_reload);
        
        return need_reload;
    }
    
}

RLMResults<MacInformation *> *deviceQueryVerifyNothing;
RLMThreadSafeReference *deviceInfoVerifyNothingRef;

- (void) runEraseForEachDevice:(NSMutableDictionary*)dicCell
{
    @autoreleasepool {
        @try {
            NSString *mSerialNumberTarget = @"";
            
            NSString *ipswFileName = [self get_ipsw_name];
            NSLog(@"%s runEraseForEachDevice: %@ ", __func__, dicCell);
            NSLog(@"Ipsw name for erase each device: %@", ipswFileName);
            NSMutableDictionary *dicInfo;
            dicInfo = [dicCell objectForKey:@"info"];
            
            NSString *eraseID = [dicInfo objectForKey:@"erase_id"];
            NSString *timeStart = [dicInfo objectForKey:@"time_start"];
            
            AppDelegate *delegatedir = (AppDelegate *)[[NSApplication sharedApplication] delegate];
            NSString *path = [[delegatedir pathLib] stringByReplacingOccurrencesOfString:@"/Lib" withString:@""];
            NSLog(@"Path file ipsw org: %@", path);
            NSString *title = [dicCell objectForKey:@"title"];
            NSString *fileImage = [NSString stringWithFormat:@"%@/IPSW/%@", path, ipswFileName];
            if ([dicInfo objectForKey:@"deviceType"] != nil) {
                NSString *devType = [dicInfo objectForKey:@"deviceType"];
                NSLog(@"%s fileImage ===> devType %@",__func__, devType);
                
                if([devType rangeOfString:@"iBridge"].location != NSNotFound)
                {
                    fileImage = [NSString stringWithFormat:@"%@/IPSW/iBridge2,1,iBridge2,10,iBridge2,12,iBridge2,14,iBridge2,15,iBridge2,16,iBridge2,19,iBridge2,20,iBridge2,21,iBridge2,22,iBridge2,3,iBridge2,4,iBridge2,5,iBridge2,6,iBridge2,7,iBridge2,8_6.5_19P5071_Restore.ipsw", path];
                } else if([devType rangeOfString:@"iPhone9,3"].location != NSNotFound) {
                    fileImage = [NSString stringWithFormat:@"%@/IPSW/iPhone_4.7_P3_15.5_19F77_Restore.ipsw", path];
                } else if ([devType rangeOfString:@"iPhone7,2"].location != NSNotFound) {
                    fileImage = [NSString stringWithFormat:@"%@/IPSW/iPhone_4.7_12.5.5_16H62_Restore.ipsw", path];
                } else if ([devType rangeOfString:@"iPhone10,6"].location != NSNotFound) {
                    fileImage = [NSString stringWithFormat:@"%@/IPSW/iPhone10,3,iPhone10,6_15.5_19F77_Restore.ipsw", path];
                } else if ([devType rangeOfString:@"iPhone8,2"].location != NSNotFound || [devType rangeOfString:@"iPhone8,1"].location != NSNotFound) {
                    fileImage = [NSString stringWithFormat:@"%@/IPSW/iPhone_4.7_15.6.1_19G82_Restore_iPhone8,1.ipsw", path];
                } else if ([devType rangeOfString:@"iPhone7,1"].location != NSNotFound) {
                    fileImage = [NSString stringWithFormat:@"%@/IPSW/iPhone_5.5_12.5.5_16H62_Restore_IP6Plus.ipsw", path];
                }
                
                NSLog(@"%s fileImage ===> path %@",__func__, fileImage);
                ProccessUSB *libusbtemp = (ProccessUSB *)[dicCell objectForKey:@"ProccessUSB"];
                BOOL kq = [libusbtemp actionCommand:@"/usr/local/bin/cfgutil" param:@[@"-e",[dicCell objectForKey:@"ECID"],@"restore",@"-I",fileImage]];
                NSLog(@"%s runEraseForEachDevice DEBUG ===> eraseID %@",__func__, eraseID);
                NSLog(@"%s runEraseForEachDevice DEBUG ===> timeStart %@",__func__, timeStart);
                if(kq == YES)
                {
                    int count = 0;
                    bool isBreak = NO;
                    while (true)
                    {
                        if(dicInfo && [devType rangeOfString:@"iBridge"].location != NSNotFound)
                        {
                            NSLog(@"%s ===================> Mac T2 devType: %@",__func__, devType);
                            break;
                        }
                        NSMutableDictionary *dicInfo = [[dicCell objectForKey:@"info"] mutableCopy];
                        if([dicInfo objectForKey:@"serial"]!=nil)
                        {
                            NSString *serial = [dicInfo objectForKey:@"serial"];
                            if(serial.length > 8 && [serial rangeOfString:@"iBoot"].location == NSNotFound)
                            {
                                NSLog(@"%s read info success 1",__func__);
                                break;
                            }
                        }
                        
                        NSMutableArray *arrDevice = [libusb getListiMacDeviceByAppleConfig];
                        int numDeviceInEraseForEachDevice = (int)arrDevice.count;
                        NSLog(@"%s ===================> numDeviceInEraseForEachDevice: %d",__func__, numDeviceInEraseForEachDevice);
                        for (int i = 0; i < numDeviceInEraseForEachDevice; i++)
                        {
                            NSMutableDictionary *dic = [arrDevice objectAtIndex:i];
                            
                            if([dic objectForKey:@"serial"])
                            {
                                
                                NSMutableDictionary *dicInfo = [[dicCell objectForKey:@"info"] mutableCopy];
                                if( [dicInfo objectForKey:@"serial"]!=nil)
                                {
                                    NSString *serial = [dicInfo objectForKey:@"serial"];
                                    if(serial.length == 12) {
                                        [dicInfo setObject:serial forKey:@"serial"];
                                        [dicCell setObject:dicInfo forKey:@"info"];
                                        isBreak = YES;
                                        NSLog(@"%s ===================> FOR DEVICES isBreak: TRUE",__func__);
                                        break;
                                    }
                                }
                                else
                                {
                                    if([dic objectForKey:@"ECID"])
                                    {
                                        NSString *ECIDinfo = [NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"ECID"]];
                                        NSString *ECIDNew = [NSString stringWithFormat:@"%@",[dic objectForKey:@"ECID"]];
                                        if([ECIDinfo isEqualToString:ECIDNew])
                                        {
                                            NSString *serial =  [NSString stringWithFormat:@"%@",[dic objectForKey:@"serial"]];
                                            [dicInfo setObject:serial forKey:@"serial"];
                                        }
                                    }
                                }
                            }
                        }
                        
                        if(isBreak == YES)
                        {
                            NSLog(@"%s read info success 2",__func__);
                            NSLog(@"%s ===================> FOR DEVICES BREAK: WHILE CHECK SERIAL",__func__);
                            break;
                        }
                        NSMutableDictionary *dicInfoNew = [[dicCell objectForKey:@"info"] mutableCopy];
                        mSerialNumberTarget = [dicInfoNew objectForKey:@"serial"];
                        NSLog(@"===================> mSerialNumberTarget: %@ ", mSerialNumberTarget);

                        if(count>24)
                        {
                            NSLog(@"%s timeout ",__func__);
                            
                            if(dicInfoNew)
                            {
                                if([dicInfoNew objectForKey:@"serial"] == nil)
                                {
                                    [dicInfoNew setObject:@"N/A" forKey:@"serial"];
                                    [dicCell setObject:dicInfoNew forKey:@"info"];
                                }
                            }
                            break;
                        }
                        NSLog(@"%s count:%d - dicCell data read sau khi xoa: %@",__func__,count,dicCell);
                        sleep(5);
                        count++;
                        
                    }
                    
                    
                    NSLog(@"%s send command erase Mac sucessfull",__func__);
                    [self setLedOnBoardOfCell:title color:LED_GREEN];
                    [dicCell setObject:[NSNumber numberWithInt:RESULT_PASSED] forKey:@"result"];
                    [dicCell setObject:[NSNumber numberWithInt:CellFinished] forKey:@"status"];
                    
                    //Start: Update the erase result to database
                    deviceQueryVerifyNothing = [MacInformation objectsWhere:@"ID = %@", eraseID];
                    NSLog(@"%sCellFinished deviceQueryVerifyNothing size: %lu", __func__, (unsigned long)deviceQueryVerifyNothing.count);
                    dispatch_queue_t queue = dispatch_queue_create("database_access", 0);
                    @try {
                        if((unsigned long)deviceQueryVerifyNothing.count > 0) {
                            for (int j = 0; j < (unsigned long)deviceQueryVerifyNothing.count; j++) {
                                deviceInfoVerifyNothingRef = [RLMThreadSafeReference referenceWithThreadConfined:deviceQueryVerifyNothing[j]];
                                dispatch_async(queue, ^{
                                    @autoreleasepool {
                                        @try {
                                            RLMRealm *realm = [RLMRealm defaultRealm];
                                            macDeviceInfoVerifyNothing = [realm resolveThreadSafeReference:deviceInfoVerifyNothingRef];
                                            if (!macDeviceInfoVerifyNothing) {
                                                return;
                                            }
                                            if(![realm inWriteTransaction]) {
                                                [realm transactionWithBlock:^{
                                                    NSLog(@"[runEraseForEachDevice] Erase Result PASSED ======> before update DATABASE %d", [[dicCell objectForKey:@"result"] intValue]);
                                                    NSDate *dateTmp = [NSDate date];
                                                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                                    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                                                    NSString *endTime = [dateFormat stringFromDate:dateTmp];
                                                    NSString *transactionIDFromDatabase = @"";
                                                    transactionIDFromDatabase = macDeviceInfoVerifyNothing.transaction_ID;
                                                    NSLog(@"[runEraseForEachDevice]  watchDeviceQueryVerifyNothing transactionIDFromDatabase: %@", transactionIDFromDatabase);
                                                    macDeviceInfoVerifyNothing.userText = self->strUserName;
                                                    macDeviceInfoVerifyNothing.batchNoText = self->strBatchNo;
                                                    macDeviceInfoVerifyNothing.lineNoText = self->strLineNo;
                                                    macDeviceInfoVerifyNothing.workAreaText = self->strWorkArea;
                                                    macDeviceInfoVerifyNothing.locationText = self->strLocation;
                                                    macDeviceInfoVerifyNothing.mSerialNumber = mSerialNumberTarget;
                                                    [macDeviceInfoVerifyNothing setResulfOfErasureText:ERASURE_PASSED_TEXT];
                                                    [macDeviceInfoVerifyNothing setResulfOfErasureValue:ERASURE_RESULT_PASSED];
                                                    [macDeviceInfoVerifyNothing setNeedToSendGCS:SEND_UNSUCCESSFULLY];
                                                    [macDeviceInfoVerifyNothing setTimeEnd:endTime];
                                                    transactionIDFromDatabase = macDeviceInfoVerifyNothing.transaction_ID;
                                                    [self sendInfoToCloud:dicCell
                                                                  process:@"end"
                                                                  station:delegatedir.serialNumberStation
                                                                  result:@"1"
                                                                  transactionID_Database:transactionIDFromDatabase
                                                                  error:@""];
                                                    
                                                }];
                                            }
                                        }
                                        @catch (NSException *exception) {
                                            NSLog(@"watchDeviceQueryVerifyNothing NSException exception.reason: %@", exception.reason);
                                            NSLog(@"watchDeviceQueryVerifyNothing NSException exception.reason: %@", exception.reason);

                                        }
                                        @finally {
                                            NSLog(@"watchDeviceQueryVerifyNothing Finally condition");
                                        }
                                    }
                                });
                            }
                        }
                    }
                    @catch (NSException *exception) {
                        NSLog(@"watchDeviceQueryVerifyNothing %@", exception.reason);
                    }
                    @finally {
                        NSLog(@"watchDeviceQueryVerifyNothing Finally condition");
                    }
                    

                    
                }
                else
                {
                    NSLog(@"%s runEraseForEachDevice DEBUG FAILED ===> eraseID %@",__func__, eraseID);
                    NSLog(@"%s runEraseForEachDevice DEBUG FAILED ===> timeStart %@",__func__, timeStart);
                    NSLog(@"%s send command erase Mac failed dicCell: %@ ", __func__, dicCell);
                    NSLog(@"%s send command erase Mac failed ",__func__);
                    NSString *title = [dicCell objectForKey:@"title"];
                    [self setLedOnBoardOfCell:title color:LED_RED];
                    [dicCell setObject:[NSNumber numberWithInt:RESULT_FAILED] forKey:@"result"];
                    [dicCell setObject:[NSNumber numberWithInt:CellFinished] forKey:@"status"];
                    
                    //Start: Update the erase result to database
                    deviceQueryVerifyNothing = [MacInformation objectsWhere:@"ID = %@", eraseID];
                    NSLog(@"%sCellFinished deviceQueryVerifyNothing size: %lu", __func__, (unsigned long)deviceQueryVerifyNothing.count);
                    dispatch_queue_t queue = dispatch_queue_create("database_access", 0);
                    @try {
                        if((unsigned long)deviceQueryVerifyNothing.count > 0) {
                            for (int j = 0; j < (unsigned long)deviceQueryVerifyNothing.count; j++) {
                                deviceInfoVerifyNothingRef = [RLMThreadSafeReference referenceWithThreadConfined:deviceQueryVerifyNothing[j]];
                                dispatch_async(queue, ^{
                                    @autoreleasepool {
                                        @try {
                                            RLMRealm *realm = [RLMRealm defaultRealm];
                                            macDeviceInfoVerifyNothing = [realm resolveThreadSafeReference:deviceInfoVerifyNothingRef];
                                            if (!macDeviceInfoVerifyNothing) {
                                                return;
                                            }
                                            if(![realm inWriteTransaction]) {
                                                [realm transactionWithBlock:^{
                                                    NSLog(@"[runEraseForEachDevice] Erase Result PASSED ======> before update DATABASE %d", [[dicCell objectForKey:@"result"] intValue]);
                                                    NSDate *dateTmp = [NSDate date];
                                                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                                    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                                                    NSString *endTime = [dateFormat stringFromDate:dateTmp];
                                                    NSString *transactionIDFromDatabase = @"";
                                                    transactionIDFromDatabase = macDeviceInfoVerifyNothing.transaction_ID;
                                                    NSLog(@"[runEraseForEachDevice]  watchDeviceQueryVerifyNothing transactionIDFromDatabase: %@", transactionIDFromDatabase);
                                                    macDeviceInfoVerifyNothing.userText = self->strUserName;
                                                    macDeviceInfoVerifyNothing.batchNoText = self->strBatchNo;
                                                    macDeviceInfoVerifyNothing.lineNoText = self->strLineNo;
                                                    macDeviceInfoVerifyNothing.workAreaText = self->strWorkArea;
                                                    macDeviceInfoVerifyNothing.locationText = self->strLocation;
                                                    macDeviceInfoVerifyNothing.mSerialNumber = mSerialNumberTarget;
                                                    [macDeviceInfoVerifyNothing setResulfOfErasureText:ERASURE_PASSED_TEXT];
                                                    [macDeviceInfoVerifyNothing setResulfOfErasureValue:ERASURE_RESULT_PASSED];
                                                    [macDeviceInfoVerifyNothing setNeedToSendGCS:SEND_UNSUCCESSFULLY];
                                                    [macDeviceInfoVerifyNothing setTimeEnd:endTime];
                                                    transactionIDFromDatabase = macDeviceInfoVerifyNothing.transaction_ID;
                                                    [self sendInfoToCloud:dicCell
                                                                  process:@"end"
                                                                  station:delegatedir.serialNumberStation
                                                                  result:@"0"
                                                                  transactionID_Database:transactionIDFromDatabase
                                                                  error:@""];
                                                    
                                                }];
                                            }
                                        }
                                        @catch (NSException *exception) {
                                            NSLog(@"watchDeviceQueryVerifyNothing NSException exception.reason: %@", exception.reason);
                                        }
                                        @finally {
                                            NSLog(@"watchDeviceQueryVerifyNothing Finally condition");
                                        }
                                    }
                                });
                            }
                        }
                    }
                    @catch (NSException *exception) {
                        NSLog(@"watchDeviceQueryVerifyNothing %@", exception.reason);
                    }
                    @finally {
                        NSLog(@"watchDeviceQueryVerifyNothing Finally condition");
                    }
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"[runEraseForEachDevice] NSException: %@", exception.reason);
        }
        @finally {
            NSLog(@"[runEraseForEachDevice]runEraseForEachDevice");
        }
    }
}

- (bool) runEraseWhenReady:(NSMutableDictionary*)dicCell
{
    @autoreleasepool {
        bool need_reload = NO;
        if([[dicCell objectForKey:@"status"] intValue] == CellReady)
        {
            NSLog(@"%s start erasing for the port here ======== CellReady dicCell: %@",__func__, dicCell.description);
            
            NSLog(@"%s start erasing for the port here ======== CellReady stringVlItemIDTemp: %@",__func__, stringVlItemIDTemp);
            NSString *conten = @"";
            [dicCell setObject:[NSNumber numberWithInt:CellRunning] forKey:@"status"];
            
            //[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO ];
            
            NSString *name = @"N/A";
            NSString *mSerial = @"N/A";
            if([dicCell objectForKey:@"name"]==nil || [[NSString stringWithFormat:@"%@",[dicCell objectForKey:@"name"]] isEqualToString:@"<null>"])
                name = [dicCell objectForKey:@"deviceType"];
            else  name = [dicCell objectForKey:@"name"];
            
            mSerial = [dicCell objectForKey:@"serial"];
            
            NSLog(@"%s CellReady ===========> runEraseWhenReady.......... mSerial: %@", __func__, mSerial);
            NSLog(@"%s CellReady ===========> runEraseWhenReady.......... product name: %@", __func__, name);
            
            
            NSDictionary *dicInfo = [dicCell objectForKey:@"info"];
            
            NSString *mSN = @"N/A";
            mSN = [[dicInfo objectForKey:@"info"] objectForKey:@"serial"];
            if ([mSerial  isEqual: @""]
                || [mSerial  isEqual: @"N/A"]) {
                mSerial = mSN;
            }
            
            conten = [NSString stringWithFormat:@"<b>Product name: %@<br><b>S/N: %@<br>State:</b> DFU<br><b>ECID:</b> %@<br></b>",
                      name,
                      mSerial==Nil?@"N/A": mSerial,
                      [dicCell objectForKey:@"ECID"]];
            
            NSLog(@"%s CellReady ===========> runEraseWhenReady.......... conten: %@", __func__, conten);
            
            int row = [[dicCell objectForKey:@"row"] intValue];
            int col = [[dicCell objectForKey:@"col"] intValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setTextToCell:col row:row text:conten];
                [self setTextToCell:col row:row text:[dicCell objectForKey:@"conten"]];
                [self->tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                                           columnIndexes:[NSIndexSet indexSetWithIndex:col]];
            });
            
            NSString *title = [dicCell objectForKey:@"title"];
            stringVlItemIDTemp = @"";
            if(dicCell != Nil)
            {
                NSLog(@"%s start erasing for the port here ======== CellReady erase WithItem OK",__func__);
                int local = -1;
                for(int i=0;i<arrDatabaseCell.count;i++)
                {
                    NSMutableDictionary *dic= [arrDatabaseCell objectAtIndex:i];
                    if([title isEqualToString:[dic objectForKey:@"title"]])
                    {
                        local = i;
                        break;
                    }
                }
                NSLog(@"%s start erasing for the port here ======== CellReady erase WithItem OK local: %d",__func__, local);
                
                if(local!= -1)
                {
                    need_reload = [self eraseWithItem:dicCell pos:local];
                    
                }
                NSLog(@"%s start erasing for the port here ======== CellReady erase WithItem OK local: %d need_reload:%d",__func__, local, need_reload);
            }
            
            [self setLedOnBoardOfCell:title color:LED_YELLOW];
        }
        return need_reload;
    }
}

- (void)btPrintLabeltClick:(id)sender
{
    NSLog(@"%s",__func__);
    UIButton *bt = (UIButton *)sender;
    [bt performSelector:@selector(resetImage) withObject:nil afterDelay:3];
    
    NSMutableArray *arrDataPrint = [NSMutableArray array];
    for(int i=0;i<arrDatabaseCell.count;i++)
    {
        NSMutableDictionary *dic = (NSMutableDictionary *)arrDatabaseCell[i];
        if([[dic objectForKey:@"status"] intValue] != 0) //== 5 CellFinished
        {
            [arrDataPrint addObject:dic];
        }
    }
    
    if(arrDataPrint.count>0)
    {
        NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
        [dicInfo setObject:arrDataPrint forKey:@"DataPrint"];
        printSetting = [[PrinterSetting alloc] initWithFrame:CGRectMake(0, 0, 620, 800) data:dicInfo];
        NSRect rect = [NSScreen mainScreen].frame;
        [printSetting view].frame = CGRectMake((rect.size.width - 620)/2, (rect.size.height -800)/2, 620, 800);
        [printSetting view].layer.backgroundColor = [NSColor whiteColor].CGColor;
        [printSetting view].layer.borderWidth = 2;
        [self.view addSubview:printSetting.view];
        
    }
    else
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Printer Alert" defaultButton:@"Close" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Not device info to print"];
        [alert runModal];
    }
}

- (void)cbSelectAllClick:(id)sender
{
    NSButton *cb = (NSButton *)sender;
    NSLog(@"Select all change %d",(int)cb.state);
    if(isSelectAll)
    {
        isSelectAll = NO;
        checkBox.image = [NSImage imageNamed:@"BoxUncheck.png"];
    }
    else
    {
        isSelectAll = YES;
        checkBox.image = [NSImage imageNamed:@"BoxChecked.png"];
    }
    
    for(int i=0; i<arrDatabaseCell.count; i++)
    {
        NSMutableDictionary *dicCell = [arrDatabaseCell objectAtIndex:i];
        [dicCell setObject:[NSNumber numberWithInt:isSelectAll?1:0] forKey: @"CheckboxValue"];
        [arrDatabaseCell replaceObjectAtIndex:i withObject:dicCell];
    }
    
    [tableView reloadData];
}

- (void) buttonCellClick:(id)sender
{
    NSMutableDictionary *dic = (NSMutableDictionary *)sender;
    
    NSButton *bt =(NSButton*)[dic objectForKey:@"button"];
    NSLog(@"%s Button stringValue:%@, tag:%ld, title:%@, state:%d \ndic:%@ ",__FUNCTION__,bt.stringValue, bt.tag, bt.title,(int)bt.state ,dic);
    
    if( bt.tag == BT_INFO)
    {
        //[self performSelectorOnMainThread:@selector(showFormInfo) withObject:dic waitUntilDone:NO];
        [self showFormInfo:dic];
    }
    else if( bt.tag == BT_CHECK)
    {
        // check box click
        int i = [[dic objectForKey:@"index"] intValue];
        NSMutableDictionary *dicCell = [arrDatabaseCell objectAtIndex:i];
        [dicCell setObject:[NSNumber numberWithInt:bt.state?1:0] forKey: @"CheckboxValue"];
        [arrDatabaseCell replaceObjectAtIndex:i withObject:dicCell];
    }
    else if( bt.tag == BT_STOP)
    {
        [self stopCell:dic];
        
    }
    else if( bt.tag == BT_RESCAN)
    {
        
        
        int i = [[dic objectForKey:@"index"] intValue];
        [self removeDevice:i];
    }
}

- (void)showFormInfo:(NSMutableDictionary *)dicCell
{
    NSLog(@"%s dicCell:%@",__func__,dicCell);
    NSString *title = [dicCell objectForKey:@"title"];
    int pos = -1;
    if([title rangeOfString:@"A"].location != NSNotFound)
        pos = 0;
    if([title rangeOfString:@"B"].location != NSNotFound)
        pos = 1;
    if([title rangeOfString:@"C"].location != NSNotFound)
        pos = 2;
    if([title rangeOfString:@"D"].location != NSNotFound)
        pos = 3;
    
    
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [dicCell setObject:delegate.userName forKey:@"username"];
    [dicCell setObject:VERSION forKey:@"software_version"];
    if(pos != -1)
    {
        NSMutableDictionary *dic = [arrayBoard objectAtIndex:pos];
        NSDictionary *hwdic = [dic objectForKey:@"VersionHW"];
        if(hwdic.count > 0)
        {
            NSString *firmware = [hwdic objectForKey:@"firmware"];
            NSString *hardware = [hwdic objectForKey:@"hardware"];
            [dicCell setObject:hardware forKey:@"hardware_version"];
            [dicCell setObject:firmware forKey:@"firmware_version"];
        }
        else
        {
            [dicCell setObject:@"N/A" forKey:@"hardware_version"];
            [dicCell setObject:@"N/A" forKey:@"firmware_version"];
        }
        
        NSString *colorDeviceTemp = [dicCell objectForKey:@"color_device"];
        NSString *capacityDeviceTemp = [dicCell objectForKey:@"capacity_device"];
        NSString *carrierDeviceTemp = [dicCell objectForKey:@"carrier_device"];
        if(colorDeviceTemp == nil)
        {
            [dicCell setObject:@"N/A" forKey:@"color_device"];
        }
        else
        {
            [dicCell setObject:colorDeviceTemp forKey:@"color_device"];
        }
        if(capacityDeviceTemp == nil)
        {
            [dicCell setObject:@"N/A" forKey:@"capacity_device"];
        }
        else
        {
            [dicCell setObject:capacityDeviceTemp forKey:@"capacity_device"];
        }
        if(carrierDeviceTemp == nil)
        {
            [dicCell setObject:@"N/A" forKey:@"carrier_device"];
        }
        else
        {
            [dicCell setObject:carrierDeviceTemp forKey:@"carrier_device"];
        }
        
    }
    
    
    NSRect rect = [NSScreen mainScreen].frame;
    int width = rect.size.width/3.5;
    int height = rect.size.height/3;
    int xCoordinate = (rect.size.width)/2;
    int yCoordinate = (rect.size.height)/2;
    
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithFrame:CGRectMake(xCoordinate, yCoordinate, width, height) data:dicCell];
    [detailViewController showWindow];
}


- (void)updateCellData:(id)sender
{
    //    NSMutableDictionary *dic = (NSMutableDictionary *)sender;
    //    NSLog(@"%s data:%@",__func__,dic);
    //    int index = [[dic objectForKey:@"index"] intValue];
}

#pragma mark - NSTrackingArea

- (void)mouseEntered:(NSEvent *)theEvent{
    NSLog(@"entered theEvent: %@", theEvent.userData);
    if (theEvent.userData == @"btFile") {
        [btFile.layer setBackgroundColor:[NSColor colorWithRed:68.0/255 green:67.0/255 blue:70.0/255 alpha:1.0].CGColor];
    } else if (theEvent.userData == @"btTools") {
        [btTools.layer setBackgroundColor:[NSColor colorWithRed:68.0/255 green:67.0/255 blue:70.0/255 alpha:1.0].CGColor];
    } else if (theEvent.userData == @"btHelp") {
        [btHelp.layer setBackgroundColor:[NSColor colorWithRed:68.0/255 green:67.0/255 blue:70.0/255 alpha:1.0].CGColor];
    } else if (theEvent.userData == @"btAboutImage" || theEvent.userData == @"btAboutText") {
        [btAboutImage.layer setBackgroundColor:NSColor.lightGrayColor.CGColor];
        [btAboutText.layer setBackgroundColor:NSColor.lightGrayColor.CGColor];
    } else if (theEvent.userData == @"btUpdateImage" || theEvent.userData == @"btUpdateText") {
        [btUpdateImage.layer setBackgroundColor:NSColor.lightGrayColor.CGColor];
        [btUpdateText.layer setBackgroundColor:NSColor.lightGrayColor.CGColor];
    } else if (theEvent.userData == @"btOSSupportedImage" || theEvent.userData == @"btOSSupportedText") {
        [btOSSupportedImage.layer setBackgroundColor:NSColor.lightGrayColor.CGColor];
        [btOSSupportedText.layer setBackgroundColor:NSColor.lightGrayColor.CGColor];
    }
    //    else if (theEvent.userData == @"btSystemOptionsText" || theEvent.userData == @"btSystemOptionsImage") {
    //        [btSystemOptionsImage.layer setBackgroundColor:NSColor.lightGrayColor.CGColor];
    //        [btSystemOptionsText.layer setBackgroundColor:NSColor.lightGrayColor.CGColor];
    //    } else if (theEvent.userData == @"btiDeviceFWText" || theEvent.userData == @"btiDeviceFWImage") {
    //        [btiDeviceFWText.layer setBackgroundColor:NSColor.lightGrayColor.CGColor];
    //        [btiDeviceFWImage.layer setBackgroundColor:NSColor.lightGrayColor.CGColor];
    //    }
    else if (theEvent.userData == @"btLogoutText" || theEvent.userData == @"btLogoutImage") {
        [btLogoutText.layer setBackgroundColor:NSColor.lightGrayColor.CGColor];
        [btLogoutImage.layer setBackgroundColor:NSColor.lightGrayColor.CGColor];
    } else if (theEvent.userData == @"btShutdownText" || theEvent.userData == @"btShutdownImage") {
        [btShutdownText.layer setBackgroundColor:NSColor.lightGrayColor.CGColor];
        [btShutdownImage.layer setBackgroundColor:NSColor.lightGrayColor.CGColor];
    } else if (theEvent.userData == @"btRestartText" || theEvent.userData == @"btRestartImage") {
        [btRestartText.layer setBackgroundColor:NSColor.lightGrayColor.CGColor];
        [btRestartImage.layer setBackgroundColor:NSColor.lightGrayColor.CGColor];
    }
    
}

- (void)mouseExited:(NSEvent *)theEvent{
    NSLog(@"exited");
    [btFile.layer setBackgroundColor:[NSColor colorWithRed:47.0/255 green:48.0/255 blue:49.0/255 alpha:1.0].CGColor];
    [btTools.layer setBackgroundColor:[NSColor colorWithRed:47.0/255 green:48.0/255 blue:49.0/255 alpha:1.0].CGColor];
    [btHelp.layer setBackgroundColor:[NSColor colorWithRed:47.0/255 green:48.0/255 blue:49.0/255 alpha:1.0].CGColor];
    [btAboutImage.layer setBackgroundColor:NSColor.whiteColor.CGColor];
    [btAboutText.layer setBackgroundColor:NSColor.whiteColor.CGColor];
    [btUpdateImage.layer setBackgroundColor:NSColor.whiteColor.CGColor];
    [btUpdateText.layer setBackgroundColor:NSColor.whiteColor.CGColor];
    [btOSSupportedImage.layer setBackgroundColor:NSColor.whiteColor.CGColor];
    [btOSSupportedText.layer setBackgroundColor:NSColor.whiteColor.CGColor];
    //    [btSystemOptionsImage.layer setBackgroundColor:NSColor.whiteColor.CGColor];
    //    [btSystemOptionsText.layer setBackgroundColor:NSColor.whiteColor.CGColor];
    //    [btiDeviceFWText.layer setBackgroundColor:NSColor.whiteColor.CGColor];
    //    [btiDeviceFWImage.layer setBackgroundColor:NSColor.whiteColor.CGColor];
    [btLogoutText.layer setBackgroundColor:NSColor.whiteColor.CGColor];
    [btLogoutImage.layer setBackgroundColor:NSColor.whiteColor.CGColor];
    [btShutdownText.layer setBackgroundColor:NSColor.whiteColor.CGColor];
    [btShutdownImage.layer setBackgroundColor:NSColor.whiteColor.CGColor];
    [btRestartText.layer setBackgroundColor:NSColor.whiteColor.CGColor];
    [btRestartImage.layer setBackgroundColor:NSColor.whiteColor.CGColor];
    
    
    
    if (theEvent.userData == @"viewHelp") {
        viewHelp.hidden = TRUE;
        btHelpClicked = FALSE;
        //        viewTools.hidden = TRUE;
        //        btToolsClicked = FALSE;
        viewFile.hidden = TRUE;
        btFileClicked = FALSE;
    } else if (theEvent.userData == @"viewTools") {
        viewHelp.hidden = TRUE;
        btHelpClicked = FALSE;
        //        viewTools.hidden = TRUE;
        //        btToolsClicked = FALSE;
        viewFile.hidden = TRUE;
        btFileClicked = FALSE;
    } else if (theEvent.userData == @"viewFile") {
        viewHelp.hidden = TRUE;
        btHelpClicked = FALSE;
        //        viewTools.hidden = TRUE;
        //        btToolsClicked = FALSE;
        viewFile.hidden = TRUE;
        btFileClicked = FALSE;
    }
}
#pragma mark - board hardware
- (void)catchEventButtonHardwareClick:(id)sender
{
    
    NSNotification *noti = (NSNotification *)sender;
    NSLog(@"%s catchEventButtonHardwareClick object:%@",__func__,noti.object);
    if([noti.name isEqualToString:@"BoardButtonsClick"])
    {
        int vt = -1;
        NSDictionary *dic = (NSDictionary *)noti.object;
        NSMutableArray *arrbt = [[dic objectForKey:@"buttonsState"] mutableCopy];
        
        NSString *serial = [dic objectForKey:@"serial"];
        
        Byte arr[8] = {NO_CHARGE,NO_CHARGE,NO_CHARGE,NO_CHARGE,NO_CHARGE,NO_CHARGE, NO_CHARGE,NO_CHARGE};
        
        
        for (int i=0; i<8; i++)
        {
            if([[arrbt objectAtIndex:i] intValue] == 1)
            {
                vt = i;// vi tri bt tren board nhan duoc event nhan [0,7]
                break;
            }
        }
        
        protocolHW = nil;
        BOOL need_reload = NO;
        for (int i=0; i<arrayBoard.count; i++)
        {
            NSMutableDictionary *dic = [arrayBoard objectAtIndex:i];
            NSString *strID = [dic objectForKey:@"UniqueDeviceID"];
            if([strID isEqualToString:serial])
            {
                protocolHW = [dic objectForKey:@"ProtocolHW"];
                //bat den tren board
                NSLog(@"%s click vt:%d, Board:%d,dic %@",__func__,vt,i,dic);
                int local=vt + i*8;
                if(local < arrDatabaseCell.count)
                {
                    NSMutableDictionary *dicCell = [arrDatabaseCell objectAtIndex:local];
                    NSLog(@"%s xoa Mac o vitri: %d,%@",__func__,local,dicCell);
                    //xoa device cho nay
                    dicCell = [arrDatabaseCell objectAtIndex:local];
                    
                    if([[dicCell objectForKey:@"status"] intValue] == CellFinished ||
                       [[dicCell objectForKey:@"status"] intValue] == CellCouldNotRead)
                    {
                        NSLog(@"%s start reset the port ======== CellFinished",__func__);
                        if([[dicCell objectForKey:@"status"] intValue] == CellFinished)
                        {
                            AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                            if([delegate.dicInfoSettingSave objectForKey:@"enable_auto_detect_device_after_proccess_complete"])
                                [self removeDevice:local];
                        }
                        else
                        {
                            [self removeDevice:local];
                        }
                        return;
                    }
                    else if([[dicCell objectForKey:@"status"] intValue] == CellReady)
                    {
                        NSLog(@"%s start erasing for the port here ======== CellReady stringVlItemIDTemp: %@",__func__, stringVlItemIDTemp);
                        
                        [dicCell setObject:[NSNumber numberWithInt:CellRunning] forKey:@"status"];
                        
                        int row = [[dicCell objectForKey:@"row"] intValue];
                        int col = [[dicCell objectForKey:@"col"] intValue];
                        NSDictionary *dicInfo = [dicCell objectForKey:@"info"];
                        NSString *name = @"";
                        if([dicInfo objectForKey:@"name"]==nil || [[NSString stringWithFormat:@"%@",[dicInfo objectForKey:@"name"]] isEqualToString:@"<null>"])
                            name = [dicInfo objectForKey:@"deviceType"];
                        else  name = [dicInfo objectForKey:@"name"];
                        
                        
                        NSLog(@"%s start erasing for the port here ======== CellReady state DFU: %d",__func__, [[dicInfo objectForKey:@"state_dfu"] intValue]);
                        
                        NSString *conten = [NSString stringWithFormat:@"<b>%@<br>State:</b> %@<br><b>ECID:</b> %@<br></b>",
                                            name,
                                            [[dicInfo objectForKey:@"state_dfu"] intValue]==1?@"DFU":@"Booted",
                                            [dicInfo objectForKey:@"ECID"]];
                        [dicCell setObject:conten forKey:@"conten"];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self setTextToCell:col row:row text:conten];
                            [self->tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                                                       columnIndexes:[NSIndexSet indexSetWithIndex:col]];
                        });
                        
                        NSLog(@"%s [catchEventButtonHardwareClick] after set conten = %@", __func__, [dicCell objectForKey:@"conten"]);
                        row = [[dicCell objectForKey:@"row"] intValue];
                        col = [[dicCell objectForKey:@"col"] intValue];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self setTextToCell:col row:row text:[dicCell objectForKey:@"conten"]];
                            [self->tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                                                       columnIndexes:[NSIndexSet indexSetWithIndex:col]];
                        });
                        stringVlItemIDTemp = @"";
                        if(dicCell != Nil)
                        {
                            arr[vt] = LED_YELLOW;
                            if(protocolHW)
                            {
                                NSLog(@"%s ledControl call 1.",__func__);
                                [protocolHW ledControl:serial ledArr:arr];
                            }
                            
                            NSLog(@"%s start erasing for the port here ======== CellReady eraseWith Item OK",__func__);
                            if([[dicCell objectForKey:@"status"] intValue] == CellReady)
                            {
                                NSThread *threadEraseDevice = [[NSThread alloc] initWithTarget:self selector:@selector(runEraseWhenReady:) object:dicCell];
                                if (threadEraseDevice.executing == false) {
                                    [threadEraseDevice start];
                                }
                            }
                            need_reload = YES;
                        }
                    }
                    
                }
                break;
            }
        }
        
        
    }
}

- (void) setLedOnBoardOfCell:(NSString*)title color:(Byte)color_led
{
    //NSMutableDictionary *dicCell = nil;
    int pos = -1;
    if([title rangeOfString:@"A"].location != NSNotFound)
    {
        pos = 0;
        title = [title stringByReplacingOccurrencesOfString:@"A" withString:@""];
    }
    else if([title rangeOfString:@"B"].location != NSNotFound)
    {
        pos = 1;
        title = [title stringByReplacingOccurrencesOfString:@"B" withString:@""];
    }
    else if([title rangeOfString:@"C"].location != NSNotFound)
    {
        pos = 2;
        title = [title stringByReplacingOccurrencesOfString:@"C" withString:@""];
    }
    else if([title rangeOfString:@"D"].location != NSNotFound)
    {
        pos = 3;
        title = [title stringByReplacingOccurrencesOfString:@"D" withString:@""];
    }
    else return;
    
    int vt = [title intValue]-1;
    NSLog(@"vt: %d",vt);
    if(vt < 0) return;
    
    NSMutableDictionary *dic = [self->arrayBoard objectAtIndex:pos];
    NSString *serial = [dic objectForKey:@"UniqueDeviceID"];
    Byte arr[8] = {NO_CHARGE,NO_CHARGE,NO_CHARGE,NO_CHARGE,NO_CHARGE,NO_CHARGE, NO_CHARGE,NO_CHARGE};
    arr[vt] = color_led;
    
    NSMutableDictionary *dicb = [self->arrayBoard objectAtIndex:pos];
    self->protocolHW = [dicb objectForKey:@"ProtocolHW"];
    if(self->protocolHW)
    {
        NSLog(@"%s ledControl call.",__func__);
        [self->protocolHW ledControl:serial ledArr:arr];
        usleep(150000);
    }
}



- (void) setUSB_State_OnBoardOfCell:(NSString*)title state:(Byte)usbState
{
    //NSMutableDictionary *dicCell = nil;
    int pos = -1;
    if([title rangeOfString:@"A"].location != NSNotFound)
    {
        pos = 0;
        title = [title stringByReplacingOccurrencesOfString:@"A" withString:@""];
    }
    else if([title rangeOfString:@"B"].location != NSNotFound)
    {
        pos = 1;
        title = [title stringByReplacingOccurrencesOfString:@"B" withString:@""];
    }
    else if([title rangeOfString:@"C"].location != NSNotFound)
    {
        pos = 2;
        title = [title stringByReplacingOccurrencesOfString:@"C" withString:@""];
    }
    else if([title rangeOfString:@"D"].location != NSNotFound)
    {
        pos = 3;
        title = [title stringByReplacingOccurrencesOfString:@"D" withString:@""];
    }
    else return;
    
    int vt = [title intValue]-1;
    NSLog(@"[setUSB_ON_OnBoardOfCell] vt: %d",vt);
    if(vt < 0) return;
    
    NSMutableDictionary *dic = [self->arrayBoard objectAtIndex:pos];
    NSString *serial = [dic objectForKey:@"UniqueDeviceID"];
    Byte arr[8] = {NO_CHANGE, NO_CHANGE, NO_CHANGE, NO_CHANGE, NO_CHANGE, NO_CHANGE, NO_CHANGE, NO_CHANGE};
    arr[vt] = usbState;
    
    NSLog(@"[setUSB_ON_OnBoardOfCell] usbState: %d",usbState);
    
    
    NSMutableDictionary *dicb = [self->arrayBoard objectAtIndex:pos];
    self->protocolHW = [dicb objectForKey:@"ProtocolHW"];
    if(self->protocolHW)
    {
        NSLog(@"%s usbControlTurnON_OFF call.",__func__);
        if (usbState == 4) {
            [self->protocolHW usbControlTurnOFF:serial usbArr:arr];
        } else {
            [self->protocolHW usbControlTurnON:serial usbArr:arr];
        }
        usleep(150000);
    }
}



#pragma mark - TableView delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return numRow;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    int hRight = tbHeigh - (numRow+1)*cellHSpacing;
    if(hRight <= 0)
    {
        CGRect rect = tableView.frame;
        rect = [NSScreen mainScreen].frame;
        hRight = rect.size.height-150;
    }
    return hRight/(numRow);
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row;
{
    NSLog(@"willDisplayCell tableColumn:%@, row: %d",tableColumn.identifier,(int)row);
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    int col = [[[tableColumn identifier] stringByReplacingOccurrencesOfString:@"Col_" withString:@""] intValue];
    NSMutableDictionary *dic = arrDatabaseCell[(col-1)*numRow+row];
    return dic;
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    NSLog(@"%s row:%ld",__func__,row);
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn  row:(NSInteger)row {
    @autoreleasepool {
        
        NSLog(@"%s [viewForTableColumn] colume:%@, row:%ld",__func__,tableColumn.identifier,row);
        [tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone]; // clear color blue select row
        [tableView setFocusRingType:NSFocusRingTypeNone];
        
        //NSString *vitri = [NSString stringWithFormat:@"%@_%d",[tableColumn identifier],(int)row];
        int col = [[[tableColumn identifier] stringByReplacingOccurrencesOfString:@"Col_" withString:@""] intValue];
        
        
        long vt = (col-1)*numRow+row;
        
        NSMutableDictionary *dic = arrDatabaseCell[vt];// thang tu tren xuong => theo dang cot doc
        if(numboard == 1) dic = arrDatabaseCell[row*numCol+(col-1)];// ngan tu trai qua => theo dang nam ngan
        
        [dic setObject:[NSNumber numberWithInt:numboard] forKey:@"num_board"];
        int hRight = tbHeigh - (numRow+1)*cellHSpacing;
        
        
        CellTableClass *cellView=[[CellTableClass alloc] initWithFrame:NSMakeRect(0, 0, (tableView.frame.size.width-10*(numCol+1))/numCol, hRight/numRow) info:dic];
        
        
        
        //CellTableClass *cellView = (CellTableClass*)[tableView viewAtColumn:col row:row makeIfNecessary:YES];
        //CellTableClass *cellView = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:nil];
        cellView.identifier = [tableColumn identifier];
        [cellView setDelegate:self method:@selector(buttonCellClick:)];
        // show image result
        [cellView updateState:[[dic objectForKey:@"status"] intValue]];
        
        //NSString *stringhtml = [NSString stringWithFormat:@"<span style=\"font-size:16px;font-family:'Roboto-Regular'\">%@</span>",[dic objectForKey:@"conten"]];
        NSString *stringhtml = [NSString stringWithFormat:@"<p style=\"font-size:16px\">%@</p>", [dic objectForKey:@"conten"]];
        
        NSLog(@"%s %@ cell_status:%d",__func__,[dic objectForKey:@"title"],[[dic objectForKey:@"status"] intValue]);
        if([[dic objectForKey:@"status"] intValue] == CellFinished)
        {
            NSString *conten = [NSString stringWithFormat:@"%@", [dic objectForKey:@"conten"]];
            if([conten rangeOfString:@"Please go to Settings -> General -> Reset"].location != NSNotFound)
            {
                conten = [conten stringByReplacingOccurrencesOfString:@"<br>Please go to Settings -> General -> Reset \n -> Erase All Content and Settings -> Select erase all to erase device" withString:@""];
                [dic setObject:conten forKey:@"conten"];
                long vt = (col-1)*numRow+row;
                if(numboard == 1) vt = row*numCol+(col - 1);// ngan tu trai qua => theo dang nam ngan
                [arrDatabaseCell replaceObjectAtIndex:vt withObject:dic];
            }
            
            
            if([[dic objectForKey:@"result"] intValue] == RESULT_PASSED)
            {
                [self setLedOnBoardOfCell:[dic objectForKey:@"title"] color:LED_GREEN];
                cellView.imgResult.image = [NSImage imageNamed:@"passed_with_text"];
                stringhtml = [NSString stringWithFormat:@"<p style=\"font-size:18px\">%@<br></p>",[dic objectForKey:@"conten"]];
                
                [cellView.imgResult setWantsLayer: YES];
                [cellView.imgResult.layer setBackgroundColor: [NSColor clearColor].CGColor];
                cellView.imgResult.hidden = false;
                cellView.imgResult.image = [NSImage imageNamed:@"icon_passed.png"];
                cellView.imgResult.imageScaling = NSImageScaleAxesIndependently;
                
                cellView.tvInfoDevice.backgroundColor = NSColor.clearColor;
                cellView.tvInfoDevice.drawsBackground = true;
                cellView.tvInfoDevice.hidden = false;
                
                //cellView.imgResult.frame = NSMakeRect(cellView.imgResult.frame.origin.x, cellView.imgResult.frame.origin.y + 30, 100, 100);
                cellView.wantsLayer = YES;
                cellView.layer.backgroundColor = [[NSColor clearColor] CGColor];
                cellView.viewContentOfCell.wantsLayer = YES;
                cellView.viewContentOfCell.layer.backgroundColor = [NSColor colorWithRed:192.0/255 green:240.0/255 blue:194.0/255 alpha:1.0].CGColor;
            }
            else
            {
                [self setLedOnBoardOfCell:[dic objectForKey:@"title"] color:LED_RED];
                cellView.imgResult.image = [NSImage imageNamed:@"failed_with_text"];
                stringhtml = [NSString stringWithFormat:@"<p style=\"font-size:18px\">%@<br></p>",[dic objectForKey:@"conten"]];
                
                //cellView.imgResult.frame = NSMakeRect(cellView.imgResult.frame.origin.x, cellView.imgResult.frame.origin.y + 20, 100, 100);
                [cellView.imgResult setWantsLayer: YES];
                [cellView.imgResult.layer setBackgroundColor: [NSColor clearColor].CGColor];
                cellView.imgResult.hidden = false;
                cellView.imgResult.image = [NSImage imageNamed:@"icon_failed.png"];
                cellView.imgResult.imageScaling = NSImageScaleAxesIndependently;
                
                cellView.tvInfoDevice.backgroundColor = NSColor.clearColor;
                cellView.tvInfoDevice.drawsBackground = true;
                cellView.tvInfoDevice.hidden = false;
                
                cellView.wantsLayer = YES;
                cellView.layer.backgroundColor = [[NSColor clearColor] CGColor];
                cellView.viewContentOfCell.wantsLayer = YES;
                cellView.viewContentOfCell.layer.backgroundColor = [NSColor colorWithRed:254.0/255 green:196.0/255 blue:197.0/255 alpha:1.0].CGColor;
            }
        }
        
        NSData *data = [stringhtml dataUsingEncoding:NSUTF8StringEncoding];
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithHTML:data baseURL:nil documentAttributes:nil];
        [[cellView.tvInfoDevice textStorage] setAttributedString:attributedString];
        cellView.tvInfoDevice.font = [NSFont fontWithName:@"Roboto-Regular" size:fontSizeCell];
        return cellView;
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSLog(@"%s",__FUNCTION__);
    NSTableView *tableView = notification.object;
    NSLog(@"User has selected row %ld", (long)tableView.selectedRow);
}

- (NSString *)get_ipsw_name
{
    NSString *ipswFileName = @"N/A";
    NSLog(@"[get_ipsw_name] begin get file name");
    
    //    size_t len = 0;
    //    NSString *macProductName;
    //    sysctlbyname("hw.model", NULL, &len, NULL, 0);
    //    if (len)
    //    {
    //        char *model = malloc(len*sizeof(char));
    //        sysctlbyname("hw.model", model, &len, NULL, 0);
    //        printf("%s\n", model);
    //        macProductName = [NSString stringWithFormat:@"%s", model];
    //        free(model);
    //    }
        
    //    macProductName = [macProductName lowercaseString];
    //    NSLog(@"[%s][INFO] self->macProductName: %@", __func__, macProductName);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *pathChecksum = [NSString stringWithFormat: @"%@/EarseMac/Lib/config/ipsw_info.config", documentsDirectory];
    if ([fileManager fileExistsAtPath:pathChecksum] == false){
        NSLog(@"File ipsw_info.config is not exist");
        ipswFileName = @"N/A";
    }
    else
    {
        NSString* content = [NSString stringWithContentsOfFile:pathChecksum encoding:NSUTF8StringEncoding error:NULL];
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        ipswFileName = json[@"apple_model"][@"file_name"];
    }
    
    return ipswFileName;
}

@end
