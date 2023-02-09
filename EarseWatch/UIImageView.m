//
//  UIImageView.m
//  EarseMac
//
//  Created by Duyet Le on 1/10/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import "UIImageView.h"

@implementation UIImageView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
- (id)initWithFrame:(NSRect)frame andImage:(NSImage*)image
{
  self = [super initWithFrame:frame];
  if (self) {
    self.layer = [[CALayer alloc] init];
    self.layer.contentsGravity = kCAGravityResizeAspectFill;
    self.layer.contents = image;
    self.wantsLayer = YES;
  }
  return self;
}

@end
