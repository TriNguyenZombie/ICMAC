//
//  PrinterSetting.h
//  EarseMac
//
//  Created by Duyet Le on 5/6/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UITextField.h"
NS_ASSUME_NONNULL_BEGIN

@interface PrinterSetting : NSViewController <UITextFieldDelegate,NSTextFieldDelegate>
{
    NSMutableDictionary *dicInfor;
    NSView *viewPrint;
    
    UITextField *txtLeftMargin;
    UITextField *txtRightMargin;
    UITextField *txtTopMargin;
    UITextField *txtBottomMargin;
    
    UITextField *txtPageWidth;
    UITextField *txtPageHeight;
    
    UITextField *txtTextFieldSize;
    NSView *viewGroupSetting;
    int autoPrint;
    int width;
    float dvpx;
    
    int leftMargin;
    int rightMargin;
    int topMargin;
    int bottomMargin;
    
    int pageWidth;// picell
    int pageHeight;//picell
    int fontSize;
    NSMutableArray *deviceInfoArray;
    
    NSComboBox *comboBox;
    
    NSImageView *imgDataPrintReview;
    int heightviewPreview;
    int widthviewPreview;
    
    NSMutableDictionary *dicConfig;
    NSString *printername;//temp when load info
    
    NSMutableDictionary *dicMapValue;
    
}
@property (strong, nonatomic) UITextField *txtLeftMargin;
@property (strong, nonatomic) UITextField *txtRightMargin;
@property (strong, nonatomic) UITextField *txtTopMargin;
@property (strong, nonatomic) UITextField *txtBottomMargin;

@property (strong, nonatomic) NSView *viewPrint;
@property (nonatomic, assign) int autoPrint;
@property (nonatomic, assign) int pageWidth;
@property (nonatomic, assign) int pageHeight;

- (id)initWithFrame:(CGRect)frameRect data:(NSMutableDictionary*)dic;
- (void) btPrintClick:(id)sender;
@end

NS_ASSUME_NONNULL_END
