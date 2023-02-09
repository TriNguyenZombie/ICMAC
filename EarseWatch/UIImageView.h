//
//  UIImageView.h
//  EarseMac
//
//  Created by Duyet Le on 1/10/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView : NSImageView
- (id)initWithFrame:(NSRect)frame andImage:(NSImage*)image;
@end

NS_ASSUME_NONNULL_END
