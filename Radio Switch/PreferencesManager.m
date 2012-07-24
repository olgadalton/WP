//
//  PreferencesManager.m
//  Radio Switch
//
//  Created by Olga Dalton on 24/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import "PreferencesManager.h"

@implementation PreferencesManager

@synthesize userAddedStations;

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

-(void) dealloc
{
    [userAddedStations release];
    [super dealloc];
}

@end
