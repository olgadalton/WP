//
//  DoubleChoiceCell.m
//  Radio Switch
//
//  Created by Olga Dalton on 27/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import "DoubleChoiceCell.h"

@implementation DoubleChoiceCell

@synthesize firstChoiceButton, secondChoiceButton;

-(IBAction)firstChoice:(id)sender
{
    [self.firstChoiceButton setBackgroundImage:[UIImage imageNamed:@"selected_bg_blue.png"] forState:UIControlStateNormal];
     
    [self.secondChoiceButton setBackgroundImage:[UIImage imageNamed:@"header-middle.png"] forState:UIControlStateNormal];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey: @"pauseOnException"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(IBAction)secondChoice:(id)sender
{
    [self.secondChoiceButton setBackgroundImage:[UIImage imageNamed:@"selected_bg_blue.png"] forState:UIControlStateNormal];
    
    [self.firstChoiceButton setBackgroundImage:[UIImage imageNamed:@"header-middle.png"] forState:UIControlStateNormal];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey: @"pauseOnException"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
