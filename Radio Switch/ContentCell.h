//
//  ContentCell.h
//  Radio Switch
//
//  Created by Olga Dalton on 05/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentCell : UITableViewCell
{
    IBOutlet UIView *separatorView;
    
    IBOutlet UILabel *numberLabel;
    
    IBOutlet UILabel *cellTitleLabel;
    
    IBOutlet UILabel *lastPlayedLabel;
}

@property (nonatomic, retain) IBOutlet UIView *separatorView;
@property (nonatomic, retain) IBOutlet UILabel *numberLabel;

@property (nonatomic, retain) IBOutlet UILabel *cellTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *lastPlayedLabel;

@end
