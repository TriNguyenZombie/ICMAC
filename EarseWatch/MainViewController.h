//
//  DetaiViewController.h
//  EarseMac
//
//  Created by Greystone on 12/20/21.
//  Copyright © 2021 Greystone. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Realm/Realm.h>
#include <sys/sysctl.h>
#import "UITextField.h"


@class ProtocolHW;
@class ProccessUSB;
@class PrinterSetting;
@class DetailViewController;
@class AboutViewController;

NS_ASSUME_NONNULL_BEGIN

@interface MainViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, UITextFieldDelegate, NSTextFieldDelegate>
{
    NSTableView *tableView;// show interface
    NSScrollView *scrollContainer;
    NSButton *checkBox;
   
    NSMutableArray *arrDatabaseCell;// luu data use for cell
    NSMutableDictionary *dicDataCellBK;//  luu data khi xoa hoac khi vao DFU
    NSMutableArray *arrayBoard;// list info board usb
    int numboard;

    int numRow,numCol;
    int tbHeigh;
    
    ProccessUSB *libusb;
    ProtocolHW *protocolHW;

    NSMutableDictionary *dicInforconfig;// luu thong tin watch + file restore, get datta tu idevice_support.config
    
    
    NSTimer *timerCheckDevice;
   // unsigned long countTime;
    int numDevice;
    NSThread *myThread;
    NSThread *myThreadRemoveDevice;
    NSThread *myThreadUpdateUI;
    NSThread *myThreadEraseForEachCell;
    NSThread *threadCheckDownloadSW_FW;
    NSThread *threadDownloadSW_FW;
    
    NSThread *threadCheckFW_HW_Version;
    NSThread *threadMainRunning;
    NSThread *threadLogout;
    unsigned long checkInfoFlag;
    
    NSTextField *lbProcessed;
    BOOL isSelectAll;
    CGFloat cellSpacing;
    CGFloat cellHSpacing;
    
    ProtocolHW *mProtocolHW;
    
    BOOL xoaManual;// chua check kq sau cung bang cach read infor
    
    __strong id appDelegate;

    
    PrinterSetting *printSetting;
    NSWindowController *windowController;
    NSWindow *windowshow;
    NSTextField *txtItemID;
//    NSTextField *lbPleaseScanItemID;
    
    DetailViewController *info;
   
    NSString *strBatchNo;
    NSString *strLineNo;
    NSString *strWorkArea;
    NSString *strUserName;
    NSString *strLocation;
}
@property (strong, nonatomic) PrinterSetting *printSetting;
@property (strong, nonatomic) ProccessUSB *libusb;
@property (strong, nonatomic) NSTableView *tableView;
@property (strong, nonatomic) NSWindowController *windowController;
@property (strong, nonatomic) NSWindow *windowshow;
@property (strong, nonatomic) NSTextField *txtItemID;
//@property (strong, nonatomic) NSTextField *lbPleaseScanItemID;
- (void) createThreadToUpdateDBDeviceMapping:(NSArray*) arrDeviceMapping;
- (NSString*) get_ipsw_name;
//-(int)sendInfoToCloud:(NSMutableDictionary *)dicCell process:(NSString *)proccess station:(NSString*)stationSerial result:(NSString *)restoreResult error:(NSString *)strError posCell:(int)posCell;

@end

NS_ASSUME_NONNULL_END
