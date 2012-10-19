//
//  Base64Util.h
//  UtilTest
//
//  Created by 高橋 勲 on 2012/10/19.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Base64Util : NSObject
// Base64にエンコードした文字列を生成する
+ (NSString *)stringEncodedWithBase64:(NSData*)str;

@end
