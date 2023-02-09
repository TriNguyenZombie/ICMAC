//
//  CellTableClassText.h
//  iCombine Watch
//
//  Created by Duyet Le on 6/9/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CellTableClassText : NSTableCellView
{
    NSTextField *aTextField;
}
@property (strong) NSTextField *aTextField;
@end

NS_ASSUME_NONNULL_END
