//
//  SmallContentCell.h
//  Radio Switch
//
//  Created by Olga Dalton on 20/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmallContentCell : UITableViewCell
{
    IBOutlet UILabel *cellTitleLabel;
    IBOutlet UILabel *countryLabel;
    IBOutlet UILabel *kbpsLabel;
    
    IBOutlet UIView *separatorView;
}

@property (nonatomic, retain) IBOutlet UILabel *cellTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *countryLabel;
@property (nonatomic, retain) IBOutlet UILabel *kbpsLabel;
@property (nonatomic, retain) IBOutlet UIView *separatorView;

@end
