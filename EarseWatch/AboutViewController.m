//
//  AboutViewController.m
//  iCombine Watch
//
//  Created by TriNguyen on 5/31/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import "AboutViewController.h"
#import "AppDelegate.h"
#include <sys/types.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include "CellTableClass.h"
#include "NS(Attributed)String+Geometrics.h"

@interface AboutViewController()

@end

@implementation AboutViewController

NSString *hwVersionMainAbout = @"";
NSString *fwVersionMainAbout = @"";


- (float) calculateFontSize:(NSString*)string field:(NSTextField *)field  maxFont:(float)kMaxFontSize minFont:(float)kMinFontSize
{
    float fontSize = kMaxFontSize;
    while (([string widthForHeight:[field frame].size.height font:[NSFont systemFontOfSize:fontSize]] > [field frame].size.width)
           && (fontSize > kMinFontSize))
    {
        fontSize--;
    }
    return fontSize;
}

- (id)initWithFrame: (CGRect)frameRect data:(NSMutableDictionary*)dic hwVersion:(NSString*)hwVersion fwVersion:(NSString*)fwVersion customerName:(NSString*)customerName
{
    self = [super init];
    hwVersionMainAbout = [hwVersion
                     stringByReplacingOccurrencesOfString:@"," withString:@"-"];;
    fwVersionMainAbout = [fwVersion
                     stringByReplacingOccurrencesOfString:@"," withString:@"-"];;
    dicInfor = dic;
    NSLog(@"[AboutViewController] info: %@", dicInfor);
    NSColor *colorCFBG = [NSColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0];
    self.view = [[NSView alloc] init];
    self.view.frame = frameRect;
    self.view.layer.backgroundColor = colorCFBG.CGColor;
    int width = frameRect.size.width;
    int height = frameRect.size.height;
    self.view.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    
    
    
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    int widthHeader = frameRect.size.width;
    int heightHeader = frameRect.size.height/15;
    int xCoordinateHeader = 0;
    int yCoordinateHeader = height - heightHeader;

    NSView *viewHeader = [[NSView alloc] initWithFrame:NSMakeRect(xCoordinateHeader, yCoordinateHeader, widthHeader, heightHeader)];
    viewHeader.wantsLayer = YES;
    viewHeader.layer.backgroundColor = delegate.colorBanner.CGColor;
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
    txtHeader.stringValue = @"   About";
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
    
    NSImageView *imageLogo = [[NSImageView alloc] initWithFrame:NSMakeRect(frameRect.size.width/4, frameRect.size.height - heightHeader - heightHeader/2 - frameRect.size.height/4, frameRect.size.width/2, frameRect.size.height/4)];
    imageLogo.image = [NSImage imageNamed:@"logoLeft.png"];
    [self.view addSubview:imageLogo];
    
    
    NSTextField *txtProjectName = [[NSTextField alloc] initWithFrame:NSMakeRect(0, frameRect.size.height - heightHeader - heightHeader/2 - frameRect.size.height/4 - heightHeader - heightHeader/2, widthHeader, heightHeader)];
    [self.view addSubview:txtProjectName];
    

    
    txtProjectName.cell = [[NSTextFieldCell alloc] init];
//    [txtProjectName fittingSize];
    txtProjectName.stringValue = @"iCombine Mac";
    float fontSize = [self calculateFontSize: txtProjectName.stringValue field:txtProjectName maxFont:22 minFont:6];
    txtProjectName.font = [NSFont fontWithName:@"Roboto-Bold" size:fontSize];
    [txtProjectName calcSize];
    txtProjectName.backgroundColor = [NSColor clearColor];
    txtProjectName.wantsLayer = NO;
    txtProjectName.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtProjectName.textColor = [NSColor blackColor];
    
    txtProjectName.alignment = NSTextAlignmentCenter;
    
    
    int widthViewInformation = frameRect.size.width - 2*heightHeader;
    int heighViewInformation = frameRect.size.height/3 + heightHeader;
    int xCoordinateViewInformation = heightHeader;
    int yCoordinateViewInformation = frameRect.size.height - heightHeader - imageLogo.frame.size.height - txtProjectName.frame.size.height - heighViewInformation - heightHeader - heightHeader/2;
    
    NSView *viewMachineInformation = [[NSView alloc] initWithFrame:NSMakeRect(xCoordinateViewInformation, yCoordinateViewInformation, widthViewInformation, heighViewInformation)];
    viewMachineInformation.wantsLayer = YES;
    viewMachineInformation.layer.backgroundColor = [NSColor clearColor].CGColor;
    viewMachineInformation.layer.borderWidth = 1;
    viewMachineInformation.layer.borderColor = [NSColor grayColor].CGColor;
    [self.view addSubview:viewMachineInformation];
    
    int widthStationName = (viewMachineInformation.frame.size.width - heightHeader)/2;
    int heighStationName = viewMachineInformation.frame.size.height/7;
    int xCoordinateStationName = heightHeader;
    int yCoordinateStationName = viewMachineInformation.frame.size.height - heighStationName;
    
    NSTextField *txtStationName = [[NSTextField alloc] initWithFrame:NSMakeRect(xCoordinateStationName, yCoordinateStationName, widthStationName, heighStationName)];
    txtStationName.cell = [[NSTextFieldCell alloc] init];
    txtStationName.stringValue = @"Station Name:";
    fontSize = [self calculateFontSize: txtStationName.stringValue field:txtStationName maxFont:18 minFont:6];
    txtStationName.font = [NSFont fontWithName:@"Roboto-Bold" size:fontSize];
    txtStationName.backgroundColor = [NSColor clearColor];
    txtStationName.wantsLayer = YES;
    txtStationName.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtStationName.textColor = [NSColor blackColor];
    txtStationName.alignment = NSTextAlignmentLeft;
    [viewMachineInformation addSubview:txtStationName];
    
    NSTextField *txtStationNameInfo = [[NSTextField alloc] initWithFrame:NSMakeRect(widthStationName + heightHeader, yCoordinateStationName, widthStationName, heighStationName)];
    txtStationNameInfo.cell = [[NSTextFieldCell alloc] init];
    txtStationNameInfo.stringValue = customerName;
    fontSize = [self calculateFontSize: txtStationNameInfo.stringValue field:txtStationNameInfo maxFont:18 minFont:6];
    txtStationNameInfo.font = [NSFont fontWithName:@"Roboto-Regular" size:fontSize];
    txtStationNameInfo.backgroundColor = [NSColor clearColor];
    txtStationNameInfo.wantsLayer = YES;
    txtStationNameInfo.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtStationNameInfo.textColor = [NSColor blackColor];
    txtStationNameInfo.alignment = NSTextAlignmentLeft;
    [viewMachineInformation addSubview:txtStationNameInfo];

    
    int widthSerialNumber = (viewMachineInformation.frame.size.width - heightHeader)/2;
    int heighSerialNumber = viewMachineInformation.frame.size.height/7;
    int xCoordinateSerialNumber = heightHeader;
    int yCoordinateSerialNumber = viewMachineInformation.frame.size.height - heighStationName - heighSerialNumber;
    
    NSTextField *txtSerialNumber = [[NSTextField alloc] initWithFrame:NSMakeRect(xCoordinateSerialNumber, yCoordinateSerialNumber, widthSerialNumber, heighSerialNumber)];
    txtSerialNumber.cell = [[NSTextFieldCell alloc] init];
    txtSerialNumber.stringValue = @"Serial number:";
    fontSize = [self calculateFontSize: txtSerialNumber.stringValue field:txtSerialNumber maxFont:18 minFont:6];
    txtSerialNumber.font = [NSFont fontWithName:@"Roboto-Bold" size:fontSize];
    txtSerialNumber.backgroundColor = [NSColor clearColor];
    txtSerialNumber.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtSerialNumber.textColor = [NSColor blackColor];
    txtSerialNumber.alignment = NSTextAlignmentLeft;
    [viewMachineInformation addSubview:txtSerialNumber];
    
    
    NSTextField *txtStationSerialNumberInfo = [[NSTextField alloc] initWithFrame:NSMakeRect(widthSerialNumber + heightHeader, yCoordinateSerialNumber, widthSerialNumber, heighSerialNumber)];
    txtStationSerialNumberInfo.cell = [[NSTextFieldCell alloc] init];
    txtStationSerialNumberInfo.stringValue = [[self getMacAddress]
                                      stringByReplacingOccurrencesOfString:@":" withString:@""];
    fontSize = [self calculateFontSize: txtStationSerialNumberInfo.stringValue field:txtStationSerialNumberInfo maxFont:18 minFont:6];
    txtStationSerialNumberInfo.font = [NSFont fontWithName:@"Roboto-Regular" size:fontSize];
    
    txtStationSerialNumberInfo.backgroundColor = [NSColor clearColor];
    txtStationSerialNumberInfo.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtStationSerialNumberInfo.textColor = [NSColor blackColor];

    txtStationSerialNumberInfo.alignment = NSTextAlignmentLeft;
    [viewMachineInformation addSubview:txtStationSerialNumberInfo];
    
    
    int widthMACAddress = (viewMachineInformation.frame.size.width - heightHeader)/2;
    int heighMACAddress = viewMachineInformation.frame.size.height/7;
    int xCoordinateMACAddress = heightHeader;
    int yCoordinateMACAddress = viewMachineInformation.frame.size.height - heighStationName - heighSerialNumber - heighMACAddress;
    
    NSTextField *txtMACAddress = [[NSTextField alloc] initWithFrame:NSMakeRect(xCoordinateMACAddress, yCoordinateMACAddress, widthMACAddress, heighMACAddress)];
    txtMACAddress.cell = [[NSTextFieldCell alloc] init];
    txtMACAddress.font = [NSFont fontWithName:@"Roboto-Bold" size:fontSize];
    txtMACAddress.backgroundColor = [NSColor clearColor];
    txtMACAddress.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtMACAddress.textColor = [NSColor blackColor];
    txtMACAddress.stringValue = @"MAC Address:";
    txtMACAddress.alignment = NSTextAlignmentLeft;
    [viewMachineInformation addSubview:txtMACAddress];
    
    NSTextField *txtMACAddressInfo = [[NSTextField alloc] initWithFrame:NSMakeRect(widthMACAddress + heightHeader, yCoordinateMACAddress, widthMACAddress, heighMACAddress)];
    txtMACAddressInfo.cell = [[NSTextFieldCell alloc] init];
    txtMACAddressInfo.font = [NSFont fontWithName:@"Roboto-Regular" size:fontSize];
    txtMACAddressInfo.backgroundColor = [NSColor clearColor];
    txtMACAddressInfo.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtMACAddressInfo.textColor = [NSColor blackColor];
    txtMACAddressInfo.stringValue = [[self getMacAddress]
                                      stringByReplacingOccurrencesOfString:@":" withString:@":"];
    txtMACAddressInfo.alignment = NSTextAlignmentLeft;
    [viewMachineInformation addSubview:txtMACAddressInfo];
    
    int widthIPAddress = (viewMachineInformation.frame.size.width - heightHeader)/2;
    int heighIPAddress = viewMachineInformation.frame.size.height/7;
    int xCoordinateIPAddress = heightHeader;
    int yCoordinateIPAddress = viewMachineInformation.frame.size.height - heighStationName - heighSerialNumber - heighMACAddress - heighIPAddress;
    
    NSTextField *txtIPAddress = [[NSTextField alloc] initWithFrame:NSMakeRect(xCoordinateIPAddress, yCoordinateIPAddress, widthIPAddress, heighIPAddress)];
    txtIPAddress.cell = [[NSTextFieldCell alloc] init];
    txtIPAddress.font = [NSFont fontWithName:@"Roboto-Bold" size:fontSize];
    txtIPAddress.backgroundColor = [NSColor clearColor];
    txtIPAddress.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtIPAddress.textColor = [NSColor blackColor];
    txtIPAddress.stringValue = @"IP Address:";
    txtIPAddress.alignment = NSTextAlignmentLeft;
    [viewMachineInformation addSubview:txtIPAddress];
    
    NSTextField *txtIPAddressInfo = [[NSTextField alloc] initWithFrame:NSMakeRect(widthIPAddress + heightHeader, yCoordinateIPAddress, widthIPAddress, heighIPAddress)];
    txtIPAddressInfo.cell = [[NSTextFieldCell alloc] init];
    txtIPAddressInfo.font = [NSFont fontWithName:@"Roboto-Regular" size:fontSize];
    txtIPAddressInfo.backgroundColor = [NSColor clearColor];
    txtIPAddressInfo.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtIPAddressInfo.textColor = [NSColor blackColor];
    txtIPAddressInfo.stringValue = [self getIPAddress];
    txtIPAddressInfo.alignment = NSTextAlignmentLeft;
    [viewMachineInformation addSubview:txtIPAddressInfo];
    
    int widthSoftwareVersion = (viewMachineInformation.frame.size.width - heightHeader)/2;
    int heighSoftwareVersion = viewMachineInformation.frame.size.height/7;
    int xCoordinateSoftwareVersion = heightHeader;
    int yCoordinateSoftwareVersion = viewMachineInformation.frame.size.height - heighStationName - heighSerialNumber - heighMACAddress - heighIPAddress - heighSoftwareVersion;
    
    NSTextField *txtSoftwareVersion = [[NSTextField alloc] initWithFrame:NSMakeRect(xCoordinateSoftwareVersion, yCoordinateSoftwareVersion, widthSoftwareVersion, heighSoftwareVersion)];
    txtSoftwareVersion.cell = [[NSTextFieldCell alloc] init];
    txtSoftwareVersion.font = [NSFont fontWithName:@"Roboto-Bold" size:fontSize];
    txtSoftwareVersion.backgroundColor = [NSColor clearColor];
    txtSoftwareVersion.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtSoftwareVersion.textColor = [NSColor blackColor];
    txtSoftwareVersion.stringValue = @"Software version:";
    txtSoftwareVersion.alignment = NSTextAlignmentLeft;
    [viewMachineInformation addSubview:txtSoftwareVersion];
    
    NSTextField *txtSoftwareVersionInfo = [[NSTextField alloc] initWithFrame:NSMakeRect(widthSoftwareVersion + heightHeader, yCoordinateSoftwareVersion, widthSoftwareVersion, heighSoftwareVersion)];
    txtSoftwareVersionInfo.cell = [[NSTextFieldCell alloc] init];
    txtSoftwareVersionInfo.font = [NSFont fontWithName:@"Roboto-Regular" size:fontSize];
    txtSoftwareVersionInfo.backgroundColor = [NSColor clearColor];
    txtSoftwareVersionInfo.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtSoftwareVersionInfo.textColor = [NSColor blackColor];
    txtSoftwareVersionInfo.stringValue = VERSION;
    txtSoftwareVersionInfo.alignment = NSTextAlignmentLeft;
    [viewMachineInformation addSubview:txtSoftwareVersionInfo];
    
    int widthFirmwareVersion = (viewMachineInformation.frame.size.width - heightHeader)/2;
    int heighFirmwareVersion = viewMachineInformation.frame.size.height/7;
    int xCoordinateFirmwareVersion = heightHeader;
    int yCoordinateFirmwareVersion = viewMachineInformation.frame.size.height - heighStationName - heighSerialNumber - heighMACAddress - heighIPAddress - heighSoftwareVersion - heighFirmwareVersion;
    
    NSTextField *txtFirmwareVersion = [[NSTextField alloc] initWithFrame:NSMakeRect(xCoordinateFirmwareVersion, yCoordinateFirmwareVersion, widthFirmwareVersion, heighFirmwareVersion)];
    txtFirmwareVersion.cell = [[NSTextFieldCell alloc] init];
    txtFirmwareVersion.font = [NSFont fontWithName:@"Roboto-Bold" size:fontSize];
    txtFirmwareVersion.backgroundColor = [NSColor clearColor];
    txtFirmwareVersion.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtFirmwareVersion.textColor = [NSColor blackColor];
    txtFirmwareVersion.stringValue = @"Firmware version:";
    txtFirmwareVersion.alignment = NSTextAlignmentLeft;
    [viewMachineInformation addSubview:txtFirmwareVersion];
    
    NSTextField *txtFirmwareVersionInfo = [[NSTextField alloc] initWithFrame:NSMakeRect(widthFirmwareVersion + heightHeader, yCoordinateFirmwareVersion, widthFirmwareVersion, heighFirmwareVersion)];
    txtFirmwareVersionInfo.cell = [[NSTextFieldCell alloc] init];
    txtFirmwareVersionInfo.font = [NSFont fontWithName:@"Roboto-Regular" size:fontSize];
    txtFirmwareVersionInfo.backgroundColor = [NSColor clearColor];
    txtFirmwareVersionInfo.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtFirmwareVersionInfo.textColor = [NSColor blackColor];
    txtFirmwareVersionInfo.stringValue = fwVersionMainAbout;
    txtFirmwareVersionInfo.alignment = NSTextAlignmentLeft;
    [viewMachineInformation addSubview:txtFirmwareVersionInfo];
    
    int widthBoardSN = (viewMachineInformation.frame.size.width - heightHeader)/2;
    int heighBoardSN = viewMachineInformation.frame.size.height/7;
    int xCoordinateBoardSN = heightHeader;
    int yCoordinateBoardSN = viewMachineInformation.frame.size.height - heighStationName - heighSerialNumber - heighMACAddress - heighIPAddress - heighSoftwareVersion - heighFirmwareVersion - heighBoardSN;
    
    NSTextField *txtBoardSN = [[NSTextField alloc] initWithFrame:NSMakeRect(xCoordinateBoardSN, yCoordinateBoardSN, widthBoardSN, heighBoardSN)];
    txtBoardSN.cell = [[NSTextFieldCell alloc] init];
    txtBoardSN.font = [NSFont fontWithName:@"Roboto-Bold" size:fontSize];
    txtBoardSN.backgroundColor = [NSColor clearColor];
    txtBoardSN.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtBoardSN.textColor = [NSColor blackColor];
    txtBoardSN.stringValue = @"Hardware version:";
    txtBoardSN.alignment = NSTextAlignmentLeft;
    [viewMachineInformation addSubview:txtBoardSN];
    
    NSTextField *txtBoardSNInfo = [[NSTextField alloc] initWithFrame:NSMakeRect(widthBoardSN + heightHeader, yCoordinateBoardSN, widthBoardSN, heighBoardSN)];
    txtBoardSNInfo.cell = [[NSTextFieldCell alloc] init];
    txtBoardSNInfo.font = [NSFont fontWithName:@"Roboto-Regular" size:fontSize];
    txtBoardSNInfo.backgroundColor = [NSColor clearColor];
    txtBoardSNInfo.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtBoardSNInfo.textColor = [NSColor blackColor];
    txtBoardSNInfo.stringValue = hwVersionMainAbout;
    txtBoardSNInfo.alignment = NSTextAlignmentLeft;
    [viewMachineInformation addSubview:txtBoardSNInfo];

    int widthBTClose = frameRect.size.width/4;
    int heighBTClose = heightHeader;
    int xCoordinateBTClose = frameRect.size.width/2 - widthBTClose/2;
    int yCoordinateBTClose = frameRect.size.height - heightHeader - imageLogo.frame.size.height - txtProjectName.frame.size.height - heighViewInformation - heightHeader - heightHeader - heighBTClose + heightHeader/4;
    
    NSButton *btClose = [[NSButton alloc] initWithFrame:NSMakeRect(xCoordinateBTClose, yCoordinateBTClose, widthBTClose, heighBTClose)];
    btClose.image = [NSImage imageNamed:@"buttonClose.png"];
    [[btClose cell] setBackgroundColor:[NSColor clearColor]];
    
    //btClose.title = @"Close";
    btClose.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    [btClose setBordered:NO];
    btClose.layer.borderColor = [NSColor clearColor].CGColor;
    btClose.layer.borderWidth = 0;
    btClose.layer.cornerRadius = 4.0;
    [btClose setToolTip:@"Close"];
    [btClose setTarget:self];
    [btClose setAction:@selector(btCloseClick:)];
    [self.view addSubview:btClose];
    

    
    return self;
}

- (void) btCloseClick:(id)sender
{
    [self.view.window close];
}

- (NSString *)getMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    NSLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

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

- (void)viewDidLoad {
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
    window.title = @"iCombine Watch";
    window.contentViewController = self;
    [window setLevel:NSNormalWindowLevel];
    [window setStyleMask:NSBorderlessWindowMask];
    NSWindowController *windowControllerIF = [[NSWindowController alloc] initWithWindow:window];
    [windowControllerIF.window makeKeyAndOrderFront:self];
    [windowControllerIF showWindow:nil];
    return window;
}

@end
