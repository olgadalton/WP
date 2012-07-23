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

@implementation SelectViewController

@synthesize tbView, stationSelectionList;


-(void) viewDidLoad
{
    [super viewDidLoad];
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.navigationItem setTitle: NSLocalizedString(@"Select streams", nil)];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) 
    {
        return 32.0f;
    }
    else
    {
        return 60.0f;
    }
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
        
        return headerCell;
    }
    else
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
        
        if(indexPath.row == 3)
        {
            [contentCell.separatorView setHidden: YES];
            bgView.position = CustomCellBackgroundViewPositionBottom;
        }
        else 
        {
            [contentCell.separatorView setHidden: NO];
            bgView.position = CustomCellBackgroundViewPositionMiddle;
        }
        
        contentCell.selectedBackgroundView = bgView;
        
        return contentCell;
    }

}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == StationSection && indexPath.row) 
    {
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
        
        [self.navigationController pushViewController:self.stationSelectionList animated:YES];
    }
    
    [self.tbView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
