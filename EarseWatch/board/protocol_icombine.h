#ifndef PROTOCOL_H
#define PROTOCOL_H
#include "qextserialport.h"
#include <QString>
#include "constant.h"
#include "define_gds.h"
#include "mysql/Mysql.h"


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


typedef struct Hardware_info{

    unsigned char moduleIndex;
    QString fwVersion;
    QString hwVersion;

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


class Protocol
{
public:

    //COMCommunication * comObj;
    QextSerialPort *SWComm;
    QString error_msg;
    int process_fw;
    Mysql *check_database;
    Protocol();
    ~Protocol();

    unsigned short connectModule(QString portName);
    unsigned char  calculateCRC(unsigned char *data, int len);
    unsigned long  calculateCRC32(unsigned char *buffFW, unsigned long size);
    unsigned short getPackage(unsigned char *data, unsigned short dataLen,
                              unsigned short timeout, int *len = NULL);
    unsigned short sendPackage (unsigned char *data, unsigned short dataLen);


    unsigned short startTest(unsigned char moduleId, unsigned char devType[8],unsigned char devList[8]);
    unsigned short stopTest(unsigned char moduleId, unsigned char devList[8]);
    unsigned short testing(unsigned char moduleId, unsigned char devType[8],unsigned char devList[8]);
    unsigned short updateInfo(unsigned char moduleId, unsigned char *capInfo, unsigned char *currentInfo,
                              unsigned char *timeInfo, unsigned char *statusInfo, unsigned char *timeRemain,
                              unsigned char *timeDischargeRemain, unsigned char *buttonInfo);
    unsigned short updateInfoV2(unsigned char moduleId, unsigned char *capInfo, unsigned char *currentInfo,
                              unsigned char *timeInfo, unsigned char *statusInfo, unsigned char *timeRemain,
                              unsigned char *timeDischargeRemain, unsigned char *buttonInfo, unsigned char *chargeModeInfo);
    unsigned short connectUsb(unsigned char moduleId, unsigned char position, unsigned char * positList);
    unsigned short upgradeFw(unsigned char moduleId);
    unsigned short startUpgradeFw(unsigned char moduleId, unsigned long fwVersion, unsigned long totalByte,  unsigned long sum32);
    unsigned short sendUpgradeFw(unsigned char moduleId, unsigned short addrPage, unsigned char * dataUpgrade, unsigned short dataLen);
    unsigned short finishUpgradeFw(unsigned char moduleId);

    unsigned short switchDevicePlugged(unsigned char moduleId, unsigned char devList[8]);
    unsigned short SWmic(unsigned char moduleID ,int mic_ID);

    unsigned short powerOff(unsigned char moduleId,
                                      unsigned char devList[8],
                                      unsigned char battery_percent[8],
                                      unsigned char device_type[8]);
    bool readVersion (unsigned char moduleId, hardware_info *hwInfo);
    bool sendCommand(command_info *cmd);
    bool upgradeFirmware(command_info cmd, QString filename);
    unsigned short swichUsb(unsigned char moduleId, unsigned char USB_mode[8]);
    bool sendCommandList(command_info cmd);
    /* Thanh edit*/
    bool isModuleOpen;
    bool readStatus(status_info *module_status);
    bool readAllStatus(QList<status_info*> *lists, int module_id, QString hwVersion);
    void closeModule();
    bool reset_module(unsigned char moduleId);
    bool setSWID(unsigned char moduleId, unsigned char SW_ID);
    bool readKeyPressFromFW(unsigned char moduleId, QList<key_control_info *> *list_status);
    unsigned short changeCriteria(unsigned char moduleId, unsigned char devList[8], unsigned char criteria[8]);
    unsigned short resetUsbHub(unsigned char moduleId, unsigned char hub_pos);
    unsigned short ledControl(unsigned char moduleId, unsigned char LEDMode[8]);
    unsigned short readKeyEvent(unsigned char moduleId,
                                          unsigned char *buttonInfo,
                                          unsigned char *deviceInfo);
    unsigned short read_seria_number(unsigned char moduleId, unsigned char * seria_number);
    unsigned short convertSerialNumber(unsigned char * seria_number);
     unsigned short detectShorted(unsigned char moduleID ,unsigned char*status);

};

#endif // COMMUNICATION_H
