/******************************************************************************
 * Copyright (c) 2009-2010 Greystone Data Technologies, Inc. All Rights Reserved.
 *
 * THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF GDT.
 * The copyright notice above does not evidence any actual or intended
 * publication of such source code.
 *
 * File Name: define_gds.h.
 *
 * Description: Define all values.
 ******************************************************************************/

#ifndef DEFINE_GDS_H
#define DEFINE_GDS_H


#define qbug     qDebug()
#define  MAX_HALONG_IN_STATION 48
///////////////////////////////////////////////////////////////////////////////
//  Dinh nghia lai mot so kieu data
typedef unsigned long long uLLong;
typedef unsigned long  uLong;
typedef unsigned char  uChar;
typedef unsigned short  uShort;
typedef unsigned int  uInt;

///////////////////////////////////////////////////////////////////////////////
//  Dinh nghia thoi gian time out (s)
#define TIME_OUT        3
#define TIME_STATUS     5
#define TIME_RECOG      20

///////////////////////////////////////////////////////////////////////////////
//  Dinh nghia signal tu client
#define DR_SIGNAL       1
#define DC_SIGNAL       2

///////////////////////////////////////////////////////////////////////////////
//  Dinh nghia thong tin cua server
#define MAX_CONNECT				32      //ps:8
#define PORT_NUMBER				1800
#define PACKE_MAX				10240
#define APPS_NAME				"Battery_Tester_D2"
#define RE_DUP_PRO_APPS_NAME    "removeDuplicateProcess"
#define SERVER_LOG_FILE_NAME_1	APPS_NAME "_1.txt"
#define SERVER_LOG_FILE_NAME_2	APPS_NAME "_2.txt"
#define ENTER_LINE				"\n"
#define MAX_PACKING_LIST_SIZE            2000

#define IMAGE_DIR "/home/greystone/ZeroIT/Image/"
#define IMAGE_LOGO_LOGIN "login.png"
#define IMAGE_LOGO_MAIN  "main.png"
#define IMAGE_LOGO_ABOUT "about.png"
#define IMAGE_LOGO_ALL   "generallogo.png"
#define IMAGE_RUNNING1   "running1.png"
#define IMAGE_RUNNING2   "running2.png"
#define IMAGE_RUNNING3   "running3.png"
#define IMAGE_RUNNING4   "running4.png"
#define IMAGE_PASSED     "passed.png"

#define MAX_MODULE      5
#define MAX_CELL        8
#define MAX_SOUND_CARD  4

//Test function result
#define TEST_FUNCTION_FAILED 0
#define TEST_FUNCTION_PASSED 1
#define TEST_FUNCTION_NOTEST 2
#define TEST_FUNCTION_WAITING_APP_OPEN       3
#define TEST_FUNCTION_WAITING_APP_RUNNING    4
#define TEST_FUNCTION_FINISHED               5

//Max listr app iOS
#define MAX_LIST_APP_IOS    20

#define DOWNLOAD_SW_DIR             "/home/greystone/new_sw_download"
#define RECORDBACK_DIR              "/home/greystone/ZeroIT/recordBackFile/"
#define DOWNLOAD_iOS_DIR            "/home/greystone/FW_STORE/new"
#define RECORDBACK_FILE             "speak.wav"
#define RECORDBACK_BB_FILE           "recording.wav"
#define BG_MULTI_FAIL_FULL           ":/new/prefix1/erase-fail-full.png"
#define BG_MULTI_FAIL_SMALL          ":/new/prefix1/erase-fail-small.png"


//Define link path9tog
#define PATH_ROOT                           "/home/greystone/ZeroIT/"
#define PATH_DEVICE_LIST_NOT_SUPPORT_SDCARD PATH_ROOT"smart_server/listDeviceNotSDCard.txt"
#define PATH_ITEST_APP_VERSION              PATH_ROOT"smart_server/appItest_version.txt"
#define PATH_QR_CODE_IMAGE_FILE             PATH_ROOT"Image/QRcodeUI_main.png"
#define PATH_CHECK_HDD_MEMORY_FILE          PATH_ROOT"checkHDD.txt"
#define PATH_SYTEM_OPTION_FILE              PATH_ROOT"system_options.xml"
#define PATH_SYSTEM_NUMBER_FILE             PATH_ROOT"number.txt"
#define PATH_SYSTEM_NUMVERSAVE_FILE         PATH_ROOT"numbersave.txt"
#define PATH_GDS_SERVER_LIST_DEFAULT        PATH_ROOT"GCS_servers.config"
#define PATH_APPLE_SERVER_LIST_DEFAULT      PATH_ROOT"smart_server/GCS_servers_apple.config"
#define PATH_IOS_SUPPORT_CONFIG_FILE        PATH_ROOT"idevice_support.config"
#define PATH_FILE_CHECKSUM_NEW_SOFTWARE_CDN PATH_ROOT"checksum_new_sw_updated.txt"
#define PATH_CUSTOMER_INFO                  PATH_ROOT"customerinfo.txt"
#define PATH_LIST_IOS_DOWNLOAD              PATH_ROOT"List_iOS_Download.xml"
#define PATH_LIST_CHECKSUM_IOS_FW           "/home/greystone/FW_STORE/new/Release_Checksum.xml"
#define PATH_LIST_IOS_FW_DOWNLOADED_FAILED  PATH_ROOT"List_iOS_Fail.txt"
#define PATH_LIST_USBHUB_DETECT             PATH_ROOT"smart_server/detect_usb_hub.txt"
#define PATH_MODEL_WITH_COLOR_CODE          PATH_ROOT"Models_with_Colour_Code.xls"
#define PATH_FW_FILE                        "/home/greystone/FW_VERSION/battery.bin"
#define PATH_FW_FOLDER                      "/home/greystone/FW_VERSION"
#define PATH_SMART_SERVER_FOLDER            PATH_ROOT"smart_server"
#define PATH_DEBUG_MODE_CONFIG              PATH_ROOT"debugMode.ini"
#define PATH_SYSTEM_NUMBER_CYCLE_COUNT_BATTERY_FILE PATH_ROOT"number_cycle_count_battery.txt"
#define PATH_CONFIG_REPORT_CERTIFICATE      PATH_ROOT"cogfig_certificate.txt"
#define PATH_ACTIVE_CONFIG                  PATH_ROOT"smart_server/active.config"
#define PATH_USB_XML_CONFIG                 PATH_ROOT"usb_xml_config.txt"
#define PATH_HOST_FILE_REMOTE_DEFAULT       PATH_ROOT"remote_machines.config"
#define PATH_MODULE_USB_CONFIG              PATH_ROOT"module_usb_config.config"
#define PATH_LOCATION_SERVER_SETTING        PATH_ROOT"location_server.config"
#define PATH_FMI_IMIE_FILE                  PATH_ROOT"imei_fmi.txt"

#define HOST_ROUTING ""; ////"pushing.greystonedatatech.com"
#define PORT_ROUTING 80
#define URI_ROUTING  "/"

#define ITEM_ID_DEFAULT     ""
#define TRACKING_ID_DEFAULT ""
#define ITEM_ID_NOREQUEST "NO_ITEMID"
#define TRACKING_ID_NOREQUEST "NO_TRACKINGID"

#define EARPHONE_FILE_TMP             "earPhoneRecord.wav"
#define EARPHONE_FILE                 "earPhone.wav"
#define HEADPHONE_FILE_TMP            "headPhoneTmp.wav"
#define HEADPHONE_FILE                "headPhone.wav"

#define RECORDBACK_ANDROID_FILE             "speak.3gp"
#define RECORDBACK_ANDROID_FILE_CONVERT     "speak.wav"
#define RECORDBACK_CHANGED_VOLUMN           "volume.wav"
#define RECORDBACK_ANDROID_FILE_CONVERT_HP  "speak_hp.wav"
#define RECORDBACK_CHANGED_VOLUMN_HP        "volume_hp.wav"
enum STATUS
{
    STATUS_READY                = 0x00,       // Client connected and Phone is on ready
    STATUS_RUNNING              = 0x01,
    STATUS_ERASE_PASS           = 0x02,
    STATUS_ERASE_ERROR          = 0x03,
    STATUS_IDLE                 = 0x04,
    STATUS_NOT_SUPPORT          = 0x05,
    STATUS_EXPIRE               = 0x06,

    STATUS_NO_DETECT            = 0x07,       // Client is disconnected
    STATUS_REQUEST              = 0x08,       // New connect
    STATUS_READING_INFO         = 0x09,
    STATUS_READ_INFO_FAIL       = 0x0A,//10

    STATUS_WAITING_FOR_VERIFY   = 0x0B,//11
    STATUS_VERIFY_OK            = 0x0C,//12
    STATUS_VERIFY_FAIL          = 0x0D,//13
    STATUS_RECOG_PHONE_FAIL     = 0x0E,//14
    STATUS_CANCEL_ERASING       = 0x0F,//15
    STATUS_UPDATE_INFO          = 0x10,

    // define tu app doc lap
    // them moi + sua tu day

    STATUS_USB_PC               = 0x11,   // SW switch usb to PC
    STATUS_USB_FW               = 0x12,   // FAST charge
    STATUS_UPGRADE_FW           = 0x13,
    STATUS_READING_INFO_PASS    = 0x1A,

    STATUS_SHORT                = 0x1B,
    STATUS_DONGLE_DISABLE       = 0x1C,
    STATUS_FAST_CHARGE_SCAN     = 0x1D,

    STATUS_INSTALL_APP          = 0x20,
    STATUS_UNINSTALL_APP        = 0x21,
    STATUS_SET_REQUEST          = 0x22,
    STATUS_GET_RESULT           = 0x23,
    STATUS_COPY_FILE            = 0x24,
    STATUS_FUNCTION_TEST        = 0x25,
    STATUS_FUNCTION_TEST_CHECKING = 0x26, // check USB PLUG
    //STATUS_FUNCTION_TEST_NONE = 0x27, // NO PO
    STATUS_FUNCTION_TEST_READING     = 0x27,
    STATUS_FUNCTION_TEST_READ_PASS   = 0x28,
    STATUS_FUNCTION_TEST_READ_FAIL   = 0x29,
   // STATUS_POWER_OFF                 = 0x2A,
    STATUS_FUNCTION_TEST_READY       = 0x30,
    STATUS_FUNCTION_TEST_FAST_CHARGE = 0x31,

    STATUS_REFESH_PREP_STATUS        = 0x32,

    STATUS_DEBRANDING_PHONE          = 0x33,
    STATUS_UNLOCK_PHONE              = 0x34,
    STATUS_FASTCHARGE_TIME_OUT       = 0x35,
    STATUS_ERASE                     = 0x36,
    STATUS_DELETE_PHONE_SPRINT       = 0x37,
    STATUS_DETECT_AUDIO_LOOPBACK     = 0x38,
    STATUS_ERASE_WITHOUT_VERIFY      = 0x39,
    STATUS_DETECT_APP_EXIST          = 0x40,
    STATUS_NONE                      = 0xFF,
    STATUS_ENCRYPT                   = 0x41,    //Status Encrypt
    STATUS_ENCRYPT_ERASE             = 0x42 ,    //Status Erase after Encrypt
    STATUS_CHECKROUTING_ERROR        = 0x43,
    STATUS_DEBRANDING_PHONE_LOADROM  = 0x44,
    STATUS_SHORT_USB                 = 0x45,
    STATUS_FAILED_SIGNAL_USB         = 0x46,
};


///////////////////////////////////////////////////////////////////////////////
//  Dinh nghia trang thai tren giao dien
enum COLOR_CODE
{
    GREEN               = 0x01,
    YELLOW              = 0x02,
    RED                 = 0x03,
    WHITE               = 0x04,
    BLUE                = 0x05,
    INVAI               = 0x06,
    DEFAULT             = 0x07,
    FOUNDHL             = 0x08,
    NOPHONE             = 0x09,
    EXPIRE              = 0x0A,
    NO_SUPP             = 0x0B,
    READ_INFO           = 0x0C
};

///////////////////////////////////////////////////////////////////////////////
//  Dinh nghia cong viec cho client
enum JOB_CODE
{
    //  Dinh nghia cong viec cho cell
    ERASE_JOB                   = 0x07,
    CANCEL_ERASE_JOB            ,
    CANCEL_FAST_CHARGE_JOB      ,
    FAST_CHARGE_JOB             ,
    RESET_ZEROIT                ,
    REFRESH_ZEROIT              ,
    SYNC_MEDIA                  ,
    APPLE_CONFIG_JOB            ,
    FUNCTION_TEST_JOB

};

enum ERROR_CODE
{
    // SUCCESS             = 0x00,
    NO_CELL_CHECK       = 0x01

};

///////////////////////////////////////////////////////////////////////////////
//  Define langage
//Tri add language 23/11/2016
enum LANGUAGE
{
    ENGLISH                   = 0X00,
    CHINESE                   = 0x01
};

#define STEP_LED                         1
#define STEP_BACK_BUTTON_KEY_LIGHT       2
#define STEP_HOVERING                    3
#define STEP_SPEN                        4
#define STEP_ROTATION                    5
#define ACTION_START                     0
#define ACTION_FINISHED                  1

#define VERSION_SOFTWARE    "STR.U19.54"
#define COPYRIGHT           "Greystone"
#define WEBSITE             "www.greystonedatatech.com"
#define DESC                "Description a bout software"

#define USER_DEFAULT        "userdefault"

#define UBUNTU_VERSION13_10 "Ubuntu 13.10"
#define UBUNTU_VERSION16_04 "Ubuntu 16.04"

#define PROCESS_TYPE_RECEIVING      "Receiving"
#define PROCESS_TYPE_PREP           "Check Carrier"

#define PROCESS_TYPE_TRIAGE         "Function Test"
#define PROCESS_TYPE_GSIGCE      "GSI"
#define PROCESS_TYPE_GSIGCE_RECEIVING      "GSI_RECEIVING"
#define PROCESS_TYPE_GSIGCE_REPAIR      "GSI_REPAIR"
#define PROCESS_TYPE_GSIGCE_QC      "GSI_QC"
#define PROCESS_TYPE_GSIGCE_SCAP      "GSI_SCAP"
#define PROCESS_TYPE_GSIGCE_FGI      "GSI_FGI"
#define PROCESS_STATUS_RECEIVING_PASSED "RECPASSED"
#define PROCESS_STATUS_RECEIVING_RUNNING "RECRUNNING"
#define PROCESS_STATUS_RECEIVING_FAILED "RECFAILED"
#define PROCESS_STATUS_PREP_PASSED "PREPPASSED"
#define PROCESS_STATUS_PREP_RUNNING "PREPRUNNING"
#define PROCESS_STATUS_PREP_FAILED "PREPFAILED"
#define PROCESS_STATUS_CEW_PASSED "CEWPASSED"
#define PROCESS_STATUS_CEW_RUNNING "CEWPRUNNING"
#define PROCESS_STATUS_CEW_FAILED "CEWFAILED"
#define PROCESS_STATUS_INSP_PASSED "INSPPASSED"
#define PROCESS_STATUS_INSP_RUNNING "INSPRUNNING"
#define PROCESS_STATUS_INSP_FAILED "INSPFAILED"
#define PROCESS_STATUS_ERASE_PASSED "ERASEPASSED"
#define PROCESS_STATUS_ERASE_RUNNING "ERASERUNNING"
#define PROCESS_STATUS_ERASE_FAILED "ERASEFAILED"

#define ERASE_LOG_BACKUP_PATH  "home/greystone/ZeroIT/erase_log_backup"
#define ERASE_LOG_BACKUP_PATH_ZIP  "home/greystone/ZeroIT/erase_log_backup.tar.gz"
#define FILE_LOG_BACKUP  "/home/greystone/ZeroIT/erase_log_backup/restore_log_"
#define FILE_LOG_DIR "home/greystone/ZeroIT/Logfile"

#define PROCESS_TYPE_CHECK_FMIP     "Check FMIP"
#define PROCESS_TYPE_ERASE          "Erase"
#define PROCESS_TYPE_APPLE_CONFIG   "Apple Config"
#define PROCESS_TYPE_VERIFY_DATA    "verify data"

//Define ERROR code send to server
#define ERROR_CANNOT_READ_PHONE_INFO "#Could not read device information."
#define ERROR_CANNOT_INSTALL_APP "#Could not install iTest app."
#define ERROR_CANNOT_UPDATE_LOCAL_DATABASE "#Database error. Could not update the test result"
#define ERROR_FIRMWARE_NOT_EXIST "#The firmware does not exist."
#define ERROR_CANNOT_ACTIVE_DEVICE "#Could not activate the device."
#define ERROR_CANCEL_BY_USER "#The process was canceled by operator."
#define ERROR_CANNOT_GET_ERASE_METHOD "#Could not get erasure method."
#define ERROR_DEVICE_AT_HOME_SCREEN_AFTER_ERASING "#Erasure failed (Device was at home screen after erasing)."
#define ERROR_CANNOT_IDENTIFY_INFORMATION_AFTER_ERASING "#Erasure failed (Could not identify the device after erasing)."
#define ERROR_ERASE_TIMEOUT "#Erasure failed (Timeout)."
#define ERROR_SUB_APP_WAS_CRASHED "#The sub app was crashed while processing."
#define ERROR_DEVICE_DISCONNECT_WHILE_ERASING "#Erasure failed (The device was disconnected while erasing)."
#define ERROR_IDEVICE_ON_RECOVERY_AFTER_ERASING "#Erasure failed (The device was in recovery mode after erasing)."
#define ERROR_CANNOT_DEBRANDING_PHONE "#Erasure failed (Could not debranding the device)."
#define ERROR_CANNOT_ERASE_SPRINT_PHONE "Erasure failed (Could not erase the Sprint phone)."
#define ERROR_CANNOT_ERASE_PASSCODE_OF_DEVICE "#Erasure failed (Could not erase passcode on the device)."
#define ERROR_CANNOT_EXECUTE_ERASE_QUERY "#Erasure failed (Could not execute query to erase)."
#define ERROR_USB_PORT_SHORT "#USB port was short circuited."
#define ERROR_DEVICE_LOST_CONNECTION_WHILE_RECEIVING "#The device was disconnected while receiving."
#define ERROR_CANNOT_REFLASH_THE_DEVICE_BEFORE_RECEIVING "#Could not reflash the device before receiving."
#define ERROR_DEVICE_LOST_CONNECTION_WHILE_ACTIVATING "#The device was disconnected while activating."
#define ERROR_CANNOT_INSERT_DATA_TO_LOCAL_DATABASE "#Could not insert data to the local database."
#define ERROR_CANNOT_SEND_REQUEST_TO_DEVICE "#Could not send request to the device. Please retest."
#define ERROR_CANNOT_GET_RESULT "#Could not get result from iTest app. Please retest."
#define ERROR_SKIP_ERASURE "#Erasure was skipped (the device is at welcome screen)."
#define ERROR_DEVICE_LOST_CONNECTION_BEFORE_STARTING_ITEST_APP "#The device was disconnected before starting iTest app."
#define ERROR_DEVICE_LOST_CONNECTION_WHILE_PROCESS "#The device was disconnected while processing."
#define ERROR_IOS_NOT_SUPPORT "#Activation failed due to the iOS was not latest."
#define ERROR_PHONE_NUMBER_EXIST "#Phone number existed."
#define ERROR_DEVICE_HAS_PASSCODE "#Device has passcode. Cannot test."
#define ERROR_DEVICE_IN_RECOVERY_MODE "#Device is in recovery mode. Cannot test."
#define ERROR_DEVICE_HAS_FMI "#FMI/RAL/FRP is on. Cannot test."
#define ERROR_DEVICE_ROOTED "#Device is rooted or custom ROM. Cannot test."
#define ERROR_DEVICE_GOOLE_ACCOUNT "#Google account exists"
#define ERROR_DEVICE_FRP "#FMI/RAL/FRP is on. Cannot test."
#define ERROR_DEVICE_KNOX "#Knox device."
#define ERROR_DEVICE_MDM "#MDM device. Cannot test."
#define ERROR_CANNOT_DETECT_MDM "#Could not detect MDM device."
#define ERROR_BATTERY_LOW "#Battery was low to do erasure with encryption."
#define ERROR_DISABLE_FUNCTION_TEST "#All functional tests were disabled."
#define ERROR_CANNOT_ERASE_THE_PHONE "#Could not erase the device."
#define ERROR_CANNOT_CEW_RECEIPT "#Could not get list function from CEW."
#define ERROR_CANNOT_MIDAS_SERVER "#The process fail with Midas server."
#define ERROR_MIDAS_NO_RMA "#No RMA."
#define ERROR_MIDAS_PASSCODE "PIN locked."
#define ERROR_MIDAS_NO_POWER "Device was not powered on."
#define ERROR_MIDAS_CANNOT_TOUCH "Failed touch screen or home button or USB port"
#define ERROR_MIDAS_DEMO_PHONE "Demo device."
#define ERROR_BATTERY_FAILED "#Battery was failed."
#define ERROR_CHECK_COLOR_FAILED "#Failed to check color of this device."
#define ERROR_CHECK_SIM_FAILED "#No SIM card inserted."
#define ERROR_CHECK_IOS_FAILED "#Please install the latest official version of iOS."
#define CHECKING_NEW_VERSION "Checking new version"
#define UPDATE_TO_NEW_VERSION "Station is updating Software"
//#define UPDATE_SOFTWARE_IS_LATEST_VERSION "Software is latest version"
#define UPDATE_SOFTWARE_IS_LATEST_VERSION "    "
#define UPDATE_FINISHED "Update finished"
// UPDATE STATE
#define UPDATE_STATE_NONE 0
#define UPDATE_STATE_START 1
#define UPDATE_STATE_FINISHED 2
//end

#define PREP_RESULT_DEFAULT         0
#define PREP_RESULT_PASSED          1
#define PREP_RESULT_NO_SIM          2
#define PREP_RESULT_INVALID_SIM     3
#define PREP_RESULT_FMI_ON          4
#define PREP_RESULT_PASSCODE_ON     5
#define PREP_RESULT_RECOVERY_MODE   6
#define PREP_RESULT_NOT_ACTIVE      7
#define PREP_RESULT_NOT_SUPPORT_IOS 8
#define PREP_RESULT_PHONENUMBER_YES 9

#define KNRM  "\x1B[0m"
#define KRED  "\x1B[31m"
#define KGRN  "\x1B[32m"
#define KYEL  "\x1B[33m"
#define KBLU  "\x1B[34m"
#define KMAG  "\x1B[35m"
#define KCYN  "\x1B[36m"
#define KWHT  "\x1B[37m"
#define RESET "\033[0m"

#define LOG_MAIN_MODULE_NAME            "Main"
#define LOG_CELL_OBJ_NAME               "CellOb"

#define MSS_DB_NOT_CORRECT      "Database is not correct. Please contact GCS Technical Support for assistance."
#define MSS_DB_ERROR            "Database fatal error. Contact GCS Technical Support for assistance."
#define MSS_NO_BOXES_SELECT     "No box selected."
#define MSS_RENEWAL_OK          "Your renewal is complete."
#define MSS_SYSTEM_DISABLED     "The All In One system has been disabled. Please contact Technical Support for assistance."
#define CANNOT_CONNECT_NET      "Can not connect to GCS Server..."
#define CONNECTED_NET           "The connection to GCS Server is established..."
#define BOARD_SN_INVALID        "Module not verified. ICombine will shutdown in 24 hours. Contact GCS Technical Support"
#define OVER_24H_VALID          "Over 24 hours. Contact GCS Technical Support"


#define USER_DEFAULT        "userdefault"

#define PROCESS_TYPE_RECEIVING      "Receiving"
#define PROCESS_TYPE_PREP           "Check Carrier"
#define PROCESS_TYPE_TRIAGE         "Function Test"
#define PROCESS_TYPE_GSIGCE      "GSI"
#define PROCESS_TYPE_GSIGCE_RECEIVING      "GSI_RECEIVING"
#define PROCESS_TYPE_GSIGCE_REPAIR      "GSI_REPAIR"
#define PROCESS_TYPE_GSIGCE_QC      "GSI_QC"
#define PROCESS_TYPE_GSIGCE_SCAP      "GSI_SCAP"
#define PROCESS_TYPE_GSIGCE_FGI      "GSI_FGI"
#define PROCESS_STATUS_RECEIVING_PASSED "RECPASSED"
#define PROCESS_STATUS_RECEIVING_RUNNING "RECRUNNING"
#define PROCESS_STATUS_RECEIVING_FAILED "RECFAILED"
#define PROCESS_STATUS_PREP_PASSED "PREPPASSED"
#define PROCESS_STATUS_PREP_RUNNING "PREPRUNNING"
#define PROCESS_STATUS_PREP_FAILED "PREPFAILED"
#define PROCESS_STATUS_CEW_PASSED "CEWPASSED"
#define PROCESS_STATUS_CEW_RUNNING "CEWPRUNNING"
#define PROCESS_STATUS_CEW_FAILED "CEWFAILED"
#define PROCESS_STATUS_INSP_PASSED "INSPPASSED"
#define PROCESS_STATUS_INSP_RUNNING "INSPRUNNING"
#define PROCESS_STATUS_INSP_FAILED "INSPFAILED"
#define PROCESS_STATUS_ERASE_PASSED "ERASEPASSED"
#define PROCESS_STATUS_ERASE_RUNNING "ERASERUNNING"
#define PROCESS_STATUS_ERASE_FAILED "ERASEFAILED"


#define PROCESS_TYPE_CHECK_FMIP     "Check FMIP"
#define PROCESS_TYPE_ERASE          "Erase"
#define PROCESS_TYPE_APPLE_CONFIG   "Apple Config"
#define PROCESS_TYPE_VERIFY_DATA    "verify data"

#define PREP_RESULT_DEFAULT         0
#define PREP_RESULT_PASSED          1
#define PREP_RESULT_NO_SIM          2
#define PREP_RESULT_INVALID_SIM     3
#define PREP_RESULT_FMI_ON          4
#define PREP_RESULT_PASSCODE_ON     5
#define PREP_RESULT_RECOVERY_MODE   6
#define PREP_RESULT_NOT_ACTIVE      7
#define PREP_RESULT_NOT_SUPPORT_IOS 8
#define PREP_RESULT_PHONENUMBER_YES 9
#define PREP_RESULT_BATTERY_FAILED  10


#define MESSAGE_TITLE       "Message"
#define ZEROIT_TITLE        "All In One"
#define GDT_TITLE           ""

#define CANCEL_ERASING     "Factory reset!!! Cancel WILL KILL the phone!!!. You want to CANCEL now?"

#define CANNOT_CONNECT_NET  "Can not connect to GCS Server..."
#define CONNECTED_NET       "The connection to GCS Server is established..."
#define CHECKING_NET        "Checking the internet connection..."
#define BOARD_SN_INVALID    "Module not verified. ICombine will shutdown in 24 hours. Contact GCS Technical Support"
#define OVER_24H_VALID      "Over 24 hours. Contact GCS Technical Support"

#define PROCESS_TYPE_ERASE          "Erase"
#define PROCESS_TYPE_VERIFY_DATA    "verify data"

#define LOGOUT_DIALOG_TEXT                      "Logout"
#define LOGOUT_MESSAGE_TEXT                     "Are you sure you want to logout?"
#define YES_BUTTON_TEXT                         "Yes"
#define NO_BUTTON_TEXT                          "No"
#define AIO_LABEL_TEXT                          "All In One Station"
#define VERSION_LABEL_TEXT                      "Version"
#define USERINFORMATION_GROUPBOX_TEXT           "User information"
#define USERNAME_LABEL_TEXT                     "Username"
#define PASSWORD_LABEL_TEXT                     "Password"
#define LOGIN_BUTTON_TEXT                       "Login"

//#define "asset id"
#define GLASS_CRACKED_CB_TEXT           "Glass Cracked"
#define RECEIVING_DATE_CB_TEXT          "Receiving Date"
#define RESULT_CB_TEXT                  "Result"
#define DEVICE_GRADE_CB_TEXT            "Device's Grade"
#define DEVICE_FINAL_PRICE_CB_TEXT      "Device's Final Price"
#define SPRINT_STATUS_CB_TEXT           "Sprint Status"
#define FUNCTION_FIRST_FAIL_CB_TEXT     "Function First Failed"
#define ROOTED_STATUS_CB_TEXT           "Rooted Status"
#define LCD_STATUS_CB_TEXT              "LCD status"
#define DEVICE_DAMAGE_CB_TEXT           "Device Damage"
#define COSMETIC_GRADE_CB_TEXT          "Cosmetic grade"
#define CARRIER_LOCK_CB_TEXT            "Carrier Lock"
#define PO_NUMBER_CB_TEXT               "PO number"
#define BLACK_LIST_CB_TEXT              "Black List"
#define CLASSIFY_CB_TEXT                "Classify"
#define DAMAGE_HOUSING_CB_TEXT          "Damage Housing"
#define ORIGINAL_CARRIER_CB_TEXT        "Original Carrier"
#define LOCKED_UNLOCKED_CB_TEXT         "Locked/Unlocked"
#define COUNTRY_CB_TEXT                 "Country"
#define LOCKED_CB_TEXT                  "Locked"
#define POSITION_CB_TEXT                "Position"
#define ENABLE_PRINT_LABEL_AUTOMATICALLY_GB_TEXT    "Enable print label automatically"
#define SHOW_PRINTER_DIALOG_CB_TEXT                 "Show Printer dialog"
#define ENABLE_AUTO_PRINT_LABEL_AFTER_THE_ERASURE_HAS_COMPLETED_CB_TEXT "Enable auto print label after\nthe erasure has completed"
#define ENABLE_AUTO_PRINT_LABEL_AFTER_THE_INDENTIFIED_HAS_COMPLETED     "Enable auto print label after\nthe identified has completed"
#define PRINT_PREVIEW_CB_TEXT           "Print Preview"
#define BARCODE_CB_TEXT                 "Barcode"
#define TEXT_SIZE_LB_TEXT               "Text size"
#define ENABLE_PRINT_FUNCTION_TEST_RESULT_IN_DETAIL_CB_TEXT "Enable print function \ntest result in detail"
#define PRINT_LABEL_TABWIGET_TEXT       "Print Label"
#define ADD_USER_DATA_FIELDS_TABWIGET_TEXT    "Add User Data Fields"
#define CREATE_LABEL_TABWIGET_TEXT            "Create Label"
#define EXCEPTION_LABEL_TABWIGET_TEXT                       "Exception Label"
#define PRINT_BT_TEXT                         "Print"
#define RESCAN_DEVICES_BT_TEXT                "Rescan devices"
#define CLOSE_BT_TEXT                         "Close"
#define RESULT_TEXT                           "Result"
#define DETAIL_TEXT                           "Detail"
#define CAMERA_COMBOX_TEXT                    "Camera"
#define CRACKED_HOUSING_TEXT                  "Cracked Housing"
#define ASSET_CB_TEXT                         "Asset" //===
#define POWER_BUTTON_COMBOX_TEXT              "Power button"
#define SCREEN_COMBOX_TEXT                    "Screen"
#define SOFTWARE_COMBOX_TEXT                    "Software"
#define SPEAKER_PHONE_COMBOX_TEXT           "Speaker phone"
#define TOUCH_PAD_COMBOX_TEXT                   "Touch Pad"
#define VIDEO_COMBOX_TEXT                   "Video"
#define VOLUME_BUTTON_COMBOX_TEXT           "Volume button"
#define STOCK_TEXT                          "Stock"
#define ONLY_INPUT_NUMBER_FOR_CB_TEXT       "Only input NUMBER for"
#define ON_PORT_TEXT                        "on Port"
#define CANCEL_BT_TEXT                      "Cancel"
#define OK_BT_TEXT                          "OK"

//===============new[8-12-2016]===========================================
#define UP_BT_TB_TEXTPRODUCT_NAME_CB_TEXT                                       "Up Button"
#define PLAY_BUTTON_TEXT                                                        "Play Button"
#define ENTIRE_COSFACE_TEXT                                                     "Entire Cosface"
#define COSFACE_TEXT                                                            "Cosface"
#define REAR_CAMERA_TEXT                                                        "Rear Camera"
#define LITMUS_PAPER_LINE_EDIT_TEXT                                             "Litmus Paper"
///////////////////////////////////////////////////////////////////////////////
//  Dinh nghia chi dinh file anh
#define RUNNING_A_PNG     ":/new/prefix2/icon/running_a.png"
#define RUNNING_B_PNG     ":/new/prefix2/icon/running_b.png"
#define RUNNING_C_PNG     ":/new/prefix2/icon/running_c.png"
#define RUNNING_D_PNG     ":/new/prefix2/icon/running_d.png"

#define RUNNING_PNG             ":/new/prefix1/icon/running.png"
#define PASS_PNG                ":/new/prefix1/icon/pass.png"
#define ERROR_PNG               ":/new/prefix1/icon/error.png"
#define ERROR_FUNCTION_PNG      ":/new/prefix1/icon/error_func.png"
#define READY_PNG               ":/new/prefix1/icon/ready.png"
#define DISABLE_PNG             ":/new/prefix1/icon/disable.png"
#define NOPHONE_PNG             ":/new/prefix1/icon/nophone.png"
#define EXPIRE_PNG              ":/new/prefix1/icon/expire.png"
#define NOT_SUPP_PNG            ":/new/prefix1/icon/notsupport.png"
#define ICON_MAIN               ":/new/prefix1/icon/icon.png"
#define LOGO_GDT                ":/new/prefix1/icon/logo_MPDE.png"
#define ZEROIT_IMAGE            ":/new/prefix1/icon/SWM.png"
#define CHECKING_PNG            ":/new/prefix1/icon/scan_status.png"
#define FAILED_PNG              ":/new/prefix1/icon/error1.png"

#define ERA_PNG                 ":/new/prefix1/icon/Erase_icon.png"
#define UPG_PNG                 ":/new/prefix1/icon/Upgrade_icon.png"
#define RES_PNG                 ":/new/prefix1/icon/Restart_icon.png"
#define INF_PNG                 ":/new/prefix1/icon/ViewInfo.png"
#define REP_PNG                 ":/new/prefix1/icon/ViewLogfile_icon.png"
#define HIS_PNG                 ":/new/prefix1/icon/History_icon.png"
#define PRT_PNG                 ":/new/prefix2/icon/printer_1.png"
#define PRT_PNG_NEW             ":/new/prefix1/icon/icon_print.png"
#define CANCEL_ERA_PNG          ":/new/prefix1/icon/cancel.png"
//#define RESET_PNG               ":/new/prefix1/icon/RetureDefault.png"
#define BATTERY_CHARGE_PNG      ":/new/prefix1/icon/battery_charging.png"
#define BATTERY_DISCHARGE_PNG   ":/new/prefix1/icon/battery_discharge.png"
#define BATTERY_CHARGING_PNG    ":/new/prefix1/icon/Status-battery-charging.png"
#define BATTERY_CHARGING1_PNG    ":/new/prefix1/icon/Status-battery-charging1.png"
#define BATTERY_CHARGING2_PNG    ":/new/prefix1/icon/Status-battery-charging2.png"
#define BATTERY_CHARGING3_PNG    ":/new/prefix1/icon/Status-battery-charging3.png"
#define REFRESH_ZEROIT_PNG      ":/new/prefix1/icon/refresh_box.png"
#define GCE_SETTING_PNG      ":/new/prefix1/icon/gce_setting.png"
#define FAILED_STATUS            ":/new/prefix2/icon/error_status_small.png"
#define WARNING_STATUS           ":/new/prefix2/icon/warning_status_small.png"


#define ACTIVE_DEVICE_PNG       ":/new/prefix1/icon/active_iphone.png"
#define UBUR_PNG                ":/new/prefix1/icon/registration.png"

#define OK_DOWNLOAD             ":/new/prefix1/icon/ok.png"
#define CANCEL_DOWNLOAD         ":/new/prefix1/icon/cancel.png"
#define FUNCTION_TEST_PNG       ":/new/prefix1/icon/qc_test.png"
#define REFRESH_COUNTPLUGGED    ":/new/prefix1/icon/refresh.png"
#define BRICKED_PHONE           ":/new/prefix1/icon/mobile.png"
#define RECEIVE_PHONE           ":/new/prefix1/icon/Receive_icon.png"
#define OK_ICON_NEW             ":/new/prefix1/icon/OK_icon.png"
//Result Triage icon
#define PTC_PNG                     ":/new/prefix1/icon/PTC_min.png"
#define PTG_PNG                     ":/new/prefix1/icon/PTG_min.png"
#define OTHER_PNG                     ":/new/prefix1/icon/Other_min.png"
#define OTHER1_PNG                     ":/new/prefix1/icon/Other1_min.png"
#define OTHER2_PNG                     ":/new/prefix1/icon/Other2_min.png"
#define OTHER3_PNG                     ":/new/prefix1/icon/Other3_min.png"
#define OTHER4_PNG                     ":/new/prefix1/icon/Other4_min.png"
#define OTHER5_PNG                     ":/new/prefix1/icon/Other5_min.png"

//Define icon function fail
#define AUDIO_FAILED_FULL_PNG                   ":/new/prefix1/icon/32/function/audio-fail-full.png"
#define AUDIO_FAILED_SMALL_PNG                  ":/new/prefix1/icon/32/function/audio-fail-small.png"
#define POWER_CHECK_FAILED_FULL_PNG             ":/new/prefix1/icon/32/function/pcheck-fail-full.png"
#define POWER_CHECK_FAILED_SMALL_PNG            ":/new/prefix1/icon/32/function/pcheck-fail-small.png"
#define WIFI_FAILED_FULL_PNG                    ":/new/prefix1/icon/32/function/wifi-fail-full.png"
#define WIFI_FAILED_SMALL_PNG                   ":/new/prefix1/icon/32/function/wifi-fail-small.png"
#define BUTTON_BACK_LIGHT_FAILED_FULL_PNG       ":/new/prefix1/icon/32/function/bkl-fail-full.png"
#define BUTTON_BACK_LIGHT_FAILED_SMALL_PNG      ":/new/prefix1/icon/32/function/bkl-fail-small.png"
#define LIGHT_FAILED_FULL_PNG                   ":/new/prefix1/icon/32/function/light-fail-full.png"
#define LIGHT_FAILED_SMALL_PNG                  ":/new/prefix1/icon/32/function/light-fail-small.png"
#define TOUCH_ID_FAILED_FULL_PNG                ":/new/prefix1/icon/32/function/tid-fail-full.png"
#define TOUCH_ID_FAILED_SMALL_PNG               ":/new/prefix1/icon/32/function/tid-fail-small.png"
#define NFC_FAILED_FULL_PNG                     ":/new/prefix1/icon/32/function/nfc-fail-full.png"
#define NFC_FAILED_SMALL_PNG                    ":/new/prefix1/icon/32/function/nfc-fail-small.png"
#define IMEI_FAILED_FULL_PNG                    ":/new/prefix1/icon/32/function/imei-fail-full.png"
#define IMEI_FAILED_SMALL_PNG                   ":/new/prefix1/icon/32/function/imei-fail-small.png"
#define SUBKEY_BACKLIGHT_FAILED_FULL_PNG        ":/new/prefix1/icon/32/function/sbl-fail-full.png"
#define SUBKEY_BACKLIGHT_FAILED_SMALL_PNG       ":/new/prefix1/icon/32/function/sbl-fail-small.png"
#define POWERDOWN_FAILED_FULL_PNG               ":/new/prefix1/icon/32/function/power-fail-full.png"
#define POWERDOWN_FAILED_SMALL_PNG              ":/new/prefix1/icon/32/function/power-fail-small.png"
#define CAMERA_FAILED_FULL_PNG                  ":/new/prefix1/icon/32/function/cam-fail-full.png"
#define CAMERA_FAILED_SMALL_PNG                 ":/new/prefix1/icon/32/function/cam-fail-small.png"
#define CALL_FAILED_FULL_PNG                    ":/new/prefix1/icon/32/function/call-fail-full.png"
#define CALL_FAILED_SMALL_PNG                   ":/new/prefix1/icon/32/function/call-fail-small.png"
#define BUTTON_FAILED_FULL_PNG                  ":/new/prefix1/icon/32/function/button-fail-full.png"
#define BUTTON_FAILED_SMALL_PNG                 ":/new/prefix1/icon/32/function/button-fail-small.png"
#define MOTION_FAILED_FULL_PNG                  ":/new/prefix1/icon/32/function/motion-fail-full.png"
#define MOTION_FAILED_SMALL_PNG                 ":/new/prefix1/icon/32/function/motion-fail-small.png"
#define PEN_FAILED_FULL_PNG                     ":/new/prefix1/icon/32/function/pen-fail-full.png"
#define PEN_FAILED_SMALL_PNG                    ":/new/prefix1/icon/32/function/pen-fail-small.png"
#define GPS_FAILED_FULL_PNG                     ":/new/prefix1/icon/32/function/gps-fail-full.png"
#define GPS_FAILED_SMALL_PNG                    ":/new/prefix1/icon/32/function/gps-fail-small.png"
#define LCD_FAILED_FULL_PNG                     ":/new/prefix1/icon/32/function/lcd-fail-full.png"
#define LCD_FAILED_SMALL_PNG                    ":/new/prefix1/icon/32/function/lcd-fail-small.png"
#define BLUETOOTH_FAILED_FULL_PNG               ":/new/prefix1/icon/32/function/bt-fail-full.png"
#define BLUETOOTH_FAILED_SMALL_PNG              ":/new/prefix1/icon/32/function/bt-fail-small.png"
#define CHARGE_FAILED_FULL_PNG                  ":/new/prefix1/icon/32/function/charge-fail-full.png"
#define CHARGE_FAILED_SMALL_PNG                 ":/new/prefix1/icon/32/function/charge-fail-small.png"
#define DIGITIZER_FAILED_FULL_PNG               ":/new/prefix1/icon/32/function/digi-fail-full.png"
#define DIGITIZER_FAILED_SMALL_PNG              ":/new/prefix1/icon/32/function/digi-fail-small.png"
#define TOUCHSCREEN_FAILED_FULL_PNG             ":/new/prefix1/icon/32/function/ts-fail-full.png"
#define TOUCHSCREEN_FAILED_SMALL_PNG            ":/new/prefix1/icon/32/function/ts-fail-small.png"
#define VIDEO_BACK_FAILED_FULL_PNG              ":/new/prefix1/icon/32/function/vback-fail-full.png"
#define VIDEO_BACK_FAILED_SMALL_PNG             ":/new/prefix1/icon/32/function/vback-fail-small.png"
#define VIDEO_FRONT_FAILED_FULL_PNG             ":/new/prefix1/icon/32/function/vfront-fail-full.png"
#define VIDEO_FRONT_FAILED_SMALL_PNG            ":/new/prefix1/icon/32/function/vfront-fail-small.png"
#define HEADPHONE_FAILED_FULL_PNG               ":/new/prefix1/icon/32/function/hp-fail-full.png"
#define HEADPHONE_FAILED_SMALL_PNG              ":/new/prefix1/icon/32/function/hp-fail-small.png"
#define HEADSET_JACK_FAILED_FULL_PNG            ":/new/prefix1/icon/32/function/hjack-fail-full.png"
#define HEADSET_JACK_FAILED_SMALL_PNG           ":/new/prefix1/icon/32/function/hjack-fail-small.png"
#define COSMETIC_FAILED_FULL_PNG                ":/new/prefix1/icon/32/function/cos-fail-full.png"
#define COSMETIC_FAILED_SMALL_PNG               ":/new/prefix1/icon/32/function/cos-fail-small.png"
#define COSFACE_FAILED_FULL_PNG                 ":/new/prefix1/icon/32/function/csg-fail-full.png"
#define COSFACE_FAILED_SMALL_PNG                ":/new/prefix1/icon/32/function/csg-fail-small.png"
#define INTERNAL_SPEAKER_FAILED_FULL_PNG        ":/new/prefix1/icon/32/function/is-fail-full.png"
#define INTERNAL_SPEAKER_FAILED_SMALL_PNG       ":/new/prefix1/icon/32/function/is-fail-small.png"
#define PROXIMITY_FAILED_FULL_PNG               ":/new/prefix1/icon/32/function/proxi-fail-full.png"
#define PROXIMITY_FAILED_SMALL_PNG              ":/new/prefix1/icon/32/function/proxi-fail-small.png"
#define VIBRATION_FAILED_FULL_PNG               ":/new/prefix1/icon/32/function/vib-fail-full.png"
#define VIBRATION_FAILED_SMALL_PNG              ":/new/prefix1/icon/32/function/vib-fail-small.png"
#define FLASH_FAILED_FULL_PNG                   ":/new/prefix1/icon/32/function/flash-fail-full.png"
#define FLASH_FAILED_SMALL_PNG                  ":/new/prefix1/icon/32/function/flash-fail-small.png"
#define DIMMING_FAILED_FULL_PNG                 ":/new/prefix1/icon/32/function/dim-fail-full.png"
#define DIMMING_FAILED_SMALL_PNG                ":/new/prefix1/icon/32/function/dim-fail-small.png"
#define COMPASS_FAILED_FULL_PNG                 ":/new/prefix1/icon/32/function/com-fail-full.png"
#define COMPASS_FAILED_SMALL_PNG                ":/new/prefix1/icon/32/function/com-fail-small.png"
#define ROOTED_FAILED_FULL_PNG                  ":/new/prefix1/icon/32/function/rooted-fail-full.png"
#define ROOTED_FAILED_SMALL_PNG                 ":/new/prefix1/icon/32/function/rooted-fail-small.png"
#define SD_CARD_FAILED_FULL_PNG                 ":/new/prefix1/icon/32/function/sd-fail-full.png"
#define SD_CARD_FAILED_SMALL_PNG                ":/new/prefix1/icon/32/function/sd-fail-small.png"
#define SIM_FAILED_FULL_PNG                     ":/new/prefix1/icon/32/function/sim-fail-full.png"
#define SIM_FAILED_SMALL_PNG                    ":/new/prefix1/icon/32/function/sim-fail-small.png"
#define SMS_FAILED_FULL_PNG                     ":/new/prefix1/icon/32/function/sms-fail-full.png"
#define SMS_FAILED_SMALL_PNG                    ":/new/prefix1/icon/32/function/sms-fail-small.png"
#define MULTI_FAILED_FULL_PNG                   ":/new/prefix1/icon/32/function/multi-fail-full.png"
#define MULTI_FAILED_SMALL_PNG                  ":/new/prefix1/icon/32/function/multi-fail-small.png"
#define HOVERING_FAILED_FULL_PNG                ":/new/prefix1/icon/32/function/hover-fail-full.png"
#define HOVERING_FAILED_SMALL_PNG               ":/new/prefix1/icon/32/function/hover-fail-small.png"

#define LONG_ERASE_METHOD         0
#define QUICK_ERASE_METHOD         1
#define SMART_ERASE_METHOD         2
#define FACTORY_RESET              3
//////////////////////////////Define location server//////////////////
#define DALLAS_LOCATION     "DALLAS"
#define CHICAGO_LOCATION    "CHICAGO"
#define OTHER_LOCATION      "MANUAL"
#define USER_NAME_CDN           "greycdn.user"
#define API_KEY_CDN             "608720ab85c3498c82f5fda650f9a079"
#define HOST_NAME_CDN_DALLAS    "https://storage101.dfw1.clouddrive.com/v1/MossoCloudFS_6d2201cb-63f4-47a5-97f4-08c7ff9621ba/"
#define HOST_NAME_CDN_CHICAGO   "https://storage101.ord1.clouddrive.com/v1/MossoCloudFS_6d2201cb-63f4-47a5-97f4-08c7ff9621ba/"
/////////////////////////////////////////////////////////////////////
#define REFLASH         "Reflash"
#define RESTORE         "Restore"
#define ERASE_DATA      "Reset"

///////////////////////////////////////////////////////////////////////////////
//  Dinh nghia ket qua tra ve
#define FUN_SUCCESS                     0
#define FUN_UN_SUCCESS                  1

///////////////////////////////////////////////////////////////////////////////
//  Dinh nghia setting cho datatabase
#ifndef MYSQL_DATABASE_NAME
#define		MYSQL_DATABASE_NAME		"gds_mobile32"
#endif
#ifndef MYSQL_DATABASE_ZEROIT_ENCORE
#define		MYSQL_DATABASE_ZEROIT_ENCORE		"zeroit_additems"
#endif
#ifndef MYSQL_DATABASE_CUSTOMER_VIEW
#define		MYSQL_DATABASE_CUSTOMER_VIEW		"customer_database"
#endif
#ifndef MYSQL_DRIVER
#define		MYSQL_DRIVER			"QMYSQL"
#endif
#ifndef MYSQL_HOST_NAME
#define		MYSQL_HOST_NAME			"localhost"
#endif
#ifndef MYSQL_USER
#define		MYSQL_USER				"greystone"
#endif
#ifndef MYSQL_PASS
#define		MYSQL_PASS				"ZITNGDTY09D31M12"
#endif
#ifndef MYSQL_ROOT
#define		MYSQL_ROOT				"root"
#endif
#ifndef MYSQL_PASS_ROOT
#define		MYSQL_PASS_ROOT				"ZIT8SPGDT101008"
#endif

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
//  Dinh nghia cau truc cua cac ban trong customer database

//
#define FAILED_TIME_FILE "/home/greystone/faile_time.txt"
//
//typedef struct machine_info {
//    QString station_serial;
//    QString station_name;
//    QString software_version;
//    QString firmware_version;
//    machine_info()
//    {
//        station_name = "ZeroIT";
//    }
//}machine_info;
//
//typedef struct gds_mobile_firmware {
//    QString firmware_version;
//    QString firmware_notes;
//    QString admin_create;
//    QString admin_update;
//    QDateTime date_create;
//    QDateTime date_update;
//    int del_if;
//    gds_mobile_firmware()
//    {
//        firmware_version = "1.0.0";
//        del_if = 0;
//    }
//}gds_mobile_firmware;
///////////////////////////////////////////////////////////////////////////////
//  Dinh nghia cau truc cua cac ban trong database
//typedef struct gds_mobile_erasedetail {
//    unsigned long long  erase_id;
//    QString halong_serial;
//    unsigned long long model_id;
//    QString  erase_userid;
//    QString erase_datetime;
//    QString erase_logfile;
//    QString erase_imei;
//    QString erase_sn;
//    int erase_status;
//    int erase_verify;
//    QString erase_hash;
//    int erase_credits;
//    QString erase_duration;
//    QString erase_customername;
//    QString erase_manufacturer;
//    QString erase_position;
//    QString erase_method;
//    QString erase_carrier;
//    QString erase_device_os_type;
//    QString erase_baseband;
//    QString erase_phone_firmware;
//    QString erase_phone_capacity;
//    QString erase_wifi_address;
//    QString erase_bluetooth;
//    QString device_model_number;
//    QDateTime local_eraseTime;
//    QString erase_elapsetime;
//    QString errorlog;
//
//    QString device_meid;
//    QString device_imei;
//
//    QString label_uid;
//    QString customer_device_info;
//    QString model_name;
//    QString erase_device_color;
//
//    QString fmip_status;
//    QString passcode;
//    QString process_action;
//    QString function_test;
//    QString erase_result_detail;
//    QString ASN_PO;
//    QString Fault_device; //I had inserted a new column whose name is Faul_device!!!
////    QString erase_result_detail;
//    QString destination;
//    QString classify;
//
//    gds_mobile_erasedetail()   // Example of a constructor used in a structure.
//    {
//        erase_id=0;
//        model_id =0;
//        erase_status = 1;
//        erase_verify = 1;
//        erase_credits = -1;
//    }
//
//}gds_mobile_erasedetail;
//
//
//typedef struct gds_mobile_halong {
//    QString halong_serial;
//    QString firmware_version;
//    QString hardware_version;
//    int halong_status;
//    QString halong_notes;
//    QString admin_create;
//    QString admin_update;
//    QDateTime date_create;
//    QDateTime date_update;
//    int del_if;
//    gds_mobile_halong()
//    {
//        halong_status = 2;
//        del_if = 0;
//    }
//}gds_mobile_halong;
//
//typedef struct gds_mobile_model{
//    unsigned long long model_id ;
//    QString product_id;
//    QString vendor_id;
//    QString product_name;
//    QString vendor_name;
//    QString model_name;
//    QString model_description;
//    QString admin_create;
//    QString admin_update;
//    QString date_create;
//    QString date_update;
//    int del_if;
//    gds_mobile_model()
//    {
//        model_id = 0;
//        del_if = 1;
//    }
//}gds_mobile_model;
//
//typedef struct gds_mobile_erasemanager{
//
//    QString halong_serial;
//    unsigned long long model_id;
//    unsigned long registered_unit;
//    unsigned long erasable_unit;
//    unsigned long erased_unit;
//
//    int erase_free;
//    int model_status;
//    QString admin_create;
//    QString date_create;
//    QString admin_update;
//    QString date_update;
//    int del_if;
//    gds_mobile_erasemanager()
//    {
//        model_status	= 1;
//        erase_free		= 1;
//        model_id		= 0;
//        registered_unit = 0;
//        erasable_unit	= 0;
//        erased_unit		= 0;
//        del_if			= 1;
//    }
//}gds_mobile_erasemanager;
//
//typedef struct gds_mobile_license{
//    uLLong license_id;
//    QString station_serial;
//    QString input_path;
//    QString output_path;
//    int request;
//    int result;
//    QString admin_create;
//    QString date_create;
//    int del_if;
//    gds_mobile_license()
//    {
//        del_if = 1;
//        request = 1;
//        result = 2;
//    }
//}gds_mobile_license;
//
//typedef struct gds_mobile_station{
//
//    QString station_serial;
//    QString station_name;
//    QString station_notes;
//    QString software_version;
//    QString firmware_version;
//    QString hardware_version;
//    QString admin_create;
//    QString date_create;
//    QString machine_type;
//    QString customerID_location;
//    QString machine_uid;
//    QString machine_routing;
//    int register_unit;
//    int erasable_unit;
//    int erased_unit;
//    int erase_free;
//    int station_visible;
//    int sid;
//    int del_if;
//    int location_key;
//    QString location_text;
//    QString machine_location;
//    int machine_local_update_status;
//    QString machine_local_update_message;
//    gds_mobile_station()
//    {
//        station_serial      = "";
//        station_name        = "";
//        station_notes       = "";
//        software_version    = "";
//        firmware_version    = "";
//        hardware_version    = "";
//        admin_create        = "";
//        date_create         = "";
//        machine_routing     = "";
//        register_unit       = 0;
//        erasable_unit       = 0;
//        erased_unit         = 0;
//        erase_free          = 1;
//        sid                 = 0;
//        del_if              = 1;
//        location_key        = 2;
//        location_text       = "";
//        machine_location    = "";
//        machine_local_update_status = 0;
//        machine_local_update_message = "";
//    }
//
//}gds_mobile_station;
//
//struct item_gds_mobile
//{
//    QString halong_serial;
//    QString firmware_version;
//    QString software_version;
//    QString hard_version;
//    QString model_name;
//    QString erase_date;
//    QString erase_imei;
//    QString erase_sn;
//    QString erase_status;
//    QString erase_verify;
//    QString erase_logfile;
//    QString erase_duration;
//    QString erase_customername;
//
//    QString phone_fw_version;
//    QString start_time;
//    QString end_time;
//    QString min_mdn;
//    QString device_model_number;
//    QString erase_phone_capacity;
//    QString erase_phone_firmware;
//    QString erase_carrier;
//    QString customer_device_info;
//    QString label_uid;
//    QString device_color;
//    QString device_imei;
//    QString device_meid;
//    QString erase_device_os_type;
//    QString fmip_status;
//    QString passcode;
//    QString process_action;
//    QString erase_username;
//    unsigned long count;
//
//    QString errorlog;
//    QString erase_result_detail;
//    QString ASN_PO;
////    QString destination;
//
//    //Battery define
//    QString battery_percent;
////    QString battery_soh;
////    QString battery_cycle_count;
//    QString battery_capacity;
//    QString battery_category;
//    QString battery_result;
//    //int model_id;
//
//    //Function test define
//    QString function_test_audio;
//    QString function_test_bluetooth;
//    QString function_test_battery;
//    QString function_test_powerbutton;
//    QString function_test_homebutton;
//    QString function_test_upbutton;
//    QString function_test_downbutton;
//    QString function_test_mutebutton;
//    QString function_test_playbutton;
//    QString function_test_camerabutton;
//    QString function_test_keypad;
//    QString function_test_call;
//    QString function_test_call_call;
//    QString function_test_camera;
//    QString function_test_camerafront;
//    QString function_test_camerarear;
//    QString function_test_charge;
//    QString function_test_LCD;
//    QString function_test_jailbreak;
//    QString function_test_compass;
//    QString function_test_cosmetic;
//    QString function_test_cosmeticfront;
//    QString function_test_cosmeticrear;
//    QString function_test_cosmeticup;
//    QString function_test_cosmeticdown;
//    QString function_test_cosmeticleft;
//    QString function_test_cosmeticright;
//    QString function_test_cosface;
//    QString function_test_cosfaceAA;
//    QString function_test_cosfaceA;
//    QString function_test_cosfaceB;
//    QString function_test_cosfaceC;
//    QString function_test_cosfaceD;
//    QString function_test_digitizer;
//    QString function_test_dimming;
//    QString function_test_flash;
//    QString function_test_gps;
//    QString function_test_headphone;
//    QString function_test_internalspeaker;
//    QString function_test_motionsensor;
//    QString function_test_proximitysensor;
//    QString function_test_touchscreen;
//    QString function_test_video;
//    QString function_test_video_front;
//    QString function_test_vibration;
//    QString function_test_wifi;
//
//    QString function_test_result;
//    QString function_test_po;
//    QString function_test_crackedLCD;
//    QString function_test_activeunit;
//    QString function_test_warrantyeligible; //TamHo added demo HYLA 17-03-2017
//    QString function_test_liquidDamage;
//    QString function_test_SimTray;
//    QString function_test_SDcardTray;
//    QString function_test_brickedphone;
//    QString function_test_chargeport;
//    QString function_test_dataport;
//    QString function_test_sdcarddetection;
//    QString function_test_checkphonenumber;
//    QString function_test_checkengraving;
//
//    QString function_test_hovering;
//    QString function_test_pen;    //Timestamp
//    QString function_test_cosmeticgrade;//Cosmetic Grade
//    QString function_test_erasestatus;
//    //Timestamp
//    QString dtime_timestart;
//    QString dtime_installapp;
//    QString dtime_startapp;
//    QString dtime_finishapp;
//    QString dtime_starterase;
//    QString dtime_finisherase;
//    QString dtime_timeend;
//    QString dtime_senddataGCS;
//
//    unsigned int dtime_durationaudio;
//    unsigned int dtime_durationbattery;
//    unsigned int dtime_durationbluetooth;
//    unsigned int dtime_durationbutton;
//    unsigned int dtime_durationcall;
//    unsigned int dtime_durationcalltest;
//    unsigned int dtime_durationcamera;
//    unsigned int dtime_durationcharge;
//    unsigned int dtime_durationcompass;
//    unsigned int dtime_durationcosmetic;
//    unsigned int dtime_durationdigitizer;
//    unsigned int dtime_durationlcd;
//    unsigned int dtime_durationjailbreak;
//    unsigned int dtime_durationdimming;
//    unsigned int dtime_durationflash;
//    unsigned int dtime_durationgps;
//    unsigned int dtime_durationheadphone;
//    unsigned int dtime_durationinternalspeak;
//    unsigned int dtime_durationmotionsensor;
//    unsigned int dtime_durationproximitysensor;
//    unsigned int dtime_durationtouchscreen;
//    unsigned int dtime_durationvibration;
//    unsigned int dtime_durationvideo;
//    unsigned int dtime_durationwifi;
//    unsigned int dtime_durationhovering;
//    unsigned int dtime_durationpen;
//    unsigned int dtime_durationcosmeticgrade;
//    unsigned int dtime_durationcosface;
//};
//typedef struct category_device
//{
//    QString categoryName;
//    int payout;
//    int index;
//
//    category_device()
//    {
//        categoryName = "" ;
//        payout = 0;
//        index = 0;
//    }
//}category_device;
//struct cond_gds_mobile
//{
//    bool b_from_date;
//    QString from_date;
//    bool b_to_date;
//    QString to_date;
//    bool b_model;
//    QString model;
//    bool b_status;
//    QString status;
//    cond_gds_mobile()
//    {
//        b_from_date = false;
//        b_model = false;
//        b_status = false;
//        b_to_date = false;
//    }
//};
//
//typedef struct GCE_server_t
//{
//    QString name_site;
//    QString server_name;
//    QString user_name;
//    QString password;
//    int     server_port;
//    bool    is_connected;
//
//    GCE_server_t()
//    {
//        name_site = "" ;
//        user_name = "";
//        password = "";
//        server_name = "";
//        server_port = 80;
//        is_connected = false;
//
//    }
//}GCE_server_t;

//typedef struct erase_options_config
//{
//    bool locked_erase_idevice_passcode;
//    bool auto_sync_media;
//    bool enableCheckFMIP;
//    bool enableRightButton;
//    bool enableRescanallButton;
//    bool enableEraseallButton;
//    bool enableFastchargeallButton;
//    bool enableCancelallButton;
//    bool enableReportsButton;
//    bool enableprintlabelButton;
//    bool enableCableMessage;
//    bool enableReceiving;
//    bool enableReceivingBrickedPhone;
//    bool enablePrep;
//    bool enableTriage;
//    bool enableReceiving_trackingID;
//    bool enableReceivingPersistentsTrackingID;
//    bool enableReceiving_customername;
//    bool enableReceiving_OnlyInputNumberTrackID;
//    bool enableTriage_customer;
//    bool enableTriage_itemID;
//    bool enableTriage_glasscracked;
//    bool enableTriage_engraving;
//    bool enableTriage_activeunit;
//    bool enableTriage_warrantyEligible;
//    bool enableTriage_LiquidDamage;
//    bool enableTriage_SIMTray;
//    bool enableTriage_SDcardTray;
//    bool enableTriage_DamagedHousing;
//    bool enableTriage_checkSIM;
//    bool enableTriage_gradecolor;
//    bool enableFastChargre;
//    bool enableTriage_PowerDown;
//    bool enableTriage_OnlyInputNumberItemID;
//    bool enableTriage_backCover;
//    bool enableAutoRunning;
//    bool enableBottomStatusBar;
//    bool enableBatterySetting;
//    bool enableDisplayStatusProcessing;
//    bool enableDebrandingPhone;
//    bool enableUnclockPhone;
//    bool enablecheckingfirmware;
//    bool enablecheckingSIMandSDcardBeforeErasing;
//    bool enablecheckingSIMandSDcardBeforeErasing_android_only;
//    bool enable_cew;
//    bool enableCatalogDevice;
//    bool enableShowResultDetail;
//    short reflashEraseMethod;
//    short longEraseAndroid;
//    bool enable_manual_config;
//    bool enable_encrypt_data;
//    bool enable_over_write_data;
//    bool enable_skipping_setup;
//    bool enable_elapsed_time_constant;
//    bool enable_elapsed_time_process;
//    bool enable_check_for_certification;
//    bool enable_display_counter;
//    bool enable_auto_detect_device;
//    bool enable_erase_Rec_Prep;
//    bool enable_normalUI;
//    bool enable_checking_bootup;
//    //Tri Nguyen add new language 23/11/2016
//    bool enable_show_language;
//    QString time_display_counter_from;
//    QString time_display_counter_to;
//    QString time_display_counter_current_day;
//    QString display_counter_numer;
//
//    QList<category_device*> categoryList;
//
//
//    int  enableAppleConfig;
//    int  battery_percent;
//    int  battery_soh;
//    int  battery_cycle_count;
//    int  battery_charge_timeout;
//    bool downloadCDN;
//    bool enable_timeout_test;
//    bool enable_timeout_erase;
//    int timeout_test;
//    int timeout_erase;
//    int limitMinCableCycle;
//    int limitMaxCableCycle;
//    bool enablefirststop;
//    bool enableInputClientNumber;
//    bool enableEraseFMION;
//    QString currentAppleConfigName;
//    //define for GSI-GCE
//    int gsi_mode;
//    QString enable_GSI_mode;
//    bool enable_GSI_receiving_testfunctions;
//    bool disable_fore_routing;
//    bool disable_input_PO;
//    QString processid;
//    QString assetid_text;
//    bool enable_assetid_gsi;
//    bool enableTriage_OnlyInputNumberAssetid;
//    bool enable_config_interface_new_tray;
//    bool enable_detect_ESN_by_captcha;
//    bool enable_triage_without_App;
//    bool enable_show_sitename_UI;
//    bool enable_input_itemID_onport;
//    bool enable_input_cometic_grade_manual;
//    bool enable_skipping_setup_advance;
//    bool enable_skipping_setup_after_triage;
//    bool enable_erase_without_trust;
//    bool enable_active_after_erasure;
//    bool disable_processing_device_without_trust;
//    bool stop_process_recovery_FMI;
//    bool enable_select_sim_locked;
//    bool enable_select_color;
//    bool enable_select_cosmetic_grade;
//    QString language_name; //Tri add new language 23/11/2016
//    QString language_code;
//    bool enable_Gen2;
//    bool enable_update_software_locally;
//    bool enable_turn_off_iOS_device;
//    bool enable_smart_watch;
//    bool enable_print_imei_barcode;
//    bool enable_reflash_to_official_ios;
//    bool enable_to_detect_mdm_device;
//    bool enable_to_check_FMI_3rd_party;
//    bool enable_cracked_font;
//    bool enable_cracked_back;
//    QVariantMap wifiList;
//    bool enable_install_profile;
//    bool enable_normal_config_ui;
//
//    bool enable_keep_ios_greater;
//    QString ios_was_keeper;
//    QString ios_list_keeper;
//    QString server_cdn_location;
//    QString server_cloud_location;
//    QString server_cdn_link;
//    QString server_cdn_link_other;
//    QString server_cloud_link;
//    QString username_CDN;
//    QString api_key_CDN;
//    QString MswStationId;
//    erase_options_config()
//    {
//        MswStationId = "";
//        server_cdn_location = "";
//        server_cloud_location = "";
//        server_cdn_link = "";
//        server_cdn_link_other = "";
//        server_cloud_link = "";
//        username_CDN = "";
//        api_key_CDN = "";
//        enable_keep_ios_greater = false;
//        ios_was_keeper = "";
//        ios_list_keeper = "";
//        enable_normal_config_ui = false;
//        enable_install_profile = false;
//        wifiList.clear();
//        enable_cracked_font = false;
//        enable_cracked_back = false;
//        enable_to_check_FMI_3rd_party = false;
//        enable_to_detect_mdm_device = false;
//        enable_reflash_to_official_ios = false;
//        enable_print_imei_barcode = true;
//        enable_smart_watch = false;
//        enable_update_software_locally = false;
//        enable_Gen2 = false;
//        enable_select_sim_locked = false;
//        enable_select_color = false;
//        enable_select_cosmetic_grade = false;
//        stop_process_recovery_FMI = false;
//        disable_processing_device_without_trust = false;
//        enable_input_itemID_onport = false;
//        enable_input_cometic_grade_manual = false;
//        enable_show_sitename_UI = false;
//        enable_triage_without_App = false;
//        enable_detect_ESN_by_captcha = false;
//        enable_config_interface_new_tray = false;
//        enable_assetid_gsi = false;
//        assetid_text = "Asset ID";
//        processid = "";
//        gsi_mode = 0;
//        enable_GSI_mode  = "";
//        enable_GSI_receiving_testfunctions = false;
//        disable_fore_routing = false;
//        disable_input_PO = false;
//        enableTriage_OnlyInputNumberAssetid = false;
//        locked_erase_idevice_passcode = false;
//        auto_sync_media = false;
//        enableCheckFMIP = true;
//        enableRightButton = true;
//        enableRescanallButton = false;
//        enableEraseallButton = false;
//        enableFastchargeallButton = false;
//        enableCancelallButton = false;
//        enableReportsButton = false;
//        enableprintlabelButton = false;
//
//        enableCableMessage = true;
//        enableReceiving = true;
//        enablePrep = true;
//        enableTriage = true;
//        enableReceiving_trackingID = true;
//        enableReceivingPersistentsTrackingID = true;
//        enableReceiving_customername = true;
//        enableReceivingBrickedPhone = false;
//        enableTriage_customer = true;
//        enableTriage_itemID = true;
//        enableTriage_glasscracked = true;
//        enableTriage_engraving = true;
//        enableTriage_warrantyEligible = false;
//        enableTriage_activeunit = true;
//        enableTriage_LiquidDamage = false;
//        enableTriage_SIMTray = false;
//        enableTriage_SDcardTray = false;
//        enableTriage_DamagedHousing = false;
//        enableTriage_checkSIM = false;
//        enableTriage_gradecolor = false;
//        enableAutoRunning = false;
//        enableBottomStatusBar = false;
//        enableBatterySetting = false;
//        enableDisplayStatusProcessing = false;
//        enableTriage_backCover = false;
//        enableCatalogDevice = false;
//        enableShowResultDetail = LONG_ERASE_METHOD;
//        enable_cew         = false;
//        reflashEraseMethod = 0;
//        longEraseAndroid = 0;
//        enable_manual_config = true;
//        enablecheckingfirmware = false;
//        enablecheckingSIMandSDcardBeforeErasing = false;
//        enablecheckingSIMandSDcardBeforeErasing_android_only = false;
//        enable_display_counter = false;
//        enable_auto_detect_device = true;
//        enable_turn_off_iOS_device = false;
//        enable_erase_Rec_Prep = false;
//        enable_normalUI = true;
//        enable_checking_bootup = false;
////        time_display_counter_from.clear();
////        time_display_counter_to.clear();
//
//        battery_percent = 10; // 10%
//        battery_soh = 10;
//        battery_cycle_count = 10000;
//        battery_charge_timeout = 20; // 20 mins
//        enableAppleConfig = CONFIG_MODE_DEFAULT;
//        currentAppleConfigName = "";
//        enableDebrandingPhone = false;
//        enableUnclockPhone = false;
//        enableFastChargre = false;
//        downloadCDN = false;
//        enableTriage_PowerDown = false;
//        enable_timeout_test = false;
//        enable_timeout_erase = false;
//        timeout_test = 30;
//        timeout_erase = 50;
//        limitMinCableCycle = 120;
//        limitMaxCableCycle = 240;
//        enablefirststop = false;
//        enableInputClientNumber = false;
//        enableEraseFMION = false;
//        categoryList.clear();
//        enable_encrypt_data = false;
//        enable_over_write_data = false;
//        enable_skipping_setup = false;
//        enable_elapsed_time_constant = false;
//        enable_elapsed_time_process = true;
//        enable_check_for_certification = false;
//        enable_skipping_setup_advance = false;
//        enable_skipping_setup_after_triage = false;
//        enable_erase_without_trust = false;
//        enable_active_after_erasure = false;
//        language_name = "English";
//        language_code = "en";
//        //Tri Nguyen add new language 23/11/2016
//        enable_show_language = false;
//    }
//}erase_options_config;

//typedef struct printer_setting_config
//{
//    bool isloadconfig;
//    int color_mode;
//    int copyCount;
//    bool collateCopy;
//    QString creator;
//    QString docname;
//    bool doubleSidedPrinting;
//    int duplex;
//    bool FontEmbeddingEnabled;
//    bool FullPage;
//    int Orientation;
//    QString OutputFileName;
//    int OutputFormat;
//
//
//    int PageOrder;
//    int PageSize;
//    int PaperSource;
//
//    QString printername;
//    QString PrintProgram;
//    int PrintRange;
//
//    int Resolution;
//
//    qreal margin_top;
//    qreal margin_bottom;
//    qreal margin_left;
//    qreal margin_right;
//
//    qreal pagersize_width;
//    qreal pagersize_height;
//    int pagesize_unit;
//    bool enable_print_position;
//    bool enable_print_UID;
//    bool enable_print_productname;
//    bool enable_print_IMEI;
//    bool enable_print_IMEI_DEC;
//    bool enable_print_SN;
//    bool enable_print_modelno;
//    bool enable_print_capacity;
//    bool enable_print_OS;
//    bool enable_print_color;
//    bool enable_print_carier;
//    bool enable_print_processtime;
//    bool enable_print_elapsedtime;
//    bool enable_print_customername;
//    bool enable_print_trackingID;
//    bool enable_print_ITEMID;
//    bool enable_print_color_grade;
//    bool enable_print_glass_cracked;
//    bool enable_print_glass_cracked_front;
//    bool enable_print_glass_cracked_back;
//    bool enable_print_receivingdate;
//    bool enable_print_result;
//    bool enable_print_operator;
//    bool enable_print_fmi_status;
//    bool enable_print_passcode_status;
//    bool enable_print_device_grade;
//    bool enable_print_device_price;
//    bool enable_print_sprint_status;
//    bool enable_print_functionFF;
//    bool enable_print_rooted_status;
//    bool enable_print_lcd_status;
//    bool enable_print_device_damage;
//    bool enable_print_device_PO_ASN_number;
//    bool enable_print_cosmetic_grade;
//    bool enable_print_functionally;
//    bool enable_print_carrier_lock;
//    bool enable_print_black_list;
//    bool enable_print_locked;
//    bool enable_print_classify;
//    bool enable_print_lock_unlock;
//    bool enable_print_damage_housing;
//    bool enable_print_original_carrier;
//    bool enable_print_country;
//    bool enable_print_datawipe;
//    bool enable_print_cycle_count_current;
//    bool enable_print_soh_battery;
//    bool enable_print_meid;
//    bool enable_print_r2tested;
//    bool enable_print_while_processing;
//    int press_time_to_print;
//    printer_setting_config()
//    {
//        enable_print_while_processing = false;
//        press_time_to_print = 2;
//        enable_print_meid = false;
//        enable_print_r2tested = false;
//        copyCount = 1;
//        margin_top = 0.05;
//        margin_bottom = 0.05;
//        margin_left = 0.05;
//        margin_right = 0.05;
//        pagersize_width = 2.0;
//        pagersize_height = 1.5;
//        isloadconfig = false;
//        enable_print_position = false;
//        enable_print_UID = false;
//        enable_print_productname = false;
//        enable_print_IMEI = false;
//        enable_print_IMEI_DEC = false;
//        enable_print_SN = false;
//        enable_print_modelno= false;
//        enable_print_capacity= false;
//        enable_print_OS= false;
//        enable_print_color= false;
//        enable_print_carier= false;
//        enable_print_processtime= false;
//        enable_print_elapsedtime= false;
//        enable_print_customername= false;
//        enable_print_trackingID= false;
//        enable_print_ITEMID= false;
//        enable_print_color_grade= false;
//        enable_print_glass_cracked= false;
//        enable_print_glass_cracked_front = false;
//        enable_print_glass_cracked_back = false;
//        enable_print_receivingdate= false;
//        enable_print_result= false;
//        enable_print_operator= false;
//        enable_print_fmi_status = false;
//        enable_print_passcode_status = false;
//        enable_print_device_grade = false;
//        enable_print_device_price = false;
//        enable_print_sprint_status = false;
//        enable_print_functionFF = false;
//        enable_print_rooted_status = false;
//        enable_print_lcd_status = false;
//        enable_print_device_damage = false;
//        enable_print_device_PO_ASN_number = false;
//        enable_print_cosmetic_grade = false;
//        enable_print_functionally = false;
//        enable_print_carrier_lock= false;
//        enable_print_black_list= false;
//        enable_print_locked= false;
//        enable_print_classify= false;
//        enable_print_lock_unlock = false;
//        enable_print_damage_housing = false;
//        enable_print_country = false;
//        enable_print_original_carrier = false;
//        enable_print_datawipe = false;
//        enable_print_cycle_count_current = false;
//        enable_print_soh_battery = false;
//    }
//}printer_setting_config;

//typedef struct print_options_config
//{
//    bool print_after_erase;
//    bool auto_print_after_erase;
//    bool show_printer_dialog;
//    int print_text_size;
//    int font_barcode_IMEI_index;
//    int font_barcode_SN_index;
//    printer_setting_config printer_config;
//    print_options_config()
//    {
//        print_after_erase = false;
//        auto_print_after_erase = false;
//        printer_config.isloadconfig = false;
//        print_text_size = 8;
//        font_barcode_IMEI_index = 0;//BARCODE_CODE93;
//        font_barcode_SN_index = 2;//BARCODE_CODE128;
//    }
//}print_options_config;
//
//typedef struct report_options_config
//{
//    bool enable_auto_email_report;
//    QDate start_date;
//    QTime start_time;
//    bool is_daily_report;
//    bool is_weekly_report;
//    bool is_monthly_report;
//    bool is_enable_reprint;
//    QString email_address_1;
//    QString email_address_2;
//    QString email_address_3;
//    report_options_config()
//    {
//        enable_auto_email_report = false;
//        is_daily_report = false;
//        is_weekly_report = false;
//        is_monthly_report = false;
//        is_enable_reprint = false;
//        email_address_1 = "";
//        email_address_2 = "";
//        email_address_3 = "";
//    }
//}report_options_config;
//
//typedef struct function_test
//{
//    bool audio; //Audio loop back
//    bool audio_manual;//Audio loop back manual
//    bool audio_advance;//Audio loopback advance
//    bool bluetool ;//Bluetooth
//    bool bluetool_manual ;//Bluetooth
//    bool button; //Button (Power+home+down+up+mute)
//    QString buttonTimes;
//    bool radiosignal; //Call signal test
//    bool call_test;//cell test 611
//    bool camera ;//Camera (just take picture)
//    bool camera_advance;//Camera (analyze RGB)
//    bool camera_manual;//Camera (take picture and check PASSED/FAILED)
//    bool camera_analyzeQRbarcode;//Camera (scan and anlyze barcode)
//    bool camera_front;
//    bool charge ;//Check charge function
//    bool chargerport ;//Check charger port
//    QString timecharger;//setting time for charger port function
//    QString cycle_count_battery_text; // setting cycle count battery
//    bool checkbatterylevel;//Check battery
//    bool checkbatterylevel_soh;
//    QString soh_battery_text;
//    bool checknonjail;//JailBreak
//    bool checkfordeadpixel ;//LCD
//    bool compass ;//Compass
//    bool cosmetic; //Cosmetic
//    bool digitizer;//Digitizer
//    bool dimming; //Dimming
//    bool flash; //Flash
//    bool gps; //GPS
//    bool internalspeaker;//Internal Speaker
//    bool headphone; //Headphone
//    bool motionsensor ;//Motion sensor
//    bool proximitysensor;//Proximitysensor
//    bool touchscreen; //Touchscreen
//    bool videoplayback; //Video record play back
//    bool videoplayfront; //Video record play back
//    bool vibration; //Vibration
//    bool wifi ;//Wifi
//    bool buttonkeylight;//button keylight for android
//    bool lightsensor;//lightsensor for iOS
//    bool touchID;//touchID for iOS
//    bool auto_internalspeaker;//Internal Speaker, automatic (use for iCombine 3.0)
//    bool auto_headphone; //Headphone, , automatic (use for iCombine 3.0)
//    bool Hovering_sensor; //Video record play back (just for android)
//    bool pen; //Vibration (just for android)
//    bool  grade_cosmetic ;//Cosmetic Grade
//    bool  cosface_grade ;//Cosmetic Surface Grade
//    bool  user_profile;
//    QString settouchscreen;
//    QString timevideoback; //timeout for video back
//    QString timevideofront; //timeout for video Front
//    QString swipe_size;
//    bool imeicheck;
//    bool NFC; // (just for android)
//    bool power;
//    bool subkeybacklight; //(just for android)
//    bool powercheck;//Check power off/on function
//    bool touchscreencaculator;//Touchscreen with interface calculator
//    bool wifi_manual; //Test wifi manual and check passed/failed
//    bool wifi_streaming; //display videos and operator check passed failed
//    QString linkWifi;
//    bool sdcarddetection; //sdcard detection
//    bool sdcardauto;//sdcard detect automatically
//    bool simcarddetection;//sim card detection
//    bool headsetjack;//headset jack
//    bool SDcardmanual;//sdcard
//    bool NFCmanual;//NFC manual
//    bool GPSmanual;//gpsmanual
//    bool SMS;//SMS test
//    bool faceID;//face ID test
//    bool iris;//iris test
//    bool isEnableFunction;
//    QString result_detail_for_label;
//
//    bool print_label;
//    bool erase_device;
//    QString timeout_internal_peaker;
//    bool color_red;
//    bool color_green;
//    bool color_grey;
//    bool color_blue;
//    bool color_while;
//
//    bool color_red_burn;
//    bool color_green_burn;
//    bool color_grey_burn;
//    bool color_blue_burn;
//    bool color_while_burn;
//
//    bool show_messageturnoffwifi;
//    bool wireless_changer;
//    //++Add by Tri
//    bool hJack_and_headphone;
//    bool barometer;
//    bool touch3d;
//    bool hallIC;
//    bool LEDlight;
//    bool re_orient;//add new 15/11/2016
//    bool multi_touch;
//    bool screen_ghost;
//    QString timescreenghost;
//    //++End add
//    QString amplitudeAudioloopback;
//    bool audio_advance_amplitude;//Audio loopback advance amplitude
//    bool power_button;
//    bool lcd_burnin;
//    QString timeout_signal;
//    QString timeout_headphone;
//    function_test()
//    {
//        timeout_headphone = "30";
//        soh_battery_text = "";
//        iris = false;
//        faceID = false;
//        timeout_signal = "10";
//        lcd_burnin = false;
//        timescreenghost = "10";
//        multi_touch = false;
//        screen_ghost = false;
//        checkbatterylevel_soh = false;
//        audio_advance_amplitude = false;
//        power_button = false;
//        hJack_and_headphone = false;
//        barometer = false;
//        touch3d = false;
//        hallIC = false;
//        LEDlight = false;
//        re_orient = false; //add new 15/11/2016
//        amplitudeAudioloopback = "0";
//        audio = false;
//        audio_manual = false;
//        audio_advance = false;
//        bluetool = false;
//        bluetool_manual = false;
//        button = false;
//        buttonTimes = "1";
//        radiosignal = false;
//        camera = false;
//        camera_analyzeQRbarcode = false;
//        camera_front = false;
//        charge = false;
//        timecharger = "0";
//        chargerport = false;
//        checkbatterylevel= false;
//        checknonjail= false;
//        checkfordeadpixel = false ;
//        compass = false;
//        cosmetic = false;
//        digitizer = false;
//        dimming = false;
//        flash = false;
//        gps = false;
//        internalspeaker = false;
//        headphone = false;
//        motionsensor= false ;
//        proximitysensor = false;
//        touchscreen = false;
//        videoplayback = false;
//        videoplayfront = false;
//        vibration = false;
//        wifi = false;
//
//        print_label = false;
//        erase_device = false;
//        timeout_internal_peaker = "10";
//        cycle_count_battery_text = "";
//        auto_internalspeaker = false;
//        auto_headphone = false;
//
//        Hovering_sensor= false; //Video record play back
//        pen= false; //Vibration
//        grade_cosmetic = false;//Wifi
//        user_profile=false;
//        settouchscreen = "";
//        isEnableFunction = false;
//        result_detail_for_label = "";
//        timevideoback = "";
//        timevideofront = "";
//        swipe_size = "";
//        buttonkeylight = false;
//        lightsensor = false;
//        touchID = false;
//        imeicheck = false;
//        NFC = false;//for android
//        power = false;
//        subkeybacklight = false;//for android
//        powercheck = false;//for android and iPhone
//        camera_advance = false;
//        touchscreencaculator = false;
//        wifi_manual = false;
//        wifi_streaming = false;
//        linkWifi = "";
//        sdcarddetection = false;
//        sdcardauto = false;
//        simcarddetection = false;
//        cosface_grade= false;
//        headsetjack= false;
//        SDcardmanual=false;
//        NFCmanual=false;
//        GPSmanual = false;
//        SMS = false;
//        color_red = true;
//        color_green = true;
//        color_grey = true;
//        color_blue = true;
//        color_while = true;
//
//        color_red_burn = true;
//        color_green_burn = true;
//        color_grey_burn = true;
//        color_blue_burn = true;
//        color_while_burn = true;
//
//        show_messageturnoffwifi = false;
//        wireless_changer = false;
//        //++Add by Tri
//        hJack_and_headphone = false;
//        barometer = false;
//        //++End add
//    }
//}function_test;
//
//typedef struct GCS_server_t
//{
//    QString hostName;
//    QString uri;
//    QString user_name;
//    QString password;
//    QString role;
//    bool is_connected;
//    long distanceUTCtime;//Khoang chenh lech thoi gian giua UTC local va UTC server.
//    QString site_name;
//    QString api_version;
//    QString location;
//    int isCustomerQuestion;
//    bool iscertificate;
//    QString station_name_GSI;
//    QVariantMap processid_config; /// huy
//    QVariantMap destination_get_GSI;
//    bool isInstallappHelloScreen;
//    bool isEraseHelloscreen;
//    bool isCertificateFrp;
//    //Tri Nguyen add new language 23/11/2016
//    bool enabled_language;
//    GCS_server_t()
//    {
//        station_name_GSI = "";
//        processid_config.clear();  /// huy
//        destination_get_GSI.clear();
//        hostName = "" ;
//        user_name = "";
//        password = "";
//        uri = "";
//        //server_port = 80;
//        is_connected = false;
//        role = "";
//        distanceUTCtime = 0;
//        site_name = "";
//        api_version = "";
//        location = "";
//        isCustomerQuestion = 0;
//        iscertificate = false;
//        isInstallappHelloScreen = true;
//        isEraseHelloscreen = true;
//        isCertificateFrp = false;
//        enabled_language = false;
//    }
//}GCS_server_t;
//
//typedef struct system_setting_options
//{
//    report_options_config report_options;
//    erase_options_config  erase_options;
//    print_options_config print_options;
//    function_test select_function_test;
//    GCS_server_t server_option;
//}system_setting_options;
//
//struct volumn_item_t
//{
//    double analyse;
//    double pass;
//    double fail;
//    double avarage;
//    double db_media;
//    double db_speak;
//    int scale;
//    float noise;
//    volumn_item_t()
//    {
//        analyse = 0;
//        pass = 0;
//        fail = 0;
//        avarage = 0;
//        db_media = 0;
//        noise = 0;
//    }
//};
//
//typedef struct GCS_server_info
//{
//    QString hostName;
//    QString url;
//    QString location;
//    QString area;
//    QString user_name;
//    QString password;
//    bool    is_connected;
//    int cnt_time_reconnect;
//    int status; // 0 : good, fail
//    QString apple_post_host;
//
//    GCS_server_info()
//    {
//        hostName = "" ;
//        url = "";
//        user_name = "";
//        password = "";
//        is_connected = true;
//        area = "";
//        cnt_time_reconnect = 0;
//        status = 0;
//        apple_post_host = "";
//    }
//}GCS_server_info;
//
//typedef struct Cosmetic_Grade_Question
//{
//    int questionindex;
//    double questionno;
//    QString category;
//    QString question;
//    double yesnextquestion;
//    QString yesautomaticgrade;
//    double nonextquestion;
//    QString noautomaticgrade;
//    Cosmetic_Grade_Question()
//    {
//        questionindex = 0;
//        questionno = 0 ;
//        category = "";
//        question = "";
//        yesnextquestion = 0;
//        yesautomaticgrade = "";
//        nonextquestion = 0;
//        noautomaticgrade = "";
//    }
//}Cosmetic_Grade_Question;
//
//#define LIST_BB_Z10_MODELS      "STL100-1, STL100-2, STL100-3, STL100-4"
//#define LIST_BB_Q10_MODELS      "SQN100-1, SQN100-2, SQN100-3, SQN100-4, SQN100-5"
//#define LIST_BB_Z30_MODELS      "STA100-1, STA100-2, STA100-3, STA100-4, STA100-5, STA100-6"
//
//typedef struct _BB_INFO_TEMP
//{
//    //++quyen tran add support BB
//    char flag_BB10_info_valid;
//    char flag_BB10_read_info_finished;
//    char flag_BB10_erase_success;
//    char flag_BB10_authen_success;
//    char flag_BB10_listApps_success;
//    char flag_BB10_installApp_success;
//    char flag_BB10_uninstallApp_success;
//    char flag_BB10_passcode_on;
//    char manufacture[32];					//manufacture name (BlackBerry)
//    char BbPin[32];                         //BbPin number (same serial number (734594913))
//    char model_name[32];					//model name (BlackBerry Z10)
//    char OSType[32];                        //model name (BlackBerry 10)
//    char model_number[32];					//model number (STL100-3)
//    char PhoneFW[32];                       //Phone firmware version - OS version (10.2.1.3442)
//    char IMEI_ESN[32];                      //IMEI: iternational mobile equipment identify (GSM)
//    unsigned long long capacity;            //Bytes
//    char capacity_GBs[8];                   //GigaBytes
//    char battery_percent;                   //[0:100] percent of capacity battery
//    char SDCard;                            //0:No SD Card; 1: Has SD Card
//    char SIMCard;                           //0:No SIM Card; 1: Has SIM Card
//}BB_INFO_TEMP;
//
////new define to quesTionList CEW
//typedef struct question_struct{
//    QString questionNumber;
//    QString questionText;
//    QString questionCode;
//    QString defaultResponseCode;//Default response code
//    QString defaultResponseText;//Default response text
//    QVariantMap validResponses;//List response
//    QVariantList validResponsesList;
//    QVariantMap reasons;//List reasons
//    QString reasonsList;
//    QString parentQuestion;//NULL if the question is the primary question.
//    QString isSecondaryQuestion;//TRUE: has secondary questions, else value FALSE
//} question_struct;
//
//typedef struct function_struct{
//    QString CEWFunctionKey;
//    int testOrder;
//} function_struct;
//
//struct CEWData
//{
//    QString itemID;
//    QString IMEI;
//    QList<question_struct> primaryQuestion;
//    QList<question_struct> secondaryQuestion;
//    QList<function_struct> primaryFunction;
//    QList<function_struct> secondaryFunction;
//};
//
//struct featurePhone
//{
//    QString manuafacture;
//    QString IDvendor;
//    QString IDproduct;
//};
//struct firmwarephonecheck
//{
//   QString manuafacture;
//   QString model;
//   QString approvedhardware;
//   QString oldhardware;
//};
//struct informationsICCIMS
//{
//   QString str_carrier;
//   QString str_iccid;
//   QString str_imsid;
//   QString str_regioncode;
//   QString str_country;
//   QString str_del_if;
//   QString str_datecreated;
//   QString str_usercreated;
//   QString str_dateupdated;
//   QString str_userupdated;
//};
//struct iOS_apptest
//{
//    QString appPath;
//    QString appAPPID;
//};
//typedef struct function_test_struct{
//    QString functionKey;
//    int ordinalFunction;
//} function_test_struct;
//
//typedef struct CLIENT_MACHINE_INFO{
//    QString machine_ipAdreess;
//    QString machine_password;
//    QString machine_macAddress;
//    QString machine_serial;
//    int machine_groupNum;
//    bool isConnecting;
//    bool is_donloading_ios;
//    CLIENT_MACHINE_INFO(){
//        machine_ipAdreess = "";
//        machine_password = "";
//        machine_macAddress = "";
//        machine_groupNum = 0;
//        isConnecting = false;
//        machine_serial = "";
//        is_donloading_ios = false;
//    }
//} CLIENT_MACHINE_INFO;

#endif // DEFINE_GDS_H
