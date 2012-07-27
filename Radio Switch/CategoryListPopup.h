//
//  TransactionDetailsPopup.h
//  UnitedTickets
//
//  Created by Eigen Lenk on 5/22/12.
//  Copyright (c) 2012 Finestmedia Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryListPopup : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIView * darkBackgroundView;
    IBOutlet UIView * contentView;
    
    BOOL viewLoaded;
    
    IBOutlet UITableView *tbView;
    
    int selectedSection;
    
    id delagate;
}

@property (nonatomic, readonly) BOOL viewLoaded;

@property (nonatomic, retain) IBOutlet UITableView *tbView;

@property int selectedSection;

@property (nonatomic, retain) id delagate;

- (void)animateIn;
- (void)animateOut;

- (IBAction)backgroudTouched:(id)sender;

@end
