//
//  CellTableClass.h
//  EarseMac
//
//  Created by Greystone on 12/21/21.
//  Copyright © 2021 Greystone. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN
enum {
    CellNoDevice    = 0,//den tat           <=> chua co device
    CellHaveDevice  = 1,//den vang          <=> co device dang doc thong tin
    CellReady       = 2,//den xanh          <=> d9a dopc thogn tin thanh cong
    CellRunning     = 3,//den vang          <=> bat dau xoa
    CellChecking    = 4,//den vang          <=> write xong cho doc trang thay
    CellFinished    = 5,// xanh hoac do     <=> ket thuc
    CellCouldNotRead = 6, //do
    CellWaitPlugDevice = 7, //Vang
    
};

//Add new May 5 2022
enum {
    RESULT_PASSED   = 0,
    RESULT_FAILED   = 1,
    RESULT_NA       = 2,
};

//Add new May 5 2022
//Erase Verify
enum {
    VERIFY_DONE          = 0,
    VERIFY_NEED_TO_SEND  = 1,
    VERIFY_NOTHING       = 2,
};

//Add new May 5 2022
//Update data to cloud status
enum {
    UPDATE_STATUS_OK          = 0,
    UPDATE_STATUS_NOT_OK      = 1,
};

//Add new May 5 2022
//Erase status
#define ERASE_STATUS_PASSED "PASSED"
#define ERASE_STATUS_FAILED "FAILED"
#define ERASE_STATUS_NA     "N/A"



@interface CellTableClass : NSTableCellView
{
    id root;
    SEL selector;
    NSTimer *timerRun;
    unsigned long counttime;
    int heighHeaderItem;
    int num_board;
}
@property (strong) NSTextView *tvInfoDevice;// thong tin
@property (strong) NSImageView *imgResult;// ket qua o giua
@property (strong) NSButton *btStop;
@property (strong) NSButton *btInfo;
@property (strong) NSButton *btRescan;
@property (strong) NSButton *cbTitle;// chackbox A1....
@property (nonnull,strong) NSTextField *txtHeaderTime;
@property (nonnull,strong) NSButton *checkBox;
@property (nonnull,strong) NSImageView *imgStatus;// nguoi chay
@property (strong) NSMutableDictionary *dicInfoCell;// curent data fo cell
@property (assign) BOOL selected;
@property (assign) int current_state;
@property (assign) int heighHeaderItem;
@property (assign) unsigned long counttime;
@property (strong) NSView *viewContentOfCell;

- (void)setDelegate:(id)Class method:(SEL) sel;
- (id)initWithFrame:(NSRect)frame info:(NSMutableDictionary *)dic;
- (void)updateState:(int)state;
@end

NS_ASSUME_NONNULL_END
