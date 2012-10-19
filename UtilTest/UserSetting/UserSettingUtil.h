//
//  UserSettingUtil.h
//  iSticky
//
//  Created by 高橋 勲 on 10/08/31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 iStickyのユーザ情報を取得するためのクラス(ライブラリ)。
 UserDefaultsへのアクセサ(getter)として用いる。
 UserDefaultsに保存するもので、かつ色んなところから参照する可能性があるものが加わったら、
 適宜getterを追加していって下さい。
 */

@interface UserSettingUtil : NSObject {
}

/*! 任意のキーの値(文字列)を取得する */
+ (NSString*) getStringWithKey:(NSString*)key;
+ (void) setStringWithKey:(NSString*)key value:(NSString*)value;
/*! 任意のキーの値(数値)を取得する */
+ (int) getIntegerWithKey:(NSString*)key;
+ (void) setIntegerWithKey:(NSString*)key value:(int)value;
/*! 任意のキーの値(NSObject系)を取得する */
+ (NSObject*) getObjectWithKey:(NSString*)key;
/*! ユーザ名の取得 */
+ (NSString*) getUserName;
/*! ユーザパスワードの取得 */
+ (NSString*) getUserPassword;
/*! Realationサーバアドレスの取得 */
+ (NSString*) getRealationServerAddress;

+ (int) getBackgroundGeoInfoState;
+ (void) setBackgroundGeoInfoState:(int)state;
@end
