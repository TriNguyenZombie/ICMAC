////
////  Upgrade.h
////  iCombineMac
////
////  Created by Tri Nguyen on 08/11/2022.
////  Copyright © 2022 Greystone. All rights reserved.
////
//
//#ifndef Upgrade_h
//#define Upgrade_h
//
//#include <stdio.h>
//#include <stdbool.h>
//#include <unistd.h>
//#include <string.h>
//
//#define SERIAL_PACK_SIZE_MAX 300
//
//#define     FWSUCCESS                     0
//#define     FWUNSUCCESS                   1
//
//#define     CM_UPGRADE_FW                 0x07
//#define     CM_START_UGFW                 0x08
//#define     CM_SEND_UGFW                  0x09
//#define     CM_FINISH_UGFW                0x0A
//
//typedef struct _Package_struct_
//{
//    unsigned short Header;
//    unsigned short Length;
//    unsigned char CMD_Code;
//    unsigned char dir;
//    unsigned char protocol_ver;
//    unsigned char moduleID;
//    unsigned char Payload[SERIAL_PACK_SIZE_MAX - 8];
//    unsigned char checksum;
//} Package_struct_t;
//
//typedef struct _Payload_get_version_
//{
//    unsigned char       status;
//    unsigned char       FW_version[3];
//    unsigned char       HW_version[3];
//} Payload_get_version_t;
//
//typedef struct _Payload_get_status_
//{
//    unsigned char status;
//    unsigned char data[21];
//    unsigned char tca9555_config;
//    unsigned char i2c_device_total;
//    unsigned char i2c_dev_addr[12];
//} Payload_get_status_t;
//
//typedef struct _Payload_start_upgrade_
//{
//    unsigned char       FW_version[3];
//    unsigned char        FW_size[3];
//    unsigned char        FW_crc[4];
//} Payload_start_upgrade_t;
//
//typedef struct _Payload_send_upgrade_
//{
//    unsigned short  pageAddr;
//    unsigned char   data[512];
//} Payload_send_upgrade_t;
//
//Package_struct_t pack_get;
//Package_struct_t pack_send;
//
//unsigned char rx_buffer[SERIAL_PACK_SIZE_MAX];
//int rx_buffer_len_temp;
//int rx_buffer_len;
//
//Payload_get_version_t payload_get_version;
//Payload_start_upgrade_t payload_start_upgrade;
//Payload_send_upgrade_t payload_send_upgrade;
//Payload_get_status_t pl_get_status;
//
//void set_ushort_be(unsigned char *buf, unsigned long off, unsigned short value);
//void set_ulong_be(unsigned char *buf, unsigned long off, unsigned long value);
//void set_nbyte_be(unsigned char *buf, unsigned long off, unsigned char numByte, unsigned long long value);
//void write_port(char *buff, unsigned short len, int fileDescriptor);
//bool packet_send(unsigned char moduleID, unsigned char cmd, unsigned char *data, unsigned short len, int fileDescriptor);
//bool get_packet(unsigned int timeout, int fileDescriptor, unsigned short len);
//bool process_input_packet(unsigned char opcode);
//unsigned short upgradeFw(unsigned char moduleId, int fileDescriptor);
//unsigned short startUpgradeFw(unsigned char moduleId, unsigned long fwVersion, unsigned long totalByte, unsigned long sum32, int fileDescriptor);
//unsigned short sendUpgradeFw(unsigned char moduleId, unsigned short addrPage, unsigned char *dataUpgrade, unsigned short dataLen, int fileDescriptor);
//unsigned short finishUpgradeFw(unsigned char moduleId, int fileDescriptor);
//unsigned char Serial_package_check_checksum(unsigned char *packageBuffer, int packageSize);
//unsigned long get_ulong_be(unsigned char *buf, unsigned long off);
//char* showDebugPackage(void* unk_buf, unsigned long byte_cnt);
//
//#endif /* Upgrade_h */
