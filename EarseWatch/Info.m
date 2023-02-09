//
//  Info.m
//  EarseMac
//
//  Created by Duyet Le on 12/27/21.
//  Copyright © 2021 Greystone. All rights reserved.
//

#import "Info.h"

@implementation Info
@synthesize vid;
@synthesize pid;
@synthesize cap;
@synthesize manufacturer;
@synthesize product;
@synthesize serialNumber;

- (id)init
{
    self  = [super init];
    vid = 0;
    pid = 0;
    cap = 0;
    manufacturer = nil;
    product = nil;
    serialNumber = nil;
    libusb = nil;
    return self;
}

- (void)setInfo:(uint16_t) vid pid:(uint16_t) pid Manufacturer:(NSString *)manufac Product:(NSString *)product Serial:(NSString*)serial
{
    self.vid = vid;
    self.pid = pid;
    self.manufacturer = [[NSString alloc] initWithString:manufac];
    self.product = [[NSString alloc] initWithString:product];
    self.serialNumber = [[NSString alloc] initWithString:serial];
}
- (void)setInfo:(NSDictionary *)dic
{
    self.vid = [[dic objectForKey:@"vid"] unsignedShortValue];
    self.pid = [[dic objectForKey:@"pid"] unsignedShortValue];;
    self.manufacturer = [[NSString alloc] initWithFormat:@"%@",[dic objectForKey:@"manufacturer"]];
    self.product = [[NSString alloc] initWithFormat:@"%@",[dic objectForKey:@"product"]];
    self.serialNumber = [[NSString alloc] initWithFormat:@"%@",[dic objectForKey:@"serial"]];
}

@end
