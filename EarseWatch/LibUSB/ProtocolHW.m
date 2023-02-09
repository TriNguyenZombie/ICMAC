//
//  Protocol.m
//  EarseWatch
//
//  Created by Duyet Le on 1/17/22.
//  Copyright © 2022 Greystone. All rights reserved.
//
#define ProtocolDEBUG

//#if defined(ProtocolDEBUG) || defined(DEBUG_ALL)
#ifdef ProtocolDEBUG
#   define debug_common(LichDuyet, ...) NSLog((@"%s[Line %d]" LichDuyet), __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define debug_common(...)
#endif
#import "AppDelegate.h"
#import "ProtocolHW.h"
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <paths.h>
#include <termios.h>
#include <sysexits.h>
#include <sys/param.h>
#include <sys/select.h>
#include <sys/time.h>
#include <time.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/serial/ioss.h>
#include <IOKit/IOBSD.h>
#include "define_gds.h"
#include <unistd.h>

#define     SIG_OFF             0x00
#define     SIDE_OFF            0x02
#define     CODE_OFF            0x04
#define     DIRECT_OFF          0x05
#define     PROTO_VER_OFF       0x06
#define     MODULE_OFF          0x07
#define     POSITION_OFF        0x08  //send
#define     STATUS_OFF          0x08  //receive

#define     ADDR_PAGE_OFF       0x08  //send data upgrage FW
#define     FW_CONTENT_OFF      0x0a  //send data upgrage FW
#define     MIC_POSITION        0x08


//Command code
#define     CM_READ_VERSION             0x01
#define     CM_START_TEST               0x02
#define     CM_STOP_TEST                0x03
#define     CM_TESTING                  0x04
#define     CM_UPDATE_INFO              0x05
#define     CM_SWITCH_USB               0x06

#define     CM_UPGRADE_FW               0x07
#define     CM_START_UGFW               0x08
#define     CM_SEND_UGFW                0x09
#define     CM_FINISH_UGFW              0x0A

#define     CM_SWITCH_DEVICE_PLUGGED    0x0B
#define     CM_POWER_ON                 0x0C
#define     CM_POWER_OFF                0x0D
#define     CM_RESET                    0x0E
#define     CM_CHANGE_CRITERIA          0x0F
#define     CM_RESET_USB_HUB            0x10
#define     CM_SET_SW_ID                0x11
#define     CM_SET_LED                  0x13
#define     CM_READ_BUTTON_EVENT        0x14

#define     CMD_CHECK_SN                0X16
#define     CMD_SWITCH_MIC              0x17
#define     CMD_DETECT_SHORTED          0x18

#define     CM_FAST_CHARGE_OLD_FW       0x07

#define     IBATTERY_32                 1
#define     ZEROIT_32                   2
#define     ICAPTURE_32                 3

#define     SUCCESS                     1
#define     FALSED                      0
#define     ERR_CHECKSUM                2

typedef struct Hardware_info{

    unsigned char moduleIndex;
    NSString *fwVersion;
    NSString *hwVersion;

}hardware_info;

//job code
enum FW_JOB_CODE
{
    START_TEST_JOB      = 0x00,
    TESTING_JOB,
    STOP_TEST_JOB,
    SWITCH_USB,
    SWITCH_DEVICE_PLUGGED_JOB,
    POWER_OFF_JOB,
    CHANGE_CRITERIA,
    RESET_USB_HUB,
    LED_CONTROL_JOB

};



#define kATCommandString    "AT\r"

#ifdef LOCAL_ECHO
#define kOKResponseString    "AT\r\r\nOK\r\n"
#else
#define kOKResponseString    "\r\nOK\r\n"
#endif

// Hold the original termios attributes so we can reset them
static struct termios gOriginalTTYAttrs;


static kern_return_t findModems(io_iterator_t *matchingServices);
static kern_return_t getModemPath(io_iterator_t serialPortIterator, char *bsdPath, CFIndex maxPathSize);
static int openSerialPort(const char *bsdPath);
static char *logString(char *str);
static Boolean initializeModem(int fileDescriptor);
static void closeSerialPort(int fileDescriptor);


@implementation ProtocolHW
@synthesize boardNumber; // chua dung den
@synthesize infoHW;
- (id)init
{
    self = [super init];
    isOpenPort = NO;
    fileDescriptor = -1;
    boardNumber = -1;// chua set
    dispatch_async(dispatch_get_main_queue(), ^{
        self->appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    });
  
    return self;
}

// Returns an iterator across all known modems. Caller is responsible for
// releasing the iterator when iteration is complete.
static kern_return_t findModems(io_iterator_t *matchingServices)
{
    kern_return_t            kernResult;
    CFMutableDictionaryRef    classesToMatch;
    
    // Serial devices are instances of class IOSerialBSDClient.
    // Create a matching dictionary to find those instances.
    classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue);
    if (classesToMatch == NULL) {
        printf("IOServiceMatching returned a NULL dictionary.\n");
    }
    else {
        // Look for devices that claim to be modems.
        CFDictionarySetValue(classesToMatch,
                             CFSTR(kIOSerialBSDTypeKey),
                             CFSTR(kIOSerialBSDModemType));
        
        // Each serial device object has a property with key
        // kIOSerialBSDTypeKey and a value that is one of kIOSerialBSDAllTypes,
        // kIOSerialBSDModemType, or kIOSerialBSDRS232Type. You can experiment with the
        // matching by changing the last parameter in the above call to CFDictionarySetValue.
        
        // As shipped, this sample is only interested in modems,
        // so add this property to the CFDictionary we're matching on.
        // This will find devices that advertise themselves as modems,
        // such as built-in and USB modems. However, this match won't find serial modems.
    }
    
    // Get an iterator across all matching devices.
    kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, classesToMatch, matchingServices);
    if (KERN_SUCCESS != kernResult) {
        printf("IOServiceGetMatchingServices returned %d\n", kernResult);
        goto exit;
    }
    
exit:
    return kernResult;
}

// Given an iterator across a set of modems, return the BSD path to the first one with the callout device
// path matching MATCH_PATH if defined.
// If MATCH_PATH is not defined, return the first device found.
// If no modems are found the path name is set to an empty string.
static kern_return_t getModemPath(io_iterator_t serialPortIterator, char *bsdPath, CFIndex maxPathSize)
{
    io_object_t        modemService;
    kern_return_t    kernResult = KERN_FAILURE;
    Boolean            modemFound = false;
    
    // Initialize the returned path
    *bsdPath = '\0';
    
    // Iterate across all modems found. In this example, we bail after finding the first modem.
    
    while ((modemService = IOIteratorNext(serialPortIterator)) && !modemFound) {
        CFTypeRef    bsdPathAsCFString;
        
        // Get the callout device's path (/dev/cu.xxxxx). The callout device should almost always be
        // used: the dialin device (/dev/tty.xxxxx) would be used when monitoring a serial port for
        // incoming calls, e.g. a fax listener.
        
        bsdPathAsCFString = IORegistryEntryCreateCFProperty(modemService,
                                                            CFSTR(kIOCalloutDeviceKey),
                                                            kCFAllocatorDefault,
                                                            0);
        if (bsdPathAsCFString) {
            Boolean result;
            
            // Convert the path from a CFString to a C (NUL-terminated) string for use
            // with the POSIX open() call.
            
            result = CFStringGetCString(bsdPathAsCFString,
                                        bsdPath,
                                        maxPathSize,
                                        kCFStringEncodingUTF8);
            CFRelease(bsdPathAsCFString);
            
#ifdef MATCH_PATH
            if (strncmp(bsdPath, MATCH_PATH, strlen(MATCH_PATH)) != 0) {
                result = false;
            }
#endif
            
            if (result) {
                printf("Modem found with BSD path: %s", bsdPath);
                modemFound = true;
                kernResult = KERN_SUCCESS;
            }
        }
        
        printf("\n");
        
        // Release the io_service_t now that we are done with it.
        
        (void) IOObjectRelease(modemService);
    }
    
    return kernResult;
}

static char *logString(char *str)
{
    static char     buf[2048];
    char            *ptr = buf;
    int             i;
    
    *ptr = '\0';
    
    while (*str) {
        if (isprint(*str)) {
            *ptr++ = *str++;
        }
        else {
            switch(*str) {
                case ' ':
                    *ptr++ = *str;
                    break;
                    
                case 27:
                    *ptr++ = '\\';
                    *ptr++ = 'e';
                    break;
                    
                case '\t':
                    *ptr++ = '\\';
                    *ptr++ = 't';
                    break;
                    
                case '\n':
                    *ptr++ = '\\';
                    *ptr++ = 'n';
                    break;
                    
                case '\r':
                    *ptr++ = '\\';
                    *ptr++ = 'r';
                    break;
                    
                default:
                    i = *str;
                    (void)sprintf(ptr, "\\%03o", i);
                    ptr += 4;
                    break;
            }
            
            str++;
        }
        
        *ptr = '\0';
    }
    
    return buf;
}
static int openSerialPort(const char *bsdPath)
{
    int                handshake;
    struct termios    options;
    int fileDescriptor;
    printf("opening serial port %s \n",  bsdPath);
    fileDescriptor = open(bsdPath, O_RDWR | O_NOCTTY | O_NONBLOCK);
    if (fileDescriptor == -1) {
        printf("Error opening serial port %s - %s(%d).\n",
               bsdPath, strerror(errno), errno);
        goto error;
    }
    
    // Note that open() follows POSIX semantics: multiple open() calls to the same file will succeed
    // unless the TIOCEXCL ioctl is issued. This will prevent additional opens except by root-owned
    // processes.
    // See tty(4) <x-man-page//4/tty> and ioctl(2) <x-man-page//2/ioctl> for details.
    
    if (ioctl(fileDescriptor, TIOCEXCL) == -1) {
        printf("Error setting TIOCEXCL on %s - %s(%d).\n",
               bsdPath, strerror(errno), errno);
        goto error;
    }
    
    // Now that the device is open, clear the O_NONBLOCK flag so subsequent I/O will block.
    // See fcntl(2) <x-man-page//2/fcntl> for details.
    
    if (fcntl(fileDescriptor, F_SETFL, 0) == -1) {
        printf("Error clearing O_NONBLOCK %s - %s(%d).\n",
               bsdPath, strerror(errno), errno);
        goto error;
    }
    
    // Get the current options and save them so we can restore the default settings later.
    if (tcgetattr(fileDescriptor, &gOriginalTTYAttrs) == -1) {
        printf("Error getting tty attributes %s - %s(%d).\n",
               bsdPath, strerror(errno), errno);
        goto error;
    }
    
    // The serial port attributes such as timeouts and baud rate are set by modifying the termios
    // structure and then calling tcsetattr() to cause the changes to take effect. Note that the
    // changes will not become effective without the tcsetattr() call.
    // See tcsetattr(4) <x-man-page://4/tcsetattr> for details.
    
    options = gOriginalTTYAttrs;
    
    // Print the current input and output baud rates.
    // See tcsetattr(4) <x-man-page://4/tcsetattr> for details.
    
    printf("Current input baud rate is %d\n", (int) cfgetispeed(&options));
    printf("Current output baud rate is %d\n", (int) cfgetospeed(&options));
    
    // Set raw input (non-canonical) mode, with reads blocking until either a single character
    // has been received or a one second timeout expires.
    // See tcsetattr(4) <x-man-page://4/tcsetattr> and termios(4) <x-man-page://4/termios> for details.
    
    cfmakeraw(&options);
    options.c_cc[VMIN] = 0;
    options.c_cc[VTIME] = 10;
    
    // The baud rate, word length, and handshake options can be set as follows:
    
    cfsetspeed(&options, B38400);        // Set 19200 baud
options.c_cflag |= (CS8     |        // Use 8 bit words
                        PARENB       |     // Parity enable (even parity if PARODD not also set)
                        CCTS_OFLOW  |    // CTS flow control of output
                        //CRTS_IFLOW |
                        //CREAD
                    CIGNORE);    // RTS flow control of input
    
    //FF 55 00 06 01 00 01 00  F8
    //settings.BaudRate=BAUD38400;
    //settings.Parity=PAR_NONE;
    //settings.DataBits=DATA_8;
   // settings.StopBits=STOP_1;
   // settings.FlowControl=FLOW_OFF;
    //settings.Timeout_Millisec=0;
    
    speed_t speed = 38400;// Set 38400 baud
    if (ioctl(fileDescriptor, IOSSIOSPEED, &speed) == -1) {
        printf("Error calling ioctl(..., IOSSIOSPEED, ...) %s - %s(%d).\n",
               bsdPath, strerror(errno), errno);
    }
    
    // Print the new input and output baud rates. Note that the IOSSIOSPEED ioctl interacts with the serial driver
    // directly bypassing the termios struct. This means that the following two calls will not be able to read
    // the current baud rate if the IOSSIOSPEED ioctl was used but will instead return the speed set by the last call
    // to cfsetspeed.
    
    printf("Input baud rate changed to %d\n", (int) cfgetispeed(&options));
    printf("Output baud rate changed to %d\n", (int) cfgetospeed(&options));
    
    // Cause the new options to take effect immediately.
    if (tcsetattr(fileDescriptor, TCSANOW, &options) == -1) {
        printf("Error setting tty attributes %s - %s(%d).\n",
               bsdPath, strerror(errno), errno);
        goto error;
    }
    
    // To set the modem handshake lines, use the following ioctls.
    // See tty(4) <x-man-page//4/tty> and ioctl(2) <x-man-page//2/ioctl> for details.
    
    // Assert Data Terminal Ready (DTR)
    if (ioctl(fileDescriptor, TIOCSDTR) == -1) {
        printf("Error asserting DTR %s - %s(%d).\n",
               bsdPath, strerror(errno), errno);
    }
    
    // Clear Data Terminal Ready (DTR)
    if (ioctl(fileDescriptor, TIOCCDTR) == -1) {
        printf("Error clearing DTR %s - %s(%d).\n",
               bsdPath, strerror(errno), errno);
    }
    
    // Set the modem lines depending on the bits set in handshake
    handshake = TIOCM_DTR | TIOCM_RTS | TIOCM_CTS | TIOCM_DSR;
    if (ioctl(fileDescriptor, TIOCMSET, &handshake) == -1) {
        printf("Error setting handshake lines %s - %s(%d).\n",
               bsdPath, strerror(errno), errno);
    }
    
    // To read the state of the modem lines, use the following ioctl.
    // See tty(4) <x-man-page//4/tty> and ioctl(2) <x-man-page//2/ioctl> for details.
    
    // Store the state of the modem lines in handshake
    if (ioctl(fileDescriptor, TIOCMGET, &handshake) == -1) {
        printf("Error getting handshake lines %s - %s(%d).\n",
               bsdPath, strerror(errno), errno);
    }
    
    printf("Handshake lines currently set to %d\n", handshake);
    
    unsigned long mics = 1UL;
    
    // Set the receive latency in microseconds. Serial drivers use this value to determine how often to
    // dequeue characters received by the hardware. Most applications don't need to set this value: if an
    // app reads lines of characters, the app can't do anything until the line termination character has been
    // received anyway. The most common applications which are sensitive to read latency are MIDI and IrDA
    // applications.
    
    if (ioctl(fileDescriptor, IOSSDATALAT, &mics) == -1) {
        // set latency to 1 microsecond
        printf("Error setting read latency %s - %s(%d).\n",
               bsdPath, strerror(errno), errno);
        goto error;
    }
    
    
    printf("open %s Success.\n", bsdPath );
    // Success
    return fileDescriptor;
    
    // Failure path
error:
    printf("open %s Failed.\n", bsdPath );
    if (fileDescriptor != -1) {
        close(fileDescriptor);
        fileDescriptor = -1;
    }
    
    return -1;
}
void closeSerialPort(int fileDescriptor)
{
    // Block until all written output has been sent from the device.
    // Note that this call is simply passed on to the serial device driver.
    // See tcsendbreak(3) <x-man-page://3/tcsendbreak> for details.
    if (tcdrain(fileDescriptor) == -1) {
        printf("Error waiting for drain - %s(%d).\n",
               strerror(errno), errno);
    }
    NSLog(@"%s tcdrain(fileDescriptor) ",__func__);
    // Traditionally it is good practice to reset a serial port back to
    // the state in which you found it. This is why the original termios struct
    // was saved.
    if (tcsetattr(fileDescriptor, TCSANOW, &gOriginalTTYAttrs) == -1) {
        printf("Error resetting tty attributes - %s(%d).\n",
               strerror(errno), errno);
    }
    NSLog(@"%s tcsetattr(fileDescriptor, TCSANOW, &gOriginalTTYAttrs) ",__func__);
    close(fileDescriptor);
    NSLog(@"%s close(fileDescriptor); ",__func__);
    fileDescriptor = -1;
}
static Boolean initializeModem(int fileDescriptor)
{
    unsigned char        buffer[17]= {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};    // Input buffer
    unsigned char        *bufPtr;        // Current char in buffer
    ssize_t        numBytes;        // Number of bytes read or written
    int            tries;            // Number of tries so far
    Boolean        result = false;
    int kNumRetries = 1;
    
    memset(buffer, 0x00, 17);
    
    //FF 55 00 06 01 00 01 00  F8
//    unsigned char dataSend[9] = {
//            0xFF, 0x55,
//            0x00, 0x00,  // side
//            0x00,        // command code
//            0x00, 0x01,  // Dir, protocol version
//            0x00,        // moduleId
//            0x00         // checksum
//        };
    Byte arr[9]= {0xFF, 0x55, 0x00, 0x06, 0x01,0x00,0x01,0x00,0xF8};
   // Byte arr_receive[16];
    for (tries = 1; tries <= kNumRetries; tries++)
    {
        for(int i=0;i< 9;i++)
            printf(" %02X",arr[i]);
        printf("\n");
        //printf("Try #%d\n", (int)strlen((const char *)arr));
        // Send an command to the modem
      //  numBytes = write(fileDescriptor, kATCommandString, strlen(kATCommandString));
        numBytes = write(fileDescriptor, arr, 9);
       
        if (numBytes == -1) {
            printf("Error writing to modem - %s(%d).\n", strerror(errno), errno);
            continue;
        }
        else {
            printf("Wrote %ld bytes \"%s\"\n", numBytes, logString((char *)arr));
            
        }
        
        if (numBytes < 9) {
            continue;
        }
        
        // Read characters into our buffer until we get a CR or LF
        sleep(2);
        bufPtr = buffer;
        do
        {
            numBytes = read(fileDescriptor, bufPtr, &buffer[sizeof(buffer)] - bufPtr - 1);
            printf("read numBytes:%d\n",(int)numBytes);
            if (numBytes == -1) {
                printf("Error reading from modem - %s(%d).\n", strerror(errno), errno);
            }
            else if (numBytes > 0)
            {
                bufPtr += numBytes;
//                if (*(bufPtr - 1) == '\n' || *(bufPtr - 1) == '\r') {
//                    break;
//                }
            }
            else
            {
                printf("end read Nothing read.\n");
            }
        
        } while (numBytes > 0);
        
        // NULL terminate the string and see if we got an OK response
        *bufPtr = '\0';
        
       // printf("Read \"%s\"\n", logString(buffer));
        for(int i=0; i< 16; i++)
            printf(" %02X",buffer[i]);
        printf("\n");
        
        if (strncmp((const char *)buffer, kOKResponseString, strlen(kOKResponseString)) == 0) {
            result = true;
            break;
        }
    }
    
    return result;
}
static NSMutableData *sendData(int fileDescriptor,NSMutableData *arrdata)
{
    unsigned char* fileBytes = (unsigned char*)arrdata.bytes;
    int sizeRead = 0;
    return senddata(fileDescriptor, fileBytes, (int)arrdata.length, &sizeRead);
}
static NSMutableData *senddata(int fileDescriptor,Byte *arr, int numbyte,int *sizeout)
{
    unsigned char        buffer[1000]= {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};    // Input buffer
    unsigned char        *bufPtr;        // Current char in buffer
    ssize_t        numBytes;        // Number of bytes read or written
    int            tries = 0;            // Number of tries so far
    Boolean        result = false;
    int kNumRetries = 1;
    memset(buffer, 0x00, 1000);
    
    //FF 55 00 06 01 00 01 00  F8
//    unsigned char dataSend[9] = {
//            0xFF, 0x55,
//            0x00, 0x00,  // side
//            0x00,        // command code
//            0x00, 0x01,  // Dir, protocol version
//            0x00,        // moduleId
//            0x00         // checksum
//        };
    //Byte arr[9]= {0xFF, 0x55, 0x00, 0x06, 0x01,0x00,0x01,0x00,0xF8};
   // Byte arr_receive[16];
    unsigned char        bufferReceive[16]= {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};    // Input buffer
    memset(bufferReceive, 0x00, 16);
    printf("\n");
    numBytes = 0;
    NSMutableData *firstdata = [[NSMutableData alloc] init];
    for (tries = 0; tries < kNumRetries; tries++)
    {
        memset(bufferReceive, 0x00, 16);
        printf(" Data send to firmware : ");
        for(int i=0; i< numbyte; i++)
        {
            printf("%02X ",arr[i]);
        }
        printf("\n");
        numBytes += write(fileDescriptor, arr, numbyte);
        if (numBytes == -1) {
            printf("Error writing to modem - %s(%d).\n", strerror(errno), errno);
            result = false;
            continue;
        }
        else {
            printf("Wrote %ld bytes \"%s\"\n", numBytes, logString((char *)arr));
            result = true;
        }
        
        if (numBytes < numbyte) {
            continue;
        }
        // Read characters into our buffer until we get a CR or LF
        sleep(1);
        //usleep(10000);
        int sizeRead = 0;
        bufPtr = buffer;
        do
        {
            //numBytes = read(fileDescriptor, bufPtr, &buffer[sizeof(buffer)] - bufPtr - 1);
            numBytes = read(fileDescriptor, bufferReceive, 16);
            printf("read numBytes:%d\n",(int)numBytes);
            if (numBytes == -1) {
                printf("Error reading from modem - %s(%d).\n", strerror(errno), errno);
            }
            else if (numBytes > 0)
            {
               // bufPtr += numBytes;
                sizeRead+= numBytes;
               // [firstdata appendBytes:bufPtr length:numBytes];
                [firstdata appendBytes:bufferReceive length:numBytes];
            }
            else
            {
                printf("end read Nothing read.\n");
            }
        } while (numBytes > 0);
        
        // NULL terminate the string and see if we got an OK response
        *bufPtr = '\0';
           
       // printf("Read \"%s\"\n", logString(buffer));
        printf(" Data receive from firmware : ");
        for(int i=0; i< sizeRead; i++)
        {
            unsigned char* fileBytes = (unsigned char*)firstdata.bytes;
            printf(" %02X", fileBytes[i]);
        }
        printf("\n");
        *sizeout = sizeRead;
    }
    
    if(result)
    return firstdata;
    else return nil;
}
static NSMutableData *sendByte(int fileDescriptor,NSMutableData *arrdata)
{
    unsigned char* fileBytes = (unsigned char*)arrdata.bytes;
    int sizeRead = 0;
    return sendNotSleep(fileDescriptor, fileBytes, (int)arrdata.length, &sizeRead);
}
static NSMutableData *sendNotSleep(int fileDescriptor,Byte *arr, int numbyte,int *sizeout)
{
    unsigned char        buffer[1000]= {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};    // Input buffer
    unsigned char        *bufPtr;        // Current char in buffer
    ssize_t        numBytes;        // Number of bytes read or written
    int            tries;            // Number of tries so far
    Boolean        result = false;
    int kNumRetries = 1;
    memset(buffer, 0x00, 1000);
    
    numBytes = 0;
    NSMutableData *firstdata = [[NSMutableData alloc] init];
    for (tries = 1; tries <= kNumRetries; tries++)
    {
        numBytes += write(fileDescriptor, arr, numbyte);
       
        if (numBytes == -1) {
            result = false;
            continue;
        }
        else
        {
            result = true;
        }
        
        if (numBytes < numbyte) {
            continue;
        }
        
        int sizeRead = 0;
        bufPtr = buffer;
        do
        {
            numBytes = read(fileDescriptor, bufPtr, &buffer[sizeof(buffer)] - bufPtr - 1);
            if (numBytes == -1) {
                printf("Error reading from modem - %s(%d).\n", strerror(errno), errno);
            }
            else if (numBytes > 0)
            {
                sizeRead+= numBytes;
                [firstdata appendBytes:bufPtr length:numBytes];
            }
        } while (numBytes > 0);
        
        // NULL terminate the string and see if we got an OK response
        *bufPtr = '\0';
           
        printf("\n");
        *sizeout = sizeRead;
    }
    
    if(result)
        return firstdata;
    else return nil;
}
- (void) closeSerialPort
{
    if(fileDescriptor != -1)
    {
    printf("%s board fileDescriptor %d.\n",__func__,fileDescriptor);
    closeSerialPort(fileDescriptor);
    isOpenPort = NO;
        NSLog(@"%s trongif",__func__);
    }
}
- (NSDictionary *) checkVersion:(NSString *)serial
{
    printf("%s board serial %s.\n",__func__,[serial UTF8String]);
    //char *second = "/dev/cu.usbserial-A601V5L5";
    if(isOpenPort==NO)
    {
        if([self openport:serial]==FALSED)
        {
            return nil;
        }
    }
    if ( fileDescriptor == -1) {
        printf("Open COM error(%s) .\n",[serial UTF8String]);
       // return EX_IOERR;
        return nil;
    }
    else
    {
        printf("Open COM successfully.(%s)\n",[serial UTF8String]);
    }
    Byte arr[9]= {0xFF, 0x55, 0x00, 0x06, 0x01, 0x00, 0x01, 0x00, 0xF8};
    NSMutableData *data = [NSMutableData dataWithBytes:arr length:9];
    int sizeRead = 0;
    //NSMutableData *result = senddata(fileDescriptor,arr,9,&sizeRead);
    NSMutableData *result = sendData(fileDescriptor,data);
    sizeRead = (int)result.length;
    printf("sizeRead = %d\n",sizeRead);
    for(int i=0;i< result.length;i++)
    {
        unsigned char* fileBytes = (unsigned char*)result.bytes;
        printf("%02X ", fileBytes[i]);
    }
    printf("\n");
    //closeSerialPort(fileDescriptor);
    printf("Modem port closed.\n");
    
    if (result!=NULL)
    {
        printf("check version Modem successfully.\n");
    }
    else {
        printf("Could not check version Modem.\n");
        //return EX_DATAERR;
        return nil;
    }
    
    unsigned char* dataRec = (unsigned char*)result.bytes;
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        printf("%s readVersion: check signature FAILED.\n",__func__);
        //return EX_UNAVAILABLE;
        return nil;
    }

    NSString *strHWVersion = @"NONE";
    NSString *strFWVersion = @"NOME";
    char str[12] = {0};
    if(dataRec[12] == 4)
    {
        sprintf(str, "%d.%d%d",dataRec[9], dataRec[10], dataRec[11]);
        strFWVersion = [NSString stringWithUTF8String:str];
        
       // hwInfo->fwVersion = QString(str);

        memset(str, 0, sizeof(str));
        sprintf(str, "%d.%d%d",dataRec[12], dataRec[13], dataRec[14]);
        strHWVersion = [NSString stringWithUTF8String:str];
        //hwInfo->hwVersion = QString(str);
    }
    else
    {
        sprintf(str, "%d.%d%c",dataRec[9], dataRec[10], dataRec[11]);
        strFWVersion = [NSString stringWithUTF8String:str];
        //hwInfo->fwVersion = QString(str);

        memset(str, 0, sizeof(str));
        sprintf(str, "%d.%d%c",dataRec[12], dataRec[13], dataRec[14]);
        strHWVersion = [NSString stringWithUTF8String:str];
        //hwInfo->hwVersion = QString(str);
    }
    if([[strHWVersion uppercaseString] rangeOfString:@"1.0D"].location != NSNotFound)
    {
        strHWVersion = @"3.0";
    }
    NSLog(@"strHWVersion:%@ - strFWVersion:%@",strHWVersion,strFWVersion);
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:strFWVersion,@"firmware",strHWVersion,@"hardware", nil];
    infoHW = [dic mutableCopy];
    return dic;
    //return EX_OK;
}
unsigned char calculateCRC(unsigned char *data, int len)
{
    int i = 0;
    unsigned char ck = 0;

    for(ck = 0, i = 0; i < len; i++)
    {
        ck += data[i];
    }
    return 256 - ck;
}
unsigned long calculateCRC32(unsigned char *buffFW, unsigned long size)
{
    unsigned short i, count;
    unsigned char data;
    unsigned long crc, mask, table[256];
    //qDebug()<<"-----------------QQQQQQQQQQQQQQQQQQQ-------------sizeofunsigned long"<<sizeof(crc);
    for (count = 0; count < 256; count++)   // Setup the Lookup table
    {
        crc = count;
        for (i = 0; i < 8; i++) // Do 8 times
        {
            mask = -(crc & 1);
            crc = (crc >> 1) ^ (0xEDB88320 & mask);
        }
        table[count] = crc;

    }
    crc = 0xFFFFFFFF;   // Initial Value

    for (i = 0; i < size; i++)
    {
        data = buffFW[i];

        crc = (crc >> 8) ^ table[(crc ^ data) & 0xFF];
    }
    return (~crc); // crc^0xFFFFFFFF : Final XOR Value
}
- (unsigned short) openport:(NSString *)serial
{
    printf("%s board serial %s.\n",__func__,[serial UTF8String]);
    if(isOpenPort == NO)
    {
        NSString *path = [NSString stringWithFormat:@"/dev/cu.usbserial-%@",serial];
        char *second = (char *)[path UTF8String];
        memcpy(bsdPath, second, strlen(second)+1);
        fileDescriptor = openSerialPort(bsdPath);
        if ( fileDescriptor == -1) {
            printf("Open COM error (%s).\n",[path UTF8String]);
            return FALSED;
        }
        else
        {
            printf("Open COM successfully (%s).\n",[path UTF8String]);
            isOpenPort = YES;
        }
    }
    return SUCCESS;
}

- (unsigned short) ledControl:(NSString *)serial ledArr:(Byte*)arr
{
    
    printf("%s board serial %s.\n",__func__,[serial UTF8String]);
    unsigned char *LEDMode = arr;

    if([self openport:serial]==FALSED)
    {
        NSLog(@"[ledControl]openport failed");
        return FALSED;
    }
   
    if(ledControl(LEDMode,fileDescriptor)==FALSED)
    {
        NSLog(@"[ledControl] ledControl failed");
        return FALSED;
    }
    return SUCCESS;
}

unsigned short ledControl(unsigned char LEDMode[8],int fileDescriptor)
{
    unsigned short i = 0;
   // unsigned short res = 0;  //result
   // unsigned short timeOut = 3000;
    unsigned short len = 0;
    unsigned char sum = 0;
    unsigned char moduleId = 0;

    unsigned char dataSend[17] = {
        0xFF, 0x55,
        0x00, 0x00,  // size
        0x00,        // command code
        0x00, 0x01,  // Dir, protocol version
        0x00,        // moduleId
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,// offset 8, led mode
        0x00
    };

    unsigned char dataRec[10]= {0};

    
    
    //send command
    len = sizeof(dataSend);
    //set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_SET_LED;
    dataSend[MODULE_OFF]= moduleId;

    for(i = 0; i < 8; i++)
    {
        dataSend[8 + i] = LEDMode[i];
    }

    sum = calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;

    if(fileDescriptor==-1)
    {
        NSLog(@"not open port");
        return FALSED;
    }
    
    NSMutableData *data = [NSMutableData dataWithBytes:dataSend length:len];
    int sizeRead = 0;
    NSMutableData *result = sendData(fileDescriptor,data);
    if(result == nil)
        return FALSED;
    sizeRead = (int)result.length;

    Byte *arr = (Byte *)result.bytes;

//    if(sizeRead < STATUS_OFF)
//    {
//        NSLog(@"%s ledControl :sizeRead %d data failede FAILED \n",__func__,sizeRead);
//        //error_msg += "ledControl: check sig err\n";
//        return FALSED;
//    }
    
    //check signature
    if(arr[0]!=0xFF && arr[1]!=0x55)
    {
        NSLog(@"%s ledControl : check signature FAILED \n",__func__);
        //error_msg += "ledControl: check sig err\n";
        return FALSED;
    }

    //check len
//    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

//    if(len + 3 != sizeof(dataRec))
//    {
//        debug_common("ledControl : len = %d \n", len);
//        debug_common("ledControl : check len FAILED \n");
//
//        error_msg += "ledControl: check len err\n";
//        return FALSED;
//    }
    //check sum
//    sum = calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);
//
//    if(sum != (unsigned char)dataRec[len+2])
//    {
//       // debug_common("switchDevicePlugged : check sum FAILED \n");
//
//        error_msg += "ledControl: check sum err\n";
//        return FALSED;
//    }
  
    //check code , status, module
    if(dataRec[CODE_OFF] != CM_SET_LED ||
            dataRec[MODULE_OFF] != moduleId ||
            dataRec[STATUS_OFF] != 0x01)
    {
        if(dataRec[STATUS_OFF] == 0x00)
        {
            NSLog(@"ledControl: FW check sum FAILED \n");
            return FALSED;
        }
        NSLog(@"ledControl: check code/ module Id/ status FAILED \n");
        return FALSED;
    }

    return SUCCESS;
}
- (void) startCheckButton:(NSString *)serial
{
    printf("%s board serial %s.\n",__func__,[serial UTF8String]);
    if([self openport:serial] == FALSED)
    {
        NSLog(@"open port %@ failed",serial);
        return;
    }
    unsigned char buttonBK[8];
    unsigned char buttonInfo[8];
    unsigned char deviceInfo[8];
    
    for (int i=0; i<8; i++)
    {
        buttonBK[i] = 0;
    }
    
    BOOL sendData;
    BOOL isLogout = NO;
    while (isLogout == NO)
    {
        if (updateFWStart == true) {
            sleep(100);
            continue;
        }
        AppDelegate *delegate = (AppDelegate *)appDelegate;
        isLogout = delegate.isLogout;
        sendData = NO;
        if(readKeyEvent(0, buttonInfo, deviceInfo,fileDescriptor)!= SUCCESS)
        {
//            for(int i=0;i<8;i++)
//                NSLog(@"%s %d button:%d-dev:%d",__func__,i,buttonInfo[i],deviceInfo[i]);
//            NSLog(@"");
        }
        // printf("\ndeviceInfo: %s \n",deviceInfo);
        printf("\n");
        
        NSMutableArray* mutableArray = [NSMutableArray array];
        for (int i = 0; i < 8; i++)
        {
           // printf(" bt[%d]=%2X   %2X",i,buttonInfo[i],buttonBK[i]);
            [mutableArray addObject:[NSNumber numberWithChar:buttonBK[i]]];
            if(buttonInfo[i] == 1)
            {
                NSLog(@"%s button %d status buttonInfo:%d-deviceInfo:%d",__func__, i, buttonInfo[i], deviceInfo[i]);
                buttonBK[i] = 1;
            }
            else if(buttonBK[i]==1)
            {
                buttonBK[i] = 0;
                sendData = YES;
                break;
            }
            
//            if(buttonBK[i] == 1)
//            {
//                buttonBK[i] = 0;
//                sendData = YES;
//                break;
//            }
        
        }
        
        if(sendData)
        {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:boardNumber],@"boardnum",
                                        serial,@"serial",
                                        mutableArray,@"buttonsState",
                                        nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BoardButtonsClick" object:dic];
            //sleep(1);
//            usleep(100);
        }
        usleep(100);
    }
    if(isLogout)
        [self closeSerialPort];
   
}

unsigned short readKeyEvent(unsigned char moduleId, unsigned char *buttonInfo, unsigned char *deviceInfo, int fileDescriptor)
{
 //   printf("\nreadKeyEvent\n");
//    unsigned short res = 0;  //result
//    unsigned short timeOut = 2000;
    unsigned short len = 0;
    unsigned char sum = 0;

    unsigned char dataSend[9] = {
        0xFF, 0x55,
        0x00, 0x00,  // side
        0x00,        // command code
        0x00, 0x01,  // Dir, protocol version
        0x00,        // moduleId
        0x00
    };

    //unsigned char dataRec[26]= {0};

    //send command
    len = sizeof(dataSend);
    //set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_READ_BUTTON_EVENT;
    dataSend[MODULE_OFF] = moduleId;


    sum = calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    
    if(fileDescriptor==-1 )
    {
        NSLog(@"not open port");
        return FALSED;
    }
    
    NSMutableData *data = [NSMutableData dataWithBytes:dataSend length:len];
    int sizeRead = 0;
    NSMutableData *result = sendByte(fileDescriptor,data);
  //  NSMutableData *result = sendData(fileDescriptor,data);
    if(result == nil)
    {
        NSLog(@"%s sendData FAILED \n",__func__);
        return FALSED;
    }
    sizeRead = (int)result.length;

    Byte *arr = (Byte *)result.bytes;
    
    //check signature
    if(arr[0]!=0xFF && arr[1]!=0x55)
    {
        NSLog(@"%s ledControl : check signature FAILED \n",__func__);

        //error_msg += "ledControl: check sig err\n";
        return FALSED;
    }
 

    //check len
   // len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

//    if(len + 3 != sizeof(dataRec))
//    {
//        debug_error("%s[ERROR]%s readKeyEvent -> check len FAILED moduleId = %d \n", KRED, RESET, moduleId);
//        error_msg += "readKeyEvent: check len err\n";
//        return FAILED;
//    }

    //check sum
//    sum = calculateCRC((unsigned char*)arr+ SIDE_OFF,len);
//
//    if(sum != (unsigned char)arr[len+2])
//    {
//        debug_common("%s[ERROR]%s readKeyEvent -> check sum FAILED moduleId = %d \n", KRED, RESET, moduleId);
//        return ERR_CHECKSUM;
//    }
    //check code , status, module
//    if(dataRec[CODE_OFF] != CM_READ_BUTTON_EVENT ||
//            dataRec[MODULE_OFF] != moduleId ||
//            dataRec[STATUS_OFF] != 0x01)
//    {
//        if(dataRec[STATUS_OFF]== 0x00)
//        {
//            debug_common("%s[ERROR]%s readKeyEvent -> FW check sum FAILED moduleId = %d \n", KRED, RESET, moduleId);
//            return ERR_CHECKSUM;
//        }
//
//        debug_common("%s[ERROR]%s readKeyEvent -> heck code/ module Id/ status FAILED moduleId = %d \n",KRED, RESET, moduleId);
//        return FALSED;
//    }

    memcpy(buttonInfo, arr + 9, 8);
    memcpy(deviceInfo, arr + 17, 8);
    return SUCCESS;
}

unsigned short get_ushort_be(unsigned char *buf, unsigned long off)
{
   unsigned short value;
   value = buf[off];
   value = (value<<8) | buf[off+1];
   return value;
}

unsigned long get_ulong_be(unsigned char *buf, unsigned long off)
{
   unsigned long value;
   value = buf[off];
   value = (value<<8)|buf[off+1];
   value = (value<<8)|buf[off+2];
   value = (value<<8)|buf[off+3];
   return value;
}

unsigned long long get_nbyte_be(unsigned char *buf, unsigned long off, unsigned char nbyte)
{
   unsigned long long value = 0;
   unsigned char i = 0;

   for(i=0; i< nbyte; i++)
   {
       value = (value<<8)|buf[i+off];
   }
   return value;
}

void set_ushort_be(unsigned char *buf, unsigned long off, unsigned short value)
{
   buf[off]   = value >> 8;
   buf[off+1] = value&0xFF;
}

void set_ulong_be(unsigned char *buf, unsigned long off, unsigned long value)
{
   buf[off]   = value >> 24;
   buf[off+1] = value >> 16;
   buf[off+2] = value >> 8;
   buf[off+3] = value&0xFF;
}

void set_nbyte_be(unsigned char *buf, unsigned long off, unsigned char numByte, unsigned long long value)
{
   unsigned char i = 0;
   for(i = 0;i < numByte; i++)
   {
       buf[off+i]   = (value >>8 * (numByte - i - 1)) & 0xFF;
   }

}

char canPrintChar(char character)
{
    if (character >= ' ' && character <= '~')
    {
        return YES;
    }
    return NO;
}

void printBuff08(unsigned char *buffer_address, int size)
{
    int i;
    int j;
    int len;

    fprintf(stderr,"size %d:\n", size);
    fprintf(stderr,"Print buffer at %s with size %d:\n", buffer_address, size);
    if(size>1024)
    {
        fprintf(stderr,"\n Size too large\n");
        len = 1024;
    }
    else
    {

        len = size;
    }

    for (i = 0; i < len; i++)
    {
        fprintf(stderr,"%02X ", buffer_address[i]&0xff);

        if ( ((i + 1) % 16 == 0) || (i == size - 1))
        {

            for (j = 1; j <= 15 - (i % 16); j++)
            {
                fprintf(stderr,"   ");
            }

            fprintf(stderr,"   |  ");

            for (j = i - (i % 16); j <= i; j++)
            {
                if (canPrintChar(buffer_address[j]) == YES)
                {
                    fprintf(stderr,"%c", buffer_address[j]);
                }
                else
                {
                    fprintf(stderr,".");
                }
            }
            fprintf(stderr,"\n");
        }
    }
}

- (unsigned short) startUpgradeFw:(NSString *)moduleId fwVersion:(unsigned long)fwVersion totalByte:(unsigned long)totalByte sum32:(unsigned long)sum32
{
    unsigned short res = 0;  //result
    unsigned short timeOut = 2000;
    unsigned short len = 0;

    unsigned char sum = 0;

    unsigned char dataSend[19] = {
        0xFF, 0x55,
        0x00, 0x00,  // side
        0x00,        // command code
        0x00, 0x01,  // Dir, protocol version
        0x00,         // moduleId
        0x00, 0x00, 0x00,  //FW version
        0x00, 0x00, 0x00,        //total byte
        0x00, 0x00, 0x00, 0x00, // CrC-32
        0x00
    };

    //unsigned  char dataRec[10]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
//    dataSend[len-3] = SIDE_OFF;

    dataSend[CODE_OFF]  = CM_START_UGFW;
    dataSend[MODULE_OFF] = 0x00;

    set_nbyte_be((unsigned char*)dataSend, 0x08, 3, fwVersion);
    set_nbyte_be((unsigned char*)dataSend, 0x0B, 3, (unsigned short)totalByte);
    set_ulong_be((unsigned char*)dataSend, 0x0E, sum32);

    sum = calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;

    NSMutableData *data = [NSMutableData dataWithBytes:dataSend length:len];
    int sizeRead = 0;
    NSMutableData *result = sendByte(fileDescriptor, data);

    if(result == nil)
    {
        NSLog(@"%s upgradeFw: sendData FAILED \n",__func__);
        return FALSED;
    }

    //receive result
    unsigned char* dataRec = (unsigned char*)result.bytes;

    if(dataRec == nil)
    {
        debug_common("startUpgradeFw : getPackage FAILED \n");
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("startUpgradeFw : getPackage check signature FAILED \n");
        return FALSED;
    }

    len = dataRec[SIDE_OFF]*256 + dataRec[SIDE_OFF+1];
    //check len
//    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);
//
//    if(len + 3 != sizeof(dataRec))
//    {
//        debug_common("startUpgradeFw : len = %d \n", len);
//        debug_common("startUpgradeFw : check len FAILED \n");
//        printBuff08((unsigned char *)dataRec, len);
//        return FALSED;
//    }
    
    //check sum
    sum = calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("startUpgradeFw : check sum FAILED \n");
        return ERR_CHECKSUM;
    }
    
    
    //check code , status, module
    printBuff08((unsigned char *)dataRec, len);
    if(dataRec[CODE_OFF] != CM_START_UGFW ||
            dataRec[MODULE_OFF] != 0x00 ||
            dataRec[STATUS_OFF] != 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("startUpgradeFw: FW check sum FAILED \n");

            return ERR_CHECKSUM;
        }
        debug_common("startUpgradeFw : check code/ module Id/ status FAILED \n");

        return FALSED;
    }

    return SUCCESS;
}

- (unsigned short) upgradeFw:(NSString *)moduleId
{
    unsigned short len = 0;

    unsigned char sum = 0;

    unsigned char dataSend[9] = {
        0xFF, 0x55,
        0x00, 0x00,  // side
        0x00,        // command code
        0x00, 0x01,  // Dir, protocol version
        0x00,         // moduleId
        0x00
    };

    //unsigned  char dataRec[10]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_UPGRADE_FW;
    dataSend[MODULE_OFF] = 0x00;
    sum = calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    
    showDebugPackage(dataSend, len);
    
    //res = sendPackage(dataSend,len);
//    fileDescriptor = open(bsdPath, O_RDWR | O_NOCTTY | O_NONBLOCK);
    NSMutableData *data = [NSMutableData dataWithBytes:dataSend length:len];
//    int sizeRead = 0;
    NSLog(@"%s upgradeFw: fileDescriptor (open port status): %d \n", __func__, fileDescriptor);

    NSMutableData *result = sendByte(fileDescriptor, data);
    
    if(result == nil)
    {
        NSLog(@"%s upgradeFw: sendData FAILED \n",__func__);
        return FALSED;
    }
    
    //receive result
    unsigned char* dataRec = (unsigned char*)result.bytes;
    len = sizeof(dataRec);

//    res = getPackage(dataRec, len, timeOut);
//    if(res != SUCCESS)
//    {
//        debug_common("upgradeFw : getPackage FAILED \n");
//        return res;
//    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        NSLog(@"%s upgradeFw : check signature FAILED \n",__func__);

        return FALSED;
    }
    len = dataRec[SIDE_OFF]*256 + dataRec[SIDE_OFF+1];

    //check len
//    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);
//
//    NSLog(@"sizeof(dataRec): %lu", sizeof(dataRec));
//    if(len + 3 != sizeof(dataRec))
//    {
//        debug_common("upgradeFw : getPackage len = %d \n", len);
//        debug_common("upgradeFw : getPackage check len FAILED \n");
//
//        return FALSE;
//    }

    //check sum
    sum = calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("upgradeFw : getPackage check sum FAILED \n");
        return ERR_CHECKSUM;
    }
    
    showDebugPackage(dataRec, len);

    //check code , status, module
    if(dataRec[CODE_OFF]!= CM_UPGRADE_FW ||
            dataRec[MODULE_OFF] != 0x00 ||
            dataRec[STATUS_OFF]!= 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            NSLog(@"%s upgradeFw : FW check sum FAILED \n",__func__);
            return ERR_CHECKSUM;
        }
        NSLog(@"%s upgradeFw : upgradeFw : check code/ module Id/ status FAILED \n",__func__);
        return FALSE;
    }
    
    return SUCCESS;
}

- (unsigned short) sendUpgradeFw:(NSString *)moduleId addrPage:(unsigned short) addrPage dataUpgrade:(unsigned char*) dataUpgrade dataLen:(unsigned short) dataLen
{
    unsigned short res = SUCCESS;  //result
    unsigned short timeOut = 1000;
    unsigned short len = 0, len_send = 0;

    unsigned char sum = 0;

    unsigned char dataSend[600] = {0};
    //unsigned char dataRec[10]= {0};

    unsigned char dataRec1[256]= {0};

    int readLen = -1;

    //send command
    memset(dataSend,0x00,sizeof(dataSend));

    len = FW_CONTENT_OFF + dataLen +1;

    set_ushort_be((unsigned char *)dataSend, SIG_OFF, 0xFF55);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_SEND_UGFW;
    dataSend[DIRECT_OFF]  = 0x00;
    dataSend[PROTO_VER_OFF]  = 0x01;
    dataSend[MODULE_OFF] = 0x00;
    set_ushort_be((unsigned char*)dataSend, ADDR_PAGE_OFF,addrPage);
    memcpy(dataSend + FW_CONTENT_OFF,dataUpgrade,dataLen);

    sum = calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    
    
    ///
    NSMutableData *data = [NSMutableData dataWithBytes:dataSend length:len];
    int sizeRead = 0;
    NSMutableData *result = sendByte(fileDescriptor, data);
    
    if(result == nil)
    {
        NSLog(@"%s upgradeFw: sendData FAILED \n",__func__);
        return FALSED;
    }
    
    //receive result
    unsigned char* dataRec = (unsigned char*)result.bytes;
    len = sizeof(dataRec);
    int cnt = 0;
//    res = getPackage(dataRec, len, timeOut);
//    if(res != SUCCESS)
//    {
//        debug_common("upgradeFw : getPackage FAILED \n");
//        return res;
//    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        NSLog(@"%s upgradeFw : check signature FAILED \n",__func__);

        return FALSED;
    }
    ///

//    res = sendPackage(dataSend,len);
//    len_send = len;
//    if(res != SUCCESS)
//    {
//        debug_common("sendUpgradeFw: sendPackage FAILED \n");
//
//        return res;
//    }

    //receive result
    //memset(dataRec, 0x00, sizeof(dataRec));
    //len = sizeof(dataRec);
    //res = this->getPackage(dataRec, len, timeOut, &readLen);
    
//    bool result = true;
//
//    if(res != SUCCESS)
//    {
//        result = false;
//        memset(dataRec1, 0x00, sizeof(dataRec1));
//        for(int retry = 0; retry < 3; retry++)
//        {
//            memcpy(dataRec1 + cnt, dataRec, readLen);
//            cnt += readLen;
//            if(cnt >= len)
//            {
//                result = true;
//                memset(dataRec, 0x00, sizeof(dataRec));
//                memcpy(dataRec, dataRec1, len);
//                break;
//            }
//            fprintf(stderr, "BBBBBBBBBB getPackage retry = %d \n", retry );
//            printBuff08((unsigned char *)dataRec1, cnt);
//
//
//            res = this->sendPackage(dataSend, len_send);
//
//            if(res != SUCCESS)
//            {
//                debug_common("sendUpgradeFw: sendPackage FAILED \n");
//                return res;
//            }
//            readLen = 0;
//            memset(dataRec, 0x00, sizeof(dataRec));
//            len = sizeof(dataRec);
//            res = this->getPackage(dataRec, len, timeOut, &readLen);
//            qDebug() << "=============== readLen = " << readLen;
//
//        }
//
//        fprintf(stderr, "AAAAAAAAAAAAAA getPackage : \n");
//        printBuff08((unsigned char *)dataRec, len);
//
//    }
//
//    if(result == false)
//    {
//        debug_common("sendUpgradeFw : getPackage FAILED \n");
//        return res;
//    }

    //check signature
    if(dataRec[0] != 0xFF && dataRec[1] != 0x55)
    {
        debug_common("sendUpgradeFw : check signature FAILED \n");
        return FALSED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

//    if(len + 3 != sizeof(dataRec))
//    {
//        debug_common("sendUpgradeFw : len = %d \n", len);
//        debug_common("sendUpgradeFw : check len FAILED \n");
//        printBuff08((unsigned char *)dataRec, len);
////        error_msg += "send upg fw: check len err\n";
//        return FALSED;
//    }
    //check sum
    sum = calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("sendUpgradeFw : check sum FAILED \n");
        printBuff08((unsigned char *)dataRec, len);

//        error_msg += "send upg fw: check sum err\n";
        return ERR_CHECKSUM;
    }
    fprintf(stderr, "AAAAAAAAAAAAAA getPackage : \n");
    printBuff08((unsigned char *)dataRec, len);
    //check code , status, module
    if(dataRec[CODE_OFF] != CM_SEND_UGFW ||
            dataRec[MODULE_OFF] != 0x00 ||
            dataRec[STATUS_OFF] != 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("sendUpgradeFw: FW check sum FAILED \n");

//            error_msg += "send upg fw: FW check sum err\n";
            return ERR_CHECKSUM;
        }
        debug_common("sendUpgradeFw : check code/ module Id/ status FAILED \n");

//        error_msg += "send upg fw: check code/status err\n";
        return FALSED;
    }

    return SUCCESS;
}

- (unsigned short) finishUpgradeFw:(NSString *)serial
{
    unsigned char moduleId = 0;
    unsigned short res = 0;  //result
    unsigned short timeOut = 1000;
    unsigned short len = 0;

    unsigned char sum = 0;

    unsigned char dataSend[9] = {
        0xFF, 0x55,
        0x00, 0x00,  // side
        0x00,        // command code
        0x00, 0x01,  // Dir, protocol version
        0x00,        // moduleId
        0x00
    };

    //unsigned char dataRec[10]= {0};
    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_FINISH_UGFW;
    dataSend[MODULE_OFF]= 0x00;
    
    sum = calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    
    NSMutableData *data = [NSMutableData dataWithBytes:dataSend length:len];
//    int sizeRead = 0;
    NSMutableData *result = sendByte(fileDescriptor, data);
    
    if(result == nil)
    {
        NSLog(@"%s upgradeFw: sendData FAILED \n",__func__);
        return FALSED;
    }
    
    //receive result
    unsigned char* dataRec = (unsigned char*)result.bytes;
    len = sizeof(dataRec);

    //receive result
    //memset(dataRec, 0x00, sizeof(dataRec));
    //len = sizeof(dataRec);
//    res = this->getPackage(dataRec, len, timeOut);
//    if(res != SUCCESS)
//    {
//        debug_common("finishUpgradeFw : getPackage FAILED\n");
//        return res;
//    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("finishUpgradeFw : check signature FAILED \n");
        return FALSED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

//    if(len + 3 != sizeof(dataRec))
//    {
//        debug_common("finishUpgradeFw : len = %d \n", len);
//        debug_common("finishUpgradeFw : check len FAILED \n");
//
//        //error_msg += "finish upg fw: check len err\n";
//        return FALSED;
//    }
    //check sum
    sum = calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("finishUpgradeFw : check sum FAILED \n");

//        error_msg += "finish upg fw: check sum err\n";
        return ERR_CHECKSUM;
    }
    //check code , status, module
    if(dataRec[CODE_OFF]!= CM_FINISH_UGFW ||
            dataRec[MODULE_OFF]!= 0x00 ||
            dataRec[STATUS_OFF]!= 0x01)
    {
        if(dataRec[STATUS_OFF] == 0x00)
        {
            debug_common("finishUpgradeFw: FW check sum FAILED \n");

//            error_msg += "finish upg fw: FW check sum err\n";
            return ERR_CHECKSUM;
        }
        debug_common("finishUpgradeFw : check code/ module Id/ status FAILED \n");

//        error_msg += "finish upg fw: check code/status err\n";
        return FALSED;
    }

    return SUCCESS;
}


- (bool) upgradeFirmware:(NSString*)filename
{
    updateFWStart = true;
    NSLog(@"upgradeFirmware --- file name: %@", filename);
    char * name = NULL;
    int size = 0, countbyte = 0;
    unsigned short addr = 0;

    //unsigned char buff[700000];//
    unsigned char* buff = NULL;
    unsigned int crc32sum = 1;
    unsigned int crc32verify = 0;
    unsigned int temp;
    unsigned short moduleID = 0;
    unsigned int fw_version = 0;
    unsigned short res = 0;
    int max_len = 2048;
    unsigned int size_read = max_len, cnt = 0;
    int size_crc = 0;
    FILE* file = NULL;
    int i, count;
    unsigned char data;
    unsigned int crc, mask, table[256];


    moduleID = 0;
    
    name = [filename UTF8String];
//    NSLog(@"upgradeFirmware --- name [c1]: %@", name);
    file = fopen(name, "rb");
    if (file == NULL)
    {
        NSLog(@"upgradeFirmware open file failed");
        return false;
    }
    fseek(file, 0, SEEK_END);
    size = ftell(file);
    if(size < 0)
    {
        return false;
    }

    if(size > 700000)
    {
        return false;
    }

    buff = (unsigned char*) malloc(max_len);
    if (buff == NULL)
    {
        return false;
    }
    memset(buff, 0xFF, max_len);

    fseek(file, 0, SEEK_SET);
    for (count = 0; count < 256; count++)   // Setup the Lookup table
    {
        crc = count;
        for (i = 0; i < 8; i++) // Do 8 times
        {
            mask = -(crc & 1);
            crc = (crc >> 1) ^ (0xEDB88320 & mask);
        }
        table[count] = crc;

    }
    NSLog(@"upgradeFirmware checksum file");
    crc = 0xFFFFFFFF;   // Initial Value
    //cal CRC
    for(i = size; i > 0; i -= max_len)
    {
        size_read = max_len;
        if (i < max_len)
        {
            size_read = i;
        }

        cnt = fread(buff, 1, size_read, file);

        NSLog(@"upgradeFirmware cnt: %u", cnt);
        if (cnt != (unsigned int) size_read)
        {
            fclose(file);
            return false;
        }
        //kiem tra block data cuoi cung cua file
        if((i - max_len) <= 0)
        {
            size_crc = size_read - 4;
            crc32verify = get_ulong_be(buff, size_crc);
        }
        else
        {
            size_crc = size_read;
        }

        for(count = 0; count < size_crc; count++)
        {
            data = buff[count];
            crc = (crc >> 8) ^ table[(crc ^ data) & 0xFF];
        }
    }
    crc32sum = ~crc;

    if(crc32sum != crc32verify)
    {
        debug_common("upgradeFirmware : file error !\n");
        return false;
    }

    for(int i = 0; i < 5; i++)
    {
        //res = upgradeFw(moduleID);
        res = [self upgradeFw:@""];
        if(res == SUCCESS)
        {
            break;
        }
    }

    if(res!= SUCCESS)
    {
        //error_msg += "upg FW err\n";
        return false;
    }
    process_fw = 0;
    sleep(1);//2 s
    res = [self startUpgradeFw:@"" fwVersion:fw_version totalByte:size - 4 sum32:crc32sum];
    //res = startUpgradeFw(moduleID, fw_version, size - 4, crc32sum);

    if((res== TIME_OUT) || (res== ERR_CHECKSUM))
    {
        //res = startUpgradeFw(moduleID, fw_version, size - 4, crc32sum);
        
        res = [self startUpgradeFw:@"" fwVersion:fw_version totalByte:size - 4 sum32:crc32sum];
    }

    if(res!= SUCCESS)
    {
        return false;
    }

    countbyte = 0;
    addr = 0;
    usleep(200000);
    if(buff != NULL)
    {
        free(buff);
        buff = NULL;
    }
    max_len = 512;
    buff = (unsigned char*) malloc(max_len);
    if (buff == NULL)
    {
        return false;
    }
    memset(buff, 0xFF, max_len);
    fseek(file, 0, SEEK_SET);

    for(i = size; i > 0; i -= max_len)
    {
        size_read = max_len;
        if (i < max_len)
        {
            size_read = i;
        }
        memset(buff, 0xFF, max_len);
        cnt = fread(buff, 1, size_read, file);

        if (cnt != (unsigned int) size_read)
        {
            fclose(file);
            return false;
        }
        //kiem tra block data cuoi cung cua file
        if((i - max_len) <= 0)
        {
            buff[size_read - 4] = 0xFF;
            buff[size_read - 3] = 0xFF;
            buff[size_read - 2] = 0xFF;
            buff[size_read - 1] = 0xFF;
            if(size_read % max_len != 0)
            {
                size_read = max_len;
            }
        }

        for(int retry = 0; retry < 2; retry++)
        {
            //res = sendUpgradeFw(moduleID, addr, buff, size_read);
            res = [self sendUpgradeFw:@"" addrPage:addr dataUpgrade:buff dataLen:size_read];
            if(res == SUCCESS)
            {
                break;
            }
            sleep(1);
        }


        if(res != SUCCESS)
        {
            return false;
        }
        countbyte += size_read;
        addr++;
        process_fw = countbyte * 100 / size ;
        usleep(5000);

    }

    if(buff != NULL)
    {
        free(buff);
    }
    res = [self finishUpgradeFw:@""];
    //res = finishUpgradeFw(moduleID);

    if((res == TIME_OUT)||(res == ERR_CHECKSUM))
    {
        //res = finishUpgradeFw(moduleID);
        res = [self finishUpgradeFw:@""];
    }

    if(res!= SUCCESS)
    {
        return false;
    }
    sleep(2);
    return true;
}

- (unsigned short) usbControlTurnOFF:(NSString *)serial usbArr:(Byte*)arr
{
    printf("%s [ProtocolHW][usbControlTurnON_OFF] board serial %s.\n",__func__,[serial UTF8String]);
    unsigned char *usbArr = arr;

    if([self openport:serial]==FALSED)
    {
        NSLog(@"[ProtocolHW][usbControlTurnON_OFF] openport failed");
        return FALSED;
    }
   
    if(swichUsbOFF(usbArr, fileDescriptor) == FALSED)
    {
        NSLog(@"[ProtocolHW][usbControlTurnON_OFF] turnUSB_power_OFF failed");
        return FALSED;
    }
    NSLog(@"[ProtocolHW][usbControlTurnON_OFF] turnUSB_power_OFF SUCCESS");

    return SUCCESS;
}

- (unsigned short) usbControlTurnON:(NSString *)serial usbArr:(Byte*)arr
{
    printf("%s [ProtocolHW][usbControlTurnON_OFF] board serial %s.\n",__func__,[serial UTF8String]);
    unsigned char *usbArr = arr;

    if([self openport:serial]==FALSED)
    {
        NSLog(@"[ProtocolHW][usbControlTurnON_OFF] openport failed");
        return FALSED;
    }
   
    if(swichUsbON(usbArr, fileDescriptor) == FALSED)
    {
        NSLog(@"[ProtocolHW][usbControlTurnON_OFF] turnUSB_power_OFF failed");
        return FALSED;
    }
    NSLog(@"[ProtocolHW][usbControlTurnON_OFF] turnUSB_power_OFF SUCCESS");

    return SUCCESS;
}

unsigned short swichUsbON(unsigned char USB_mode[8], int fileDescriptor)
{
    unsigned short i = 0;
   // unsigned short res = 0;  //result
   // unsigned short timeOut = 3000;
    unsigned short len = 0;
    unsigned char sum = 0;
    unsigned char moduleId = 0;

    char dataSend[17] = {
         0xFF, 0x55,
         0x00, 0x0E,  // side
         0x00,        // command code
         0x00, 0x01,  // Dir, protocol version
         0x00,        // moduleId
         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // USB mode
         0x00
     };

    unsigned char dataRec[10]= {0};

    //send command
    len = sizeof(dataSend);
    //set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_SWITCH_USB;
    dataSend[MODULE_OFF]= moduleId;
    
    

    for(i = 0; i < 8; i++)
    {
        dataSend[8 + i] = USB_mode[i];
    }
    

    sum = calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;

    if(fileDescriptor==-1)
    {
        NSLog(@"not open port");
        return FALSED;
    }
    
    NSMutableData *data = [NSMutableData dataWithBytes:dataSend length:len];
    NSLog(@"TURN ON USB: data: %@", data);
    
    printf("TURN ON USB: SEND: ");
    
    for(int i=0; i< len; i++)
    {
        unsigned char* fileBytes = (unsigned char*)data.bytes;
        printf(" %02X", fileBytes[i]);
    }
    printf("\n");

    int sizeRead = 0;
    NSMutableData *result = sendData(fileDescriptor,data);
    
    NSLog(@"TURN ON USB: result: %@", result);

    if(result == nil)
        return FALSED;
    sizeRead = (int)result.length;

    Byte *arr = (Byte *)result.bytes;
    
    printf("TURN ON USB: RESULT: ");
    
    for(int i=0; i< sizeRead; i++)
    {
        unsigned char* fileBytes = (unsigned char*)result.bytes;
        printf(" %02X", fileBytes[i]);
    }
    printf("\n");

    
    //check signature
    if(arr[0]!=0xFF && arr[1]!=0x55)
    {
        NSLog(@"%s TURN ON USB : check signature FAILED \n",__func__);
        //error_msg += "ledControl: check sig err\n";
        return FALSED;
    }

    //check code , status, module
    if(dataRec[CODE_OFF] != CM_SWITCH_USB ||
            dataRec[MODULE_OFF] != moduleId ||
            dataRec[STATUS_OFF] != 0x01)
    {
        if(dataRec[STATUS_OFF] == 0x00)
        {
            NSLog(@"TURN ON USB: FW check sum FAILED \n");
            return FALSED;
        }
        NSLog(@"TURN ON USB: check code/ module Id/ status FAILED \n");
        return FALSED;
    }

    return SUCCESS;
}

unsigned short swichUsbOFF(unsigned char USB_mode[8], int fileDescriptor)
{
    unsigned short i = 0;
   // unsigned short res = 0;  //result
   // unsigned short timeOut = 3000;
    unsigned short len = 0;
    unsigned char sum = 0;
    unsigned char moduleId = 0;

    char dataSend[17] = {
         0xFF, 0x55,
         0x00, 0x0E,  // side
         0x00,        // command code
         0x00, 0x01,  // Dir, protocol version
         0x00,        // moduleId
         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // USB mode
         0x00
     };

    unsigned char dataRec[10]= {0};

    //send command
    len = sizeof(dataSend);
    //set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_FAST_CHARGE_OLD_FW;
    dataSend[MODULE_OFF]= moduleId;
    
    

    for(i = 0; i < 8; i++)
    {
        dataSend[8 + i] = USB_mode[i];
    }
    

    sum = calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;

    if(fileDescriptor==-1)
    {
        NSLog(@"not open port");
        return FALSED;
    }
    
    NSMutableData *data = [NSMutableData dataWithBytes:dataSend length:len];
    NSLog(@"TURN OFF USB: data: %@", data);
    
    printf("TURN OFF USB: SEND: ");
    
    for(int i=0; i< len; i++)
    {
        unsigned char* fileBytes = (unsigned char*)data.bytes;
        printf(" %02X", fileBytes[i]);
    }
    printf("\n");

    int sizeRead = 0;
    NSMutableData *result = sendData(fileDescriptor,data);
    
    NSLog(@"TURN OFF USB: result: %@", result);

    if(result == nil)
        return FALSED;
    sizeRead = (int)result.length;

    Byte *arr = (Byte *)result.bytes;
    
    printf("TURN OFF USB: RESULT: ");
    
    for(int i=0; i< sizeRead; i++)
    {
        unsigned char* fileBytes = (unsigned char*)result.bytes;
        printf(" %02X", fileBytes[i]);
    }
    printf("\n");

    
    //check signature
    if(arr[0]!=0xFF && arr[1]!=0x55)
    {
        NSLog(@"%s TURN OFF USB : check signature FAILED \n",__func__);
        //error_msg += "ledControl: check sig err\n";
        return FALSED;
    }

    //check code , status, module
    if(dataRec[CODE_OFF] != CM_SWITCH_USB ||
            dataRec[MODULE_OFF] != moduleId ||
            dataRec[STATUS_OFF] != 0x01)
    {
        if(dataRec[STATUS_OFF] == 0x00)
        {
            NSLog(@"TURN OFF USB: FW check sum FAILED \n");
            return FALSED;
        }
        NSLog(@"TURN OFF USB: check code/ module Id/ status FAILED \n");
        return FALSED;
    }

    return SUCCESS;
}

char* showDebugPackage(void* unk_buf, unsigned long byte_cnt)
{
    unsigned char* buf = (unsigned char*) unk_buf;

    fprintf(stderr, "\n--------------------------------------------------------------\n");
    fprintf(stderr, " Offset |");
    for (unsigned long i = 0x00000000; i <= 0x0000000F; i++)
    {
        if ((i % 8 == 0) && (i != 0))
        {
            fprintf(stderr, " ");
        }
        fprintf(stderr, "%2lX ", i);
    }
    fprintf(stderr, "\n--------------------------------------------------------------");
    unsigned long off = 0x00000000;
    fprintf(stderr, "\n%08lX |", off++);
    unsigned long i = 0;
    unsigned long sec_cnt = 0;
    for (; i < byte_cnt; i++)
    {
        if (i % 8 == 0)
        {
            if (i != 0)
            {
                fprintf(stderr, " ");
            }
        }
        if (i % 16 == 0)
        {
            if (i != 0)
            {
                fprintf(stderr, "| ");
                unsigned long idx = 16;
                for (unsigned long j = 1; j <= 16; j++)
                {
                    unsigned char c = buf[i - idx--];
                    if (c >= 33 && c <= 126)
                    {
                        fprintf(stderr, "%c", c);
                    }
                    else
                    {
                        fprintf(stderr, ".");
                    }
                }
                if (i % 512 == 0)
                {
                    fprintf(stderr, "\nSector %ld\n", ++sec_cnt);
                }
                fprintf(stderr, "\n%08lX |", off++);
            }
        }
        fprintf(stderr, "%02X ", buf[i]);
    }
    fprintf(stderr, " | ");
    unsigned long idx = 16;
    for (unsigned long j = 1; j <= 16; j++)
    {
        unsigned char c = buf[i - idx--];
        if (c >= 33 && c <= 126)
        {
            fprintf(stderr, "%c", c);
        }
        else
        {
            fprintf(stderr, ".");
        }
    }

    fprintf(stderr, "\n\n");
    return (char*)"";
}

@end
