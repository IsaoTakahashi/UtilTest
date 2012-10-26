//
//  NetworkViewController.m
//  UtilTest
//
//  Created by 高橋 勲 on 2012/10/21.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import "NetworkViewController.h"

@interface NetworkViewController ()

@end

@implementation NetworkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [FileUtil removeFile:@"text.txt" subDir:@"test"];
    
    if([FileUtil existsFile:@"text.txt" subDir:@"test"]) {
        NSLog(@"%@",[FileUtil data2str:[FileUtil file2data:@"text.txt" subDir:@"test"]]);
        NSLog(@"loaded from file");
    } else {
        SimpleNetwork* sn = [[SimpleNetwork alloc] init];
        sn.delegate = self;
        [sn sendGetRequest:[NSURL URLWithString:@"http://www.apple.com"] tag:@"google"];
        NSLog(@"loaded from web");
    } 
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark delegate
- (void) receiveResponseResult:(NSHTTPURLResponse *)responseHeader responseString:(NSString *)responseString tag:(NSString *)tag {
    NSLog(@"tag: %@",tag);
    NSLog(@"%@",responseString);
    [FileUtil data2file:@"text.txt" subDir:@"test" data:[FileUtil str2data:responseString]];
}

@end
