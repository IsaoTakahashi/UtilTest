//
//  FileIO.h
//  iPadTest_100326
//
//  Created by 高橋 勲 on 10/04/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserSettingUtil.h"

@interface FileUtil : NSObject {

}

//文字列型からデータ型への変換メソッド
+ (NSData*)str2data:(NSString*)str;
//データ型から文字列型への変換メソッド
+ (NSString*)data2str:(NSData*)data;

// 指定したディレクトリ内のファイルパスの一覧を返す
+ (NSArray*) getFileList:(NSString*)dirName;
//適切なファイル名を返す
+ (NSString *)getPath:(NSString *)fileName subDir:(NSString *)subDir;

//ファイルが存在するか
+ (BOOL)existsFile:(NSString*)fileName subDir:(NSString*)subDir;
//ディレクトリの生成メソッド(既にディレクトリが存在するなら何もしない)
+ (void)makeDir:(NSString*)dirName subDir:(NSString*)subDir;
//ファイルの削除
+ (void)removeFile:(NSString*)fileName subDir:(NSString*)subDir;
//データ型の内容をファイルへ書き込むメソッド
+ (BOOL)data2file:(NSString*)fileName subDir:(NSString*)subDir data:(NSData*)data;
//ファイルから読み込み、その内容をデータ型で返すメソッド
+ (NSData*)file2data:(NSString*)fileName subDir:(NSString*)subDir;

//配列をアーカイブするメソッド
+(void) archiveArray:(NSMutableArray*)array fileName:(NSString*)fileName subDir:(NSString*)subDir;
//アーカイブから配列を読み出すメソッド
+(NSMutableArray*) arrayFromArchive:(NSString*)fileName subDir:(NSString*)subDir;

@end
