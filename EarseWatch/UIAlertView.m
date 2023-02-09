//
//  UIAlertView.m
//  iCombine Watch
//
//  Created by Duyet Le on 6/8/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import "UIAlertView.h"
#import "AppDelegate.h"
#import "UITextFieldCell.h"

@interface UIAlertView ()

@end

@implementation UIAlertView
@synthesize titleWindow;
@synthesize conten;
@synthesize icon;
@synthesize buttonList;
@synthesize root;
@synthesize seletor;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
- (void)setRoot:(id)parent seletor:(SEL)sel
{
    self.root = parent;
    self.seletor = sel;
}
- (id)initWithFrame:(NSRect)frame title:(NSString *)title conten:(NSString *)message icon:(NSImage *)image buttons:(NSMutableArray*)buttons tag:(NSInteger) tag Root:(id)parent seletor:(SEL)sel
{
    self = [self initWithFrame:frame title:title conten:message icon:image buttons:buttons tag:tag];
    [self setRoot:parent seletor:sel];
    return self;
}
- (id)initWithFrame:(NSRect)frame title:(NSString *)title conten:(NSString *)message icon:(NSImage *)image buttons:(NSMutableArray*)buttons tag:(NSInteger) tag
{
    self = [super init];
    
    index = tag;
    self.view = [[NSView alloc] init];
    self.view.frame = frame;
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = NSColor.whiteColor.CGColor;
    self.view.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    self.titleWindow = [[NSTextField alloc] initWithFrame:NSMakeRect(0, frame.size.height - 50, frame.size.width, 50)];
    self.titleWindow.cell = [[NSTextFieldCell alloc] init];
    self.titleWindow.stringValue = title;
    self.titleWindow.alignment = NSTextAlignmentCenter;
    self.titleWindow.font = [NSFont fontWithName:@"Roboto-Regular" size:28];
    self.titleWindow.textColor = [NSColor whiteColor];
    self.titleWindow.wantsLayer = YES;
    [self.titleWindow setBordered:NO];
    self.titleWindow.backgroundColor = delegate.colorBanner;
    self.titleWindow.layer.backgroundColor = delegate.colorBanner.CGColor;
    [self.view addSubview:self.titleWindow];
        
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

    if(image)
    {
    self.icon = [[NSImageView alloc] initWithFrame:NSMakeRect(10, frame.size.height - 120, 50, 50)];
    self.icon.image = image;
    [self.view addSubview:self.icon];
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
    }
    
    self.conten = [[NSTextField alloc] initWithFrame:NSMakeRect(60, frame.size.height - 120, frame.size.width-70, 70)];
    self.conten.cell = [[UITextFieldCell alloc] init];
    self.conten.alignment = NSTextAlignmentCenter;
    self.conten.wantsLayer = YES;
    self.conten.backgroundColor = [NSColor clearColor];
    self.conten.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.conten.textColor = [NSColor blackColor];
    self.conten.font = [NSFont fontWithName:@"Roboto-Regular" size:20];
    self.conten.stringValue = message;
    self.conten.maximumNumberOfLines = 3;
    [self.view addSubview:self.conten];
    
    if(buttons == Nil) return self;
    
    if(buttons.count == 2)
    {
        NSButton *bt = [[NSButton alloc] initWithFrame:NSMakeRect(50+(frame.size.width - 50)*1.0/4 - 50,20, 100, 30)];
        [bt setFont:[NSFont fontWithName:@"Roboto-Regular" size:15]];
        bt.wantsLayer = YES;
        [bt setBordered:YES];
        bt.layer.cornerRadius = 5;
        bt.layer.borderWidth = 2;
        bt.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
        [bt setToolTip:[buttons objectAtIndex:0]];
        [bt setTarget:self];
        bt.image = [NSImage imageNamed:@"button_normal.png"];
        bt.title = [buttons objectAtIndex:0];
        bt.tag = index;
        [bt setAction:@selector(btClick:)];
        [self.view addSubview:bt];
        
        NSButton *bt1 = [[NSButton alloc] initWithFrame:NSMakeRect(50+(frame.size.width-50)*3.0/4 - 50,20, 100, 30)];
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
        bt1.tag = index + 1;
        [bt1 setAction:@selector(btClick:)];
        [self.view addSubview:bt1];
    }
    else
    {
        for (int i = 0; i<buttons.count; i++)
        {
            NSButton *bt = [[NSButton alloc] initWithFrame:NSMakeRect(frame.size.width/2 - 70,frame.size.height-(buttons.count-i)*50+10, 140, 40)];
            [bt setFont:[NSFont fontWithName:@"Roboto-Regular" size:20]];
            bt.wantsLayer = YES;
            [bt setBordered:YES];
            bt.layer.cornerRadius = 5;
            bt.layer.borderWidth = 2;
            bt.layer.borderColor = [NSColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0].CGColor;
            [bt setToolTip:@"Cancel"];
            [bt setTarget:self];
            bt.image = [NSImage imageNamed:@"button_normal.png"];
            bt.title = [buttons objectAtIndex:i];
            bt.tag = i + index;
            [bt setAction:@selector(btClick:)];
            [self.view addSubview:bt];
        }
    }

    return self;
}
- (void)showWindow
{
    dispatch_async(dispatch_get_main_queue(), ^{

    NSWindow *window = [NSWindow windowWithContentViewController:self];
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
//        return window;
    });
    
}
- (void)btCloseClick:(id)sender
{
    [self.view.window close];
}
- (void)btClick:(id)sender
{
    if(root != nil && [root respondsToSelector:seletor])
    {
        NSButton *bt = (NSButton *)sender;
        [root performSelector:seletor withObject:[NSNumber numberWithLong:bt.tag]];
    }
    [self.view.window close];
}
@end
