//
//  UITextField.h
//  EarseMac
//
//  Created by Duyet Le on 1/10/22.
//  Copyright © 2022 Greystone. All rights reserved.
//



#import <Cocoa/Cocoa.h>
@class UITextField;

@protocol UITextFieldDelegate
@optional
-(BOOL)textFieldDidResignFirstResponder:(NSTextField *)sender;
@optional
-(BOOL)textFieldDidBecomeFirstResponder:(NSTextField *)sender;
@end

@interface UITextField : NSTextField
@property (strong, nonatomic) id <UITextFieldDelegate> uidelegate;
@end


