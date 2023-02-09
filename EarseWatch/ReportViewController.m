//
//  ReportViewController.m
//  iCombine Watch
//
//  Created by Duyet Le on 6/9/22.
//  Copyright © 2022 Greystone. All rights reserved.


//which irecovery 
//

#import "ReportViewController.h"
#import "AppDelegate.h"
#import "CellTableClassText.h"
#import "UITextFieldCell.h"

@interface ReportViewController ()<NSTableViewDelegate,NSTableViewDataSource>

@end

@implementation ReportViewController
- (id)initWithFrame:(CGRect)frame data:(NSMutableDictionary*)dic
{
    numRowOfPage = 10;
    self = [super init];
    self.view = [[NSView alloc] init];
    self.view.frame = frame;
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0].CGColor;
    self.view.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    int width = frame.size.width;
    int height = frame.size.height;
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    //=====================================
    NSView *viewTop = [[NSView alloc] initWithFrame:NSMakeRect(0, height - 30, width, 30)];
    viewTop.wantsLayer = YES;
    viewTop.layer.backgroundColor = delegate.colorBanner.CGColor;
    [self.view addSubview:viewTop];
    
    NSTextField *txtHeader = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 10, width-20, 20)];
    txtHeader.cell = [[NSTextFieldCell alloc] init];
    [viewTop addSubview:txtHeader];
    txtHeader.alignment = NSTextAlignmentLeft;
    txtHeader.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtHeader.backgroundColor = [NSColor clearColor];
    txtHeader.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtHeader.textColor = [NSColor whiteColor];
    txtHeader.stringValue = @"Report";
  
    NSButton *btCloseTop = [[NSButton alloc] initWithFrame:NSMakeRect(width - 30,5, 20, 20)];
    btCloseTop.title = @"";
    btCloseTop.image = [NSImage imageNamed:@"CloseWhite.png"];
    [[btCloseTop cell] setBackgroundColor:delegate.colorBanner];
    btCloseTop.wantsLayer = YES;
    [btCloseTop setBordered:NO];
    [btCloseTop setToolTip:@"Close"];
    [btCloseTop setTarget:self];
    [btCloseTop setAction:@selector(btCloseClick:)];
    [viewTop addSubview:btCloseTop];
    
    //================================================
    NSView *viewConten = [[NSView alloc] initWithFrame:NSMakeRect(20, 20, width-40, height - 70 )];
    viewConten.wantsLayer = YES;
    viewConten.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [self.view addSubview:viewConten];
    
    [self createViewSearch:viewConten];
    [self createViewData:viewConten];
    [self createViewAction:viewConten];
    
    
    return self;
}
//======================================================group view search============================================================
- (void) createViewSearch:(NSView *)parentView
{
    int top = 70;
    CGRect frame = parentView.frame;
    int width = frame.size.width;
    int height = frame.size.height;
    NSView *viewSearch = [[NSView alloc] initWithFrame:NSMakeRect(20, height - 120, width-40, 100 )];
    viewSearch.wantsLayer = YES;
    viewSearch.layer.borderWidth = 1;
    viewSearch.layer.backgroundColor = [NSColor clearColor].CGColor;
    [parentView addSubview:viewSearch];
    
    
    NSTextField *labelLocation = [[NSTextField alloc] initWithFrame:NSMakeRect(20, top, 80, 20)];
    labelLocation.cell = [[NSTextFieldCell alloc] init];
    labelLocation.alignment = NSTextAlignmentLeft;
    labelLocation.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    labelLocation.backgroundColor = [NSColor clearColor];
    labelLocation.layer.backgroundColor = [NSColor clearColor].CGColor;
    labelLocation.textColor = [NSColor blackColor];
    labelLocation.stringValue = @"Location";
    [viewSearch addSubview:labelLocation];
    
    NSMutableArray *itemLocation = [NSMutableArray arrayWithObjects:@"All",@"Dallat",@"Chicago", nil];
    NSPopUpButton *popupBTLocation = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(100, top-10, 180, 30)];
    [popupBTLocation removeAllItems];
    [popupBTLocation addItemsWithTitles:itemLocation];
    popupBTLocation.target = self;
    popupBTLocation.action = @selector(locationSelected:);
    [viewSearch addSubview:popupBTLocation];
    
    
    NSTextField *labelFrom = [[NSTextField alloc] initWithFrame:NSMakeRect(width/2 - 130, top, 60, 20)];
    labelFrom.cell = [[NSTextFieldCell alloc] init];
    labelFrom.alignment = NSTextAlignmentLeft;
    labelFrom.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    labelFrom.backgroundColor = [NSColor clearColor];
    labelFrom.layer.backgroundColor = [NSColor clearColor].CGColor;
    labelFrom.textColor = [NSColor blackColor];
    labelFrom.stringValue = @"From:";
    [viewSearch addSubview:labelFrom];
    
    NSDatePicker *pickerFrom = [[NSDatePicker alloc] initWithFrame:NSMakeRect(width/2 - 70, top-5, 200, 25)];
    pickerFrom.cell = [[NSDatePickerCell alloc] init];
    pickerFrom.target = self;
    pickerFrom.tag = 100;
    pickerFrom.wantsLayer = YES;
    pickerFrom.layer.borderWidth = 1;
    [pickerFrom setDateValue:[NSDate date]];
    pickerFrom.action = @selector(pickerSelected:);
    [viewSearch addSubview:pickerFrom];
    
    NSTextField *labelTo = [[NSTextField alloc] initWithFrame:NSMakeRect(width - 300, top, 50, 20)];
    labelTo.cell = [[NSTextFieldCell alloc] init];
    labelTo.alignment = NSTextAlignmentLeft;
    labelTo.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    labelTo.backgroundColor = [NSColor clearColor];
    labelTo.layer.backgroundColor = [NSColor clearColor].CGColor;
    labelTo.textColor = [NSColor blackColor];
    labelTo.stringValue = @"To:";
    [viewSearch addSubview:labelTo];
    
    NSDatePicker *pickerTo = [[NSDatePicker alloc] initWithFrame:NSMakeRect(width - 260, top-5, 200, 25)];
    pickerTo.cell = [[NSDatePickerCell alloc] init];
    pickerTo.target = self;
    pickerTo.tag = 101;
    pickerTo.wantsLayer = YES;
    pickerTo.layer.borderWidth = 1;
    [pickerTo setDateValue:[NSDate date]];
    pickerTo.action = @selector(pickerSelected:);
    [viewSearch addSubview:pickerTo];
    
    
//    NSButton *checkBox = [[NSButton alloc] initWithFrame:NSMakeRect(730,top, 150, 20)];
//    [checkBox setButtonType:NSSwitchButton];
//    //[checkBox setAction:@selector(cbSelectAllClick:)];
//    [checkBox setTitle:@"Re Print label"];
//    checkBox.font = [NSFont fontWithName:@"Roboto-Medium" size:16];
//    [checkBox setBezelStyle:0];
//    [checkBox setState:0];
//    [checkBox setWantsLayer:YES];
//    [viewSearch addSubview:checkBox];
//
    
    
    NSButton *btSearch = [[NSButton alloc] initWithFrame:NSMakeRect(width - 490,10, 130, 30)];
    [btSearch setFont:[NSFont fontWithName:@"Roboto-Regular" size:20]];
    btSearch.wantsLayer = YES;
    [btSearch setBordered:YES];
    btSearch.layer.cornerRadius = 5;
    btSearch.layer.borderWidth = 2;
    btSearch.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
    [btSearch setToolTip:@"Search with current data"];
    [btSearch setTarget:self];
    btSearch.image = [NSImage imageNamed:@"button_normal.png"];
    btSearch.title = @"Search";
    [btSearch setAction:@selector(btSearchClick:)];
    [viewSearch addSubview:btSearch];
    
    NSButton *btRefresh = [[NSButton alloc] initWithFrame:NSMakeRect(width - 340,10, 130, 30)];
    [btRefresh setFont:[NSFont fontWithName:@"Roboto-Regular" size:20]];
    btRefresh.wantsLayer = YES;
    [btRefresh setBordered:YES];
    btRefresh.layer.cornerRadius = 5;
    btRefresh.layer.borderWidth = 2;
    btRefresh.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
    [btRefresh setToolTip:@"Refresh"];
    [btRefresh setTarget:self];
    btRefresh.image = [NSImage imageNamed:@"button_normal.png"];
    btRefresh.title = @"Refresh";
    [btRefresh setAction:@selector(btRefreshClick:)];
    [viewSearch addSubview:btRefresh];
    
    NSButton *btExport = [[NSButton alloc] initWithFrame:NSMakeRect(width -190,10, 130, 30)];
    [btExport setFont:[NSFont fontWithName:@"Roboto-Regular" size:20]];
    btExport.wantsLayer = YES;
    [btExport setBordered:YES];
    btExport.layer.cornerRadius = 5;
    btExport.layer.borderWidth = 2;
    btExport.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
    [btExport setToolTip:@"Export"];
    [btExport setTarget:self];
    btExport.image = [NSImage imageNamed:@"button_normal.png"];
    btExport.title = @"Export";
    [btExport setAction:@selector(btExportClick:)];
    [viewSearch addSubview:btExport];
}
- (void) btSearchClick:(id)sender
{
    NSLog(@"%s search data",__func__);
}
- (void) btRefreshClick:(id)sender
{
    NSLog(@"%s search data",__func__);
}
- (void) btExportClick:(id)sender
{
    NSLog(@"%s search data",__func__);
}
- (void) pickerSelected:(id)sender
{
    NSDatePicker *pic = (NSDatePicker *)sender;
    NSDate *date = [pic dateValue];
    NSLog(@"%s date tag:%d select:%@",__func__,(int)pic.tag,date);
}
- (void) locationSelected:(id)sender
{
    NSMenuItem *selected = (NSMenuItem *)sender;
    NSLog(@"%s location selected : %@",__func__,selected);
}
//==================================================================================================================
- (void) createViewData:(NSView *)parentView
{
    
    arrayItem = [NSMutableArray array];
    for (int i=0; i<20; i++)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:i+1],@"stt",@"Nguyen van a",@"name",@"20",@"tuoi",@"123 nguyen van luon",@"diachi",@"trung ta",@"chucvu", nil];
        [arrayItem addObject:dic];
    }
   

    CGRect frame = parentView.frame;
    int width = frame.size.width;
    int height = frame.size.height;
    NSView *viewData = [[NSView alloc] initWithFrame:NSMakeRect(20, 100, width-40, height - 240 )];
    viewData.wantsLayer = YES;
    viewData.layer.borderWidth = 1;
    viewData.layer.backgroundColor = [NSColor clearColor].CGColor;
    [parentView addSubview:viewData];
    width = width - 40;
    height = height - 240;
    
    NSTableView *tableView = [[NSTableView alloc] init];
    tableView.wantsLayer = true;
    tableView.layer.borderWidth = 0;
    tableView.layer.borderColor = [NSColor blackColor].CGColor;
    tableView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    tableView.alignment = NSTextAlignmentCenter;
    tableView.backgroundColor = [NSColor clearColor];
    tableView.intercellSpacing = NSMakeSize(0, 0);
    tableView.rowSizeStyle = NSTableViewRowSizeStyleCustom;
    tableView.headerView = nil;
    int numCol = 5;
    for (int i = 0;i<numCol; i++)
    {
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"c%d",i]];
        column.width = 200;
        [tableView addTableColumn:column];
    }
    tableView.delegate = self;
    tableView.dataSource = self;
            
    if (@available(iOS 9, *))
    {
        tableView.style = NSTableViewStylePlain;
    }
    int heightOfRowNew = 60;
    CGFloat heighttemp = (CGFloat)(arrayItem.count*heightOfRowNew);
    tableView.frame = NSMakeRect(0, 10, width, heighttemp);
    NSScrollView *scrollViewTableView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 10, width, height - 20 )];
    scrollViewTableView.documentView = tableView;
    scrollViewTableView.translatesAutoresizingMaskIntoConstraints = false;
    scrollViewTableView.layer.borderWidth = 0;
    //scrollViewTableView.frame = tableView.frame;
    [viewData addSubview:scrollViewTableView];
    
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    return arrayItem.count;
}
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 50;;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn  row:(NSInteger)row {
    NSLog(@"%s colume:%@, row:%ld",__func__,tableColumn.identifier,row);
    [tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone]; // clear color blue select row
    [tableView setFocusRingType:NSFocusRingTypeNone];
    int col = [[[tableColumn identifier] stringByReplacingOccurrencesOfString:@"c" withString:@""] intValue];
    NSDictionary *dic = arrayItem[row];
   // [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:i+1],@"stt",@"Nguyen van a",@"name",@"20",@"tuoi",@"123 nguyen van luon",@"diachi",@"trung ta",@"chucvu", nil];
    NSString *str = @"";
    switch (col)
    {
        case 0:str = [NSString stringWithFormat:@"%d",(int)(row+1)]; break;
        case 1:str = [NSString stringWithFormat:@"%@",[dic objectForKey:@"name"]]; break;
        case 2:str = [NSString stringWithFormat:@"%@",[dic objectForKey:@"tuoi"]]; break;
        case 3:str = [NSString stringWithFormat:@"%@",[dic objectForKey:@"diachi"]]; break;
        case 4:str = [NSString stringWithFormat:@"%@",[dic objectForKey:@"chucvu"]]; break;
        default: break;
    }
    int numCol = 5;
    CellTableClassText *cell = [[CellTableClassText alloc] initWithFrame:NSMakeRect(0, 0, (tableView.frame.size.width)/numCol, 48)];
    cell.wantsLayer = true;
    cell.layer.borderWidth = 0;
    cell.layer.borderColor = [NSColor blackColor].CGColor;
    cell.identifier = tableColumn.identifier;
    cell.aTextField.stringValue = str;
    cell.aTextField.wantsLayer = true;
    cell.aTextField.layer.borderWidth = 1;
    cell.aTextField.alignment = NSTextAlignmentCenter;
    cell.aTextField.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    return cell;
    
}


//==================================================================================================================
- (void) createViewAction:(NSView *)parentView
{
    CGRect frame = parentView.frame;
    int width = frame.size.width;
    //int height = frame.size.height;
    NSView *viewAction = [[NSView alloc] initWithFrame:NSMakeRect(20, 20, width-40, 60)];
    viewAction.wantsLayer = YES;
    viewAction.layer.borderWidth = 1;
    viewAction.layer.backgroundColor = [NSColor clearColor].CGColor;
    [parentView addSubview:viewAction];
    
    
    int page = 0;
    int numpage = (int)arrayItem.count/numRowOfPage;
    if(arrayItem.count%numRowOfPage>0)
        numpage += 1;
    
    NSTextField *labeldisplay = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 15, 200, 30)];
    labeldisplay.cell = [[UITextFieldCell alloc] init];
    labeldisplay.alignment = NSTextAlignmentLeft;
    labeldisplay.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    labeldisplay.backgroundColor = [NSColor clearColor];
    labeldisplay.layer.backgroundColor = [NSColor clearColor].CGColor;
    labeldisplay.textColor = [NSColor blackColor];
    long begin = page*numRowOfPage+1;
    long end = (arrayItem.count - begin)>numRowOfPage?numRowOfPage:arrayItem.count - begin;
    labeldisplay.stringValue = [NSString stringWithFormat:@"Displaying %ld-%ld of %ld",begin,end,arrayItem.count];
    [viewAction addSubview:labeldisplay];
    
    
    NSButton *btPageLast = [[NSButton alloc] initWithFrame:NSMakeRect(200,10, 40, 40)];
    [btPageLast setFont:[NSFont fontWithName:@"Roboto-Regular" size:20]];
    btPageLast.wantsLayer = YES;
    [btPageLast setBordered:YES];
    btPageLast.layer.cornerRadius = 5;
    btPageLast.layer.borderWidth = 2;
    btPageLast.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
    [btPageLast setToolTip:@"Page last"];
    [btPageLast setTarget:self];
    btPageLast.image = [NSImage imageNamed:@"button_normal.png"];
    btPageLast.title = @"<";
    [btPageLast setAction:@selector(btPageLastClick:)];
    [viewAction addSubview:btPageLast];
    
    NSButton *btPageNext = [[NSButton alloc] initWithFrame:NSMakeRect(260,10, 40, 40)];
    [btPageNext setFont:[NSFont fontWithName:@"Roboto-Regular" size:20]];
    btPageNext.wantsLayer = YES;
    [btPageNext setBordered:YES];
    btPageNext.layer.cornerRadius = 5;
    btPageNext.layer.borderWidth = 2;
    btPageNext.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
    [btPageNext setToolTip:@"Page next"];
    [btPageNext setTarget:self];
    btPageNext.image = [NSImage imageNamed:@"button_normal.png"];
    btPageNext.title = @">";
    [btPageNext setAction:@selector(btPageNextClick:)];
    [viewAction addSubview:btPageNext];
    
    NSButton *btPrintPreview = [[NSButton alloc] initWithFrame:NSMakeRect( width/2 -230,10, 160, 40)];
    [btPrintPreview setFont:[NSFont fontWithName:@"Roboto-Regular" size:20]];
    btPrintPreview.wantsLayer = YES;
    [btPrintPreview setBordered:YES];
    btPrintPreview.layer.cornerRadius = 5;
    btPrintPreview.layer.borderWidth = 2;
    btPrintPreview.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
    [btPrintPreview setToolTip:@"Print preview"];
    [btPrintPreview setTarget:self];
    btPrintPreview.image = [NSImage imageNamed:@"button_normal.png"];
    btPrintPreview.title = @"Print preview";
    [btPrintPreview setAction:@selector(btPrintPreviewClick:)];
    [viewAction addSubview:btPrintPreview];
    
    NSButton *btEmailReport = [[NSButton alloc] initWithFrame:NSMakeRect(width/2 - 50,10, 160, 40)];
    [btEmailReport setFont:[NSFont fontWithName:@"Roboto-Regular" size:20]];
    btEmailReport.wantsLayer = YES;
    [btEmailReport setBordered:YES];
    btEmailReport.layer.cornerRadius = 5;
    btEmailReport.layer.borderWidth = 2;
    btEmailReport.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
    [btEmailReport setToolTip:@"Email report"];
    [btEmailReport setTarget:self];
    btEmailReport.image = [NSImage imageNamed:@"button_normal.png"];
    btEmailReport.title = @"Email report";
    [btEmailReport setAction:@selector(btPrintPreviewClick:)];
    [viewAction addSubview:btEmailReport];
    
//    NSButton *btExport = [[NSButton alloc] initWithFrame:NSMakeRect(760,10, 160, 40)];
//    [btExport setFont:[NSFont fontWithName:@"Roboto-Regular" size:20]];
//    btExport.wantsLayer = YES;
//    [btExport setBordered:YES];
//    btExport.layer.cornerRadius = 5;
//    btExport.layer.borderWidth = 2;
//    btExport.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
//    [btExport setToolTip:@"Export"];
//    [btExport setTarget:self];
//    btExport.image = [NSImage imageNamed:@"button_normal.png"];
//    btExport.title = @"Export";
//    [btExport setAction:@selector(btExportClick:)];
//    [viewAction addSubview:btExport];
//
    NSButton *btCancel = [[NSButton alloc] initWithFrame:NSMakeRect(width/2 + 130,10, 100, 40)];
    [btCancel setFont:[NSFont fontWithName:@"Roboto-Regular" size:20]];
    btCancel.wantsLayer = YES;
    [btCancel setBordered:YES];
    btCancel.layer.cornerRadius = 5;
    btCancel.layer.borderWidth = 2;
    btCancel.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
    [btCancel setToolTip:@"Cancel"];
    [btCancel setTarget:self];
    btCancel.image = [NSImage imageNamed:@"button_normal.png"];
    btCancel.title = @"Cancel";
    [btCancel setAction:@selector(btExportClick:)];
    [viewAction addSubview:btCancel];
}
//- (void)btExportClick:(id)sender
//{
//    NSLog(@"%s ",__func__);
//}
- (void)btPrintPreviewClick:(id)sender
{
    NSLog(@"%s ",__func__);
}
- (void)btPageLastClick:(id)sender
{
    NSLog(@"%s ",__func__);
}
- (void)btPageNextClick:(id)sender
{
    NSLog(@"%s ",__func__);
}

//====================================================================================================
- (void)showWindow
{
    
    NSWindow *window = [NSWindow windowWithContentViewController:self];
    [window center];
    [window setBackgroundColor:[NSColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0]];
    [window setContentSize:NSSizeFromCGSize(CGSizeMake(self.view.frame.size.width, self.view.frame.size.height))];
    window.title = @"iCombine Watch";
    window.contentViewController = self;
    [window setLevel:NSFloatingWindowLevel];
    [window setStyleMask:NSBorderlessWindowMask];
    NSWindowController *windowControllerIF = [[NSWindowController alloc] initWithWindow:window];
    [windowControllerIF.window makeKeyAndOrderFront:self];
    [windowControllerIF showWindow:nil];
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (void)btCloseClick:(id)sender
{
    [self.view.window close];
    
}
@end
