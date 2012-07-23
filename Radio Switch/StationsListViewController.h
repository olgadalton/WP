//
//  StationsListViewController.h
//  Radio Switch
//
//  Created by Olga Dalton on 05/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryListPopup.h"

enum ViewType {
    CategoriesView = 0,
    ListView = 1,
    CustomView = 2,
    RecordedView = 3
    };

@interface StationsListViewController : UIViewController 
                                        <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
    IBOutlet UITableView *tbView;
    
    NSInteger selectedSection;
    
    IBOutlet UISegmentedControl *viewSelector;
    
    enum ViewType currentViewType;
    
    IBOutlet CategoryListPopup *categoryListView;
}

@property (nonatomic, retain) IBOutlet UITableView *tbView;

@property (nonatomic, retain) IBOutlet UISegmentedControl *viewSelector;

@property (nonatomic, retain) IBOutlet CategoryListPopup *categoryListView;

-(IBAction)viewTypeChanged:(id)sender;
-(IBAction)categoryButtonPressed:(id)sender;

-(void) addNewStation;

@end
