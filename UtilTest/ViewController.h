//
//  ViewController.h
//  UtilTest
//
//  Created by 高橋 勲 on 2012/10/19.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSetting/UserSettingUtil.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *passField;
- (IBAction)inputUserName:(id)sender;
- (IBAction)inputPassword:(id)sender;

@end
