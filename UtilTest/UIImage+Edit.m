//
//  UIImage+Edit.m
//  UtilTest
//
//  Created by 高橋 勲 on 2012/10/21.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import "UIImage+Edit.h"

#define PRECISION   0.9

@implementation UIImage (Edit)

- (NSData*) convertToNSData:(IMAGETYPE)type {
    NSData* data = nil;
    
    switch (type) {
        case JPG:
            data = UIImageJPEGRepresentation(self, PRECISION);
            break;
        case PNG:
            data = UIImagePNGRepresentation(self);
        default:
            break;
    }
    
    return data;
}

@end
