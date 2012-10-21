//
//  UserSettingUtil.h
//  iSticky
//
//  Created by 高橋 勲 on 10/08/31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Validate.h"

/*!
 This class supports manage user name/password secure.
 Also this class provides wrap set/get of NSUserDefaults (text/number/object).
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
+ (void) setObjectWithKey:(NSString*)key object:(NSObject*)object;
/*! ユーザ名の取得 */
+ (NSString*) getUserNameWithService:(NSString*)serviceName;
+ (void) setUserName:(NSString*)userName service:(NSString*)serviceName;
/*! ユーザパスワードの取得 */
+ (NSString*) getUserPasswordWithService:(NSString*)serviceName;
+ (NSError*) setUserPassword:(NSString*)password service:(NSString*)serviceName;

@end
