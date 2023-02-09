//
//  ProccessUSB.m
//  EarseMac
//
//  Created by Duyet Le on 12/27/21.
//  Copyright © 2021 Greystone. All rights reserved.
//https://sysadm.mielnet.pl/tag/idevicerestore/
#import "AppDelegate.h"
#import "ProccessUSB.h"
#import "libusb.h"

#define VID 0x04d8
#define PID 0x005e
#define CDC_DATA_INTERFACE_ID 2

@implementation ProccessUSB
- (id)init
{
    self  = [super init];
    count=0;
    return self;
}

- (int)resetUSBwithVid:(int)vid Pid:(int)pid
{
    int resetStatus = 0;
       libusb_context * context;
       libusb_init(&context);

       libusb_device_handle * dev_handle = libusb_open_device_with_vid_pid(context,vid,pid);
       if (dev_handle == NULL){
         printf("usb resetting unsuccessful! No matching device found, or error encountered!\n");
         resetStatus = 1;
       }
       else{
         /*reset the device, if one was found*/
         resetStatus = libusb_reset_device(dev_handle);
       }
       /*exit libusb*/
       libusb_exit(context);
       return resetStatus;
}
// show all curent device usb
- (void) showListUsbDevice
{
    printf("%s", __func__);
    libusb_device **devs;
    libusb_context *context = NULL;
    
   
    //size_t i;
    int ret;
    ret = libusb_init(&context);
    if(ret < 0)
    {
        perror("libusb_init failed");
        return;
    }
    
    size_t num_device = libusb_get_device_list(context, &devs);
    
    printf("There are %zd devices foundn\n", num_device);
    for(int i=0;i<num_device;i++)
    {
        [self print_device:devs[i]];
    }
    printf("There are %zd devices foundn\n", num_device);
    libusb_free_device_list(devs, (int)num_device);
    libusb_exit(context);
}

- (NSString *) readFileConfigHUB {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *pathUSB_HUB = [NSString stringWithFormat: @"%@/EarseMac/Lib/config/usb_hub.config", documentsDirectory];
    if ([fileManager fileExistsAtPath:pathUSB_HUB] == false){
        NSLog(@"File usb_hub.config is not exist");
        pid_vendor = @"N/A";
    }
    else
    {
        NSString* content = [NSString stringWithContentsOfFile:pathUSB_HUB encoding:NSUTF8StringEncoding error:NULL];
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        vid_vendor = json[@"usb_hub"][@"vid_hub"];
        pid_vendor = json[@"usb_hub"][@"pid_hub"];
        NSLog(@"[TN-DB] readFileConfigHUB vid_vendor: %@", vid_vendor);
        NSLog(@"[TN-DB] readFileConfigHUB pid_vendor:%@", pid_vendor);
    }
    return pid_vendor;
}


// get list current module watch plugin
- (NSMutableArray *)getListModule
{
    printf("%s", __func__);
    libusb_device **devs;
    libusb_context *context = NULL;
    
    //size_t i;
    int ret;
    ret = libusb_init(&context);
    if(ret < 0)
    {
        perror("libusb_init failed");
        return nil;
    }
    NSMutableArray *arrtemp = [self getModuleViaTTY];
    NSLog(@"Usbarr:%@", arrtemp);
    [self readFileConfigHUB];
    
    size_t num_device = libusb_get_device_list(context, &devs);
    

    printf("There are %zd devices foundn\n", num_device);
    NSMutableArray *arrayDevice = [[NSMutableArray alloc] init];
    [arrayDevice removeAllObjects];
    NSString *vid,*pid,*path;
    NSLog(@"[TN-DB] vid_vendor: %@", vid_vendor);
    NSLog(@"[TN-DB] pid_vendor:%@", pid_vendor);
    for(int i=0;i<num_device;i++)
        {
            NSMutableDictionary *dic = [self getInfo:devs[i]];
            if(dic!=nil)
            {
                vid = [NSString stringWithFormat:@"0x%04x",[[dic objectForKey:@"vid"] intValue]];
                pid = [NSString stringWithFormat:@"0x%04x",[[dic objectForKey:@"pid"] intValue]];
                path = [NSString stringWithFormat:@"%@",[dic objectForKey:@"path"]];
    //            if([vid isEqualToString:@"0x0403"] && [pid isEqualToString:@"0x6001"])//UARC
    //            {
    //                [arrayDevice addObject:dic];
    //            }
                //if([vid isEqualToString:@"0x2109"] && [pid isEqualToString:@"0x0817"])


                if([vid isEqualToString:vid_vendor] && [pid isEqualToString:pid_vendor])
                {
                    //hub usb co hub con
                    bool exists = NO;
                    for(int j=0;j<arrayDevice.count;j++)
                    {
                        NSMutableDictionary *dictmp = arrayDevice[j];
                        NSString *temPath = [NSString stringWithFormat:@"%@",[dictmp objectForKey:@"path"]];
                        if ([temPath hasPrefix:path])
                            exists = YES;
                    }
                    if(exists == NO)
                   //
                    {
                        [arrayDevice addObject:dic];
                        break; // chi dung 1 cai
                    }
                }
            }
        }
    
//    for(int i=0;i<num_device;i++)
//    {
//        NSMutableDictionary *dic = [self getInfo:devs[i]];
//        if(dic!=nil)
//        {
//            vid = [NSString stringWithFormat:@"0x%04x",[[dic objectForKey:@"vid"] intValue]];
//            pid = [NSString stringWithFormat:@"0x%04x",[[dic objectForKey:@"pid"] intValue]];
//            path = [NSString stringWithFormat:@"%@",[dic objectForKey:@"path"]];
////            if([vid isEqualToString:@"0x0403"] && [pid isEqualToString:@"0x6001"])//UARC
////            {
////                [arrayDevice addObject:dic];
////            }
//
//            if([vid isEqualToString:@"0x2109"] && [pid isEqualToString:@"0x0817"])//usb hub
//            {
//                //hub usb co hub con
//                bool exists = NO;
//                for(int j=0;j<arrayDevice.count;j++)
//                {
//                    NSMutableDictionary *dictmp = arrayDevice[j];
//                    NSString *temPath = [NSString stringWithFormat:@"%@",[dictmp objectForKey:@"path"]];
//                    if ([temPath hasPrefix:path])
//                        exists = YES;
//                }
//                if(exists == NO)
//               //
//                {
//                    [arrayDevice addObject:dic];
//                    break; // chi dung 1 cai
//                }
//            }
//        }
//    }
   
    NSLog(@"arrayDevice:%@", arrayDevice);
    if(arrayDevice.count == arrtemp.count)
    {
        for(int i=0;i<arrayDevice.count;i++)
        {
            NSMutableDictionary *dic = [arrayDevice objectAtIndex:i];
            NSString *UniqueDeviceID = [dic objectForKey:@"UniqueDeviceID"];
            if(UniqueDeviceID.length < 2)
            {
                UniqueDeviceID = [arrtemp objectAtIndex:i];
                [dic setObject:UniqueDeviceID forKey:@"UniqueDeviceID"];
                [arrayDevice replaceObjectAtIndex:i withObject:dic];
            }
        }
    }
    
    
    /*
     evices vendor:idProduct 0x0403:0x6001
     Product: FT232R USB UART
     manufacturer: FTDI
     UniqueDeviceID: A601V5NB
     bcdDevice: 0x0600
     0403:6001 (bus 20, device 50) path: 6.1.3.3.2
     */
    
    
    libusb_free_device_list(devs, (int)num_device);
    libusb_exit(context);
    
    //NSLog(@"list module:%@",arrayDevice);
    return arrayDevice;
}
// get list watch
- (NSMutableArray *)getListiWatchDevice
{
    printf("%s", __func__);
    NSMutableArray *arrayDevice = [[NSMutableArray alloc] init];
 
    libusb_device **devs;
    libusb_context *context = NULL;

    //size_t i;
    int ret;
    ret = libusb_init(&context);
    if(ret < 0)
    {
        perror("libusb_init failed");
        return nil;
    }

    size_t num_device = libusb_get_device_list(context, &devs);

    printf("There are %zd usb devices found \n", num_device);

    [arrayDevice removeAllObjects];
    for(int i=0; i < num_device; i++)
    {
        printf("%s ====================================================usb devices [%d]\n",__func__, i);
        NSMutableDictionary *dic = [self print_device:devs[i]];
        if(dic!=nil)
        {
            [arrayDevice addObject:dic];
        }
    }

    libusb_free_device_list(devs, (int)num_device);
    libusb_exit(context);
    
    
    
    NSLog(@"arrayDevice watch: \n%@", arrayDevice);
    return arrayDevice;
}

- (NSString *)runCommandNew:(NSString *)commandToRun
{
    @autoreleasepool {
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/sh"];
        
        NSArray *arguments = [NSArray arrayWithObjects:
                              @"-c" ,
                              [NSString stringWithFormat:@"%@", commandToRun],
                              nil];
        NSLog(@"run command:%@", commandToRun);
        [task setArguments:arguments];
        
        NSPipe *pipe = [NSPipe pipe];
        [task setStandardOutput:pipe];
        
        NSFileHandle *file = [pipe fileHandleForReading];
        
        [task launch];
        
        NSData *data = [file readDataToEndOfFile];
        @autoreleasepool {
            NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            return output;
        }
//        NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        return output;
    }
}

- (bool) checkDeviceInDFU_Mode:(NSString *)mECID
{
    @autoreleasepool {
        bool isDFUMode = false;
        
        //check DFU
        NSLog(@"[ProcessUSB][checkDeviceInDFU_Mode] ECID: %@", mECID);
        
        NSTimeInterval timeBegin = [[NSDate date] timeIntervalSince1970];
        NSString *data = [self runCommand:@"/usr/local/bin/cfgutil" param:@[@"-e",mECID,@"get-property",@"bootedState"]];
        NSTimeInterval timeEnd = [[NSDate date] timeIntervalSince1970];
        double timescand = timeEnd - timeBegin;
        NSLog(@"[ProcessUSB][checkDeviceInDFU_Mode] runCommand elapsed time: %.2f", timescand);
        NSLog(@"[ProcessUSB][checkDeviceInDFU_Mode] runCommand data: %@", data);

        if ([data rangeOfString:@"DFU"].location != NSNotFound)// cuoi dong
        {
            isDFUMode = true;
        }
        //[dic setObject:[NSNumber numberWithBool:isDFUMode] forKey:@"state_dfu"];
        // End Check DFU
        NSLog(@"[ProcessUSB][checkDeviceInDFU_Mode] isDFUMode: %d", isDFUMode);
        return  isDFUMode;
    }
}

- (bool) checkDeviceConnectByECID:(NSString *)mECID
{
    @autoreleasepool {
        bool isDisconnect = false;
        //check DFU
        NSLog(@"[ProcessUSB][checkDeviceConnectByECID] ECID: %@", mECID);
        
        NSTimeInterval timeBegin = [[NSDate date] timeIntervalSince1970];
        //NSString *data = [self runCommand:@"/usr/local/bin/cfgutil" param:@[@"-e",mECID,@"get-property",@"bootedState"]];
        NSString *data = [self runCommandErrNew:@"/usr/local/bin/cfgutil" param:@[@"-e",mECID,@"get-property",@"bootedState"]];
        
        NSTimeInterval timeEnd = [[NSDate date] timeIntervalSince1970];
        double timescand = timeEnd - timeBegin;
        NSLog(@"[ProcessUSB][checkDeviceConnectByECID] runCommand elapsed time: %.2f", timescand);
        NSLog(@"[ProcessUSB][checkDeviceConnectByECID] data: %@", data);

        if ([data rangeOfString:@"error: no devices found"].location != NSNotFound)// cuoi dong
        {
            isDisconnect = true;
        }
        //[dic setObject:[NSNumber numberWithBool:isDFUMode] forKey:@"state_dfu"];
        // End Check DFU
        NSLog(@"[ProcessUSB][checkDeviceInDFU_Mode] isDisconnect: %d", isDisconnect);
        return  isDisconnect;
    }
}

NSMutableArray *arrayDevice;
- (NSMutableArray *)getListiMacDeviceByAppleConfig
{
    printf("%s", __func__);
    if (arrayDevice == nil) {
        arrayDevice = [[NSMutableArray alloc] init];
    } else {
        NSLog(@"[ProcessUSB] getListiMacDeviceByAppleConfig arrayDevice Mac: \n%@", arrayDevice);
        [arrayDevice removeAllObjects];
    }

    //which cfgutil
    NSTimeInterval timeBegin = [[NSDate date] timeIntervalSince1970];
    NSString *data = [self runCommand:@"/usr/local/bin/cfgutil" param:@[@"--format",@"JSON",@"list"]];
    NSTimeInterval timeEnd = [[NSDate date] timeIntervalSince1970];
    double timescand = timeEnd - timeBegin;
    NSLog(@"[getListiMacDeviceByAppleConfig] runCommand elapsed time: %.2f", timescand);
    data = runCommandOutput;
    NSLog(@"data search mac: \n%@", data);
    
    NSMutableDictionary *dic = Nil;
    
    if ([data rangeOfString:@"{\"Command\":\"list\""].location != NSNotFound)
    {
        NSArray *arr = [data componentsSeparatedByString:@"{\"Command\":\"list\""];
        if(arr.count >=2)
        {
            NSString *tmp = [arr objectAtIndex:1];
            tmp = [NSString stringWithFormat:@"{\"Command\":\"list\"%@",tmp];
            AppDelegate *delegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
            dic = (NSMutableDictionary *)[[delegate diccionaryFromJsonString:tmp] mutableCopy];
            NSLog(@"dic Mac: \n%@", dic);

            NSMutableDictionary *dictmp = [[dic objectForKey:@"Output"] mutableCopy];
            NSLog(@"dic dictmp: \n%@", dictmp);
            if([dictmp allKeys].count>0)
            {
                for (int i=0; i<[dictmp allKeys].count; i++)
                {
                    NSString *key = [[dictmp allKeys] objectAtIndex:i];
                    dic = [[dictmp objectForKey:key] mutableCopy];
                    NSLog(@"dic[%d]: %@",i,dic);
                    NSLog(@"[ProcessUSB] check DFU dic[%d]: ECID: %@",i, [dic objectForKey:@"ECID"]);

                    NSString *model = @"N/A";
                    NSString *name = @"none";
                    model = [dic objectForKey:@"deviceType"];
                    if (![model  isEqual: @"N/A"]) {
                        name = model;
                    }
                    [dic setObject:name forKey:@"name"];

                    // Begin read S/N of Mac
                    NSString *serial = @"N/A";
                    NSString *strLocator = [NSString stringWithFormat:@"0x%08x",[[dic objectForKey:@"locationID"] unsignedIntValue]];
                    NSString *cmd =  [NSString stringWithFormat:@"system_profiler SPUSBDataType | grep 'Location ID: %@' -B5 | grep 'Serial Number:'", strLocator];
                    NSLog(@"[ProcessUSB][Check Serial Number]cdm get serial: %@",cmd);
                    
                    timeBegin = [[NSDate date] timeIntervalSince1970];
                    NSString *output = [self runCommandNew:cmd];
                    timeEnd = [[NSDate date] timeIntervalSince1970];
                    timescand = timeEnd - timeBegin;
                    NSLog(@"[getListiMacDeviceByAppleConfig] Check Serial runCommand elapsed time: %.2f", timescand);
                    
                    NSLog(@"[ProcessUSB][Check Serial Number] item output serial: %@", output);

                    data = output;
                    NSCharacterSet *separator = [NSCharacterSet newlineCharacterSet];
                    NSArray *rows = [data componentsSeparatedByCharactersInSet:separator];
                    for (int j = 0; j<rows.count; j++)
                    {
                        NSString *item = [rows objectAtIndex:j];
                        if([item rangeOfString:@"Serial Number:"].location != NSNotFound)
                        {
                            NSLog(@"[Check Serial Number] item serial: %@", item);

                            NSArray *arr = [item componentsSeparatedByString:@":"];
                            if(arr.count>1)
                            {
                                if([arr objectAtIndex:1])
                                {
                                    serial = [arr objectAtIndex:1];
                                }

                                if ( [[serial uppercaseString] rangeOfString:@"SDOM"].location != NSNotFound)
                                {
                                    int vt = (int)arr.count;
                                    serial = [NSString stringWithFormat:@"%@",[arr objectAtIndex:vt -1]];
                                    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"[ ]"];
                                    serial = [[serial componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
                                }
                                serial = [serial stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                serial = [serial stringByReplacingOccurrencesOfString:@" " withString:@""];
                                if([[serial uppercaseString] rangeOfString:@"(NULL)"].location == NSNotFound &&
                                   [[serial uppercaseString] rangeOfString:@"SDOM"].location == NSNotFound &&
                                   [[serial uppercaseString] rangeOfString:@"CPID"].location == NSNotFound &&
                                   [[serial uppercaseString] rangeOfString:@"-"].location == NSNotFound &&
                                   [[serial uppercaseString] rangeOfString:@"000000000000"].location == NSNotFound &&
                                   [[serial uppercaseString] rangeOfString:@"IBOOT"].location == NSNotFound)
                                {
                                    if(serial.length == 12)
                                    {
                                        NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"[ ]"];
                                        serial = [[serial componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
                                    }
                                    [dic setObject:serial forKey:@"serial"];
                                }


                            }
                        }
                    }//end for
                    if (serial == nil) {
                        serial = @"N/A";
                    }
                    [arrayDevice addObject:[dic mutableCopy]];
                }
              
            }
            else dic = nil;
            NSLog(@"dic Mac 0: \n%@", dic);
            NSLog(@"==================================================");
        }
          
    }
    NSLog(@"[ProcessUSB] arrayDevice Mac: \n%@", arrayDevice);
    return arrayDevice;
    
}

NSString *outputRunCommandErrNewProUSB = @"";
- (NSString *) runCommandErrNew:(NSString*)cmd param:(NSArray*)arguments
{
    @autoreleasepool {
        NSLog(@"%s %@ %@",__func__,cmd,arguments);
        NSPipe *pipe = [NSPipe pipe];
        NSFileHandle *file = pipe.fileHandleForReading;
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = cmd;
        if(arguments.count > 0)
            task.arguments = arguments;
        //task.standardOutput = pipe;
        task.standardError = pipe;
        [task launch];
        
        NSData *dataPlist = [file readDataToEndOfFile];
        NSString *grepOutput = [[NSString alloc] initWithData: dataPlist encoding: NSUTF8StringEncoding];
        NSLog(@"[strDisconnectNew] %s output: %@",__func__, grepOutput);
        [task waitUntilExit];
        [file closeFile];
        if (![task isRunning])
        {
            int status = [task terminationStatus];
            if (status == 0) {
                NSLog(@"%s[runCommandErrNew] Task succeeded.",__func__);
                task = nil;
                outputRunCommandErrNewProUSB = grepOutput;
                return grepOutput;
            } else {
                NSLog(@"%s[runCommandErrNew] Task failed.",__func__);
                task = nil;
                return @"";
            }
        }
        return grepOutput;//grepOutput
    }
}

- (NSMutableArray *)getListiMacDevice
{

    printf("%s", __func__);
    NSMutableArray *arrayDevice = [[NSMutableArray alloc] init];

    NSLog(@"[ProcessUSB] getListiMacDevice arrayDevice Mac: \n%@", arrayDevice);

    //NSString *data = [self runCommandErrNew:@"/usr/local/bin/cfgutil" param:@[@"--format",@"JSON",@"list"]];

    //which cfgutil
    
    NSTimeInterval timeBegin = [[NSDate date] timeIntervalSince1970];
    NSString *data = [self runCommand:@"/usr/local/bin/cfgutil" param:@[@"--format",@"JSON",@"list"]];
    NSTimeInterval timeEnd = [[NSDate date] timeIntervalSince1970];
    double timescand = timeEnd - timeBegin;
    NSLog(@"[getListiMacDevice]runCommand elapsed time: %.2f", timescand);

    NSLog(@"data search mac: %@", data);

    NSMutableDictionary *dic = Nil;
    if ([data rangeOfString:@"{\"Command\":\"list\""].location != NSNotFound)
    {


        NSArray *arr = [data componentsSeparatedByString:@"{\"Command\":\"list\""];
        if(arr.count >=2)
        {
            NSString *tmp = [arr objectAtIndex:1];
            tmp = [NSString stringWithFormat:@"{\"Command\":\"list\"%@",tmp];
            AppDelegate *delegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
            dic = (NSMutableDictionary *)[[delegate diccionaryFromJsonString:tmp] mutableCopy];
            NSLog(@"dic Mac: \n%@", dic);

            NSMutableDictionary *dictmp = [[dic objectForKey:@"Output"] mutableCopy];
            NSLog(@"dic dictmp: \n%@", dictmp);
            if([dictmp allKeys].count>0)
            {
                for (int i=0; i<[dictmp allKeys].count; i++)
                {
                    NSString *key = [[dictmp allKeys] objectAtIndex:i];
                    dic = [[dictmp objectForKey:key] mutableCopy];
                    NSLog(@"dic[%d]: %@",i,dic);


                    //check DFU
                    NSLog(@"[ProcessUSB] check DFU dic[%d]: ECID: %@",i, [dic objectForKey:@"ECID"]);

                    
                    
                    NSTimeInterval timeBegin = [[NSDate date] timeIntervalSince1970];
                    NSString *data = [self runCommand:@"/usr/local/bin/irecovery" param:@[@"-q",@"-i", [dic objectForKey:@"ECID"]]];
                    NSTimeInterval timeEnd = [[NSDate date] timeIntervalSince1970];
                    double timescand = timeEnd - timeBegin;
                    NSLog(@"[ProcessUSB] check DFU runCommand elapsed time: %.2f", timescand);
                    
                    NSCharacterSet *separator = [NSCharacterSet newlineCharacterSet];


                    NSString *item = @"none";
                    BOOL isDFUMode = NO;
                    NSLog(@"[ProcessUSB] check DFU dic[%d]: data.length: %lu",i, (unsigned long)data.length);

                    if(data != Nil || data.length>0)
                    {
                        NSLog(@"[ProcessUSB] check DFU dic[%d]: data: %@",i, data);

                        NSArray *rows = [data componentsSeparatedByCharactersInSet:separator];

                        NSString *name = @"none";
                        for (int j = 0; j<rows.count; j++)
                        {
                            item = [rows objectAtIndex:j];
                            if([item rangeOfString:@"MODE: DFU"].location != NSNotFound)
                            {
                                isDFUMode = YES;
                            }

                            if([item rangeOfString:@"NAME:"].location != NSNotFound)
                            {
                                name = [item stringByReplacingOccurrencesOfString:@"NAME:" withString:@""];
                            } else {
                                NSString *model = @"N/A";
                                model = [dic objectForKey:@"deviceType"];
                                if (![model  isEqual: @"N/A"]) {
                                    name = model;
                                }
                            }
                        }


                        [dic setObject:[NSNumber numberWithBool:isDFUMode] forKey:@"state_dfu"];
                        [dic setObject:name forKey:@"name"];

                        NSLog(@"[ProcessUSB] data irecovery: \n%@", data);
                    } else if (data.length == 0) {
                        NSLog(@"[ProcessUSB] check DFU output: data.length == 0 isDFUMode: %d", isDFUMode);
                        [dic setObject:[NSNumber numberWithBool:isDFUMode] forKey:@"state_dfu"];
                    } else if (data == nil) {
                        NSLog(@"[ProcessUSB] check DFU output: data == nill isDFUMode: %d", isDFUMode);
                        [dic setObject:[NSNumber numberWithBool:isDFUMode] forKey:@"state_dfu"];
                    }
                   //==============================================================
                    //get serial number
                    NSString *serial = @"N/A";

                    NSString *strLocator = [NSString stringWithFormat:@"0x%08x",[[dic objectForKey:@"locationID"] unsignedIntValue]];

                    NSString *cmd =  [NSString stringWithFormat:@"system_profiler SPUSBDataType | grep 'Location ID: %@' -B5 | grep 'Serial Number:'", strLocator];
                    NSLog(@"[ProcessUSB][Check Serial Number]cdm get serial: %@",cmd);
                    //NSString *output = [self runCommandNew:cmd];
                    
                    
                    timeBegin = [[NSDate date] timeIntervalSince1970];
                    NSString *output = [self runCommandNew:cmd];
                    timeEnd = [[NSDate date] timeIntervalSince1970];
                    timescand = timeEnd - timeBegin;
                    NSLog(@"[ProcessUSB] Get serial number runCommandNew elapsed time: %.2f", timescand);
                    
                    NSLog(@"[ProcessUSB][Check Serial Number] item output serial: %@", output);
                    data = output;
                    separator = [NSCharacterSet newlineCharacterSet];
                    NSArray *rows = [data componentsSeparatedByCharactersInSet:separator];
                    for (int j = 0; j<rows.count; j++)
                    {
                        item = [rows objectAtIndex:j];
                        if([item rangeOfString:@"Serial Number:"].location != NSNotFound)
                        {
                            NSLog(@"[Check Serial Number] item serial: %@", item);

                            NSArray *arr = [item componentsSeparatedByString:@":"];
                            if(arr.count>1)
                            {
                                if([arr objectAtIndex:1])
                                {
                                    serial = [arr objectAtIndex:1];
                                }

                                if ( [[serial uppercaseString] rangeOfString:@"SDOM"].location != NSNotFound)
                                {
                                    int vt = (int)arr.count;
                                    serial = [NSString stringWithFormat:@"%@",[arr objectAtIndex:vt -1]];
                                    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"[ ]"];
                                    serial = [[serial componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
                                }
                                serial = [serial stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                serial = [serial stringByReplacingOccurrencesOfString:@" " withString:@""];
                                if([[serial uppercaseString] rangeOfString:@"(NULL)"].location == NSNotFound &&
                                   [[serial uppercaseString] rangeOfString:@"SDOM"].location == NSNotFound &&
                                   [[serial uppercaseString] rangeOfString:@"CPID"].location == NSNotFound &&
                                   [[serial uppercaseString] rangeOfString:@"-"].location == NSNotFound &&
                                   [[serial uppercaseString] rangeOfString:@"000000000000"].location == NSNotFound &&
                                   [[serial uppercaseString] rangeOfString:@"IBOOT"].location == NSNotFound)
                                {
                                    if(serial.length == 12)
                                    {
                                       // serial = [arr objectAtIndex:10];
                                        NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"[ ]"];
                                        serial = [[serial componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
                                    }
                                    [dic setObject:serial forKey:@"serial"];
                                }
                            }
                        }
                    }
                    //end for
                    if (serial == nil) {
                        serial = @"N/A";
                    }
                    [arrayDevice addObject:[dic mutableCopy]];

                }

            }
            else dic = nil;
            NSLog(@"dic Mac 0: \n%@", dic);
            NSLog(@"==================================================");
        }
    }
    NSLog(@"[ProcessUSB] arrayDevice Mac: \n%@", arrayDevice);
    return arrayDevice;

}

/*
- (NSDictionary*)getMacInfo
{
    //cfgutil list -x
    //NSString *cmd = @"/usr/bin/cfgutil";
    NSString *data = [self runCommand:cmd param:@[@"list",@"-x"]];
    NSData* plistData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSPropertyListFormat format;
    NSDictionary * dict;
//    if (@available(macOS 10.10, *)) {
          // macOS 10.10 or later code path
        NSError *error;
        dict = (NSDictionary*)[NSPropertyListSerialization
                               propertyListWithData:plistData
                               options:NSPropertyListMutableContainersAndLeaves
                               format:&format
                               error:&error];
        
//    }
//    else {
//          // code for earlier than 10.10
//        NSString *errorDesc = nil;
//        dict = (NSDictionary*)[NSPropertyListSerialization
//                                              propertyListFromData:plistData
//                                              mutabilityOption:NSPropertyListMutableContainersAndLeaves
//                                              format:&format
//                                              errorDescription:&errorDesc];
//    }
    
    NSLog(@"dict plist: %@",dict);
   
                                           
    return dict;
    
   // NSDictionary *dict = [[NSDictionary alloc] initWith];
    
}
 */
//get infomation of device
- (NSMutableDictionary *) getInfo:(libusb_device *)device
{
    struct libusb_device_descriptor device_descriptor;
    struct libusb_device_handle *device_handle = NULL;

    // Get USB device descriptor
    int result = libusb_get_device_descriptor(device, &device_descriptor);
    if (result < 0) {
        printf("Failed to get device descriptor!\n");
        return nil;
    }
   
    // Only print our devices
   // if(VID == device_descriptor.idVendor && PID == device_descriptor.idProduct) {
        // Print VID & PID
        //printf("devices vendor:idProduct 0x%04x:0x%04x\n", device_descriptor.idVendor, device_descriptor.idProduct);
    //}
  
    // Attempt to open the device
    int open_result = libusb_open(device, &device_handle);
    if (open_result < 0) {
        libusb_close(device_handle);
        return nil;
    }
   
    char Product[256] = " ";
    if (device_descriptor.iProduct)
    {
        libusb_get_string_descriptor_ascii(device_handle, device_descriptor.iProduct,
            (unsigned char *)Product, sizeof(Product));
     //   printf("Product: %s\n", Product);
    }
    NSString *product = [[NSString alloc] initWithUTF8String:Product];
   
    // Print the device manufacturer string
    char manufacturer[256] = " ";
    if (device_descriptor.iManufacturer)
    {
        libusb_get_string_descriptor_ascii(device_handle, device_descriptor.iManufacturer,
                                           (unsigned char *)manufacturer, sizeof(manufacturer));
      //  printf("manufacturer: %s\n", manufacturer);
    }
    
    char SerialNumber[256] = " ";
    if (device_descriptor.iSerialNumber)
    {
        libusb_get_string_descriptor_ascii(device_handle, device_descriptor.iSerialNumber,
                                           (unsigned char *)SerialNumber, sizeof(SerialNumber));
       // printf("UniqueDeviceID: %s\n", SerialNumber);
    }
        
    /** Device release number in binary-coded decimal */
    //printf("bcdDevice: 0x%04x\n", device_descriptor.bcdDevice);
//    int bus = libusb_get_bus_number(device);
//    int dev = libusb_get_device_address(device);
    uint8_t path[8];
    //printf("%04x:%04x (bus %d, device %d)", device_descriptor.idVendor, device_descriptor.idProduct, bus, dev);
    NSString *path_usb = @"";
    int r = libusb_get_port_numbers(device, path, sizeof(path));
    if (r > 0) {
        path_usb = [path_usb stringByAppendingFormat:@"%d",path[0]];
       // printf(" path: %d", path[0]);
        for (int j = 1; j < r; j++)
        {
           //printf(".%d", path[j]);
            path_usb = [path_usb stringByAppendingFormat:@".%d",path[j]];
        }
    }
    NSString *manufac = [[NSString alloc] initWithUTF8String:manufacturer];
    NSString *serial =  [[NSString alloc] initWithUTF8String:SerialNumber];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                [NSNumber numberWithShort:device_descriptor.idVendor], @"vid",
                                [NSNumber numberWithShort:device_descriptor.idProduct], @"pid",
                                [NSNumber numberWithShort:device_descriptor.iSerialNumber], @"iSerialNumber",
                                product==nil?@"":product, @"product",
                                manufac==nil?@"":manufac, @"manufacturer",
                                [NSString stringWithFormat:@"0x%04x",device_descriptor.bcdDevice],@"bcd_device",
                                path_usb,@"path",
                                serial==nil?@"":serial, @"UniqueDeviceID",
                                nil];
    libusb_close(device_handle);
    return dic;
}
// find and filter iwatch
- (NSMutableDictionary *) print_device:(libusb_device *)device
{
    struct libusb_device_descriptor device_descriptor;
    struct libusb_device_handle *device_handle = NULL;

    // Get USB device descriptor
    int result = libusb_get_device_descriptor(device, &device_descriptor);
    if (result < 0) {
        printf("Failed to get device descriptor!\n");
        return nil;
    }

    // Only print our devices
   // if(VID == device_descriptor.idVendor && PID == device_descriptor.idProduct) {
        // Print VID & PID
        printf("devices vendor:idProduct 0x%04x:0x%04x\n", device_descriptor.idVendor, device_descriptor.idProduct);
    //}

    // Attempt to open the device
    int open_result = libusb_open(device, &device_handle);
    if (open_result < 0) {
        libusb_close(device_handle);
        return nil;
    }

    char Product[256] = " ";
    if (device_descriptor.iProduct)
    {
        libusb_get_string_descriptor_ascii(device_handle, device_descriptor.iProduct,
            (unsigned char *)Product, sizeof(Product));
        printf("Product: %s\n", Product);
    }
    NSString *product = [[NSString alloc] initWithUTF8String:Product];


    // Print the device manufacturer string
    char manufacturer[256] = " ";
    if (device_descriptor.iManufacturer)
    {
        libusb_get_string_descriptor_ascii(device_handle, device_descriptor.iManufacturer,
                                           (unsigned char *)manufacturer, sizeof(manufacturer));
        printf("manufacturer: %s\n", manufacturer);
    }
    
    char SerialNumber[256] = " ";
    if (device_descriptor.iSerialNumber)
    {
        libusb_get_string_descriptor_ascii(device_handle, device_descriptor.iSerialNumber,
                                           (unsigned char *)SerialNumber, sizeof(SerialNumber));
        printf("UniqueDeviceID: %s\n", SerialNumber);
    }
        
    /** Device release number in binary-coded decimal */
    printf("bcdDevice: 0x%04x\n", device_descriptor.bcdDevice);

  
   int port_number = libusb_get_port_number(device);
    printf("port_number: %d ", port_number);
    
    uint8_t port[10];
    int port_len=0;
    int port_num = libusb_get_port_numbers(device, port, port_len);
    printf("port_number: %d port_len: %d", port_num,port_len);
    for (int i=0; i<port_len; i++)
    {
        printf("port_%d: %d",i, port[i]);
    }
    
   LIBUSB_DEPRECATED_FOR(libusb_get_port_numbers)
   int LIBUSB_CALL libusb_get_port_path(libusb_context *ctx, libusb_device *dev, uint8_t *path, uint8_t path_length);
   libusb_device * LIBUSB_CALL libusb_get_parent(libusb_device *dev);
    
    
    
    
   
    int bus = libusb_get_bus_number(device);
    int dev = libusb_get_device_address(device);
    uint8_t path[8];
    printf("%04x:%04x (bus %d, device %d) sizepath:%lu ", device_descriptor.idVendor, device_descriptor.idProduct, bus, dev, sizeof(path));
    
//    libusb_context *ctx;
//    libusb_get_port_path(ctx, device, &path, sizeof(path));
    
    NSString *path_usb = @"";
    int r = libusb_get_port_numbers(device, path, sizeof(path));
    if (r > 0) {
        path_usb = [path_usb stringByAppendingFormat:@"%d",path[0]];
        printf(" path: %d", path[0]);
        for (int j = 1; j < r; j++)
        {
            printf(".%d", path[j]);
            path_usb = [path_usb stringByAppendingFormat:@".%d",path[j]];
        }
    }

    printf("\n");
    puts("");
    NSString *bdid = @"";
    NSString *cpid = @"";
    NSString *ecid = @"";
    NSString *srnm = @"";
    NSString *pro_type = @"";
//    if(device_descriptor.idVendor == 0x05ac &&
//       (device_descriptor.idProduct == 0x12af || device_descriptor.idProduct == 0x1881))
//    {
//
//    }
    
    if([[product lowercaseString] isEqualToString:@"mac"]==NO )
    {
        if([[product lowercaseString] rangeOfString:@"apple mobile device (recovery mode)"].location==NSNotFound)
        {
            // read info trong trang thay binh thuong
            if(device_descriptor.idVendor == 0x05ac && device_descriptor.idProduct == 0x1881)
            {
                // goi update
                pro_type = @"Update info";
            }
            else
            {
                libusb_close(device_handle);
                return nil;
            }
        }
        else
        {
            // read infor in recovery mode
            
            NSString *serial =  [[NSString alloc] initWithUTF8String:SerialNumber];
            
            // UniqueDeviceID: SDOM:01 CPID:8002 CPRV:10 CPFM:03 SCEP:01 BDID:0C ECID:001F28C128EB6326 IBFL:3D SRNM:[FH7TL5YMHJLL]
            NSArray *arr = [serial componentsSeparatedByString:@" "];
            if(arr.count < 9)
            {
                libusb_close(device_handle);
                return nil;
            }
            bdid = [arr objectAtIndex:5];
            bdid = [bdid stringByReplacingOccurrencesOfString:@"BDID:" withString:@""];
            cpid = [arr objectAtIndex:1];
            cpid = [cpid stringByReplacingOccurrencesOfString:@"CPID:" withString:@""];
            ecid = [arr objectAtIndex:6];
            ecid = [ecid stringByReplacingOccurrencesOfString:@"ECID:" withString:@""];
            srnm = [arr objectAtIndex:8];
            srnm = [srnm stringByReplacingOccurrencesOfString:@"SRNM:[" withString:@""];
            srnm = [srnm stringByReplacingOccurrencesOfString:@"]" withString:@""];
    
            NSLog(@"%s bdid:%@ cpid:%@ ecid:%@ srnm:%@\n",__func__,bdid,cpid,ecid,srnm);
            pro_type = [self getProducType:bdid CPID:cpid];
            if([pro_type isEqualToString:@"Not support"]==YES)
            {
                NSLog(@"%s chua support this watch",__func__);
                libusb_close(device_handle);
                return nil;
            }
            product = pro_type;
        }
    }
    
    NSMutableDictionary *dinfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                  ecid,@"ECID",
                                  bdid,@"BDID",
                                  cpid,@"CPID",
                                  srnm,@"SerialNumber",
                                  pro_type,@"ProductType",
                                  @"N/A",@"ProductVersion",
                                    nil];
    
    NSString *manufac = [[NSString alloc] initWithUTF8String:manufacturer];
    NSString *data =  [[NSString alloc] initWithUTF8String:SerialNumber];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                [NSNumber numberWithShort:device_descriptor.idVendor], @"vid",
                                [NSNumber numberWithShort:device_descriptor.idProduct], @"pid",
                                product, @"product",
                                manufac, @"manufacturer",
                                data,@"UniqueDeviceID",
                                [NSString stringWithFormat:@"0x%04x",device_descriptor.bcdDevice],@"bcd_device",
                                path_usb,@"path",
                                dinfo,@"info_ex",
                                nil];
    libusb_close(device_handle);
    return dic;
}
- (NSString *)getProducType:(NSString *)bdid CPID:(NSString *)cpid
{
    // read tu file config khong gan cung nhu the nay
    
    if([bdid isEqualToString:@"02"] && [cpid isEqualToString:@"7002"])
        return @"Watch1,1";
    else if([bdid isEqualToString:@"04"] && [cpid isEqualToString:@"7002"])
        return @"Watch1,2";
    else if([bdid isEqualToString:@"02"] && [cpid isEqualToString:@"8002"])
        return @"Watch2,6";
    else if([bdid isEqualToString:@"04"] && [cpid isEqualToString:@"8002"])
        return @"Watch2,7";
    else if([bdid isEqualToString:@"0C"] && [cpid isEqualToString:@"8002"])
        return @"Watch2,3";
    else if([bdid isEqualToString:@"0E"] && [cpid isEqualToString:@"8002"])
        return @"Watch2,4";
    else if([bdid isEqualToString:@"1C"] && [cpid isEqualToString:@"8004"])
        return @"Watch3,1";
    else if([bdid isEqualToString:@"1E"] && [cpid isEqualToString:@"8004"])
        return @"Watch3,2";
    else if([bdid isEqualToString:@"18"] && [cpid isEqualToString:@"8004"])
        return @"Watch3,3";
    else if([bdid isEqualToString:@"1A"] && [cpid isEqualToString:@"8004"])
        return @"Watch3,4";
    else if([bdid isEqualToString:@"08"] && [cpid isEqualToString:@"8006"])
        return @"Watch4,1";
    else if([bdid isEqualToString:@"0A"] && [cpid isEqualToString:@"8006"])
        return @"Watch4,2";
    else if([bdid isEqualToString:@"0C"] && [cpid isEqualToString:@"8006"])
        return @"Watch4,3";
    else if([bdid isEqualToString:@"0E"] && [cpid isEqualToString:@"8006"])
        return @"Watch4,4";
    else if([bdid isEqualToString:@"10"] && [cpid isEqualToString:@"8006"])
        return @"Watch5,1";
    else if([bdid isEqualToString:@"12"] && [cpid isEqualToString:@"8006"])
        return @"Watch5,2";
    else if([bdid isEqualToString:@"14"] && [cpid isEqualToString:@"8006"])
        return @"Watch5,3";
    else if([bdid isEqualToString:@"16"] && [cpid isEqualToString:@"8006"])
        return @"Watch5,4";
    else if([bdid isEqualToString:@"28"] && [cpid isEqualToString:@"8006"])
        return @"Watch5,9";
    else if([bdid isEqualToString:@"2A"] && [cpid isEqualToString:@"8006"])
        return @"Watch5,10";
    else if([bdid isEqualToString:@"2C"] && [cpid isEqualToString:@"8006"])
        return @"Watch5,11";
    else if([bdid isEqualToString:@"2E"] && [cpid isEqualToString:@"8006"])
        return @"Watch5,12";
    else if([bdid isEqualToString:@"08"] && [cpid isEqualToString:@"8301"])
        return @"Watch6,1";
    else if([bdid isEqualToString:@"0A"] && [cpid isEqualToString:@"8301"])
        return @"Watch6,2";
    else if([bdid isEqualToString:@"0C"] && [cpid isEqualToString:@"8301"])
        return @"Watch6,3";
    else if([bdid isEqualToString:@"0E"] && [cpid isEqualToString:@"8301"])
        return @"Watch6,4";
    else if([bdid isEqualToString:@"10"] && [cpid isEqualToString:@"8301"])
        return @"Watch6,6";
    else if([bdid isEqualToString:@"12"] && [cpid isEqualToString:@"8301"])
        return @"Watch6,7";
    else if([bdid isEqualToString:@"14"] && [cpid isEqualToString:@"8301"])
        return @"Watch6,8";
    else if([bdid isEqualToString:@"16"] && [cpid isEqualToString:@"8301"])
        return @"Watch6,9";
   
    return @"Not support";
    


    
  /*
    { "Watch1,1",    "n27aap",   0x02, 0x7002, "Apple Watch 38mm (1st gen)" },
    { "Watch1,2",    "n28aap",   0x04, 0x7002, "Apple Watch 42mm (1st gen)" },
   { "Watch2,6",    "n27dap",  0x02, 0x8002, "Apple Watch Series 1 (38mm)" },
    { "Watch2,7",    "n28dap",  0x04, 0x8002, "Apple Watch Series 1 (42mm)" },
    { "Watch2,3",    "n74ap",   0x0C, 0x8002, "Apple Watch Series 2 (38mm)" },
    { "Watch2,4",    "n75ap",   0x0E, 0x8002, "Apple Watch Series 2 (42mm)" },
    { "Watch3,1",    "n111sap", 0x1C, 0x8004, "Apple Watch Series 3 (38mm Cellular)" },
    { "Watch3,2",    "n111bap", 0x1E, 0x8004, "Apple Watch Series 3 (42mm Cellular)" },
    { "Watch3,3",    "n121sap", 0x18, 0x8004, "Apple Watch Series 3 (38mm)" },
    { "Watch3,4",    "n121bap", 0x1A, 0x8004, "Apple Watch Series 3 (42mm)" },
    { "Watch4,1",    "n131sap", 0x08, 0x8006, "Apple Watch Series 4 (40mm)" },
    { "Watch4,2",    "n131bap", 0x0A, 0x8006, "Apple Watch Series 4 (44mm)" },
    { "Watch4,3",    "n141sap", 0x0C, 0x8006, "Apple Watch Series 4 (40mm Cellular)" },
    { "Watch4,4",    "n141bap", 0x0E, 0x8006, "Apple Watch Series 4 (44mm Cellular)" },
    { "Watch5,1",    "n144sap", 0x10, 0x8006, "Apple Watch Series 5 (40mm)" },
    { "Watch5,2",    "n144bap", 0x12, 0x8006, "Apple Watch Series 5 (44mm)" },
    { "Watch5,3",    "n146sap", 0x14, 0x8006, "Apple Watch Series 5 (40mm Cellular)" },
    { "Watch5,4",    "n146bap", 0x16, 0x8006, "Apple Watch Series 5 (44mm Cellular)" },
    { "Watch5,9",    "n140sap", 0x28, 0x8006, "Apple Watch SE (40mm)" },
    { "Watch5,10",   "n140bap", 0x2A, 0x8006, "Apple Watch SE (44mm)" },
    { "Watch5,11",   "n142sap", 0x2C, 0x8006, "Apple Watch SE (40mm Cellular)" },
    { "Watch5,12",   "n142bap", 0x2E, 0x8006, "Apple Watch SE (44mm Cellular)" },
    { "Watch6,1",    "n157sap", 0x08, 0x8301, "Apple Watch Series 6 (40mm)" },
    { "Watch6,2",    "n157bap", 0x0A, 0x8301, "Apple Watch Series 6 (44mm)" },
    { "Watch6,3",    "n158sap", 0x0C, 0x8301, "Apple Watch Series 6 (40mm Cellular)" },
    { "Watch6,4",    "n158bap", 0x0E, 0x8301, "Apple Watch Series 6 (44mm Cellular)" },
    { "Watch6,6",    "n187sap", 0x10, 0x8301, "Apple Watch Series 7 (41mm)" },
    { "Watch6,7",    "n187bap", 0x12, 0x8301, "Apple Watch Series 7 (45mm)" },
    { "Watch6,8",    "n188sap", 0x14, 0x8301, "Apple Watch Series 7 (41mm Cellular)" },
    { "Watch6,9",    "n188bap", 0x16, 0x8301, "Apple Watch Series 7 (45mm Cellular)" },
*/
}
// send data via usb
- (void) send:(libusb_context *)usb_context vid:(uint16_t) vid pid:(uint16_t) pid
{
    libusb_device_handle *device_handle;
    device_handle = libusb_open_device_with_vid_pid(usb_context, vid, pid);

    if (device_handle == NULL) {
        puts("Unable to open device by VID & PID!");
        return;
    }
    puts("Device successfully opened");

    unsigned char *data = (unsigned char *)"test";

    if (libusb_kernel_driver_active(device_handle, CDC_DATA_INTERFACE_ID)) {
        puts("Kernel driver active");
        if (libusb_detach_kernel_driver(device_handle, CDC_DATA_INTERFACE_ID)) {
            puts("Kernel driver detached");
        }
    } else {
        puts("Kernel driver doesn't appear to be active");
    }

    int result = libusb_claim_interface(device_handle, CDC_DATA_INTERFACE_ID);
    if (result < 0) {
        puts("Unable to claim interface!");
        libusb_close(device_handle);
        return;
    }
    puts("Interface claimed");

    int written = 0;
    result = libusb_bulk_transfer(device_handle, (3 | LIBUSB_ENDPOINT_OUT), data, 4, &written, 0);
    if (result == 0 && written == 4) {
        puts("Send success");
    } else {
        puts("Send failed!");
    }

    result = libusb_release_interface(device_handle, CDC_DATA_INTERFACE_ID);
    if (result != 0) {
        puts("Unable to release interface!");
    }

    libusb_close(device_handle);
}
- (NSString *)checkDevicePaired:(NSString *)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];

    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"run command:%@", commandToRun);
    [task setArguments:arguments];

    NSPipe *pipe = [NSPipe pipe];
    [task setStandardError:pipe];

    NSFileHandle *file = [pipe fileHandleForReading];

    [task launch];

    NSData *data = [file readDataToEndOfFile];

    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}
- (NSString *)checkDeviceDisconnect:(NSString *)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];

    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"run command:%@", commandToRun);
    [task setArguments:arguments];

    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];

    NSFileHandle *file = [pipe fileHandleForReading];

    [task launch];

    NSData *data = [file readDataToEndOfFile];

    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}
// get infomation current idevice via udid
- (NSMutableDictionary *)getInfoUSBDevice:(NSString *)udid
{
    //system("ideviceinfo -x");
    NSLog(@"%s ideviceinfo -x -u %@",__func__,udid);
    // not pemisstion or not find command => turn of sanbox
    
    AppDelegate *delegatedir = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSString *pathLib = [delegatedir pathLib];
    NSString *cmd = [NSString stringWithFormat:@"%@/libimobiledevice/tools/ideviceinfo",pathLib];
    // NSString *cmd = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/EarseWatch/Lib/libimobiledevice/tools/ideviceinfo"]].path;
    
    NSPipe *pipe = [NSPipe pipe];
     
    NSFileHandle *file = pipe.fileHandleForReading;
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = cmd;
    task.arguments = @[@"-x",@"-u",udid];
    task.standardOutput = pipe;
   // NSLog(@"[QT][task standardOutput00000]; %@",  [task standardOutput]);
    [task launch];
   // NSLog(@"[QT][task standardOutput]; %@",  [task standardOutput]);
    [task waitUntilExit];
    NSData *dataPlist = [file readDataToEndOfFile];
    NSString *grepOutput = [[NSString alloc] initWithData: dataPlist encoding: NSUTF8StringEncoding];
    //NSLog (@"ideviceinfo data leng:%lu data:%@",grepOutput.length, grepOutput);
   
   // NSLog(@"[QT]dataPlist %@",  dataPlist);
    
    [file closeFile];
//NSLog( @"[QT]grepOutput %@", grepOutput);
   
    if(grepOutput.length == 0 ||
       [grepOutput rangeOfString:@"not found"].location != NSNotFound)
    {
        NSLog( @"[QT]grepOutput nil ======================= %@", grepOutput);
        return nil;
    }
    else
    {
       // NSLog( @"[QT]grepOutput not nil ======================= %@", grepOutput);
    }

    NSError *error=nil;
    NSPropertyListFormat format;
    NSMutableDictionary* dic = [NSPropertyListSerialization propertyListWithData:dataPlist
                                                                    options:NSPropertyListImmutable
                                                                     format:&format
                                                                      error:&error];
    
    
    dic = [dic mutableCopy];
    [dic setObject:grepOutput forKey:@"output"];
    
    //NSLog( @"[QT] Dic is %@", dic );
    if(!dic){
        NSLog(@"[QT] Error: %@",error);
    }
    if (![task isRunning]) {
        int status = [task terminationStatus];
        if (status == 0) {
            NSLog(@"%s [QT] Task succeeded.",__func__);
        } else {
            NSLog(@"%s [QT] Task failed.",__func__);
        }
    }
    return dic;
}
//restore Watch with path file ipsw
- (bool)restoreWatch:(NSString *)UniqueDeviceID pathFile:(NSString *)path
{
    //system("idevicerestore -u");
    // not pemisstion or not find command => turn of sanbox
    NSLog (@"%s",__func__);
    NSLog (@"idevicerestore -u %@ %@",UniqueDeviceID,path);
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/EarseWatch/Lib/idevicerestore/src/idevicerestore"]].path;
    NSLog (@"launchPath:%@",task.launchPath );
    task.arguments = @[@"-u",UniqueDeviceID,path];
   //task.arguments = @[@"-x",path];
    task.standardOutput = pipe;
    task.standardError = pipe;
    
    
    [task launch];
   
   
    NSError *err = nil;
    NSData *dataPlist = nil;
    
    if (@available(macOS 10.15, *)) {
        dataPlist = [file readDataToEndOfFileAndReturnError:&err];
    } else {
        dataPlist = [file readDataToEndOfFile];
    }
    
    NSString *grepOutput = [[NSString alloc] initWithData: dataPlist encoding: NSUTF8StringEncoding];
    NSLog (@"restoreWatch data:\n%@", grepOutput);
    if(err)
    {
        NSLog (@"error: %@", [err description]);
    }

    [task waitUntilExit];
    [file closeFile];
    if (![task isRunning]) {
        int status = [task terminationStatus];
        if (status == 0) {
            NSLog(@"%s Task succeeded.",__func__);
            return YES;
        } else {
            NSLog(@"%s Task failed.",__func__);
            return NO;
        }
    }
    
    return YES;
}

- (void)showRunning
{
    NSLog (@"%d",count++);
}

- (bool)listDir:(NSString *)dir
{
    //system("ld Download");
    // not pemisstion or not find command => turn of sanbox
    
    NSLog (@"%s ls %@",__func__,dir);
    @try
    {
        // Set up the process
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/ls"];
        [task setArguments:[NSArray arrayWithObjects:@"-1", dir, nil]];
        
        // Set the pipe to the standard output and error to get the results of the command
        NSPipe *p = [[NSPipe alloc] init];
        [task setStandardOutput:p];
        [task setStandardError:p];
        
        // Launch (forks) the process
        [task launch]; // raises an exception if something went wrong
        
        // Prepare to read
        NSFileHandle *readHandle = [p fileHandleForReading];
        NSData *inData = nil;
        NSMutableData *totalData = [[NSMutableData alloc] init];
        
        while ((inData = [readHandle availableData]) && [inData length])
        {
            [totalData appendData:inData];
        }
        
        // Polls the runloop until its finished
        [task waitUntilExit];
        if (![task isRunning]) {
            int status = [task terminationStatus];
            if (status == 0) {
                NSLog(@"%s Task succeeded.",__func__);
                NSLog(@"Data recovered: \n%@",[NSString stringWithUTF8String:totalData.bytes ]);
            } else {
                NSLog(@"%s Task failed.",__func__);
                NSLog(@"Terminationstatus: %d", [task terminationStatus]);
            }
        }
    }
    @catch (NSException *e)
    {
        NSLog(@"%s Expection occurred %@",__func__, [e reason]);
        return NO;
    }
    return YES;
}
/*dung cho board 2.0*/
- (NSMutableArray*)getModuleViaTTY
{
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/ls";
    task.arguments = @[@"/dev/",@"| grep usb"];
    task.standardOutput = pipe;
    task.standardError = pipe;
    [task launch];
   
    NSData *dataPlist = [file readDataToEndOfFile];
    NSString *grepOutput = [[NSString alloc] initWithData: dataPlist encoding: NSUTF8StringEncoding];
    NSLog(@"%s output: %@",__func__,grepOutput);
    [task waitUntilExit];
    [file closeFile];
    if (![task isRunning])
    {
        int status = [task terminationStatus];
        if (status == 0) {
            NSLog(@"%s Task succeeded.",__func__);
            
        } else {
            NSLog(@"%s Task failed.",__func__);
            
        }
    }
   
   // NSString *grepOutput = [NSString stringWithUTF8String:totalData.bytes];
    NSCharacterSet *separator = [NSCharacterSet newlineCharacterSet];
    NSArray *arr = [grepOutput componentsSeparatedByCharactersInSet:separator];
    //NSLog( @"array ======================= %@", arr);
    NSMutableArray *array = [NSMutableArray array];
    for(int i=0;i<arr.count;i++)
    {
        NSString *str = [arr objectAtIndex:i];
        if([str rangeOfString:@"cu.usbserial-"].location != NSNotFound)
        {
            str = [str stringByReplacingOccurrencesOfString:@"cu.usbserial-" withString:@""];
            [array addObject:str];
        }
    }
    return array;
}



- (bool)actionCommand:(NSString*)cmd param:(NSArray*)arguments
{
    @autoreleasepool {
        NSLog(@"actionCommand ===> %s %@ %@",__func__,cmd,arguments);
        NSPipe *pipe = [NSPipe pipe];
        NSFileHandle *file = pipe.fileHandleForReading;
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = cmd;
        task.arguments = arguments;
        task.standardOutput = pipe;
        task.standardError = pipe;
        [task launch];
       
        NSData *dataPlist = [file readDataToEndOfFile];
        NSString *grepOutput = [[NSString alloc] initWithData: dataPlist encoding: NSUTF8StringEncoding];
        NSLog(@"%s output: %@",__func__,grepOutput);
        [task waitUntilExit];
        [file closeFile];
        if (![task isRunning])
        {
            int status = [task terminationStatus];
            if (status == 0) {
                NSLog(@"%s Task succeeded.",__func__);
                return YES;
            } else {
                NSLog(@"%s Task failed.",__func__);
                return NO;
            }
        }
        return NO;
    }
}

NSString *runCommandOutput = @"";
- (NSString *)runCommand:(NSString*)cmd param:(NSArray*)arguments
{
    @autoreleasepool {
        NSLog(@"%s %@ %@",__func__,cmd,arguments);
        NSPipe *pipe = [NSPipe pipe];
        NSFileHandle *file = pipe.fileHandleForReading;
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = cmd;
        if(arguments.count > 0)
            task.arguments = arguments;
        task.standardOutput = pipe;
        task.standardError = pipe;
        [task launch];
        
        NSData *dataPlist = [file readDataToEndOfFile];
        NSString *grepOutput = [[NSString alloc] initWithData: dataPlist encoding: NSUTF8StringEncoding];
        NSLog(@"%s output: %@",__func__,grepOutput);
        [task waitUntilExit];
        [file closeFile];
        if (![task isRunning])
        {
            int status = [task terminationStatus];
            if (status == 0) {
                NSLog(@"%s Task succeeded.",__func__);
                runCommandOutput = grepOutput;
                return grepOutput;
            } else {
                NSLog(@"%s Task failed.",__func__);
                return @"";
            }
        }
        return grepOutput;
    }
}

//dispatch_source_create(DISPATCH_SOURCE_TYPE_PROC, task.processIdentifier, DISPATCH_PROC_EXIT, dispatch_get_main_queue());

@end


