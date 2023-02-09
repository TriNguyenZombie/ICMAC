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
#include <stdio.h>
#include <string.h>
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
static bool isOpenPort;
int fileDescriptor = -1;

@implementation ProtocolHW
@synthesize boardnum; // chua dung den
@synthesize infoHW;
- (id)init
{
    self = [super init];
    isOpenPort = NO;
    fileDescriptor = -1;
    boardnum = -1;// chua set
    appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
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
    
    // Success
    isOpenPort = YES;
    return fileDescriptor;
    
    // Failure path
error:
    if (fileDescriptor != -1) {
        close(fileDescriptor);
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
    
    // Traditionally it is good practice to reset a serial port back to
    // the state in which you found it. This is why the original termios struct
    // was saved.
    if (tcsetattr(fileDescriptor, TCSANOW, &gOriginalTTYAttrs) == -1) {
        printf("Error resetting tty attributes - %s(%d).\n",
               strerror(errno), errno);
    }
    isOpenPort = NO;
    close(fileDescriptor);
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
    int            tries;            // Number of tries so far
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
    printf("\n");
    numBytes = 0;
    NSMutableData *firstdata = [[NSMutableData alloc] init];
    for (tries = 1; tries <= kNumRetries; tries++)
    {
        for(int i=0;i< numbyte;i++)
            printf(" %02X",arr[i]);
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
            numBytes = read(fileDescriptor, bufPtr, &buffer[sizeof(buffer)] - bufPtr - 1);
            printf("read numBytes:%d\n",(int)numBytes);
            if (numBytes == -1) {
                printf("Error reading from modem - %s(%d).\n", strerror(errno), errno);
            }
            else if (numBytes > 0)
            {
               // bufPtr += numBytes;
                sizeRead+= numBytes;
                [firstdata appendBytes:bufPtr length:numBytes];
            }
            else
            {
                printf("end read Nothing read.\n");
            }
        } while (numBytes > 0);
        
        // NULL terminate the string and see if we got an OK response
        *bufPtr = '\0';
           
       // printf("Read \"%s\"\n", logString(buffer));
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
static NSMutableData *sendbyte(int fileDescriptor,NSMutableData *arrdata)
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
    closeSerialPort(fileDescriptor);
    isOpenPort = NO;
    fileDescriptor = -1;
}
- (NSDictionary *) checkVersion:(NSString *)serial
{
    //char *second = "/dev/cu.usbserial-A601V5L5";
    if(isOpenPort==NO)
    {
        if([self openport:serial]==FALSED)
        {
            return nil;
        }
    }
    if ( fileDescriptor == -1) {
        printf("Open COM error .\n");
       // return EX_IOERR;
        return nil;
    }
    else
    {
        printf("Open COM successfully.\n");
    }
    Byte arr[9]= {0xFF, 0x55, 0x00, 0x06, 0x01,0x00,0x01,0x00,0xF8};
    NSMutableData *data = [NSMutableData dataWithBytes:arr length:9];
    int sizeRead = 0;
    //NSMutableData *result = senddata(fileDescriptor,arr,9,&sizeRead);
    NSMutableData *result = sendData(fileDescriptor,data);
    sizeRead = (int)result.length;
    printf("sizeRead = %d\n",sizeRead);
    for(int i=0;i< result.length;i++)
    {
        unsigned char* fileBytes = (unsigned char*)result.bytes;
        printf(" %02X", fileBytes[i]);
    }
    printf("\n");
    closeSerialPort(fileDescriptor);
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
    if(isOpenPort==NO)
    {
        NSString *path = [NSString stringWithFormat:@"/dev/cu.usbserial-%@",serial];
        char *second = (char *)[path UTF8String];
        memcpy(bsdPath, second, strlen(second)+1);
        fileDescriptor = openSerialPort(bsdPath);
        if ( fileDescriptor == -1) {
            printf("Open COM error .\n");
            return FALSED;
        }
        else
        {
            printf("Open COM successfully.\n");
        }
    }
    return SUCCESS;
}

- (unsigned short) ledControl:(NSString *)serial ledArr:(Byte*)arr
{
    unsigned char *LEDMode = arr;
    if([self openport:serial]==FALSED)
    {
        NSLog(@"openport failed");
        return FALSED;
    }
   
    if(ledControl(LEDMode)==FALSED)
    {
        NSLog(@"ledControl failed");
        return FALSED;
    }
    return SUCCESS;
}

unsigned short ledControl(unsigned char LEDMode[8])
{
    unsigned short i = 0;
   // unsigned short res = 0;  //result
   // unsigned short timeOut = 3000;
    unsigned short len = 0;
    unsigned char sum = 0;
    unsigned char moduleId = 0;

    unsigned char dataSend[17] = {
        0xFF, 0x55,
        0x00, 0x00,  // side
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

    if(fileDescriptor==-1 || isOpenPort==NO)
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

            //error_msg += "ledControl T: FW check sum err\n";
            return FALSED;
        }
        NSLog(@"ledControl: check code/ module Id/ status FAILED \n");

       // error_msg += "ledControl T: check code/status err\n";
        return FALSED;
    }

    return SUCCESS;
}
- (void) startCheckButton:(NSString *)serial
{
    if([self openport:serial]==FALSED)
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
    
    BOOL senddata;
    BOOL isLogout = NO;
    while (isLogout == NO)
    {
        AppDelegate *delegate = (AppDelegate *)appDelegate;
        isLogout = delegate.isLogout;
        senddata = NO;
        if(readKeyEvent(0, buttonInfo, deviceInfo)!= SUCCESS)
        {
            for(int i=0;i<8;i++)
                NSLog(@"%d button:%d-dev:%d",i,buttonInfo[i],deviceInfo[i]);
            NSLog(@"");
        }
        // printf("\ndeviceInfo: %s \n",deviceInfo);
        printf("\n");
        NSMutableArray* mutableArray = [NSMutableArray array];
        for (int i=0; i<8; i++)
        {
           // printf(" bt[%d]=%2X   %2X",i,buttonInfo[i],buttonBK[i]);
            [mutableArray addObject:[NSNumber numberWithChar:buttonBK[i]]];
            if(buttonInfo[i]==1)
            {
                buttonBK[i] = 1;
            }
            else if(buttonBK[i]==1)
            {
                buttonBK[i] = 0;
                senddata = YES;
            }
        }
        //sleep(1);
        //usleep(6000);
        if(senddata)
        {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:boardnum],@"boardnum",
                                        serial,@"serial",
                                        mutableArray,@"buttonsState",
                                        nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BoardButtonsClick" object:dic];
            sleep(1);
        }
       
    }
}

unsigned short readKeyEvent(unsigned char moduleId, unsigned char *buttonInfo, unsigned char *deviceInfo)
{
    printf("\nreadKeyEvent\n");
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
    
    if(fileDescriptor==-1 || isOpenPort==NO)
    {
        NSLog(@"not open port");
        return FALSED;
    }
    
    NSMutableData *data = [NSMutableData dataWithBytes:dataSend length:len];
    int sizeRead = 0;
    NSMutableData *result = sendbyte(fileDescriptor,data);
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


@end
