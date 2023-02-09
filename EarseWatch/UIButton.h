//
//  UIButton.h
//  EarseMac
//
//  Created by Duyet Le on 1/11/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, UIControlState) {
    UIControlStateNormal       = 0,
    UIControlStateHighlighted  = 1 << 0,                  // used when UIControl isHighlighted is set
    UIControlStateDisabled     = 1 << 1,
    UIControlStateSelected     = 1 << 2,                  // flag usable by app (see below)
    UIControlStateFocused      = 1 << 3, // Applicable only when the screen supports focus
    UIControlStatePress        = 1 << 4,
    UIControlStateApplication  = 0x00FF0000,              // additional flags available for application use
    UIControlStateReserved     = 0xFF000000               // flags reserved for internal framework use
};

@interface UIButton : NSButton
{
    NSImage *imageNormal;
    NSImage *imagePress;
    NSImage *imageDisable;
}
- (void)resetImage;
- (void)setButtonImage:(NSImage *)img forState:(UIControlState)state;
@end

NS_ASSUME_NONNULL_END
