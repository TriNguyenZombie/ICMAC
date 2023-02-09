//
//  main.m
//  EarseMac
//
//  Created by Greystone on 12/16/21.
//  Copyright © 2021 Greystone. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
int main(int argc, const char * argv[]) {
    
//    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    [NSApplication sharedApplication];

    AppDelegate *appDelegate = [[AppDelegate alloc] init];
    [NSApp setDelegate:appDelegate];
    [NSApp run];
    
//    [pool release];
//    return 0;
    return NSApplicationMain(argc, argv);
}
