//
//  ReportViewController.h
//  iCombine Watch
//
//  Created by Duyet Le on 6/9/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReportViewController : NSViewController
{
    NSMutableDictionary *dicInfor;
    NSMutableArray *arrayItem;
    int numRowOfPage;
}
- (id)initWithFrame:(CGRect)frame data:(NSMutableDictionary*)dic;
- (void)showWindow;
@end

NS_ASSUME_NONNULL_END
