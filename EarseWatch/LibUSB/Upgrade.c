////
////  Upgrade.c
////  iCombineMac
////
////  Created by Tri Nguyen on 08/11/2022.
////  Copyright © 2022 Greystone. All rights reserved.
////
//
//#include <string.h>
//#include "Upgrade.h"
//
//extern int portValue;
//
//unsigned long get_ulong_be(unsigned char *buf, unsigned long off)
//{
//    unsigned long value;
//    value = buf[off];
//    value = (value<<8)|buf[off+1];
//    value = (value<<8)|buf[off+2];
//    value = (value<<8)|buf[off+3];
//    return value;
//}
//
//unsigned short upgradeFw(unsigned char moduleId, int fileDescriptor)
//{
//    unsigned char cmd = CM_UPGRADE_FW;
//    unsigned char pl = '0';
//    
//    printf("Address of data: %p open port: %i\n", &pl, fileDescriptor);
//    
//    if(packet_send(moduleId, cmd, &pl, 0, fileDescriptor) == true)
//    {
//        printf("Send package successfully \n");
//    }
//    else
//    {
//        printf("Send package unsuccessfully \n");
//    }
//    
////    if (get_packet(5, fileDescriptor, 512) == false)
////    {
////        printf("Cannot get package \n");
////        return FWUNSUCCESS;
////    }
////    else
//    {
////        if (process_input_packet(cmd) == false)
////        {
////            fprintf(stderr, "[upgradeFw] Package not correct \n");
////            return FWUNSUCCESS;
////        }
//    }
//    
//    return FWSUCCESS;
//}
//
////unsigned char dataSend[9] = {
////    0xFF, 0x55,
////    0x00, 0x00,  // size
////    0x00,        // command code
////    0x00, 0x01,  // Dir, protocol version
////    0x00,         // moduleId
////    0x00
////};
//
//bool packet_send(unsigned char moduleID, unsigned char cmd, unsigned char *data, unsigned short len, int fileDescriptor)
//{
//    unsigned short packetLen = 0;
//    pack_send.Header = 0x55FF;
//    pack_send.CMD_Code = cmd;
//    pack_send.dir = 0;
//    pack_send.protocol_ver = 0x01;
//    pack_send.moduleID = moduleID;
//    packetLen = 6+len;
//    
//    if(cmd == CM_SEND_UGFW)
//    {
//        len = 292;
//    }
//    
//    set_ushort_be((unsigned char*)&pack_send.Length, 0, packetLen);
//    
//    memcpy((unsigned char*)&pack_send.Payload[0], data, len);
//    
//    *((unsigned char*)&pack_send + packetLen + 2) = Serial_package_check_checksum((unsigned char*)&pack_send + 2, packetLen);
//    
//    rx_buffer_len_temp = 0;
//    rx_buffer_len = 0;
//    
//    write(fileDescriptor, (unsigned char *)&pack_send, packetLen+3);
//    printf("\n---------------- Send data -------------- \n");
//    showDebugPackage((unsigned char *)&pack_send, packetLen+3);
//    printf("\n---------------- End send data -------------- \n");
//    return true;
//}
//
//void set_ushort_be(unsigned char *buf, unsigned long off, unsigned short value)
//{
//    buf[off]   = value >> 8;
//    buf[off+1] = value&0xFF;
//}
//
//void set_ulong_be(unsigned char *buf, unsigned long off, unsigned long value)
//{
//    buf[off]   = value >> 24;
//    buf[off+1] = value >> 16;
//    buf[off+2] = value >> 8;
//    buf[off+3] = value&0xFF;
//}
//
//unsigned char Serial_package_check_checksum(unsigned char *packageBuffer, int packageSize)
//{
//    unsigned char result;
//    int i;
//    result = 0;
//    
//    for(i = 0; i < (packageSize+1); i++)
//    {
//        result += packageBuffer[i];
//    }
//    
//    printf("checksum result: %c", result);
//    
//    return result;
//}
//
//bool get_packet(unsigned int timeout, int fileDescriptor, unsigned short len)
//{
//    ssize_t numBytePackageGet = 0;
//    unsigned int count = 0;
//    unsigned int desire_len = 1000;
//    timeout *= 1000;
//    
//    while (count < timeout)
//    {
//        numBytePackageGet += read(fileDescriptor, (unsigned char *)&pack_get, len);
//        
//        printf("------------------ Get data ------------------- \n");
//        showDebugPackage((unsigned char *)&pack_get, len);
//        
//        printf("Number of byte of package get: %zd \n", numBytePackageGet);
//        if(numBytePackageGet != -1)
//        {
//            printf("Get packet from firmware success! \n");
//            return true;
//        }
//        
//        //        if (rx_buffer_len > 4)
//        //        {
//        //            desire_len = rx_buffer[2]*256 + rx_buffer[3];
//        //        }
//        //
//        //        if (rx_buffer_len >= desire_len+3)
//        //        {
//        //            memcpy((unsigned char *)&pack_get, rx_buffer, rx_buffer_len);
//        //            return true;
//        //        }
//        
//        usleep(5000);
//        count += 5;
//    }
//    
//    return false;
//}
//
//bool process_input_packet(unsigned char opcode)
//{
//    printf("packet opcode: %d\n", opcode);
//    printf("pack_get.CMD_Code: %d\n", pack_get.CMD_Code);
//    printf("pack_get.Header: %d\n", pack_get.Header);
//    printf("pack_get.Payload: %d\n", pack_get.Payload[0]);
//    
//    int packLen;
//    unsigned char buff[2];
//    if ((pack_get.Header == 0x55FF) && (pack_get.CMD_Code == opcode))
//    {
//        set_ushort_be(buff, 0, pack_get.Length);
//        packLen = buff[1]*256 + buff[0];
//        printf("Packet lenght: %d\n", packLen);
//        if(Serial_package_check_checksum((unsigned char*)&pack_get + 2, packLen) == 0)
//        {
//            if (pack_get.Payload[0] == 1)
//                return true;
//        }
//        else
//        {
//            fprintf(stderr, "process_input_packet: failed checksum \n");
//        }
//    }
//    
//    return false;
//}
//
//unsigned short startUpgradeFw(unsigned char moduleId, unsigned long fwVersion, unsigned long totalByte, unsigned long sum32, int fileDescriptor)
//{
//    printf("Start upgrade firmware");
//    printf("Start upgrade firmware - totalByte: %lu \n", totalByte);
//    unsigned char cmd = CM_START_UGFW;
//    
//    set_nbyte_be((unsigned char*)&payload_start_upgrade, 0x08, 3, fwVersion);
//    set_nbyte_be((unsigned char*)&payload_start_upgrade, 0x0B, 3, totalByte);
//    set_ulong_be((unsigned char*)&payload_start_upgrade, 0x0E, sum32);
//    
//    packet_send(moduleId, cmd, (unsigned char*)&payload_start_upgrade, sizeof(payload_start_upgrade), fileDescriptor);
//    
////    if (get_packet(5, fileDescriptor, sizeof(payload_start_upgrade)) == false)
////    {
////        return FWUNSUCCESS;
////    }
////    else
////    {
////        if (process_input_packet(cmd) == false)
////        {
////            printf("Cannot inut PK \n");
////            return FWUNSUCCESS;
////        }
////    }
//    
//    return FWSUCCESS;
//}
//
//void set_nbyte_be(unsigned char *buf, unsigned long off, unsigned char numByte, unsigned long long value)
//{
//    unsigned char i = 0;
//    for(i=0; i < numByte; i++)
//    {
//        buf[off+i] = (value >> 8*(numByte-i-1)) & 0xFF;
//    }
//}
//
//unsigned short sendUpgradeFw(unsigned char moduleId, unsigned short addrPage, unsigned char *dataUpgrade, unsigned short dataLen, int fileDescriptor)
//{
//    printf("Start send data upgrade firmware \n");
//    unsigned char cmd = CM_SEND_UGFW;
//    
//    set_ushort_be((unsigned char*)&payload_send_upgrade, 0, addrPage);
//    memset((unsigned char*)&payload_send_upgrade.data, 0xFF, sizeof(payload_send_upgrade.data));
//    memcpy((unsigned char*)&payload_send_upgrade.data, dataUpgrade, dataLen);
//    
//    printf("Size of payload_send_upgrade: %lu \n", sizeof(payload_send_upgrade));
//    packet_send(moduleId, cmd, (unsigned char*)&payload_send_upgrade, sizeof(payload_send_upgrade), fileDescriptor);
//    
//    //    if (get_packet(5) == false)
//    //    {
//    //        printf("Cannot get package \n");
//    //        return FWUNSUCCESS;
//    //    }
//    //    else
////    {
////        if (process_input_packet(cmd) == false)
////        {
////            printf("Cannot input packet \n");
////            return FWUNSUCCESS;
////        }
////    }
//    
//    printf("Send data upgrade FW SUCCESSFULLY \n");
//    return FWSUCCESS;
//}
//
//unsigned short finishUpgradeFw(unsigned char moduleId, int fileDescriptor)
//{
//    printf("Finished upgrade firmware");
//    
//    unsigned char cmd = CM_FINISH_UGFW;
//    unsigned char pl = 0;
//    
//    packet_send(moduleId, cmd, &pl, 0, fileDescriptor);
//    
//    //    if (get_packet(5) == false)
//    //    {
//    //        return FWUNSUCCESS;
//    //    }
//    //    else
//    //    {
////    if (process_input_packet(cmd) == false)
////    {
////        printf("Could not inout PK \n");
////        return FWUNSUCCESS;
////    }
//    
//    return FWSUCCESS;
//}
//
//char* showDebugPackage(void* unk_buf, unsigned long byte_cnt)
//{
//    unsigned char* buf = (unsigned char*) unk_buf;
//    
//    fprintf(stderr, "\n--------------------------------------------------------------\n");
//    fprintf(stderr, " Offset |");
//    for (unsigned long i = 0x00000000; i <= 0x0000000F; i++)
//    {
//        if ((i % 8 == 0) && (i != 0))
//        {
//            fprintf(stderr, " ");
//        }
//        fprintf(stderr, "%2lX ", i);
//    }
//    fprintf(stderr, "\n--------------------------------------------------------------");
//    unsigned long off = 0x00000000;
//    fprintf(stderr, "\n%08lX |", off++);
//    unsigned long i = 0;
//    unsigned long sec_cnt = 0;
//    for (; i < byte_cnt; i++)
//    {
//        if (i % 8 == 0)
//        {
//            if (i != 0)
//            {
//                fprintf(stderr, " ");
//            }
//        }
//        if (i % 16 == 0)
//        {
//            if (i != 0)
//            {
//                fprintf(stderr, "| ");
//                unsigned long idx = 16;
//                for (unsigned long j = 1; j <= 16; j++)
//                {
//                    unsigned char c = buf[i - idx--];
//                    if (c >= 33 && c <= 126)
//                    {
//                        fprintf(stderr, "%c", c);
//                    }
//                    else
//                    {
//                        fprintf(stderr, ".");
//                    }
//                }
//                if (i % 512 == 0)
//                {
//                    fprintf(stderr, "\nSector %ld\n", ++sec_cnt);
//                }
//                fprintf(stderr, "\n%08lX |", off++);
//            }
//        }
//        fprintf(stderr, "%02X ", buf[i]);
//    }
//    fprintf(stderr, " | ");
//    unsigned long idx = 16;
//    for (unsigned long j = 1; j <= 16; j++)
//    {
//        unsigned char c = buf[i - idx--];
//        if (c >= 33 && c <= 126)
//        {
//            fprintf(stderr, "%c", c);
//        }
//        else
//        {
//            fprintf(stderr, ".");
//        }
//    }
//    
//    fprintf(stderr, "\n\n");
//    return (char*)"";
//}
//
