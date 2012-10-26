//
//  FileIO.m
//  iPadTest_100326
//
//  Created by 高橋 勲 on 10/04/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileUtil.h"


//static NSString *dirName = @"root";

@interface FileUtil()
+ (NSString*) getRootDirectoryName;
+ (NSString*) getRootDirectoryPath;
@end

@implementation FileUtil

//文字列型からデータ型への変換メソッド
+ (NSData*)str2data:(NSString*)str {
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}

//データ型から文字列型への変換メソッド
+ (NSString*)data2str:(NSData*)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

// 指定したディレクトリ内のファイルパスの一覧を返す
+ (NSArray*) getFileList:(NSString*)subDirName
{
    NSString* dirPath = [FileUtil getPath:[FileUtil getRootDirectoryName] subDir:subDirName];
    
    return  [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
}

//適切なファイル名を返す
+ (NSString *)getPath:(NSString *)fileName subDir:(NSString *)subDir{
    
    NSString* userDir = [FileUtil getRootDirectoryPath];
    
    if(subDir)
    {
        [self makeDir:[FileUtil getRootDirectoryName] subDir:subDir];
        userDir = [userDir stringByAppendingPathComponent:subDir];
    }
    NSString* file = [userDir stringByAppendingPathComponent:fileName];
    return file;
}

//ファイルが存在するか
+ (BOOL)existsFile:(NSString*)fileName subDir:(NSString*)subDir{
    NSString* userDir = [FileUtil getRootDirectoryPath];
    if(subDir)
    {
        userDir = [userDir stringByAppendingPathComponent:subDir];
    }
    fileName=[userDir stringByAppendingPathComponent:fileName]; 
    return [[NSFileManager defaultManager] fileExistsAtPath:fileName];
}

//ディレクトリの生成メソッド(既にディレクトリが存在するなら何もしない)
+ (void)makeDir:(NSString*)dirName subDir:(NSString*)subDir{
    if ([FileUtil existsFile:dirName subDir:subDir]) return;
    
    NSArray* paths=NSSearchPathForDirectoriesInDomains(
                                                       NSDocumentDirectory,NSUserDomainMask,YES); 
    NSString* dir=[paths objectAtIndex:0]; 
    NSString* userDir = [dir stringByAppendingPathComponent:dirName];
    if(subDir)
    {
        userDir = [userDir stringByAppendingPathComponent:subDir];
    }
//    [[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];  <-Deprecated
    [[NSFileManager defaultManager] createDirectoryAtPath:userDir withIntermediateDirectories:YES attributes:nil error:NULL];
}

//ファイルの削除
+ (void)removeFile:(NSString*)fileName subDir:(NSString*)subDir{
    if (![FileUtil existsFile:fileName subDir:subDir]) return;

    NSString* userDir = [FileUtil getRootDirectoryPath];
    if(subDir)
    {
        userDir = [userDir stringByAppendingPathComponent:subDir];
    }
    fileName=[userDir stringByAppendingPathComponent:fileName]; 
    [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
}

//データ型の内容をファイルへ書き込むメソッド
+ (BOOL)data2file:(NSString*)fileName subDir:(NSString*)subDir data:(NSData*)data {
   
    NSString* userDir = [FileUtil getRootDirectoryPath];
    if(subDir)
    {
        [self makeDir:[FileUtil getRootDirectoryName] subDir:subDir];
        userDir = [userDir stringByAppendingPathComponent:subDir];
    }
    NSString* file = [userDir stringByAppendingPathComponent:fileName];
    return ([data writeToFile:file atomically:YES]);
}

//ファイルから読み込み、その内容をデータ型で返すメソッド
+ (NSData*)file2data:(NSString*)fileName subDir:(NSString*)subDir{

    NSString* userDir = [FileUtil getRootDirectoryPath];
    if(subDir != nil)
    {
        userDir = [userDir stringByAppendingPathComponent:subDir];
    }
    NSString* file = [userDir stringByAppendingPathComponent:fileName];
    return [[NSData alloc] initWithContentsOfFile:file];
}

//配列をアーカイブするメソッド
+(void) archiveArray:(NSMutableArray*)array fileName:(NSString*)fileName subDir:(NSString*)subDir
{
    
    NSString* userDir = [FileUtil getRootDirectoryPath];
    if(subDir != nil)
    {
        [self makeDir:[FileUtil getRootDirectoryName] subDir:subDir];
        userDir = [userDir stringByAppendingPathComponent:subDir];
    }
    NSString* filePath = [userDir stringByAppendingPathComponent:fileName];
    
    [NSKeyedArchiver archiveRootObject:array toFile:filePath];
}

//アーカイブから配列を読み出すメソッド
+(NSMutableArray*) arrayFromArchive:(NSString*)fileName subDir:(NSString*)subDir
{

    NSString* userDir = [FileUtil getRootDirectoryPath];
    if(subDir != nil)
    {
        userDir = [userDir stringByAppendingPathComponent:subDir];
    }
    NSString* filePath = [userDir stringByAppendingPathComponent:fileName];
    
    NSMutableArray* array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    return array;
}

#pragma mark -
#pragma mark private method

+ (NSString*) getRootDirectoryName {
    NSString* rootDirName = [UserSettingUtil getStringWithKey:@"ROOT_DIRECTORY_NAME"];
    if([rootDirName isEmpty]) {
        return @"root";
    }
    
    return rootDirName;
}

+ (NSString*) getRootDirectoryPath {
    NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dir = [path objectAtIndex:0];
    NSString* userDir = [dir stringByAppendingPathComponent:[FileUtil getRootDirectoryName]];
    
    return userDir;
}

@end
