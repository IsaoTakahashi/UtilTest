//
//  NetworkUtil.m
//  UtilTest
//
//  Created by 高橋 勲 on 2012/10/19.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import "NetworkUtil.h"


static NetworkUtil *network = nil;

@interface NetworkUtil()


@end



@implementation NetworkUtil

+ (NetworkUtil*) getInstance {
    if(network == nil){
        network = [[NetworkUtil alloc] init];
    }
    
    return network;
}


@end
