//
//  Info.h
//  EarseMac
//
//  Created by Duyet Le on 12/27/21.
//  Copyright © 2021 Greystone. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ProccessUSB;
NS_ASSUME_NONNULL_BEGIN

@interface Info : NSObject
{
    uint16_t vid;
    uint16_t pid;
    uint16_t cap;
    NSString *manufacturer;
    NSString *product;
    NSString *serialNumber;
    ProccessUSB *libusb;
}
@property (assign) uint16_t vid;
@property (assign) uint16_t pid;
@property (assign) uint16_t cap;
@property (strong, nonatomic) NSString *manufacturer;
@property (strong, nonatomic) NSString *product;
@property (strong, nonatomic) NSString *serialNumber;
@end

NS_ASSUME_NONNULL_END
