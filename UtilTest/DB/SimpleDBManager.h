//
//  SimpleDBManager.h
//  UtilTest
//
//  Created by 高橋 勲 on 2012/10/23.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FileUtil.h"
#import "RegexKitLite.h"

@interface SimpleDBManager : NSObject {
    @protected
    FMDatabase *connection;
    NSMutableSet *cache;
}
@property (nonatomic, retain) FMDatabase *connection;
@property (nonatomic, retain) NSMutableSet *cache;
@property (nonatomic, assign) BOOL logging;

+ (SimpleDBManager*) getInstance;

//DB周りのラッパ
- (void) connect:(NSString*)dbname;
- (void) disconnect;
- (BOOL) isConnected;
- (void) beginTransaction;
- (void) rollback;
- (void) commit;
- (BOOL) hadError;
- (BOOL) isTransactionStarted;
//SessionDB周り
- (NSString *) getDBFilePath:(NSString *) dbname;
- (NSString *) getOldDBFilePath:(NSString *) dbname;
- (BOOL) hasUpdateSQLFor:(NSString *) version;
- (void) updateDB;
- (BOOL) updateDBWorker;
- (void) createEditableCopyOfDatabaseIfNeeded:(NSString *)dbname;
- (void) setDatabaseVersionTo:(int)version;


@end
