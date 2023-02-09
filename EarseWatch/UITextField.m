//
//  UITextField.m
//  EarseMac
//
//  Created by Duyet Le on 1/10/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import "UITextField.h"

@implementation UITextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
}

- (BOOL)becomeFirstResponder
{
    BOOL status = [super becomeFirstResponder];
    if (status) [self.uidelegate textFieldDidBecomeFirstResponder:self];
    return status;
    
}
- (BOOL)resignFirstResponder
{
    BOOL status = [super resignFirstResponder];
    if (status) [self.uidelegate textFieldDidResignFirstResponder:self];
    return status;
}


@end
