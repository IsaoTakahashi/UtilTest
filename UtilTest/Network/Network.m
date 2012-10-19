//
//  Network.m
//  Project_iPadSticky
//
//  Created by 高橋 勲 on 10/04/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Network.h"
#import "UserSettingUtil.h"


//クラスプロパティの代わり
static Network* network;

//! 符号化／復号化時の変換テーブル
static const char    s_cBase64Tbl[] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
    'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
    'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3',
    '4', '5', '6', '7', '8', '9', '+', '/'
    // '='
};

// CR/LF
static NSString        *s_pstrCRLF = @"\r\n";

// '-'
static NSString        *s_pstrEqual = @"=";

@implementation Network

@synthesize isTMBDisconnected=isTMBDisconnected_;

#pragma mark -
#pragma mark Util
//シングルトンメソッド
+ (Network*) getInstance {
    if(network == nil){
        network = [[Network alloc] init];
        [network retain];
    }
    
    return network;
}

- (id) init
{
    if((self = [super init]))
    {
        userdef_    = [NSUserDefaults standardUserDefaults];
		isTMBDisconnected_ = YES;
    }
    
    return self;
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

//urlにBasic認証を使ったGETリクエストを飛ばして結果を返すメソッド
+ (void)sendGetAsyncRequestBasicAuth:(NSString *)uri
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL* url = [NSURL URLWithString:uri];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // basic認証用のヘッダの内容を作る
    NSMutableString* enc = [NSMutableString stringWithCapacity:128];
    [enc appendString:[UserSettingUtil getUserName]];
    [enc appendString:@":"];
    [enc appendString:[UserSettingUtil getUserPassword]];
    
    // ヘッダに加える
    NSData* pool = [enc dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
    NSString* passwd = [Network stringEncodedWithBase64:pool];
    [request setValue:[NSString stringWithFormat:@"Basic %@", passwd] forHTTPHeaderField:@"Authorization"];
    
    // GETする
    [request setHTTPMethod:@"GET"];
    [NSURLConnection connectionWithRequest:request delegate:nil];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

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

//Basic認証通過してGETするメソッド
- (NSData*)getHttp:(NSString*)uri user:(NSString*)user pass:(NSString*)pass {
    NSURL* url = [NSURL URLWithString:uri];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // basic認証用のヘッダの内容を作る
    NSMutableString* enc = [NSMutableString stringWithCapacity:128];
    [enc appendString:user];
    [enc appendString:@":"];
    [enc appendString:pass];
    
    // ヘッダに加える
    NSData* pool = [enc dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
    NSString* passwd = [Network stringEncodedWithBase64:pool];
    [request setValue:[NSString stringWithFormat:@"Basic %@", passwd] forHTTPHeaderField:@"Authorization"];
    
    // GETする
    [request setHTTPMethod:@"GET"];
    NSURLResponse* response;
    NSData* result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    return [[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] autorelease];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"サーバーから応答がありました");
    
    //あとで復元に使うため、エンコーディング方法を保存しておきます
    //ここではShift_JISか、それ以外の場合はUTF-8でエンコードします
    //NSString *responseName = [response textEncodingName];
    //if(response == nil) NSLog(@"failed?");
    //NSLog(@"%@",response);
    //NSLog(@"%@",responseName);
    /*if ([encodingName isEqualToString:@"shift_jis"] || [encodingName isEqualToString:@"sjis"]) {
     encoding = NSShiftJISStringEncoding;
     }else{
     encoding = NSUTF8StringEncoding;
     }*/
}

#pragma mark -
#pragma mark Relationサーバとの通信インタフェース

- (BOOL) sendAuth
{
    NSString* uri = [UserSettingUtil getRealationServerAddress];
    NSString* mail = [UserSettingUtil getUserName];
    NSString* pass = [UserSettingUtil getUserPassword];
    
    uri = [uri stringByAppendingFormat:@"login.php?mail=%@&pass=%@",mail,pass];
    //NSLog(@"%@",uri);
    
    NSData* response = [Network sendGetRequest:uri];
    
    //NSLog(@"%@",[FileIO data2str:response]);
    if([[FileIO data2str:response] isEqualToString:@"1"])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL) sendChatMessage:(ChatLog*)message roomId:(int)roomId
{
    NSString* uri = [UserSettingUtil getRealationServerAddress];
    NSString* mail = [UserSettingUtil getUserName];
    
    uri = [uri stringByAppendingFormat:@"chatLog.php?mail=%@&room_id=%d&text=%@",mail,roomId,[message.content stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@",uri);
    
    NSData* response = [Network sendGetRequest:uri];
    
    NSLog(@"%@",[FileIO data2str:response]);
    if([[FileIO data2str:response] isEqualToString:@"1"])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL) sendGeoLocation:(UserData*)user;
{
    //NSData* result = [Network sendGetRequest:[NSString stringWithFormat:@"http://tm-1031.sakura.ne.jp/realation/getLocation.php?mail=%@",[UserSettingUtil getUserName]]];
    //NSLog(@"%@",[FileIO data2str:result]);
    NSString* uri = [NSString stringWithFormat:@"http://tm-1031.sakura.ne.jp/realation/setLocation.php?mail=%@",[UserSettingUtil getUserName]];
    uri = [uri stringByAppendingFormat:@"&lat=%f&lng=%f",user.currentLocation.latitude,user.currentLocation.longitude];
    NSData* result = [Network sendGetRequest:uri];
    NSLog(@"%@",[FileIO data2str:result]);
    
    return YES;
}

- (BOOL) sendInvitingUserInChat:(UserData*)user
{
    return NO;
}

- (BOOL) sendFriendRequest:(UserData*)target operation:(enum REQUEST_CODE)op
{
    NSString* baseUri = [UserSettingUtil getRealationServerAddress];
    NSString* mail = [UserSettingUtil getUserName];
    NSString* code = nil;
    
    switch (op) {
        case REQUEST:
            code = @"request";
            break;
        case ACCEPT:
            code = @"accept";
            break;
        case DECLINE:
            code = @"decline";
            break;
        case UNFRIEND:
            code = @"unfriend";
            break;
        default:
            break;
    }
    
    if(code == nil) return NO;
    
    NSString* uri = [NSString stringWithFormat:@"%@friend/operation.php?mail=%@&code=%@&friend_id=%d",baseUri,mail,code,target.userId];
    NSData* result = [Network sendGetRequest:uri];
    NSLog(@"%@",[FileIO data2str:result]);
    
    NSString* xmlString = [FileIO data2str:result];
    //NSLog(@"%@",xmlString);
    
    NSRange searchResult = [xmlString rangeOfString:@"ok"];
    if(searchResult.location == NSNotFound)
    {
        return NO;
    }
    
    return YES;
}

- (NSString*) getUserListXML
{
    NSString* uri = [UserSettingUtil getRealationServerAddress];
    NSString* mail = [UserSettingUtil getUserName];
    
    uri = [uri stringByAppendingFormat:@"userList.php?mail=%@",mail];
    //NSLog(@"%@",uri);
    
    NSData* response = [Network sendGetRequest:uri];
    NSString* xmlString = [FileIO data2str:response];
    //NSLog(@"%@",[FileIO data2str:response]);

    //NSLog(@"%@",xmlString);

    return xmlString;
}

- (NSString*) getRequestUserListXML:(NSString*)searchWord
{
    NSString* uri = [UserSettingUtil getRealationServerAddress];
    NSString* mail = [UserSettingUtil getUserName];
    
    uri = [uri stringByAppendingFormat:@"friend/getstatusall.php?mail=%@",mail];
    //NSLog(@"%@",uri);
    
    NSData* response = [Network sendGetRequest:uri];
    NSString* xmlString = [FileIO data2str:response];
    //NSLog(@"%@",[FileIO data2str:response]);
    
    //NSLog(@"%@",xmlString);
    
    return xmlString;
}

- (NSString*) getUnfriendUserListXML:(NSString*)searchWord
{
    NSString* uri = [UserSettingUtil getRealationServerAddress];
    NSString* mail = [UserSettingUtil getUserName];
    
    uri = [uri stringByAppendingFormat:@"friend/search.php?mail=%@",mail];
    //NSLog(@"%@",uri);
    
    NSData* response = [Network sendGetRequest:uri];
    NSString* xmlString = [FileIO data2str:response];
    //NSLog(@"%@",[FileIO data2str:response]);
    
    //NSLog(@"%@",xmlString);
    
    return xmlString;
}

- (NSString*) getGeoLocationListXML
{
    NSString* uri = [UserSettingUtil getRealationServerAddress];
    NSString* mail = [UserSettingUtil getUserName];
    
    uri = [uri stringByAppendingFormat:@"getLocation.php?mail=%@",mail];
    //NSLog(@"%@",uri);
    
    NSData* response = [Network sendGetRequest:uri];
    NSString* xmlString = [FileIO data2str:response];
    //NSLog(@"%@",[FileIO data2str:response]);
    
    //NSLog(@"%@",xmlString);
    
    return xmlString;
}

- (NSString*) getChatLogXML:(int)roomId
{
    //return [FileIO data2str:[FileIO file2data:@"chatlog.xml" subDir:nil]];
    
    NSString* uri = [UserSettingUtil getRealationServerAddress];
    //NSString* mail = [UserSettingUtil getUserName];
    
    uri = [uri stringByAppendingFormat:@"chatLog.php?room_id=%d",roomId];
    //NSLog(@"%@",uri);
    
    NSData* response = [Network sendGetRequest:uri];
    NSString* xmlString = [FileIO data2str:response];
    //NSLog(@"%@",[FileIO data2str:response]);
    
    NSLog(@"%@",xmlString);
    
    return xmlString;
}

- (NSString*) getChatRoomListXML
{
    //return [FileIO data2str:[FileIO file2data:@"roomList.xml" subDir:nil]];
    
    NSString* uri = [UserSettingUtil getRealationServerAddress];
    NSString* mail = [UserSettingUtil getUserName];
    
    uri = [uri stringByAppendingFormat:@"roomList.php?mail=%@",mail];
    //NSLog(@"%@",uri);
    
    NSData* response = [Network sendGetRequest:uri];
    NSString* xmlString = [FileIO data2str:response];
    //NSLog(@"%@",[FileIO data2str:response]);
    
    //NSLog(@"%@",xmlString);
    
    return xmlString;
}

- (NSString*) getUserProfileXML:(NSString*)mailAddress
{
    NSString* uri = [UserSettingUtil getRealationServerAddress];
    NSString* mail = mailAddress;// [UserSettingUtil getUserName];
    
    uri = [uri stringByAppendingFormat:@"ws/getUsr.php?mail=%@",mail];
    //NSLog(@"%@",uri);
    
    NSData* response = [Network sendGetRequest:uri];
    NSString* xmlString = [FileIO data2str:response];
    //NSLog(@"%@",[FileIO data2str:response]);
    
    //NSLog(@"%@",xmlString);
    
    return xmlString;
}

- (NSString*) getDepartmentList
{
    NSString* uri = [UserSettingUtil getRealationServerAddress];
    
    uri = [uri stringByAppendingFormat:@"ws/getDepartment.php?"];
    //NSLog(@"%@",uri);
    
    NSData* response = [Network sendGetRequest:uri];
    NSString* xmlString = [FileIO data2str:response];
    //NSLog(@"%@",[FileIO data2str:response]);
    
    //NSLog(@"%@",xmlString);
    
    return xmlString;
}

- (BOOL) checkExistsDeviceToken
{
    NSString* uri = [UserSettingUtil getRealationServerAddress];
    NSString* mail = [UserSettingUtil getUserName];
    
    uri = [uri stringByAppendingFormat:@"ws/push_existed.php?mail=%@",mail];
    //NSLog(@"%@",uri);
    
    NSData* response = [Network sendGetRequest:uri];
    NSString* xmlString = [FileIO data2str:response];
    NSRange searchResult = [xmlString rangeOfString:@"ok"];
    if(searchResult.location == NSNotFound)
    {
        return NO;
    }
    
    return YES;
}


- (BOOL) registerDeviceToken:(NSData*)deviceToken
{
    NSString* uri = [UserSettingUtil getRealationServerAddress];
    NSString* mail = [UserSettingUtil getUserName];
        
    NSString* deviceTokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    uri = [uri stringByAppendingFormat:@"ws/push_register_get.php?mail=%@&device_token=%@",mail,deviceTokenString];

    //NSLog(@"%@",uri);
    NSData* response = [Network sendGetRequest:uri];
    NSString* xmlString = [FileIO data2str:response];
    //NSLog(@"%@",xmlString);

    NSRange searchResult = [xmlString rangeOfString:@"ok"];
    if(searchResult.location == NSNotFound)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL) requestUserLocation:(UserData*)ud
{
    NSString* uri = [UserSettingUtil getRealationServerAddress];
    NSString* mail = [UserSettingUtil getUserName];
    uri = [uri stringByAppendingFormat:@"push/requestLocation?mail=%@&friend_id=%d&push_msg=%@",mail,ud.userId,[@"今どこー？" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];//]ud.userId];
    NSLog(@"%@",uri);
    NSData* response = [Network sendGetRequest:uri];
    NSString* xmlString = [FileIO data2str:response];
    NSLog(@"%@",xmlString);
    
    NSRange searchResult = [xmlString rangeOfString:@"ok"];
    if(searchResult.location == NSNotFound)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL) locationUpdate:(UserData*)friend myLocation:(CLLocationCoordinate2D)coordinate
{
    NSString* uri = [UserSettingUtil getRealationServerAddress];
    NSString* mail = [UserSettingUtil getUserName];
    uri = [uri stringByAppendingFormat:@"push/locationUpdated?mail=%@&friend_id=%d&lat=%f&lng=%f&push_msg=%@",mail,friend.userId,coordinate.latitude,coordinate.longitude,[@"今ここー" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"%@",uri);
    NSData* response = [Network sendGetRequest:uri];
    NSString* xmlString = [FileIO data2str:response];
    //NSLog(@"%@",xmlString);
    
    NSRange searchResult = [xmlString rangeOfString:@"ok"];
    if(searchResult.location == NSNotFound)
    {
        return NO;
    }
    
    return YES;
}


//ドキュメントサーバから特定のノートを取得するメソッド
- (NSString*)getNoteXML:(NSString*)uri
{
    NSData* data;
    
    data = [self getHttp:uri user:[userdef_ stringForKey:@"userName"] pass:[userdef_ stringForKey:@"password"]];
    
    return (NSString*)data;
}


//イメージをイメージサーバーにPOSTするメソッド
+ (NSString*)sendImageToImageServer:(NSString*)uri user:(NSString*)user pass:(NSString*)pass data:(NSData*)data rect:(CGRect)rect filename:(NSString*)filename
{
    //NSLog(@"sendImage start... filename = %@",filename);
    //boundary
    NSString* boundary = @"----1010101010";
    
    //NSURL* url = [NSURL URLWithString:[uri stringByAppendingFormat:@"?userid=%@%@", user,stringRect]];
    
    NSLog(@"%@",uri);
    NSURL* url = [NSURL URLWithString:uri];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // basic認証用のヘッダの内容を作る
    NSMutableString* enc = [NSMutableString stringWithCapacity:128];
    [enc appendString:user];
    [enc appendString:@":"];
    [enc appendString:pass];
    
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
    if(filename != nil){
		[postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadfile\"; filename=\"%@\"\r\n",filename] dataUsingEncoding:NSUTF8StringEncoding]];
		NSString* extension = [[filename componentsSeparatedByString:@"."] lastObject];
		if(extension != nil){
			if([extension isEqualToString:@"jpg"]){
				[postData appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			}else if([extension isEqualToString:@"zip"]){
				[postData appendData:[@"Content-Type: application/zip\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			}
		}
    }else{
        [postData appendData:[@"Content-Disposition: form-data; name=\"uploadfile\"; filename=\"test.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[postData appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [postData appendData:data];
    //[postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:postData];
    [request addValue:[NSString stringWithFormat:@"%d", postData.length] forHTTPHeaderField: @"Content-Length"];
    [request setTimeoutInterval:100];
    [request setCachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    
    NSURLResponse* response;
    NSData* result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSString* rest = [FileIO data2str:result];
    NSLog(@"%@",rest);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSHTTPURLResponse* res = (NSHTTPURLResponse*)response;
    
    //NSLog(@"sendImage end... result = %@",resultString);
    if([res statusCode] != 200)
    //if(![resultString isEqualToString:@"OK"] && ![HashUtil isMD5Hash:resultString])
    {
        UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"イメージ送信" message:@"送信に失敗しました" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [alert show];
        return @"NG";
    }
    
    return rest;
}



//矩形を指定してテキストを送信
+ (NSString*) sendTextWithRect:(NSString *)sendText rect:(CGRect)rect ColorInt:(int)colorInt sourceHash:(NSString *)sourceHash
{
    NSUserDefaults* userdef = [NSUserDefaults standardUserDefaults];
    
    NSString* stringCoordinate = @"";
    if(rect.size.width != 0)
    {
        int x = (int)rect.origin.x;
        int y = (int)rect.origin.y;
        int width = (int)rect.size.width;
        int height = (int)rect.size.height;
        
        stringCoordinate = [NSString stringWithFormat:@"&x=%d&y=%d&w=%d&h=%d",x,y,width,height];
    }
    stringCoordinate = [stringCoordinate stringByAppendingFormat:@"&fontcolor=%d",colorInt];
        
    
    NSString* strurl =  [NSString stringWithFormat:@"http://%@/api/?pad.textUpload",[userdef stringForKey:@"api_address"]];
    strurl = [strurl stringByAppendingString: [@"&uuid=" stringByAppendingString: [userdef stringForKey: @"board_uuid"]]];
    strurl = [strurl stringByAppendingString: [@"&userid=" stringByAppendingString: [userdef stringForKey: @"userName"]]];
    
    sendText = [FileIO changeSymbolToFull:sendText];
    
    strurl = [strurl stringByAppendingString: [@"&text=" stringByAppendingString:sendText]];    
    strurl = [strurl stringByAppendingString:stringCoordinate];
    if(sourceHash != nil){
        strurl = [strurl stringByAppendingString: [@"&source=" stringByAppendingString: sourceHash]];
    }

    
    strurl = [strurl stringByReplacingOccurrencesOfString:@"\n" withString:@"\t"];
    
    //NSLog(@"%@",strurl);
    
    NSData* datastr = [FileIO str2data:strurl];
    strurl = [FileIO data2str:datastr];
    strurl = [strurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //NSLog(@"sendTextWithRect");
    NSData* result = [Network sendGetRequestBasicAuth:strurl];
    NSString* resultString = [FileIO data2str:result];
    resultString = [resultString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    resultString = [resultString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    //NSLog(@"%@",resultString);
    
    return resultString;
}




@end