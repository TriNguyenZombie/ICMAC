//
//  ViewController.h
//  EarseMac
//
//  Created by Greystone on 12/16/21.
//  Copyright © 2021 Greystone. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UITextField.h"
@interface LoginViewcontroller : NSViewController <UITextFieldDelegate,NSTextFieldDelegate>
{
    int height, width;
    UITextField *txtUserName;
    NSSecureTextField *txtPasswrod;
    NSImageView *imgUser;
    NSImageView *imgPass;
    int enterPassword;
    NSThread *threadSendLinkServerVerfy;

}

@property (strong, nonatomic) UITextField *txtUserName;
@property (strong, nonatomic) NSSecureTextField *txtPasswrod;

- (void)getTokenAndDownloadChecksumFile;
- (void)downloadFileConfig;
- (NSString *)createTokenWithUser:(NSString *)username api:(NSString*)apikey;
@end

