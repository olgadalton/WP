//
//  StationsListViewController.h
//  Radio Switch
//
//  Created by Olga Dalton on 05/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryListPopup.h"
#import "FixedTextField.h"
#import "BrowserViewController.h"

enum ViewType {
    CategoriesView = 0,
    ListView = 1,
    CustomView = 2,
    RecordedView = 3
    };

@interface StationsListViewController : UIViewController 
                                        <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UISearchBarDelegate>
{
    IBOutlet UITableView *tbView;
    
    NSInteger selectedSection;
    
    IBOutlet UISegmentedControl *viewSelector;
    
    enum ViewType currentViewType;
    
    IBOutlet CategoryListPopup *categoryListView;
    
    IBOutlet UIView *pickerMainView;
    IBOutlet UINavigationBar *pickerNavbar;
    IBOutlet UINavigationItem *pickerNavItem;
    
    BOOL pickerVisible;
    
    IBOutlet FixedTextField *stationNameField;
    IBOutlet FixedTextField *stationURLField;
    
    FixedTextField *currentTextField;
    
    BOOL editingInProcess;
    
    IBOutlet UIButton *addStationButton;
    IBOutlet BrowserViewController *analyzingBrowser;
    
    IBOutlet UISearchBar *searchBar;
    
    BOOL searching;
}

@property (nonatomic, retain) IBOutlet UITableView *tbView;

@property (nonatomic, retain) IBOutlet BrowserViewController *analyzingBrowser;

@property (nonatomic, retain) IBOutlet UISegmentedControl *viewSelector;

@property (nonatomic, retain) IBOutlet CategoryListPopup *categoryListView;

@property (nonatomic, retain) IBOutlet UIView *pickerMainView;
@property (nonatomic, retain) IBOutlet UINavigationBar *pickerNavbar;
@property (nonatomic, retain) IBOutlet UINavigationItem *pickerNavItem;

@property (nonatomic, retain) IBOutlet FixedTextField *stationNameField;
@property (nonatomic, retain) IBOutlet FixedTextField *stationURLField;
@property (nonatomic, retain) FixedTextField *currentTextField;

@property (nonatomic, retain) IBOutlet UIButton *addStationButton;

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;

-(IBAction)viewTypeChanged:(id)sender;
-(IBAction)categoryButtonPressed:(id)sender;

-(IBAction) addNewStation: (id) selector;

-(void) showBottomPopup;
-(void)dismissPicker;

-(IBAction)dismissKeyboard:(id)sender;
-(IBAction)editingDidStart:(id)sender;

-(void) urlCheckDone: (NSNumber *) result;

@end
