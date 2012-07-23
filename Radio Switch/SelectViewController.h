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
    StationSection = 0,
    ExceptionsSection = 1
};

@interface SelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView *tbView;
    
    IBOutlet StationsListViewController *stationSelectionList;
}

@property (nonatomic, retain) IBOutlet UITableView *tbView;
@property (nonatomic, retain) IBOutlet StationsListViewController *stationSelectionList;

@end
