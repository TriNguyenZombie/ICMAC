//
//  ProccessUSB.h
//  EarseMac
//
//  Created by Duyet Le on 12/27/21.
//  Copyright © 2021 Greystone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "libusb.h"
NS_ASSUME_NONNULL_BEGIN

// dang ky nhan event khi task ket thuc: [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskFinished:) name:NSTaskDidTerminateNotification object:nil];


@interface ProccessUSB : NSObject
{
    libusb_context *usbContext;
    int count;
    
}
@property (strong, nonatomic) NSMutableArray *arrDeviceBackupLib;

- (NSMutableArray *)getListModule;
- (void)showListUsbDevice;
- (int)resetUSBwithVid:(int)vid Pid:(int)pid;
- (NSMutableArray *)getListiWatchDevice;
- (NSMutableArray *)getListiMacDevice;
- (NSMutableArray *)getListiMacDeviceByAppleConfig;
- (bool) checkDeviceInDFU_Mode:(NSString *)mEECID;
- (bool) checkDeviceConnectByECID:(NSString *)mEECID;


- (NSMutableDictionary *)getInfoUSBDevice:(NSString *)udid;
- (bool)restoreWatch:(NSString *)UniqueDeviceID pathFile:(NSString *)path;

- (NSMutableDictionary *) print_device:(libusb_device *)device;
- (void) send:(libusb_context *)usb_context vid:(uint16_t) vid pid:(uint16_t) pid;

- (bool)listDir:(NSString *)dir;

- (NSString *)runCommand:(NSString*)cmd param:(NSArray*)arguments;
- (bool)actionCommand:(NSString*)cmd param:(NSArray*)arguments;
- (NSString *)checkDevicePaired:(NSString *)commandToRun;
- (NSString *)checkDeviceDisconnect:(NSString *)commandToRun;

@end

NS_ASSUME_NONNULL_END
/*
 idevicerestore parameter:
 
        -i, --ecid ECID
              target  specific  device   by   its   hexadecimal   ECID   e.g.   0xaabb123456   or
              00000012AABBCCDD.

       -u, --udid UDID
              target  specific device by its 40-digit device UDID.  NOTE: only works with devices
              in normal mode.

       -e, --erase
              perform a full restore, erasing all data (defaults to update).

       -c, --custom
              restore with a custom firmware.

       -l, --latest
              use latest available firmware (with download on demand). DO NOT USE if you need  to
              preserve  the  baseband (unlock)! USE WITH CARE if you want to keep a jailbreakable
              firmware! The FILE argument is ignored when using this option.

       -s, --cydia
              use Cydia's signature service instead of Apple's.

       -x, --exclude
              exclude nor/baseband upgrade.

       -t, --shsh
              fetch TSS record and save to .shsh file, then exit.

       -p, --pwn
              put device in pwned DFU mode and exit (limera1n devices only).

       -n, --no-action
              do not perform any restore action. If combined with -l option the  on  demand  IPSW
              download is performed before exiting.

       -C, --cache-path DIR
              use specified directory for caching extracted or other reused files.

       -d, --debug
              enable communication debugging.

       -h, --help
              prints usage information.

       -v, --version
              prints version information.
 
 */
//Examole:
/*
     ProccessUSB *libusb = [[ProccessUSB alloc] init];
     NSMutableDictionary *dicw6 = [libusb getInfoUSBDevice:@"141243b7d4dcd59a94e95545492e6284cec7558e"];
     NSMutableDictionary *dicw2 = [libusb getInfoUSBDevice:@"34ab381d997043cadb184d76c46a2dbb98c8c57e"];
     NSLog(@"%s dicw6:%@",__func__,dicw6);
     NSLog(@"%s dicw2:%@",__func__,dicw2);
     [libusb actionCommand:@"ideviceinfo" param:@[@"-u",@"34ab381d997043cadb184d76c46a2dbb98c8c57e"]];
     return;
     
     //=================
     
     NSThread *myThread1 = [[NSThread alloc] initWithTarget:self selector:@selector(xoaWatch01) object:nil];
     [myThread1 start];
     NSThread *myThread2 = [[NSThread alloc] initWithTarget:self selector:@selector(xoaWatch02) object:nil];
     [myThread2 start];
 
     return;
     
     //=================
     
 //    get plist
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
     NSLog( @"Dic is %@", dic );
     if(!dic){
         NSLog(@"Error: %@",error);
     }
     return;
     //=================
     ProccessUSB *libusb = [[ProccessUSB alloc] init];
     [libusb listDir:pathLib];
     return;
     //=================
     ProccessUSB *libusb = [[ProccessUSB alloc] init];
     NSString *path = @"/Users/duyetle/Documents/IPSW/Watch_2_Regular_6.3_17U208_Restore.ipsw";
     NSString *UniqueDeviceID = @"34ab381d997043cadb184d76c46a2dbb98c8c57e";
     NSString *cmd = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/EarseWatch/Lib/idevicerestore/src/idevicerestore"]].path;
     NSString *kq = [libusb actionCommand:cmd param:@[@"-u",UniqueDeviceID,path]];
     NSLog(@"%s kq:%@",__func__,kq);
     return;
     //=================
 //da chay
     ProccessUSB *libusb = [[ProccessUSB alloc] init];
     NSString *UniqueDeviceID = @"34ab381d997043cadb184d76c46a2dbb98c8c57e";
     NSString *path = @"/Users/duyetle/Documents/IPSW/Watch_2_Regular_6.3_17U208_Restore.ipsw";
     [libusb restoreWatch:UniqueDeviceID pathFile:path];
     //[libusb actionCommand:@"/Users/duyetle/Documents/EarseWatch/Lib/idevicerestore/src/idevicerestore" param:@[@"-e",@"--latest"]];
     return;
    
     //=================
     ProccessUSB *libusb = [[ProccessUSB alloc] init];
     NSMutableArray *arr = [libusb getListiWatchDevice];
     NSLog(@"%s arr: %@",__func__,arr);
     [libusb getInfoAllUSBDevice];
     NSLog(@"%s list Module:%@",__func__,[libusb getListModule]);
 //
 //    return;
     //=================
 //    ProccessUSB *libusb = [[ProccessUSB alloc] init];
 //    [libusb showListUsbDevice];
 //    return;
     //===============
 //    NSMutableArray *arrDatabaseCell = [libusb getListiWatchDevice];
 //    if(arrDatabaseCell == nil)
 //        arrDatabaseCell = [[NSMutableArray alloc] init];
 //    NSLog(@"%s list:\n%@",__func__,arrDatabaseCell);
 //    return;
 
 
 
 */
