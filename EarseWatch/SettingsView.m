//
//  SettingsView.m
//  iCombine Watch
//
//  Created by Duyet Le on 6/10/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import "SettingsView.h"
#import "UITextFieldCell.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "UIWindow.h"
@interface SettingsView ()

@end

@implementation SettingsView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    leftTitleGroup = 30;
    self.view = [[NSView alloc] init];
    self.view.frame = frame;
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;//[NSColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0].CGColor;
    self.view.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
   
    int width = frame.size.width;
    int height = frame.size.height;
    
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    dicInfoSave = [delegate loadSettingInfoSave];
   
    NSButton *btOK = [[NSButton alloc] initWithFrame:NSMakeRect(width/2 - 120,10, 100, 30)];
    [btOK setFont:[NSFont fontWithName:@"Roboto-Regular" size:12]];
    btOK.wantsLayer = YES;
    [btOK setBordered:YES];
    btOK.layer.cornerRadius = 5;
    btOK.layer.borderWidth = 2;
    btOK.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
    [btOK setToolTip:@"Agree and save"];
    [btOK setTarget:self];
    btOK.image = [NSImage imageNamed:@"button_normal.png"];
    btOK.title = @"OK";
    [btOK setAction:@selector(btOKlick:)];
    [self.view addSubview:btOK];
    
    NSButton *btCancel = [[NSButton alloc] initWithFrame:NSMakeRect(width/2 + 20,10, 100, 30)];
    [btCancel setFont:[NSFont fontWithName:@"Roboto-Regular" size:12]];
    btCancel.wantsLayer = YES;
    [btCancel setBordered:YES];
    btCancel.layer.cornerRadius = 5;
    btCancel.layer.borderWidth = 2;
    btCancel.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
    [btCancel setToolTip:@"Cancel"];
    [btCancel setTarget:self];
    btCancel.image = [NSImage imageNamed:@"button_normal.png"];
    btCancel.title = @"Cancel";
    [btCancel setAction:@selector(btCancellick:)];
    [self.view addSubview:btCancel];
    
    [self createGroupServer:NSMakeRect(10, height - 260, width-20, 200)];
    
    [self createGroupFeatures:NSMakeRect(10,height - 480 , width-20, 200)];
    
    [self createGroupReport:NSMakeRect(10,60 , width-20, 290)];
    
    [self createHeader];//50px
    
    
//    mouseEventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:(NSLeftMouseDownMask | NSRightMouseDownMask | NSOtherMouseDownMask)
//                                               handler:^(NSEvent *event){
//
//            NSLog(@"theEvent->%@",event);
//
//            //here you will receive the all mouse DOWN events
//            if (event.modifierFlags & NSCommandKeyMask)
//            {
//              NSLog(@"theEvent1->%@",event);
//            }else{
//              NSLog(@"theEvent2->%@",event);
//            }
//        }];

    
    return self;
}
#pragma mark -
- (void) createGroupFeatures:(NSRect) frame
{
    NSView *viewtemp = [[NSView alloc] initWithFrame:frame];
    viewtemp.wantsLayer = YES;
    viewtemp.layer.borderWidth = 1;
    viewtemp.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [self.view addSubview:viewtemp];
    
    NSTextField *groupTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(leftTitleGroup,frame.size.height+frame.origin.y-6,70,20)];
    groupTitle.alignment = NSTextAlignmentCenter;
    groupTitle.cell = [[UITextFieldCell alloc] init];
    groupTitle.stringValue = @"Features";
    groupTitle.wantsLayer = YES;
    groupTitle.layer.borderWidth = 0;
    [groupTitle setEditable:NO];
    groupTitle.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    groupTitle.backgroundColor = [NSColor whiteColor];;
    groupTitle.drawsBackground = YES;
    groupTitle.textColor = [NSColor blackColor];
    [self.view addSubview:groupTitle];

    //erasure_method==========================================================
#pragma mark Erasure group
    NSRect frameErasure = NSMakeRect(10, 100, 180,80);
    
    NSView *viewGroupErasure = [[NSView alloc] initWithFrame:frameErasure];
    viewGroupErasure.wantsLayer = YES;
    viewGroupErasure.layer.borderWidth = 1;
    viewGroupErasure.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [viewtemp addSubview:viewGroupErasure];
    
    NSTextField *groupTitleErasure = [[NSTextField alloc] initWithFrame:NSMakeRect(leftTitleGroup,frameErasure.size.height+frameErasure.origin.y-6,120,20)];
    groupTitleErasure.alignment = NSTextAlignmentCenter;
    groupTitleErasure.cell = [[UITextFieldCell alloc] init];
    groupTitleErasure.stringValue = @"Erasure method";
    groupTitleErasure.wantsLayer = YES;
    groupTitleErasure.layer.borderWidth = 0;
    [groupTitleErasure setEditable:NO];
    groupTitleErasure.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    groupTitleErasure.backgroundColor = [NSColor whiteColor];;
    groupTitleErasure.drawsBackground = YES;
    groupTitleErasure.textColor = [NSColor blackColor];
    [viewtemp addSubview:groupTitleErasure];
    
    
    NSArray *items = @[@"Reflash", @"Manual erasure"];
    if(dicInfoSave && [dicInfoSave objectForKey:@"erasure_method"])
    {
        strErasure_method = [dicInfoSave objectForKey:@"erasure_method"];
        if(strErasure_method==nil || strErasure_method.length == 0)
            strErasure_method = [items objectAtIndex:0];
    }
    else strErasure_method = [items objectAtIndex:0];
    
   
    for(int i=0;i<items.count;i++)
    {
        NSButton *rdItem = [[NSButton alloc] initWithFrame:CGRectMake(10, frameErasure.size.height - 30 - i*30, frameErasure.size.width - 20, 20)];
        [rdItem setButtonType:NSRadioButton];
        [rdItem setTitle:[items objectAtIndex:i]];
        rdItem.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
        [rdItem setBezelStyle:0];
        [rdItem setState:0];
        NSString *temp = [items objectAtIndex:i];
        if([temp isEqualToString:strErasure_method])
        {
            [rdItem setState:1];
        }
        [rdItem setWantsLayer:YES];
        [rdItem setTarget:self];
        [rdItem setAction:@selector(rdButtonErasureMethodClick:)];
        [viewGroupErasure addSubview:rdItem];
        
    }
    
   //Other==========================================================
#pragma mark Other group
    NSView *viewGroupOthers = [[NSView alloc] initWithFrame:NSMakeRect(10, 10, frame.size.width - 20, 70)];
    viewGroupOthers.wantsLayer = YES;
    viewGroupOthers.layer.borderWidth = 1;
    viewGroupOthers.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [viewtemp addSubview:viewGroupOthers];
    
    int width = viewGroupOthers.frame.size.width;
    int height = viewGroupOthers.frame.size.height;
    
    NSTextField *groupTitleOthers = [[NSTextField alloc] initWithFrame:NSMakeRect(leftTitleGroup,height+viewGroupOthers.frame.origin.y-6,60,20)];
    groupTitleOthers.alignment = NSTextAlignmentCenter;
    groupTitleOthers.cell = [[UITextFieldCell alloc] init];
    groupTitleOthers.stringValue = @"Others";
    groupTitleOthers.wantsLayer = YES;
    groupTitleOthers.layer.borderWidth = 0;
    [groupTitleOthers setEditable:NO];
    groupTitleOthers.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    groupTitleOthers.backgroundColor = [NSColor whiteColor];;
    groupTitleOthers.drawsBackground = YES;
    groupTitleOthers.textColor = [NSColor blackColor];
    [viewtemp addSubview:groupTitleOthers];
    

    NSButton *cbAutomatically = [[NSButton alloc] initWithFrame:NSMakeRect(10,35, width-20, 20)];
    [cbAutomatically setButtonType:NSSwitchButton];
    //[checkBox setAction:@selector(cbSelectAllClick:)];
    [cbAutomatically setTitle:@"Automatically run after plugin device"];
    cbAutomatically.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
    [cbAutomatically setBezelStyle:0];
    if([dicInfoSave objectForKey:@"auto_run_after_plugin_device"])
        [cbAutomatically setState:[[dicInfoSave objectForKey:@"auto_run_after_plugin_device"] intValue]];
    else [cbAutomatically setState:0];
    cbAutomatically.tag = 700;
    [cbAutomatically setWantsLayer:YES];
    [viewGroupOthers addSubview:cbAutomatically];
    
    NSButton *cbEnableAuto = [[NSButton alloc] initWithFrame:NSMakeRect(10,10,  width-20, 20)];
    [cbEnableAuto setButtonType:NSSwitchButton];
    //[checkBox setAction:@selector(cbSelectAllClick:)];
    [cbEnableAuto setTitle:@"Enable auto detect device was unplugged after the proccess has completed"];
    cbEnableAuto.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
    [cbEnableAuto setBezelStyle:0];
    if([dicInfoSave objectForKey:@"enable_auto_detect_device_after_proccess_complete"])
        [cbEnableAuto setState:[[dicInfoSave objectForKey:@"enable_auto_detect_device_after_proccess_complete"] intValue]];
    else [cbEnableAuto setState:0];
    cbEnableAuto.tag = 701;
    [cbEnableAuto setWantsLayer:YES];
    [viewGroupOthers addSubview:cbEnableAuto];
    
    //Battery setting==========================================================
#pragma mark Battery group
   // NSRect frameBattery = NSMakeRect(10, 100, 180,80);
    NSRect frameBattery = NSMakeRect(200, 100, frame.size.width - 210,80);
    
    NSView *viewGroupBattery = [[NSView alloc] initWithFrame:frameBattery];
    viewGroupBattery.wantsLayer = YES;
    viewGroupBattery.layer.borderWidth = 1;
    viewGroupBattery.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [viewtemp addSubview:viewGroupBattery];
    
    //NSTextField *groupTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(leftTitleGroup,frameBattery.size.height+frame.origin.y-6,60,20)];
    NSButton *cbBatterySetting = [[NSButton alloc] initWithFrame:NSMakeRect(frameBattery.origin.x + leftTitleGroup-10,frameBattery.size.height+frameBattery.origin.y-8,130,20)];
    [cbBatterySetting setButtonType:NSSwitchButton];
    [cbBatterySetting setTitle:@"Battery settings"];
    cbBatterySetting.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
    [cbBatterySetting setBezelStyle:0];
    if([dicInfoSave objectForKey:@"battery_settings"])
        [cbBatterySetting setState:[[dicInfoSave objectForKey:@"battery_settings"] intValue]];
    else [cbBatterySetting setState:1];
    cbBatterySetting.tag = 600;
    [cbBatterySetting setWantsLayer:YES];
    cbBatterySetting.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [viewtemp addSubview:cbBatterySetting];
    
    //------------------------
    
    NSTextField *lbTimeOut = [[NSTextField alloc] initWithFrame:NSMakeRect(10,15, 100, 20)];
    lbTimeOut.alignment = NSTextAlignmentLeft;
    lbTimeOut.cell = [[UITextFieldCell alloc] init];
    lbTimeOut.stringValue = @"Timeout";
    lbTimeOut.wantsLayer = YES;
    lbTimeOut.layer.borderWidth = 0;
    [lbTimeOut setEditable:NO];
    lbTimeOut.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    lbTimeOut.backgroundColor = [NSColor whiteColor];;
    lbTimeOut.drawsBackground = YES;
    lbTimeOut.textColor = [NSColor blackColor];
    [viewGroupBattery addSubview:lbTimeOut];
    
    int timeout = 30;
    if([dicInfoSave objectForKey:@"baterry_timeout"])
        timeout = [[dicInfoSave objectForKey:@"baterry_timeout"] intValue];
    NSTextField *txtTimeout = [[NSTextField alloc] initWithFrame:NSMakeRect(110,7,70,30)];
    txtTimeout.cell = [[NSTextFieldCell alloc] init];
    [viewGroupBattery addSubview:txtTimeout];
    [txtTimeout.cell setFocusRingType:NSFocusRingTypeNone];
    txtTimeout.alignment = NSTextAlignmentLeft;
    txtTimeout.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtTimeout.bordered = YES;
    txtTimeout.wantsLayer = YES;
    txtTimeout.layer.borderColor = [NSColor blackColor].CGColor;
    txtTimeout.editable = YES;
    txtTimeout.backgroundColor = [NSColor redColor];
    txtTimeout.layer.cornerRadius = 5;
    txtTimeout.layer.borderWidth = 0;
    txtTimeout.layer.backgroundColor = [NSColor whiteColor].CGColor;
    txtTimeout.stringValue = [NSString stringWithFormat:@"%d",timeout];
    txtTimeout.tag = 601;
    
    NSTextField *lbMinutes = [[NSTextField alloc] initWithFrame:NSMakeRect(190,15, 100, 20)];
    lbMinutes.alignment = NSTextAlignmentLeft;
    lbMinutes.cell = [[UITextFieldCell alloc] init];
    lbMinutes.stringValue = @"minutes";
    lbMinutes.wantsLayer = YES;
    lbMinutes.layer.borderWidth = 0;
    [lbMinutes setEditable:NO];
    lbMinutes.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    lbMinutes.backgroundColor = [NSColor whiteColor];;
    lbMinutes.drawsBackground = YES;
    lbMinutes.textColor = [NSColor blackColor];
    [viewGroupBattery addSubview:lbMinutes];
    
    //------------------------
    
    NSTextField *lbBattery = [[NSTextField alloc] initWithFrame:NSMakeRect(10,50, 100, 20)];
    lbBattery.alignment = NSTextAlignmentLeft;
    lbBattery.cell = [[UITextFieldCell alloc] init];
    lbBattery.stringValue = @"Bartery";
    lbBattery.wantsLayer = YES;
    lbBattery.layer.borderWidth = 0;
    [lbBattery setEditable:NO];
    lbBattery.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    lbBattery.backgroundColor = [NSColor whiteColor];;
    lbBattery.drawsBackground = YES;
    lbBattery.textColor = [NSColor blackColor];
    [viewGroupBattery addSubview:lbBattery];
    
    int battery = 30;
    if([dicInfoSave objectForKey:@"baterry_lever"])
        battery = [[dicInfoSave objectForKey:@"baterry_lever"] intValue];
    
    NSTextField *txtBartery = [[NSTextField alloc] initWithFrame:NSMakeRect(110,42,70,30)];
    txtBartery.cell = [[NSTextFieldCell alloc] init];
    [viewGroupBattery addSubview:txtBartery];
    [txtBartery.cell setFocusRingType:NSFocusRingTypeNone];
    txtBartery.alignment = NSTextAlignmentLeft;
    txtBartery.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtBartery.bordered = YES;
    txtBartery.wantsLayer = YES;
    txtBartery.layer.borderColor = [NSColor blackColor].CGColor;
    txtBartery.editable = YES;
    txtBartery.backgroundColor = [NSColor redColor];
    txtBartery.layer.cornerRadius = 5;
    txtBartery.layer.borderWidth = 0;
    txtBartery.layer.backgroundColor = [NSColor whiteColor].CGColor;
    txtBartery.stringValue = [NSString stringWithFormat:@"%d",battery];
    txtBartery.tag = 602;
    
    NSTextField *lbPercent = [[NSTextField alloc] initWithFrame:NSMakeRect(190,50, 100, 20)];
    lbPercent.alignment = NSTextAlignmentLeft;
    lbPercent.cell = [[UITextFieldCell alloc] init];
    lbPercent.stringValue = @"%";
    lbPercent.wantsLayer = YES;
    lbPercent.layer.borderWidth = 0;
    [lbPercent setEditable:NO];
    lbPercent.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    lbPercent.backgroundColor = [NSColor whiteColor];;
    lbPercent.drawsBackground = YES;
    lbPercent.textColor = [NSColor blackColor];
    [viewGroupBattery addSubview:lbPercent];
    
    //------------------------
    
    NSTextField *lbCycleCount = [[NSTextField alloc] initWithFrame:NSMakeRect(290,15, 100, 20)];
    lbCycleCount.alignment = NSTextAlignmentLeft;
    lbCycleCount.cell = [[UITextFieldCell alloc] init];
    lbCycleCount.stringValue = @"Cycle Count";
    lbCycleCount.wantsLayer = YES;
    lbCycleCount.layer.borderWidth = 0;
    [lbCycleCount setEditable:NO];
    lbCycleCount.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    lbCycleCount.backgroundColor = [NSColor whiteColor];;
    lbCycleCount.drawsBackground = YES;
    lbCycleCount.textColor = [NSColor blackColor];
    [viewGroupBattery addSubview:lbCycleCount];
    
    int cycleCount = 1000;
    if([dicInfoSave objectForKey:@"baterry_cycle_count"])
        cycleCount = [[dicInfoSave objectForKey:@"baterry_cycle_count"] intValue];
    
    NSTextField *txtCycleCount = [[NSTextField alloc] initWithFrame:NSMakeRect(390,7,70,30)];
    txtCycleCount.cell = [[NSTextFieldCell alloc] init];
    [viewGroupBattery addSubview:txtCycleCount];
    [txtCycleCount.cell setFocusRingType:NSFocusRingTypeNone];
    txtCycleCount.alignment = NSTextAlignmentLeft;
    txtCycleCount.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtCycleCount.bordered = YES;
    txtCycleCount.wantsLayer = YES;
    txtCycleCount.layer.borderColor = [NSColor blackColor].CGColor;
    txtCycleCount.editable = YES;
    txtCycleCount.backgroundColor = [NSColor redColor];
    txtCycleCount.layer.cornerRadius = 5;
    txtCycleCount.layer.borderWidth = 0;
    txtCycleCount.layer.backgroundColor = [NSColor whiteColor].CGColor;
    txtCycleCount.stringValue = [NSString stringWithFormat:@"%d",cycleCount];
    txtCycleCount.tag = 603;
    
    NSTextField *lbCycle = [[NSTextField alloc] initWithFrame:NSMakeRect(470,15, 100, 20)];
    lbCycle.alignment = NSTextAlignmentLeft;
    lbCycle.cell = [[UITextFieldCell alloc] init];
    lbCycle.stringValue = @"cycle";
    lbCycle.wantsLayer = YES;
    lbCycle.layer.borderWidth = 0;
    [lbCycle setEditable:NO];
    lbCycle.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    lbCycle.backgroundColor = [NSColor whiteColor];;
    lbCycle.drawsBackground = YES;
    lbCycle.textColor = [NSColor blackColor];
    [viewGroupBattery addSubview:lbCycle];
    
    //------------------------
    
    NSTextField *lbSoH = [[NSTextField alloc] initWithFrame:NSMakeRect(290,50, 100, 20)];
    lbSoH.alignment = NSTextAlignmentLeft;
    lbSoH.cell = [[UITextFieldCell alloc] init];
    lbSoH.stringValue = @"SoH";
    lbSoH.wantsLayer = YES;
    lbSoH.layer.borderWidth = 0;
    [lbSoH setEditable:NO];
    lbSoH.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    lbSoH.backgroundColor = [NSColor whiteColor];;
    lbSoH.drawsBackground = YES;
    lbSoH.textColor = [NSColor blackColor];
    [viewGroupBattery addSubview:lbSoH];
    
    int SoH = 30;
    if([dicInfoSave objectForKey:@"baterry_soh"])
        SoH = [[dicInfoSave objectForKey:@"baterry_soh"] intValue];
    
    NSTextField *txtSoH = [[NSTextField alloc] initWithFrame:NSMakeRect(390,42,70,30)];
    txtSoH.cell = [[NSTextFieldCell alloc] init];
    [viewGroupBattery addSubview:txtSoH];
    [txtSoH.cell setFocusRingType:NSFocusRingTypeNone];
    txtSoH.alignment = NSTextAlignmentLeft;
    txtSoH.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtSoH.bordered = YES;
    txtSoH.wantsLayer = YES;
    txtSoH.layer.borderColor = [NSColor blackColor].CGColor;
    txtSoH.editable = YES;
    txtSoH.backgroundColor = [NSColor redColor];
    txtSoH.layer.cornerRadius = 5;
    txtSoH.layer.borderWidth = 0;
    txtSoH.layer.backgroundColor = [NSColor whiteColor].CGColor;
    txtSoH.stringValue = [NSString stringWithFormat:@"%d",SoH];
    txtSoH.tag = 604;
    
    lbPercent = [[NSTextField alloc] initWithFrame:NSMakeRect(470,50, 100, 20)];
    lbPercent.alignment = NSTextAlignmentLeft;
    lbPercent.cell = [[UITextFieldCell alloc] init];
    lbPercent.stringValue = @"%";
    lbPercent.wantsLayer = YES;
    lbPercent.layer.borderWidth = 0;
    [lbPercent setEditable:NO];
    lbPercent.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    lbPercent.backgroundColor = [NSColor whiteColor];;
    lbPercent.drawsBackground = YES;
    lbPercent.textColor = [NSColor blackColor];
    [viewGroupBattery addSubview:lbPercent];
    
    //------------------------
//    chua add controll : Image 4.02 Settings.jpg
    
//    int width = viewGroupOthers.frame.size.width;
//    int height = viewGroupOthers.frame.size.height;
}
#pragma mark -
- (void) createGroupServer:(NSRect) frame
{
    NSView *viewtemp = [[NSView alloc] initWithFrame:frame];
    viewtemp.wantsLayer = YES;
    viewtemp.layer.borderWidth = 1;
    viewtemp.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [self.view addSubview:viewtemp];
    
    NSTextField *groupTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(leftTitleGroup,frame.size.height+frame.origin.y-6,60,20)];
    groupTitle.alignment = NSTextAlignmentCenter;
    groupTitle.cell = [[UITextFieldCell alloc] init];
    groupTitle.stringValue = @"Server";
    groupTitle.wantsLayer = YES;
    groupTitle.layer.borderWidth = 0;
    [groupTitle setEditable:NO];
    groupTitle.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    groupTitle.backgroundColor = [NSColor whiteColor];;
    groupTitle.drawsBackground = YES;
    groupTitle.textColor = [NSColor blackColor];
    [self.view addSubview:groupTitle];
    
   
    //timeout group==============================================================================
#pragma mark Timeout group
    NSRect frameTimeout =  NSMakeRect(300,  frame.size.height - 120,  frame.size.width - 310,100);
    
    NSView *viewgroupTimeOut = [[NSView alloc] initWithFrame:frameTimeout];
    viewgroupTimeOut.wantsLayer = YES;
    viewgroupTimeOut.layer.borderWidth = 1;
    viewgroupTimeOut.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [viewtemp addSubview:viewgroupTimeOut];
    
    NSTextField *groupTitleTimeOut = [[NSTextField alloc] initWithFrame:NSMakeRect(frameTimeout.origin.x + leftTitleGroup,frameTimeout.size.height+frameTimeout.origin.y-6,70,20)];
    groupTitleTimeOut.alignment = NSTextAlignmentCenter;
    groupTitleTimeOut.cell = [[UITextFieldCell alloc] init];
    groupTitleTimeOut.stringValue = @"Time out";
    groupTitleTimeOut.wantsLayer = YES;
    groupTitleTimeOut.layer.borderWidth = 0;
    [groupTitleTimeOut setEditable:NO];
    groupTitleTimeOut.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    groupTitleTimeOut.backgroundColor = [NSColor whiteColor];;
    groupTitleTimeOut.drawsBackground = YES;
    groupTitleTimeOut.textColor = [NSColor blackColor];
    [viewtemp addSubview:groupTitleTimeOut];
    
   // int height = frameTimeout.size.height;
    
    int time = 60;
    if([dicInfoSave objectForKey:@"timeout"]!=nil)//timeout erase
        time = [[dicInfoSave objectForKey:@"timeout"] intValue];
    
    NSButton *cbEnableTimeout = [[NSButton alloc] initWithFrame:NSMakeRect(10,25, 250, 20)];
    [cbEnableTimeout setButtonType:NSSwitchButton];
    [cbEnableTimeout setTitle:@"Enable timeout proccess erase"];
    cbEnableTimeout.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
    if(time > 0)
        [cbEnableTimeout setState:1];
    else [cbEnableTimeout setState:0];
    cbEnableTimeout.tag = 500;
    [cbEnableTimeout setWantsLayer:YES];
    [viewgroupTimeOut addSubview:cbEnableTimeout];
    
    
    NSTextField *txtMinutes = [[NSTextField alloc] initWithFrame:NSMakeRect(250,17,90,30)];
    txtMinutes.cell = [[NSTextFieldCell alloc] init];
    [viewgroupTimeOut addSubview:txtMinutes];
    [txtMinutes.cell setFocusRingType:NSFocusRingTypeNone];
    txtMinutes.alignment = NSTextAlignmentLeft;
    txtMinutes.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtMinutes.bordered = YES;
    txtMinutes.wantsLayer = YES;
    txtMinutes.layer.borderColor = [NSColor blackColor].CGColor;
    txtMinutes.editable = YES;
    txtMinutes.backgroundColor = [NSColor redColor];
    txtMinutes.layer.cornerRadius = 5;
    txtMinutes.layer.borderWidth = 1;
    txtMinutes.layer.backgroundColor = [NSColor whiteColor].CGColor;
    txtMinutes.stringValue = [NSString stringWithFormat:@"%d",time];
    txtMinutes.tag = 501;

    NSTextField *lbMinutes = [[NSTextField alloc] initWithFrame:NSMakeRect(350,27, 100, 20)];
    lbMinutes.alignment = NSTextAlignmentLeft;
    lbMinutes.cell = [[UITextFieldCell alloc] init];
    lbMinutes.stringValue = @"minutes";
    lbMinutes.wantsLayer = YES;
    lbMinutes.layer.borderWidth = 0;
    [lbMinutes setEditable:NO];
    lbMinutes.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    lbMinutes.backgroundColor = [NSColor whiteColor];;
    lbMinutes.drawsBackground = YES;
    lbMinutes.textColor = [NSColor blackColor];
    [viewgroupTimeOut addSubview:lbMinutes];
    //---------------
    
    time = 30;
    if([dicInfoSave objectForKey:@"timeout_test"]!=nil)//timeout erase
        time = [[dicInfoSave objectForKey:@"timeout_test"] intValue];
    
    NSButton *cbEnableTimeout_test = [[NSButton alloc] initWithFrame:NSMakeRect(10,63, 250, 20)];
    [cbEnableTimeout_test setButtonType:NSSwitchButton];
    [cbEnableTimeout_test setTitle:@"Enable timeout proccess test"];
    cbEnableTimeout_test.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
    [cbEnableTimeout_test setBezelStyle:0];
    if(time > 0)
        [cbEnableTimeout_test setState:1];
    else [cbEnableTimeout_test setState:0];
    cbEnableTimeout_test.tag = 502;
    [cbEnableTimeout_test setWantsLayer:YES];
    [viewgroupTimeOut addSubview:cbEnableTimeout_test];
    
    
    NSTextField *txtMinutes_test = [[NSTextField alloc] initWithFrame:NSMakeRect(250,55,90,30)];
    txtMinutes_test.cell = [[NSTextFieldCell alloc] init];
    [viewgroupTimeOut addSubview:txtMinutes_test];
    [txtMinutes_test.cell setFocusRingType:NSFocusRingTypeNone];
    txtMinutes_test.alignment = NSTextAlignmentLeft;
    txtMinutes_test.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtMinutes_test.bordered = YES;
    txtMinutes_test.wantsLayer = YES;
    txtMinutes_test.layer.borderColor = [NSColor blackColor].CGColor;
    txtMinutes_test.editable = YES;
    txtMinutes_test.backgroundColor = [NSColor redColor];
    txtMinutes_test.layer.cornerRadius = 5;
    txtMinutes_test.layer.borderWidth = 1;
    txtMinutes_test.layer.backgroundColor = [NSColor whiteColor].CGColor;
    txtMinutes_test.stringValue = [NSString stringWithFormat:@"%d",time];
    txtMinutes_test.tag = 503;

    lbMinutes = [[NSTextField alloc] initWithFrame:NSMakeRect(350,65, 100, 20)];
    lbMinutes.alignment = NSTextAlignmentLeft;
    lbMinutes.cell = [[UITextFieldCell alloc] init];
    lbMinutes.stringValue = @"minutes";
    lbMinutes.wantsLayer = YES;
    lbMinutes.layer.borderWidth = 0;
    [lbMinutes setEditable:NO];
    lbMinutes.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    lbMinutes.backgroundColor = [NSColor whiteColor];;
    lbMinutes.drawsBackground = YES;
    lbMinutes.textColor = [NSColor blackColor];
    [viewgroupTimeOut addSubview:lbMinutes];
    
    
    
    
    //Location ================================================================================
#pragma mark Location group
    NSRect frameCDNLocation = NSMakeRect(10,  frame.size.height - 120, 270,100);
    
    NSView *viewGroupCDNLocation = [[NSView alloc] initWithFrame:frameCDNLocation];
    viewGroupCDNLocation.wantsLayer = YES;
    viewGroupCDNLocation.layer.borderWidth = 1;
    viewGroupCDNLocation.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [viewtemp addSubview:viewGroupCDNLocation];
    
    NSTextField *groupTitleCDNLocation = [[NSTextField alloc] initWithFrame:NSMakeRect(leftTitleGroup,frameCDNLocation.size.height+frameCDNLocation.origin.y-6,100,20)];
    groupTitleCDNLocation.alignment = NSTextAlignmentCenter;
    groupTitleCDNLocation.cell = [[UITextFieldCell alloc] init];
    groupTitleCDNLocation.stringValue = @"CDN Location";
    groupTitleCDNLocation.wantsLayer = YES;
    groupTitleCDNLocation.layer.borderWidth = 0;
    [groupTitleCDNLocation setEditable:NO];
    groupTitleCDNLocation.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    groupTitleCDNLocation.backgroundColor = [NSColor whiteColor];;
    groupTitleCDNLocation.drawsBackground = YES;
    groupTitleCDNLocation.textColor = [NSColor blackColor];
    [viewtemp addSubview:groupTitleCDNLocation];
    
    
    
    NSArray *items = @[@"Dalas", @"Chicago", @"Manual"];
    if(dicInfoSave && [dicInfoSave objectForKey:@"location"])
    {
        strLocation = [dicInfoSave objectForKey:@"location"];
        if(strLocation.length == 0)
            strLocation = [items objectAtIndex:0];
    }
    else strLocation = [items objectAtIndex:0];
    
    bool isManual = YES;
    for(int i=0;i<items.count;i++)
    {
        NSButton *rdItem = [[NSButton alloc] initWithFrame:CGRectMake(10, frameCDNLocation.size.height - 25 - i*30, frameCDNLocation.size.width - 20, 20)];
        [rdItem setButtonType:NSRadioButton];
        [rdItem setTitle:[items objectAtIndex:i]];
        rdItem.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
        [rdItem setBezelStyle:0];
        [rdItem setState:0];
        NSString *temp = [items objectAtIndex:i];
        if([temp isEqualToString:strLocation] && [[temp lowercaseString] isEqualToString:@"manual"]==NO)
        {
            [rdItem setState:1];
            isManual = NO;
        }
        if(i == items.count -1)//@"Manual" o vi tri cuoi cung
        {
            if(isManual == YES)
            {
                [rdItem setState:1];
            }
        }
        [rdItem setWantsLayer:YES];
        [rdItem setTarget:self];
        [rdItem setAction:@selector(rdButtonlocationClick:)];
        [viewGroupCDNLocation addSubview:rdItem];
        
    }
   
    
    NSTextField *txtCDNLocation = [[NSTextField alloc] initWithFrame:NSMakeRect(100,frameCDNLocation.size.height - 30 - (items.count -1)*30,160,30)];
    txtCDNLocation.cell = [[NSTextFieldCell alloc] init];
    [viewGroupCDNLocation addSubview:txtCDNLocation];
    [txtCDNLocation.cell setFocusRingType:NSFocusRingTypeNone];
    txtCDNLocation.alignment = NSTextAlignmentLeft;
    txtCDNLocation.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtCDNLocation.bordered = YES;
    txtCDNLocation.wantsLayer = YES;
    txtCDNLocation.layer.borderColor = [NSColor blackColor].CGColor;
    txtCDNLocation.editable = YES;
    txtCDNLocation.backgroundColor = [NSColor redColor];
    txtCDNLocation.layer.cornerRadius = 5;
    txtCDNLocation.layer.borderWidth = 1;
    txtCDNLocation.layer.backgroundColor = [NSColor whiteColor].CGColor;
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
     txtCDNLocation.stringValue = @"";
    if([[strLocation lowercaseString] isEqualToString:@"dalas"]==YES)
    {
        NSString *pathLib = [delegate pathLib];
        NSString *filename = [pathLib stringByAppendingString:@"/config/location_server_dalas.config"];
        if([[NSFileManager defaultManager] fileExistsAtPath:filename]==YES)
        {
            NSString *info = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:nil];
            NSMutableDictionary *dic = (NSMutableDictionary *)[delegate diccionaryFromJsonString:info];
            txtCDNLocation.stringValue = [NSString stringWithFormat:@"%@",[[dic objectForKey:@"cdn"] objectForKey:@"link_manual_bk"]];
        }
    }
    else if([[strLocation lowercaseString] isEqualToString:@"chicago"]==YES)
    {
        NSString *pathLib = [delegate pathLib];
        NSString *filename = [pathLib stringByAppendingString:@"/config/location_server_chicago.config"];
        if([[NSFileManager defaultManager] fileExistsAtPath:filename]==YES)
        {
            NSString *info = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:nil];
            NSMutableDictionary *dic = (NSMutableDictionary *)[delegate diccionaryFromJsonString:info];
            txtCDNLocation.stringValue = [NSString stringWithFormat:@"%@",[[dic objectForKey:@"cdn"] objectForKey:@"link_manual_bk"]];
        }
    }
    if(isManual == YES)
    {
        NSLog(@"dicInfoSave: %@",dicInfoSave);
        txtCDNLocation.stringValue = [dicInfoSave objectForKey:@"localLink"];// con sai cho nay do chua input va update duoc info trongfile
    }
    txtCDNLocation.tag = 900;
    
    //sup server:================================================================================
#pragma mark Server group
    NSArray *itemsServer = @[@"Dalas", @"Chicago"];
    strServer = itemsServer[0];
    if(dicInfoSave && [dicInfoSave objectForKey:@"server"])
    {
        strServer = [dicInfoSave objectForKey:@"server"];
    }
    unsigned long tmpHeight = 50;
    NSRect frameSubServer = NSMakeRect(10,  frame.size.height - 140 - tmpHeight, 270, tmpHeight);
    
    NSView *viewGroupSubServer = [[NSView alloc] initWithFrame:frameSubServer];
    viewGroupSubServer.wantsLayer = YES;
    viewGroupSubServer.layer.backgroundColor = [NSColor whiteColor].CGColor;
    viewGroupSubServer.layer.borderWidth = 1;
    [viewtemp addSubview:viewGroupSubServer];
    

    
    NSTextField *groupTitleSubServer = [[NSTextField alloc] initWithFrame:NSMakeRect(leftTitleGroup, frameSubServer.origin.y + frameSubServer.size.height-5, 60,20)];
    groupTitleSubServer.alignment = NSTextAlignmentCenter;
    groupTitleSubServer.cell = [[UITextFieldCell alloc] init];
    groupTitleSubServer.stringValue = @"Server";
    groupTitleSubServer.wantsLayer = YES;
    groupTitleSubServer.layer.borderWidth = 0;
    [groupTitleSubServer setEditable:NO];
    groupTitleSubServer.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    groupTitleSubServer.backgroundColor = [NSColor whiteColor];;
    groupTitleSubServer.drawsBackground = YES;
    groupTitleSubServer.textColor = [NSColor blackColor];
    [viewtemp addSubview:groupTitleSubServer];
    
//    NSRect frameSubServerBother = NSMakeRect(frameSubServer.origin.x+1, frameSubServer.origin.y-1, frameSubServer.size.width, tmpHeight);
//
//    NSTextField *groupBotherSubServer = [[NSTextField alloc] initWithFrame:frameSubServerBother];
//    groupBotherSubServer.wantsLayer = YES;
//    groupBotherSubServer.layer.borderWidth = 1;
//    [groupBotherSubServer setEditable:NO];
//    groupBotherSubServer.backgroundColor = [NSColor clearColor];;
//    [viewtemp addSubview:groupBotherSubServer];
    
   
    
    NSString *tmp = [itemsServer objectAtIndex:0];
    NSButton *rdItem = [[NSButton alloc] initWithFrame:CGRectMake(10, frameSubServer.size.height -35,90, 20)];
    [rdItem setButtonType:NSRadioButton];
    [rdItem setTitle:[itemsServer objectAtIndex:0]];
    rdItem.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
    [rdItem setBezelStyle:0];
    [rdItem setState:0];
    if([strServer isEqualToString:tmp])
        [rdItem setState:1];
    [rdItem setWantsLayer:YES];
    [rdItem setTarget:self];
    [rdItem setAction:@selector(rdButtonServerClick:)];
    [viewGroupSubServer addSubview:rdItem];
    
    tmp = [itemsServer objectAtIndex:1];
    NSButton *rdItem1 = [[NSButton alloc] initWithFrame:CGRectMake(100, frameSubServer.size.height -35, 90, 20)];
    [rdItem1 setButtonType:NSRadioButton];
    [rdItem1 setTitle:[itemsServer objectAtIndex:1]];
    rdItem1.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
    [rdItem1 setBezelStyle:0];
    [rdItem1 setState:0];
    if([strServer isEqualToString:tmp])
        [rdItem1 setState:1];
    [rdItem1 setWantsLayer:YES];
    [rdItem1 setTarget:self];
    [rdItem1 setAction:@selector(rdButtonServerClick:)];
    [viewGroupSubServer addSubview:rdItem1];
    
    //-----------------------------
    
    //sup Elapsed time:================================================================================
#pragma mark Elapsed time group
    NSArray *itemsElapsedTime = @[@"Elapsed time continuity", @"Elapsed time Proccess"];
    strElapsedTime = itemsElapsedTime[0];
    if(dicInfoSave && [dicInfoSave objectForKey:@"elapsed_time"])
    {
        strElapsedTime = [dicInfoSave objectForKey:@"elapsed_time"];
    }
    tmpHeight = 50;
    NSRect frameSubElapsedTime = NSMakeRect(300,  frame.size.height - 140 - tmpHeight, frame.size.width - 310,tmpHeight);
    
    NSView *viewGroupSubElapsedTime = [[NSView alloc] initWithFrame:frameSubElapsedTime];
    viewGroupSubElapsedTime.wantsLayer = YES;
    viewGroupSubElapsedTime.layer.backgroundColor = [NSColor whiteColor].CGColor;
    viewGroupSubElapsedTime.layer.borderWidth = 1;
    [viewtemp addSubview:viewGroupSubElapsedTime];
    
    NSTextField *groupTitleElapsedTime = [[NSTextField alloc] initWithFrame:NSMakeRect(frameSubElapsedTime.origin.x + leftTitleGroup, frameSubElapsedTime.origin.y + frameSubElapsedTime.size.height-5, 100,20)];
    groupTitleElapsedTime.alignment = NSTextAlignmentCenter;
    groupTitleElapsedTime.cell = [[UITextFieldCell alloc] init];
    groupTitleElapsedTime.stringValue = @"Elapsed time";
    groupTitleElapsedTime.wantsLayer = YES;
    groupTitleElapsedTime.layer.borderWidth = 0;
    [groupTitleElapsedTime setEditable:NO];
    groupTitleElapsedTime.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    groupTitleElapsedTime.backgroundColor = [NSColor whiteColor];;
    groupTitleElapsedTime.drawsBackground = YES;
    groupTitleElapsedTime.textColor = [NSColor blackColor];
    [viewtemp addSubview:groupTitleElapsedTime];
    
    
    
    tmp = [itemsElapsedTime objectAtIndex:0];
    rdItem = [[NSButton alloc] initWithFrame:CGRectMake(10, frameSubServer.size.height -35,180, 20)];
    [rdItem setButtonType:NSRadioButton];
    [rdItem setTitle:[itemsElapsedTime objectAtIndex:0]];
    rdItem.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
    [rdItem setBezelStyle:0];
    [rdItem setState:0];
    if([strElapsedTime isEqualToString:tmp])
        [rdItem setState:1];
    [rdItem setWantsLayer:YES];
    [rdItem setTarget:self];
    [rdItem setAction:@selector(rdButtonElapsedTimeClick:)];
    [viewGroupSubElapsedTime addSubview:rdItem];
    
    tmp = [itemsElapsedTime objectAtIndex:1];
    rdItem1 = [[NSButton alloc] initWithFrame:CGRectMake(210, frameSubServer.size.height -35, 180, 20)];
    [rdItem1 setButtonType:NSRadioButton];
    [rdItem1 setTitle:[itemsElapsedTime objectAtIndex:1]];
    rdItem1.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
    [rdItem1 setBezelStyle:0];
    [rdItem1 setState:0];
    if([strElapsedTime isEqualToString:tmp])
        [rdItem1 setState:1];
    [rdItem1 setWantsLayer:YES];
    [rdItem1 setTarget:self];
    [rdItem1 setAction:@selector(rdButtonElapsedTimeClick:)];
    [viewGroupSubElapsedTime addSubview:rdItem1];
    

    
//    unsigned long tmpHeight = itemsServer.count*40+10;
//    if(itemsServer.count < 3)
//        tmpHeight = 3*40+10;
//
//    tmpHeight = 80;
//
//    NSView *viewGroupSubServer = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width - 350,tmpHeight)];
//    viewGroupSubServer.layer.backgroundColor = [NSColor whiteColor].CGColor;
//   // [viewtemp addSubview:viewGroupSubServer];
//
//    NSRect frameSubServer = NSMakeRect(frame.size.width - 239, 91, frame.size.width - 350, frame.size.height - 112);
//    NSRect frameSubServerBother = NSMakeRect(frame.size.width - 240, 90, frame.size.width - 350, frame.size.height - 110);
//
//    NSTextField *groupBotherSubServer = [[NSTextField alloc] initWithFrame:frameSubServerBother];
//    groupBotherSubServer.wantsLayer = YES;
//    groupBotherSubServer.layer.borderWidth = 1;
//    [groupBotherSubServer setEditable:NO];
//    groupBotherSubServer.backgroundColor = [NSColor clearColor];;
//    [viewtemp addSubview:groupBotherSubServer];
//
//    NSScrollView *scrollServerView = [[NSScrollView alloc] initWithFrame:frameSubServer];
//    scrollServerView.documentView = viewGroupSubServer;
//    scrollServerView.translatesAutoresizingMaskIntoConstraints = false;
//    [viewtemp addSubview:scrollServerView];
//
//    NSTextField *groupTitleSubServer = [[NSTextField alloc] initWithFrame:NSMakeRect(frame.size.width - 200, frameSubServer.size.height+frameSubServer.origin.y-6,60,20)];
//    groupTitleSubServer.alignment = NSTextAlignmentCenter;
//    groupTitleSubServer.cell = [[UITextFieldCell alloc] init];
//    groupTitleSubServer.stringValue = @"Server";
//    groupTitleSubServer.wantsLayer = YES;
//    groupTitleSubServer.layer.borderWidth = 0;
//    [groupTitleSubServer setEditable:NO];
//    groupTitleSubServer.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
//    groupTitleSubServer.backgroundColor = [NSColor whiteColor];;
//    groupTitleSubServer.drawsBackground = YES;
//    groupTitleSubServer.textColor = [NSColor blackColor];
//    [viewtemp addSubview:groupTitleSubServer];
//
//    if(itemsServer.count < 3)
//    {
//        for(int i=0;i<itemsServer.count;i++)
//        {
//            NSString *tmp = [itemsServer objectAtIndex:i];
//            NSButton *rdDallas = [[NSButton alloc] initWithFrame:CGRectMake(10, frameSubServer.size.height - (i*40)-30, frameSubServer.size.width - 20, 20)];
//            [rdDallas setButtonType:NSRadioButton];
//            [rdDallas setTitle:[itemsServer objectAtIndex:i]];
//            rdDallas.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
//            [rdDallas setBezelStyle:0];
//            [rdDallas setState:0];
//            if([strServer isEqualToString:tmp])
//                [rdDallas setState:1];
//            [rdDallas setWantsLayer:YES];
//            [rdDallas setTarget:self];
//            [rdDallas setAction:@selector(rdButtonServerClick:)];
//            [viewGroupSubServer addSubview:rdDallas];
//        }
//    }
//    else
//    {
//        for(int i=0;i<itemsServer.count;i++)
//        {
//            NSString *tmp = [itemsServer objectAtIndex:i];
//            NSButton *rdDallas = [[NSButton alloc] initWithFrame:CGRectMake(10, i*40+13, frameSubServer.size.width - 20, 20)];
//            [rdDallas setButtonType:NSRadioButton];
//            [rdDallas setTitle:[itemsServer objectAtIndex:i]];
//            rdDallas.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
//            [rdDallas setBezelStyle:0];
//            [rdDallas setState:0];
//            if([strServer isEqualToString:tmp])
//                [rdDallas setState:1];
//            [rdDallas setWantsLayer:YES];
//            [rdDallas setTarget:self];
//            [rdDallas setAction:@selector(rdButtonServerClick:)];
//            [viewGroupSubServer addSubview:rdDallas];
//
//        }
//    }
//    NSPoint pointToScrollTo = NSMakePoint (0, itemsServer.count*40+30);  // Any point you like.
//    [[scrollServerView contentView] scrollToPoint: pointToScrollTo];
//    [scrollServerView reflectScrolledClipView: [scrollServerView contentView]];
//

}
#pragma mark -
- (void) createGroupReport:(NSRect) frame
{
    NSView *viewGroup = [[NSView alloc] initWithFrame:frame];
    viewGroup.wantsLayer = YES;
    viewGroup.layer.borderWidth = 1;
    viewGroup.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [self.view addSubview:viewGroup];
    
    NSTextField *groupTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(leftTitleGroup,frame.size.height+frame.origin.y-6,60,20)];
    groupTitle.alignment = NSTextAlignmentCenter;
    groupTitle.cell = [[UITextFieldCell alloc] init];
    groupTitle.stringValue = @"Report";
    groupTitle.wantsLayer = YES;
    groupTitle.layer.borderWidth = 0;
    [groupTitle setEditable:NO];
    groupTitle.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    groupTitle.backgroundColor = [NSColor whiteColor];;
    groupTitle.drawsBackground = YES;
    groupTitle.textColor = [NSColor blackColor];
    [self.view addSubview:groupTitle];

    //mail setting ==========================================================
#pragma mark Mail address seting group
    NSRect rectMailGroup = NSMakeRect(10, frame.size.height - 100, frame.size.width - 20, 80);
    NSView *viewMailAddressGroup = [[NSView alloc] initWithFrame:rectMailGroup];
    viewMailAddressGroup.wantsLayer = YES;
    viewMailAddressGroup.layer.borderWidth = 1;
    viewMailAddressGroup.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [viewGroup addSubview:viewMailAddressGroup];
    
    groupTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(leftTitleGroup,frame.size.height-25,180,20)];
    groupTitle.alignment = NSTextAlignmentCenter;
    groupTitle.cell = [[UITextFieldCell alloc] init];
    groupTitle.stringValue = @"Mail's addresses settings";
    groupTitle.wantsLayer = YES;
    groupTitle.layer.borderWidth = 0;
    [groupTitle setEditable:NO];
    groupTitle.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    groupTitle.backgroundColor = [NSColor whiteColor];;
    groupTitle.drawsBackground = YES;
    groupTitle.textColor = [NSColor blackColor];
    [viewGroup addSubview:groupTitle];
    
    //----------------------------------
    
    NSTextField *lbEmailAddressNote = [[NSTextField alloc] initWithFrame:NSMakeRect(10,15, rectMailGroup.size.width - 20, 20)];
    lbEmailAddressNote.alignment = NSTextAlignmentLeft;
    lbEmailAddressNote.cell = [[UITextFieldCell alloc] init];
    lbEmailAddressNote.stringValue = @"Note: Use commas to separate recipients";
    lbEmailAddressNote.wantsLayer = YES;
    lbEmailAddressNote.layer.borderWidth = 0;
    [lbEmailAddressNote setEditable:NO];
    lbEmailAddressNote.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    lbEmailAddressNote.backgroundColor = [NSColor whiteColor];;
    lbEmailAddressNote.drawsBackground = YES;
    lbEmailAddressNote.textColor = [NSColor redColor];
    [viewMailAddressGroup addSubview:lbEmailAddressNote];
    
    //----------------------------------
    
    NSTextField *lbEmailAddress = [[NSTextField alloc] initWithFrame:NSMakeRect(10,48, 150, 20)];
    lbEmailAddress.alignment = NSTextAlignmentLeft;
    lbEmailAddress.cell = [[UITextFieldCell alloc] init];
    lbEmailAddress.stringValue = @"Email address";
    lbEmailAddress.wantsLayer = YES;
    lbEmailAddress.layer.borderWidth = 0;
    [lbEmailAddress setEditable:NO];
    lbEmailAddress.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    lbEmailAddress.backgroundColor = [NSColor whiteColor];;
    lbEmailAddress.drawsBackground = YES;
    lbEmailAddress.textColor = [NSColor blackColor];
    [viewMailAddressGroup addSubview:lbEmailAddress];
    
    NSTextField *txtEmailAddress = [[NSTextField alloc] initWithFrame:NSMakeRect(150,40, rectMailGroup.size.width - 160,30)];
    txtEmailAddress.cell = [[NSTextFieldCell alloc] init];
    [viewMailAddressGroup addSubview:txtEmailAddress];
    [txtEmailAddress.cell setFocusRingType:NSFocusRingTypeNone];
    txtEmailAddress.alignment = NSTextAlignmentLeft;
    txtEmailAddress.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    txtEmailAddress.bordered = YES;
    txtEmailAddress.wantsLayer = YES;
    txtEmailAddress.layer.borderColor = [NSColor blackColor].CGColor;
    txtEmailAddress.editable = YES;
    txtEmailAddress.backgroundColor = [NSColor redColor];
    txtEmailAddress.layer.cornerRadius = 5;
    txtEmailAddress.layer.borderWidth = 0;
    txtEmailAddress.layer.backgroundColor = [NSColor whiteColor].CGColor;
    txtEmailAddress.stringValue = [NSString stringWithFormat:@""];
    if([dicInfoSave objectForKey:@"email_reoprt"])
        txtEmailAddress.stringValue = [NSString stringWithFormat:@"%@",[dicInfoSave objectForKey:@"email_reoprt"]];
    txtEmailAddress.tag = 611;
    
    //==========================================================
#pragma mark Enable auto email report group
  
    NSRect frameEnableAutoMailFrame = NSMakeRect(10, 10, frame.size.width - 20,160);
    
    NSView *viewEnableAutoMail = [[NSView alloc] initWithFrame:frameEnableAutoMailFrame];
    viewEnableAutoMail.wantsLayer = YES;
    viewEnableAutoMail.layer.borderWidth = 1;
    viewEnableAutoMail.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [viewGroup addSubview:viewEnableAutoMail];
    
    //NSTextField *groupTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(leftTitleGroup,frameBattery.size.height+frame.origin.y-6,60,20)];
    NSButton *cbEnableAutoEmailReport = [[NSButton alloc] initWithFrame:NSMakeRect(frameEnableAutoMailFrame.origin.x + leftTitleGroup-10,frameEnableAutoMailFrame.size.height+frameEnableAutoMailFrame.origin.y-8,200,20)];
    [cbEnableAutoEmailReport setButtonType:NSSwitchButton];
    [cbEnableAutoEmailReport setTitle:@"Enable auto-email reports"];
    cbEnableAutoEmailReport.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
    [cbEnableAutoEmailReport setBezelStyle:0];
    if([dicInfoSave objectForKey:@"auto_mail_report"])
        [cbEnableAutoEmailReport setState:[[dicInfoSave objectForKey:@"auto_mail_report"] intValue]];
    else [cbEnableAutoEmailReport setState:1];
    cbEnableAutoEmailReport.tag = 801;
    [cbEnableAutoEmailReport setWantsLayer:YES];
    cbEnableAutoEmailReport.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [viewGroup addSubview:cbEnableAutoEmailReport];
    
    //-------------------------------
#pragma mark Recurrences group
    
    NSArray *itemsRecurrences = @[@"Daily", @"Weekly", @"Monthly"];
    Recurrences = itemsRecurrences[2];
    if(dicInfoSave && [dicInfoSave objectForKey:@"recurrences"])
    {
        Recurrences = [dicInfoSave objectForKey:@"recurrences"];
    }

    NSRect frameRecurrences = NSMakeRect(10,  10, frameEnableAutoMailFrame.size.width - 20,50);
    
    NSView *viewRecurrences = [[NSView alloc] initWithFrame:frameRecurrences];
    viewRecurrences.wantsLayer = YES;
    viewRecurrences.layer.backgroundColor = [NSColor whiteColor].CGColor;
    viewRecurrences.layer.borderWidth = 1;
    [viewEnableAutoMail addSubview:viewRecurrences];
    
    NSTextField *groupTitleRecurrences = [[NSTextField alloc] initWithFrame:NSMakeRect(frameRecurrences.origin.x + leftTitleGroup, frameRecurrences.origin.y + frameRecurrences.size.height-5, 100,20)];
    groupTitleRecurrences.alignment = NSTextAlignmentCenter;
    groupTitleRecurrences.cell = [[UITextFieldCell alloc] init];
    groupTitleRecurrences.stringValue = @"Recurrences";
    groupTitleRecurrences.wantsLayer = YES;
    groupTitleRecurrences.layer.borderWidth = 0;
    [groupTitleRecurrences setEditable:NO];
    groupTitleRecurrences.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    groupTitleRecurrences.backgroundColor = [NSColor whiteColor];;
    groupTitleRecurrences.drawsBackground = YES;
    groupTitleRecurrences.textColor = [NSColor blackColor];
    [viewEnableAutoMail addSubview:groupTitleRecurrences];
    
    
    NSButton *rdItem;
    
    for(int i = 0;i<itemsRecurrences.count;i++)
    {
        NSString *tmp = [itemsRecurrences objectAtIndex:i];
        rdItem = [[NSButton alloc] initWithFrame:CGRectMake(10+i*250, frameRecurrences.size.height -35,100, 20)];
        [rdItem setButtonType:NSRadioButton];
        [rdItem setTitle:tmp];
        rdItem.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
        [rdItem setBezelStyle:0];
        [rdItem setState:0];
        if([Recurrences isEqualToString:tmp])
            [rdItem setState:1];
        [rdItem setWantsLayer:YES];
        [rdItem setTarget:self];
        [rdItem setAction:@selector(rdButtonRecurrencesClick:)];
        [viewRecurrences addSubview:rdItem];
    }
    //-------------------------------
#pragma mark Schedule group
    
    NSRect frameScheduleSetting = NSMakeRect(10,  80, frameEnableAutoMailFrame.size.width - 20,60);
    NSView *viewScheduleSetting = [self createGroup:@"Schedule Setting"
                                              Frame:frameScheduleSetting
                                         parentView:viewEnableAutoMail];

    
    NSTextField *labelFrom = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 20, 100, 20)];
    labelFrom.cell = [[NSTextFieldCell alloc] init];
    labelFrom.alignment = NSTextAlignmentLeft;
    labelFrom.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    labelFrom.backgroundColor = [NSColor clearColor];
    labelFrom.layer.backgroundColor = [NSColor clearColor].CGColor;
    labelFrom.textColor = [NSColor blackColor];
    labelFrom.stringValue = @"Starting date";
    [viewScheduleSetting addSubview:labelFrom];
    
    
    NSDate *date =  [NSDate date];
    if([dicInfoSave objectForKey:@"start_date"])
    {
        NSString *str = [dicInfoSave objectForKey:@"start_date"];
        date = [self changeStringToDate:str format:@"MM-dd-yyyy"];
    }
    NSDatePicker *pickerDate = [[NSDatePicker alloc] initWithFrame:NSMakeRect(110, 15, 200, 25)];
    pickerDate.cell = [[NSDatePickerCell alloc] init];
    pickerDate.target = self;
    pickerDate.tag = 650;
    pickerDate.wantsLayer = YES;
    pickerDate.layer.borderWidth = 1;
    [pickerDate setDateValue:date];
    pickerDate.action = @selector(pickerSelected:);
    [pickerDate setDatePickerElements:NSDatePickerElementFlagYearMonthDay];
    [viewScheduleSetting addSubview:pickerDate];
    
    
    NSTextField *labelTo = [[NSTextField alloc] initWithFrame:NSMakeRect(350, 20, 100, 20)];
    labelTo.cell = [[NSTextFieldCell alloc] init];
    labelTo.alignment = NSTextAlignmentLeft;
    labelTo.font = [NSFont fontWithName:@"Roboto-Regular" size:16];
    labelTo.backgroundColor = [NSColor clearColor];
    labelTo.layer.backgroundColor = [NSColor clearColor].CGColor;
    labelTo.textColor = [NSColor blackColor];
    labelTo.stringValue = @"Starting time";
    [viewScheduleSetting addSubview:labelTo];
    
    
    date =  [NSDate date];
    if([dicInfoSave objectForKey:@"start_time"])
    {
        NSString *str = [dicInfoSave objectForKey:@"start_time"];
        date = [self changeStringToDate:str format:@"HH:mm:ss"];
    }
  
    
    NSDatePicker *pickerTime = [[NSDatePicker alloc] initWithFrame:NSMakeRect(450, 15, 200, 25)];
    pickerTime.cell = [[NSDatePickerCell alloc] init];
    pickerTime.target = self;
    pickerTime.tag = 651;
    pickerTime.wantsLayer = YES;
    pickerTime.layer.borderWidth = 1;
    [pickerTime setDateValue:date];
    pickerTime.action = @selector(pickerSelected:);
    [pickerTime setDatePickerElements:NSDatePickerElementFlagHourMinuteSecond];
    [viewScheduleSetting addSubview:pickerTime];
    
    
    //-------------------------------

}
- (void) pickerSelected:(id)sender
{
    
}
- (NSView *) createGroup:(NSString *)name Frame:(CGRect)frame parentView:(NSView *)parentView
{
    NSView *viewConten = [[NSView alloc] initWithFrame:frame];
    viewConten.wantsLayer = YES;
    viewConten.layer.backgroundColor = [NSColor whiteColor].CGColor;
    viewConten.layer.borderWidth = 1;
    [parentView addSubview:viewConten];


    NSFont *font = [NSFont fontWithName:@"Roboto-Regular" size:15];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    int widthString = (int)[[[NSAttributedString alloc] initWithString:name attributes:attributes] size].width;

//    if(checkbox == NO)
//    {
        NSTextField *groupTitleRecurrences = [[NSTextField alloc] initWithFrame:NSMakeRect(frame.origin.x + leftTitleGroup, frame.origin.y + frame.size.height-5, widthString + 20,20)];
        groupTitleRecurrences.alignment = NSTextAlignmentCenter;
        groupTitleRecurrences.cell = [[UITextFieldCell alloc] init];
        groupTitleRecurrences.stringValue = name;
        groupTitleRecurrences.wantsLayer = YES;
        groupTitleRecurrences.layer.borderWidth = 0;
        [groupTitleRecurrences setEditable:NO];
        groupTitleRecurrences.font = [NSFont fontWithName:@"Roboto-Regular" size:15];
        groupTitleRecurrences.backgroundColor = [NSColor whiteColor];;
        groupTitleRecurrences.drawsBackground = YES;
        groupTitleRecurrences.textColor = [NSColor blackColor];
        [parentView addSubview:groupTitleRecurrences];
//    }
//    else
//    {
//        NSButton *cb = [[NSButton alloc] initWithFrame:NSMakeRect(frame.origin.x + leftTitleGroup, frame.origin.y + frame.size.height-5, widthString + 20,20)];
//        [cb setButtonType:NSSwitchButton];
//        [cb setTitle:@"Enable auto-email reports"];
//        cb.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
//        [cb setBezelStyle:0];
//        if([dicInfoSave objectForKey:@"battery_settings"])
//            [cbBatterySetting setState:[[dicInfoSave objectForKey:@"battery_settings"] intValue]];
//        else [cbBatterySetting setState:0];
//        cbBatterySetting.tag = 0;
//        [cbBatterySetting setWantsLayer:YES];
//        cbBatterySetting.layer.backgroundColor = [NSColor whiteColor].CGColor;
//        [viewGroup addSubview:cbBatterySetting];
//    }
    return viewConten;
}



#pragma mark -

- (void)rdButtonRecurrencesClick:(id)sender
{
    NSButton *bt = (NSButton *)sender;
    NSLog(@"%s select :%@",__func__,bt.title);
    Recurrences = bt.title;
}

- (void)rdButtonErasureMethodClick:(id)sender
{
    NSButton *bt = (NSButton *)sender;
    NSLog(@"%s select :%@",__func__,bt.title);
    strErasure_method = bt.title;
}
- (void)rdButtonServerClick:(id)sender
{
    NSButton *bt = (NSButton *)sender;
    NSLog(@"%s select :%@",__func__,bt.title);
    strServer = bt.title;
}
- (void)rdButtonElapsedTimeClick:(id)sender
{
    NSButton *bt = (NSButton *)sender;
    NSLog(@"%s select :%@",__func__,bt.title);
    strElapsedTime = bt.title;
}
- (void)rdButtonlocationClick:(id)sender
{
    NSButton *bt = (NSButton *)sender;
    NSLog(@"%s select :%@",__func__,bt.title);
    strLocation = bt.title;
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSTextField *txtCDNLocation = (NSTextField *)[self.view viewWithTag:900];
    txtCDNLocation.stringValue = @"";
    if([[strLocation lowercaseString] isEqualToString:@"dalas"]==YES)
    {
        NSString *pathLib = [delegate pathLib];
        NSString *filename = [pathLib stringByAppendingString:@"/config/location_server_dalas.config"];
        if([[NSFileManager defaultManager] fileExistsAtPath:filename]==YES)
        {
            NSString *info = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:nil];
            NSMutableDictionary *dic = (NSMutableDictionary *)[delegate diccionaryFromJsonString:info];
            txtCDNLocation.stringValue = [NSString stringWithFormat:@"%@",[[dic objectForKey:@"cdn"] objectForKey:@"link_manual_bk"]];
        }
    }
    else if([[strLocation lowercaseString] isEqualToString:@"chicago"]==YES)
    {
        NSString *pathLib = [delegate pathLib];
        NSString *filename = [pathLib stringByAppendingString:@"/config/location_server_chicago.config"];
        if([[NSFileManager defaultManager] fileExistsAtPath:filename]==YES)
        {
            NSString *info = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:nil];
            NSMutableDictionary *dic = (NSMutableDictionary *)[delegate diccionaryFromJsonString:info];
            txtCDNLocation.stringValue = [NSString stringWithFormat:@"%@",[[dic objectForKey:@"cdn"] objectForKey:@"link_manual_bk"]];
        }
    }
    else //manual
    {
        txtCDNLocation.stringValue = @"";
    }
}
- (BOOL) isNumeric:(NSString *)s
{
   NSScanner *sc = [NSScanner scannerWithString: s];
   if ( [sc scanInt:NULL] )
   {
      // Ensure nothing left in scanner so that "42foo" is not accepted.
      // ("42" would be consumed by scanFloat above leaving "foo".)
      return [sc isAtEnd];
   }
   // Couldn't even scan a float :(
   return NO;
}

- (void) btOKlick:(id)sender
{
    //close and save info , current not check validate
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    //save location
    if([strLocation isEqualToString:@" "] || [strLocation isEqualToString:@"Manual"])
    {
        NSTextField *txtCDNLocation = [self.view viewWithTag:900];
        NSString *strlo = txtCDNLocation.stringValue;
        strlo = [strlo stringByReplacingOccurrencesOfString:@" " withString:@""];
        if(strlo.length == 0)
        {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Setting " defaultButton:@"Close" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Location text is not empty"];
            [alert runModal];
            return;
        }
        
        [dic setObject:@"Manual" forKey:@"location"];
        [dic setObject:strlo forKey:@"localLink"];
    }
    else
    {
       // NSArray *items = @[@"dalas", @"Chicago", @"Manual"];
        NSString *strlo = @"";
       
        NSString *pathLib = [delegate pathLib];
        if([[strLocation lowercaseString] rangeOfString:@"chicago"].location != NSNotFound)
        {
            strlo = @"https://storage101.ord1.clouddrive.com/v1/MossoCloudFS_6d2201cb-63f4-47a5-97f4-08c7ff9621ba/";
            pathLib = [pathLib stringByAppendingString:@"/config/location_server_chicago.config"];
            if([[NSFileManager defaultManager] fileExistsAtPath:pathLib]==NO)
            {
                //NSString* filePath = [[NSBundle mainBundle] pathForResource:@"paylines" ofType:@"txt" inDirectory:@"TextFiles"];
                NSString* filePath = [[NSBundle mainBundle] pathForResource:@"location_server_chicago" ofType:@"config"];
                NSLog(@"\n\nthe string %@",filePath);
                [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:pathLib error:nil];
                
            }
            
            NSString *info = [NSString stringWithContentsOfFile:pathLib encoding:NSUTF8StringEncoding error:nil];
            NSMutableDictionary *dicData = (NSMutableDictionary *)[delegate diccionaryFromJsonString:info];
            if([[dicData objectForKey:@"cdn"] objectForKey:@"link"]!=nil)
            {
                strlo = [[dicData objectForKey:@"cdn"] objectForKey:@"link"];
            }
        }
        else if([[strLocation lowercaseString] rangeOfString:@"dalas"].location != NSNotFound)
        {
            strlo = @"https://storage101.ord1.clouddrive.com/v1/MossoCloudFS_6d2201cb-63f4-47a5-97f4-08c7ff9621ba/";
            pathLib = [pathLib stringByAppendingString:@"/config/location_server_dalas.config"];
            if([[NSFileManager defaultManager] fileExistsAtPath:pathLib]==NO)
            {
                //NSString* filePath = [[NSBundle mainBundle] pathForResource:@"paylines" ofType:@"txt" inDirectory:@"TextFiles"];
                NSString* filePath = [[NSBundle mainBundle] pathForResource:@"location_server_dalas" ofType:@"config"];
                NSLog(@"\n\nthe string %@",filePath);
                [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:pathLib error:nil];
            }
            
            NSString *info = [NSString stringWithContentsOfFile:pathLib encoding:NSUTF8StringEncoding error:nil];
            NSMutableDictionary *dicData = (NSMutableDictionary *)[delegate diccionaryFromJsonString:info];
            if([[dicData objectForKey:@"cdn"] objectForKey:@"link"]!=nil)
            {
                strlo = [[dicData objectForKey:@"cdn"] objectForKey:@"link"];
            }
        }
        else
        {
            NSTextField *txtCDNLocation = (NSTextField *)[self.view viewWithTag:900];
            strlo = txtCDNLocation.stringValue;
        }
        [dic setObject:strlo forKey:@"localLink"];
        [dic setObject:strLocation forKey:@"location"];
    }
    
   
    //server
    [dic setObject:strServer forKey:@"server"];
    [delegate loadArrayServer:strServer];

    //timeout erase
    [dic setObject:[NSNumber numberWithInt:0] forKey:@"timeout"];//timeout erase
    NSButton *bt = [self.view viewWithTag:500]; //timeout
    if(bt && bt.state == 1)
    {
        NSTextField *tf =  [self.view viewWithTag:501];
        NSString *str = tf.stringValue;
        int va = [str intValue];
        if (va>0)
        {
            [dic setObject:[NSNumber numberWithInt:va] forKey:@"timeout"];
        }
    }
    //timeout test
    [dic setObject:[NSNumber numberWithInt:0] forKey:@"timeout_test"];//timeout erase
    bt = [self.view viewWithTag:502]; //timeout
    if(bt && bt.state == 1)
    {
        NSTextField *tf =  [self.view viewWithTag:503];
        NSString *str = tf.stringValue;
        int va = [str intValue];
        if (va>0)
        {
            [dic setObject:[NSNumber numberWithInt:va] forKey:@"timeout_test"];
        }
    }
    
    
    //autorun
    bt = [self.view viewWithTag:700];
    if(bt)
    {
        [dic setObject:[NSNumber numberWithLong:bt.state] forKey:@"auto_run_after_plugin_device"];
    }
    else [dic setObject:[NSNumber numberWithInt:0] forKey:@"auto_run_after_plugin_device"];
    
 
    bt = [self.view viewWithTag:701];
    if(bt)
    {
        [dic setObject:[NSNumber numberWithLong:bt.state] forKey:@"enable_auto_detect_device_after_proccess_complete"];
    }
    else [dic setObject:[NSNumber numberWithInt:0] forKey:@"enable_auto_detect_device_after_proccess_complete"];

    [dic setObject:strElapsedTime forKey:@"elapsed_time"];
    [dic setObject:strErasure_method forKey:@"erasure_method"];
    
    NSTextField *txtBatteryTimeout = [self.view viewWithTag:601];
    if(txtBatteryTimeout &&  txtBatteryTimeout.stringValue.length > 0)
    {
        NSString *BatteryTimeout = txtBatteryTimeout.stringValue;
        [dic setObject:BatteryTimeout forKey:@"baterry_timeout"];
    }
    else [dic setObject:@"30" forKey:@"baterry_timeout"];
   
    NSTextField *txtBarteryLever = [self.view viewWithTag:602];
    if(txtBarteryLever &&  txtBarteryLever.stringValue.length > 0)
        [dic setObject:txtBarteryLever.stringValue forKey:@"battery_lever"];
    else [dic setObject:@"30" forKey:@"battery_lever"];
    
    
    NSTextField *txtCycleCount = [self.view viewWithTag:603];
    if(txtCycleCount &&  txtCycleCount.stringValue.length > 0)
        [dic setObject:txtCycleCount.stringValue forKey:@"battery_cycle_count"];
    else [dic setObject:@"1000" forKey:@"battery_cycle_count"];
    
    NSTextField *txtSoH = [self.view viewWithTag:604];
    if(txtSoH &&  txtSoH.stringValue.length > 0)
        [dic setObject:txtSoH.stringValue forKey:@"battery_soh"];
    else [dic setObject:@"30" forKey:@"battery_soh"];
    
    bt = [self.view viewWithTag:600];
    if(bt)
    {
        [dic setObject:[NSNumber numberWithLong:bt.state] forKey:@"battery_settings"];
    }
    else [dic setObject:[NSNumber numberWithInt:0] forKey:@"battery_settings"];
   
    
    NSTextField *txtEmailAddress =  [self.view viewWithTag:611];
    if(txtEmailAddress &&  txtEmailAddress.stringValue.length > 0)
        [dic setObject:txtEmailAddress.stringValue forKey:@"email_reoprt"];
    else [dic setObject:@"" forKey:@"email_reoprt"];
    
    bt = [self.view viewWithTag:801];
    if(bt)
    {
        [dic setObject:[NSNumber numberWithLong:bt.state] forKey:@"auto_mail_report"];
    }
    else [dic setObject:[NSNumber numberWithInt:0] forKey:@"auto_mail_report"];
   
    
    
    //NSDate *date = [NSDate date];
    //NSCalendar *calendar = [NSCalendar currentCalendar];
    //int day = [calendar component:NSCalendarUnitDay fromDate:date];
    NSDate *dateTmp = [NSDate date];
    NSDatePicker *pickerDate = [self.view viewWithTag:650];
    if(pickerDate)
    {
        dateTmp = [pickerDate dateValue];
    }
    NSString *strdate = [self changeDateToString:dateTmp format:@"dd-MM-yyyy"];
    [dic setObject:strdate forKey:@"start_date"];
    
    
    dateTmp = [NSDate date];
    NSDatePicker *pickerTime = [self.view viewWithTag:651];
    if(pickerTime)
    {
        dateTmp = [pickerTime dateValue];
    }
    strdate = [self changeDateToString:dateTmp format:@"HH:mm:ss"];
    [dic setObject:strdate forKey:@"start_time"];
    
    
    [dic setObject:Recurrences forKey:@"recurrences"];
    
    BOOL result = [delegate saveSettingInfo:dic];
    if(result == NO)
    {
        NSLog(@"Save data failed ");
    }
    dicInfoSave = [delegate loadSettingInfoSave];
    
    
    NSLog(@"%s data setting save: %@ ",__func__,dicInfoSave);
    
    [self btCloseClick:sender];
}
- (NSString *) changeDateToString :(NSDate *)date format:(NSString*)Template
{

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSLocale *locale = [NSLocale currentLocale];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:Template options:0 locale:locale];//@"dd-MM-yyyy hh:mm:ss"
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setLocale:locale];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}
- (NSDate *) changeStringToDate:(NSString *)str format:(NSString*)Template
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:Template];
    NSDate *dte = [dateFormatter dateFromString:str];
    NSLog(@"Date: %@", dte);
    return dte;
}
- (void) btCancellick:(id)sender
{
    //close withdown saving
    [self btCloseClick:sender];
}

- (NSWindow *)showWindow
{
    UIWindow *window = [UIWindow windowWithContentViewController:self];
    [window center];
    [window setBackgroundColor:[NSColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0]];
    [window setContentSize:NSSizeFromCGSize(CGSizeMake(self.view.frame.size.width, self.view.frame.size.height))];
    window.title = @"iCombine Watch";
    window.contentViewController = self;
    [window setLevel:NSNormalWindowLevel];
    [window setStyleMask:NSBorderlessWindowMask];
    NSWindowController *windowControllerIF = [[NSWindowController alloc] initWithWindow:window];
    [windowControllerIF.window makeKeyAndOrderFront:self];
    [windowControllerIF showWindow:nil];
    return window;
}
- (void)createHeader
{
    CGRect frame = self.view.frame;
    int width = frame.size.width;
    int height = frame.size.height;
    
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSView *viewTop = [[NSView alloc] initWithFrame:NSMakeRect(0, height - 50, width, 50)];
    viewTop.wantsLayer = YES;
    viewTop.layer.backgroundColor = delegate.colorBanner.CGColor;
    [self.view addSubview:viewTop];
    
    NSTextField *txtHeader = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, width, 47)];
    txtHeader.cell = [[NSTextFieldCell alloc] init];
    [viewTop addSubview:txtHeader];
    txtHeader.alignment = NSTextAlignmentLeft;
    txtHeader.font = [NSFont fontWithName:@"Roboto-Regular" size:24];
    txtHeader.backgroundColor = [NSColor clearColor];
    txtHeader.layer.backgroundColor = [NSColor clearColor].CGColor;
    txtHeader.textColor = [NSColor whiteColor];
    txtHeader.stringValue = @"   Setting";
  
    NSButton *btCloseTop = [[NSButton alloc] initWithFrame:NSMakeRect(width - 40,10, 30, 30)];
    btCloseTop.title = @"";
    btCloseTop.image = [NSImage imageNamed:@"CloseWhite.png"];
    [[btCloseTop cell] setBackgroundColor:delegate.colorBanner];
    btCloseTop.wantsLayer = YES;
    [btCloseTop setBordered:NO];
    [btCloseTop setToolTip:@"Close"];
    [btCloseTop setTarget:self];
    [btCloseTop setAction:@selector(btCloseClick:)];
    [viewTop addSubview:btCloseTop];
    
}
- (void)btCloseClick:(id)sender
{
    [self.view.window close];
}
@end
