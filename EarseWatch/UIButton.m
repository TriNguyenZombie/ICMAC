//
//  UIButton.m
//  EarseMac
//
//  Created by Duyet Le on 1/11/22.
//  Copyright © 2022 Greystone. All rights reserved.
//

#import "UIButton.h"

@implementation UIButton

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if(imageNormal)
        [self setImage:imageNormal];
    // Drawing code here.
    [self setNeedsDisplay];
    
}
- (void) awakeFromNib
{
    [super awakeFromNib];
    if(imageNormal)
        [self setImage:imageNormal];
    //[self sendActionOn:NSEventMaskLeftMouseDown];
}
- (void)setButtonImage:(NSImage *)img forState:(UIControlState)state
{
    if(state==UIControlStateNormal)
    {
        imageNormal = img;
    }
    else if(state == UIControlStatePress)
    {
        imagePress = img;
    }
    else if(state == UIControlStateDisabled)
    {
        imageDisable = img;
    }
}
//- (void)mouseDown:(NSEvent *)event
//{
//    [super mouseDown:event];
//    if(self.enabled==NO) return;
//    NSLog(@"%s",__func__);
//    if(imagePress)
//    {
//        [self setImage:imagePress];
//     //  [self setNeedsDisplay];
//    }
//}

- (void)mouseDown:(NSEvent *)event
{
    [super mouseDown:event];
    NSLog(@"%s",__func__);
    if(imagePress)
    {
        [self setImage:imagePress];
    }
    
 
}
- (void)resetImage
{
    NSLog(@"%s",__func__);
    if(imageNormal)
        [self setImage:imageNormal];
         
}
- (void)mouseUp:(NSEvent *)event
{
    [super mouseUp:event];    
    if(self.enabled==NO) return;
    NSLog(@"%s",__func__);
    if(imageNormal)
        [self setImage:imageNormal];
       
}
- (void)mouseExited:(NSEvent *)event
{
    [super mouseExited:event];
    if(self.enabled==NO) return;
    NSLog(@"%s",__func__);
    if(imageNormal)
        [self setImage:imageNormal];
}
- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if(enabled)
    {
        if(imageNormal)
            [self setImage:imageNormal];
    }
    else
    {
        if(imageDisable)
            [self setImage:imageDisable];
    }
}


/*
- (void)chekMoseEvent:(NSEvent *)event
{
    BOOL keepOn = YES;
    BOOL isInside = YES;
    NSPoint mouseLoc;
    while (keepOn)
    {
        event = [[self window] nextEventMatchingMask: NSLeftMouseDown | NSLeftMouseUp | NSMouseExited | NSMouseEntered];
       //event = [[self window] nextEventMatchingMask: NSAnyEventMask];
        mouseLoc = [self convertPoint:[event locationInWindow] fromView:nil];
        isInside = [self mouse:mouseLoc inRect:[self bounds]];

        switch ([event type])
        {
            case NSMouseEntered:NSLog(@"NSMouseEntered");
                break;
            case NSLeftMouseDown:NSLog(@"NSLeftMouseDown");
                break;
            case NSMouseExited:NSLog(@"NSMouseExited");
                break;
            case NSLeftMouseUp:NSLog(@"NSLeftMouseUp");
                    if (isInside)
                    {
                        [self mouseUp:event];
                    }
                    [self highlight:NO];
                    keepOn = NO;
                    break;


            default: break;

        }
    }



//
//        NSEventTypeLeftMouseDown             = 1,
//           NSEventTypeLeftMouseUp               = 2,
//           NSEventTypeRightMouseDown            = 3,
//           NSEventTypeRightMouseUp              = 4,
//           NSEventTypeMouseMoved                = 5,
//           NSEventTypeLeftMouseDragged          = 6,
//           NSEventTypeRightMouseDragged         = 7,
//           NSEventTypeMouseEntered              = 8,
//           NSEventTypeMouseExited               = 9,
//           NSEventTypeKeyDown                   = 10,
//           NSEventTypeKeyUp                     = 11,
//           NSEventTypeFlagsChanged              = 12,
//           NSEventTypeAppKitDefined             = 13,
//           NSEventTypeSystemDefined             = 14,
//           NSEventTypeApplicationDefined        = 15,
//           NSEventTypePeriodic                  = 16,
//           NSEventTypeCursorUpdate              = 17,
//           NSEventTypeScrollWheel               = 22,
//           NSEventTypeTabletPoint               = 23,
//           NSEventTypeTabletProximity           = 24,
//           NSEventTypeOtherMouseDown            = 25,
//           NSEventTypeOtherMouseUp              = 26,
//           NSEventTypeOtherMouseDragged         = 27,


//        event = [[self window] nextEventMatchingMask: NSAnyEventMask];
//        NSLog(@"NSMouse event %d",event);
//        mouseLoc = [self convertPoint:[event locationInWindow] fromView:nil];
//        isInside = [self mouse:mouseLoc inRect:[self bounds]];
//
//        switch ([event type])
//        {
//            case NSLeftMouseDragged:
//                NSLog(@"NSLeftMouseDragged");
//                    [self highlight:isInside];
//                    break;
//            case NSMouseExited:
//                NSLog(@"NSMouseExited");
//                if(self.enabled==NO) return;
//                NSLog(@"%s",__func__);
//                if(imageNormal)
//                    [self setImage:imageNormal];
//                break;
//            case NSEventTypeLeftMouseDown:
//                NSLog(@"NSEventTypeLeftMouseDown");
//                break;
////            case NSEventTypeLeftMouseUp:
////                NSLog(@"NSEventTypeLeftMouseUp");
////                break;
//            case NSEventTypeMouseEntered:
//                NSLog(@"NSEventTypeMouseEntered");
//                break;
//
//            case NSLeftMouseUp:
////                    if (isInside)
////                    {
//                        [self mouseUp:event];
////                    }
//                    [self highlight:NO];
//                    keepOn = NO;
//                    break;
//
//
//            default: break;
//
//        }
//    }
}
*/
//
//- (void)rightMouseDown:(NSEvent *)event
//{
//    NSLog(@"%s",__func__);
//}
//- (void)otherMouseDown:(NSEvent *)event
//{
//    NSLog(@"%s",__func__);
//}
//- (void)rightMouseUp:(NSEvent *)event
//{
//    NSLog(@"%s",__func__);
//}
//- (void)otherMouseUp:(NSEvent *)event
//{
//    NSLog(@"%s",__func__);
//}
//- (void)mouseMoved:(NSEvent *)event
//{
//    NSLog(@"%s",__func__);
//}
//- (void)mouseDragged:(NSEvent *)event
//{
//    NSLog(@"%s",__func__);
//}
//- (void)mouseEntered:(NSEvent *)event
//{
//    NSLog(@"%s",__func__);
//}




@end
