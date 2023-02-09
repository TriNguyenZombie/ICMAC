//
//  PrinterSetting.m
//  EarseMac
//
//  Created by Duyet Le on 5/6/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import "PrinterSetting.h"
#import "AppDelegate.h"
//#import "UITextFieldCell.h"

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AppKit/AppKit.h>
#import <CoreImage/CIFilter.h>
#import "CellTableClass.h"
#import "ZXImage.h"
#import "ZXingObjC/ZXBarcodeFormat.h"
#import "ZXMultiFormatWriter.h"


@interface PrinterSetting ()<NSComboBoxDelegate>
@end

@implementation PrinterSetting
@synthesize txtLeftMargin;
@synthesize txtRightMargin;
@synthesize txtTopMargin;
@synthesize txtBottomMargin;
@synthesize autoPrint;
@synthesize pageWidth;
@synthesize pageHeight;
- (id)initWithFrame:(CGRect)frameRect data:(NSMutableDictionary*)dic
{
    self = [super init];
    dicMapValue = nil;
 //   dicConfig = [self getConfig];
    dicInfor = dic;
    deviceInfoArray = (NSMutableArray *)[dicInfor objectForKey:@"DataPrint"];
    
  //  NSColor *colorCFBG = [NSColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0];
    self.view = [[NSView alloc] init];
    self.view.frame = frameRect;
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.view.wantsLayer = YES;
    
    width = frameRect.size.width;
    int height = frameRect.size.height;
    
    autoPrint = YES;
    leftMargin = 0;
    rightMargin = 0;
    topMargin = 0;
    bottomMargin = 0;
    fontSize = 9;
    
    dvpx = 96;// 1 inch 96 picel
    pageWidth = 2.11*dvpx;//288;// 3 inch =>  1 inch 96 picel
    pageHeight= 1.25*dvpx;//192;// 2 inch
    //w:207 - h:120
    
//    dvpx = 37.7952755906;// 1cm  = 37.7952755906 px
//    pageWidth = 5.5*dvpx;// 5.5 cm =>  1 cm 37.7952755906 picel
//    pageHeight = 3.2*dvpx;// 4 cm
//
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
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
    txtHeader.stringValue = @"Printer";
//    txtHeader.layer.borderColor = [NSColor yellowColor].CGColor;
//    txtHeader.layer.borderWidth = 2;
//    txtHeader.backgroundColor = [NSColor blueColor];
//    txtHeader.drawsBackground = YES;
//    txtHeader.wantsLayer = YES;
  
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
   
    NSButton *btCancel = [[NSButton alloc] initWithFrame:NSMakeRect(2*width/3 - 70,20, 140, 44)];
    [btCancel setFont:[NSFont fontWithName:@"Roboto-Regular" size:20]];
//    [btCancel setContentTintColor:[NSColor colorWithRed:30.0/255 green:30.0/255 blue:30.0/255 alpha:1.0]];
    btCancel.wantsLayer = YES;
    [btCancel setBordered:YES];
    btCancel.layer.cornerRadius = 5;
    btCancel.layer.borderWidth = 2;
    btCancel.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
    [btCancel setToolTip:@"Cancel"];
    [btCancel setTarget:self];
    btCancel.image = [NSImage imageNamed:@"button_normal.png"];
    btCancel.title = @"Cancel";
    [btCancel setAction:@selector(btCloseClick:)];
    [self.view addSubview:btCancel];
    
    NSButton *btPrint = [[NSButton alloc] initWithFrame:NSMakeRect(width/3 - 70,20, 140, 44)];
    [btPrint setFont:[NSFont fontWithName:@"Roboto-Regular" size:20]];
    btPrint.wantsLayer = YES;
    [btPrint setBordered:YES];
    btPrint.layer.cornerRadius = 5;
    btPrint.layer.borderWidth = 2;
    btPrint.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
    [btPrint setToolTip:@"Print"];
    [btPrint setTarget:self];
    btPrint.image = [NSImage imageNamed:@"button_normal.png"];
    btPrint.title = @"Print";
    [btPrint setAction:@selector(btPrintClick:)];
    [self.view addSubview:btPrint];
    

   
    
    int hei_label = 24;
    int hei_tb = 35, wid_tb = 120, kc_tb = 50,font_tb = 18;
    //%%%%%%%%%%%%%%%%%%%%%%%%%%:Setting:%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    int heightGroupSetting = 250;
    
    viewGroupSetting = [[NSView alloc] initWithFrame:NSMakeRect(10, height-300, width - 20, heightGroupSetting)];
    viewGroupSetting.wantsLayer = YES;
    viewGroupSetting.layer.backgroundColor = [NSColor whiteColor].CGColor;
    viewGroupSetting.layer.borderWidth = 1.0;
    viewGroupSetting.layer.borderColor = [NSColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0].CGColor;
    [self.view addSubview:viewGroupSetting];
    
    NSTextField *txtHeaderGroupPrintSettingLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(30, height-56, 130, hei_label)];
    txtHeaderGroupPrintSettingLabel.alignment = NSTextAlignmentCenter;
    txtHeaderGroupPrintSettingLabel.cell = [[NSTextFieldCell alloc] init];
    txtHeaderGroupPrintSettingLabel.stringValue = @"  Print settings";
    txtHeaderGroupPrintSettingLabel.layer.borderWidth = 1;
    txtHeaderGroupPrintSettingLabel.layer.borderColor = [NSColor blackColor].CGColor;
    [txtHeaderGroupPrintSettingLabel setEditable:NO];
    txtHeaderGroupPrintSettingLabel.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtHeaderGroupPrintSettingLabel.backgroundColor = [NSColor whiteColor];
    txtHeaderGroupPrintSettingLabel.drawsBackground = YES;
    txtHeaderGroupPrintSettingLabel.textColor = [NSColor blackColor];
    [self.view addSubview:txtHeaderGroupPrintSettingLabel];
    //=================================conten setting======================================
  
    [self getAndSetValueConfig];
    NSMutableDictionary *dicCF =[self getConfig];
//    return self;
    //-------------------------------------left txt config
    NSTextField *leftMarginLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(50,heightGroupSetting-kc_tb+6 , 150, hei_label)];
    leftMarginLabel.alignment = NSTextAlignmentLeft;
    leftMarginLabel.cell = [[NSTextFieldCell alloc] init];
    leftMarginLabel.stringValue = @"Left Margin";
    leftMarginLabel.layer.borderWidth = 1;
    [leftMarginLabel setEditable:NO];
    leftMarginLabel.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    leftMarginLabel.backgroundColor = [NSColor whiteColor];;
    leftMarginLabel.drawsBackground = YES;
    leftMarginLabel.textColor = [NSColor blackColor];
    [viewGroupSetting addSubview:leftMarginLabel];
    
    txtLeftMargin = [[UITextField alloc] initWithFrame:NSMakeRect(150, heightGroupSetting-kc_tb, wid_tb, hei_tb)];
    txtLeftMargin.cell = [[NSTextFieldCell alloc] init];
    [viewGroupSetting addSubview:txtLeftMargin];
    [txtLeftMargin.cell setFocusRingType:NSFocusRingTypeDefault];
    txtLeftMargin.placeholderString = @"Left margin";
    txtLeftMargin.alignment = NSTextAlignmentLeft;
    txtLeftMargin.font = [NSFont fontWithName:@"Roboto-Regular" size:font_tb];
    txtLeftMargin.bordered = YES;
    txtLeftMargin.wantsLayer = YES;
    txtLeftMargin.editable = YES;
    txtLeftMargin.backgroundColor = [NSColor clearColor];
    if(dicCF && [dicCF objectForKey:@"left_margin"])
        txtLeftMargin.stringValue = [dicCF objectForKey:@"left_margin"];
    else txtLeftMargin.stringValue = @"0.00";
    txtLeftMargin.delegate = self;

    
    
  
    //-------------------------------------right txt config
    NSTextField *rightMarginLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(50,heightGroupSetting-2*kc_tb+6 , 150, hei_label)];
    rightMarginLabel.alignment = NSTextAlignmentLeft;
    rightMarginLabel.cell = [[NSTextFieldCell alloc] init];
    rightMarginLabel.stringValue = @"Right Margin";
    rightMarginLabel.layer.borderWidth = 1;
    [rightMarginLabel setEditable:NO];
    rightMarginLabel.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    rightMarginLabel.backgroundColor = [NSColor whiteColor];;
    rightMarginLabel.drawsBackground = YES;
    rightMarginLabel.textColor = [NSColor blackColor];
    [viewGroupSetting addSubview:rightMarginLabel];
    
    UITextField *TextFieldR = [[UITextField alloc] initWithFrame:NSMakeRect(150, heightGroupSetting-2*kc_tb, wid_tb, hei_tb)];
    TextFieldR.cell = [[NSTextFieldCell alloc] init];
    [viewGroupSetting addSubview:TextFieldR];
    [TextFieldR.cell setFocusRingType:NSFocusRingTypeNone];
    TextFieldR.placeholderString = @"Right margin";
    TextFieldR.alignment = NSTextAlignmentLeft;
    TextFieldR.font = [NSFont fontWithName:@"Roboto-Regular" size:font_tb];
    TextFieldR.bordered = YES;
    TextFieldR.wantsLayer = YES;
    TextFieldR.editable = YES;
    TextFieldR.backgroundColor = [NSColor clearColor];
    if(dicCF && [dicCF objectForKey:@"right_margin"])
        TextFieldR.stringValue = [dicCF objectForKey:@"right_margin"];
    else TextFieldR.stringValue = @"0.00";
    txtRightMargin = TextFieldR;
    //---------------------------------------------------top
    
    NSTextField *topMarginLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(290,heightGroupSetting-kc_tb+6 , 150, hei_label)];
    topMarginLabel.alignment = NSTextAlignmentLeft;
    topMarginLabel.cell = [[NSTextFieldCell alloc] init];
    topMarginLabel.stringValue = @"Top Margin";
    topMarginLabel.layer.borderWidth = 1;
    [topMarginLabel setEditable:NO];
    topMarginLabel.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    topMarginLabel.backgroundColor = [NSColor whiteColor];;
    topMarginLabel.drawsBackground = YES;
    topMarginLabel.textColor = [NSColor blackColor];
    [viewGroupSetting addSubview:topMarginLabel];
    
    UITextField *TextFieldT = [[UITextField alloc] initWithFrame:NSMakeRect(420, heightGroupSetting-kc_tb, wid_tb, hei_tb)];
    TextFieldT.cell = [[NSTextFieldCell alloc] init];
    [viewGroupSetting addSubview:TextFieldT];
    [TextFieldT.cell setFocusRingType:NSFocusRingTypeNone];
    TextFieldT.placeholderString = @"Top margin";
    TextFieldT.alignment = NSTextAlignmentLeft;
    TextFieldT.font = [NSFont fontWithName:@"Roboto-Regular" size:font_tb];
    TextFieldT.bordered = YES;
    TextFieldT.wantsLayer = YES;
    TextFieldT.editable = YES;
    TextFieldT.backgroundColor = [NSColor clearColor];
    if(dicCF && [dicCF objectForKey:@"right_margin"])
        TextFieldT.stringValue = [dicCF objectForKey:@"top_margin"];
    else TextFieldT.stringValue = @"0.00";
    TextFieldT.delegate = self;
    txtTopMargin = TextFieldT;
    
    //---------------------------------------------------bottom
    
    NSTextField *bottomMarginLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(290,heightGroupSetting-2*kc_tb+6 , 150, hei_label)];
    bottomMarginLabel.alignment = NSTextAlignmentLeft;
    bottomMarginLabel.cell = [[NSTextFieldCell alloc] init];
    bottomMarginLabel.stringValue = @"Bottom Margin";
    bottomMarginLabel.layer.borderWidth = 1;
    [bottomMarginLabel setEditable:NO];
    bottomMarginLabel.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    bottomMarginLabel.backgroundColor = [NSColor whiteColor];;
    bottomMarginLabel.drawsBackground = YES;
    bottomMarginLabel.textColor = [NSColor blackColor];
    [viewGroupSetting addSubview:bottomMarginLabel];
    
    UITextField *TextFieldB = [[UITextField alloc] initWithFrame:NSMakeRect(420, heightGroupSetting-2*kc_tb, wid_tb, hei_tb)];
    TextFieldB.cell = [[NSTextFieldCell alloc] init];
    [viewGroupSetting addSubview:TextFieldB];
    [TextFieldB.cell setFocusRingType:NSFocusRingTypeNone];
    TextFieldB.placeholderString = @"Bottom margin";
    TextFieldB.alignment = NSTextAlignmentLeft;
    TextFieldB.font = [NSFont fontWithName:@"Roboto-Regular" size:font_tb];
    TextFieldB.bordered = YES;
    TextFieldB.wantsLayer = YES;
    TextFieldB.editable = YES;
    TextFieldB.backgroundColor = [NSColor clearColor];
    if(dicCF && [dicCF objectForKey:@"bottom_margin"])
        TextFieldB.stringValue = [dicCF objectForKey:@"bottom_margin"];
    else TextFieldB.stringValue = @"0.00";
    txtBottomMargin = TextFieldB;
    
    //-------------------------------------size config
    NSTextField *sizeTextLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(50,heightGroupSetting-3*kc_tb+6 , 150, hei_label)];
    sizeTextLabel.alignment = NSTextAlignmentLeft;
    sizeTextLabel.cell = [[NSTextFieldCell alloc] init];
    sizeTextLabel.stringValue = @"Size text:";
    sizeTextLabel.layer.borderWidth = 1;
    [sizeTextLabel setEditable:NO];
    sizeTextLabel.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    sizeTextLabel.backgroundColor = [NSColor whiteColor];;
    sizeTextLabel.drawsBackground = YES;
    sizeTextLabel.textColor = [NSColor blackColor];
    [viewGroupSetting addSubview:sizeTextLabel];
    
    UITextField *TextFieldSize = [[UITextField alloc] initWithFrame:NSMakeRect(150, heightGroupSetting-3*kc_tb, wid_tb, hei_tb)];
    TextFieldSize.cell = [[NSTextFieldCell alloc] init];
    [viewGroupSetting addSubview:TextFieldSize];
    [TextFieldSize.cell setFocusRingType:NSFocusRingTypeNone];
    TextFieldSize.placeholderString = @"size";
    TextFieldSize.alignment = NSTextAlignmentLeft;
    TextFieldSize.font = [NSFont fontWithName:@"Roboto-Regular" size:font_tb];
    TextFieldSize.bordered = YES;
    TextFieldSize.wantsLayer = YES;
    TextFieldSize.editable = YES;
    TextFieldSize.backgroundColor = [NSColor clearColor];
    TextFieldSize.stringValue = [NSString stringWithFormat:@"%d",fontSize];
    TextFieldSize.delegate = self;
    txtTextFieldSize = TextFieldSize;
   // [txtTextFieldSize.window makeFirstResponder:nil];
    
    //---------------------------------------------------
    
    
    
    
    NSButton *checkBox = [[NSButton alloc] initWithFrame:NSMakeRect(50,heightGroupSetting-4*kc_tb+5, 250, 20)];
    checkBox.image = [NSImage imageNamed:@"BoxChecked.png"];
    checkBox.imagePosition = NSImageLeft;
    checkBox.imageScaling = NSImageScaleProportionallyUpOrDown;
    checkBox.title = @"  Auto-print after completing";
    checkBox.alignment = NSTextAlignmentLeft;
    [checkBox.cell setBackgroundColor:[NSColor clearColor]];
    NSMutableAttributedString *atribute = [delegate setColorTitleFor:checkBox color:[NSColor blackColor] size:16];
    [checkBox setAttributedTitle:atribute];
    checkBox.layer.borderWidth = 0.0;
    checkBox.layer.cornerRadius = 4.0;
    checkBox.wantsLayer = YES;
    checkBox.bordered = NO;
    checkBox.font = [NSFont fontWithName:@"Roboto-Regular" size:16];;
    [checkBox setTarget:self];
    [checkBox setAction:@selector(autoPrintAfterComplete:)];
    checkBox.state = 0;
    if(autoPrint == NO)
    {
        checkBox.state = 0;
        checkBox.image = [NSImage imageNamed:@"BoxUncheck.png"];
    }
    [viewGroupSetting addSubview:checkBox];

    //---------------------------------------------------page size width
    
    NSTextField *pageWidthLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(290,heightGroupSetting-3*kc_tb+6 , 150, hei_label)];
    pageWidthLabel.alignment = NSTextAlignmentLeft;
    pageWidthLabel.cell = [[NSTextFieldCell alloc] init];
    pageWidthLabel.stringValue = @"Pape width:";
    pageWidthLabel.layer.borderWidth = 1;
    [pageWidthLabel setEditable:NO];
    pageWidthLabel.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    pageWidthLabel.backgroundColor = [NSColor whiteColor];;
    pageWidthLabel.drawsBackground = YES;
    pageWidthLabel.textColor = [NSColor blackColor];
    [viewGroupSetting addSubview:pageWidthLabel];
    
    UITextField *TextFieldPageWidth = [[UITextField alloc] initWithFrame:NSMakeRect(420, heightGroupSetting-3*kc_tb, wid_tb, hei_tb)];
    TextFieldPageWidth.cell = [[NSTextFieldCell alloc] init];
    [viewGroupSetting addSubview:TextFieldPageWidth];
    [TextFieldPageWidth.cell setFocusRingType:NSFocusRingTypeNone];
    TextFieldPageWidth.placeholderString = @"Page width";
    TextFieldPageWidth.alignment = NSTextAlignmentLeft;
    TextFieldPageWidth.font = [NSFont fontWithName:@"Roboto-Regular" size:font_tb];
    TextFieldPageWidth.bordered = YES;
    TextFieldPageWidth.wantsLayer = YES;
    TextFieldPageWidth.editable = YES;
    TextFieldPageWidth.backgroundColor = [NSColor clearColor];
    if(dicCF && [dicCF objectForKey:@"page_width"])
        TextFieldPageWidth.stringValue = [dicCF objectForKey:@"page_width"];
    else TextFieldPageWidth.stringValue = [NSString stringWithFormat:@"%.2f",(float)(pageWidth*1.0/dvpx)];
   // TextFieldPageWidth.stringValue = [dicCF objectForKey:@"page_width"];//[NSString stringWithFormat:@"%.2f",(float)(pageWidth*1.0/dvpx)];
    //TextFieldPageWidth.stringValue = [NSString stringWithFormat:@"%.2f",(float)(5.5)];
    txtPageWidth = TextFieldPageWidth;
   
    //---------------------------------------------------page size height
    
    NSTextField *pageHeightLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(290,heightGroupSetting-4*kc_tb+6 , 150, hei_label)];
    pageHeightLabel.alignment = NSTextAlignmentLeft;
    pageHeightLabel.cell = [[NSTextFieldCell alloc] init];
    pageHeightLabel.stringValue = @"Pape height:";
    pageHeightLabel.layer.borderWidth = 1;
    [pageHeightLabel setEditable:NO];
    pageHeightLabel.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    pageHeightLabel.backgroundColor = [NSColor whiteColor];;
    pageHeightLabel.drawsBackground = YES;
    pageHeightLabel.textColor = [NSColor blackColor];
    [viewGroupSetting addSubview:pageHeightLabel];
    
    UITextField *TextFieldPageHeight = [[UITextField alloc] initWithFrame:NSMakeRect(420, heightGroupSetting-4*kc_tb, wid_tb, hei_tb)];
    TextFieldPageHeight.cell = [[NSTextFieldCell alloc] init];
    [viewGroupSetting addSubview:TextFieldPageHeight];
    [TextFieldPageHeight.cell setFocusRingType:NSFocusRingTypeNone];
    TextFieldPageHeight.placeholderString = @"Page height";
    TextFieldPageHeight.alignment = NSTextAlignmentLeft;
    TextFieldPageHeight.font = [NSFont fontWithName:@"Roboto-Regular" size:font_tb];
    TextFieldPageHeight.bordered = YES;
    TextFieldPageHeight.wantsLayer = YES;
    TextFieldPageHeight.editable = YES;
    TextFieldPageHeight.backgroundColor = [NSColor clearColor];
    if(dicCF && [dicCF objectForKey:@"page_width"])
        TextFieldPageHeight.stringValue = [dicCF objectForKey:@"page_height"];
    else TextFieldPageHeight.stringValue = [NSString stringWithFormat:@"%.2f",(float)(pageHeight*1.0/dvpx)];
    //TextFieldPageHeight.stringValue = [dicCF objectForKey:@"page_height"];
    //TextFieldPageHeight.stringValue = [NSString stringWithFormat:@"%.2f",4.00];
    txtPageHeight = TextFieldPageHeight;
    //---------------------------------------------------Select printer
//    NSButton *btSelectPrinter = [[NSButton alloc] initWithFrame:NSMakeRect(50, heightGroupSetting-200, 300, 30)];
//    [btSelectPrinter setFont:[NSFont fontWithName:@"Roboto-Regular" size:20]];
//    btSelectPrinter.wantsLayer = YES;
//    [btSelectPrinter setBordered:YES];
//    btSelectPrinter.layer.cornerRadius = 5;
//    btSelectPrinter.layer.borderWidth = 2;
//    btSelectPrinter.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
//    [btSelectPrinter setToolTip:@"Printer"];
//    [btSelectPrinter setTarget:self];
//   // btSelectPrinter.image = [NSImage imageNamed:@"bt_print_enable.png"];
//    btSelectPrinter.title = @"Select Printer";
//    [btSelectPrinter setAction:@selector(btSelectPrinterClick:)];
//    [viewGroupSetting addSubview:btSelectPrinter];
    
    
    NSTextField *printerLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(50,heightGroupSetting-5*kc_tb+15 , 150, hei_label)];
    printerLabel.alignment = NSTextAlignmentLeft;
    printerLabel.cell = [[NSTextFieldCell alloc] init];
    printerLabel.stringValue = @"Select printer";
    printerLabel.layer.borderWidth = 1;
    [printerLabel setEditable:NO];
    printerLabel.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    printerLabel.backgroundColor = [NSColor whiteColor];;
    printerLabel.drawsBackground = YES;
    printerLabel.textColor = [NSColor blackColor];
    [viewGroupSetting addSubview:printerLabel];
    
    NSArray *items = [NSPrinter printerNames];//@[@"Apple", @"Ball", @"Cat", @"Doll"];
    comboBox = [[NSComboBox alloc] initWithFrame:NSMakeRect(150, heightGroupSetting-5*kc_tb+10, 300, 30)];
    comboBox.font = [NSFont systemFontOfSize:16];
    comboBox.backgroundColor = [NSColor whiteColor];
    [comboBox setDrawsBackground:YES];
    [comboBox setEditable:NO];
    [viewGroupSetting addSubview:comboBox];
    [comboBox removeAllItems];
    [comboBox addItemsWithObjectValues:items];
    int selectprinter =-1;
    if(printername != nil)
    {
        for (int i=0; i<items.count; i++)
        {
            NSString *name = items[i];
            if([printername isEqualToString:name] == YES)
            {
                selectprinter = i;
                break;
            }
        }
        if(selectprinter != -1)
            [comboBox selectItemAtIndex:selectprinter];
    }
    else
    {
        if(items.count>0)
            [comboBox selectItemAtIndex:0];
    }
    //%%%%%%%%%%%%%%%%%%%%%%%%%:Print conten:%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    heightviewPreview = 380;
    widthviewPreview = width - 20;
    NSView *viewPrintPreview = [[NSView alloc] initWithFrame:NSMakeRect(10, 100, widthviewPreview, heightviewPreview)];
    viewPrintPreview.wantsLayer = YES;
    viewPrintPreview.layer.backgroundColor = [NSColor whiteColor].CGColor;
    viewPrintPreview.layer.borderWidth = 1.0;
    viewPrintPreview.layer.borderColor = [NSColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0].CGColor;
    [self.view addSubview:viewPrintPreview];
    //viewPrint = viewPrintPreview;
    
    NSTextField *txtHeaderGroupPrintPreviewLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(30, 472, 140, hei_label)];
    txtHeaderGroupPrintPreviewLabel.alignment = NSTextAlignmentCenter;
    txtHeaderGroupPrintPreviewLabel.cell = [[NSTextFieldCell alloc] init];
    txtHeaderGroupPrintPreviewLabel.stringValue = @"  Printing preview";
    [txtHeaderGroupPrintPreviewLabel setEditable:NO];
    txtHeaderGroupPrintPreviewLabel.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtHeaderGroupPrintPreviewLabel.backgroundColor = [NSColor whiteColor];;
    txtHeaderGroupPrintPreviewLabel.drawsBackground = YES;
    txtHeaderGroupPrintPreviewLabel.layer.borderWidth = 1;
    txtHeaderGroupPrintPreviewLabel.textColor = [NSColor blackColor];
    [self.view addSubview:txtHeaderGroupPrintPreviewLabel];
    
    //%%%%%%%%%%%%%%%%%%%%%%%%%%%:viewPrint data:%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    NSImage *image;
    for(int i=0;i<deviceInfoArray.count;i++)
    {
        NSMutableDictionary *dicInfo = [deviceInfoArray objectAtIndex:i];
        viewPrint = [self createViewPrinter:dicInfo];
        image = [self imageRepresentation:viewPrint];
        break;
    }
    float tile = 2.0/4;
   // NSRect rect = NSMakeRect(widthviewPreview/2 - ( (heightviewPreview*207.0/120)*tile)/2, heightviewPreview*0.5*(1-tile), (heightviewPreview*207.0/120)*tile, heightviewPreview*tile);
    NSRect rect = NSMakeRect(0,0, (heightviewPreview*207.0/120)*tile, heightviewPreview*tile*207.0/120);
    NSImageView *dataprint = [[NSImageView alloc] initWithFrame:rect];
    dataprint.image = image;
    dataprint.imageScaling = NSImageScaleAxesIndependently;
    [viewPrintPreview addSubview:dataprint];
    imgDataPrintReview = dataprint;
    NSSize size = viewPrint.frame.size;
    imgDataPrintReview.frame = NSMakeRect(leftMargin, heightviewPreview-size.height-10, size.width, size.height);
    return self;
}
- (void)showImageReview
{
    NSImage *image;
    for(int i=0;i<deviceInfoArray.count;i++)
    {
        NSMutableDictionary *dicInfo = [deviceInfoArray objectAtIndex:i];
        viewPrint = [self createViewPrinter:dicInfo];
        image = [self imageRepresentation:viewPrint];
        break;
    }
    NSSize size = viewPrint.frame.size;
    imgDataPrintReview.frame = NSMakeRect(imgDataPrintReview.frame.origin.x, heightviewPreview-size.height-10, size.width, size.height);
    imgDataPrintReview.image = image;
}
- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    if(obj.object == txtTextFieldSize)
    {
        NSLog(@"%s",__func__);
        int temp = [txtTextFieldSize.stringValue intValue];
        if(temp > 0) fontSize = temp;
        
        
        NSDictionary *userAttributes = @{NSFontAttributeName: [NSFont fontWithName:@"Roboto-Regular" size:fontSize],
                                         NSForegroundColorAttributeName: [NSColor blackColor]};
        NSString *text = @"hello";
        const CGSize textSize = [text sizeWithAttributes: userAttributes];
        NSLog(@"Size text: %@",NSStringFromSize(textSize));
        
        pageHeight = (textSize.height+1)*10;
        pageWidth = pageHeight*1.75;
        
        [self showImageReview];
        NSSize size = viewPrint.frame.size;
        temp =  heightviewPreview-size.height-10 - (int)([txtTopMargin.stringValue floatValue]*dvpx);
        imgDataPrintReview.frame = NSMakeRect(imgDataPrintReview.frame.origin.x, temp, size.width, size.height);
    }
    else if(obj.object == txtTopMargin)
    {
        if(imgDataPrintReview)
        {
            NSSize size = viewPrint.frame.size;
            int temp =  heightviewPreview-size.height-10 - (int)([txtTopMargin.stringValue floatValue]*dvpx);
            if(temp >= 0)
            {
            NSSize size = viewPrint.frame.size;
            imgDataPrintReview.frame = NSMakeRect(imgDataPrintReview.frame.origin.x, temp, size.width, size.height);
            }
        }
    }
    else if(obj.object == txtLeftMargin)
    {
        if(imgDataPrintReview)
        {
            int temp = (int)([txtLeftMargin.stringValue floatValue]*dvpx);
            if(temp >= 0)
            {
            NSSize size = viewPrint.frame.size;
            imgDataPrintReview.frame = NSMakeRect(temp, imgDataPrintReview.frame.origin.y, size.width, size.height);
            }
        }
    }
    
}
- (NSMutableDictionary *)getConfig
{
    AppDelegate *delegatedir = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSString *pathLib = [delegatedir pathLib];
    NSLog(@"%s pathLib:%@",__func__,pathLib);
    pathLib = [pathLib stringByAppendingString:@"/config/Printer.config"];
    NSLog(@"%s pathconfig:%@",__func__,pathLib);
    if([[NSFileManager defaultManager] fileExistsAtPath:pathLib]==NO)
    {
        return Nil;
    }
    NSString *info = [NSString stringWithContentsOfFile:pathLib encoding:NSUTF8StringEncoding error:nil];
    NSMutableDictionary *dicData = (NSMutableDictionary *)[self diccionaryFromJsonString:info];
    return dicData;
    
}
- (void)getAndSetValueConfig
{
    NSMutableDictionary *dic =[self getConfig];
    if(dic == nil)
    {
        NSLog(@"khong co file config");
        return;
    }
    if([dic objectForKey:@"page_width"])
    {
        pageWidth = [[dic objectForKey:@"page_width"] floatValue]*dvpx;// coi lai cho nay
    }
    if([dic objectForKey:@"page_height"])
    {
        pageHeight = [[dic objectForKey:@"page_height"] floatValue]*dvpx;
    }
    if([dic objectForKey:@"left_margin"])
    {
        leftMargin = [[dic objectForKey:@"left_margin"] floatValue]*dvpx;
    }
    if([dic objectForKey:@"right_margin"])
    {
        rightMargin = [[dic objectForKey:@"right_margin"] floatValue]*dvpx;
    }
    if([dic objectForKey:@"top_margin"])
    {
        topMargin = [[dic objectForKey:@"top_margin"] floatValue]*dvpx;
    }
    if([dic objectForKey:@"bottom_margin"])
    {
        bottomMargin = [[dic objectForKey:@"bottom_margin"] floatValue]*dvpx;
    }
    if([dic objectForKey:@"font_size"])
    {
        fontSize = [[dic objectForKey:@"font_size"] intValue];
    }
    if([dic objectForKey:@"auto_print"])
    {
        autoPrint = [[dic objectForKey:@"auto_print"] intValue];
    }
    if([dic objectForKey:@"auto_print"])
    {
        printername = [[NSString alloc] initWithFormat:@"%@",[dic objectForKey:@"printer_name"]];
    }
    else printername = nil;
    
}
- (void)createAndSaveConfig
{
    NSString *priterName = [comboBox objectValueOfSelectedItem];
    if (!priterName)
           priterName = [comboBox stringValue];
    if(priterName==nil)
    {
        NSLog(@"not select priter name");
        return;
    }
    int pageWidthtmp = 2.11*dvpx;
    float ftemp = [txtPageWidth.stringValue floatValue];
    if(ftemp >= 0) pageWidthtmp = (int)(ftemp*dvpx);


    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:txtPageWidth.stringValue forKey:@"page_width"];
    [dic setObject:txtPageHeight.stringValue forKey:@"page_height"];
    [dic setObject:txtLeftMargin.stringValue forKey:@"left_margin"];
    [dic setObject:txtRightMargin.stringValue forKey:@"right_margin"];
    [dic setObject:txtTopMargin.stringValue forKey:@"top_margin"];
    [dic setObject:txtBottomMargin.stringValue forKey:@"bottom_margin"];
    [dic setObject:[NSNumber numberWithInt:fontSize] forKey:@"font_size"];
    [dic setObject:[NSNumber numberWithInt:autoPrint] forKey:@"auto_print"];
    [dic setObject:priterName forKey:@"printer_name"];
    [self saveConfig:dic];
}
- (BOOL)saveConfig:(NSMutableDictionary *)dicData
{
    AppDelegate *delegatedir = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSString *pathLib = [delegatedir pathLib];
    NSLog(@"%s pathLib:%@",__func__,pathLib);
    pathLib = [pathLib stringByAppendingString:@"/config/Printer.config"];
    NSLog(@"%s pathconfig:%@",__func__,pathLib);
    NSString *str = [delegatedir jsonStringFromDictionary:dicData];
    [str writeToFile:pathLib atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return YES;
}
- (void)btSelectPrinterClick:(id)sender
{
    NSButton *bt =(NSButton *)sender;
    NSViewController *controller = [[NSViewController alloc] init];
    controller.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0,200, 200)];
    //NSView(frame: CGRect(x: CGFloat(100), y: CGFloat(50), width: CGFloat(100), height: CGFloat(50)))
    NSPopover *popover = [[NSPopover alloc] init];

    popover.contentViewController = controller;
    popover.contentSize = controller.view.frame.size;

    popover.behavior = NSPopoverBehaviorTransient;
    popover.animates = YES;
//    NSWindow *invisibleWindow = [[NSWindow alloc] initWithContentRect:bt.frame styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
//    invisibleWindow.backgroundColor = [NSColor redColor];
//    invisibleWindow.alphaValue = 0;
    [popover showRelativeToRect:bt.bounds ofView:(NSView *)sender preferredEdge:NSRectEdgeMaxY];

  
    
}

- (NSString*)modifyDataToBarcodeString:(NSString*)str
{
    str = [str uppercaseString];
    printf("\n");
    NSMutableData *data = [NSMutableData dataWithCapacity:0];
    printf("\n begin convert barcode: \n");
    unsigned long total=104;
    unsigned char cs = 0;//checksum
    unsigned char val = 204;//start
    [data appendBytes:&val length:sizeof(char)];
    printf("\nstr: %s",[str UTF8String]);
    for(int i=0; i<[str length]; ++i)
    {
        val = [str characterAtIndex:i];
        [data appendBytes:&val length:sizeof(char)];
        int tmp = [self converAsciiToValue:val]*(i+1);// co the sai cho nay
        total += tmp;
    }
    cs = total%103;
    cs = [self converValueToAscii:cs];
    [data appendBytes:&cs length:sizeof(char)];
    val = 206;//end
    [data appendBytes:&val length:sizeof(char)];
    str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    return str;
}

- (unsigned char)converAsciiToValue:(unsigned char)ascii
{
    unsigned char value = ascii;// max uchar
    if(ascii==194) value = 0;
    else if(ascii>=33 && ascii<=126) //-32
    {
        value = ascii - 32;
    }
    else if(ascii>=195 && ascii<=206) //-100
    {
        value = ascii - 100;
    }
    
    return value;
}

- (unsigned char)converValueToAscii:(unsigned char)value
{
    unsigned char ascii = value;// max uchar
    if(value==0) ascii = 194;
    else if(value>=1 && value<=94) //+32
    {
        ascii = value + 32;
    }
    else if(ascii>=95 && ascii<=106) //+100
    {
        ascii = value + 100;
    }
    
    return ascii;
}

- (int)getValueMap
{
    if(dicMapValue==nil)
        dicMapValue = [self createMapValue];
    return 0;
}
-(NSMutableDictionary *)createMapValue
{
//https://www.idautomation.com/barcode-fonts/code-128/user-manual/
    
    NSMutableDictionary *dicData;
    
    return dicData;
}


- (NSView *)createViewPrinter:(NSMutableDictionary *)dic
{
    
  //   NSLog(@"%@",[[[NSFontManager sharedFontManager] availableFontFamilies] description]);
    
    NSDictionary *userAttributes = @{NSFontAttributeName: [NSFont fontWithName:@"Roboto-Regular" size:fontSize],
                                     NSForegroundColorAttributeName: [NSColor blackColor]};
    NSString *text = @"hello";
    const CGSize textSize = [text sizeWithAttributes: userAttributes];
    NSLog(@"Size text: %@",NSStringFromSize(textSize));
    
    
    viewPrint = [[NSView alloc] initWithFrame:NSMakeRect(0, 0,pageWidth-leftMargin-rightMargin, pageHeight-topMargin-bottomMargin)];//width - 20
    viewPrint.wantsLayer = YES;
    viewPrint.layer.backgroundColor = [NSColor clearColor].CGColor;
    viewPrint.layer.borderWidth = 0.0;
    viewPrint.layer.borderColor = [NSColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0].CGColor;
   
    int top = textSize.height,kc = textSize.height-3,hei = textSize.height, left = 15;
    int height = pageHeight -topMargin-bottomMargin;
    int widthp = pageWidth-leftMargin-rightMargin-4;

    NSTextField *txtPosition = [[NSTextField alloc] initWithFrame:NSMakeRect(left,height - top, widthp - 40 -left, hei)];
    txtPosition.alignment = NSTextAlignmentLeft;
    txtPosition.cell = [[NSTextFieldCell alloc] init];
    txtPosition.stringValue = [NSString stringWithFormat:@"Position %@",[dic objectForKey:@"title"]];//A1
    [txtPosition setEditable:NO];
    txtPosition.font = [NSFont fontWithName:@"Roboto-Regular" size:fontSize];
    txtPosition.backgroundColor = [NSColor clearColor];
    txtPosition.drawsBackground = YES;
    txtPosition.textColor = [NSColor blackColor];
    [viewPrint addSubview:txtPosition];
    
    top += kc;
    NSTextField *txtDeviceInfo = [[NSTextField alloc] initWithFrame:NSMakeRect(left,height -  top, widthp, hei)];
    txtDeviceInfo.alignment = NSTextAlignmentLeft;
    txtDeviceInfo.cell = [[NSTextFieldCell alloc] init];
    txtDeviceInfo.stringValue = [NSString stringWithFormat:@"Device info: %@",[dic objectForKey:@"fullname"]];//Apple Watch Series 2 Black N/A 8GB 6.3
    [txtDeviceInfo setEditable:NO];
    txtDeviceInfo.font = [NSFont fontWithName:@"Roboto-Regular" size:fontSize];
    txtDeviceInfo.backgroundColor = [NSColor clearColor];
    txtDeviceInfo.drawsBackground = YES;
    txtDeviceInfo.textColor = [NSColor blackColor];
    [viewPrint addSubview:txtDeviceInfo];
    
    top += kc;
    NSTextField *txtSerialNumber = [[NSTextField alloc] initWithFrame:NSMakeRect(left,height -  top, widthp - 40-left, hei)];
    txtSerialNumber.alignment = NSTextAlignmentLeft;
    txtSerialNumber.cell = [[NSTextFieldCell alloc] init];
    txtSerialNumber.stringValue = [NSString stringWithFormat:@"Serial Number: %@",[[dic objectForKey:@"info"] objectForKey:@"SerialNumber"]];//@"FH7TJ25UHJLJ"
    [txtSerialNumber setEditable:NO];
    txtSerialNumber.font = [NSFont fontWithName:@"Roboto-Regular" size:fontSize];
    txtSerialNumber.backgroundColor = [NSColor clearColor];
    txtSerialNumber.drawsBackground = YES;
    txtSerialNumber.textColor = [NSColor blackColor];
    [viewPrint addSubview:txtSerialNumber];
    
    top +=  2.1*kc;
    
     NSLog(@"%@",[[[NSFontManager sharedFontManager] availableFontFamilies] description]);
    
    //image barcode Serial
    NSTextField *txtBarSeri = [[NSTextField alloc] initWithFrame:NSMakeRect(left+3,height -  top+5, widthp-3, 2.1*kc)];
    txtBarSeri.alignment = NSTextAlignmentLeft;
    txtBarSeri.cell = [[NSTextFieldCell alloc] init];
    txtBarSeri.stringValue = [self modifyDataToBarcodeString:[NSString stringWithFormat:@"%@",[[dic objectForKey:@"info"] objectForKey:@"SerialNumber"]]];
    [txtBarSeri setEditable:NO];
    txtBarSeri.font = [NSFont fontWithName:@"Libre Barcode 128" size:fontSize<9?28:19+(fontSize)];
    txtBarSeri.backgroundColor = [NSColor clearColor];
    txtBarSeri.drawsBackground = NO;
    txtBarSeri.textColor = [NSColor blackColor];
    [viewPrint addSubview:txtBarSeri];
    
//    NSImage *image = [self createBarcode:[[dic objectForKey:@"info"] objectForKey:@"SerialNumber"]];//@"FH7TJ25UHJLJ"
//    int tmpwidth = 180;//2*kc*image.size.width/image.size.height;
//    NSImageView *barSeri = [[NSImageView alloc] initWithFrame:NSMakeRect(left,height -  top+2, 180,2*kc)];
//    barSeri.image = image;
//    barSeri.imageScaling = NSImageScaleAxesIndependently;
//    barSeri.layer.backgroundColor = [NSColor blueColor].CGColor;
//    barSeri.layer.borderWidth = 2;
//    [viewPrint addSubview:barSeri];

    
    top += kc;
    NSTextField *txtModelNo = [[NSTextField alloc] initWithFrame:NSMakeRect(left,height - top, widthp - 40-left, hei)];
    txtModelNo.alignment = NSTextAlignmentLeft;
    txtModelNo.cell = [[NSTextFieldCell alloc] init];
    txtModelNo.stringValue = [NSString stringWithFormat:@"Model No: %@%@",[[dic objectForKey:@"info"] objectForKey:@"ModelNumber"],[[dic objectForKey:@"info"] objectForKey:@"RegionInfo"]];//@"MP062LL/A"
    [txtModelNo setEditable:NO];
    txtModelNo.font = [NSFont fontWithName:@"Roboto-Regular" size:fontSize];
    txtModelNo.backgroundColor = [NSColor clearColor];
    txtModelNo.drawsBackground = YES;
    txtModelNo.textColor = [NSColor blackColor];
    [viewPrint addSubview:txtModelNo];
    
    
    top += kc;
    NSString *screenLock = [NSString stringWithFormat:@"OFF"];
    int va = [[[dic objectForKey:@"info"] objectForKey:@"PasswordProtected"] intValue];
    if(va==1) screenLock = [NSString stringWithFormat:@"ON"];
    
    NSTextField *txtPasscode = [[NSTextField alloc] initWithFrame:NSMakeRect(left,height - top, widthp - 40-left, hei)];
    txtPasscode.alignment = NSTextAlignmentLeft;
    txtPasscode.cell = [[NSTextFieldCell alloc] init];
    txtPasscode.stringValue = [NSString stringWithFormat:@"Passcode:\t %@",screenLock];//@"OFF"
    [txtPasscode setEditable:NO];
    txtPasscode.font = [NSFont fontWithName:@"Roboto-Regular" size:fontSize];
    txtPasscode.backgroundColor = [NSColor clearColor];
    txtPasscode.drawsBackground = YES;
    txtPasscode.textColor = [NSColor blackColor];
    [viewPrint addSubview:txtPasscode];
    
    
    NSString *stringItemTemp = [dic objectForKey:@"itemID"];

   // NSLog(@"%@",[[[NSFontManager sharedFontManager] availableFontFamilies] description]);
    
    
    if(stringItemTemp!=nil && stringItemTemp.length > 0)
    {
        top += kc;
        NSTextField *txtItemID = [[NSTextField alloc] initWithFrame:NSMakeRect(left,height - top, widthp - 40-left, hei)];
        txtItemID.alignment = NSTextAlignmentLeft;
        txtItemID.cell = [[NSTextFieldCell alloc] init];
        txtItemID.stringValue = [NSString stringWithFormat:@"ItemID:\t %@", stringItemTemp==nil?@" ":stringItemTemp];
        [txtItemID setEditable:NO];
        txtItemID.font = [NSFont fontWithName:@"Roboto-Regular" size:fontSize];
        txtItemID.backgroundColor = [NSColor clearColor];
        txtItemID.drawsBackground = YES;
        txtItemID.textColor = [NSColor blackColor];
        [viewPrint addSubview:txtItemID];
        
        top += 2.1*kc;
        // NSLog(@"%@",[[[NSFontManager sharedFontManager] availableFontFamilies] description]);
        stringItemTemp = [stringItemTemp stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        //image barcode Serial
        NSTextField *txtBarID = [[NSTextField alloc] initWithFrame:NSMakeRect(left+3,height -  top+5, widthp-3, 2.0*kc)];
        txtBarID.alignment = NSTextAlignmentLeft;
        txtBarID.cell = [[NSTextFieldCell alloc] init];
        txtBarID.stringValue = [self modifyDataToBarcodeString:[NSString stringWithFormat:@"%@",stringItemTemp]];
        [txtBarID setEditable:NO];
        txtBarID.font = [NSFont fontWithName:@"Libre Barcode 128" size:fontSize<9?28:19+(fontSize)];
        txtBarID.backgroundColor = [NSColor clearColor];;
        txtBarID.drawsBackground = NO;
        txtBarID.textColor = [NSColor blackColor];
        [viewPrint addSubview:txtBarID];
    }
    else  top += 0.1*kc;

    
    NSString *resultText = @"N/A";
    if ([[dic objectForKey:@"result"] intValue] == RESULT_PASSED) {
        resultText = @"Passed";
    } else if ([[dic objectForKey:@"result"] intValue] == RESULT_FAILED) {
        resultText = @"Failed";
    } else {
        resultText = @"N/A";
    }
    
    top += kc;
    NSTextField *txtResult = [[NSTextField alloc] initWithFrame:NSMakeRect(left,height - top+2, widthp - 40-left, hei)];
    txtResult.alignment = NSTextAlignmentLeft;
    txtResult.cell = [[NSTextFieldCell alloc] init];
    txtResult.stringValue = [NSString stringWithFormat:@"Result:\t Erase %@",resultText];
    [txtResult setEditable:NO];
    txtResult.font = [NSFont fontWithName:@"Roboto-Regular" size:fontSize];
    txtResult.backgroundColor = [NSColor clearColor];
    txtResult.drawsBackground = YES;
    txtResult.textColor = [NSColor blackColor];
    [viewPrint addSubview:txtResult];
    
    return viewPrint;
}
- (void)autoPrintAfterComplete:(id)sender
{
    NSButton *bt = (NSButton*)sender;
    if(autoPrint == YES)
    {
        bt.state = 0;
        autoPrint = NO;
        bt.image = [NSImage imageNamed:@"BoxUncheck.png"];
    }
    else
    {
        bt.state = 1;
        autoPrint = YES;
        bt.image = [NSImage imageNamed:@"BoxChecked.png"];
    }
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    delegate.autoPrint = autoPrint;
    
    
}

- (void)loadView
{
    [super loadView];
    self.view = [[NSView alloc] init];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSColor *colorCFBG = [NSColor whiteColor];
    self.view.layer.backgroundColor = colorCFBG.CGColor;

}
- (void) btCloseClick:(id)sender
{
    [self.view removeFromSuperview];
//    [self.view.window close];
}
- (void) btPrintClick:(id)sender
{
    float ftemp = [txtLeftMargin.stringValue floatValue];
    if(ftemp >= 0) leftMargin = ftemp*dvpx;
   
    ftemp = [txtRightMargin.stringValue floatValue];
    if(ftemp >= 0) rightMargin = ftemp*dvpx;
    
    ftemp = [txtBottomMargin.stringValue floatValue];
    if(ftemp >= 0) bottomMargin = ftemp*dvpx;
   
    ftemp = [txtTopMargin.stringValue floatValue];
    if(ftemp >= 0) topMargin = ftemp*dvpx;
    
    ftemp = [txtPageHeight.stringValue floatValue];
    if(ftemp >= 0) pageHeight = (float)(ftemp*dvpx);

    ftemp = [txtPageWidth.stringValue floatValue];
    if(ftemp >= 0) pageWidth = ftemp*dvpx - 2;
   
    int temp = [txtTextFieldSize.stringValue intValue];
    if(temp >= 0) fontSize = temp;

    NSMutableDictionary *printInfoDict = [[[NSPrintInfo sharedPrintInfo] dictionary] mutableCopy];
    NSLog(@"printInfoDict: %@",printInfoDict);
    printInfoDict[NSPrintJobDisposition] = NSPrintSpoolJob;//NSPrintSpoolJob; //NSPrintSaveJob: means you want a PDF file, not printing to a real printer(NSPrintSpoolJob).
    printInfoDict[NSPrintJobSavingURL] = [NSURL fileURLWithPath:[@"~/Desktop/print_test.pdf" stringByExpandingTildeInPath]]; // path of the generated pdf file
    //printInfoDict[NSPrintDetailedErrorReporting] = @YES; // not necessary
    if( printInfoDict[NSPrintJobDisposition] == NSPrintSpoolJob)
    {
        NSLog(@"list: %@",[NSPrinter printerNames]);
        if([NSPrinter printerNames].count==0)
        {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Priter Failed" defaultButton:@"Close" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Printer not found"];
            [alert runModal];
            return;
        }
    }
    
    NSString *priterName = [comboBox objectValueOfSelectedItem];
    if (!priterName)
        priterName = [comboBox stringValue];
    NSLog(@"Printer: %@",priterName);
    NSPrinter *printer = [NSPrinter printerWithName:priterName];
    [printInfoDict setObject:priterName forKey:@"NSPrinterName"];
    [printInfoDict setObject:printer forKey:@"NSPrinter"];
    
    // customize the layout of the "printing"
    NSPrintInfo *customPrintInfo = [[NSPrintInfo alloc] initWithDictionary:printInfoDict];
    [customPrintInfo setHorizontalPagination: NSPrintingPaginationModeAutomatic];
    [customPrintInfo setVerticalPagination: NSPrintingPaginationModeAutomatic];
    
    [customPrintInfo setPaperSize:NSMakeSize(pageWidth,pageHeight)];//(288, 192);// 1 incher == 96px
    [customPrintInfo setVerticallyCentered:YES];
    [customPrintInfo setHorizontallyCentered:YES];
    [customPrintInfo setOrientation:NSPaperOrientationLandscape];
    
    customPrintInfo.leftMargin = leftMargin;
    customPrintInfo.rightMargin = rightMargin;
    customPrintInfo.topMargin = topMargin;
    customPrintInfo.bottomMargin = bottomMargin;
    
    NSLog(@"Print InfoArray : %@",deviceInfoArray);
    NSLog(@"customPrintInfo : %@",customPrintInfo);

    
    [self createAndSaveConfig];// save info form data
    
    for(int i=0;i<deviceInfoArray.count;i++)
    {
        NSMutableDictionary *dicInfo = [deviceInfoArray objectAtIndex:i];
        
        viewPrint = [self createViewPrinter:dicInfo];
        
//        NSImage *image = [self imageRepresentation:viewPrint];
//        imgDataPrintReview.image = image;
        
        NSPrintOperation *printOperation = (NSPrintOperation*)[NSPrintOperation printOperationWithView:viewPrint printInfo:customPrintInfo];
        [printOperation setShowsPrintPanel:NO];
        [printOperation setShowsProgressPanel:NO];
        BOOL printSuccess = [printOperation runOperation];
        NSLog(@"print Success: %@",printSuccess?@"YES":@"NO");
    }
    
}

- (NSImage *)imageRepresentation:(NSView *)viewToPrint
{
    
  NSSize mySize = viewToPrint.bounds.size;
  NSSize imgSize = NSMakeSize( mySize.width, mySize.height );
  NSBitmapImageRep *bir = [viewToPrint bitmapImageRepForCachingDisplayInRect:[viewToPrint bounds]];
  [bir setSize:imgSize];
  [viewToPrint cacheDisplayInRect:[viewToPrint bounds] toBitmapImageRep:bir];
  NSImage* image = [[NSImage alloc]initWithSize:imgSize] ;
  [image addRepresentation:bir];
  return image;
}


- (CIImage*)generateBarcode:(NSString*)dataString
{
    CIFilter *barCodeFilter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    NSData *barCodeData = [dataString dataUsingEncoding:NSASCIIStringEncoding];
    [barCodeFilter setValue:barCodeData forKey:@"inputMessage"];
//    [barCodeFilter setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputQuietSpace"];
//    [barCodeFilter setValue:[NSNumber numberWithFloat:100.0] forKey:@"inputBarcodeHeight"];
    
   // [barCodeFilter setValue:[NSNumber numberWithFloat:1.0] forKey:kCIInputContrastKey];
   // [barCodeFilter setValue:[NSNumber numberWithFloat:1] forKey:kCIInputSaturationKey];
   // [barCodeFilter setValue:[NSNumber numberWithFloat:1] forKey:kCIInputBrightnessKey];

    CIImage *barCodeImage = barCodeFilter.outputImage;
    return barCodeImage;
}

- (NSImage *)createBarcode:(NSString*)string
{
    CIImage *img = [self generateBarcode:string];
    NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:img];
    CGAffineTransform transform = CGAffineTransformMakeScale(5.0, 5.0);
    [img imageByApplyingTransform:transform];
    NSLog(@"rep.size: %@",NSStringFromSize(rep.size));
    //NSImage *image = [[NSImage alloc] initWithSize:rep.size];
  
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(rep.size.width*2, rep.size.height*2)];//NSMakeSize(rep.size.width, rep.size.height);
    [image addRepresentation:rep];
    
 

//        let scaled = barImage.imageByApplyingTransform(transform)
    
    
    
    
    return image;
}


-(BOOL)textFieldDidResignFirstResponder:(NSTextField *)sender
{
//   // cai nay chay truoc textFieldDidBecomeFirstResponder
    return YES;
}


#pragma mark -
#pragma mark Dictionary converter

- (NSDictionary *)diccionaryFromJsonString:(NSString *)stringJson
{
    
    NSData *data = [stringJson dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error=Nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if(error)
    {
        NSLog(@"%s Error al leer json: %@",__FUNCTION__, [error description]);
        NSLog(@"%s String json: %@",__FUNCTION__, stringJson);
        return Nil;
    }
    return jsonDictionary;
}

//- (NSString *)jsonString FromDictionary:(NSDictionary *)dictionary
//{
//    @try
//    {
//        NSError *error = Nil;
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
//        if (error)
//        {
//            NSLog(@"%s Error: %@",__FUNCTION__, error);
//        }
//        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//
//        return jsonString;
//    }
//    @catch (NSException *exception)
//    {
//        NSLog(@"%s Error: %@",__FUNCTION__, [exception debugDescription]);
//
//        NSDate * now = [NSDate date];
//        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
//        [outputFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
//        NSString *newDateString = [outputFormatter stringFromDate:now];
//        newDateString = [NSString stringWithFormat:@"error(%@): %@",newDateString,[exception description]];
//
//        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *fileJsonlog = [NSString stringWithFormat:@"%@/jsonerror.txt", [paths objectAtIndex:0]];
//        [newDateString writeToFile:fileJsonlog atomically:YES encoding:NSUTF8StringEncoding error:nil];
//    }
//}
//



@end
