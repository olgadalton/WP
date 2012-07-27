//
//  SelectViewController.m
//  Radio Switch
//
//  Created by Olga Dalton on 04/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import "SelectViewController.h"
#import "HeaderCell.h"
#import "ContentCell.h"
#import "CustomCellBackgroundView.h"
#import "PreferencesManager.h"
#import "MoreCell.h"
#import "ChoiceCell.h"
#import "DoubleChoiceCell.h"
#import "SmallContentCell.h"

@implementation SelectViewController

@synthesize tbView, stationSelectionList, addStationButton, childItem;
@synthesize settingsController, segmentedControl, bgView;


-(void) viewDidLoad
{
    [super viewDidLoad];
}

-(void) showSettings
{
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStyleBordered target:nil action:NULL] autorelease];
    
    self.settingsController.childItem = YES;
    [self.navigationController pushViewController:self.settingsController animated:YES];
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    if (!childItem) 
    {
        [self.navigationItem setTitle: NSLocalizedString(@"Select streams", nil)];
    }
    else
    {
        [self.navigationItem setTitle: NSLocalizedString(@"Settings", nil)];
    }
    
    [self.tbView reloadData];
    
    if ([[PreferencesManager sharedManager].userSelectedStations count] == 0) 
    {
        [self.addStationButton setHidden:NO];
    }
    else
    {
        [self.addStationButton setHidden:YES];
    }
    
    [self.addStationButton setTitle:NSLocalizedString(@"Select station", nil) forState: UIControlStateNormal];
    
    if (!childItem) 
    {
        [self.navigationItem setLeftBarButtonItem: [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings", nil) style:UIBarButtonItemStyleBordered target:self action: @selector(showSettings)] autorelease]];
        
        [self.navigationItem setRightBarButtonItem: [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addStation:)] autorelease]];
    }
    
    [self.segmentedControl setTitle: NSLocalizedString(@"Preferences", nil) forSegmentAtIndex: 0];
    [self.segmentedControl setTitle: NSLocalizedString(@"Exceptions", nil) forSegmentAtIndex: 1];
    
    if (childItem) 
    {
        [self.bgView setHidden: YES];
        [self.segmentedControl setHidden: YES];
        
        [self.tbView setFrame: CGRectMake(0.0f, 0.0f, 320.0f, 343.0f + 44.0f)];
    }
    else
    {
        [self.bgView setHidden: NO];
        [self.segmentedControl setHidden: NO];
        
        [self.tbView setFrame: CGRectMake(0.0f, 44.0f, 320.0f, 343.0f)];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!childItem && currentType == StationsSegment) 
    {
        return [[PreferencesManager sharedManager].userSelectedStations count] ?
                [[PreferencesManager sharedManager].userSelectedStations count] + 1 : 0;
    }
    else if(!childItem && currentType == ExceptionsSegment)
    {
        return [[PreferencesManager sharedManager].songExceptions count] ? 
                [[PreferencesManager sharedManager].songExceptions count] + 1 : 0;
    }
    else if(section == 0 && childItem)
    {
        return 3;
    }
    
    return 0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) 
    {
        return 32.0f;
    }
    else if(!childItem && currentType == StationsSegment)
    {
        return 60.0f;
    }
    else if(!childItem && currentType == ExceptionsSegment)
    {
        return 55.0f;
    }
    else
    {
        return 44.0f;
    }
    
    return 0.0f;
}

//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    if ([[PreferencesManager sharedManager].userSelectedStations count] 
//                && section == 0 && !childItem && currentType == StationsSegment) 
//    {
//        UIView *footerView = [[[UIView alloc] initWithFrame: CGRectMake(0, 0, 320.0f, 60.0f)] autorelease];
//        
//        UIButton *addButton = [UIButton buttonWithType: UIButtonTypeCustom];
//        
//        [addButton setFrame: CGRectMake(8.0f, 6.0f, 303.0f, 39.0f)];
//        
//        [addButton setTitle:NSLocalizedString(@"Add station", nil) forState: UIControlStateNormal];
//        
//        [addButton setBackgroundImage:[UIImage imageNamed: @"grayBtn.png"] forState:UIControlStateNormal];
//        
//        [addButton setTitleColor:[UIColor darkTextColor] forState: UIControlStateNormal];
//        [addButton setTitleColor:[UIColor darkTextColor] forState: UIControlStateHighlighted];
//        [addButton setTitleColor:[UIColor darkTextColor] forState: UIControlStateSelected];
//        
//        [addButton.titleLabel setFont: [UIFont boldSystemFontOfSize: 15.0f]];
//        
//        [addButton addTarget:self action:@selector(addStationToList) forControlEvents:UIControlEventTouchUpInside];
//        
//        [footerView addSubview: addButton];
//        
//        return footerView;
//    }
//    else
//    {
//        return nil;
//    }
//}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([[PreferencesManager sharedManager].userSelectedStations count] && section == 0
            && currentType == StationsSegment) 
    {
        return 60.0f;
    }
    else
    {
        return 5.0f;
    }
}

-(void) addStationToList
{
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
    
    [PreferencesManager sharedManager].indexToAdd = [[PreferencesManager sharedManager].userSelectedStations count];
    
    [self.navigationController pushViewController:self.stationSelectionList animated:YES];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
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
        
        if (currentType == StationsSegment) 
        {
            headerCell.cellTitleLabel.text = NSLocalizedString(@"Preferences", nil);
        }
        else
        {
            headerCell.cellTitleLabel.text = NSLocalizedString(@"Exceptions", nil);
        }
        
        return headerCell;
    }
    else if(!childItem && currentType == StationsSegment)
    {
        /// Content cells start
        
        ContentCell *contentCell = nil;
        
        NSString *cellToLoad = nil;
        
        cellToLoad = @"ContentCell";
        
        NSString *cellIdentifier = cellToLoad;
        
        contentCell = (ContentCell *)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        
        if (contentCell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellToLoad owner:self options:nil];
            
            id firstObject = [topLevelObjects objectAtIndex: 0];
            
            if ([firstObject isKindOfClass: [ContentCell class]])
            {
                contentCell = firstObject;
            }
            else 
            {
                contentCell = [topLevelObjects objectAtIndex: 1];
            }
        }
        
        CustomCellBackgroundView *bgView = [[[CustomCellBackgroundView alloc] initWithFrame:contentCell.frame gradientTop:[UIColor colorWithRed:0.3882 green:0.7373 blue:0.9765 alpha:1.0f] andBottomColor:[UIColor colorWithRed:0.3412 green:0.5843 blue:0.8902 alpha:1.0f] andBorderColor:[UIColor lightGrayColor]] autorelease];
        
        contentCell.numberLabel.text = [NSString stringWithFormat: @"%d", indexPath.row];
        
        if(indexPath.row == [[PreferencesManager sharedManager].userSelectedStations count])
        {
            [contentCell.separatorView setHidden: YES];
            bgView.position = CustomCellBackgroundViewPositionBottom;
        }
        else 
        {
            [contentCell.separatorView setHidden: NO];
            bgView.position = CustomCellBackgroundViewPositionMiddle;
        }
        
        NSDictionary *station = [[PreferencesManager sharedManager].userSelectedStations objectAtIndex: indexPath.row - 1];
        
        contentCell.cellTitleLabel.text = [station objectForKey: @"name"];
        contentCell.lastPlayedLabel.text = [station objectForKey: @"streamurl"];
        
        contentCell.selectedBackgroundView = bgView;
        
        return contentCell;
    }
    else if(!childItem && currentType == ExceptionsSegment)
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
            
            stationCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (indexPath.row == [[PreferencesManager sharedManager].songExceptions count]) 
        {
            [stationCell.separatorView setHidden: YES];
        }
        else
        {
            [stationCell.separatorView setHidden: NO];
        }
        
        NSDictionary *song = [[PreferencesManager sharedManager].songExceptions objectAtIndex: indexPath.row - 1];
        
        stationCell.cellTitleLabel.text = [song objectForKey: @"name"];
        stationCell.countryLabel.text = [song objectForKey: @"singer"];
        stationCell.kbpsLabel.text = nil;
        
        return stationCell;
    }
    else if(childItem)
    {
        static NSString *cellIdentifier = @"ChoiceCell";
        
        ChoiceCell *choiceCell = (ChoiceCell *)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        
        if (choiceCell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ChoiceCell" owner:self options:nil];
            
            id firstObject = [topLevelObjects objectAtIndex: 0];
            
            if ([firstObject isKindOfClass: [ChoiceCell class]])
            {
                choiceCell = firstObject;
            }
            else 
            {
                choiceCell = [topLevelObjects objectAtIndex: 1];
            }
        }
        
        CustomCellBackgroundView *bgView = [[[CustomCellBackgroundView alloc] initWithFrame:choiceCell.frame gradientTop:[UIColor colorWithRed:0.3882 green:0.7373 blue:0.9765 alpha:1.0f] andBottomColor:[UIColor colorWithRed:0.3412 green:0.5843 blue:0.8902 alpha:1.0f] andBorderColor:[UIColor lightGrayColor]] autorelease];
        
        choiceCell.selectedBackgroundView = bgView;
        
        if (indexPath.row == 1) 
        {
            choiceCell.cellTitleLabel.text = NSLocalizedString(@"Detect and skip ads", nil);
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey: @"skipAds"]) 
            {
                choiceCell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                choiceCell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            bgView.position = CustomCellBackgroundViewPositionMiddle;
        }
        else if(indexPath.row == 2)
        {
            choiceCell.cellTitleLabel.text = NSLocalizedString(@"Change station on exception", nil);
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey: @"pauseOnException"]) 
            {
                choiceCell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                choiceCell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            bgView.position = CustomCellBackgroundViewPositionBottom;
        }
        
        return choiceCell;
        //        else if(indexPath.row == 2)
        //        {
        //            static NSString *cellIdentifier = @"DoubleChoiceCell";
        //            
        //            DoubleChoiceCell *choiceCell = (DoubleChoiceCell *)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
        //            
        //            if (choiceCell == nil)
        //            {
        //                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DoubleChoiceCell" owner:self options:nil];
        //                
        //                id firstObject = [topLevelObjects objectAtIndex: 0];
        //                
        //                if ([firstObject isKindOfClass: [DoubleChoiceCell class]])
        //                {
        //                    choiceCell = firstObject;
        //                }
        //                else 
        //                {
        //                    choiceCell = [topLevelObjects objectAtIndex: 1];
        //                }
        //            }
        //            return choiceCell;
        //        }
        //        else
        //        {
        //            return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Empty"] autorelease];
        //        }
    }
    else
    {
        return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Empty"] autorelease];
    }
}


-(IBAction)segmentValueChanged:(id)sender
{
    if ([sender isKindOfClass: [UISegmentedControl class]])
    {
        UISegmentedControl *segControl = (UISegmentedControl *) sender;
        currentType = segControl.selectedSegmentIndex;
        [self.tbView reloadData];
        
        if (currentType == StationsSegment) 
        {
            [self.addStationButton setTitle:NSLocalizedString(@"Add new station", nil) forState:UIControlStateNormal];
            
            if ([[PreferencesManager sharedManager].userSelectedStations count] == 0) 
            {
                [self.addStationButton setHidden: NO];
            }
            else
            {
                [self.addStationButton setHidden: YES];
            }
            
        }
        else if(currentType == ExceptionsSegment)
        {
            [self.addStationButton setTitle:NSLocalizedString(@"No songs added yet", nil) forState:UIControlStateNormal];
            
            if ([[PreferencesManager sharedManager].songExceptions count] == 0) 
            {
                [self.addStationButton setHidden: NO];
            }
            else
            {
                [self.addStationButton setHidden: YES];
            }
        }
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row && !childItem && currentType == StationsSegment) 
    {
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
        
        [PreferencesManager sharedManager].indexToAdd = indexPath.row - 1;
        
        [self.navigationController pushViewController:self.stationSelectionList animated:YES];
    }
    else if(indexPath.section == 0 && indexPath.row == 1 && childItem)
    {
        [[NSUserDefaults standardUserDefaults] setBool:
         ![[NSUserDefaults standardUserDefaults] boolForKey: @"skipAds"] forKey: @"skipAds"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.tbView reloadData];
    }
    else if(indexPath.section == 0 && indexPath.row == 2 && childItem)
    {
        [[NSUserDefaults standardUserDefaults] setBool:
         ![[NSUserDefaults standardUserDefaults] boolForKey: @"pauseOnException"] forKey: @"pauseOnException"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.tbView reloadData];
    }
    
    [self.tbView deselectRowAtIndexPath:indexPath animated:YES];
}

-(IBAction)addStation:(id)sender
{
    if (currentType == StationsSegment) 
    {
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
        
        [PreferencesManager sharedManager].indexToAdd = [[PreferencesManager sharedManager].userSelectedStations count];
        
        [self.navigationController pushViewController:self.stationSelectionList animated:YES];
    }
    else
    {
        UIAlertView *helpAlert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"You can add song exceptions while this song is playing or just started to play!", nil) message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
        
        [helpAlert show];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (!indexPath.section && !childItem) 
    {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        if (currentType == StationsSegment) 
        {
            [[PreferencesManager sharedManager].userSelectedStations removeObjectAtIndex: indexPath.row - 1];
            [[PreferencesManager sharedManager] saveChanges];
            [self.tbView reloadData];
        }
        else
        {
            [[PreferencesManager sharedManager].songExceptions removeObjectAtIndex: indexPath.row - 1];
            [[PreferencesManager sharedManager] saveChanges];
            [self.tbView reloadData];
        }
        
        if (currentType == StationsSegment) 
        {
            [self.addStationButton setTitle:NSLocalizedString(@"Add new station", nil) forState:UIControlStateNormal];
            
            if ([[PreferencesManager sharedManager].userSelectedStations count] == 0) 
            {
                [self.addStationButton setHidden: NO];
            }
            else
            {
                [self.addStationButton setHidden: YES];
            }
            
        }
        else if(currentType == ExceptionsSegment)
        {
            [self.addStationButton setTitle:NSLocalizedString(@"No songs added yet", nil) forState:UIControlStateNormal];
            
            if ([[PreferencesManager sharedManager].songExceptions count] == 0) 
            {
                [self.addStationButton setHidden: NO];
            }
            else
            {
                [self.addStationButton setHidden: YES];
            }
        }
    }    
}


@end
