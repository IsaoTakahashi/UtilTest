//
//  AtoBtoViewController.m
//  UtilTest
//
//  Created by 高橋 勲 on 2012/10/23.
//  Copyright (c) 2012年 高橋 勲. All rights reserved.
//

#import "AtoBtoViewController.h"

@interface AtoBtoViewController ()

@end

@implementation AtoBtoViewController

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

@end
