//
//  LiveViewController.m
//  Radio Switch
//
//  Created by Olga Dalton on 04/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import "LiveViewController.h"

@implementation LiveViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden: YES];
    [self.navigationController setNavigationBarHidden: NO];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [self.navigationController setNavigationBarHidden: YES];
    [self.navigationController setNavigationBarHidden: NO];
}

@end
