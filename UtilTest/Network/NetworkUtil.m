//
//  NetworkUtil.m
//  UtilTest
//
//  Created by 高橋 勲 on 2012/10/19.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import "NetworkUtil.h"


static NetworkUtil *network = nil;

@interface NetworkUtil()

- (NSMutableURLRequest*)makeRequest:(NSURL*)url imageData:(NSData*)imageData fileName:(NSString*)fileName;

@end



@implementation NetworkUtil

+ (NetworkUtil*) getInstance {
    if(network == nil){
        network = [[NetworkUtil alloc] init];
    }
    
    return network;
}

//urlにGETリクエストを飛ばして結果を返すメソッド
+ (NSData*)sendGetRequest:(NSString*)url
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSMutableURLRequest* urlRequest =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [urlRequest setHTTPMethod:@"GET"];
    
    NSURLResponse* response;
    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:nil];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    return result;
}

//urlにBasic認証を使ったGETリクエストを飛ばして結果を返すメソッド
+ (NSData*)sendGetRequestBasicAuth:(NSString *)uri
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL* url = [NSURL URLWithString:uri];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // basic認証用のヘッダの内容を作る
    NSMutableString* enc = [NSMutableString stringWithCapacity:128];
    [enc appendString:[UserSettingUtil getUserName]];
    [enc appendString:@":"];
    [enc appendString:[UserSettingUtil getUserPassword]];
    //NSLog(@"%@",[UserSettingUtil getUserName]);
    
    // ヘッダに加える
    NSData* pool = [enc dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
    NSString* passwd = [Network stringEncodedWithBase64:pool];
    [request setValue:[NSString stringWithFormat:@"Basic %@", passwd] forHTTPHeaderField:@"Authorization"];
    
    // GETする
    [request setHTTPMethod:@"GET"];
    NSURLResponse* response;
    NSData* result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [request release];
    return result;
}

#pragma mark -
#pragma mark - private methods implementation
/*! maltipartで画像を送信するためのリクエストの作成 */
+ (NSMutableURLRequest*)makeRequest:(NSURL*)url imageData:(NSData*)imageData fileName:(NSString*)fileName
{
    NSString* boundary = @"----1010101010";
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // basic認証用のヘッダの内容を作る
    NSMutableString* enc = [NSMutableString stringWithCapacity:128];
    [enc appendString:[UserSettingUtil getUserName]];
    [enc appendString:@":"];
    [enc appendString:[UserSettingUtil getUserPassword]];
    // ヘッダに加える
    NSData* pool = [enc dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
    NSString* passwd = [self stringEncodedWithBase64:pool];
    [request setValue:[NSString stringWithFormat:@"Basic %@", passwd] forHTTPHeaderField:@"Authorization"];
    
    // POSTする
    [request setHTTPMethod:@"POST"];
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    //データの格納(取り敢えずイメージのみ)
    NSMutableData* postData = [[NSMutableData alloc] init];
    [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    if(fileName != nil){
        [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@\"\r\n",fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    }else{
        [postData appendData:[@"Content-Disposition: form-data; name=\"image\"; filename=\"test.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [postData appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:imageData];
    //[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:postData];
    [request addValue:[NSString stringWithFormat:@"%d", postData.length] forHTTPHeaderField: @"Content-Length"];
    [request setTimeoutInterval:100];
    [request setCachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    
    return request;
}

@end
