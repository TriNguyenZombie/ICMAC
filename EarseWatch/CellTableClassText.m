//
//  CellTableClassText.m
//  iCombine Watch
//
//  Created by Duyet Le on 6/9/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import "CellTableClassText.h"
#import "UITextFieldCell.h"

@implementation CellTableClassText
@synthesize aTextField;

- (id) initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    aTextField = [[NSTextField alloc] initWithFrame:frameRect];
    aTextField.drawsBackground = YES;
    [aTextField setBordered:YES];
    aTextField.cell = [[UITextFieldCell alloc] init];
    [aTextField setEditable:NO];
    [self addSubview:aTextField];
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    //aTextField = [[NSTextField alloc] initWithFrame:dirtyRect];
    // Drawing code here.
}

@end
