//
//  ViewController.m
//  UtilTest
//
//  Created by 高橋 勲 on 2012/10/19.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import "ViewController.h"

static NSString* serviceName = @"test";

@interface ViewController ()

@end

@implementation ViewController
@synthesize userField;
@synthesize passField;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString* userName = [UserSettingUtil getUserName:serviceName];
    if(userName != nil) {
        NSLog(@"load username from UserDefaults");
        userField.text = userName;
        
        NSString* password = [UserSettingUtil getUserPassword:serviceName];
        if(password != nil) {
            NSLog(@"load password from Keychain");
            passField.text = password;
        }
    } else {
        userField.text = @"Please input your name";
    }

}

- (void)viewDidUnload
{
    [self setUserField:nil];
    [self setPassField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)inputUserName:(id)sender {
    [UserSettingUtil setUserName:((UITextField*)sender).text service:serviceName];
    NSLog(@"set user name: %@",[UserSettingUtil getUserName:serviceName]);
}

- (IBAction)inputPassword:(id)sender {
    
    [UserSettingUtil setUserPassword:((UITextField*)sender).text service:serviceName];
    NSLog(@"set password");
}
@end
