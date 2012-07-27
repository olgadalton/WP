//
//  PreferencesManager.m
//  Radio Switch
//
//  Created by Olga Dalton on 24/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import "PreferencesManager.h"

@implementation PreferencesManager

@synthesize userAddedStations, userSelectedStations, indexToAdd, songExceptions;

static  PreferencesManager *sharedRequestsManager = nil;

+(PreferencesManager *) sharedManager
{
    @synchronized([PreferencesManager class])
    {
        if (!sharedRequestsManager)
        {
            [[self alloc] init];
        }
        return sharedRequestsManager;
    }
    return nil;
}

+(id) alloc
{
    @synchronized([PreferencesManager class])
    {
        if (sharedRequestsManager == nil)
        {
            sharedRequestsManager = [super alloc];
        }
        return sharedRequestsManager;
    }
    return nil;
}

-(id) init
{
    self = [super init];
    
    if (self) 
    {
        self.userAddedStations = [[NSUserDefaults standardUserDefaults] objectForKey: @"stations"];
        
        if (self.userAddedStations == nil) 
        {
            self.userAddedStations = [NSMutableArray array];
        }
        
        self.userSelectedStations = [[NSUserDefaults standardUserDefaults] objectForKey: @"preferences"];
        
        if (self.userSelectedStations == nil) 
        {
            self.userSelectedStations = [NSMutableArray array];
        }
        
        self.songExceptions = [[NSUserDefaults standardUserDefaults] objectForKey: @"songs"];
        
        if (self.songExceptions == nil) 
        {
            self.songExceptions = [NSMutableArray array];
        }
        
        [self.songExceptions addObject: [NSDictionary dictionaryWithObjectsAndKeys:@"Test song name", @"name", @"Test song singer", @"singer", nil]];
        
        [self.songExceptions addObject: [NSDictionary dictionaryWithObjectsAndKeys:@"Test song name 2", @"name", @"Test song singer 2", @"singer", nil]];
    }
    
    return self;
}

-(void) addStation: (NSDictionary *) newStation
{
    [self.userAddedStations addObject: newStation];
    [[NSUserDefaults standardUserDefaults] setObject:self.userAddedStations forKey: @"stations"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Do request?
}

-(void) removeStationAtIndex: (NSInteger) index
{
    [self.userAddedStations removeObjectAtIndex: index];
    [[NSUserDefaults standardUserDefaults] setObject:self.userAddedStations forKey: @"stations"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) saveChanges
{
    [[NSUserDefaults standardUserDefaults] setObject: self.userSelectedStations forKey:@"preferences"];
    [[NSUserDefaults standardUserDefaults] setObject: self.songExceptions forKey: @"songs"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) delloc
{
    [userAddedStations release];
    [super dealloc];
}

@end
