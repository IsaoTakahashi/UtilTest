//
//  UserSettingUtil.m
//  iSticky
//
//  Created by 高橋 勲 on 10/08/31.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserSettingUtil.h"
#import "SFHFKeychainUtils.h"

@implementation UserSettingUtil


+ (NSString*) getStringWithKey:(NSString*)key
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

+ (void) setStringWithKey:(NSString*)key value:(NSString*)value
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

+ (int) getIntegerWithKey:(NSString*)key
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

+ (void) setIntegerWithKey:(NSString*)key value:(int)value
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:value] forKey:key];
}

+ (NSObject*) getObjectWithKey:(NSString*)key
{
     return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (NSString*) getUserName
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"USERNAME"];
}

+ (NSString*) getUserPassword
{
    NSError *error;
    return [SFHFKeychainUtils getPasswordForUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"USERNAME"] andServiceName:@"Realation" error:&error];
}

+ (NSString*) getRealationServerAddress
{
    return @"http://tm-1031.sakura.ne.jp/realation/";// [[NSUserDefaults standardUserDefaults] stringForKey:@"imageServer_address"];
}

+ (int) getBackgroundGeoInfoState
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"GEOINFOSTATE"];
}

+ (void) setBackgroundGeoInfoState:(int)state
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:state] forKey:@"GEOINFOSTATE"];
}


@end