//
//  StationsListViewController.m
//  Radio Switch
//
//  Created by Olga Dalton on 05/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import "StationsListViewController.h"
#import "CustomCellBackgroundView.h"
#import "RequestsManager.h"
#import "HeaderCell.h"
#import "SmallContentCell.h"
#import "MoreCell.h"
#import "PreferencesManager.h"

@implementation StationsListViewController
@synthesize tbView, viewSelector, categoryListView;
@synthesize pickerNavbar, pickerNavItem, pickerMainView;
@synthesize stationNameField, stationURLField, currentTextField;
@synthesize addStationButton, analyzingBrowser, searchBar;

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationItem setTitle: NSLocalizedString(@"Stations", nil)];
    
    selectedSection = -10;
    
    if (currentViewType == CustomView) 
    {
        if ([[PreferencesManager sharedManager].userAddedStations count] == 0) 
        {
            [self.addStationButton setHidden: NO];
        }
        else
        {
            [self.addStationButton setHidden: YES];
        }
    }
    
    [self.tbView reloadData];
    
    [self.tbView setContentOffset:CGPointMake(0,40)];
}

-(IBAction) addNewStation: (id) selector
{
    if (!pickerVisible) 
    {
        UIActionSheet *actionSheet = [[[UIActionSheet alloc] 
                                       initWithTitle:NSLocalizedString(@"Please select how to add new station", nil) delegate:self 
                                       cancelButtonTitle:nil 
                                       destructiveButtonTitle:NSLocalizedString(@"Cancel", nil) 
                                       otherButtonTitles: NSLocalizedString(@"Enter URL", nil), 
                                       NSLocalizedString(@"Search with browser", nil), nil] autorelease];
        
        [actionSheet showFromTabBar: 
         ((AppDelegate *) [[UIApplication sharedApplication] 
                           delegate]).tabBarController.tabBar];
    }
}

-(void) showBottomPopup
{
    [self.pickerNavbar setTintColor: [UIColor blackColor]];
    [self.pickerNavItem setTitle: NSLocalizedString(@"Add new station", nil)];
    
    self.pickerNavItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(dismissPicker)] autorelease];
    
    self.pickerNavItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", nil) style:UIBarButtonItemStyleDone target:self action:@selector(saveAndDismiss)] autorelease];
    
    pickerVisible = YES;
    
    [self.pickerMainView removeFromSuperview];
    
    CGRect datePickerFrame = self.pickerMainView.frame;
    
    [self.pickerMainView setFrame: CGRectMake(0.0, self.view.frame.size.height, datePickerFrame.size.width, datePickerFrame.size.height)];
    
    [self.view addSubview: self.pickerMainView];
    
    [UIView beginAnimations:@"" context: NULL];
    [UIView setAnimationDuration: 0.3f];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
    
    [self.pickerMainView setFrame: CGRectMake(0.0, self.view.frame.size.height - datePickerFrame.size.height, datePickerFrame.size.width, datePickerFrame.size.height)];
    
    [UIView commitAnimations];          
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) 
    {
        [self showBottomPopup];
    }
    else if(buttonIndex == 2)
    {
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
        
        [self.navigationController pushViewController:self.analyzingBrowser animated:YES];
    }
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searching = YES;
    [self.tbView reloadData];
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if ([self.searchBar isFirstResponder]) 
    {
        [self.searchBar resignFirstResponder];
    }
    
    searching = NO;
    [self.tbView reloadData];
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([self.searchBar isFirstResponder]) 
    {
        [self.searchBar resignFirstResponder];
    }
    
    searching = YES;
    [self.tbView reloadData];
}

-(void) urlCheckDone: (NSNumber *) result
{
    BOOL isCorrect = [result boolValue];
    
    if (isCorrect  == YES)
    {
        [[PreferencesManager sharedManager] addStation: [NSDictionary dictionaryWithObjectsAndKeys:self.stationNameField.text, @"name", self.stationURLField.text, @"streamurl", nil]];
        
        [self dismissPicker];
    }
    else 
    {
        UIAlertView *errorAlert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"The url you entered is not correct!", nil) message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
        
        [errorAlert show];
    }
}
                                              
-(void) saveAndDismiss
{
    if (self.stationURLField.text.length && self.stationNameField.text.length) 
    {
        // Validate url
        
        NSString *enteredUrl = self.stationURLField.text;
        
        [[RequestsManager sharedManager] urlIsCorrect:enteredUrl andResultSelector:@selector(urlCheckDone:) andDelegate:self];
    }
    else
    {
        UIAlertView *errorAlert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please fill in all fields!", nil) message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
        
        [errorAlert show];
    }
}
   
-(IBAction)dismissKeyboard:(id)sender
{
    
    if ([sender isFirstResponder]) 
    {
        [sender resignFirstResponder];
        
        editingInProcess = NO;
        
        [self performSelector:@selector(scrollMeUp) withObject: nil afterDelay:0.0f];
    }
}

-(void) scrollMeUp
{
    if (!editingInProcess && pickerVisible) 
    {
        CGRect datePickerFrame = self.pickerMainView.frame;
        [UIView beginAnimations:@"" context: NULL];
        [UIView setAnimationDuration: 0.15f];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        
        [self.pickerMainView setFrame: CGRectMake(0.0, self.view.frame.size.height - datePickerFrame.size.height, datePickerFrame.size.width, datePickerFrame.size.height)];
        
        [UIView commitAnimations]; 
    }
}

-(IBAction)editingDidStart:(id)sender
{
    if (pickerVisible == NO) 
    {
        return;
    }
    
    self.currentTextField = sender;
    
    CGRect datePickerFrame = self.pickerMainView.frame;
    
    if (!editingInProcess) 
    {
        [UIView beginAnimations:@"" context: NULL];
        [UIView setAnimationDuration: 0.3f];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
        
        [self.pickerMainView setFrame: CGRectMake(0.0, 0.0f, datePickerFrame.size.width, datePickerFrame.size.height)];
        
        [UIView commitAnimations];
        
        editingInProcess = YES;
    }
}

-(void)dismissPicker
{
    if (pickerVisible == NO) 
    {
        return;
    }
    
    CGRect datePickerFrame = self.pickerMainView.frame;
    [UIView beginAnimations:@"" context: NULL];
    [UIView setAnimationDuration: 0.3f];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
    
    [self.pickerMainView setFrame: CGRectMake(0.0, self.view.frame.size.height, datePickerFrame.size.width, datePickerFrame.size.height)];
    
    [UIView commitAnimations];
    
    pickerVisible = NO;
    
    [self.tbView reloadData];
    
    if (currentViewType == CustomView) 
    {
        if ([[PreferencesManager sharedManager].userAddedStations count] == 0) 
        {
            [self.addStationButton setHidden: NO];
        }
        else
        {
            [self.addStationButton setHidden: YES];
        }
    }
    
    if (self.currentTextField && [self.currentTextField isFirstResponder]) 
    {
        [self.currentTextField resignFirstResponder];
    }
}

-(void) viewDidLoad
{
    [super viewDidLoad];
     
    [self.viewSelector setTitle: NSLocalizedString(@"Categories", nil) 
              forSegmentAtIndex: 0];
    
    [self.viewSelector setTitle: NSLocalizedString(@"List", nil) 
              forSegmentAtIndex: 1];
    
    [self.viewSelector setTitle: NSLocalizedString(@"Custom", nil) 
              forSegmentAtIndex: 2];
    
    [self.viewSelector setTitle: NSLocalizedString(@"Recorded", nil) 
              forSegmentAtIndex: 3];
    
    currentViewType = CategoriesView;
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewStation:)] autorelease];
    
    [self.addStationButton setTitle:NSLocalizedString(@"Add new station", nil) forState:UIControlStateNormal];
    
    [self.addStationButton setHidden: YES];
}

-(IBAction)viewTypeChanged:(id)sender
{
    searching = NO;
    currentViewType = ((UISegmentedControl *) sender).selectedSegmentIndex;
    [self.tbView reloadData];
    
    [self.addStationButton setHidden: YES];
    
    if (currentViewType == CustomView) 
    {
        if ([[PreferencesManager sharedManager].userAddedStations count] == 0) 
        {
            [self.addStationButton setHidden: NO];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (!searching && currentViewType == CustomView) 
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        [[PreferencesManager sharedManager] removeStationAtIndex: indexPath.row];
        [self.tbView reloadData];
        
        if (currentViewType == CustomView) 
        {
            if ([[PreferencesManager sharedManager].userAddedStations count] == 0) 
            {
                [self.addStationButton setHidden: NO];
            }
        }
        else
        {
            [self.addStationButton setHidden: YES];
        }
    }    
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0
        && currentViewType == ListView && !searching)
    {
        // Header cell
        
        static NSString *cellIdentifier = @"HeaderCell";
        
        HeaderCell *headerCell = (HeaderCell *)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        
        if (headerCell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HeaderCell" owner:self options:nil];
            
            id firstObject = [topLevelObjects objectAtIndex: 0];
            
            if ([firstObject isKindOfClass: [HeaderCell class]])
            {
                headerCell = firstObject;
            }
            else 
            {
                headerCell = [topLevelObjects objectAtIndex: 1];
            }
            
            [headerCell setBackgroundView: nil];
            [headerCell setBackgroundColor: [UIColor clearColor]];
        }
        
        if ([[RequestsManager sharedManager].allData count] > indexPath.section
            && [[RequestsManager sharedManager].allData objectAtIndex: indexPath.section]) 
        {
            headerCell.cellTitleLabel.text = [[[RequestsManager sharedManager].allData objectAtIndex: indexPath.section] objectForKey: @"name"];
        }
        
        return headerCell;
    }
    else if((((indexPath.section == selectedSection || indexPath.row != 3) 
             && currentViewType == ListView) 
            || (currentViewType == CategoriesView 
                && indexPath.section == selectedSection)) && !searching)
    {
        /// Content cells start
        
        SmallContentCell *contentCell = nil;
        
        NSString *cellToLoad = nil;
        
        cellToLoad = @"SmallContentCell";
        
        NSString *cellIdentifier = cellToLoad;
        
        contentCell = (SmallContentCell *)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        
        if (contentCell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellToLoad owner:self options:nil];
            
            id firstObject = [topLevelObjects objectAtIndex: 0];
            
            if ([firstObject isKindOfClass: [SmallContentCell class]])
            {
                contentCell = firstObject;
            }
            else 
            {
                contentCell = [topLevelObjects objectAtIndex: 1];
            }
        }
        
        CustomCellBackgroundView *bgView = [[[CustomCellBackgroundView alloc] initWithFrame:contentCell.frame gradientTop:[UIColor colorWithRed:0.3882 green:0.7373 blue:0.9765 alpha:1.0f] andBottomColor:[UIColor colorWithRed:0.3412 green:0.5843 blue:0.8902 alpha:1.0f] andBorderColor:[UIColor lightGrayColor]] autorelease];
        
        if (indexPath.row == [self tableView:self.tbView numberOfRowsInSection:indexPath.section] - 1) 
        {
            [contentCell.separatorView setHidden: YES];
            bgView.position = CustomCellBackgroundViewPositionBottom;
        }
        else
        {
            [contentCell.separatorView setHidden: NO];
            bgView.position = CustomCellBackgroundViewPositionMiddle;
        }
        
        if ([[RequestsManager sharedManager].allData count] > indexPath.section
            && [[[[RequestsManager sharedManager].allData objectAtIndex:indexPath.section] objectForKey: @"stations"] count] > indexPath.row) 
        {
            NSDictionary *station = [[[[RequestsManager sharedManager].allData 
                                       objectAtIndex:indexPath.section] objectForKey: @"stations"]
                                     objectAtIndex: (currentViewType == ListView) ? indexPath.row - 1
                                                                                    : indexPath.row];
            
            contentCell.cellTitleLabel.text = [station objectForKey: @"name"];
            
            contentCell.countryLabel.text = NSLocalizedString(@"Unknown country", nil);
            
            if ([station objectForKey: @"country"]) 
            {
                NSString *country = [[NSLocale currentLocale] 
                                     displayNameForKey:NSLocaleCountryCode 
                                     value:[station objectForKey:@"country"]];
                
                if (country) 
                {
                    contentCell.countryLabel.text = country;
                }
                else
                {
                    contentCell.countryLabel.text = [station objectForKey: @"country"];
                }
            }
            
            contentCell.kbpsLabel.text = [station objectForKey: @"bitrate"];
        }
        
        contentCell.selectedBackgroundView = bgView;
        
        return contentCell;
    }
    else if(currentViewType == ListView && !searching)
    {
        static NSString *cellIdentifier = @"MoreCell";
        
        MoreCell *moreCell = (MoreCell *)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        
        if (moreCell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MoreCell" owner:self options:nil];
            
            id firstObject = [topLevelObjects objectAtIndex: 0];
            
            if ([firstObject isKindOfClass: [MoreCell class]])
            {
                moreCell = firstObject;
            }
            else 
            {
                moreCell = [topLevelObjects objectAtIndex: 1];
            }
        }
        
        CustomCellBackgroundView *bgView = [[[CustomCellBackgroundView alloc] initWithFrame:moreCell.frame gradientTop:[UIColor colorWithRed:0.3882 green:0.7373 blue:0.9765 alpha:1.0f] andBottomColor:[UIColor colorWithRed:0.3412 green:0.5843 blue:0.8902 alpha:1.0f] andBorderColor:[UIColor lightGrayColor]] autorelease];
        
        bgView.position = CustomCellBackgroundViewPositionBottom;
        moreCell.selectedBackgroundView = bgView;
        
        moreCell.cellTitleLabel.text = NSLocalizedString(@"More....", nil);
        
        return moreCell;
    }
    else if(currentViewType == CustomView || searching)
    {
        static NSString *cellIdentifier = @"SmallContentCell";
        
        SmallContentCell *stationCell = (SmallContentCell *)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        
        if (stationCell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SmallContentCell" owner:self options:nil];
            
            id firstObject = [topLevelObjects objectAtIndex: 0];
            
            if ([firstObject isKindOfClass: [SmallContentCell class]])
            {
                stationCell = firstObject;
            }
            else 
            {
                stationCell = [topLevelObjects objectAtIndex: 1];
            }
        }
        
        CustomCellBackgroundView *bgView = [[[CustomCellBackgroundView alloc] initWithFrame:stationCell.frame gradientTop:[UIColor colorWithRed:0.3882 green:0.7373 blue:0.9765 alpha:1.0f] andBottomColor:[UIColor colorWithRed:0.3412 green:0.5843 blue:0.8902 alpha:1.0f] andBorderColor:[UIColor lightGrayColor]] autorelease];
        
        stationCell.selectedBackgroundView = bgView;
        
        [stationCell.separatorView setHidden: NO];
        
        if (!searching) 
        {
            stationCell.cellTitleLabel.text = [[[PreferencesManager sharedManager].userAddedStations 
                                                objectAtIndex:indexPath.row] 
                                               objectForKey: @"name"];
            
            stationCell.countryLabel.text = [[[PreferencesManager sharedManager].userAddedStations 
                                              objectAtIndex:indexPath.row] 
                                             objectForKey: @"streamurl"];
            
            if ([[PreferencesManager sharedManager].userAddedStations count] == 1) 
            {
                bgView.position = CustomCellBackgroundViewPositionSingle;
                [stationCell.separatorView setHidden: YES];
            }
            else if(indexPath.row == 0)
            {
                bgView.position = CustomCellBackgroundViewPositionTop;
            }
            else if(indexPath.row == [[PreferencesManager sharedManager].userAddedStations count] - 1)
            {
                bgView.position = CustomCellBackgroundViewPositionBottom;
                [stationCell.separatorView setHidden: YES];
            }
            else
            {
                bgView.position = CustomCellBackgroundViewPositionMiddle;
            }
        }
        else
        {
            NSArray *searchResults = nil;
            
            if (currentViewType == CustomView) 
            {
                searchResults = [[RequestsManager sharedManager] searchForTermInUserStations: self.searchBar.text];
            }
            else
            {
                searchResults = [[RequestsManager sharedManager] searchResultsForTerm: self.searchBar.text];
            }
            
            stationCell.cellTitleLabel.text = [[searchResults 
                                                objectAtIndex:indexPath.row] 
                                               objectForKey: @"name"];
            
            stationCell.countryLabel.text = [[searchResults 
                                              objectAtIndex:indexPath.row] 
                                             objectForKey: @"streamurl"];
            
            if ([searchResults count] == 1) 
            {
                bgView.position = CustomCellBackgroundViewPositionSingle;
                [stationCell.separatorView setHidden: YES];
            }
            else if(indexPath.row == 0)
            {
                bgView.position = CustomCellBackgroundViewPositionTop;
            }
            else if(indexPath.row == [searchResults count] - 1)
            {
                bgView.position = CustomCellBackgroundViewPositionBottom;
                [stationCell.separatorView setHidden: YES];
            }
            else
            {
                bgView.position = CustomCellBackgroundViewPositionMiddle;
            }
        }
        
        stationCell.kbpsLabel.text = nil;
        
        return stationCell;
    }
    else
    {
        return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier: @"Empty"] autorelease];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (searching) 
    {
        return 1;
    }
    else
    {
        if (currentViewType == ListView
            || currentViewType == CategoriesView) 
        {
            return [[RequestsManager sharedManager].allData count];
        }
        else if(currentViewType == CustomView)
        {
            return 1;
        } 
    }
    
    return 0;
}

-(IBAction)categoryButtonPressed:(id)sender
{
    int tag = [sender tag];
    tag %= 900;
    selectedSection = tag;
    
    self.categoryListView.selectedSection = selectedSection;
    self.categoryListView.delagate = self;
    
    [[((AppDelegate *)[[UIApplication sharedApplication] delegate]) window] 
                                        addSubview: self.categoryListView.view];
    
    [self.categoryListView animateIn];
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (currentViewType == CategoriesView && !searching) 
    {
        UIView *headerView = [[[UIView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, self.tbView.frame.size.width, self.tbView.frame.size.height)] autorelease];
        
        [headerView setBackgroundColor: [UIColor clearColor]];
        
        UIButton *headerButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [headerButton setFrame: CGRectMake(10.0f, 2.0f + (section == 0 ? 4.0f : 0.0f), 300.0f, 44.0f)]; 
        
        [headerButton addTarget:self action:@selector(categoryButtonPressed:) 
               forControlEvents:UIControlEventTouchUpInside];
        
        [headerButton setBackgroundImage:[UIImage imageNamed:@"cat_cell_bg.png"] forState:UIControlStateNormal];
        headerButton.tag = 900 + section;
        
        [headerView addSubview: headerButton];
        
        UILabel *headerTitleLabel = [[[UILabel alloc] initWithFrame: CGRectMake(50.0f, 12.0f, 200.0f, 21.0f)] autorelease];
        
        [headerTitleLabel setFont: [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:18.0f]];
        [headerTitleLabel setTextColor: [UIColor darkGrayColor]];
        [headerTitleLabel setBackgroundColor: [UIColor clearColor]];
        
        if (section < [[RequestsManager sharedManager].allData count]) 
        {
            [headerTitleLabel setText: [[[RequestsManager sharedManager].allData objectAtIndex: section] objectForKey: @"name"]];
            
            [headerButton addSubview: headerTitleLabel];
        }
        
        return headerView;
    }
    else
    {
        UIView *transparentView = [[[UIView alloc] initWithFrame: 
                                    CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 
                                               [self tableView: self.tbView heightForHeaderInSection:section])] autorelease];
        
        [transparentView setBackgroundColor: [UIColor clearColor]];
        
        return transparentView;
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (currentViewType == ListView) 
    {
        if (section == selectedSection) 
        {
            if ([[RequestsManager sharedManager].allData count] > section 
                && [[RequestsManager sharedManager].allData objectAtIndex: section]) 
            {
                if (searching) 
                {
                    NSArray *searchResults = [[RequestsManager sharedManager] searchResultsForTerm: self.searchBar.text];
                    
                    return [searchResults count];
                }
                else
                {
                    NSArray *stations = [[[RequestsManager sharedManager].allData objectAtIndex: section] objectForKey:@"stations"];
                    
                    return [stations count] + 1;
                }
            }
            
            return 0;
        }
        else
        {
            int minCount = 4;
            
            if ([[RequestsManager sharedManager].allData count] > section 
                && [[RequestsManager sharedManager].allData objectAtIndex: section]) 
            {
                
                if (searching) 
                {
                    NSArray *searchResults = [[RequestsManager sharedManager] searchResultsForTerm: self.searchBar.text];
                    
                    return [searchResults count];
                }
                else
                {
                    NSArray *stations = [[[RequestsManager sharedManager].allData objectAtIndex: section] objectForKey:@"stations"];
                    
                    minCount = [stations count] + 2;
                    
                    return MIN(4, minCount);
                }
                
            }
        }
    }
    else if(currentViewType == CategoriesView)
    {
        if (searching) 
        {
            NSArray *searchResults = [[RequestsManager sharedManager] searchResultsForTerm: self.searchBar.text];
            
            return [searchResults count];
        }
        else
        {
            return 0;
        }
    }
    else if(currentViewType == CustomView)
    {
        if (searching) 
        {
            NSArray *results = [[RequestsManager sharedManager] searchForTermInUserStations: self.searchBar.text];
            return [results count];
        }
        else
        {
            return [[PreferencesManager sharedManager].userAddedStations count];
        }
    }
    
    return 0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (searching) 
    {
        return 55.0f;
    }
    else
    {
        if (currentViewType == ListView) 
        {
            if (indexPath.row == 0 || 
                (indexPath.row == [self tableView:self.tbView numberOfRowsInSection: indexPath.section] - 1
                 && indexPath.section != selectedSection && indexPath.row == 3)) 
            {
                return 32.0f;
            }
            else
            {
                return 55.0f;
            }
        }
        else if(currentViewType == CategoriesView 
                || currentViewType == CustomView)
        {
            return 55.0f;
        }
    }
    
    return 44.0f;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tbView deselectRowAtIndexPath:indexPath animated: YES];
    
    if (currentViewType == ListView) 
    {
        if (indexPath.row == 3 && indexPath.section != selectedSection) 
        {
            selectedSection = -10;
            
            [self.tbView reloadData];
            
            selectedSection = indexPath.section;
            
            NSMutableArray *paths = [NSMutableArray array];
            
            for (int i = indexPath.row; i < 
                 [self tableView:self.tbView 
           numberOfRowsInSection: indexPath.section] - 1; i++)
            {
                [paths addObject: [NSIndexPath indexPathForRow:i inSection:indexPath.section]];
            }
            
            if ([paths count]) 
            {
                [self.tbView beginUpdates];
                
                [self.tbView insertRowsAtIndexPaths:paths withRowAnimation: UITableViewRowAnimationFade];
                
                [self.tbView endUpdates];
                
                [self.tbView performSelector:
                 @selector(reloadData) 
                                  withObject:nil afterDelay:0.5f];
            }
            else
            {
                [self.tbView reloadData];
            }
        }
    }
    
    NSDictionary *station = nil;
    
    if (currentViewType == ListView) 
    {
        if (indexPath.row != 0 && !(indexPath.row == 3 && indexPath.section == selectedSection)) 
        {
            station = [[[[RequestsManager sharedManager].allData 
                            objectAtIndex: indexPath.section] objectForKey: @"stations"] 
                            objectAtIndex: indexPath.row - 1];
        }
    }
    else if(currentViewType == CustomView)
    {
        station = [[PreferencesManager sharedManager].userAddedStations objectAtIndex: indexPath.row];
    }
    
    if (station) 
    {
        if ([[PreferencesManager sharedManager].userSelectedStations count] > [PreferencesManager sharedManager].indexToAdd) 
        {
            [[PreferencesManager sharedManager].userSelectedStations replaceObjectAtIndex:[PreferencesManager sharedManager].indexToAdd withObject: station];
        }
        else
        {
            [[PreferencesManager sharedManager].userSelectedStations addObject: station];
        }
        
        [[PreferencesManager sharedManager] saveChanges];
        
        [self.navigationController popViewControllerAnimated: YES];
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (currentViewType == ListView) 
    {
        if (section != [[RequestsManager sharedManager].allData count]) 
        {
            return 3.0f;
        }
    }
    else if(currentViewType == CategoriesView)
    {
        return 1.0f;
    }
    
    return 10.0f;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (currentViewType == ListView) 
    {
        if (section) 
        {
            return 5.0f;
        }
    }
    else if(currentViewType == CategoriesView && !searching)
    {
        if (!section) 
        {
            return 52.0f;
        }
        return 48.0f;
    }
    
    return 10.0f;
}

@end
