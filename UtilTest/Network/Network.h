
//
//  Network.h
//  Project_iPadSticky
//BOOL
//  Created by 高橋 勲 on 10/04/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileIO.h"
#import "UserData.h"
#import "ChatLog.h"
#import "MultipartPostHelper.h"

/*!
 通信全体を統括するクラス。
 利用時にはインスタンスを生成せず、以下のように必ずgetInstanceを使ってください。
 Network* net = [Network getInstance];
 その際インスタンスをreleaseしないようにしてください。
 */

enum REQUEST_CODE{REQUEST,ACCEPT,DECLINE,UNFRIEND};

@interface Network : NSObject {
    NSUserDefaults*     userdef_;
    BOOL             isTMBDisconnected_;
}

@property (nonatomic, assign) BOOL isTMBDisconnected;

+ (Network*) getInstance;


// Base64にエンコードした文字列を生成する
+ (NSString *)stringEncodedWithBase64:(NSData*)str;

//urlにGETリクエストを飛ばして結果を返すメソッド
+ (NSData*)sendGetRequest:(NSString*)uri;

//urlにBasic認証を使ったGETリクエストを飛ばして結果を返すメソッド
+ (NSData*)sendGetRequestBasicAuth:(NSString *)uri;

//urlにBasic認証を使ったGETリクエストを飛ばして結果を返すメソッド
+ (void)sendGetAsyncRequestBasicAuth:(NSString *)uri;


//Basic認証通過してGETするメソッド
- (NSData*)getHttp:(NSString*)uri user:(NSString*)user pass:(NSString*)pass;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

- (BOOL) sendAuth;
- (BOOL) sendChatMessage:(ChatLog*)message roomId:(int)roomId;
- (BOOL) sendGeoLocation:(UserData*)user;
- (BOOL) sendInvitingUserInChat:(UserData*)user;
- (BOOL) sendFriendRequest:(UserData*)target operation:(enum REQUEST_CODE)op;
- (NSString*) getUserListXML;
- (NSString*) getRequestUserListXML:(NSString*)searchWord;
- (NSString*) getUnfriendUserListXML:(NSString*)searchWord;
- (NSString*) getGeoLocationListXML;
- (NSString*) getChatLogXML:(int)roomId;
- (NSString*) getChatRoomListXML;

- (NSString*) getUserProfileXML:(NSString*)mailAddress;
- (NSString*) getDepartmentList;

- (BOOL) checkExistsDeviceToken;
- (BOOL) registerDeviceToken:(NSData*)deviceToken;

- (BOOL) requestUserLocation:(UserData*)ud;
- (BOOL) locationUpdate:(UserData*)friend myLocation:(CLLocationCoordinate2D)coordinate;


//FIXME:イメージをイメージサーバーに送信するメソッド 
+ (NSString*)sendImageToImageServer:(NSString*)uri user:(NSString*)user 
                               pass:(NSString*)pass data:(NSData*)data
                               rect:(CGRect)rect filename:(NSString*)filename;





@end

