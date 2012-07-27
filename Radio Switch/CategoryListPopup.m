//
//  TransactionDetailsPopup.m
//  UnitedTickets
//
//  Created by Eigen Lenk on 5/22/12.
//  Copyright (c) 2012 Finestmedia Ltd. All rights reserved.
//

#import "CategoryListPopup.h"
#import "AppDelegate.h"
#import "RequestsManager.h"
#import "CustomCellBackgroundView.h"
#import "SmallContentCell.h"
#import "PreferencesManager.h"

#import "StationsListViewController.h"

@interface CategoryListPopup ()

@end

@implementation CategoryListPopup

@synthesize viewLoaded, tbView, selectedSection, delagate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        viewLoaded = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    viewLoaded = YES;  
    
    UIView *bgView = [[[UIView alloc] initWithFrame: self.tbView.frame] autorelease];
    [bgView setBackgroundColor: [UIColor colorWithPatternImage: [UIImage imageNamed: @"paper-texture.jpg"]]];
    
    [self.tbView setBackgroundView: bgView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    viewLoaded = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
} 

- (IBAction)backgroudTouched:(id)sender
{
    [self animateOut];
}

- (void)animateOut
{
    darkBackgroundView.alpha = 1.0f;
    contentView.alpha = 1.f;
    
    /*CGRect r = darkBackgroundView.frame;
    CGRect orig = r;
    
    r.origin.x -= 20.f;
    r.origin.y -= 20.f;
    
    r.size.width += 40.f;
    r.size.height += 40.f;
    
    contentView.frame = orig;*/
    
    [UIView animateWithDuration:0.38f
                          delay:0.0f
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         darkBackgroundView.alpha = 0.0f;
                         contentView.alpha = 0.0f;
                         //contentView.frame = r;
                     } 
                     completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                     }];
}

- (void)animateIn
{
    darkBackgroundView.alpha = 0.0f;
    contentView.alpha = 0.f;
    
    CGRect r = contentView.frame;
    r.origin.y = 0.f;
    contentView.frame = r;
    
    CGAffineTransform transform = contentView.transform;
    contentView.transform = CGAffineTransformScale(transform, 1.5f, 1.5f);
    
    [UIView animateWithDuration:0.2f
                          delay:0.08f
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         contentView.transform = CGAffineTransformScale(transform, 1.0f, 1.0f);
                        contentView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    [UIView animateWithDuration:0.35f
                          delay:0.0f
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         darkBackgroundView.alpha = 1.0f;
                     } 
                     completion:^(BOOL finished) {
                         
                     }];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[RequestsManager sharedManager].allData 
              objectAtIndex: selectedSection] 
             objectForKey: @"stations"] count];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [self.tbView reloadData];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    bgView.position = CustomCellBackgroundViewPositionMiddle;
    
    if (indexPath.row == [self tableView:self.tbView numberOfRowsInSection:indexPath.section] - 1) 
    {
        [contentCell.separatorView setHidden: YES];
    }
    else
    {
        [contentCell.separatorView setHidden: NO];
    }
    
    if ([[RequestsManager sharedManager].allData count] > selectedSection
        && [[[[RequestsManager sharedManager].allData objectAtIndex:selectedSection] objectForKey: @"stations"] count] > indexPath.row) 
    {
        NSDictionary *station = [[[[RequestsManager sharedManager].allData 
                                   objectAtIndex:selectedSection] objectForKey: @"stations"]
                                 objectAtIndex: indexPath.row];
        
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

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *station = [[[[RequestsManager sharedManager].allData 
                               objectAtIndex:selectedSection] objectForKey: @"stations"]
                             objectAtIndex: indexPath.row];
    
    
    if ([[PreferencesManager sharedManager].userSelectedStations count] > [PreferencesManager sharedManager].indexToAdd) 
    {
        [[PreferencesManager sharedManager].userSelectedStations replaceObjectAtIndex:[PreferencesManager sharedManager].indexToAdd withObject: station];
    }
    else
    {
        [[PreferencesManager sharedManager].userSelectedStations addObject: station];
    }
    
    [[PreferencesManager sharedManager] saveChanges];
    
    [self animateOut];
    
    [((StationsListViewController *) self.delagate).navigationController popViewControllerAnimated: YES];
}

@end
