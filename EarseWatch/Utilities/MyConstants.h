//
//  MyConstants.h
//  iTest
//
//  Created by TriNguyen on 8/5/22.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

#define SW_VERSION_CURRENT                 @"1.05"
#define DEBUG_MODE 0


#define FONT_SIZE_TITLE                 35
#define FONT_SIZE_CONNECTION_STATUS     20
#define FONT_SIZE_INFO                  20

#define TAG_CHECK_BOX_ALL_LEFT                1000
#define TAG_CHECK_BOX_ALL_RIGHT               1001


//Information
#define BATCH_NUMBER @"Batch #"
#define WORK_AREA @"Work Area"
#define LINE_NUMBER @"Line #"
#define USER_NAME @"Username"
#define LOCATION @"Location"

//Hardware Diagnostics
#define HEADER_NO @"No"
#define HEADER_ITEM @"Item"
#define HEADER_TEST @"Test"
#define HEADER_RESULT @"Result"

#define RESULT_PASSED               0
#define RESULT_FAILED               1
#define RESULT_NA                   2
#define RESULT_NOT_IMPLEMENTED      -1
#define RESULT_NOT_SUPPORT          2


#define SEND_UNSUCCESSFULLY             1
#define SEND_SUCCESSFULLY               0
#define SEND_UNKNOWN                    2

#define ERASURE_RESULT_FAILED               0
#define ERASURE_RESULT_PASSED               1
#define ERASURE_RESULT_NA                   2

#define ERASURE_PASSED_TEXT @"Passed"
#define ERASURE_FAILED_TEXT @"Failed"
#define ERASURE_NA_TEXT @"N/A"

#define FUNCTION_PASSED @"Passed"
#define FUNCTION_FAILED @"Failed"
#define FUNCTION_NA @"N/A"
#define FUNCTION_NOT_IMPLEMENTED @"Not Implemented"

#define FUNCTION_CPU_TEXT @"CPU"
#define FUNCTION_CPU_KEY @"F1_CPU"

#define FUNCTION_DISPLAY_TEXT @"Display"
#define FUNCTION_DISPLAY_KEY @"F2_DISPLAY"

#define FUNCTION_KEYBOARD_TEXT @"Keyboard"
#define FUNCTION_KEYBOARD_KEY @"F3_KEYBOARD"


#define FUNCTION_POINTER_DEVICE_TEXT @"Pointer device"
#define FUNCTION_POINTER_DEVICE_KEY @"F4_POINTER_DEVICE"

#define FUNCTION_WIFI_TEXT @"Wi-Fi"
#define FUNCTION_WIFI_KEY @"F5_WIFI"

#define FUNCTION_LEFT_SPEAKER_TEXT @"Left speaker"
#define FUNCTION_LEFT_SPEAKER_KEY @"F6_LEFT_SPEAKER"

#define FUNCTION_RIGHT_SPEAKER_TEXT @"Right speaker"
#define FUNCTION_RIGHT_SPEAKER_KEY @"F7_RIGHT_SPEAKER"

#define FUNCTION_CAMERA_TEXT @"Camera"
#define FUNCTION_CAMERA_KEY @"F10_CAMERA"

#define FUNCTION_MICROPHONE_TEXT @"Microphone"
#define FUNCTION_MICROPHONE_KEY @"F9_MICROPHONE"

#define FUNCTION_CHARGE_TEXT @"Charge"
#define FUNCTION_CHARGE_KEY @"F8_CHARGE"

#define FUNCTION_BLUETOOTH_TEXT @"Bluetooth"
#define FUNCTION_BLUETOOTH_KEY @"F11_BLUETOOTH"

#define FUNCTION_ETHERNET_PORT_TEXT @"Ethernet port"
#define FUNCTION_ETHERNET_PORT_KEY @"F12_ETHERNET_PORT"

#define FUNCTION_OVERHEATING_TEXT @"Overheating"
#define FUNCTION_OVERHEATING_KEY @"F13_OVERHEATING"

#define FUNCTION_USB_PORT_TEXT @"USB port"
#define FUNCTION_USB_PORT_KEY @"F14_USB_PORT"

#define FUNCTION_HARD_DRIVE_TEST_TEXT @"Hard Drive Test"
#define FUNCTION_HARD_DRIVE_TEST_KEY @"F15_HARD_DRIVE_TEST"

#define FUNCTION_HDMI_PORT_TEXT @"HDMI port"
#define FUNCTION_HDMI_PORT_KEY @"F16_HDMI_PORT_TEST"

//Message
#define MAC_HARDWARE_DIAGNOSTICS @"Mac Hardware Diagnostics"
#define MESSAGE_DISCONNECTED @"The connection to the GCS server is disconnected."
#define MESSAGE_ESTABLISHED @"The connection to the GCS server is established."
#define TEXT_PRESS_ESC_OR_COMMAND_X_TO_EXIT @"PRESS \"ESC\" OR \"COMMAND + X\" TO EXIT"
#define TEXT_PRESS_ESC_TWICE_OR_COMMAND_X_TO_EXIT @"PRESS \"ESC\" TWICE OR \"COMMAND + X\" TO EXIT"


#define DID_THE_FUNCTION_WORK_CORRECTLY @"Did the %@ work correctly?"
#define MESSAGE_TESTING_FUNCTION @"Testing %@"
#define MESSAGE_PLEASE_FORCE_CLICK_TO_THE_TOUCH_PAD_WITH_ONE_FINGER_TWO_FINGERS @"Please force click to the touch pad with one finger, with two fingers, with three\n fingers in turn and force click with one finger to the two circles on the top."
#define TEXT_HDMI_NORMAL @"Please plug an HDMI device to the HDMI port this device for testing."
#define MESSAGE_PLEASE_PRESS_ALL_KEYS_ON_THE_KEYBOARD @"Please press all keys on the keyboard. Use Fn for the function key."
#define MESSAGE_PROCESS_NOT_FINISHED @"Process not finished. Click OK to turn off the software and remove the live USB from machine."
#define MESSAGE_PROCESS_FINISHED @"Process finished. Click OK to turn off the software and remove the live USB from machine."


typedef enum {
    UNKNOWN  = 0,
    SDD  = 1,
    HDD  = 2,
    NVME = 3
} DISK_TYPE;

typedef enum {
    STATE_IDLE    = 0,
    STATE_CHECK_INFORMATION  = 1,
    STATE_CHECK_INFORMATION_SUCCESS  = 2
} GUI_STATE;

@interface MyConstants : NSObject {
    
}

+ (NSColor*)getColorBottomView;
+ (NSColor*)getColorInforView;
+ (NSColor*)getColorDiagnosticsView;
+ (NSColor*)getColorHeaderTableView;
+ (NSColor*)getColorTableView;
+ (NSColor*)getColorTextNotImplemented;
+ (NSColor*)getColorTextPassed;
+ (NSColor*)getColorTextFailed;
+ (NSColor*)getColorHeaderConfirmationDialog;
+ (NSColor*)getColorFooterFunctionTest;
+ (NSColor*)getColorYellowTouchPad;
+ (NSColor*)getColorGreenTouchPad;
+ (NSColor*)getColorYellowKeyboard;
+ (NSColor*)getColorGreenKeyboard;

@end


NS_ASSUME_NONNULL_END
