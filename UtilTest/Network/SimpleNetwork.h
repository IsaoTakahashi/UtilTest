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
#import "UIImage+Edit.h"
#import "NSString+Validate.h"

@protocol SimpeNetworkDelegate <NSObject>

- (void) receiveResponseResult:(NSHTTPURLResponse*)responseHeader responseString:(NSString*)responseString tag:(NSString*)tag;

@end

@interface SimpleNetwork : NSObject{
    __weak id<SimpeNetworkDelegate> delegate;
}

@property (weak) id<SimpeNetworkDelegate> delegate;

- (void) sendGetRequest:(NSURL*)url tag:(NSString*)tag;
- (void) sendPostRequest:(NSURL*)url tag:(NSString*)tag postDatas:(NSMutableDictionary*)dic;

- (void) sendBasicAuthGetRequest:(NSURL*)url tag:(NSString*)tag service:(NSString*)service;
- (void) sendBasicAuthPostRequest:(NSURL*)url tag:(NSString*)tag postDatas:(NSMutableDictionary*)dic service:(NSString*)service;



@end


