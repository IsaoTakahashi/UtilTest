//
//  NetworkUtil.m
//  UtilTest
//
//  Created by 高橋 勲 on 2012/10/19.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import "SimpleNetwork.h"

@interface SimpleNetwork()
- (void) setBasicAuthInformation:(R9HTTPRequest*)request service:(NSString*)service;
- (void) setPostData:(R9HTTPRequest*)request postData:(NSMutableDictionary*)dic;
@end


@implementation SimpleNetwork

@synthesize delegate;

- (void) test {
    NSURL *URL = [NSURL URLWithString:@"http://www.apple.com"];
    R9HTTPRequest *request = [[R9HTTPRequest alloc] initWithURL:URL];
    // リクエスト結果の受け取り
    [request setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
        NSLog(@"%@", responseString);
    }];
    [request startRequest];
}

- (void) sendGetRequest:(NSURL*)url tag:(NSString*)tag {
    R9HTTPRequest* request = [[R9HTTPRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    [request setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
        [delegate receiveResponseResult:responseHeader responseString:responseString tag:tag];
    }];
    
    [request startRequest];
}

- (void) sendPostRequest:(NSURL*)url tag:(NSString*)tag postDatas:(NSMutableDictionary*)dic {
    R9HTTPRequest* request = [[R9HTTPRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    [request setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
        [delegate receiveResponseResult:responseHeader responseString:responseString tag:tag];
    }];
    
    [request setUploadProgressHandler:^(float newProgress){
        NSLog(@"%@'s progress: %g %%", tag,newProgress);
    }];

    //add body (仮)
    [request addBody:tag forKey:tag];
    
    //store post data
    [self setPostData:request postData:dic];
    
    [request startRequest];
}

- (void) sendBasicAuthGetRequest:(NSURL*)url tag:(NSString*)tag service:(NSString*)service {
    
    R9HTTPRequest* request = [[R9HTTPRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [self setBasicAuthInformation:request service:service];
    
    [request setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
        [delegate receiveResponseResult:responseHeader responseString:responseString tag:tag];
    }];
    
    [request startRequest];
    
    
}

- (void) sendBasicAuthPostRequest:(NSURL*)url tag:(NSString*)tag postDatas:(NSMutableDictionary*)dic service:(NSString*)service{
    R9HTTPRequest* request = [[R9HTTPRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    [request setCompletionHandler:^(NSHTTPURLResponse *responseHeader, NSString *responseString){
        [delegate receiveResponseResult:responseHeader responseString:responseString tag:tag];
    }];
    
    [request setUploadProgressHandler:^(float newProgress){
        NSLog(@"%@'s progress: %g %%", tag,newProgress);
    }];
    
    [self setBasicAuthInformation:request service:service];
    
    //add body (仮)
    [request addBody:tag forKey:tag];
    
    //store post data
    [self setPostData:request postData:dic];
    
    [request startRequest];
}


#pragma mark -
#pragma mark Private Method
- (void) setBasicAuthInformation:(R9HTTPRequest *)request service:(NSString*)service {
    // get use name/password
    NSMutableString* enc = [NSMutableString stringWithCapacity:128];
    [enc appendString:[UserSettingUtil getUserNameWithService:service]];
    [enc appendString:@":"];
    [enc appendString:[UserSettingUtil getUserPasswordWithService:service]];
    
    // add information to header
    NSData* pool = [enc dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
    NSString* passwd = [Base64Util stringEncodedWithBase64:pool];
    [request addHeader:[NSString stringWithFormat:@"Basic %@", passwd] forKey:@"Authorization"];
}

- (void) setPostData:(R9HTTPRequest*)request postData:(NSMutableDictionary*)dic {
    for (id key in [dic keyEnumerator]) {
        id value = [dic objectForKey:key];
        NSString* keyString = (NSString*)key;
        if([keyString isEmpty]) continue;
        
        if ([value isKindOfClass:[NSString class]]) {
            [request addBody:(NSString*)value forKey:keyString];
        } else if ([value isKindOfClass:[UIImage class]]) {
            IMAGETYPE type = [keyString hasPrefix:@"JPG"] ? JPG : PNG;
            NSString* contentType = nil;
            NSString* fileName = nil;
            switch (type) {
                case JPG:
                    contentType = [NSString stringWithFormat:@"image/jpeg"];
                    fileName = [NSString stringWithFormat:@"%@.jpg",keyString];
                    break;
                case PNG:
                    contentType = [NSString stringWithFormat:@"image/png"];
                    fileName = [NSString stringWithFormat:@"%@.png",keyString];
                default:
                    break;
            }
            UIImage* image = (UIImage*)value;
            NSData* data = [image convertToNSData:type];
            [request setData:data withFileName:(NSString*)key andContentType:contentType forKey:keyString];
        } else if ([value isKindOfClass:[NSData class]]) {
            [request setData:(NSData*)value withFileName:keyString andContentType:@"application/octet-stream" forKey:keyString];
        }
    }
}

@end
