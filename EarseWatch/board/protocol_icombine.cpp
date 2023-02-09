#include <stdio.h>
#include <string.h>
#include "protocol.h"
#include "utility.h"
#include <QDebug>
#include <unistd.h>
#include <QStringList>
#include "constant.h"
#include "zeroall_infor.h"

Protocol::Protocol()
{

    this->SWComm = NULL;
}
////////////////////////////////////////////////////////////////////////////
//
Protocol::~Protocol()
{
    closeModule();
}

void Protocol::closeModule()
{
    isModuleOpen = false;
    if(this->SWComm!=NULL)
    {
        if(this->SWComm->isOpen()==true)
        {
            this->SWComm->close();
        }
        delete this->SWComm;
        this->SWComm = NULL;
    }
}

////////////////////////////////////////////////////////////////////////////
//
unsigned short Protocol::connectModule(QString portName)
{
    PortSettings settings;

    //IXComm=new QextSerialPort("/dev/ttyUSB0",settings);

    //settings.BaudRate=BAUD9600;
    settings.BaudRate=BAUD38400;
    settings.Parity=PAR_NONE;
    settings.DataBits=DATA_8;
    settings.StopBits=STOP_1;
    settings.FlowControl=FLOW_OFF;
    settings.Timeout_Millisec=0;

    SWComm = new QextSerialPort(settings);

    SWComm->setPortName(portName);
    isModuleOpen = true;
    return SUCCESS;
}
////////////////////////////////////////////////////////////////////////////
//
unsigned short Protocol::sendPackage(unsigned char *data, unsigned short dataLen)
{
    QByteArray cmd_read;
    int result = -1;
    unsigned short timeOut = 0;

    cmd_read.append((char*)data, dataLen);
    SWComm->flush();
    if(SWComm->open(QIODevice::ReadWrite | QIODevice::Truncate)==false)
    {
        qDebug() << "sendPackage : Open COM failed";

        error_msg += "sendPackage : Open COM err\n";
        return FAILED;
    }

    QByteArray received;
    received=SWComm->readAll();
    result = SWComm->write(cmd_read);
    //    qDebug() << "sendPackage : byte write = " << result;

    while(result != dataLen)
    {
        timeOut++;
        usleep(5000);
        SWComm->flush();
        received = this->SWComm->readAll();
        result   = this->SWComm->write(cmd_read);

        if(timeOut > 2)
        {
            error_msg += "sendPackage : timeout err\n";
            return FAILED;

        } //end if
    } //end while

    //    fprintf(stderr, "sendPackage: \n");
    //    printBuff08((unsigned char *)data,dataLen);
    return SUCCESS;
}

////////////////////////////////////////////////////////////////////////////
// timeout : ms
unsigned short Protocol:: getPackage(unsigned char *data, unsigned short dataLen,
                                     unsigned short timeout, int *lenGet)
{
    if(SWComm->open(QIODevice::ReadWrite | QIODevice::Truncate)==false)
    {
        qDebug() << "getPackage: Open failed";

        error_msg += "getPackage : Open COM failed\n";
        return FAILED;
    }

    int count=0;
    while(1)
    {
        if(count > timeout)
        {
            break;
        }
        if(SWComm->bytesAvailable() >= dataLen)
        {
            break;
        }
        count++;
        //        usleep(1000); // 1ms
        //       usleep(5000);
        usleep(10000);
    }

    if(SWComm->bytesAvailable() == 0)
    {
        fprintf(stderr, "getPackage : bytesAvailable = 0 \n");
        error_msg += "getPackage : timeout err\n";
        return TIME_OUT;
    }

    QByteArray received;
    received = SWComm->readAll();

    //    fprintf(stderr, "getPackage : \n");
    //    printBuff08((unsigned char *)received.data(),received.size());
    if(lenGet != NULL)
    {
        *lenGet = received.size();
    }
    if(received.size() < dataLen)
    {

        memcpy((unsigned char*)data, received.data(), received.size());
        error_msg += "getPackage: package len err\n";
        return FAILED;
    }

    memcpy((unsigned char*)data, received.data(), dataLen);

    return SUCCESS;
}
////////////////////////////////////////////////////////////////////////////
//
unsigned char Protocol::calculateCRC(unsigned char *data, int len)
{
    int i = 0;
    unsigned char ck = 0;

    for(ck = 0, i = 0; i < len; i++)
    {
        ck += data[i];
    }
    return 256 - ck;
}
////////////////////////////////////////////////////////////////////////////
///* Calculate the CRC32 */
unsigned long Protocol::calculateCRC32(unsigned char *buffFW, unsigned long size)
{
    unsigned short i, count;
    unsigned char data;
    unsigned long crc, mask, table[256];
    qDebug()<<"-----------------QQQQQQQQQQQQQQQQQQQ-------------sizeofunsigned long"<<sizeof(crc);
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

/**
 * @brief Protocol::readVersion
 * @param moduleId
 * @param hwInfo
 * @return
 */
bool Protocol::readVersion(unsigned char moduleId, hardware_info *hwInfo)
{
    unsigned short res = 0;  //result
    unsigned short timeOut = 1000;  //ms
    unsigned short len = 0;
    unsigned char sum = 0;
    bool isError = true;

    unsigned char dataSend[9] = {
        0xFF, 0x55,
        0x00, 0x00,  // side
        0x00,        // command code
        0x00, 0x01,  // Dir, protocol version
        0x00,        // moduleId
        0x00         //sum
    };

    unsigned char dataRec[16]= {0};

    error_msg = "";
    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_READ_VERSION;
    dataSend[MODULE_OFF]= moduleId;

    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF, len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {
        debug_error("%s[ERROR]%s readVersion: sendPackage FAILED \n", KRED, RESET);
        error_msg += "rd ver: send err\n";
        return false;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_error("%s[ERROR]%s readVersion: getPackage FAILED \n", KRED, RESET);
        error_msg += "rd ver: get err\n";
        return false;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_error("%s[ERROR]%s readVersion: check signature FAILED \n", KRED, RESET);
        error_msg += "rd ver: check sig err\n";
        return false;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec, SIDE_OFF);

    if(len + 3 != sizeof(dataRec))
    {
        debug_error("%s[ERROR]%s readVersion: check len FAILED (%d) \n", KRED, RESET, len);
        error_msg += "rd ver: check len err\n";
        return false;
    }

    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);
    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_error("%s[ERROR]%s readVersion: check sum FAILED (sum = %d = 0x%2x; dataRec[len+2] = %d = 0x%2x) \n", KRED, RESET, sum, sum, (unsigned char)dataRec[len+2], (unsigned char)dataRec[len+2]);
        error_msg += "rd ver: check sum err\n";
        return false;
    }

    //check code , status, module
    if(dataRec[CODE_OFF]!= CM_READ_VERSION ||
            dataRec[STATUS_OFF] != 0x01)
    {
        debug_error("%s[ERROR]%s readVersion: check code/status FAILED \n", KRED, RESET);
        error_msg += "rd ver: check status err\n";
        return false;
    }

    hwInfo->moduleIndex = dataRec[MODULE_OFF];
    if(hwInfo->moduleIndex != moduleId)
    {
        debug_error("%s[ERROR]%s readVersion: moduleIndex (%d) <> moduleId (%d) \n", KRED, RESET, hwInfo->moduleIndex, moduleId);
        return false;
    }

    for(int i = 9; i < 15; i++)
    {
        if(dataRec[i] != 0xFF)
        {
            isError = false;
            break;
        }
    }
    char str[12] = {0};
    if(dataRec[12] == 4)
    {
        sprintf(str, "%d.%d%d",dataRec[9], dataRec[10], dataRec[11]);
        hwInfo->fwVersion = QString(str);

        memset(str, 0, sizeof(str));
        sprintf(str, "%d.%d%d",dataRec[12], dataRec[13], dataRec[14]);
        hwInfo->hwVersion = QString(str);
    }
    else
    {
        sprintf(str, "%d.%d%c",dataRec[9], dataRec[10], dataRec[11]);
        hwInfo->fwVersion = QString(str);

        memset(str, 0, sizeof(str));
        sprintf(str, "%d.%d%c",dataRec[12], dataRec[13], dataRec[14]);
        hwInfo->hwVersion = QString(str);
    }
    if(isError == true)
    {
        hwInfo->hwVersion = QString("-1.-1");
        hwInfo->fwVersion = QString("-1.-1");
    }

    //3.0
    if(hwInfo->hwVersion.toUpper().contains("1.0D") == true)
    {
        hwInfo->hwVersion = "3.0";
    }
    HW_version =  hwInfo->hwVersion;

    debug_info("%s[DEBUG]%s readVersion: fwVersion = %s, hwVersion = %s \n", KBLU, RESET, hwInfo->fwVersion.toLatin1().data(), hwInfo->hwVersion.toLatin1().data());
    return true;
}

/**
 * @brief Protocol::startTest
 * @param moduleId
 * @param devType
 * @param devList
 * @return
 */
unsigned short Protocol::startTest(unsigned char moduleId, unsigned char devType[8],unsigned char devList[8])
{
    unsigned short i = 0;
    unsigned short res = 0;  //result
    unsigned short timeOut = 8000;
    unsigned short len = 0;
    unsigned char sum = 0;

    unsigned char dataSend[33] = {
        0xFF, 0x55,
        0x00, 0x00,  // side
        0x00,        // command code
        0x00, 0x01,  // Dir, protocol version
        0x00,        // moduleId
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,// offset 8, idevice type
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // offset 16, device list
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00
    };

    unsigned char dataRec[10]= {0};
    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_START_TEST;
    dataSend[MODULE_OFF]= moduleId;
    for(i = 0; i < 8; i++)
    {
        dataSend[8 + i] = devType[i];
    }

    for(i = 0; i < 8; i++)
    {
        if(devList[i] == 1)
        {
            dataSend[16 + i] = 1;
        }
    }

    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {
        debug_common("startTest: sendPackage FAILED \n");

        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_common("startTest: getPackage FAILED\n");
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("startTest: check signature FAILED \n");
        error_msg += "start T: check sig err\n";
        return FAILED;
    }

    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

    //check len
    if(len + 3 != sizeof(dataRec))
    {
        debug_common("startTest: len = %d \n", len);
        debug_common("startTest: check len FAILED\n");
        error_msg += "start T: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("startTest: check sum = %d = 0x%2x \n", sum, sum);
        debug_common("startTest: dataRec[len+2] = %d = 0x%2x \n", (unsigned char)dataRec[len+2], (unsigned char)dataRec[len+2]);
        debug_common("startTest: check sum FAILED \n");

        error_msg += "start T: check sum err\n";
        return ERR_CHECKSUM;
    }

    //check code , status, module
    if(dataRec[CODE_OFF]!= CM_START_TEST ||
            dataRec[MODULE_OFF]!= moduleId    ||
            dataRec[STATUS_OFF]!= 0x01)
    {

        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("startTest: FW check sum FAILED \n");

            error_msg += "start T: FW check sum err\n";
            return ERR_CHECKSUM;
        }
        debug_common("startTest: check code/module Id/status FAILED \n");
        error_msg += "start T: check code/status err\n";
        return FAILED;
    }

    return SUCCESS;
}
////////////////////////////////////////////////////////////////////////////
//
unsigned short Protocol::stopTest(unsigned char moduleId, unsigned char devList[8])
{
    unsigned short i = 0;
    unsigned short res = 0;  //result
    unsigned short timeOut = 1000;
    unsigned short len = 0;
    unsigned char sum = 0;

    unsigned char dataSend[17] = {
        0xFF, 0x55,
        0x00, 0x00,  // side
        0x00,        // command code
        0x00, 0x01,  // Dir, protocol version
        0x00,        // moduleId
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,// offset 8, idevice list
        0x00
    };

    unsigned char dataRec[10]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_STOP_TEST;
    dataSend[MODULE_OFF]= moduleId;

    for(i = 0; i < 8; i++)
    {
        if(devList[i] == 1)
        {
            dataSend[8+i] = 1;
        }
    }

    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {
        debug_common("stopTest: sendPackage FAILED \n");

        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_common("stopTest : getPackage FAILED \n");
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("stopTest : check signature FAILED \n");

        error_msg += "stop T: check sig err\n";
        return FAILED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

    if(len + 3 != sizeof(dataRec))
    {
        debug_common("stopTest : len = %d \n", len);
        debug_common("stopTest : check len FAILED \n");

        error_msg += "stop T: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("stopTest : check sum FAILED \n");

        error_msg += "stop T: check sum err\n";
        return ERR_CHECKSUM;
    }

    //check code , status, module
    if(dataRec[CODE_OFF]!= CM_STOP_TEST ||
            dataRec[MODULE_OFF]!= moduleId   ||
            dataRec[STATUS_OFF]!= 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("stopTest: FW check sum FAILED \n");

            error_msg += "stop T: FW check sum err\n";
            return ERR_CHECKSUM;
        }
        debug_common("stopTest: check code/ module Id/ status FAILED \n");

        error_msg += "stop T: check code/status err\n";
        return FAILED;
    }

    return SUCCESS;
}
////////////////////////////////////////////////////////////////////////////
//
unsigned short Protocol::testing(unsigned char moduleId, unsigned char devType[8],unsigned char devList[8])
{
    unsigned short i = 0;
    unsigned short res = 0;  //result
    unsigned short timeOut = 3000;
    unsigned short len = 0;
    unsigned char sum = 0;

    unsigned char dataSend[33] = {
        0xFF, 0x55,
        0x00, 0x00,  // side
        0x00,        // command code
        0x00, 0x01,  // Dir, protocol version
        0x00,        // moduleId
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,// offset 8, idevice type
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // offset 16, device list
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00
    };

    unsigned char dataRec[10]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_TESTING;
    dataSend[MODULE_OFF]= moduleId;
    for(i = 0; i < 8; i++)
    {
        dataSend[8+i] = devType[i];

    }

    for(i=0;i<8;i++)
    {
        if(devList[i]== 1)
        {
            dataSend[16+i]= 1;
        }
    }

    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {
        debug_common("testing: sendPackage FAILED \n");

        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_common("testing : getPackage FAILED \n");
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("testing : check signature FAILED \n");

        error_msg += "testing: check sig err\n";
        return FAILED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

    if(len + 3 != sizeof(dataRec))
    {
        debug_common("testing : getPackage check len FAILED \n");

        error_msg += "testing: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("testing : check sum FAILED \n");

        error_msg += "testing: check sum err\n";
        return ERR_CHECKSUM;
    }

    //check code , status, module
    if(dataRec[CODE_OFF]!= CM_TESTING ||
            dataRec[MODULE_OFF]!= moduleId ||
            dataRec[STATUS_OFF]!= 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("stopTest: FW check sum FAILED \n");

            error_msg += "testing: FW check sum err\n";
            return ERR_CHECKSUM;
        }
        debug_common("stopTest: check code/ module Id/ status FAILED \n");

        error_msg += "testing: check code/status err\n";
        return FAILED;
    }

    return SUCCESS;
}
////////////////////////////////////////////////////////////////////////////
//
unsigned short Protocol::updateInfo(unsigned char moduleId, unsigned char *capInfo, unsigned char *currentInfo,
                                    unsigned char *timeInfo, unsigned char *statusInfo, unsigned char *timeRemain,
                                    unsigned char *timeDischargeRemain, unsigned char *buttonInfo)
{
    unsigned short res = 0;  //result
    unsigned short timeOut = 2000;
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

    unsigned char dataRec[106]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_UPDATE_INFO;
    dataSend[MODULE_OFF]= moduleId;


    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {
        debug_common("updateInfo: sendPackage FAILED \n");
        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_common("111 updateInfo: getPackage FAILED moduleId = %d \n", moduleId);
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("updateInfo: check signature FAILED \n");

        error_msg += "upd inf: check sig err\n";
        return FAILED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);
    //debug_common("updateInfo: len = %d \n", len);

    if(len + 3 != sizeof(dataRec))
    {
        debug_common("updateInfo: check len FAILED \n");

        error_msg += "upd inf: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("updateInfo: check sum FAILED \n");

        error_msg += "upd inf: check sum err\n";
        return ERR_CHECKSUM;
    }
    //check code , status, module
    if(dataRec[CODE_OFF]!= CM_UPDATE_INFO ||
            dataRec[MODULE_OFF]!= moduleId ||
            dataRec[STATUS_OFF]!= 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("updateInfo: FW check sum FAILED \n");
            error_msg += "upd inf: FW check sum err\n";
            return ERR_CHECKSUM;
        }

        debug_common("updateInfo: check code/ module Id/ status FAILED \n");
        error_msg += "upd inf: FW check code/status err\n";
        return FAILED;
    }
    memcpy(capInfo,dataRec + 9, 16);
    memcpy(buttonInfo,dataRec + 25, 8);
    memcpy(currentInfo,dataRec + 33, 16);
    memcpy(timeInfo,dataRec + 49, 16);
    memcpy(statusInfo,dataRec + 65, 8);
    memcpy(timeRemain,dataRec + 73, 16);
    memcpy(timeDischargeRemain,dataRec + 89, 16);
    return SUCCESS;
}
unsigned short Protocol::updateInfoV2(unsigned char moduleId, unsigned char *capInfo, unsigned char *currentInfo,
                                    unsigned char *timeInfo, unsigned char *statusInfo, unsigned char *timeRemain,
                                    unsigned char *timeDischargeRemain, unsigned char *buttonInfo, unsigned char *chargeModeInfo)
{
    unsigned short res = 0;  //result
    unsigned short timeOut = 2000;
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

//    unsigned char dataRec[106]= {0};
    unsigned char dataRec[122]= {0};//ICV3

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_UPDATE_INFO;
    dataSend[MODULE_OFF]= moduleId;


    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {
        debug_common("updateInfo: sendPackage FAILED \n");
        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_common("111 updateInfoV2: getPackage FAILED moduleId = %d \n", moduleId);
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("updateInfoV2: check signature FAILED \n");

        error_msg += "upd inf: check sig err\n";
        return FAILED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);
    //debug_common("updateInfoV2: len = %d \n", len);

    if(len + 3 != sizeof(dataRec))
    {
        debug_common("updateInfoV2: check len FAILED \n");

        error_msg += "upd inf: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("updateInfoV2: check sum FAILED \n");

        error_msg += "upd inf: check sum err\n";
        return ERR_CHECKSUM;
    }
    //check code , status, module
    if(dataRec[CODE_OFF]!= CM_UPDATE_INFO ||
            dataRec[MODULE_OFF]!= moduleId ||
            dataRec[STATUS_OFF]!= 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("updateInfoV2: FW check sum FAILED \n");
            error_msg += "upd inf: FW check sum err\n";
            return ERR_CHECKSUM;
        }

        debug_common("updateInfoV2: check code/ module Id/ status FAILED \n");
        error_msg += "upd inf: FW check code/status err\n";
        return FAILED;
    }
    debug_common("updateInfo V2: data receive ================================ \n");
    printBuff08((unsigned char *)dataRec, len);
    memcpy(capInfo,dataRec + 9, 16);
    memcpy(buttonInfo,dataRec + 25, 8);
    memcpy(currentInfo,dataRec + 33, 16);
    memcpy(timeInfo,dataRec + 49, 16);
    memcpy(statusInfo,dataRec + 65, 8);
    memcpy(timeRemain,dataRec + 73, 16);
    memcpy(timeDischargeRemain,dataRec + 89, 16);
    memcpy(chargeModeInfo, dataRec + 105, 16);

    return SUCCESS;
}
//////////////////////////////////////////////////////////////////////////////
////
unsigned short Protocol::swichUsb(unsigned char moduleId, unsigned char USB_mode[8])
{
    unsigned short res = 0;  //result
    unsigned short timeOut = 4000;
    unsigned short len = 0;
    unsigned char sum = 0;

    unsigned char dataSend[17] = {
        0xFF, 0x55,
        0x00, 0x00,  // side
        0x00,        // command code
        0x00, 0x01,  // Dir, protocol version
        0x00,        // moduleId
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // USB mode
        0x00
    };

    unsigned char dataRec[18]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_SWITCH_USB;
    dataSend[MODULE_OFF]= moduleId;

    for(int i = 0; i < 8; i++)
    {
        dataSend[8 + i] = USB_mode[i];
    }


    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {
        debug_common("swichUsb: sendPackage FAILED \n");
        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_common("swichUsb : getPackage FAILED \n");
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF&&dataRec[1]!=0x55)
    {
        debug_common("swichUsb : check signature FAILED \n");

        error_msg += "swich: check sig err\n";
        return FAILED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);
    if(len + 3 != sizeof(dataRec))
    {
        debug_common("swichUsb : check len FAILED \n");

        error_msg += "swich: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("swichUsb : check sum FAILED \n");

        error_msg += "swich: check sum err\n";
        return ERR_CHECKSUM;
    }
    //check code , status, module
    if(dataRec[CODE_OFF]!= CM_SWITCH_USB ||
            dataRec[MODULE_OFF]!= moduleId ||
            dataRec[STATUS_OFF]!= 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("swichUsb: FW check sum FAILED \n");

            error_msg += "swich: FW check sum err\n";
            return ERR_CHECKSUM;
        }

        debug_common("swichUsb : check code/ module Id/ status FAILED \n");

        error_msg += "swich: check code/status err\n";
        return FAILED;
    }
    return SUCCESS;
}

////////////////////////////////////////////////////////////////////////////
//
unsigned short Protocol::upgradeFw(unsigned char moduleId)
{
    unsigned short res = 0;  //result
    unsigned short timeOut = 2000;
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

    unsigned  char dataRec[10]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_UPGRADE_FW;
    dataSend[MODULE_OFF]= moduleId;
    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {
        debug_common("upgradeFw: sendPackage FAILED \n");
        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_common("upgradeFw : getPackage FAILED \n");
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("upgradeFw : getPackage check signature FAILED \n");
        error_msg += "upg fw: check sig err\n";
        return FAILED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

    if(len + 3 != sizeof(dataRec))
    {
        debug_common("upgradeFw : getPackage len = %d \n", len);
        debug_common("upgradeFw : getPackage check len FAILED \n");

        error_msg += "upg fw: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("upgradeFw : getPackage check sum FAILED \n");

        error_msg += "upg fw: check sum err\n";
        return ERR_CHECKSUM;
    }

    //check code , status, module
    if(dataRec[CODE_OFF]!= CM_UPGRADE_FW ||
            dataRec[MODULE_OFF]!= moduleId ||
            dataRec[STATUS_OFF]!= 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("upgradeFw: FW check sum FAILED \n");

            error_msg += "upg fw: FW check sum err\n";
            return ERR_CHECKSUM;
        }
        debug_common("upgradeFw : check code/ module Id/ status FAILED \n");

        error_msg += "upg fw: check code/status err\n";
        return FAILED;
    }

    return SUCCESS;
}

////////////////////////////////////////////////////////////////////////////
//
unsigned short Protocol::startUpgradeFw(unsigned char moduleId, unsigned long fwVersion, unsigned long totalByte, unsigned long sum32)
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

    unsigned  char dataRec[10]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_START_UGFW;
    dataSend[MODULE_OFF]= moduleId;

    set_nbyte_be((unsigned char*)dataSend, 0x08, 3, fwVersion);
    set_nbyte_be((unsigned char*)dataSend, 0x0B, 3, (unsigned short)totalByte);
    set_ulong_be((unsigned char*)dataSend, 0x0E, sum32);

    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;

    res = this->sendPackage(dataSend,len);

    if(res != SUCCESS)
    {
        debug_common("startUpgradeFw: sendPackage FAILED \n");
        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_common("startUpgradeFw : getPackage FAILED \n");
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("startUpgradeFw : getPackage check signature FAILED \n");

        error_msg += "start upg fw: check sig err\n";
        return FAILED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

    if(len + 3 != sizeof(dataRec))
    {
        debug_common("startUpgradeFw : len = %d \n", len);
        debug_common("startUpgradeFw : check len FAILED \n");
        printBuff08((unsigned char *)dataRec, len);
        error_msg += "start upg fw: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("startUpgradeFw : check sum FAILED \n");

        error_msg += "start upg fw: check sum err\n";
        return ERR_CHECKSUM;
    }
    //check code , status, module
    printBuff08((unsigned char *)dataRec, len);
    if(dataRec[CODE_OFF]!= CM_START_UGFW ||
            dataRec[MODULE_OFF]!= moduleId ||
            dataRec[STATUS_OFF]!= 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("startUpgradeFw: FW check sum FAILED \n");

            error_msg += "start upg fw: FW check sum err\n";
            return ERR_CHECKSUM;
        }
        debug_common("startUpgradeFw : check code/ module Id/ status FAILED \n");

        error_msg += "start upg fw: check code/status err\n";
        return FAILED;
    }

    return SUCCESS;
}

////////////////////////////////////////////////////////////////////////////
//
unsigned short Protocol::sendUpgradeFw(unsigned char moduleId, unsigned short addrPage, unsigned char * dataUpgrade, unsigned short dataLen)
{
    unsigned short res = SUCCESS;  //result
    unsigned short timeOut = 1000;
    unsigned short len = 0, len_send = 0;

    unsigned char sum = 0;

    unsigned char dataSend[600] = {0};
    unsigned char dataRec[10]= {0};

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
    dataSend[MODULE_OFF]= moduleId;
    set_ushort_be((unsigned char*)dataSend, ADDR_PAGE_OFF,addrPage);
    memcpy(dataSend + FW_CONTENT_OFF,dataUpgrade,dataLen);

    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;

    res = this->sendPackage(dataSend,len);
    len_send = len;
    if(res != SUCCESS)
    {
        debug_common("sendUpgradeFw: sendPackage FAILED \n");

        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut, &readLen);
    qDebug() << "=============== readLen = " << readLen;
    int cnt = 0;
    bool result = true;

    if(res != SUCCESS)
    {
        result = false;
        memset(dataRec1, 0x00, sizeof(dataRec1));
        for(int retry = 0; retry < 3; retry++)
        {
            memcpy(dataRec1 + cnt, dataRec, readLen);
            cnt += readLen;
            if(cnt >= len)
            {
                result = true;
                memset(dataRec, 0x00, sizeof(dataRec));
                memcpy(dataRec, dataRec1, len);
                break;
            }
            fprintf(stderr, "BBBBBBBBBB getPackage retry = %d \n", retry );
            printBuff08((unsigned char *)dataRec1, cnt);


            res = this->sendPackage(dataSend, len_send);

            if(res != SUCCESS)
            {
                debug_common("sendUpgradeFw: sendPackage FAILED \n");
                return res;
            }
            readLen = 0;
            memset(dataRec, 0x00, sizeof(dataRec));
            len = sizeof(dataRec);
            res = this->getPackage(dataRec, len, timeOut, &readLen);
            qDebug() << "=============== readLen = " << readLen;

        }

        fprintf(stderr, "AAAAAAAAAAAAAA getPackage : \n");
        printBuff08((unsigned char *)dataRec, len);

    }
    if(result == false)
    {
        debug_common("sendUpgradeFw : getPackage FAILED \n");
        return res;
    }

    //check signature
    if(dataRec[0] != 0xFF && dataRec[1] != 0x55)
    {
        debug_common("sendUpgradeFw : check signature FAILED \n");

        error_msg += "send upg fw: check sig err\n";
        return FAILED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

    if(len + 3 != sizeof(dataRec))
    {
        debug_common("sendUpgradeFw : len = %d \n", len);
        debug_common("sendUpgradeFw : check len FAILED \n");
        printBuff08((unsigned char *)dataRec, len);

        error_msg += "send upg fw: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("sendUpgradeFw : check sum FAILED \n");
        printBuff08((unsigned char *)dataRec, len);

        error_msg += "send upg fw: check sum err\n";
        return ERR_CHECKSUM;
    }
    fprintf(stderr, "AAAAAAAAAAAAAA getPackage : \n");
    printBuff08((unsigned char *)dataRec, len);
    //check code , status, module
    if(dataRec[CODE_OFF] != CM_SEND_UGFW ||
            dataRec[MODULE_OFF] != moduleId ||
            dataRec[STATUS_OFF] != 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("sendUpgradeFw: FW check sum FAILED \n");

            error_msg += "send upg fw: FW check sum err\n";
            return ERR_CHECKSUM;
        }
        debug_common("sendUpgradeFw : check code/ module Id/ status FAILED \n");

        error_msg += "send upg fw: check code/status err\n";
        return FAILED;
    }

    return SUCCESS;
}
////////////////////////////////////////////////////////////////////////////
//
unsigned short Protocol::finishUpgradeFw(unsigned char moduleId)
{
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

    unsigned char dataRec[10]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_FINISH_UGFW;
    dataSend[MODULE_OFF]= moduleId;

    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);

    if(res != SUCCESS)
    {
        debug_common("finishUpgradeFw: sendPackage FAILED \n");

        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_common("finishUpgradeFw : getPackage FAILED\n");
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("finishUpgradeFw : check signature FAILED \n");
        error_msg += "finish upg fw: check sig err\n";
        return FAILED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

    if(len + 3 != sizeof(dataRec))
    {
        debug_common("finishUpgradeFw : len = %d \n", len);
        debug_common("finishUpgradeFw : check len FAILED \n");

        error_msg += "finish upg fw: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("finishUpgradeFw : check sum FAILED \n");

        error_msg += "finish upg fw: check sum err\n";
        return ERR_CHECKSUM;
    }
    //check code , status, module
    if(dataRec[CODE_OFF]!= CM_FINISH_UGFW ||
            dataRec[MODULE_OFF]!= moduleId ||
            dataRec[STATUS_OFF]!= 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("finishUpgradeFw: FW check sum FAILED \n");

            error_msg += "finish upg fw: FW check sum err\n";
            return ERR_CHECKSUM;
        }
        debug_common("finishUpgradeFw : check code/ module Id/ status FAILED \n");

        error_msg += "finish upg fw: check code/status err\n";
        return FAILED;
    }

    return SUCCESS;
}

////////////////////////////////////////////////////////////////////////////
//
bool Protocol::sendCommand(command_info *cmd)
{

    unsigned short code = 0;
    unsigned short moduleID = 0;
    unsigned char deviceType[8];
    unsigned char deviceList[8];
    unsigned char batteryPercent[8];
    unsigned char controlMode[8];
    unsigned char hub_usb = 0;

    unsigned short res = 0;
    //    debug_common("sendCommand : sendCommand============== \n");
    memset(deviceType,NO_DEVICE,sizeof(deviceType));
    memset(deviceList,0x00,sizeof(deviceList));
    memset(batteryPercent,0x00,sizeof(batteryPercent));
    memset(controlMode,0x00,sizeof(controlMode));

    error_msg = "";

    code = cmd->job_code;
    moduleID = cmd->module_index;
    //    debug_common("sendCommand : module_index = %d\n",moduleID);

    if(cmd->cell_index > 7)
    {
        debug_common("sendCommand : cell index invalid\n");
        error_msg += "sendCommand: err cell > 7";
        return false;
    }
    deviceList[cmd->cell_index] = 1;
    deviceType[cmd->cell_index] = cmd->device_type;
    batteryPercent[cmd->cell_index] = cmd->battery_percent;
    controlMode[cmd->cell_index] = cmd->control_mode;

    switch(code)
    {
    case START_TEST_JOB:
        res = this->startTest(moduleID, deviceType, deviceList);
        if((res == TIME_OUT) || (res == ERR_CHECKSUM))
        {
            res = this->startTest(moduleID, deviceType, deviceList);
        }
        break;

    case TESTING_JOB:
        res = this->testing(moduleID, deviceType, deviceList);
        if((res == TIME_OUT)||(res == ERR_CHECKSUM))
        {
            res = this->testing(moduleID, deviceType, deviceList);
        }
        break;

    case STOP_TEST_JOB:
        res = this->stopTest(moduleID, deviceList);
        if((res == TIME_OUT) || (res == ERR_CHECKSUM))
        {
            res = this->stopTest(moduleID, deviceList);
        }
        break;

    case SWITCH_USB:
        res = this->swichUsb(moduleID, controlMode);
        if((res == TIME_OUT) || (res == ERR_CHECKSUM))
        {
            res = this->swichUsb(moduleID ,controlMode);
        }
        break;

    case RESET_USB_HUB:
        if(cmd->cell_index > 3)
        {
            hub_usb = 1;
        }
        res = this->resetUsbHub(moduleID, hub_usb);
        if((res == TIME_OUT) || (res == ERR_CHECKSUM))
        {
            res = this->resetUsbHub(moduleID, hub_usb);
        }
        break;

    case SWITCH_DEVICE_PLUGGED_JOB:
        res = this->switchDevicePlugged(moduleID,deviceList);
        if((res == TIME_OUT) || (res == ERR_CHECKSUM))
        {
            res = this->switchDevicePlugged(moduleID,deviceList);
        }
        break;
    case POWER_OFF_JOB:

        res = this->powerOff(moduleID, deviceList, batteryPercent, deviceType);
        if((res == TIME_OUT) || (res == ERR_CHECKSUM))
        {
            res = this->powerOff(moduleID, deviceList, batteryPercent, deviceType);
        }
        break;

    case CHANGE_CRITERIA:

        res = this->changeCriteria(moduleID, deviceType, batteryPercent);
        if((res == TIME_OUT) || (res == ERR_CHECKSUM))
        {
            res = this->changeCriteria(moduleID, deviceType, batteryPercent);
        }
        break;

    case LED_CONTROL_JOB:

        res = this->ledControl(moduleID, controlMode);
        if((res == TIME_OUT) || (res == ERR_CHECKSUM))
        {
            res = this->ledControl(moduleID, controlMode);
        }
        break;
    }

    if(res != SUCCESS)
    {
        return false;
    }

    return true;

}
////////////////////////////////////////////////////////////////////////////
//
bool Protocol::upgradeFirmware(command_info cmd, QString filename)
{
    char * name = NULL;
    int size = 0, countbyte = 0;
    unsigned short addr = 0;

    //unsigned char buff[700000];//
    unsigned char* buff = NULL;
    unsigned int crc32sum = 1;
    unsigned int crc32verify = 0;
    unsigned int temp;
    qDebug()<<"-----------------QQQQQQQQQQQQQQQQQQQ-------------sizeofunsigned long"<<sizeof(crc32verify)<<"sizeofint"<< sizeof(temp);
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

    QString error_msg = "";


    moduleID = cmd.module_index;
    name = (char *)filename.toLatin1().data();
    file = fopen(name, "rb");
    if (file == NULL)
    {
        qDebug() << "open file upg fw err\n";
        error_msg += "open file upg fw err\n";
        return false;
    }
    fseek(file, 0, SEEK_END);
    size = ftell(file);
    if(size < 0)
    {
        qDebug() << "open file upg fw ftell \n";
        error_msg += "open file upg fw err\n";
        return false;
    }

    if(size > 700000)
    {
        qDebug() << "upgradeFirmware : file so large\n";
        error_msg += "file upg fw so large\n";
        return false;
    }

    buff = (unsigned char*) malloc(max_len);
    if (buff == NULL)
    {
        qDebug() << "upgradeFirmware : ERROR: Out of memory\n";
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

        if (cnt != (unsigned int) size_read)
        {
            qDebug() << "Error reading filesystem\n";
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
        qDebug() << "size_crc = " << size_crc;

        for(count = 0; count < size_crc; count++)
        {
            data = buff[count];
            crc = (crc >> 8) ^ table[(crc ^ data) & 0xFF];
        }
    }
    crc32sum = ~crc;
    qDebug() << "crc32sum = " << crc32sum;
    qDebug() << "crc32verify = " << crc32verify;

    if(crc32sum != crc32verify)
    {
        debug_common("upgradeFirmware : file error !\n");
        error_msg += "file upg fw checksum err\n";
        return false;
    }

    for(int i = 0; i < 5; i++)
    {
        res = this->upgradeFw(moduleID);
        if(res == SUCCESS)
        {
            break;
        }
    }

    if(res!= SUCCESS)
    {
        error_msg += "upg FW err\n";
        return false;
    }
    process_fw = 0;
    sleep(2);//2 s

    res = this->startUpgradeFw(moduleID, fw_version, size - 4, crc32sum);

    if((res== TIME_OUT) || (res== ERR_CHECKSUM))
    {
        res = this->startUpgradeFw(moduleID, fw_version, size - 4, crc32sum);
    }

    if(res!= SUCCESS)
    {
        error_msg += "start upg FW err\n";
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
        qDebug() << "upgradeFirmware : ERROR: Out of memory\n";
        return false;
    }
    memset(buff, 0xFF, max_len);
    fseek(file, 0, SEEK_SET);
    qDebug() << "upgradeFirmware : size " << size;

    for(i = size; i > 0; i -= max_len)
    {
        qDebug() << "1111111111111 i = " << i;
        size_read = max_len;
        if (i < max_len)
        {
            size_read = i;
        }
        memset(buff, 0xFF, max_len);
        cnt = fread(buff, 1, size_read, file);

        if (cnt != (unsigned int) size_read)
        {
            qDebug() << "Error reading filesystem\n";
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
            res = this->sendUpgradeFw(moduleID, addr, buff, size_read);
            if(res == SUCCESS)
            {
                break;
            }
            sleep(1);
        }


        if(res != SUCCESS)
        {
            error_msg += "send upg FW err\n";
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

    res = this->finishUpgradeFw(moduleID);

    if((res == TIME_OUT)||(res == ERR_CHECKSUM))
    {
        res = this->finishUpgradeFw(moduleID);
    }

    if(res!= SUCCESS)
    {
        error_msg += "finish upg FW err\n";
        return false;
    }
    sleep(2);
    return true;
}
////////////////////////////////////////////////////////////////////////////
//
bool Protocol::readAllStatus(QList<status_info*> *lists, int module_id, QString hwVersion)
{
    unsigned char moduleId = 0;
    unsigned char capInf[16];
    unsigned char currentInf[16];
    unsigned char timeInfo[16];
    unsigned char statusInfo[8];
    unsigned char timeRemain[16];
    unsigned char timeDischargeRemain[16];
    unsigned char buttonInfo[8];
    unsigned char ChargModeInfo[16];
    unsigned short res = 0; //result
    int cell = 0;
    status_info *module_status = NULL;

    error_msg = "";
    moduleId = module_id;

    memset(buttonInfo, 0, sizeof(buttonInfo));
    if(hwVersion.contains("4."))
    {
        res = this->updateInfoV2(moduleId, capInf, currentInf,
                               timeInfo, statusInfo, timeRemain,
                               timeDischargeRemain, buttonInfo, ChargModeInfo);

        if((res== TIME_OUT)||(res== ERR_CHECKSUM))
        {
            res = this->updateInfoV2(moduleId, capInf, currentInf,
                                   timeInfo, statusInfo, timeRemain,
                                   timeDischargeRemain, buttonInfo, ChargModeInfo);
        }
    }
    else
    {
        res = this->updateInfo(moduleId, capInf, currentInf,
                               timeInfo, statusInfo, timeRemain,
                               timeDischargeRemain, buttonInfo);

        if((res== TIME_OUT)||(res== ERR_CHECKSUM))
        {
            res = this->updateInfo(moduleId, capInf, currentInf,
                                   timeInfo, statusInfo, timeRemain,
                                   timeDischargeRemain, buttonInfo);
        }
    }

    if(res != SUCCESS)
    {
        return false;
    }

    for(cell = 0; cell < MAX_CELL_NUM; cell++)
    {
        module_status = new status_info();
        module_status->module_index = moduleId;
        module_status->cell_index = cell;
        module_status->pos_status = statusInfo[cell];

        module_status->button_status = buttonInfo[cell];


        module_status->capacities = get_ushort_be(capInf,cell*2);
        module_status->time_sec   = get_ushort_be(timeInfo,cell*2);
        module_status->current = get_ushort_be(currentInf,cell*2);
        module_status->remain_time   = get_ushort_be(timeRemain,cell*2);
        module_status->remain_discharge_time   = get_ushort_be(timeDischargeRemain,cell*2);

        lists->append(module_status);
    }

    return true;
}

////////////////////////////////////////////////////////////////////////////
//
unsigned short Protocol::switchDevicePlugged(unsigned char moduleId, unsigned char devList[8])
{
    unsigned short i = 0;
    unsigned short res = 0;  //result
    unsigned short timeOut = 3000;
    unsigned short len = 0;
    unsigned char sum = 0;

    unsigned char dataSend[17] = {
        0xFF, 0x55,
        0x00, 0x00,  // side
        0x00,        // command code
        0x00, 0x01,  // Dir, protocol version
        0x00,        // moduleId
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,// offset 8, idevice list
        0x00
    };

    unsigned char dataRec[10]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_SWITCH_DEVICE_PLUGGED;
    dataSend[MODULE_OFF]= moduleId;

    for(i = 0; i < 8; i++)
    {
        if(devList[i] == 1)
        {
            dataSend[8+i] = 1;
        }
    }

    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {
        debug_common("switchDevicePlugged: sendPackage FAILED \n");

        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_common("switchDevicePlugged : getPackage FAILED \n");
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("switchDevicePlugged : check signature FAILED \n");

        error_msg += "stop T: check sig err\n";
        return FAILED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

    if(len + 3 != sizeof(dataRec))
    {
        debug_common("switchDevicePlugged : len = %d \n", len);
        debug_common("switchDevicePlugged : check len FAILED \n");

        error_msg += "stop T: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("switchDevicePlugged : check sum FAILED \n");

        error_msg += "stop T: check sum err\n";
        return ERR_CHECKSUM;
    }

    //check code , status, module
    if(dataRec[CODE_OFF] != CM_SWITCH_DEVICE_PLUGGED ||
            dataRec[MODULE_OFF] != moduleId   ||
            dataRec[STATUS_OFF] != 0x01)
    {
        if(dataRec[STATUS_OFF] == 0x00)
        {
            debug_common("switchDevicePlugged: FW check sum FAILED \n");

            error_msg += "switchDevicePlugged T: FW check sum err\n";
            return ERR_CHECKSUM;
        }
        debug_common("switchDevicePlugged: check code/ module Id/ status FAILED \n");

        error_msg += "switchDevicePlugged T: check code/status err\n";
        return FAILED;
    }

    return SUCCESS;
}


unsigned short Protocol::powerOff(unsigned char moduleId,
                                  unsigned char devList[8],
unsigned char battery_percent[8],
unsigned char device_type[8])
{
    unsigned short i = 0;
    unsigned short res = 0;  //result
    unsigned short timeOut = 3000;
    unsigned short len = 0;
    unsigned char sum = 0;

    unsigned char dataSend[33] = {
        0xFF, 0x55,
        0x00, 0x00,  // side
        0x00,        // command code
        0x00, 0x01,  // Dir, protocol version
        0x00,        // moduleId
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,// offset 8, idevice list
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,// offset 16, Power percent
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,// offset 24, Power percent
        0x00
    };

    unsigned char dataRec[10]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_POWER_OFF;
    dataSend[MODULE_OFF]= moduleId;

    for(i = 0; i < 8; i++)
    {
        if(devList[i] == 1)
        {
            dataSend[8+i] = 1;
        }
    }
    for(i = 0; i < 8; i++)
    {
        if(devList[i] == 1)
        {
            dataSend[16 + i] = battery_percent[i];
        }
    }

    for(i = 0;i < 8; i++)
    {
        //if(device_type[i]== 1)
        //{
        dataSend[24+i]= device_type[i];
        //}
    }


    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {
        debug_common("powerOff: sendPackage FAILED \n");

        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_common("powerOff : getPackage FAILED \n");
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("powerOff : check signature FAILED \n");

        error_msg += "stop T: check sig err\n";
        return FAILED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

    if(len + 3 != sizeof(dataRec))
    {
        debug_common("powerOff : len = %d \n", len);
        debug_common("powerOff : check len FAILED \n");

        error_msg += "stop T: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("powerOff : check sum FAILED \n");

        error_msg += "stop T: check sum err\n";
        return ERR_CHECKSUM;
    }

    //check code , status, module
    if(dataRec[CODE_OFF]!= CM_POWER_OFF ||
            dataRec[MODULE_OFF]!= moduleId   ||
            dataRec[STATUS_OFF]!= 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("powerOff: FW check sum FAILED \n");

            error_msg += "powerOff T: FW check sum err\n";
            return ERR_CHECKSUM;
        }
        debug_common("powerOff: check code/ module Id/ status FAILED \n");

        error_msg += "powerOff T: check code/status err\n";
        return FAILED;
    }

    return SUCCESS;
}


bool Protocol::reset_module(unsigned char moduleId)
{
    unsigned short res = 0;  //result
    unsigned short timeOut = 3000;
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

    unsigned char dataRec[10]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_RESET;
    dataSend[MODULE_OFF]= moduleId;




    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {
        debug_common("reset_module: sendPackage FAILED \n");

        return false;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_common("reset_module : getPackage FAILED \n");
        return false;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("reset_module : check signature FAILED \n");

        error_msg += "stop T: check sig err\n";
        return false;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

    if(len + 3 != sizeof(dataRec))
    {
        debug_common("reset_module : len = %d \n", len);
        debug_common("reset_module : check len FAILED \n");

        error_msg += "stop T: check len err\n";
        return false;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("reset_module : check sum FAILED \n");

        error_msg += "stop T: check sum err\n";
        return false;
    }

    //check code , status, module
    if(dataRec[CODE_OFF]!= CM_RESET ||
            dataRec[MODULE_OFF]!= moduleId   ||
            dataRec[STATUS_OFF]!= 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("reset_module: FW check sum FAILED \n");

            error_msg += "reset_module T: FW check sum err\n";
            return false;
        }
        debug_common("reset_module: check code/ module Id/ status FAILED \n");

        error_msg += "reset_module T: check code/status err\n";
        return false;
    }

    return true;
}


unsigned short Protocol::changeCriteria(unsigned char moduleId,
                                        unsigned char devList[8], unsigned char criteria[8])
{
    unsigned short i = 0;
    unsigned short res = 0;  //result
    unsigned short timeOut = 3000;
    unsigned short len = 0;
    unsigned char sum = 0;

    unsigned char dataSend[25] = {
        0xFF, 0x55,
        0x00, 0x00,  // side
        0x00,        // command code
        0x00, 0x01,  // Dir, protocol version
        0x00,        // moduleId
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,// offset 8, idevice list
        0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    };

    unsigned char dataRec[10]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_CHANGE_CRITERIA;
    dataSend[MODULE_OFF]= moduleId;

    for(i = 0; i < 8; i++)
    {

        dataSend[8 + i] = devList[i];

    }

    for(i = 0; i < 8; i++)
    {
        dataSend[16 + i] = criteria[i];

    }

    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {
        debug_common("changeCriteria: sendPackage FAILED \n");

        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_common("changeCriteria : getPackage FAILED \n");
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("switchDevicePlugged : check signature FAILED \n");

        error_msg += "stop T: check sig err\n";
        return FAILED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

    if(len + 3 != sizeof(dataRec))
    {
        debug_common("changeCriteria : len = %d \n", len);
        debug_common("changeCriteria : check len FAILED \n");

        error_msg += "stop T: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("changeCriteria : check sum FAILED \n");

        error_msg += "stop T: check sum err\n";
        return ERR_CHECKSUM;
    }

    //check code , status, module
    if(dataRec[CODE_OFF]!= CM_CHANGE_CRITERIA ||
            dataRec[MODULE_OFF]!= moduleId   ||
            dataRec[STATUS_OFF]!= 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("changeCriteria: FW check sum FAILED \n");

            error_msg += "changeCriteria T: FW check sum err\n";
            return ERR_CHECKSUM;
        }
        debug_common("changeCriteria: check code/ module Id/ status FAILED \n");

        error_msg += "changeCriteria T: check code/status err\n";
        return FAILED;
    }

    return SUCCESS;
}



unsigned short Protocol::resetUsbHub(unsigned char moduleId, unsigned char hub_pos)
{
    unsigned short res = 0;  //result
    unsigned short timeOut = 4000;
    unsigned short len = 0;
    unsigned char sum = 0;

    unsigned char dataSend[10] = {
        0xFF, 0x55,
        0x00, 0x00,  // side
        0x00,        // command code
        0x00, 0x01,  // Dir, protocol version
        0x00,        // moduleId
        0x00,        // hub pos
        0x00        // checksum

    };

    unsigned char dataRec[10]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_RESET_USB_HUB;
    dataSend[MODULE_OFF]= moduleId;
    dataSend[8] = hub_pos;


    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {
        debug_common("switchUsbHub: sendPackage FAILED \n");
        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_common("switchUsbHub : getPackage FAILED \n");
        return res;
    }

    //check signature
    if(dataRec[0] != 0xFF && dataRec[1] != 0x55)
    {
        debug_common("switchUsbHub : check signature FAILED \n");

        error_msg += "connectUsb: check sig err\n";
        return FAILED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);
    if(len + 3 != sizeof(dataRec))
    {
        debug_common("switchUsbHub : check len FAILED \n");

        error_msg += "switchUsbHub: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("switchUsbHub : check sum FAILED \n");

        error_msg += "switchUsbHub: check sum err\n";
        return ERR_CHECKSUM;
    }
    //check code , status, module
    if(dataRec[CODE_OFF]!= CM_RESET_USB_HUB ||
            dataRec[MODULE_OFF]!= moduleId ||
            dataRec[STATUS_OFF]!= 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("connectUsb: FW check sum FAILED \n");

            error_msg += "connectUsb: FW check sum err\n";
            return ERR_CHECKSUM;
        }

        debug_common("connectUsb : check code/ module Id/ status FAILED \n");

        error_msg += "connectUsb: check code/status err\n";
        return FAILED;
    }

    //memcpy(positList,dataRec+9,8);

    return SUCCESS;
}
bool Protocol::setSWID(unsigned char moduleId, unsigned char SW_ID)
{
    unsigned short res = 0;  //result
    unsigned short timeOut = 4000;
    unsigned short len = 0;
    unsigned char sum = 0;

    unsigned char dataSend[10] = {
        0xFF, 0x55,
        0x00, 0x00,  // side
        0x00,        // command code
        0x00, 0x01,  // Dir, protocol version
        0x00,        // moduleId
        0x00,        // SW_ID
        0x00        // checksum
    };

    unsigned char dataRec[10]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_SET_SW_ID;
    dataSend[MODULE_OFF]= moduleId;
    dataSend[POSITION_OFF]= SW_ID;


    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {
        debug_common("setSWID: sendPackage FAILED \n");
        return false;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_common("setSWID : getPackage FAILED \n");
        return false;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("setSWID : check signature FAILED \n");

        error_msg += "setSWID: check sig err\n";
        return false;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);
    if(len + 3 != sizeof(dataRec))
    {
        debug_common("setSWID : check len FAILED \n");

        error_msg += "setSWID: check len err\n";
        return false;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("setSWID : check sum FAILED \n");

        error_msg += "setSWID: check sum err\n";
        return false;
    }
    //check code , status, module
    if(dataRec[CODE_OFF]!= CM_SET_SW_ID ||
            dataRec[MODULE_OFF]!= moduleId ||
            dataRec[STATUS_OFF]!= 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("setSWID: FW check sum FAILED \n");

            error_msg += "setSWID: FW check sum err\n";
            return false;
        }

        debug_common("setSWID : check code/ module Id/ status FAILED \n");

        // error_msg += "setSWID: check code/status err \n" + QString(dataRec);
        return false;
    }
    return true;
}


unsigned short Protocol::ledControl(unsigned char moduleId, unsigned char LEDMode[8])
{
    unsigned short i = 0;
    unsigned short res = 0;  //result
    unsigned short timeOut = 3000;
    unsigned short len = 0;
    unsigned char sum = 0;

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
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_SET_LED;
    dataSend[MODULE_OFF]= moduleId;

    for(i = 0; i < 8; i++)
    {
        dataSend[8 + i] = LEDMode[i];
    }

    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {
        debug_common("ledControl: sendPackage FAILED \n");
        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_common("ledControl : getPackage FAILED \n");
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("ledControl : check signature FAILED \n");

        error_msg += "ledControl: check sig err\n";
        return FAILED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

    if(len + 3 != sizeof(dataRec))
    {
        debug_common("ledControl : len = %d \n", len);
        debug_common("ledControl : check len FAILED \n");

        error_msg += "ledControl: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("switchDevicePlugged : check sum FAILED \n");

        error_msg += "ledControl: check sum err\n";
        return ERR_CHECKSUM;
    }

    //check code , status, module
    if(dataRec[CODE_OFF] != CM_SET_LED ||
            dataRec[MODULE_OFF] != moduleId ||
            dataRec[STATUS_OFF] != 0x01)
    {
        if(dataRec[STATUS_OFF] == 0x00)
        {
            debug_common("ledControl: FW check sum FAILED \n");

            error_msg += "ledControl T: FW check sum err\n";
            return ERR_CHECKSUM;
        }
        debug_common("ledControl: check code/ module Id/ status FAILED \n");

        error_msg += "ledControl T: check code/status err\n";
        return FAILED;
    }

    return SUCCESS;
}

/**
 * @brief Protocol::readKeyEvent
 * @param moduleId
 * @param buttonInfo
 * @param deviceInfo
 * @return
 */
unsigned short Protocol::readKeyEvent(unsigned char moduleId,
                                      unsigned char *buttonInfo,
                                      unsigned char *deviceInfo)
{
    unsigned short res = 0;  //result
    unsigned short timeOut = 2000;
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

    unsigned char dataRec[26]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CM_READ_BUTTON_EVENT;
    dataSend[MODULE_OFF] = moduleId;


    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {
        debug_error("%s[ERROR]%s readKeyEvent -> sendPackage FAILED moduleId = %d \n", KRED, RESET, moduleId);
        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_error("%s[ERROR]%s readKeyEvent -> getPackage FAILED moduleId = %d \n", KRED, RESET, moduleId);
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_error("%s[ERROR]%s readKeyEvent -> gcheck signature FAILED moduleId = %d \n", KRED, RESET, moduleId);
        error_msg += "upd inf: check sig err\n";
        return FAILED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

    if(len + 3 != sizeof(dataRec))
    {
        debug_error("%s[ERROR]%s readKeyEvent -> check len FAILED moduleId = %d \n", KRED, RESET, moduleId);
        error_msg += "readKeyEvent: check len err\n";
        return FAILED;
    }

    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_error("%s[ERROR]%s readKeyEvent -> check sum FAILED moduleId = %d \n", KRED, RESET, moduleId);
        error_msg += "readKeyEvent: check sum err\n";
        return ERR_CHECKSUM;
    }
    //check code , status, module
    if(dataRec[CODE_OFF] != CM_READ_BUTTON_EVENT ||
            dataRec[MODULE_OFF] != moduleId ||
            dataRec[STATUS_OFF] != 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_error("%s[ERROR]%s readKeyEvent -> FW check sum FAILED moduleId = %d \n", KRED, RESET, moduleId);
            error_msg += "readKeyEvent: FW check sum err\n";
            return ERR_CHECKSUM;
        }

        debug_error("%s[ERROR]%s readKeyEvent -> heck code/ module Id/ status FAILED moduleId = %d \n", KRED, RESET, moduleId);
        error_msg += "readKeyEvent: FW check code/status err\n";
        return FAILED;
    }

    memcpy(buttonInfo, dataRec + 9, 8);
    memcpy(deviceInfo, dataRec + 17, 8);
    return SUCCESS;
}

/**
 * @brief Protocol::read_seria_number
 * @param moduleID
 * @param seria_number
 * @return
 */
unsigned short Protocol::read_seria_number(unsigned char moduleID ,unsigned char  *seria_number)
{
    unsigned short res = 0;  //result
    unsigned short timeOut = 2000;
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

    unsigned char dataRec[35]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CMD_CHECK_SN;
    dataSend[MODULE_OFF] = moduleID;


    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {
        //debug_common("THDB here: read_seria_number: sendPackage FAILED \n");
        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    if(res != SUCCESS)
    {
        debug_common("THDB here: read_seria_number: getPackage FAILED moduleId = %d \n", moduleID);
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("THDB here: read_seria_number: check signature FAILED \n");
        error_msg += "upd inf: check sig err\n";
        return FAILED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

    if(len + 3 != sizeof(dataRec))
    {
        debug_common("THDB here: read_seria_number: check len FAILED \n");
        error_msg += "read_seria_number: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common("THDB here: read_seria_number: check sum FAILED \n");
        error_msg += "read_seria_number: check sum err\n";
        return ERR_CHECKSUM;
    }
    //check code , status, module
    if(dataRec[CODE_OFF] != CMD_CHECK_SN ||
            dataRec[MODULE_OFF] != moduleID ||
            dataRec[STATUS_OFF] != 0x01)
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("THDB here: read_seria_number: FW check sum FAILED \n");
            error_msg += "read_seria_number: FW check sum err\n";
            return ERR_CHECKSUM;
        }

        debug_common("THDB here: read_seria_number: check code/ module Id/ status FAILED \n");
        error_msg += "read_seria_number: FW check code/status err\n";
        return FAILED;
    }


    memcpy(seria_number, dataRec + 9, 25);

    serial_convert = convertSerialNumber(seria_number);
    //debug_common("THDB here: read_seria_number PASSED ############\n");
    return SUCCESS;
}

/**
 * @brief Protocol::convertSerialNumber
 * @param seria_number
 * @return
 */
unsigned short Protocol::convertSerialNumber(unsigned char *seria_number)
{    
    short i, startIndex;
    unsigned int a = 0;
    unsigned short retval = 0 ;

    if (seria_number == NULL)
    {
        debug_error("%s[ERROR]%s convertSerialNumber:: seria_number  IS NULL \n", KRED, RESET);
        return 0;
    }
    startIndex = 0;

    while ((seria_number[startIndex] == 32) && ((startIndex + 8) < 20))
    {
        startIndex++;
    }

    for (i = startIndex; i < (startIndex + 25); i++)
    {
        a = (unsigned int)(a << 4) + (unsigned int)(seria_number[i] % 16);
    }

    if ((a & 0x0000FFFF) != 0)
    {

        retval = (unsigned short)(a & 0x0000FFFF);
    }
    else
    {
        if (((a >> 16) & 0x0000FFFF) != 0)
            retval = (unsigned short)((a >> 16) & 0x0000FFFF);
    }

    debug_info("%s[DEBUG]%s convertSerialNumber:: RESULT = %u \n", KBLU, RESET, retval);
    return retval;
}

/**
 * @brief Protocol::readKeyPressFromFW
 * @param moduleId
 * @param list_status
 * @return
 */
bool Protocol::readKeyPressFromFW(unsigned char moduleId, QList<key_control_info *> *list_status)
{
    unsigned short res = 0;
    //bool isKeyPress = false;
    key_control_info *key_status = NULL;
    error_msg = "";
    unsigned char deviceInfo[8];
    unsigned char buttonInfo[8];
    memset(buttonInfo, 0, sizeof(buttonInfo));
    memset(deviceInfo, 0, sizeof(deviceInfo));
    res = this->readKeyEvent(moduleId, buttonInfo, deviceInfo);

    if((res== TIME_OUT)||(res== ERR_CHECKSUM))
    {
        res = this->readKeyEvent(moduleId, buttonInfo, deviceInfo);
    }

    if(res != SUCCESS)
    {
        return false;
    }

    // add detect sort USB
    unsigned char sortUSBInfo[8];
    res = detectShorted(moduleId, sortUSBInfo);

    for(int cell = 0; cell < MAX_CELL_NUM; cell++)
    {
        key_status = new key_control_info();
        key_status->module_index = moduleId;
        key_status->cell_index = cell;
        key_status->device_status = deviceInfo[cell];

        if(res == SUCCESS)
        {
            if(sortUSBInfo[cell] == 1) // sort
            {
                //fprintf(stderr,"\n ++++++++++++++++++ sort cell = %d ================ ",cell);
                key_status->device_status = 2;
            }
        }


        key_status->button_status = buttonInfo[cell];
        //        if(key_status->button_status == 1)
        //        {
        //            isKeyPress = true;
        //        }
        list_status->append(key_status);
    }
    //return isKeyPress;
    return true;
}

/* Send cmd tren nhieu cell
  Battery: start, stop
  ZeroIT: Fast charge, led, USB mode

  */
bool Protocol::sendCommandList(command_info cmd)
{
    int i = 0;
    unsigned short code = 0;
    unsigned short moduleID = 0;
    unsigned char deviceType[8];
    unsigned char deviceList[8];
    unsigned char batteryPercent[8];
    unsigned char controlMode[8];

    unsigned short res = 0;
    memset(deviceType,NO_DEVICE,sizeof(deviceType));
    memset(deviceList,0x00,sizeof(deviceList));
    memset(batteryPercent,0x00,sizeof(batteryPercent));
    memset(controlMode,0x00,sizeof(controlMode));

    if(cmd.is_multi_mode == 0)
    {
        debug_common("sendCommandList : ERROR is_multi_mode \n");
        error_msg = "sendCommandList : ERROR is_multi_mode \n";
        return false;
    }
    for(i = 0; i < MAX_CELL; i++)
    {
        deviceList[i] = cmd.position[i];
        controlMode[i] = cmd.mode[i];
    }

    error_msg = "";

    code = cmd.job_code;
    moduleID = cmd.module_index;
    debug_common(" qt debug here ...sendCommand : module_index = %d\n",moduleID);

    if(cmd.cell_index > 7)
    {
        debug_common("sendCommand : cell index invalid\n");
        error_msg += "sendCommand: err cell > 7";
        return false;
    }


    switch(code)
    {
    case START_TEST_JOB:
        res = this->startTest(moduleID, deviceType, deviceList);
        if((res == TIME_OUT) || (res == ERR_CHECKSUM))
        {
            res = this->startTest(moduleID, deviceType, deviceList);
        }
        break;

    case STOP_TEST_JOB:
        res = this->stopTest(moduleID, deviceList);
        if((res == TIME_OUT) || (res == ERR_CHECKSUM))
        {
            res = this->stopTest(moduleID, deviceList);
        }
        break;

    case SWITCH_USB:
        res = this->swichUsb(moduleID, controlMode);
        if((res == TIME_OUT) || (res == ERR_CHECKSUM))
        {
            res = this->swichUsb(moduleID ,controlMode);
        }
        break;

    case LED_CONTROL_JOB:

        res = this->ledControl(moduleID, controlMode);
        if((res == TIME_OUT) || (res == ERR_CHECKSUM))
        {
            res = this->ledControl(moduleID, controlMode);
        }
        break;
    }

    if(res != SUCCESS)
    {
        return false;
    }

    return true;

}
unsigned short Protocol::detectShorted(unsigned char moduleID ,unsigned char  *status)
{
    unsigned short res = 0;  //result
    unsigned short timeOut = 2000;
    unsigned short len = 0;
    unsigned char sum = 0;

    unsigned char dataSend[9] = {
        0xFF, 0x55,
        0x00, 0x06,  // side
        0x18,        // command code
        0x00, 0x01,  // Dir, protocol version
        0x00,        // moduleId
        0x00
    };

    unsigned char dataRec[18]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CMD_DETECT_SHORTED;
    dataSend[MODULE_OFF] = moduleID;


    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    //    qDebug()<<"QTDB here data send \n";
    //    for(int i = 0 ; i < 9 ; i ++)
    //    {
    //        fprintf(stderr,"%x",dataSend[i]);
    //    }
    //    qDebug()<<"\n";
    res = this->sendPackage(dataSend,len);
    if(res != SUCCESS)
    {

        debug_common("QTDB here detectShorted: sendPackage FAILED \n");
        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);
    res = this->getPackage(dataRec, len, timeOut);
    //    qDebug()<<"QTDB here data get: \n";
    //    for(int i = 0; i < 18 ; i++)
    //    {
    //     fprintf(stderr,"%x",dataRec[i]);
    //    }
    //    qDebug()<<"\n";
    if(res != SUCCESS)
    {
        debug_common("QTDB here detectShorted: getPackage FAILED moduleId = %d \n", moduleID);
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common(" QTDB here detectShorted: check signature FAILED \n");

        error_msg += "upd inf: check sig err\n";
        return FAILED;
    }

    //check len
    len = get_ushort_be((unsigned char*)dataRec,SIDE_OFF);

    if(len + 3 != sizeof(dataRec))
    {
        debug_common("QTDB here detectShorted: check len FAILED \n");

        error_msg += "readKeyEvent: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len);

    if(sum != (unsigned char)dataRec[len+2])
    {
        debug_common(" QTDB here detectShorted: check sum FAILED \n");

        error_msg += "readKeyEvent: check sum err\n";
        return ERR_CHECKSUM;
    }
    //check code , status, module
    if(dataRec[CODE_OFF] != CMD_DETECT_SHORTED ||
            dataRec[MODULE_OFF] != moduleID )
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("QTDB here detectShorted: FW check sum FAILED \n");
            error_msg += "readKeyEvent: FW check sum err\n";
            return ERR_CHECKSUM;
        }

        debug_common(" QTDB here detectShorted: check code/ module Id/ status FAILED \n");
        error_msg += "readKeyEvent: FW check code/status err\n";
        return FAILED;
    }
    memcpy(status, dataRec + 9, 8);
    return SUCCESS;
}
unsigned short Protocol::SWmic(unsigned char moduleID ,int mic_ID)
{
    //    qDebug()<<"QTDB here go to SWmic function here >>>>>>>>"<<mic_ID;
    unsigned short res = 0;  //result
    unsigned short timeOut = 2000;
    unsigned short len = 0;
    unsigned char sum = 0;



    //khoanguyen add for smic on 4 module
    if(mic_ID >= 24)
    {
        mic_ID = mic_ID - 24;
    }
    else if(mic_ID >= 16)
    {
        mic_ID = mic_ID - 16;
    }
    else if(mic_ID >= 8)
    {
        mic_ID = mic_ID - 8;
    }

    //

    unsigned char dataSend[10] = {
        0xFF, 0x55,
        0x00, 0x07,  // side
        0x17,        // command code
        0x00, 0x01,  // Dir, protocol version
        0x00,        // moduleId
        0x00,
        0x00
    };

    unsigned char dataRec[10]= {0};

    //send command
    len = sizeof(dataSend);
    set_ushort_be((unsigned char *)dataSend, SIDE_OFF, len-3);
    dataSend[CODE_OFF]  = CMD_SWITCH_MIC;
    dataSend[MODULE_OFF] = moduleID;
    dataSend[MIC_POSITION] = mic_ID;

    sum = this->calculateCRC((unsigned char *)dataSend + SIDE_OFF,len-3);
    dataSend[len-1] = (char)sum;
    //     qDebug()<<"QTDB here data send";
    //     for(int i = 0; i <10 ; i++)
    //     {
    //         fprintf(stderr,"%0x",dataSend[i]);
    //     }
    //     printBuff08((unsigned char*)dataSend,10);
    res = this->sendPackage(dataSend,len);
    //    qDebug()<<"KNDB Here: ######################## result send package\n";
    if(res != SUCCESS)
    {
        debug_common("set MIC swicth failed: sendPackage FAILED \n");
        return res;
    }

    //receive result
    memset(dataRec, 0x00, sizeof(dataRec));
    len = sizeof(dataRec);


    //     qDebug()<<"QTDB here data get from FW";


    res = this->getPackage(dataRec, len, timeOut);


    //    for(int i = 0; i <10 ; i++)
    //    {
    //        fprintf(stderr,"%0x",dataRec[i]);
    //    }
    //    printBuff08((unsigned char*)dataRec,10);
    if(res != SUCCESS)
    {
        debug_common("set MIC swicth failed: getPackage FAILED moduleId = %d \n", moduleID);
        return res;
    }

    //check signature
    if(dataRec[0]!=0xFF && dataRec[1]!=0x55)
    {
        debug_common("set MIC swicth failed: check signature FAILED \n");
        error_msg += "upd inf: check sig err\n";
        return FAILED;
    }

    //check len

    //    fprintf(stderr,"ddsfsdf %x",len);
    if(dataRec[8] == 0x00)
    {
        debug_common("set MIC swicth failed: check len FAILED \n");
        error_msg += "read_seria_number: check len err\n";
        return FAILED;
    }
    //check sum
    sum = this->calculateCRC((unsigned char*)dataRec+ SIDE_OFF,len-3);
    //qDebug()<< "lennnnnnnnnnnnnn" << sum <<"      "<<(unsigned char)dataRec[len-1];
    if(sum != (unsigned char)dataRec[len-1])
    {
        debug_common("THDB here: : check sum FAILED \n");
        error_msg += "read_seria_number: check sum err\n";
        return ERR_CHECKSUM;
    }
    //check code , status, module
    if(dataRec[CODE_OFF] != CMD_SWITCH_MIC ||
            dataRec[MODULE_OFF] != moduleID  )
    {
        if(dataRec[STATUS_OFF]== 0x00)
        {
            debug_common("CMD_SWITCH_MIC: FW check sum FAILED \n");
            error_msg += "W check sum err\n";
            return ERR_CHECKSUM;
        }

        debug_common("CMD_SWITCH_MIC: %d, %d\n", dataRec[MODULE_OFF], moduleID);
        debug_common("CMD_SWITCH_MIC: check code/ module Id/ status FAILED \n");
        error_msg += "FW check code/status err\n";
        return FAILED;
    }
    //    qDebug()<<"\n CMD_SWITCH_MIC: CUCCESS "<<mic_ID;
    return SUCCESS;
}
