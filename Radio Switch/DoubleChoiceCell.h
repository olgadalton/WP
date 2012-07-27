//
//  DoubleChoiceCell.h
//  Radio Switch
//
//  Created by Olga Dalton on 27/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoubleChoiceCell : UITableViewCell
{
    IBOutlet UIButton *firstChoiceButton, *secondChoiceButton;
}

@property (nonatomic, retain) IBOutlet UIButton *firstChoiceButton, *secondChoiceButton;

-(IBAction)firstChoice:(id)sender;
-(IBAction)secondChoice:(id)sender;

@end
