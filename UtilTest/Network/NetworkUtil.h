//
//  NetworkUtil.h
//  UtilTest
//
//  Created by 高橋 勲 on 2012/10/19.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserSettingUtil.h"
#import "Base64Util.h"

enum DATA_TYPE{ASCII,BINARY,JPG};

@interface NetworkUtil : NSObject{}


+ (NetworkUtil*) getInstance;


//urlにGETリクエストを飛ばして結果を返すメソッド
+ (NSData*)sendGetRequest:(NSString*)uri;

//(Sync)urlにBasic認証を使ったGETリクエストを飛ばして結果を返すメソッド
+ (NSData*)sendGetRequestBasicAuth:(NSString *)uri;

//(Async)urlにBasic認証を使ったGETリクエストを飛ばして結果を返すメソッド
+ (void)sendGetAsyncRequestBasicAuth:(NSString *)uri;

@end


