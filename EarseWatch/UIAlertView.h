//
//  UIAlertView.h
//  iCombine Watch
//
//  Created by Duyet Le on 6/8/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertView : NSViewController
{
    NSTextField *titleWindow;
    NSTextField *conten;
    NSImageView *icon;
    NSMutableArray *buttonList;
    
    long index;
    id root;
    SEL seletor;
}
@property (strong, nonatomic) NSTextField *titleWindow;
@property (strong, nonatomic) NSTextField *conten;
@property (strong, nonatomic) NSImageView *icon;
@property (strong, nonatomic) NSMutableArray *buttonList;
@property (strong, nonatomic)  id root;
@property (assign, nonatomic)  SEL seletor;
- (id)initWithFrame:(NSRect)frame title:(NSString *)title conten:(NSString *)message icon:(NSImage *)image buttons:(NSMutableArray*)buttons tag:(NSInteger) tag Root:(id)parent seletor:(SEL)sel;
- (void)showWindow;
@end

NS_ASSUME_NONNULL_END
