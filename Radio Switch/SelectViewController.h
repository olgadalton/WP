//
//  SelectViewController.h
//  Radio Switch
//
//  Created by Olga Dalton on 04/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StationsListViewController.h"

enum Section 
{
    StationsSegment = 0,
    ExceptionsSegment = 1
};

@interface SelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *tbView;
    
    IBOutlet StationsListViewController *stationSelectionList;
    
    IBOutlet UIButton *addStationButton;
    
    BOOL childItem;
    
    IBOutlet SelectViewController *settingsController;
    
    enum Section currentType;
    
    IBOutlet UISegmentedControl *segmentedControl;
    
    IBOutlet UIView *bgView;
}

@property (nonatomic, retain) IBOutlet UITableView *tbView;
@property (nonatomic, retain) IBOutlet StationsListViewController *stationSelectionList;
@property (nonatomic, retain) IBOutlet UIButton *addStationButton;
@property BOOL childItem;
@property (nonatomic, retain) IBOutlet SelectViewController *settingsController;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) IBOutlet UIView *bgView;

-(IBAction)addStation:(id)sender;

-(IBAction)segmentValueChanged:(id)sender;

@end
