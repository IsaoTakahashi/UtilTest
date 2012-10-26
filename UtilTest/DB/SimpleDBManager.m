//
//  SimpleDBManager.m
//  UtilTest
//
//  Created by 高橋 勲 on 2012/10/23.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import "SimpleDBManager.h"

static SimpleDBManager* singlton;

@interface SimpleDBManager()
- (SimpleDBManager*) init;
@end

@implementation SimpleDBManager

@synthesize connection;
@synthesize cache;

+ (SimpleDBManager *)getInstance {
    if (singlton == nil) {
        singlton = [[SimpleDBManager alloc] init];
        [singlton connect: @"navi.db"];
    }
    
    return singlton;
}

- (SimpleDBManager*) init {
    if(self = [super init]) {
        self.connection = nil;
        self.cache = [[NSMutableSet alloc] init];
    }
    
    return self;
}

//接続
//ファイルが既にあるかどうかチェックして、なければセットアップする
- (void) connect:(NSString *)dbname{
    NSString* dbpath = [self getDBFilePath:dbname];
    
    [self createEditableCopyOfDatabaseIfNeeded: dbname];
    
    self.connection = [FMDatabase databaseWithPath:dbpath];
    
    [self.connection open];
    if([self hadError]){
        NSLog(@"Could not open Database.");
    }
    
    //[self updateDB];
}

//DBファイルへのパスを取得
- (NSString *) getDBFilePath:(NSString *) dbname{
    return [FileUtil getPath: dbname subDir:@""];
}

//古いDBファイルへのパスを取得
- (NSString *) getOldDBFilePath:(NSString *) dbname{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:dbname];
}

//UpdateSQLのパスを取得
-(NSString *) getUpdateSQL:(NSString *) version{
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"sessionDBUpdate_%@.txt", version]];
}

//UpdateSQLがあるかどうか
-(BOOL) hasUpdateSQLFor:(NSString *) version{
    NSString *path = [self getUpdateSQL:version];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager isReadableFileAtPath: path];
}

//最新バージョンまでアップデートSQLを当てる
-(void) updateDB{
    [self beginTransaction];
    while([self updateDBWorker]){
    }
    [self commit];
}

//現在のバージョンからアップデート
-(BOOL) updateDBWorker{
    FMResultSet *rs = [self.connection executeQuery: @"SELECT version FROM dbinfo"];
    if([rs next]){
        NSString *version = [rs stringForColumn: @"version"];
        [rs close];
        NSError *error;
        version = [version stringByMatching: @"[0-9]+"];
        if([self hasUpdateSQLFor: version]){
            NSString *query = [NSString stringWithContentsOfFile:[self getUpdateSQL:version]
                                                        encoding: NSUTF8StringEncoding error: &error];
            NSArray *queries = [query componentsSeparatedByString:@";"];
            for(NSString *line in queries){
                [self.connection executeUpdate:line];
            }
            if([self hadError]){
                [self rollback];
                return false;
            }
            NSLog(@"database updated from %@", version);
            return true;
        }else{
            NSLog(@"database version is %@", version);
        }
    }
    [rs close];
    return false;
}

//DBファイルを作成
- (void)createEditableCopyOfDatabaseIfNeeded:(NSString *)dbname {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    //古いデータベースをコピーする
    NSString *writableOldDBPath = [self getOldDBFilePath:dbname];
    NSString *writableDBPath = [self getDBFilePath:dbname];
    
    //NSString *debugDBPath = [self getDBFilePath:@"debug.sqlite"];
    //[fileManager copyItemAtPath:writableDBPath toPath:debugDBPath error:&error];
    //[fileManager copyItemAtPath:debugDBPath toPath:writableDBPath error:&error];
    //[fileManager removeItemAtPath:writableDBPath error:&error];
    
    //すでにファイルがあれば処理しない。
    if([FileUtil existsFile:dbname subDir:@""]){
        return;
    }
    //昔の古いファイルがあれば消す
    if([fileManager isWritableFileAtPath: writableOldDBPath]){
        [fileManager removeItemAtPath:writableOldDBPath error:&error];
    }
    //デフォルトファイルをコピー
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbname];
    [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
}

//切断
- (void) disconnect{
    if([self isConnected]){
        [self.connection close];
    }
    self.connection = nil;
}

//接続されているかどうか
- (BOOL) isConnected{
    if(self.connection != nil){
        return YES;
    }
    return NO;
}

//トランザクションが開始されているかどうか
- (BOOL) isTransactionStarted{
    if([self isConnected] == NO){
        return NO;
    }
    return [self.connection inTransaction];
}

//トランザクション開始
- (void) beginTransaction{
    if([self isConnected]){
        [self.connection beginTransaction];
    }else{
        NSLog(@"Could not open Database.");
    }
}

//コミット
- (void) commit{
    if([self isConnected]){
        [self.connection commit];
    }else{
        NSLog(@"Could not open Database.");
    }
}

//ロールバック
- (void) rollback{
    if([self isConnected]){
        [self.connection rollback];
    }else{
        NSLog(@"Could not open Database.");
    }
}

//エラーチェック
- (BOOL) hadError{
    if(self.connection == nil){
        return true;
    }
    if ([self.connection hadError]) {
        NSLog(@"Err %d: %@", [self.connection lastErrorCode], [self.connection lastErrorMessage]);
        return true;
    }
    return false;
}

//ログをとるかどうかの設定を取得
- (BOOL) logging{
    return [self.connection traceExecution];
}

//ログをとるかどうかの設定
- (void) setLogging:(BOOL)logging{
    [self.connection setTraceExecution: logging];
}

//デバッグ用，バージョンを特定バージョンに戻す
- (void) setDatabaseVersionTo: (int)version{
    NSString *v = [NSString stringWithFormat:@"%d", version];
    [self beginTransaction];
    [self.connection executeQuery:[NSString stringWithFormat:@"UPDATE dbinfo SET version='%@'", v]];
    if([self hadError]){
        [self rollback];
    }
    [self commit];
}

@end
