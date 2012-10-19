//
//  Base64Util.m
//  UtilTest
//
//  Created by 高橋 勲 on 2012/10/19.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import "Base64Util.h"

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


@implementation Base64Util

// Base64にエンコードした文字列を生成する
+ (NSString *)stringEncodedWithBase64:(NSData*)str
{
    int            nState, nIndex, nLineCharCnt;
    unsigned    unCnt;
    const unsigned char    *pcRawData = [str bytes];
    unsigned    unLength   = [str length];
    
    NSMutableString* pstrResult = [NSMutableString string];
    nState         = 0;
    nLineCharCnt = 0;
    unCnt         = 0;
    while ( unCnt < unLength ) {
        switch ( nState ) {
            case 0:
                // バイトの先頭位置の場合
                // →先頭6bitを処理
                nIndex = (pcRawData[unCnt] >> 2) & 0x3F;
                break;
                
            case 1:
                // バイトの残り2bitと次のバイトの先頭4bitの場合
                nIndex = (pcRawData[unCnt] & 0x03) << 4;
                unCnt++;
                if ( unCnt < unLength ) {
                    // 次のバイトがある場合のみ
                    nIndex |= (pcRawData[unCnt] >> 4) & 0x0F;
                }
                break;
                
            case 2:
                // バイトの残り4bitと次のバイトの先頭2bitの場合
                nIndex = (pcRawData[unCnt] & 0x0F) << 2;
                unCnt++;
                if ( unCnt < unLength ) {
                    // 次のバイトがある場合のみ
                    nIndex |= (pcRawData[unCnt] >> 6) & 0x03;
                }
                break;
                
            case 3:
                // バイトの残り6bitの場合
                nIndex = pcRawData[unCnt] & 0x03F;
                unCnt++;
                break;
        }
        
        // 変換文字を符号化結果格納領域に設定
        char    cConvChar[2];
        cConvChar[0] = s_cBase64Tbl[nIndex];
        cConvChar[1] = '\0';
        [pstrResult appendString:[NSString stringWithCString:cConvChar encoding:NSASCIIStringEncoding]];
        nLineCharCnt++;
        if ( (nLineCharCnt % 76) == 0 ) {
            // 76文字毎の改行コード挿入
            [pstrResult appendString:s_pstrCRLF];
            nLineCharCnt = 0;
        }
        
        // 状態更新
        nState++;
        if ( nState > 3 ) {
            // 3byte区切りで元に戻る
            nState = 0;
        }
    }
    
    // Padding文字決定
    int    nPadCnt = 0;
    int    i;
    switch ( nState ) {
        case 1:
        case 2:
            // 1バイト目で終わった場合
            nPadCnt = 2;
            break;
        case 3:
            // 2バイト目で終わった場合
            nPadCnt = 1;
            break;
    }
    for ( i = 0; i < nPadCnt; i++ ) {
        [pstrResult appendString:s_pstrEqual];
        nLineCharCnt++;
        if ( (nLineCharCnt % 76) == 0 && i+1 < nPadCnt ) {
            // 76文字毎の改行コード挿入
            [pstrResult appendString:s_pstrCRLF];
            nLineCharCnt = 0;
        }
    }
    
    return pstrResult;
}


@end
