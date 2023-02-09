//
//  AppDelegate.h
//  EarseMac
//
//  Created by Greystone on 12/16/21.
//  Copyright © 2021 Greystone. All rights reserved.
//  Link design: https://drive.google.com/drive/folders/12l0G-oU3ZV2o5Ql7tNnp5_MoPeg3-xCu
//  Link data result:https://dashboard1.greystonedatatech.com/admin/macbook-erasure-report/



#import <Cocoa/Cocoa.h>
#import "UIWindow.h"
#define BT_INFO 1000
#define BT_CHECK 1001
#define BT_STOP 1002
#define BT_RESCAN 1003

#define VERSION @"2.23"

#define DEBUG_TEST 0

@class LoginViewcontroller;
@class MainViewController;
static NSString *ipswName;
static bool isDownloadIPSW;
static NSString *pid_vendor;
static NSString *vid_vendor;
@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    UIWindow *window;
    LoginViewcontroller *viewController;
    int height, width;
    NSString *userName;
    NSString *serialNumberStation;
    NSColor *colorBanner;
    bool isLogout;
    int autoPrint;
    NSArray *arrPushingList;
    NSMutableDictionary *dicInfoSettingSave;
    NSMutableArray *arrServerLinks;
}

@property (nonatomic, assign) int autoPrint;
@property (nonatomic, assign) bool isLogout;
@property (nonatomic, assign) bool isDownload;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *mMacAddress;
@property (strong, nonatomic) NSString *serialNumberStation;
@property (strong, nonatomic) NSMutableArray *arrPushingListDelegate;
@property (strong, nonatomic) NSMutableDictionary *dicInfoSettingSave;
@property (strong, nonatomic) NSString *mMacAddress2Send;
@property (strong, nonatomic) NSMutableArray *arrServerLinks;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LoginViewcontroller *viewController;
@property (strong, nonatomic) NSColor *colorBanner;
@property (strong, nonatomic) MainViewController *mainViewController;
-(NSMutableAttributedString *)setColorTitleFor:(NSButton*) ButtonInfo color:(NSColor *)color size:(int)size;
-(NSMutableAttributedString *)setColorTitleFor:(NSButton*) ButtonInfo color:(NSColor *)color Font:(NSFont*)font;
- (void)logout;
- (NSMutableDictionary *)loadSettingInfoSave;
- (void)loadArrayServer:(NSString*)strServer;
- (BOOL)saveSettingInfo:(NSMutableDictionary *)dic;
- (NSString*)pathLib;
- (NSString*)postToServer:(NSString *)serverLink data:(NSString*)postString;
- (NSDictionary *)diccionaryFromJsonString:(NSString *)stringJson;
- (NSString *)jsonStringFromDictionary:(NSDictionary *)dictionary;
@end

/*
 libusb:
 (
         {
         "bcd_device" = 0x0304;
         manufacturer = "Apple Inc.";
         path = "3.1";// chi ra vi tri
         pid = 4783;
         product = Watch;
         serialnumber = 141243b7d4dcd59a94e95545492e6284cec7558e;
         vid = 1452;
     }
 )
 
 cell:{
 [NSNumber numberWithInt:j],@"row",
 [NSNumber numberWithInt:i],@"col",
 title, @"title",
 @"No device", @"conten",
 options,@"info",
 }
 */
 /*
  arrDatabaseCell: (
          {
          CheckboxValue = 1;
          InfoUpdated = 0;
          ProccessUSB = "<ProccessUSB: 0x60000184ff80>";
          TimeProccess = 0;
          UniqueDeviceID = "";
          button = "<NSButton: 0x7f9038c41560>";
          "capacity_device" = "N/A";
          "carrier_device" = "N/A";
          col = 0;
          "color_device" = "N/A";
          conten = "No device";
          counterDisconnected = 0;
          counterTrust = 0;
          elapsedTime = "00:00:00";
          "firmware_version" = "4.5a";
          "hardware_version" = "3.0";
          index = 0;
          info =         {
          };
          isWaiting = 0;
          itemID = "";
          note = "";
          "num_board" = 1;
          result = 2;
          row = 0;
          "software_version" = "1.07";
          startTimerErase = 0;
          status = 0;
          title = A1;
          "update_info" = 0;
          username = tuyennguyen;
      },...)
  
  
  object:{
      col = 0;
      conten = "iWatch Type:Watch3,4\nSerial :FHLVJ320J5X5\nPath:3.1";
      info =     {
          ActivationState = Unactivated;
          BasebandStatus = NoTelephonyCapabilty;
          BluetoothAddress = "68:ab:1e:03:68:e7";
          BoardId = 26;
          BrickState = 1;
          BuildVersion = 19R570;
          CPUArchitecture = armv7k;
          ChipID = 32772;
          DeviceClass = Watch;
          DeviceColor = 1;
          DeviceName = "Apple Watch";
          DieID = 1976424373755686;
          EthernetAddress = "68:ab:1e:03:69:18";
          FirmwareVersion = "iBoot-7429.40.94";
          HardwareModel = N121bAP;
          HardwarePlatform = t8004;
          HostAttached = 1;
          MLBSerialNumber = FN673930880J0Y342;
          ModelNumber = MQL22;
          NonVolatileRAM =         {
              "auto-boot" = {length = 4, bytes = 0x74727565};
              "backlight-level" = {length = 3, bytes = 0x353837};
              "backlight-nits" = {length = 10, bytes = 0x30783031323732656438};
              "boot-args" = "";
              bootdelay = {length = 1, bytes = 0x30};
              "com.apple.System.tz0-size" = {length = 8, bytes = 0x3078363030303030};
              "device-material" = {length = 192, bytes = 0x30313030 30303030 30303030 30303030 ... 30343030 30303030 };
              "oblit-begins" = {length = 88, bytes = 0x4f626c69 74547970 653a204f 626c6974 ... 70702f53 65747570 };
              obliteration = {length = 38, bytes = 0x68616e64 6c655f6d 65737361 67653a20 ... 6f6d706c 6574650a };
          };
          PairRecordProtectionClass = 4;
          PartitionType = "GUID_partition_scheme";
          PasswordProtected = 0;
          ProductName = "Watch OS";
          ProductType = "Watch3,4";
          ProductVersion = "8.1";
          ProductionSOC = 1;
          ProtocolVersion = 2;
          RegionInfo = "ZP/A";
          SerialNumber = FHLVJ320J5X5;
          SoftwareBehavior = {length = 16, bytes = 0x01000000000000000000000000000000};
          SoftwareBundleVersion = "";
          SupportedDeviceFamilies =         (
              4
          );
          TelephonyCapability = 0;
          TimeIntervalSince1970 = "39901.883138";
          TimeZone = "US/Pacific";
          TimeZoneOffsetFromUTC = "-28800";
          TrustedHostAttached = 1;
          UniqueChipID = 1976424373755686;
          UniqueDeviceID = 141243b7d4dcd59a94e95545492e6284cec7558e;
          UseRaptorCerts = 1;
          Uses24HourClock = 0;
          WiFiAddress = "68:ab:1e:03:69:17";
      };
      row = 0;
      status = 0;
      title = A1;
  }
  
  
  <__NSArrayM 0x600003850cc0>(
  {
      ProtocolHW = "<ProtocolHW: 0x7fe5e40d6200>";
      UniqueDeviceID = AU04OGX7;
      VersionHW =     {
          firmware = "5.13";
          hardware = "4.02";
      };
      "bcd_device" = 0x0600;
      iSerialNumber = 3;
      "location_port" =     {
          1 = 0x14324000;
          2 = 0x14323000;
          3 = 0x14322000;
          4 = 0x14321000;
          5 = 0x14344000;
          6 = 0x14343000;
          7 = 0x14342000;
          8 = 0x14341000;
      };
      manufacturer = FTDI;
      path = 2;
      pid = 24577;
      product = "FT232R USB UART";
      vid = 1027;
  }
  )

  
  
  
  */
