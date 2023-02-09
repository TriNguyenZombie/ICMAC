//
//  DeviceInfo.h
//  EarseMac
//
//  Created by TriNguyen on 5/4/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import <Realm/Realm.h>

@interface DeviceInfo : RLMObject

/*
 {
     ECID = 0xA582E20F1A526;
     UDID = 49f7b7ed304bca488d0b1732f1e1622ba39d9d57;
     deviceType = "iPhone9,3";
     locationID = 336736256;
     name = "iPhone9,3";
     "send_start" = 1;
     serial = 49f7b7ed304bca488d0b1732f1e1622ba39d9d57;
     "time_start" = "2022-08-31 10:46:58";
 }
 */
// Add properties here to define the model
@property NSString    *ID;
@property NSString    *cellID;
@property NSString    *createTime;
@property NSString    *serialNumber;
@property NSString    *productName;
@property NSString    *productType;
@property NSString    *productVersion;
@property NSString    *modelNumber;
@property NSString    *modelName;
@property NSString    *regionInfo;
@property NSString    *carrierDevice;
@property NSString    *colorDevice;
@property NSString    *capacityDevice;
@property NSString    *bluetoothAddress;
@property NSString    *wifiAddress;
@property NSString    *devicePasscode;
@property int         eraseVerify;
@property int         resultOfErasure;
@property NSString    *eraseStatus;
@property NSString    *itemID;
@property NSString    *IMEI;
@property NSString    *elapsedTime;





@end

RLM_ARRAY_TYPE(DeviceInfo)


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
  
  */
