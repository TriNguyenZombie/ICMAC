//
//  DeviceInfomation.m
//  EarseWatch
//
//  Created by Duyet Le on 1/13/22.
//  Copyright © 2022 Greystone. All rights reserved.
//
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "UIButton.h"
#import <Realm/Realm.h>
#include "DeviceMapping.h"

@interface DetailViewController()

@end

@implementation DetailViewController
- (id)initWithFrame:(CGRect)frameRect data:(NSMutableDictionary*)dic
{
    self = [super init];
    dicInfor = dic;
    NSLog(@"info:%@",dicInfor);
    NSColor *colorCFBG = [NSColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0];
    self.view = [[NSView alloc] init];
    self.view.frame = frameRect;
    self.view.layer.backgroundColor = colorCFBG.CGColor;
    int width = frameRect.size.width;
    int height = frameRect.size.height;
    self.view.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    
    
//    RLMRealm *realm = [RLMRealm defaultRealm];
//    RLMResults<DeviceMapping *> *itemDeviceMapping = [DeviceMapping objectsWhere:@"icapture_pn = %@", @" MU6W2LL/A"];
//    //NSLog(@"QUERY COLOR %@", [NSString stringWithFormat:@"%@%@",dicInfo[@"ModelNumber"],dicInfo[@"RegionInfo"]]);
//    NSLog(@"[DeviceInfomation]itemDeviceMapping.count: %lu", (unsigned long)itemDeviceMapping.count);
//
//    if (itemDeviceMapping.count > 0) {
//        NSLog(@"[DeviceInfomation]itemDeviceMapping[0].color: %@", itemDeviceMapping[0].color);
//        NSLog(@"[DeviceInfomation]itemDeviceMapping[0].capacity: %@", itemDeviceMapping[0].capacity);
//        NSLog(@"[DeviceInfomation]itemDeviceMapping[0].carrier: %@", itemDeviceMapping[0].carrier);
//    }
//
    
    
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSView *viewTop = [[NSView alloc] initWithFrame:NSMakeRect(0, height - 30, width, 30)];
    viewTop.wantsLayer = YES;
    viewTop.layer.backgroundColor = delegate.colorBanner.CGColor;
    [self.view addSubview:viewTop];
    
    NSTextField *txtHeader = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 10, width-20, 20)];
    txtHeader.cell = [[NSTextFieldCell alloc] init];
    [viewTop addSubview:txtHeader];
    txtHeader.alignment = NSTextAlignmentLeft;
    txtHeader.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtHeader.backgroundColor = [NSColor clearColor];
    txtHeader.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtHeader.textColor = [NSColor whiteColor];
    txtHeader.stringValue = @"Device Information";
  
    NSButton *btCloseTop = [[NSButton alloc] initWithFrame:NSMakeRect(width - 30,5, 20, 20)];
    btCloseTop.title = @"";
    btCloseTop.image = [NSImage imageNamed:@"CloseWhite.png"];
    [[btCloseTop cell] setBackgroundColor:delegate.colorBanner];
    btCloseTop.wantsLayer = YES;
    [btCloseTop setBordered:NO];
    [btCloseTop setToolTip:@"Close"];
    [btCloseTop setTarget:self];
    [btCloseTop setAction:@selector(btCloseClick:)];
    [viewTop addSubview:btCloseTop];
    
   //======================================================device info
//    if (@available(macOS 10.12, *)) {
//        NSTextField *label = [NSTextField labelWithString:@"NSViewController without Storyboard"];
//        label.frame = NSMakeRect(0, 50, 800, 50);
//        label.backgroundColor = [NSColor brownColor];
//        label.translatesAutoresizingMaskIntoConstraints = NO;
//        [self.view addSubview:label];
//
//
//        [NSLayoutConstraint activateConstraints:@[
//            [label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
//            [label.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
//        ]];
//    } else {
//        // Fallback on earlier versions
//    }
//
   
   
   
    int heigroup = 380,widgroup=width-30, kc = 40,a;a=kc;
    // group Device info
    NSView *groupBoxDeviceInfo =[[NSView alloc] initWithFrame:NSMakeRect(15 , height - 433,widgroup, heigroup)];
    groupBoxDeviceInfo.wantsLayer = YES;
    groupBoxDeviceInfo.layer.borderWidth = 1;
    groupBoxDeviceInfo.layer.borderColor = [NSColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0].CGColor;
    groupBoxDeviceInfo.layer.backgroundColor =[NSColor clearColor].CGColor;
    [self.view addSubview:groupBoxDeviceInfo];
    
    NSTextField *lbHeaderGroupDeviceInfo = [[NSTextField alloc] initWithFrame:NSMakeRect(30, height - 60, 150, 22)];
    lbHeaderGroupDeviceInfo.alignment = NSTextAlignmentCenter;
    lbHeaderGroupDeviceInfo.cell = [[NSTextFieldCell alloc] init];
    lbHeaderGroupDeviceInfo.stringValue = @"   Device infomation";
    [lbHeaderGroupDeviceInfo setEditable:NO];
    lbHeaderGroupDeviceInfo.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbHeaderGroupDeviceInfo.backgroundColor = colorCFBG;
    lbHeaderGroupDeviceInfo.drawsBackground = YES;
    lbHeaderGroupDeviceInfo.textColor = [NSColor blackColor];
    [self.view addSubview:lbHeaderGroupDeviceInfo];
    
    //===================================================conten group info
    int h = 30, xcol1 = widgroup/4, xcol2 = widgroup*3/4 +30;
    NSTextField *lbProduct_name = [[NSTextField alloc] initWithFrame:NSMakeRect(30, heigroup - a, 200, h)];
    lbProduct_name.alignment = NSTextAlignmentCenter;
    lbProduct_name.cell = [[NSTextFieldCell alloc] init];
    lbProduct_name.stringValue = @"Product name:";
    [lbProduct_name setEditable:NO];
    lbProduct_name.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbProduct_name.backgroundColor = colorCFBG;
    lbProduct_name.drawsBackground = YES;
    lbProduct_name.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbProduct_name];
    
    
    NSString *fullname = @"N/A";
    fullname =  [dicInfor objectForKey:@"fullname"]==nil?@"N/A":[dicInfor objectForKey:@"fullname"];
    NSTextField *lbProduct_name_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol1, heigroup - a, 200, h)];
    lbProduct_name_va.alignment = NSTextAlignmentCenter;
    lbProduct_name_va.cell = [[NSTextFieldCell alloc] init];
    lbProduct_name_va.stringValue = fullname;
    [lbProduct_name_va setEditable:NO];
    lbProduct_name_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbProduct_name_va.backgroundColor = colorCFBG;
    lbProduct_name_va.drawsBackground = YES;
    lbProduct_name_va.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbProduct_name_va];
    
    NSTextField *lbCapacity= [[NSTextField alloc] initWithFrame:NSMakeRect(widgroup/2+30, heigroup - a, 200, h)];
    lbCapacity.alignment = NSTextAlignmentCenter;
    lbCapacity.cell = [[NSTextFieldCell alloc] init];
    lbCapacity.stringValue = @"Capacity:";
    [lbCapacity setEditable:NO];
    lbCapacity.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbCapacity.backgroundColor = colorCFBG;
    lbCapacity.drawsBackground = YES;
    lbCapacity.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbCapacity];
    
    NSString *sn= @"N/A";
    if([[dicInfor objectForKey:@"InfoUpdated"] intValue]==1)
    {
        NSMutableDictionary *dic = [dicInfor objectForKey:@"info"];
        sn = [NSString stringWithFormat:@"%@",[dic objectForKey:@"SerialNumber"]];
    }
    else
    {
        NSMutableDictionary *dic = [[dicInfor objectForKey:@"info_ex"] mutableCopy];
        sn = [NSString stringWithFormat:@"%@",[dic objectForKey:@"SerialNumber"]];
     }
    if(sn == nil || [sn isEqualToString:@"(null)"])
    {
        sn = @"N/A";
      
    }
    
    NSString *capacityDevice= @"N/A";
    capacityDevice = [dicInfor objectForKey:@"capacity_device"];
    NSLog(@"[DetailInformation] capacityDevice: %@", capacityDevice);
    if ([capacityDevice  isEqual: @""] || [sn  isEqual: @"N/A"] || [capacityDevice isEqualToString:@"capacityDevice"]) {
        capacityDevice= @"N/A";
    }
    NSTextField *lbCapacity_va= [[NSTextField alloc] initWithFrame:NSMakeRect(xcol2, heigroup - a, 200, h)];
    lbCapacity_va.alignment = NSTextAlignmentCenter;
    lbCapacity_va.cell = [[NSTextFieldCell alloc] init];
    lbCapacity_va.stringValue = [dicInfor objectForKey:@"Capacity"]==nil?@"N/A":[dicInfor objectForKey:@"Capacity"];
    lbCapacity_va.stringValue = capacityDevice;

    [lbCapacity_va setEditable:NO];
    lbCapacity_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbCapacity_va.backgroundColor = colorCFBG;
    lbCapacity_va.drawsBackground = YES;
    lbCapacity_va.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbCapacity_va];
   
    a+=kc;
    NSTextField *lbESN_IMEI_MEID = [[NSTextField alloc] initWithFrame:NSMakeRect(30, heigroup - a, 200, h)];
    lbESN_IMEI_MEID.alignment = NSTextAlignmentCenter;
    lbESN_IMEI_MEID.cell = [[NSTextFieldCell alloc] init];
    lbESN_IMEI_MEID.stringValue = @"ESN/IMEI/MEID:";
    [lbESN_IMEI_MEID setEditable:NO];
    lbESN_IMEI_MEID.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbESN_IMEI_MEID.backgroundColor = colorCFBG;
    lbESN_IMEI_MEID.drawsBackground = YES;
    lbESN_IMEI_MEID.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbESN_IMEI_MEID];
    
    NSTextField *lbESN_IMEI_MEID_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol1, heigroup - a, 200, h)];
    lbESN_IMEI_MEID_va.alignment = NSTextAlignmentCenter;
    lbESN_IMEI_MEID_va.cell = [[NSTextFieldCell alloc] init];
    lbESN_IMEI_MEID_va.stringValue = [dicInfor objectForKey:@"IMEI_ESN"]==nil?@"N/A":[dicInfor objectForKey:@"IMEI_ESN"];// can xem lai key nay
    [lbESN_IMEI_MEID_va setEditable:NO];
    lbESN_IMEI_MEID_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbESN_IMEI_MEID_va.backgroundColor = colorCFBG;
    lbESN_IMEI_MEID_va.drawsBackground = YES;
    lbESN_IMEI_MEID_va.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbESN_IMEI_MEID_va];
    
    
   
    NSTextField *lbColor = [[NSTextField alloc] initWithFrame:NSMakeRect(widgroup/2+30, heigroup - a, 200, h)];
    lbColor.alignment = NSTextAlignmentCenter;
    lbColor.cell = [[NSTextFieldCell alloc] init];
    lbColor.stringValue = @"Color:";// dua theo info.ModelNumber = MP0D2; de detect
    [lbColor setEditable:NO];
    lbColor.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbColor.backgroundColor = colorCFBG;
    lbColor.drawsBackground = YES;
    lbColor.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbColor];
    
    


    NSString *color = @"N/A";
    if([[dicInfor objectForKey:@"InfoUpdated"] intValue]==1)
    {
        NSMutableDictionary *dic = [dicInfor objectForKey:@"info"];
        color = [NSString stringWithFormat:@"%@",[dic objectForKey:@"DeviceColor"]];
    }
    
    
    color = [dicInfor objectForKey:@"color_device"];
    NSLog(@"[DetailInformation] color: %@", color);
    if ([color  isEqual: @""]||  [sn  isEqual: @"N/A"] || [color isEqualToString:@"colorDevice"]) {
        color = @"N/A";
    }
    NSTextField *lbColor_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol2, heigroup - a, 200, h)];
    lbColor_va.alignment = NSTextAlignmentCenter;
    lbColor_va.cell = [[NSTextFieldCell alloc] init];
    lbColor_va.stringValue = color;
    [lbColor_va setEditable:NO];
    lbColor_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbColor_va.backgroundColor = colorCFBG;
    lbColor_va.drawsBackground = YES;
    lbColor_va.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbColor_va];
    
    a+=kc;
    NSTextField *lbSerialNo = [[NSTextField alloc] initWithFrame:NSMakeRect(30, heigroup - a, 200, h)];
    lbSerialNo.alignment = NSTextAlignmentCenter;
    lbSerialNo.cell = [[NSTextFieldCell alloc] init];
    lbSerialNo.stringValue = @"Serial No:";
    [lbSerialNo setEditable:NO];
    lbSerialNo.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbSerialNo.backgroundColor = colorCFBG;
    lbSerialNo.drawsBackground = YES;
    lbSerialNo.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbSerialNo];
    
    
    NSString *carrierDevice = @"N/A";
    carrierDevice = [dicInfor objectForKey:@"carrier_device"];
    NSLog(@"[DetailInformation] carrierDevice: %@", carrierDevice);
    if ([carrierDevice  isEqual: @""] ||[sn isEqualToString:@"N/A"] || [carrierDevice isEqualToString:@"carrierDevice"]) {
        carrierDevice = @"N/A";
    }
    
  
    
    NSTextField *lbSerialNo_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol1, heigroup - a, 200, h)];
    lbSerialNo_va.alignment = NSTextAlignmentCenter;
    lbSerialNo_va.cell = [[NSTextFieldCell alloc] init];
    lbSerialNo_va.stringValue = sn;
    [lbSerialNo_va setEditable:NO];
    lbSerialNo_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbSerialNo_va.backgroundColor = colorCFBG;
    lbSerialNo_va.drawsBackground = YES;
    lbSerialNo_va.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbSerialNo_va];
    
    
    NSTextField *lbOriginalCarrier = [[NSTextField alloc] initWithFrame:NSMakeRect(widgroup/2+30, heigroup - a, 200, h)];
    lbOriginalCarrier.alignment = NSTextAlignmentCenter;
    lbOriginalCarrier.cell = [[NSTextFieldCell alloc] init];
    lbOriginalCarrier.stringValue = @"Original carrier:";
    [lbOriginalCarrier setEditable:NO];
    lbOriginalCarrier.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbOriginalCarrier.backgroundColor = colorCFBG;
    lbOriginalCarrier.drawsBackground = YES;
    lbOriginalCarrier.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbOriginalCarrier];
    
    NSTextField *lbOriginalCarrier_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol2, heigroup - a, 200, h)];
    lbOriginalCarrier_va.alignment = NSTextAlignmentCenter;
    lbOriginalCarrier_va.cell = [[NSTextFieldCell alloc] init];
    lbOriginalCarrier_va.stringValue = carrierDevice;
    [lbOriginalCarrier_va setEditable:NO];
    lbOriginalCarrier_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbOriginalCarrier_va.backgroundColor = colorCFBG;
    lbOriginalCarrier_va.drawsBackground = YES;
    lbOriginalCarrier_va.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbOriginalCarrier_va];
    
    a+=kc;
    NSTextField *lbFirmware = [[NSTextField alloc] initWithFrame:NSMakeRect(30, heigroup - a, 200, h)];
    lbFirmware.alignment = NSTextAlignmentCenter;
    lbFirmware.cell = [[NSTextFieldCell alloc] init];
    lbFirmware.stringValue = @"Firmware:";
    [lbFirmware setEditable:NO];
    lbFirmware.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbFirmware.backgroundColor = colorCFBG;
    lbFirmware.drawsBackground = YES;
    lbFirmware.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbFirmware];
   
    NSString *ProductVersion= @"N/A";
    if([[dicInfor objectForKey:@"InfoUpdated"] intValue]==1)
    {
        NSMutableDictionary *dic = [dicInfor objectForKey:@"info"];
        ProductVersion = [NSString stringWithFormat:@"%@",[dic objectForKey:@"ProductVersion"]];
    }
    NSTextField *lbFirmware_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol1, heigroup - a, 200, h)];
    lbFirmware_va.alignment = NSTextAlignmentCenter;
    lbFirmware_va.cell = [[NSTextFieldCell alloc] init];
    lbFirmware_va.stringValue = ProductVersion;
    [lbFirmware_va setEditable:NO];
    lbFirmware_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbFirmware_va.backgroundColor = colorCFBG;
    lbFirmware_va.drawsBackground = YES;
    lbFirmware_va.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbFirmware_va];
    
    
    
    NSTextField *lbCountry = [[NSTextField alloc] initWithFrame:NSMakeRect(widgroup/2+30, heigroup - a, 200, h)];
    lbCountry.alignment = NSTextAlignmentCenter;
    lbCountry.cell = [[NSTextFieldCell alloc] init];
    lbCountry.stringValue = @"Country:";
    [lbCountry setEditable:NO];
    lbCountry.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbCountry.backgroundColor = colorCFBG;
    lbCountry.drawsBackground = YES;
    lbCountry.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbCountry];
    
    NSTextField *lbCountry_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol2, heigroup - a, 200, h)];
    lbCountry_va.alignment = NSTextAlignmentCenter;
    lbCountry_va.cell = [[NSTextFieldCell alloc] init];
    lbCountry_va.stringValue = @"unknown";
    [lbCountry_va setEditable:NO];
    lbCountry_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbCountry_va.backgroundColor = colorCFBG;
    lbCountry_va.drawsBackground = YES;
    lbCountry_va.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbCountry_va];
    
    
    a+=kc;
    
    NSTextField *lbOSType = [[NSTextField alloc] initWithFrame:NSMakeRect(30, heigroup - a, 200, h)];
    lbOSType.alignment = NSTextAlignmentCenter;
    lbOSType.cell = [[NSTextFieldCell alloc] init];
    lbOSType.stringValue = @"OS Type:";
    [lbOSType setEditable:NO];
    lbOSType.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbOSType.backgroundColor = colorCFBG;
    lbOSType.drawsBackground = YES;
    lbOSType.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbOSType];
    
    NSString *osType= @"N/A";
    NSString *internal_name= @"N/A";
    if([[dicInfor objectForKey:@"InfoUpdated"] intValue]==1)
    {
        NSMutableDictionary *dic = [dicInfor objectForKey:@"info"];
        internal_name = [NSString stringWithFormat:@"%@",[dic objectForKey:@"ProductType"]];
    }
    else
    {
        NSMutableDictionary *dic = [[dicInfor objectForKey:@"info_ex"] mutableCopy];
        internal_name = [NSString stringWithFormat:@"%@",[dic objectForKey:@"ProductType"]];
    }
    
    if([[internal_name lowercaseString] rangeOfString:@"watch"].location != NSNotFound)
    {
        osType = @"WatchOS";
    }
    else osType = @"N/A";
    
    
    NSTextField *lbOSType_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol1, heigroup - a, 200, h)];
    lbOSType_va.alignment = NSTextAlignmentCenter;
    lbOSType_va.cell = [[NSTextFieldCell alloc] init];
    lbOSType_va.stringValue = osType;
    [lbOSType_va setEditable:NO];
    lbOSType_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbOSType_va.backgroundColor = colorCFBG;
    lbOSType_va.drawsBackground = YES;
    lbOSType_va.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbOSType_va];
    
    
    NSTextField *lbCurentCarrier = [[NSTextField alloc] initWithFrame:NSMakeRect(widgroup/2+30, heigroup - a, 200, h)];
    lbCurentCarrier.alignment = NSTextAlignmentCenter;
    lbCurentCarrier.cell = [[NSTextFieldCell alloc] init];
    lbCurentCarrier.stringValue = @"Current carrier:";
    [lbCurentCarrier setEditable:NO];
    lbCurentCarrier.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbCurentCarrier.backgroundColor = colorCFBG;
    lbCurentCarrier.drawsBackground = YES;
    lbCurentCarrier.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbCurentCarrier];
    
    NSTextField *lbCurentCarrier_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol2, heigroup - a, 200, h)];
    lbCurentCarrier_va.alignment = NSTextAlignmentCenter;
    lbCurentCarrier_va.cell = [[NSTextFieldCell alloc] init];
    lbCurentCarrier_va.stringValue = @"unknown";
    [lbCurentCarrier_va setEditable:NO];
    lbCurentCarrier_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbCurentCarrier_va.backgroundColor = colorCFBG;
    lbCurentCarrier_va.drawsBackground = YES;
    lbCurentCarrier_va.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbCurentCarrier_va];
    
    a+=kc;
    NSTextField *lbInternalName = [[NSTextField alloc] initWithFrame:NSMakeRect(30, heigroup - a, 200, h)];
    lbInternalName.alignment = NSTextAlignmentCenter;
    lbInternalName.cell = [[NSTextFieldCell alloc] init];
    lbInternalName.stringValue = @"Internal Name:";
    [lbInternalName setEditable:NO];
    lbInternalName.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbInternalName.backgroundColor = colorCFBG;
    lbInternalName.drawsBackground = YES;
    lbInternalName.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbInternalName];
    
    
    if(internal_name==nil || [internal_name isEqualToString:@"(null)"])
    {
        internal_name = @"N/A";
    }
    NSTextField *lbInternalName_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol1, heigroup - a, 200, h)];
    lbInternalName_va.alignment = NSTextAlignmentCenter;
    lbInternalName_va.cell = [[NSTextFieldCell alloc] init];
    lbInternalName_va.stringValue = internal_name;
    [lbInternalName_va setEditable:NO];
    lbInternalName_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbInternalName_va.backgroundColor = colorCFBG;
    lbInternalName_va.drawsBackground = YES;
    lbInternalName_va.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbInternalName_va];
    
    
    NSTextField *lbSimDetection = [[NSTextField alloc] initWithFrame:NSMakeRect(widgroup/2+30, heigroup - a, 200, h)];
    lbSimDetection.alignment = NSTextAlignmentCenter;
    lbSimDetection.cell = [[NSTextFieldCell alloc] init];
    lbSimDetection.stringValue = @"SIM detection:";
    [lbSimDetection setEditable:NO];
    lbSimDetection.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbSimDetection.backgroundColor = colorCFBG;
    lbSimDetection.drawsBackground = YES;
    lbSimDetection.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbSimDetection];
    
    NSTextField *lbSimDetection_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol2, heigroup - a, 200, h)];
    lbSimDetection_va.alignment = NSTextAlignmentCenter;
    lbSimDetection_va.cell = [[NSTextFieldCell alloc] init];
    lbSimDetection_va.stringValue = @"N/A";
    [lbSimDetection_va setEditable:NO];
    lbSimDetection_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbSimDetection_va.backgroundColor = colorCFBG;
    lbSimDetection_va.drawsBackground = YES;
    lbSimDetection_va.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbSimDetection_va];
    
    a+=kc;
    NSTextField *lbScreenLock = [[NSTextField alloc] initWithFrame:NSMakeRect(30, heigroup - a, 200, h)];
    lbScreenLock.alignment = NSTextAlignmentCenter;
    lbScreenLock.cell = [[NSTextFieldCell alloc] init];
    lbScreenLock.stringValue = @"Screen lock:";
    [lbScreenLock setEditable:NO];
    lbScreenLock.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbScreenLock.backgroundColor = colorCFBG;
    lbScreenLock.drawsBackground = YES;
    lbScreenLock.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbScreenLock];
    
    
  
    NSString *screenLock= @"N/A";
    if([[dicInfor objectForKey:@"InfoUpdated"] intValue]==1)
    {
        NSMutableDictionary *dic = [dicInfor objectForKey:@"info"];
        if([dic objectForKey:@"PasswordProtected"])
        {
            int va = [[dic objectForKey:@"PasswordProtected"] intValue];
            if(va==1)
                screenLock = [NSString stringWithFormat:@"ON"];
            else screenLock = [NSString stringWithFormat:@"OFF"];
        }
    }
    
    NSTextField *lbScreenLock_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol1, heigroup - a, 200, h)];
    lbScreenLock_va.alignment = NSTextAlignmentCenter;
    lbScreenLock_va.cell = [[NSTextFieldCell alloc] init];
    lbScreenLock_va.stringValue = screenLock;
    [lbScreenLock_va setEditable:NO];
    lbScreenLock_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbScreenLock_va.backgroundColor = colorCFBG;
    lbScreenLock_va.drawsBackground = YES;
    lbScreenLock_va.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbScreenLock_va];
    
    
    NSTextField *lbBatteryCycleCount = [[NSTextField alloc] initWithFrame:NSMakeRect(widgroup/2+30, heigroup - a, 210, h)];
    lbBatteryCycleCount.alignment = NSTextAlignmentCenter;
    lbBatteryCycleCount.cell = [[NSTextFieldCell alloc] init];
    lbBatteryCycleCount.stringValue = @"Battery cycle count:";
    [lbBatteryCycleCount setEditable:NO];
    lbBatteryCycleCount.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbBatteryCycleCount.backgroundColor = colorCFBG;
    lbBatteryCycleCount.drawsBackground = YES;
    lbBatteryCycleCount.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbBatteryCycleCount];
    
    NSTextField *lbBatteryCycleCount_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol2, heigroup - a, 200, h)];
    lbBatteryCycleCount_va.alignment = NSTextAlignmentCenter;
    lbBatteryCycleCount_va.cell = [[NSTextFieldCell alloc] init];
    lbBatteryCycleCount_va.stringValue = @"unknown";
    [lbBatteryCycleCount_va setEditable:NO];
    lbBatteryCycleCount_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbBatteryCycleCount_va.backgroundColor = colorCFBG;
    lbBatteryCycleCount_va.drawsBackground = YES;
    lbBatteryCycleCount_va.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbBatteryCycleCount_va];
    
   
    a+=kc;
    
    NSTextField *lbModelName = [[NSTextField alloc] initWithFrame:NSMakeRect(30, heigroup - a, 200, h)];
    lbModelName.alignment = NSTextAlignmentCenter;
    lbModelName.cell = [[NSTextFieldCell alloc] init];
    lbModelName.stringValue = @"Model name:";
    [lbModelName setEditable:NO];
    lbModelName.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbModelName.backgroundColor = colorCFBG;
    lbModelName.drawsBackground = YES;
    lbModelName.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbModelName];
    
    fullname = [fullname stringByReplacingOccurrencesOfString:@"Apple " withString:@""];
    NSArray *arr = [fullname componentsSeparatedByString:@"("];
    if(arr.count > 1)
    {
        fullname = [arr objectAtIndex:0];
    }
    NSTextField *lbModelName_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol1, heigroup - a, 200, h)];
    lbModelName_va.alignment = NSTextAlignmentCenter;
    lbModelName_va.cell = [[NSTextFieldCell alloc] init];
    lbModelName_va.stringValue = fullname;
    [lbModelName_va setEditable:NO];
    lbModelName_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbModelName_va.backgroundColor = colorCFBG;
    lbModelName_va.drawsBackground = YES;
    lbModelName_va.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbModelName_va];
    
    NSTextField *lbBatterySoH = [[NSTextField alloc] initWithFrame:NSMakeRect(widgroup/2+30, heigroup - a, 200, h)];
    lbBatterySoH.alignment = NSTextAlignmentCenter;
    lbBatterySoH.cell = [[NSTextFieldCell alloc] init];
    lbBatterySoH.stringValue = @"Battery SoH:";
    [lbBatterySoH setEditable:NO];
    lbBatterySoH.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbBatterySoH.backgroundColor = colorCFBG;
    lbBatterySoH.drawsBackground = YES;
    lbBatterySoH.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbBatterySoH];
    
    NSTextField *lbBatterySoH_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol2, heigroup - a, 200, h)];
    lbBatterySoH_va.alignment = NSTextAlignmentCenter;
    lbBatterySoH_va.cell = [[NSTextFieldCell alloc] init];
    lbBatterySoH_va.stringValue = @"unknown";
    [lbBatterySoH_va setEditable:NO];
    lbBatterySoH_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbBatterySoH_va.backgroundColor = colorCFBG;
    lbBatterySoH_va.drawsBackground = YES;
    lbBatterySoH_va.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbBatterySoH_va];
    
    a+=kc;
    NSTextField *lbModelNum = [[NSTextField alloc] initWithFrame:NSMakeRect(30, heigroup - a, 200, h)];
    lbModelNum.alignment = NSTextAlignmentCenter;
    lbModelNum.cell = [[NSTextFieldCell alloc] init];
    lbModelNum.stringValue = @"Model number:";
    [lbModelNum setEditable:NO];
    lbModelNum.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbModelNum.backgroundColor = colorCFBG;
    lbModelNum.drawsBackground = YES;
    lbModelNum.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbModelNum];
    
    NSString *ModelNumber= @"N/A";
    if([[dicInfor objectForKey:@"InfoUpdated"] intValue]==1)
    {
        NSMutableDictionary *dic = [dicInfor objectForKey:@"info"];
        ModelNumber = [NSString stringWithFormat:@"%@%@",[dic objectForKey:@"ModelNumber"],[dic objectForKey:@"RegionInfo"]];
    }
    NSTextField *lbModelNum_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol1, heigroup - a, 200, h)];
    lbModelNum_va.alignment = NSTextAlignmentCenter;
    lbModelNum_va.cell = [[NSTextFieldCell alloc] init];
    lbModelNum_va.stringValue = ModelNumber;
    [lbModelNum_va setEditable:NO];
    lbModelNum_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbModelNum_va.backgroundColor = colorCFBG;
    lbModelNum_va.drawsBackground = YES;
    lbModelNum_va.textColor = [NSColor blackColor];
    [groupBoxDeviceInfo addSubview:lbModelNum_va];
    
    
    //    ===================================================== group machin infor
    heigroup = 110;widgroup=width-30;kc = 35;a=kc;
    // group Device info
    NSView *groupBoxMachin =[[NSView alloc] initWithFrame:NSMakeRect(15 ,70,widgroup, heigroup)];
    groupBoxMachin.wantsLayer = YES;
    groupBoxMachin.layer.borderWidth = 1;
    groupBoxMachin.layer.borderColor = [NSColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0].CGColor;
    groupBoxMachin.layer.backgroundColor =[NSColor clearColor].CGColor;
    [self.view addSubview:groupBoxMachin];

    NSTextField *lbHeaderGroupMachin = [[NSTextField alloc] initWithFrame:NSMakeRect(30, 63+heigroup, 260, 22)];
    lbHeaderGroupMachin.alignment = NSTextAlignmentCenter;
    lbHeaderGroupMachin.cell = [[NSTextFieldCell alloc] init];
    lbHeaderGroupMachin.stringValue = @"   iCombine Watch machine infomation";
    [lbHeaderGroupMachin setEditable:NO];
    lbHeaderGroupMachin.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbHeaderGroupMachin.backgroundColor = colorCFBG;
    lbHeaderGroupMachin.drawsBackground = YES;
    lbHeaderGroupMachin.textColor = [NSColor blackColor];
    [self.view addSubview:lbHeaderGroupMachin];
    
    
    heigroup -= 7;
    
    NSTextField *lbUseID = [[NSTextField alloc] initWithFrame:NSMakeRect(30, heigroup - a, 200, h)];
    lbUseID.alignment = NSTextAlignmentCenter;
    lbUseID.cell = [[NSTextFieldCell alloc] init];
    lbUseID.stringValue = @"User ID:";
    [lbUseID setEditable:NO];
    lbUseID.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbUseID.backgroundColor = colorCFBG;
    lbUseID.drawsBackground = YES;
    lbUseID.textColor = [NSColor blackColor];
    [groupBoxMachin addSubview:lbUseID];
   
    NSString *UseID= @"N/A";
    if([dicInfor objectForKey:@"username"])
    {
        UseID = [NSString stringWithFormat:@"%@",[dicInfor objectForKey:@"username"]];
    }
    
    NSTextField *lbUseID_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol1, heigroup - a, 200, h)];
    lbUseID_va.alignment = NSTextAlignmentCenter;
    lbUseID_va.cell = [[NSTextFieldCell alloc] init];
    lbUseID_va.stringValue = UseID;
    [lbUseID_va setEditable:NO];
    lbUseID_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbUseID_va.backgroundColor = colorCFBG;
    lbUseID_va.drawsBackground = YES;
    lbUseID_va.textColor = [NSColor blackColor];
    [groupBoxMachin addSubview:lbUseID_va];
    
   
    NSTextField *lbPosition = [[NSTextField alloc] initWithFrame:NSMakeRect(widgroup/2+30, heigroup - a, 200, h)];
    lbPosition.alignment = NSTextAlignmentCenter;
    lbPosition.cell = [[NSTextFieldCell alloc] init];
    lbPosition.stringValue = @"Position:";
    [lbPosition setEditable:NO];
    lbPosition.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbPosition.backgroundColor = colorCFBG;
    lbPosition.drawsBackground = YES;
    lbPosition.textColor = [NSColor blackColor];
    [groupBoxMachin addSubview:lbPosition];
   
    NSString *Position = @"N/A";
    if([dicInfor objectForKey:@"title"])
    {
        Position = [NSString stringWithFormat:@"%@",[dicInfor objectForKey:@"title"]];
    }
    
    NSTextField *lbPosition_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol2, heigroup - a, 200, h)];
    lbPosition_va.alignment = NSTextAlignmentCenter;
    lbPosition_va.cell = [[NSTextFieldCell alloc] init];
    lbPosition_va.stringValue = Position;
    [lbPosition_va setEditable:NO];
    lbPosition_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbPosition_va.backgroundColor = colorCFBG;
    lbPosition_va.drawsBackground = YES;
    lbPosition_va.textColor = [NSColor blackColor];
    [groupBoxMachin addSubview:lbPosition_va];
    
    a+=kc;
    NSTextField *lbHardWare = [[NSTextField alloc] initWithFrame:NSMakeRect(30, heigroup - a, 200, h)];
    lbHardWare.alignment = NSTextAlignmentCenter;
    lbHardWare.cell = [[NSTextFieldCell alloc] init];
    lbHardWare.stringValue = @"Hardware version:";
    [lbHardWare setEditable:NO];
    lbHardWare.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbHardWare.backgroundColor = colorCFBG;
    lbHardWare.drawsBackground = YES;
    lbHardWare.textColor = [NSColor blackColor];
    [groupBoxMachin addSubview:lbHardWare];
   
    NSString *HardWare= @"N/A";
    if([dicInfor objectForKey:@"hardware_version"])
    {
        HardWare = [NSString stringWithFormat:@"%@",[dicInfor objectForKey:@"hardware_version"]];
    }
    
    NSTextField *lbHardWare_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol1, heigroup - a, 200, h)];
    lbHardWare_va.alignment = NSTextAlignmentCenter;
    lbHardWare_va.cell = [[NSTextFieldCell alloc] init];
    lbHardWare_va.stringValue = HardWare;
    [lbHardWare_va setEditable:NO];
    lbHardWare_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbHardWare_va.backgroundColor = colorCFBG;
    lbHardWare_va.drawsBackground = YES;
    lbHardWare_va.textColor = [NSColor blackColor];
    [groupBoxMachin addSubview:lbHardWare_va];
    
    
    NSTextField *lbFirmwareVersion = [[NSTextField alloc] initWithFrame:NSMakeRect(widgroup/2+30, heigroup - a, 200, h)];
    lbFirmwareVersion.alignment = NSTextAlignmentCenter;
    lbFirmwareVersion.cell = [[NSTextFieldCell alloc] init];
    lbFirmwareVersion.stringValue = @"Firmware version:";
    [lbFirmwareVersion setEditable:NO];
    lbFirmwareVersion.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbFirmwareVersion.backgroundColor = colorCFBG;
    lbFirmwareVersion.drawsBackground = YES;
    lbFirmwareVersion.textColor = [NSColor blackColor];
    [groupBoxMachin addSubview:lbFirmwareVersion];
   
    NSString *Firmware = @"N/A";
    if([dicInfor objectForKey:@"firmware_version"])
    {
        Firmware = [NSString stringWithFormat:@"%@",[dicInfor objectForKey:@"firmware_version"]];
    }
    
    NSTextField *lbFirmwareVersion_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol2, heigroup - a, 200, h)];
    lbFirmwareVersion_va.alignment = NSTextAlignmentCenter;
    lbFirmwareVersion_va.cell = [[NSTextFieldCell alloc] init];
    lbFirmwareVersion_va.stringValue = Firmware;
    [lbFirmwareVersion_va setEditable:NO];
    lbFirmwareVersion_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbFirmwareVersion_va.backgroundColor = colorCFBG;
    lbFirmwareVersion_va.drawsBackground = YES;
    lbFirmwareVersion_va.textColor = [NSColor blackColor];
    [groupBoxMachin addSubview:lbFirmwareVersion_va];
    
    
    a+=kc;
    NSTextField *lbSoftWare = [[NSTextField alloc] initWithFrame:NSMakeRect(30, heigroup - a, 200, h)];
    lbSoftWare.alignment = NSTextAlignmentCenter;
    lbSoftWare.cell = [[NSTextFieldCell alloc] init];
    lbSoftWare.stringValue = @"Software version:";
    [lbSoftWare setEditable:NO];
    lbSoftWare.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbSoftWare.backgroundColor = colorCFBG;
    lbSoftWare.drawsBackground = YES;
    lbSoftWare.textColor = [NSColor blackColor];
    [groupBoxMachin addSubview:lbSoftWare];
   
    NSString *software= @"N/A";
    if([dicInfor objectForKey:@"software_version"])
    {
        software = [NSString stringWithFormat:@"%@",[dicInfor objectForKey:@"software_version"]];
    }
    
    NSTextField *lbSoftWare_va = [[NSTextField alloc] initWithFrame:NSMakeRect(xcol1, heigroup - a, 200, h)];
    lbSoftWare_va.alignment = NSTextAlignmentCenter;
    lbSoftWare_va.cell = [[NSTextFieldCell alloc] init];
    lbSoftWare_va.stringValue = software;
    [lbSoftWare_va setEditable:NO];
    lbSoftWare_va.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    lbSoftWare_va.backgroundColor = colorCFBG;
    lbSoftWare_va.drawsBackground = YES;
    lbSoftWare_va.textColor = [NSColor blackColor];
    [groupBoxMachin addSubview:lbSoftWare_va];
    
    
    //
    //    [dicCell setObject:delegate.userName forKey:@"username"];
    //    [dicCell setObject:@"H_5.7" forKey:@"hardware_version"];
    //    [dicCell setObject:VERSION forKey:@"software_version"];
    //    [dicCell setObject:@"F_3.4" forKey:@"firmware_version"];
//    ===================================================== end data info
    
    NSButton *btClose = [[NSButton alloc] initWithFrame:NSMakeRect(width/2 - 50,20, 100, 30)];
    btClose.image = [NSImage imageNamed:@"buttonClose.png"];
    [[btClose cell] setBackgroundColor:[NSColor clearColor]];
    [btClose sizeToFit];
    //btClose.title = @"Close";
    btClose.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    [btClose setBordered:NO];
    btClose.layer.borderColor = [NSColor clearColor].CGColor;
    btClose.layer.borderWidth = 0;
    btClose.layer.cornerRadius = 4.0;
    [btClose setToolTip:@"close"];
    [btClose setTarget:self];
    [btClose setAction:@selector(btCloseClick:)];
    [self.view addSubview:btClose];
    
    return self;
}



- (void)loadView
{
    [super loadView];
    self.view = [[NSView alloc] init];
    
  //  self.view.frame = frameRect;
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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    //CGRect rect = CGRectMake(0, 0, 800, 600);
   // self.view.layer.backgroundColor = [NSColor brownColor].CGColor;
    //self.view.frame = rect;

}
- (void) btCloseClick:(id)sender
{
    [self.view.window close];
}
@end
