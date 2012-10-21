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
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (int) getIntegerWithKey:(NSString*)key
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

+ (void) setIntegerWithKey:(NSString*)key value:(int)value
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:value] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSObject*) getObjectWithKey:(NSString*)key
{
     return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void) setObjectWithKey:(NSString*)key object:(NSObject*)object
{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString*) getUserNameWithService:(NSString*)serviceName
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%@_USERNAME",serviceName]];
}

+ (void) setUserName:(NSString *)userName service:(NSString *)serviceName
{
    //delete password for old user name
    NSError *error;
    NSString *oldUserName = [UserSettingUtil getUserNameWithService:serviceName];
    if(oldUserName != nil && ![oldUserName isEqualToString:userName]) {
        [SFHFKeychainUtils deleteItemForUsername:oldUserName andServiceName:serviceName error:&error];
    }
    
    [UserSettingUtil setStringWithKey:[NSString stringWithFormat:@"%@_USERNAME",serviceName] value:userName];
}

+ (NSString*) getUserPasswordWithService:(NSString*)serviceName
{
    NSString* userName = [UserSettingUtil getUserNameWithService:serviceName];
    if(userName == nil) {
        return nil;
    }
    
    NSError *error;
    return [SFHFKeychainUtils getPasswordForUsername:userName andServiceName:serviceName error:&error];
}

+ (NSError*) setUserPassword:(NSString*)password service:(NSString*)serviceName
{
    NSString* userName = [UserSettingUtil getUserNameWithService:serviceName];
    if([userName isEmpty]) {
        return nil;
    }
    
    NSError *error;
    [SFHFKeychainUtils storeUsername:userName andPassword:password forServiceName:serviceName updateExisting:YES error:&error];
    
    return error;
}

- (NSError*) deleteUserPassword:(NSString *)serviceName
{
    NSError *error;
    [SFHFKeychainUtils deleteItemForUsername:[UserSettingUtil getUserNameWithService:serviceName] andServiceName:serviceName error:&error];
    return error;
}


@end