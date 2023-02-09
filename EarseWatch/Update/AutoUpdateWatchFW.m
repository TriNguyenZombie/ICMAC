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
#import "AFNetworking.h"

@interface AutoUpdateWatchFW ()

@end

@implementation AutoUpdateWatchFW
- (instancetype)init
{
    colorBanner = [NSColor colorWithRed:0x30*1.0/0xff green:0x30*1.0/0xff blue:0x30*1.0/0xff alpha:1.0];
    NSRect frame = NSMakeRect(0, 0, 800, 600);
    self = [super init];
    self.view = [[NSView alloc] init];
    self.view.frame = frame;
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = NSColor.whiteColor.CGColor;
    self.view.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    
    //==============================Title top=================================
    titleWindow = [[NSTextField alloc] initWithFrame:NSMakeRect(0, frame.size.height - 50, frame.size.width, 50)];
    titleWindow.cell = [[NSTextFieldCell alloc] init];
    titleWindow.stringValue = @"  Automatic macOS update";
    titleWindow.alignment = NSTextAlignmentLeft;
    titleWindow.font = [NSFont fontWithName:@"Roboto-Regular" size:28];
    titleWindow.textColor = [NSColor whiteColor];
    titleWindow.wantsLayer = YES;
    [titleWindow setBordered:NO];
    titleWindow.backgroundColor = colorBanner;
    titleWindow.layer.backgroundColor = colorBanner.CGColor;
    [self.view addSubview:titleWindow];
    
    NSButton *btCloseTop = [[NSButton alloc] initWithFrame:NSMakeRect(frame.size.width - 48,frame.size.height - 48, 46, 46)];
    btCloseTop.title = @"";
    btCloseTop.image = [NSImage imageNamed:@"CloseWhite.png"];
    [[btCloseTop cell] setBackgroundColor:colorBanner];
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
    
    timerUpdateUI = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                     target: self
                                                   selector:@selector(checkNewVersion)
                                                   userInfo: nil repeats:YES];
    
//    timerUpdateUI = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(updateState:) userInfo:nil repeats:YES];
    
    NSThread *threadGetTokenAndDownloadFileChecksum = [[NSThread alloc] initWithTarget:self selector:@selector(getTokenAndDownloadChecksumFile) object:nil];
    [threadGetTokenAndDownloadFileChecksum start];
    
    return self;
}

- (void)getTokenAndDownloadChecksumFile
{
    NSLog(@"[getTokenAndDownloadChecksumFile] ------------------- get token id then download file config from CDN ---------------");
    NSString *token = [self createTokenWithUser: @USER_NAME_CDN api: @API_KEY_CDN];
    self->tokenID = token;
    NSLog(@"[getTokenAndDownloadChecksumFile] token id: %@", self->tokenID);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathFileConfig = [NSString stringWithFormat: @"%@/EarseMac/NewSoftware/ipsw_info.config", documentsDirectory];
    
    NSLog(@"[getTokenAndDownloadChecksumFile] Path ipsw_info.config: %@", pathFileConfig);
    
    NSString *command = [NSString stringWithFormat: @"curl -H \"X-Auth-Token: %@\" https://storage101.dfw1.clouddrive.com/v1/MossoCloudFS_6d2201cb-63f4-47a5-97f4-08c7ff9621ba/Macbook_Erasure/IPSW/ipsw_info.config --output %@", self->tokenID, pathFileConfig];
    [self runCommand: command];
    
    self->dicSupportChecksum = [[NSMutableDictionary alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath: pathFileConfig] == false){
        NSLog(@"[getTokenAndDownloadChecksumFile] File ipsw_info.config is not exist");
        self->dicSupportChecksum = nil;
    }
    else
    {
        NSLog(@"[getTokenAndDownloadChecksumFile] File ipsw_info.config is exist");
        NSString* content = [NSString stringWithContentsOfFile: pathFileConfig encoding:NSUTF8StringEncoding error:NULL];
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        self->dicSupportChecksum = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"[getTokenAndDownloadChecksumFile] json data: %@", self->dicSupportChecksum);
    }
}

- (void)drawCurrentVersion:(NSRect) rectFrame
{
    NSLog(@"[drawCurrentVersion] --------------- draw UI current version ---------------");
    NSRect frame =  self.view.frame;
    int num_row = 24, row_height = 40;
    NSRect rectCurrent = NSMakeRect(0, 0, frame.size.width/2-30, num_row * row_height);
    NSView *viewCurrentVersion = [[NSView alloc] initWithFrame: rectCurrent];
    viewCurrentVersion.layer.borderColor = NSColor.redColor.CGColor;
    viewCurrentVersion.layer.borderWidth = 5;
    NSTextField *lbName, *lbVersion;
    NSString *key;
    NSMutableDictionary *dicItem;
    [self readFileChecksum];
    if(self->dicSupport != nil)
    {
        NSArray *arr = [dicSupport allKeys];
        NSLog(@"[drawCurrentVersion] array: %@", arr);
        num_row = (unsigned int) arr.count;
        for(int i = 0 ; i < num_row; i++)
        {
            key = [arr objectAtIndex:i];
            dicItem = [dicSupport objectForKey:key];
            NSLog(@"[drawCurrentVersion] dicItem: %@", dicItem);
            lbName = [[NSTextField alloc] initWithFrame:NSMakeRect(10, rectCurrent.size.height - (i + 1) * row_height + 10, rectCurrent.size.width - 60, 20)];
            lbName.cell = [[NSTextFieldCell alloc] init];
            lbName.stringValue = [NSString stringWithFormat:@"%@", dicItem[@"name"]];
            lbName.alignment = NSTextAlignmentLeft;
            lbName.textColor = [NSColor blackColor];
            lbName.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
            lbName.wantsLayer = YES;
            [lbName setBordered:NO];
            [viewCurrentVersion addSubview:lbName];

            lbVersion = [[NSTextField alloc] initWithFrame:NSMakeRect(rectCurrent.size.width - 60, rectCurrent.size.height - (i + 1) * row_height + 10, 60, 20)];
            lbVersion.cell = [[NSTextFieldCell alloc] init];
            lbVersion.stringValue = dicItem[@"version_ipsw"];
            lbVersion.alignment = NSTextAlignmentLeft;
            lbVersion.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
            lbVersion.textColor = [NSColor blackColor];
            lbVersion.wantsLayer = YES;
            [lbVersion setBordered:NO];
            [viewCurrentVersion addSubview:lbVersion];
        }
    }
    
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

    lbName = [[NSTextField alloc] initWithFrame:NSMakeRect(30, rectFrame.origin.y + rectFrame.size.height - 10, 140, 30)];
    lbName.cell = [[NSTextFieldCell alloc] init];
    lbName.stringValue = @" Current version";
    lbName.alignment = NSTextAlignmentLeft;
    lbName.textColor = [NSColor colorWithSRGBRed:208.0/255 green:186.0/255 blue:138.0/255 alpha:1.0];
    lbName.backgroundColor = [NSColor whiteColor];
    lbName.wantsLayer = YES;
    lbName.drawsBackground = YES;
    [lbName setBordered:NO];
    lbName.font = [NSFont fontWithName:@"Roboto-Regular" size:18];
    [self.view addSubview:lbName];
}

- (void)drawNewVersion:(NSRect) rectFrame
{
    NSLog(@"[drawCurrentVersion] --------------- draw UI new version ---------------");
    cbtem = [self.view viewWithTag: 900];
    NSRect frame =  self.view.frame;
    int numrow = 24, rowHeigh = 40;
    NSRect rectCurrent = NSMakeRect(0, 0, frame.size.width/2-30,numrow*rowHeigh);
    viewNewVersion = [[NSView alloc] initWithFrame:rectCurrent];
    
    btUpdate = (NSButton *)[self.view viewWithTag:110];
    if(btUpdate)
        btUpdate.enabled = enableButtonUpdate;
    scrollContainer = [[NSScrollView alloc] initWithFrame:rectFrame];
    scrollContainer.layer.borderColor = [NSColor clearColor].CGColor;
    [scrollContainer setWantsLayer:YES];
    scrollContainer.layer.borderWidth = 2.0;
    scrollContainer.borderType = NSLineBorder;
    [scrollContainer setDocumentView:viewNewVersion];
    [scrollContainer setHasVerticalScroller:NO];
    scrollContainer.backgroundColor = [NSColor whiteColor];
    [self.view addSubview:scrollContainer];
    [scrollContainer.contentView scrollToPoint:NSMakePoint(0, rectCurrent.size.height-20)];

    if ([scrollContainer hasVerticalScroller]) {
        scrollContainer.verticalScroller.floatValue = 0;
        }

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

- (void)readFileChecksum
{
    NSLog(@"[readFileChecksum] --------------- read file checksum ---------------");
    self->dicSupport = [[NSMutableDictionary alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathChecksum = [NSString stringWithFormat: @"%@/EarseMac/Lib/config/ipsw_info.config", documentsDirectory];
    
    if ([fileManager fileExistsAtPath: pathChecksum] == false)
    {
        NSLog(@"[readFileChecksum] File ipsw_info.config is not exist");
        self->dicSupport = nil;
    }
    else
    {
        NSLog(@"[readFileChecksum] File ipsw_info.config is exist");
        NSString* content = [NSString stringWithContentsOfFile: pathChecksum encoding:NSUTF8StringEncoding error:NULL];
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        self->dicSupport = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"[readFileChecksum] json data: %@", self->dicSupport);
    }
}

- (void)updateState
{
//    bool state = cbSelectAll.state;
//    for(int i = 0; i < numRowNew; i++)
//    {
//        NSButton *bt = (NSButton *)[self.view viewWithTag:900+i];
//        if(bt.enabled)
//        {
//            bt.state = state;
//            if(bt.state == YES)
//            {
//                bt.enabled = YES;
//            }
//        }
//    }
}

- (void)cbItemClick:(id)sender
{
    NSLog(@"[cbItemClick] ------------------ combobox item click ------------------");
    NSButton *bt = (NSButton *)sender;
    NSLog(@"%s [[cbItemClick] button state: %d",__func__,(int)bt.state);
    BOOL flag = NO;
    for(int i = 0; i < numRowNew; i++)
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

- (void)checkNewVersion
{
    NSLog(@"[checkNewVersion] ------------------- Checking new version ------------------");
    NSArray *arr = [self->dicSupportChecksum allKeys];
    numRowNew = 24;
    int numrow = 24, rowHeigh = 40;

    NSRect rectCurrent = NSMakeRect(0, 0, self.view.frame.size.width/2-30, numrow*rowHeigh);
    
    for(int i = 0; i < arr.count; i++)
    {
        key = [arr objectAtIndex:i];
        
        NSLog(@"[checkNewVersion] key: %@", key);
        dicItemNewVersion = [self->dicSupportChecksum objectForKey:key];
        NSLog(@"[checkNewVersion] dicItemNewVersion: %@", dicItemNewVersion);
        
        NSButton *cbSelect = [[NSButton alloc] initWithFrame:NSMakeRect(10, rectCurrent.size.height - (i+1)*rowHeigh+10, rectCurrent.size.width-50, 20)];
        
        [cbSelect setButtonType:NSSwitchButton];
        NSString *tmp = dicItemNewVersion[@"name"];
        
        if([tmp rangeOfString:key].location == NSNotFound)
            [cbSelect setTitle:[NSString stringWithFormat:@"%@ (%@)", dicItemNewVersion[@"name"],key]];
        else [cbSelect setTitle:[NSString stringWithFormat:@"%@", dicItemNewVersion[@"name"]]];
        cbSelect.font = [NSFont fontWithName:@"Roboto-Medium" size:15];
        [cbSelect setBezelStyle:0];
        cbSelect.tag = 900+i;
//        cbSelect.state = YES;
        [cbSelect setWantsLayer:YES];
        cbSelect.layer.backgroundColor = [NSColor whiteColor].CGColor;
        [cbSelect setTarget:self];
        [cbSelect setAction:@selector(cbItemClick:)];
        [viewNewVersion addSubview:cbSelect];
        
        lbNewVersion = [[NSTextField alloc] initWithFrame:NSMakeRect(rectCurrent.size.width-60, rectCurrent.size.height - (i+1)*rowHeigh+10, 60, 20)];
        lbNewVersion.cell = [[NSTextFieldCell alloc] init];
        lbNewVersion.stringValue = dicItemNewVersion[@"version_ipsw"];
        lbNewVersion.alignment = NSTextAlignmentLeft;
        lbNewVersion.textColor = [NSColor blackColor];
        lbNewVersion.font = [NSFont fontWithName:@"Roboto-Medium" size:14];
        lbNewVersion.wantsLayer = YES;
        [lbNewVersion setBordered:NO];
        [viewNewVersion addSubview:lbNewVersion];
        
        if(dicItemNewVersion[@"version_ipsw"] != dicItem[@"version_ipsw"] && dicItemNewVersion[@"version_ipsw"] != nil)
        {
            NSLog(@"Compare version");
            cbSelect.enabled = YES;
            enableButtonUpdate = YES;
            btUpdate.enabled = enableButtonUpdate;
            [self->timerUpdateUI invalidate];
        }
    }
}

- (NSString *)runCommand:(NSString *)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"[runCommand - Update firmware] Command string: \n%@\n", commandToRun);
    [task setArguments:arguments];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    NSData *data = [file readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}

- (NSString *)createTokenWithUser:(NSString *)username api:(NSString*)apikey
{
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSString *commandGetToken = @"curl -X POST https://identity.api.rackspacecloud.com/v2.0/tokens -H 'Content-Type: application/json' -d '{\"auth\":{\"RAX-KSKEY:apiKeyCredentials\":{\"username\":\"greycdn.user\",\"apiKey\":\"608720ab85c3498c82f5fda650f9a079\"}}}'";
    NSString *result = [self runCommand: commandGetToken];
    NSDictionary *dic  = [delegate diccionaryFromJsonString:result];
    NSString *strToken = [NSString stringWithFormat:@"%@",[[[dic objectForKey:@"access"] objectForKey:@"token"] objectForKey:@"id"]];
    return strToken;
}

- (void)cbSelectAllClick:(id)sender
{
    NSButton *cbSelectAll = (NSButton *)sender;
    bool state = cbSelectAll.state;
    NSButton *btUpdate = (NSButton *)[self.view viewWithTag:110];
    for(int i = 0; i < numRowNew; i++)
    {
        NSButton *bt = (NSButton *)[self.view viewWithTag:900+i];
        
        if(bt.enabled)
        {
            bt.state = state;
            if(bt.state == YES)
            {
                btUpdate.enabled = YES;
            }
        }
    }
    
    if(state == NO)
    {
        btUpdate.enabled = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)percentUpdate:(int)percent
{
    NSLog(@"%s percent:%d",__func__,percent);

    dispatch_async(dispatch_get_main_queue(), ^{
        NSRect rect = self->proccessbarRun.frame;
        int valueWidth = (int)(percent*self->proccessWidthMax*1.0/100);
        self->proccessbarRun.frame = NSMakeRect(rect.origin.x, rect.origin.y, valueWidth, rect.size.height);
        self->proccessbarText.stringValue = [NSString stringWithFormat:@"%d %%",percent];
    });
}

-(void) runUpdate
{
    NSLog(@"[runUpdate] -------------------- start update macOS firmware -------------------");
}
    
- (void) btUpdateClick:(id)sender
{
    NSLog(@"[btUpdateClick] ------------ clicked ------------");
    NSButton *bt = (NSButton *)sender;
    bt.enabled = NO;
    if(arrayUpdate == nil) arrayUpdate = [[NSMutableArray alloc] init];
    else [arrayUpdate removeAllObjects];

    for(int i = 0 ; i < numRowNew; i++)
    {
        NSButton *bt = (NSButton *)[self.view viewWithTag:900+i];
//        bt.enabled = NO;
        
        if(bt.enabled && bt.state == YES)
        {
            NSLog(@"button select: %@", bt.title);
            [arrayUpdate addObject:[NSNumber numberWithInt:i]];//900+i
            
            if([bt.title containsString:@"apple_model"] || [bt.title containsString:@"intel_model"])
            {
                if([bt.title containsString:@"apple_model"])
                {
                    
                }
            }
            
            NSLog(@"arrayUpdate: %@", arrayUpdate);
        }
    }
    //hien o day
    proccessbarRun.hidden = NO;
    proccessbarText.hidden = NO;
    lbUpdating.hidden = NO;
    ProccessbarBG.hidden = NO;
    
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
    [timerUpdateUI invalidate];
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
    [window makeKeyAndOrderFront:nil];
    [window setLevel:NSStatusWindowLevel];
    [window setStyleMask:NSBorderlessWindowMask];
    NSWindowController *windowControllerIF = [[NSWindowController alloc] initWithWindow:window];
    [windowControllerIF.window makeKeyAndOrderFront:self];
    [windowControllerIF showWindow:self];
    return window;
}
@end
