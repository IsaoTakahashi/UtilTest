//
//  NetworkUtil.h
//  UtilTest
//
//  Created by 高橋 勲 on 2012/10/19.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserSettingUtil.h"
#import "R9HTTPRequest.h"
#import "Base64Util.h"

enum DATA_TYPE{ASCII,BINARY,JPG};

@interface NetworkUtil : NSObject{}


+ (NetworkUtil*) getInstance;


@end


