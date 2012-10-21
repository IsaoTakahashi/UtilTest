//
//  UIImage+Edit.h
//  UtilTest
//
//  Created by 高橋 勲 on 2012/10/21.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum ImageType
{
    JPG,
    PNG
}IMAGETYPE;

@interface UIImage (Edit)
- (NSData*) convertToNSData:(IMAGETYPE)type;

@end
