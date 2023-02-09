//
//  CellTableClass.m
//  EarseMac
//
//  Created by Greystone on 12/21/21.
//  Copyright © 2021 Greystone. All rights reserved.
//

#import "CellTableClass.h"
#import "AppDelegate.h"
#import "UITextFieldCell.h"
#import "UIButton.h"

@implementation CellTableClass
@synthesize tvInfoDevice;// thong tin
@synthesize imgStatus;// nguoi chay
@synthesize imgResult;// passed, failed
@synthesize btStop;
@synthesize btInfo;
@synthesize btRescan;
@synthesize checkBox;
@synthesize cbTitle;// chackbox A1....
@synthesize txtHeaderTime;
@synthesize dicInfoCell;
@synthesize selected;// check box value
@synthesize current_state;
@synthesize counttime;

@synthesize viewContentOfCell;

- (id)initWithFrame:(NSRect)frame info:(NSMutableDictionary *)dic
{
    dicInfoCell = dic;//[dic mutableCopy];
    return [self initWithFrame:frame];
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setDelegate:(id)Class method:(SEL) sel
{
    root=Class;
    selector = sel;
    timerRun = nil;
    current_state = -1;// khong xac dinh
}
- (void)buttonClick:(id)sender
{
    if(root && [root respondsToSelector:selector])
    {
        [dicInfoCell setObject:sender forKey:@"button"];
        [root performSelector:selector withObject:dicInfoCell];
    }
}
- (void)checkBoxClick:(id)sender
{
    
    NSButton *bt = (NSButton*)sender;
    if(selected == YES)
    {
        bt.state = 0;
        selected = NO;
        bt.image = [NSImage imageNamed:@"CellUncheck.png"];
        [dicInfoCell setObject:[NSNumber numberWithInt:0] forKey: @"CheckboxValue"];
    }
    else
    {
        bt.state = 1;
        selected = YES;
        bt.image = [NSImage imageNamed:@"CellChecked.png"];
        [dicInfoCell setObject:[NSNumber numberWithInt:1] forKey: @"CheckboxValue"];
    }
    [self buttonClick:sender];
}


- (void)updateState:(int)state
{
    bool debugMode = false;
    if([dicInfoCell objectForKey:@"status"]!=nil)
    {
        state = [[dicInfoCell objectForKey:@"status"] intValue];
    }
    if(current_state == state) return;// chi khi doi trang thay moi update
    current_state = state;
    if(state==(int)CellNoDevice)
    {
        self.txtHeaderTime.stringValue = @" ";
        self.txtHeaderTime.hidden = NO;
        self.imgStatus.image = [NSImage imageNamed:@"Idle"];//nguoi dung im
        [self.btStop setEnabled:NO];


        NSData *data = [@"" dataUsingEncoding:NSUTF8StringEncoding];
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithHTML:data baseURL:nil documentAttributes:nil];
        [[tvInfoDevice textStorage] setAttributedString:attributedString];
        // [self.btStop.cell setBackgroundColor:[NSColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0]];
        [self.btRescan setEnabled:NO];
        // DEBUG July 27
        if (debugMode) {
            [self.btRescan setEnabled:YES];
            [self.btStop setEnabled:YES];
        }

       // [self.btRescan.cell setBackgroundColor:[NSColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0]];
        self.imgResult.hidden = YES;
    }
    else if(state==(int)CellHaveDevice)
    {
        self.txtHeaderTime.stringValue = @"00:00:00";
        self.txtHeaderTime.hidden = NO;
        self.imgStatus.image = [NSImage imageNamed:@"running"];//chay
        [self.btStop setEnabled:NO];
      //  [self.btStop.cell setBackgroundColor:[NSColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0]];
        [self.btRescan setEnabled:NO];
      //  [self.btRescan.cell setBackgroundColor:[NSColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0]];
        self.imgResult.hidden = YES;
        counttime = 0;
    }
    else if(state==(int)CellReady)
    {
        self.txtHeaderTime.stringValue = @"00:00:00";
        self.txtHeaderTime.hidden = NO;
        self.imgStatus.image = [NSImage imageNamed:@"Ready"];//dong ho
        self.imgStatus.image = [NSImage imageNamed:@"mac_small_normal"];
        [self.btStop setEnabled:NO];
        [self.btRescan setEnabled:NO];
        self.imgResult.hidden = YES;
        counttime = 0;
        if (debugMode) {
            [self.btRescan setEnabled:YES];
            [self.btStop setEnabled:YES];
        }
    }
    else if(state==(int)CellRunning)
    {
        if([dicInfoCell objectForKey:@"TimeProccess"])
            counttime = [[dicInfoCell objectForKey:@"TimeProccess"] intValue];
        if(timerRun==nil)
        timerRun = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countTime:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timerRun forMode:NSRunLoopCommonModes];
        self.imgStatus.image = [NSImage imageNamed:@"running"];//chay
        [self.btStop setEnabled:YES];
        //[self.btStop.cell setBackgroundColor:[NSColor whiteColor]];
        [self.btRescan setEnabled:NO];
        //[self.btRescan.cell setBackgroundColor:[NSColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0]];
        self.imgResult.hidden = YES;
    }
    else if(state==(int)CellChecking)
    {
        if([dicInfoCell objectForKey:@"TimeProccess"])
            counttime = [[dicInfoCell objectForKey:@"TimeProccess"] intValue];
        if(timerRun==nil)
        timerRun = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countTime:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timerRun forMode:NSRunLoopCommonModes];
        self.imgStatus.image = [NSImage imageNamed:@"running"];//chay
        [self.btStop setEnabled:NO];
       // [self.btStop.cell setBackgroundColor:[NSColor whiteColor]];
        [self.btRescan setEnabled:NO];
        //[self.btRescan.cell setBackgroundColor:[NSColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0]];
        self.imgResult.hidden = YES;
    }
    else if(state==(int)CellFinished)
    {
        if(timerRun)
        {
            [timerRun invalidate];
            timerRun = nil;
        }
      
        self.imgStatus.image = [NSImage imageNamed:@"Finished"];//dong ho check
        self.imgStatus.image = [NSImage imageNamed:@"mac_small_finished"];//dong ho check
        [self.btStop setEnabled:NO];
        //[self.btStop.cell setBackgroundColor:[NSColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0]];
        [self.btRescan setEnabled:YES];
        //[self.btRescan.cell setBackgroundColor:[NSColor whiteColor]];
        
        self.imgResult.hidden = NO;
        if ([dicInfoCell objectForKey:@"TimeProccess"])
            counttime = [[dicInfoCell objectForKey:@"TimeProccess"] intValue];
    
        int hh = (int)(counttime/3600);
        int mm = counttime%3600;
        int ss = mm%60;
        mm = mm/60;
        NSString *elapsedTime = [NSString stringWithFormat:@"%02d:%02d:%02d",hh,mm,ss];
        [dicInfoCell setObject:elapsedTime forKey:@"elapsedTime"];
        
        NSLog(@"finish counttime:%ld",counttime);
        [self showTime:counttime];
    }
    else
    {
        if(timerRun)
        {
            [timerRun invalidate];
            timerRun = nil;
        }
        self.txtHeaderTime.stringValue = @"00:00:00";
        self.txtHeaderTime.hidden = NO;
        [self.btStop setEnabled:NO];
        //[self.btStop.cell setBackgroundColor:[NSColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0]];
        [self.btRescan setEnabled:NO];
        //[self.btRescan.cell setBackgroundColor:[NSColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0]];
        self.imgResult.hidden = YES;
    }
}
- (void)countTime:(id)sender
{
    if([dicInfoCell objectForKey:@"status"]!=nil)
    {
        current_state = [[dicInfoCell objectForKey:@"status"] intValue];
    }
    
    if(current_state==CellRunning || current_state==CellChecking)
    {
        counttime++;
        [dicInfoCell setObject: [NSNumber numberWithLong:counttime] forKey:@"TimeProccess"];
        SEL selector = NSSelectorFromString(@"updateCellData:");
        if(root && [root respondsToSelector:selector])
            [root performSelector:selector withObject:dicInfoCell];
        [self showTime:counttime];
        
        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        int timeoutsave = [[delegate.dicInfoSettingSave objectForKey:@"timeout"] intValue];
        timeoutsave *=60;
        if(counttime > timeoutsave && timeoutsave > 0)
        {
            if([dicInfoCell objectForKey:@"status"]!=nil)
            {
                [dicInfoCell setObject:[NSNumber numberWithInt:CellFinished] forKey:@"status"];
                self.imgResult.image = [NSImage imageNamed:@"failed_with_text"];
                [dicInfoCell setObject:@"Timeout" forKey:@"conten"];
                [self updateState:CellFinished];
            }
        }
    }
    else
    {
        if(timerRun)
        {
            NSLog(@"%s counttime stop",__func__);
            [timerRun invalidate];
            timerRun = nil;
        }
    }
    
}
- (void)showTime:(unsigned long)val
{
    int hh = (int)(val/3600);
    int mm = val%3600;
    int ss = mm%60;
    mm = mm/60;
    self.txtHeaderTime.stringValue = [NSString stringWithFormat:@"%02d:%02d:%02d",hh,mm,ss];
    self.txtHeaderTime.hidden = NO;
}


- (id)initWithFrame:(NSRect)frame
{
    //   NSLog(@"%s",__FUNCTION__);
    self = [super initWithFrame:frame];
    if(self)
    {
        NSRect rect = frame;
        self.frame = frame;
        self.wantsLayer = YES;
        self.layer.borderWidth = 2;
        self.layer.borderColor = [NSColor colorWithRed:194.0/255 green:194.0/255 blue:194.0/255 alpha:1.0].CGColor;
        heighHeaderItem = 32;
        if([dicInfoCell objectForKey:@"num_board"])
        {
            num_board = [[dicInfoCell objectForKey:@"num_board"] intValue];
            if(num_board<3)
                heighHeaderItem = 50;
        }
        NSView *viewcell = [[NSView alloc] initWithFrame:frame];
        NSView *viewTop = [[NSView alloc] initWithFrame:NSMakeRect(0, rect.size.height - heighHeaderItem, rect.size.width, heighHeaderItem)];
        viewTop.wantsLayer = YES;
        viewTop.layer.backgroundColor = [NSColor blueColor].CGColor;
        [viewcell addSubview:viewTop];
        

        
        
        NSString *checkPosion = @"";
        if(dicInfoCell && [dicInfoCell objectForKey:@"title"])
            checkPosion = [NSString stringWithFormat:@"%@",[dicInfoCell objectForKey:@"title"]];
        NSLog(@"title:%@",checkPosion);
        if(checkPosion.length > 0)
        {
            if([checkPosion rangeOfString:@"A"].location!=NSNotFound)
            {
                viewTop.layer.backgroundColor = [NSColor colorWithRed:0x43*1.0/255 green:0xA0*1.0/255 blue:0x47*1.0/255 alpha:1.0].CGColor;
            }
            else if([checkPosion rangeOfString:@"B"].location!=NSNotFound)
            {
                viewTop.layer.backgroundColor = [NSColor colorWithRed:0xC5*1.0/255 green:0x85*1.0/255 blue:0x41*1.0/255 alpha:1.0].CGColor;
            }
            else if([checkPosion rangeOfString:@"C"].location!=NSNotFound)
            {
                viewTop.layer.backgroundColor = [NSColor colorWithRed:0x35*1.0/255 green:0xC5*1.0/255 blue:0xCA*1.0/255 alpha:1.0].CGColor;
            }
            else if([checkPosion rangeOfString:@"D"].location!=NSNotFound)
            {
                viewTop.layer.backgroundColor = [NSColor colorWithRed:0x22*1.0/255 green:0x68*1.0/255 blue:0xB0*1.0/255 alpha:1.0].CGColor;
            }
            else
            {
                viewTop.layer.backgroundColor = [NSColor systemBrownColor].CGColor;
            }
        }
        else
        {
            viewTop.layer.backgroundColor = [NSColor colorWithRed:1.0 green:1.0 blue:0 alpha:1.0].CGColor;
        }
        
        

        txtHeaderTime = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 5, rect.size.width, heighHeaderItem-3)];
        txtHeaderTime.stringValue = @"00:00:00";
        txtHeaderTime.cell = [[UITextFieldCell alloc] init];
        txtHeaderTime.alignment = NSTextAlignmentCenter;
        txtHeaderTime.font = [NSFont fontWithName:@"Roboto-Regular" size:22];
        txtHeaderTime.backgroundColor = [NSColor clearColor];
        txtHeaderTime.layer.backgroundColor = [NSColor clearColor].CGColor;
        txtHeaderTime.bordered = NO;
        txtHeaderTime.textColor = [NSColor whiteColor];
        [viewTop addSubview:txtHeaderTime];
        self.txtHeaderTime.hidden = YES;
       
        
        NSButton *btInfo = [[NSButton alloc] initWithFrame:NSMakeRect(rect.size.width - heighHeaderItem-4,3, heighHeaderItem -4, heighHeaderItem - 8)];
        btInfo.image = [NSImage imageNamed:@"Info_normal.png"];
        btInfo.imageScaling = NSImageScaleProportionallyUpOrDown;
        btInfo.title = @"";
        btInfo.tag = BT_INFO;
        [btInfo setToolTip:@"Device info"];
        btInfo.bordered = NO;
        [btInfo setTarget:self];
        [btInfo setAction:@selector(buttonClick:)];
        [viewTop addSubview:btInfo];
        self.btInfo = btInfo;
        
        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        selected = [[dicInfoCell objectForKey:@"CheckboxValue"] boolValue];
        if(num_board<3)
            checkBox = [[NSButton alloc] initWithFrame:NSMakeRect(10,14,60 , heighHeaderItem-28 )];
        else checkBox = [[NSButton alloc] initWithFrame:NSMakeRect(5,5,60 , heighHeaderItem-10 )];
        if([[dicInfoCell objectForKey:@"CheckboxValue"] intValue]==1)
            checkBox.image = [NSImage imageNamed:@"CellChecked.png"];
        else checkBox.image = [NSImage imageNamed:@"CellUncheck.png"];
        checkBox.imagePosition = NSImageLeft;
        checkBox.imageScaling = NSImageScaleProportionallyUpOrDown;
        [checkBox setTitle:checkPosion];
        NSMutableAttributedString *atribute = [delegate setColorTitleFor:checkBox color:[NSColor whiteColor] Font:[NSFont systemFontOfSize:20]];
        [checkBox setAttributedTitle:atribute];
        [checkBox setState:[[dicInfoCell objectForKey:@"CheckboxValue"] intValue]];
        checkBox.wantsLayer = YES;
        checkBox.tag = BT_CHECK;
        checkBox.layer.borderWidth = 0.0;
        checkBox.layer.borderColor = [NSColor clearColor].CGColor;
        checkBox.layer.backgroundColor = [NSColor clearColor].CGColor;
        checkBox.bordered = NO;
        checkBox.font = [NSFont fontWithName:@"Roboto-Medium" size:24];;
        [checkBox setAction:@selector(checkBoxClick:)];
        [checkBox setTarget:self];
        [viewTop addSubview:checkBox];
        
        imgStatus = [[NSImageView alloc] initWithFrame:NSMakeRect(60,3, heighHeaderItem-8, heighHeaderItem-8 )];
        imgStatus.image = [NSImage imageNamed:@"Idle"];
        [viewTop addSubview:imgStatus];
        
        //===============================================conten
        viewContentOfCell = [[NSView alloc] initWithFrame:NSMakeRect(0, heighHeaderItem, rect.size.width, rect.size.height - heighHeaderItem*2)];
        viewContentOfCell.wantsLayer = YES;
        viewContentOfCell.layer.backgroundColor = [NSColor whiteColor].CGColor;
        [viewcell addSubview:viewContentOfCell];//create color background chua dung toi vew nay
        
        tvInfoDevice = [[NSTextView alloc] initWithFrame:NSMakeRect(10, heighHeaderItem+1, rect.size.width-20, rect.size.height - heighHeaderItem*2-2)];
        [tvInfoDevice setTextColor:[NSColor blackColor]];
        tvInfoDevice.backgroundColor = [NSColor whiteColor];
        tvInfoDevice.drawsBackground = YES;
        tvInfoDevice.font = [NSFont fontWithName:@"Roboto-Regular" size:16];

        [tvInfoDevice setEditable:NO];
        tvInfoDevice.layer.borderWidth = 2;
        [viewcell addSubview:tvInfoDevice];
        
        imgResult = [[NSImageView alloc] initWithFrame:NSMakeRect(rect.size.width/2 - 50, rect.size.height/2 - 50 - 50 - 50, 100, 100)];
        imgResult.hidden = YES;
        [viewcell addSubview:imgResult];
        
        //===============================================bottom
        
        NSView *viewBottom = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, rect.size.width, heighHeaderItem)];
        viewBottom.wantsLayer = YES;
        viewBottom.layer.backgroundColor = [NSColor colorWithRed:248.0/255 green:248.0/255 blue:248.0/255 alpha:1.0].CGColor;
        [viewcell addSubview:viewBottom];

        
        UIButton *btStop = [[UIButton alloc] initWithFrame:NSMakeRect(rect.size.width/4 - 50,2, 100,heighHeaderItem - 4)];
        btStop.title = @"";
        [[btStop cell] setBackgroundColor:[NSColor colorWithRed:248.0/255 green:248.0/255 blue:248.0/255 alpha:1.0]];
        [btStop setImage:[NSImage imageNamed:@"cell_stop_normal.png"]];
        [btStop setButtonImage:[NSImage imageNamed:@"cell_stop_disable.png"] forState:UIControlStateDisabled];
        [btStop setImageScaling:NSImageScaleProportionallyUpOrDown];
        btStop.layer.cornerRadius = 10;
        [btStop setBordered:NO];
        [btStop setToolTip:@"Stop"];
        btStop.tag = BT_STOP;
        [btStop setTarget:self];
        [btStop setAction:@selector(buttonClick:)];
        [viewBottom addSubview:btStop];
        self.btStop = btStop;
        
        
        UIButton *btRescan = [[UIButton alloc] initWithFrame:NSMakeRect(rect.size.width*3/4 - 50,2, 100, heighHeaderItem - 4)];
        btRescan.title = @"";
        [[btRescan cell] setBackgroundColor:[NSColor colorWithRed:248.0/255 green:248.0/255 blue:248.0/255 alpha:1.0]];
        [btRescan setImage:[NSImage imageNamed:@"cell_rescan_normal.png"]];
        [btRescan setButtonImage:[NSImage imageNamed:@"cell_rescan_disable.png"] forState:UIControlStateDisabled];
        [btRescan setImageScaling:NSImageScaleProportionallyUpOrDown];
       // [btRescan sizeToFit];
        btRescan.layer.cornerRadius = 10;
        [btRescan setBordered:NO];
        btRescan.tag = BT_RESCAN;
        [btRescan setToolTip:@"Rescan"];
        [btRescan setTarget:self];
        [btRescan setAction:@selector(buttonClick:)];
        [viewBottom addSubview:btRescan];
        self.btRescan = btRescan;
        
        [self addSubview:viewcell];
    }
    
    
 
    return self;
}

@end
