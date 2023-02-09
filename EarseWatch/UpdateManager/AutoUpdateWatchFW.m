//
//  AutomaticUpdateFirmware.m
//  iCombine Watch
//
//  Created by Duyet Le on 9/14/22.
//  Copyright © 2022 Greystone. All rights reserved.
//
//https://drive.google.com/drive/u/0/folders/1dV07B7r0QCVSS3Jh8OEcA-OtZ07LuLNH

#import "AutoUpdateWatchFW.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "define_gds.h"
#import "LibUSB/ProccessUSB.h"
#import "AFNetworking.h"
#import "XMLReader.h"

@interface AutoUpdateWatchFW ()

@end

@implementation AutoUpdateWatchFW
- (instancetype)init
{
    NSRect frame = NSMakeRect(0, 0, 800, 600);
    self = [super init];
    self.view = [[NSView alloc] init];
    self.view.frame = frame;
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = NSColor.whiteColor.CGColor;
    self.view.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [delegate writeLog:@" init" key:POS_LOG];
    //==============================Title top=================================
    titleWindow = [[NSTextField alloc] initWithFrame:NSMakeRect(0, frame.size.height - 50, frame.size.width, 50)];
    titleWindow.cell = [[NSTextFieldCell alloc] init];
    titleWindow.stringValue = @"  Automatic watchOS update";
    titleWindow.alignment = NSTextAlignmentLeft;
    titleWindow.font = [NSFont fontWithName:@"Roboto-Regular" size:28];
    titleWindow.textColor = [NSColor whiteColor];
    titleWindow.wantsLayer = YES;
    [titleWindow setBordered:NO];
    titleWindow.backgroundColor = delegate.colorBanner;
    titleWindow.layer.backgroundColor = delegate.colorBanner.CGColor;
    [self.view addSubview:titleWindow];
    
    NSButton *btCloseTop = [[NSButton alloc] initWithFrame:NSMakeRect(frame.size.width - 48,frame.size.height - 48, 46, 46)];
    btCloseTop.title = @"";
    btCloseTop.image = [NSImage imageNamed:@"CloseWhite.png"];
    [[btCloseTop cell] setBackgroundColor:delegate.colorBanner];
    btCloseTop.wantsLayer = YES;
    [btCloseTop setBordered:NO];
    [btCloseTop setToolTip:@"Close"];
    [btCloseTop setTarget:self];
    [btCloseTop setAction:@selector(btCloseClick:)];
    [self.view addSubview:btCloseTop];
    //==============================Content=================================
    //==============================Current version=================================
    dicMacFWNew = nil;
    enableButtonUpdate = NO;
    [self drawCurrentVersion:NSMakeRect(20, 100,  frame.size.width/2-30,frame.size.height-170)];
    [self drawNewVersion:NSMakeRect(frame.size.width/2+10, 100,  frame.size.width/2-30,frame.size.height-170)];
    [self performSelector:@selector(checkNewVersion:)
               withObject: [NSValue valueWithRect:NSMakeRect(frame.size.width/2+10, 100,  frame.size.width/2-30,frame.size.height-170)]
               afterDelay:3];
    //==============================Proccess bar=================================
    
    NSTextField *lbDownloading = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 70, 150, 20)];
    lbDownloading.cell = [[NSTextFieldCell alloc] init];
    lbDownloading.stringValue = @"Downloading ...";
    lbDownloading.alignment = NSTextAlignmentRight;
    lbDownloading.font = [NSFont fontWithName:@"Roboto-Regular" size:12];
    lbDownloading.textColor = [NSColor blackColor];
    lbDownloading.wantsLayer = YES;
    [lbDownloading setBordered:NO];
    lbDownloading.backgroundColor = NSColor.clearColor;
    lbDownloading.layer.backgroundColor = NSColor.clearColor.CGColor;
    lbUpdating = lbDownloading;
    lbUpdating.hidden = YES;
    [self.view addSubview:lbDownloading];
    
    proccessWidthMax = frame.size.width-360;
    NSRect rect = NSMakeRect(180,70, proccessWidthMax, 20);
    NSTextField *ProccessbarBackground = [[NSTextField alloc] initWithFrame:rect];
    ProccessbarBackground.cell = [[NSTextFieldCell alloc] init];
    ProccessbarBackground.layer.cornerRadius = 10;
    ProccessbarBackground.stringValue = @" ";
    [ProccessbarBackground setEditable:NO];
    ProccessbarBackground.backgroundColor = [NSColor colorWithSRGBRed:224.0/255 green:224.0/255 blue:224.0/255 alpha:1.0];
    ProccessbarBackground.drawsBackground = YES;
    ProccessbarBG = ProccessbarBackground;
    ProccessbarBG.hidden = YES;
    [self.view addSubview:ProccessbarBackground];
    
    NSTextField *ProccessbarRun = [[NSTextField alloc] initWithFrame:NSMakeRect(rect.origin.x, rect.origin.y, 0, rect.size.height)];
    ProccessbarRun.cell = [[NSTextFieldCell alloc] init];
    [ProccessbarRun setEditable:NO];
    ProccessbarRun.backgroundColor = [NSColor colorWithSRGBRed:12.0/255 green:126.0/255 blue:210.0/255 alpha:1.0];
    ProccessbarRun.drawsBackground = YES;
    ProccessbarRun.layer.cornerRadius = 10;
    ProccessbarRun.stringValue = @" ";
    [self.view addSubview:ProccessbarRun];
    proccessbarRun = ProccessbarRun;
    proccessbarRun.hidden = YES;
   
    NSTextField *ProccessbarText = [[NSTextField alloc] initWithFrame:NSMakeRect(rect.origin.x, rect.origin.y+5, rect.size.width, rect.size.height)];
    ProccessbarText.cell = [[NSTextFieldCell alloc] init];
    ProccessbarText.stringValue = @"0 %";
    [ProccessbarText setEditable:NO];
    ProccessbarText.font = [NSFont fontWithName:@"Roboto-Bold" size:16];
    ProccessbarText.backgroundColor = [NSColor clearColor];
    ProccessbarText.drawsBackground = YES;
    ProccessbarText.alignment = NSTextAlignmentCenter;
    ProccessbarText.textColor = [NSColor whiteColor];
    [self.view addSubview:ProccessbarText];
    proccessbarText = ProccessbarText;
    proccessbarText.hidden = YES;
    

    
    //debug
    NSTextField *lbtestText = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 0, 700, 20)];
    lbtestText.cell = [[NSTextFieldCell alloc] init];
    lbtestText.stringValue = @"File ...";
    lbtestText.alignment = NSTextAlignmentRight;
    lbtestText.font = [NSFont fontWithName:@"Roboto-Regular" size:12];
    lbtestText.textColor = [NSColor blackColor];
    lbtestText.wantsLayer = YES;
    [lbtestText setBordered:NO];
    lbtestText.backgroundColor = NSColor.clearColor;
    lbtestText.layer.backgroundColor = NSColor.clearColor.CGColor;
    [self.view addSubview:lbtestText];
    testText = lbtestText;
    testText.hidden = YES;// chi de debug
    //==============================Button Bottom=================================
    NSMutableArray *buttons = [NSMutableArray arrayWithObjects:@"Update",@"Close",nil];
  
    
    NSButton *bt = [[NSButton alloc] initWithFrame:NSMakeRect(frame.size.width/2 - 120,20, 100, 30)];
    [bt setFont:[NSFont fontWithName:@"Roboto-Regular" size:15]];
    bt.wantsLayer = YES;
    [bt setBordered:YES];
    bt.layer.cornerRadius = 5;
    bt.layer.borderWidth = 2;
    bt.enabled = enableButtonUpdate;
    bt.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
    [bt setToolTip:[buttons objectAtIndex:0]];
    [bt setTarget:self];
    bt.image = [NSImage imageNamed:@"button_normal.png"];
    bt.title = [buttons objectAtIndex:0];
    bt.tag = 110;
    [bt setAction:@selector(btUpdateClick:)];
    [self.view addSubview:bt];
    
    NSButton *bt1 = [[NSButton alloc] initWithFrame:NSMakeRect(frame.size.width/2 + 20,20, 100, 30)];
    [bt1 setFont:[NSFont fontWithName:@"Roboto-Regular" size:15]];
    bt1.wantsLayer = YES;
    [bt1 setBordered:YES];
    bt1.layer.cornerRadius = 5;
    bt1.layer.borderWidth = 2;
    bt1.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
    [bt1 setToolTip:[buttons objectAtIndex:1]];
    [bt1 setTarget:self];
    bt1.image = [NSImage imageNamed:@"button_normal.png"];
    bt1.title = [buttons objectAtIndex:1];
    bt1.tag = 111;
    [bt1 setAction:@selector(btCloseClick:)];
    [self.view addSubview:bt1];
    
   
   
    
    
    
    return self;
}

- (void)drawCurrentVersion:(NSRect) rectFrame
{
    NSRect frame =  self.view.frame;
    int numrow = 0,rowHeigh = 40;
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSMutableDictionary *dicSupport = [delegate.mainViewController getConfig];
    numrow = (int)[dicSupport allKeys].count;
    NSLog(@"%s dicSupport num item: %d\n data:%@",__func__,numrow,dicSupport);
    NSRect rectCurrent = NSMakeRect(0, 0, frame.size.width/2-30,numrow*rowHeigh);
    NSView *viewCurrentVersion = [[NSView alloc] initWithFrame:rectCurrent];
    NSTextField *lbName,*lbVersion;
    NSString *key;
    NSMutableDictionary *dicItem;
    
    NSArray *arr = [dicSupport allKeys];
    NSArray *arrkey = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *obj1str = [NSString stringWithFormat:@"%@",obj1];
        NSArray *list1 = [[[obj1str lowercaseString] stringByReplacingOccurrencesOfString:@"watch" withString:@""] componentsSeparatedByString:@","];
        NSString *obj2str = [NSString stringWithFormat:@"%@",obj2];
        NSArray *list2 = [[[obj2str lowercaseString] stringByReplacingOccurrencesOfString:@"watch" withString:@""] componentsSeparatedByString:@","];
        obj1str = list1[0];
        obj2str = list2[0];
        return [obj1str intValue] < [obj2str intValue];
    }];
    
    
//    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"idevice_name" ascending:YES];
//    arrkey = [arrkey sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
    if(dicMacFWCurent==nil)
        dicMacFWCurent = [NSMutableDictionary dictionary];
    for(int i=0;i<numrow;i++)
    {
        key = [arrkey objectAtIndex:i];
        dicItem = [dicSupport objectForKey:key];
        [dicItem setObject:[NSNumber numberWithInt:0] forKey:@"is_new"];
        [dicMacFWCurent setObject:dicItem forKey:key];
        
        lbName = [[NSTextField alloc] initWithFrame:NSMakeRect(10, rectCurrent.size.height - (i+1)*rowHeigh+10, rectCurrent.size.width-60, 20)];
        lbName.cell = [[NSTextFieldCell alloc] init];
        lbName.stringValue = [NSString stringWithFormat:@"%@ (%@)",dicItem[@"idevice_name"],key];
        lbName.alignment = NSTextAlignmentLeft;
        lbName.textColor = [NSColor blackColor];
        lbName.wantsLayer = YES;
        [lbName setBordered:NO];
        [viewCurrentVersion addSubview:lbName];
        
        lbVersion = [[NSTextField alloc] initWithFrame:NSMakeRect(rectCurrent.size.width-60, rectCurrent.size.height - (i+1)*rowHeigh+10, 60, 20)];
        lbVersion.cell = [[NSTextFieldCell alloc] init];
        lbVersion.stringValue = dicItem[@"FW_version"];
        lbVersion.alignment = NSTextAlignmentLeft;
        lbVersion.textColor = [NSColor blackColor];
        lbVersion.wantsLayer = YES;
        [lbVersion setBordered:NO];
        [viewCurrentVersion addSubview:lbVersion];
        
    }
    
   // NSScrollView *scrollContainer = [[NSScrollView alloc] initWithFrame:NSMakeRect(20, 100,  frame.size.width/2-30,frame.size.height-170)];
    NSScrollView *scrollContainer = [[NSScrollView alloc] initWithFrame:rectFrame];
    scrollContainer.layer.borderColor = [NSColor clearColor].CGColor;
    [scrollContainer setWantsLayer:YES];
    scrollContainer.layer.borderWidth = 2.0;
    scrollContainer.borderType = NSLineBorder;
    [scrollContainer setDocumentView:viewCurrentVersion];
    [scrollContainer setHasVerticalScroller:NO];
    scrollContainer.backgroundColor = [NSColor whiteColor];//[NSColor whiteColor];
    [self.view addSubview:scrollContainer];
    [scrollContainer.contentView scrollToPoint:NSMakePoint(0, [[scrollContainer documentView] bounds].size.height)];
  
    lbName = [[NSTextField alloc] initWithFrame:NSMakeRect(30,rectFrame.origin.y +rectFrame.size.height-10, 140, 30)];
    lbName.cell = [[NSTextFieldCell alloc] init];
    lbName.stringValue = @" Current version";
    lbName.alignment = NSTextAlignmentLeft;
    lbName.textColor = [NSColor colorWithSRGBRed:208.0/255 green:186.0/255 blue:138.0/255 alpha:1.0];
    lbName.backgroundColor = [NSColor whiteColor];
    lbName.wantsLayer = YES;
    lbName.drawsBackground = YES;
    [lbName setBordered:NO];
    lbName.font = [NSFont fontWithName:@"Roboto-Regular" size:18];
    [self.view  addSubview:lbName];
}

- (void)drawNewVersion:(NSRect) rectFrame
{
    NSRect frame =  self.view.frame;
    int numrow = 0,rowHeigh = 40;
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSMutableDictionary *dicSupport = [delegate.mainViewController getConfig];
    if(dicMacFWNew)
        dicSupport = dicMacFWNew;
    numrow = (int)[dicSupport allKeys].count;
    NSLog(@"%s dicSupport num item: %d\n data:%@",__func__,numrow,dicSupport);
    
    NSRect rectCurrent = NSMakeRect(0, 0, frame.size.width/2-30,numrow*rowHeigh);
    NSView *viewNewVersion = [[NSView alloc] initWithFrame:rectCurrent];
    NSTextField *lbVersion;
    NSString *key;
    NSMutableDictionary *dicItem;
    
    NSArray *arr = [dicSupport allKeys];
    NSArray *arrkey = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *obj1str = [NSString stringWithFormat:@"%@",obj1];
        NSArray *list1 = [[[obj1str lowercaseString] stringByReplacingOccurrencesOfString:@"watch" withString:@""] componentsSeparatedByString:@","];
        NSString *obj2str = [NSString stringWithFormat:@"%@",obj2];
        NSArray *list2 = [[[obj2str lowercaseString] stringByReplacingOccurrencesOfString:@"watch" withString:@""] componentsSeparatedByString:@","];
        obj1str = list1[0];
        obj2str = list2[0];
        return [obj1str intValue] < [obj2str intValue];
    }];
    
    arrkeyNew = arrkey;
//    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"idevice_name" ascending:YES];
//    arrkey = [arrkey sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
    enableButtonUpdate = NO;
    numRowNew = numrow;
    
    for(int i=0;i<numrow;i++)
    {
        NSButton *cbtem =  [self.view viewWithTag:900+i];
        if(cbtem)
        {
            [cbtem removeFromSuperview];
        }
        
        key = [arrkey objectAtIndex:i];
        dicItem = [dicSupport objectForKey:key];
    
        
        NSButton *cbSelect = [[NSButton alloc] initWithFrame:NSMakeRect(10, rectCurrent.size.height - (i+1)*rowHeigh+10, rectCurrent.size.width-50, 20)];
        [cbSelect setButtonType:NSSwitchButton];
        NSString *tmp = dicItem[@"idevice_name"];
        if([tmp rangeOfString:key].location == NSNotFound)
            [cbSelect setTitle:[NSString stringWithFormat:@"%@ (%@)",dicItem[@"idevice_name"],key]];
        else [cbSelect setTitle:[NSString stringWithFormat:@"%@",dicItem[@"idevice_name"]]];
        cbSelect.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
        [cbSelect setBezelStyle:0];
        [cbSelect setState:0];
        cbSelect.tag = 900+i;
        cbSelect.enabled = NO;
       
        if(dicMacFWNew!=nil && [dicMacFWNew objectForKey:key])
        {
//            if([key isEqualToString:@"Watch6,1"])
//                NSLog(@"debug vi tri");
            
            NSMutableDictionary *dic_temp = [dicMacFWNew objectForKey:key];
            if([dic_temp objectForKey:@"is_new"] != nil && [[dic_temp objectForKey:@"is_new"] intValue] != 0)
            {
                cbSelect.enabled = YES;
                [cbSelect setState:1];
                enableButtonUpdate = YES;
            }
        }
        [cbSelect setWantsLayer:YES];
        cbSelect.layer.backgroundColor = [NSColor whiteColor].CGColor;
        [cbSelect setTarget:self];
        [cbSelect setAction:@selector(cbItemClick:)];
        [viewNewVersion addSubview:cbSelect];
        
        
        
        lbVersion = [[NSTextField alloc] initWithFrame:NSMakeRect(rectCurrent.size.width-60, rectCurrent.size.height - (i+1)*rowHeigh+10, 60, 20)];
        lbVersion.cell = [[NSTextFieldCell alloc] init];
        lbVersion.stringValue = dicItem[@"FW_version"];
        lbVersion.alignment = NSTextAlignmentLeft;
        lbVersion.textColor = [NSColor blackColor];
        lbVersion.font = [NSFont fontWithName:@"Roboto-Medium" size:14];
        lbVersion.wantsLayer = YES;
        [lbVersion setBordered:NO];
        [viewNewVersion addSubview:lbVersion];
        
    }
    
    NSButton *btUpdate = (NSButton *)[self.view viewWithTag:110];
    if(btUpdate)
        btUpdate.enabled = enableButtonUpdate;
    
   // NSScrollView *scrollContainer = [[NSScrollView alloc] initWithFrame:NSMakeRect(20, 100,  frame.size.width/2-30,frame.size.height-170)];
    NSScrollView *scrollContainer = [[NSScrollView alloc] initWithFrame:rectFrame];
    scrollContainer.layer.borderColor = [NSColor clearColor].CGColor;
    [scrollContainer setWantsLayer:YES];
    scrollContainer.layer.borderWidth = 2.0;
    scrollContainer.borderType = NSLineBorder;
    [scrollContainer setDocumentView:viewNewVersion];
    [scrollContainer setHasVerticalScroller:NO];
    scrollContainer.backgroundColor = [NSColor whiteColor];//[NSColor whiteColor];
    [self.view addSubview:scrollContainer];
    [scrollContainer.contentView scrollToPoint:NSMakePoint(0, rectCurrent.size.height-20)];
   
    if ([scrollContainer hasVerticalScroller]) {
        scrollContainer.verticalScroller.floatValue = 0;
        }
        // Scroll the contentView to top
        [scrollContainer.contentView scrollToPoint:NSMakePoint(0, ((NSView*)scrollContainer.documentView).frame.size.height - scrollContainer.contentSize.height)];
    

    NSButton *cbSelectAll = [[NSButton alloc] initWithFrame:NSMakeRect(rectFrame.origin.x +30,rectFrame.origin.y +rectFrame.size.height-10, 140, 30)];
    [cbSelectAll setButtonType:NSSwitchButton];
    [cbSelectAll setTitle:[NSString stringWithFormat:@" New version"]];
    cbSelectAll.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
    [cbSelectAll setBezelStyle:0];
    [cbSelectAll setState:1];
    cbSelectAll.tag = 801;
    [cbSelectAll setWantsLayer:YES];
    cbSelectAll.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [self.view  addSubview:cbSelectAll];
    [cbSelectAll setTarget:self];
    [cbSelectAll setAction:@selector(cbSelectAllClick:)];
    
}
- (void)cbItemClick:(id)sender
{
    NSButton *bt = (NSButton *)sender;
    NSLog(@"%s bt state: %d",__func__,(int)bt.state);
    BOOL flag = NO;
    for(int i=0;i<numRowNew;i++)
    {
        NSButton *bt = (NSButton *)[self.view viewWithTag:900+i];
        if(bt.state == YES)
            flag = YES;
    }
    NSButton *btUpdate = (NSButton *)[self.view viewWithTag:110];
    if(flag)
        btUpdate.enabled = YES;
    else btUpdate.enabled = NO;
}

- (void)checkNewVersion:(NSValue *) rectVal
{
    NSString *token = [self createTokenWithUser:USER_NAME_CDN api:API_KEY_CDN];
    NSLog(@"token:%@",token);
    NSMutableDictionary *dicCheckSumOnServer = (NSMutableDictionary *)[self dicInfoWatchFWOnServer:token];
    NSLog(@"dicCheckSum:%@",dicCheckSumOnServer);
    dicMacFWNew = [self dicInfoModify:dicCheckSumOnServer];
    /*
    "Watch1,2" =     {
            "FW_version" = "4.3.2";
            "FW_version_name" = "4.3.2";
            capacity = GB;
            checksum = 362c89fcc7b058b54d24b54ed9514855;
            "file_restore" = "Watch1,2_M4_4.3.2_Restore.ipsw";
            "idevice_name" = "Apple Watch (1st generation) (Watch1,2)";
            "idevice_type" = "Watch1,2";
            "is_new" = 2;
        };
*/
    
    NSRect rectFrame = [rectVal rectValue];
    [self drawNewVersion:rectFrame];
    
}
- (NSMutableDictionary *) dicInfoModify:(NSMutableDictionary *)dicServer
{
    NSMutableDictionary *dicMacFW = [NSMutableDictionary dictionary];
    NSMutableArray *array_new = (NSMutableArray *)[[dicServer objectForKey:@"list_item"] objectForKey:@"item"];
    NSMutableDictionary *newItem,*oldItem;
    for(int i=0;i<array_new.count;i++)// run array new
    {
        newItem = (NSMutableDictionary *)[array_new objectAtIndex:i];//new array
        NSString *key = [[newItem objectForKey:@"idevice_type"] objectForKey:@"text"];
        if(key==nil || [[key lowercaseString] rangeOfString:@"watch"].location == NSNotFound) continue;
        
        NSString *filename = [[newItem objectForKey:@"filename"] objectForKey:@"text"];
        oldItem = [dicMacFWCurent objectForKey:key];
        if(oldItem == nil)// chua co
        {
            //them moi vao
            NSString *FW_version = [NSString stringWithFormat:@"%@",[[newItem objectForKey:@"version"] objectForKey:@"text"]];
            NSString *device_type = [NSString stringWithFormat:@"%@",[[newItem objectForKey:@"idevice_type"] objectForKey:@"text"]];
            NSString *productname = [NSString stringWithFormat:@"%@",[[newItem objectForKey:@"productname"] objectForKey:@"text"]];
            NSString *checksum = [NSString stringWithFormat:@"%@",[[newItem objectForKey:@"checksum"] objectForKey:@"text"]];
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        FW_version, @"FW_version",
                                        FW_version, @"FW_version_name",
                                        @"GB", @"capacity",
                                        filename,@"file_restore",
                                        productname,@"idevice_name",
                                        key,@"idevice_type",
                                        checksum,@"checksum",
                                        [NSNumber numberWithInt:2],@"is_new",// 2:add file moi
                                        nil];
            [dicMacFW setObject:dic forKey:key];
/*
            //save current
//            {
//                "FW_version" = "6.3";
//                "FW_version_name" = "6.3";
//                capacity = 8GB;
//                "file_restore" = NONE;
//                "idevice_name" = "Apple Watch Series 2";
//                "idevice_type" = "Watch2,3";
//                "is_new" = 0;
//            }
//            //new read from server
//            "Watch6,4" =     {
//                "FW_version" = "8.1";
//                "FW_version_name" = "8.1";
//                capacity = GB;
//                checksum = 5de869d181e04c20338bffbbf6667846;
//                "file_restore" = "Watch6,4_8.1_19R570_Restore.ipsw";
//                "idevice_name" = "Apple Watch Series 6 (Watch6,4)";
//                "idevice_type" = "Watch6,4";
//                "is_new" = 1;
//            };
            // on server
             {
                             checksum =                 {
                                 text = 6ed6cb1c2eac7177f96c9fbcf04a4f34;
                             };
                             filename =                 {
                                 text = "iPhone3,1_7.1.2_11D257_Restore.ipsw";
                             };
                             "idevice_type" =                 {
                                 text = "iPhone3,1";
                             };
                             "name_interface" =                 {
                                 text = "iPhone 4 (7.1.2/ 1.1 GB - iPhone3,1)";
                             };
                             productname =                 {
                                 text = "iPhone 4";
                             };
                             producttype =                 {
                                 text = iPhone;
                             };
                             text = "";
                             version =                 {
                                 text = "7.1.2";
                             };
                         },

*/

        }
        else
        {
            
            NSString *FW_version = [NSString stringWithFormat:@"%@",[[newItem objectForKey:@"version"] objectForKey:@"text"]];
            NSString *device_type = [NSString stringWithFormat:@"%@",[[newItem objectForKey:@"idevice_type"] objectForKey:@"text"]];
            NSString *productname = [NSString stringWithFormat:@"%@",[[newItem objectForKey:@"productname"] objectForKey:@"text"]];
            NSString *checksumNew = [NSString stringWithFormat:@"%@",[[newItem objectForKey:@"checksum"] objectForKey:@"text"]];
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        FW_version, @"FW_version",
                                        FW_version, @"FW_version_name",
                                        @"GB", @"capacity",
                                        filename,@"file_restore",
                                        productname,@"idevice_name",
                                        key,@"idevice_type",
                                        checksumNew,@"checksum",
                                        [NSNumber numberWithInt:1],@"is_new",//1: update lai
                                        nil];
            
            NSString *checksum_old = [NSString stringWithFormat:@"%@",[oldItem objectForKey:@"checksum"]];
            NSString *path = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"/Documents/EarseWatch/IPSW/%@",filename]]].path;
            BOOL isExistsFile = [[NSFileManager defaultManager] fileExistsAtPath:path];
            
//            if([key isEqualToString:@"Watch6,1"])
//                NSLog(@"debug vi tri");
            
            if([checksumNew isEqualToString:checksum_old] == YES && isExistsFile==YES)
            {
                [dic setObject:[NSNumber numberWithInt:0] forKey:@"is_new"];
            }
            [dicMacFW setObject:dic forKey:key];
            
        }
        
    }
    return dicMacFW;
}
- (NSDictionary *) dicInfoWatchFWOnServer:(NSString *)token
{
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    ProccessUSB *libusb = delegate.mainViewController.libusb;
    if(libusb == nil)
        libusb = [[ProccessUSB alloc] init];
    
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"/EarseWatch/NewSoftware/Release_Checksum.xml"];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]==YES)
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
    NSString *cmd = [NSString stringWithFormat: @"curl -H \"X-Auth-Token: %@\" \"https://storage101.dfw1.clouddrive.com/v1/MossoCloudFS_6d2201cb-63f4-47a5-97f4-08c7ff9621ba/MiniZeroIT_AIO/iOS_Version/version/Release_Checksum.xml\" --output %@ ",token,filePath];
    
    NSString *result = [libusb runCommandNew:cmd];
    NSLog(@"get checksum %@",result);
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO)
    {
        [delegate writeLog:[NSString stringWithFormat:@"Error file Release_Checksum not exists"] key:POS_LOG];
        return nil;//@{};
    }
    NSError *error;
        
//    chuyen doi xml parser
    
    NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        [delegate writeLog:[NSString stringWithFormat:@"Error reading file Release_Checksum: %@", error.localizedDescription] key:POS_LOG];
        return nil;//@{};
    }
    [delegate writeLog:[NSString stringWithFormat:@"Checksum data xml:%@ ",fileContents] key:POS_LOG];


    NSDictionary *dic = [XMLReader dictionaryFromXMLString:fileContents error:&error];
    if(error)
    {
        [delegate writeLog:[NSString stringWithFormat:@"Error parser to dictionary: %@", error.localizedDescription] key:POS_LOG];
        dic = nil;//@{};
    }
    return dic;
}

- (NSString *)createTokenWithUser:(NSString *)username api:(NSString*)apikey
{
    
    NSMutableDictionary *auth = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                username,@"username",
                                apikey,@"apiKey",
                                nil];
    NSMutableDictionary *mapAuth = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    auth,@"RAX-KSKEY:apiKeyCredentials",
                                    nil];
    NSMutableDictionary *mapData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    mapAuth,@"auth",
                                    nil];
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSString *strjson = [delegate jsonStringFromDictionary:mapData];
    NSString *mServerLink = @"https://identity.api.rackspacecloud.com/v2.0/tokens";
    [delegate writeLog:[NSString stringWithFormat:@"postlink:%@ data:%@",mServerLink,strjson] key:POS_LOG];
    

    ProccessUSB *libusb = delegate.mainViewController.libusb;
    if(libusb == nil)
        libusb = [[ProccessUSB alloc] init];
    NSString *cmd = @"curl -X POST https://identity.api.rackspacecloud.com/v2.0/tokens -H 'Content-Type: application/json' -d '{\"auth\":{\"RAX-KSKEY:apiKeyCredentials\":{\"username\":\"greycdn.user\",\"apiKey\":\"608720ab85c3498c82f5fda650f9a079\"}}}'";
    NSString *result = [libusb runCommandNew:cmd];
    NSDictionary *dic  = [delegate diccionaryFromJsonString:result];
    NSString *strToken = [NSString stringWithFormat:@"%@",[[[dic objectForKey:@"access"] objectForKey:@"token"] objectForKey:@"id"]];
    [delegate writeLog:[NSString stringWithFormat:@"Token: %@",strToken] key:POS_LOG];
    return strToken;

 
}

- (void)cbSelectAllClick:(id)sender
{
    NSButton *cbSelectAll = (NSButton *)sender;
    bool state = cbSelectAll.state;
    NSButton *btUpdate = (NSButton *)[self.view viewWithTag:110];
    for(int i=0;i<numRowNew;i++)
    {
        NSButton *bt = (NSButton *)[self.view viewWithTag:900+i];
        if(bt.enabled)
        {
            bt.state = state;
            if(state==YES)
                btUpdate.enabled = YES;
        }
    }
    if(state==NO)
        btUpdate.enabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (void)percentUpdate:(int)percent
{
  
    NSLog(@"%s pecent:%d",__func__,percent);
   
    dispatch_async(dispatch_get_main_queue(), ^{
        NSRect rect = self->proccessbarRun.frame;
        int valueWidth = (int)(percent*self->proccessWidthMax*1.0/100);
        self->proccessbarRun.frame = NSMakeRect(rect.origin.x, rect.origin.y, valueWidth, rect.size.height);
        self->proccessbarText.stringValue = [NSString stringWithFormat:@"%d %%",percent];
    });
    
    
}
-(void) runUpdate
{
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
  
    if(arrayUpdate.count==0) return;
    if(listFileDownloaded == nil) listFileDownloaded = [[NSMutableArray alloc] init];
    else [listFileDownloaded removeAllObjects];
    [delegate writeLog:[NSString stringWithFormat:@"dicMacFWNew: %@",dicMacFWNew] key:POS_LOG];
    [delegate writeLog:[NSString stringWithFormat:@"arrkeyNew: %@",arrkeyNew] key:POS_LOG];
    [delegate writeLog:[NSString stringWithFormat:@"arrayUpdate: %@",arrayUpdate] key:POS_LOG];
    

    NSString *token = [self createTokenWithUser:USER_NAME_CDN api:API_KEY_CDN];
    [delegate writeLog:[NSString stringWithFormat:@"token:%@",token] key:POS_LOG];
    
    
    for(int i=0;i<arrayUpdate.count;i++)
    {
        [delegate writeLog:[NSString stringWithFormat:@"key update[%d]: %@",i,[arrayUpdate objectAtIndex:i]] key:POS_LOG];
        int vt = [[arrayUpdate objectAtIndex:i] intValue];
        NSString *keydic = [arrkeyNew objectAtIndex:vt];
        [delegate writeLog:[NSString stringWithFormat:@"dic update: %@",[dicMacFWNew objectForKey:keydic]] key:POS_LOG];
        //load file
        NSString *fileName = [[dicMacFWNew objectForKey:keydic] objectForKey:@"file_restore"];
        NSString *fileChecksum = [[dicMacFWNew objectForKey:keydic] objectForKey:@"checksum"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          //Your main thread code goes in here
            self->testText.stringValue = [NSString stringWithFormat:@"%@ - %@",keydic,fileName];
        });
        
//thu nghiem
//fileName = @"Watch_2_Regular_6.3_17U208_Restore.ipsw";//dang thu
//fileChecksum = @"6015f998890ad1c7d6cd102bb2f886a5";
        int percent = 3+(int) i*100.0/arrayUpdate.count;
        if(percent > 100) percent = 100;
        [self percentUpdate:percent];
        
        [delegate writeLog:[NSString stringWithFormat:@"file update: %@",fileName] key:POS_LOG];
       
        //check da download file nay trong session hay chua, neu moi download thi khong download nua
        if([listFileDownloaded containsObject:fileName] == YES)
        {
            [delegate writeLog:[NSString stringWithFormat:@"file: %@ da duoc download roi",fileName] key:POS_LOG];
            NSMutableDictionary *dicCurrent = [dicMacFWNew objectForKey:keydic];
            [dicMacFWCurent setObject:dicCurrent forKey:keydic];
            //cap nhat lai database
            NSString *pathLib = [delegate pathLib];
            NSLog(@"%s save file idevice_support to pathLib:%@",__func__,pathLib);
            pathLib = [pathLib stringByAppendingString:@"/config/idevice_support.config"];
            [dicMacFWCurent writeToFile:pathLib atomically:YES];
            continue;
        }
        
        
        
        NSString *path = [NSString stringWithFormat: @"https://storage101.dfw1.clouddrive.com/v1/MossoCloudFS_6d2201cb-63f4-47a5-97f4-08c7ff9621ba/iOS/%@",fileName];
        
        [delegate writeLog:[NSString stringWithFormat:@"path load: %@",path] key:POS_LOG];
        
        // luu tru
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [paths objectAtIndex:0];
        NSString *downloadFolderPath = [NSString stringWithFormat: @"%@/EarseWatch/NewSoftware", documentPath];
        NSString *desk = [NSString stringWithFormat: @"%@/%@",downloadFolderPath,fileName];
        [delegate writeLog:[NSString stringWithFormat:@"download file save to: %@",desk] key:POS_LOG];
        
       // down load file
        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        ProccessUSB *libusb = delegate.mainViewController.libusb;
        NSString *cmd = [NSString stringWithFormat: @"curl -H \"X-Auth-Token: %@\" \"%@\" --output %@",token, path, desk];
        NSLog(@"run cmd %@",cmd);
        NSString *strReturn = [libusb runCommandNew:cmd];
        NSLog(@"run cmd strReturn: %@",strReturn);
        
    // tinh check sum new file
        cmd = [NSString stringWithFormat:@"md5 %@",desk];
        NSString *checksumNewFile = [libusb runCommandNew:cmd];
        NSLog(@"get md5: %@",checksumNewFile);
        [delegate writeLog:[NSString stringWithFormat:@"checksum newfile: %@, checksum oldfile:%@",checksumNewFile, fileChecksum] key:POS_LOG];
        
        [delegate writeLog:[NSString stringWithFormat:@"file download: %@",fileName] key:POS_LOG];
        if([[checksumNewFile lowercaseString] rangeOfString:fileChecksum].location == NSNotFound)
        {
            [delegate writeLog:[NSString stringWithFormat:@"khong giong voi check sum trog file=> download failed"] key:POS_LOG];
            [[NSFileManager defaultManager] removeItemAtPath:desk error:nil];
            continue;//tiep tuc load file khac
        }
    
        [delegate writeLog:[NSString stringWithFormat:@"check sum giong nhau => download thanh cong"] key:POS_LOG];
                
        //remove old file in IPSW,
        NSError *error = nil;
        NSMutableDictionary *dicCurrent = [dicMacFWCurent objectForKey:keydic];
        if(dicCurrent) //da co trongdb
        {
            //da co trong database => update lai db
            NSString *oldFileName = [NSString stringWithFormat: @"%@",[dicCurrent objectForKey:@"file_restore"]];
            NSString *oldFilePath = [NSString stringWithFormat: @"%@/EarseWatch/IPSW/%@", documentPath,oldFileName];
            
            //remove old file dang co trong db
            if([[NSFileManager defaultManager] fileExistsAtPath:oldFilePath]==YES)
            {
                [[NSFileManager defaultManager] removeItemAtPath:oldFilePath error:&error];
                if(error)
                {
                    [delegate writeLog:[NSString stringWithFormat:@"remove old file error: %@",[error description]] key:POS_LOG];
                    continue;//tiep tuc load file khac
                }
            }
 /*
//            //remove file trung voi new file
//            NSString *newFilePath = [NSString stringWithFormat: @"%@/EarseWatch/IPSW/%@", documentPath,fileName];
//            if([[NSFileManager defaultManager] fileExistsAtPath:newFilePath]==YES)
//            {
//                [[NSFileManager defaultManager] removeItemAtPath:newFilePath error:&error];
//                if(error)
//                {
//                    [delegate writeLog:[NSString stringWithFormat:@"remove file same name new file error: %@",[error description]] key:POS_LOG];
//                    continue;//tiep tuc load file khac
//                }
//            }
//
//            //copy file
//            [[NSFileManager defaultManager] copyItemAtPath:desk toPath:newFilePath error:&error];
//            if(error)
//            {
//                [delegate writeLog:[NSString stringWithFormat:@"copyItemAtPath: %@ -to: %@, error:%@",desk,newFilePath,[error description]] key:POS_LOG];
//                continue;//tiep tuc load file khac
//            }
//            else
//            {
//                [[NSFileManager defaultManager] removeItemAtPath:desk error:&error];
//            }
//            //update lai db
//            [dicCurrent setObject:fileName forKey:@"file_restore"];
//            [dicMacFWCurent setObject:dicCurrent forKey:keydic];
  */
        }
        else // chua co trong db
        {
            //chua co trong database lay tu new add vao current
            NSMutableDictionary *dicCurrent = [dicMacFWNew objectForKey:keydic];
            [dicMacFWCurent setObject:dicCurrent forKey:keydic];
            
        }
        
        
        //remove file trung voi new file
        NSString *newFilePath = [NSString stringWithFormat: @"%@/EarseWatch/IPSW/%@", documentPath,fileName];
        if([[NSFileManager defaultManager] fileExistsAtPath:newFilePath]==YES)
        {
            [[NSFileManager defaultManager] removeItemAtPath:newFilePath error:&error];
            if(error)
            {
                [delegate writeLog:[NSString stringWithFormat:@"remiove old file error: %@",[error description]] key:POS_LOG];
                continue;//tiep tuc load file khac
            }
        }
        
        //copy pathtem to IPSW
        [[NSFileManager defaultManager] copyItemAtPath:desk toPath:newFilePath error:&error];
        if(error)
        {
            [delegate writeLog:[NSString stringWithFormat:@"copyItemAtPath: %@ -to: %@, error:%@",desk,newFilePath,[error description]] key:POS_LOG];
            continue;//tiep tuc load file khac
        }
        else
        {
            [[NSFileManager defaultManager] removeItemAtPath:desk error:&error];
        }
        
        //update lai db
        [dicCurrent setObject:fileName forKey:@"file_restore"];
        [dicMacFWCurent setObject:dicCurrent forKey:keydic];
        
        
        [listFileDownloaded addObject:fileName];//Luu lai file vua download
     
        //save database
        NSString *pathLib = [delegate pathLib];
        NSLog(@"%s save file idevice_support to pathLib:%@",__func__,pathLib);
        pathLib = [pathLib stringByAppendingString:@"/config/idevice_support.config"];
        [dicMacFWCurent writeToFile:pathLib atomically:YES];
        NSLog(@"xem log");
    
         
    }//end for
    NSLog(@"%s end for",__func__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self percentUpdate:100];
    });
   
}
- (void)btUpdateClick:(id)sender
{
    NSLog(@"%s",__func__);
    NSButton *bt = (NSButton *)sender;
    bt.enabled = NO;
    if(arrayUpdate==nil) arrayUpdate = [[NSMutableArray alloc] init];
    else [arrayUpdate removeAllObjects];
    
    for(int i=0;i<numRowNew;i++)
    {
        NSButton *bt = (NSButton *)[self.view viewWithTag:900+i];
        if(bt.enabled && bt.state == YES)
        {
            [arrayUpdate addObject:[NSNumber numberWithInt:i]];//900+i
        }
    }
    //hien o day
    proccessbarRun.hidden = NO;
    proccessbarText.hidden = NO;
    lbUpdating.hidden = NO;
    ProccessbarBG.hidden = NO;
    
    if(listFileDownloaded)
        [listFileDownloaded removeAllObjects];
    threadUpdate = [[NSThread alloc] initWithTarget:self selector:@selector(runUpdate) object:nil];
    [threadUpdate start];
}
- (void)btCloseClick:(id)sender
{
    if(threadUpdate)
    {
        [threadUpdate cancel];
        threadUpdate = nil;
    }
    [self.view.window close];
}
- (NSWindow *)showWindow
{
    NSWindow *window = [NSWindow windowWithContentViewController:self];
    [window center];
    [window setBackgroundColor:[NSColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1.0]];
    [window setContentSize:NSSizeFromCGSize(CGSizeMake(self.view.frame.size.width, self.view.frame.size.height))];
    window.title = @"iCombine Watch";
    window.contentViewController = self;
    //[window setLevel:NSNormalWindowLevel];
    [window makeKeyAndOrderFront:nil];
    [window setLevel:NSStatusWindowLevel];
    [window setStyleMask:NSBorderlessWindowMask];
    NSWindowController *windowControllerIF = [[NSWindowController alloc] initWithWindow:window];
    [windowControllerIF.window makeKeyAndOrderFront:self];
    [windowControllerIF showWindow:self];
    return window;
}
@end
