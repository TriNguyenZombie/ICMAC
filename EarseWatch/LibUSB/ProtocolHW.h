//
//  Protocol.h
//  EarseWatch
//
//  Created by Duyet Le on 1/17/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "qextserialport.h"
NS_ASSUME_NONNULL_BEGIN
enum LED_STATUS
{
    NO_CHARGE         = 0x00,
    LED_RED,
    LED_GREEN,
    LED_YELLOW,
    LED_RED_BLINK,
    LED_GREEN_BLINK,
    LED_YELLOW_BLINK,
    LED_RED_GREEN_BLINK,
    LED_RED_YELLOW_BLINK,
    LED_GREEN_YELLOW_BLINK,
    LED_OFF
};

enum USB_MODE_STATUS
{
    NO_CHANGE         = 0x00,
    USB_MODE,
    USB_CHARGE_MODE,
    USB_POWER_ON,
    USB_POWER_OFF
};

@interface ProtocolHW : NSObject
{
    NSString *error_msg;
    int process_fw;

//    int             fileDescriptor;
//    BOOL            isOpenPort;
//    kern_return_t    kernResult;
//    io_iterator_t    serialPortIterator;
    char            bsdPath[MAXPATHLEN];
    int flagCheckButtonPress;// use for chech button on board press
    int boardNumber;
   
    __strong id appDelegate;
    
    bool isOpenPort;
    int fileDescriptor;
    bool updateFWStart;
}
@property (assign, nonatomic)  int boardNumber;
@property (assign, nonatomic)  NSMutableDictionary *infoHW;

- (NSDictionary *) checkVersion:(NSString *)serial;
- (unsigned short) ledControl:(NSString *)serial ledArr:(Byte*)arr;
- (unsigned short) usbControlTurnOFF:(NSString *)serial usbArr:(Byte*)arr;
- (unsigned short) usbControlTurnON:(NSString *)serial usbArr:(Byte*)arr;
- (void) startCheckButton:(NSString *)serial;
- (void) closeSerialPort;

- (unsigned short) upgradeFw:(NSString *)serial;
- (unsigned short) startUpgradeFw:(NSString *)moduleId fwVersion:(unsigned long) fwVersion totalByte:(unsigned long) totalByte sum32:(unsigned long) sum32;
- (unsigned short) sendUpgradeFw:(NSString *)moduleId addrPage:(unsigned short) addrPage dataUpgrade:(unsigned char*) dataUpgrade dataLen:(unsigned short) dataLen;
- (unsigned short) finishUpgradeFw:(NSString *)serial;
- (bool) upgradeFirmware:(NSString*)filename;
char* showDebugPackage(void* unk_buf, unsigned long byte_cnt);
@end

NS_ASSUME_NONNULL_END
