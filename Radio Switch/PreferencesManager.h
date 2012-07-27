//
//  PreferencesManager.h
//  Radio Switch
//
//  Created by Olga Dalton on 24/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferencesManager : NSObject
{
    NSMutableArray *userAddedStations;
    
    NSMutableArray *userSelectedStations;
    
    NSInteger indexToAdd;
    
    NSMutableArray *songExceptions;
}

@property (nonatomic, retain) NSMutableArray *userAddedStations, *userSelectedStations;
@property NSInteger indexToAdd;
@property (nonatomic, retain) NSMutableArray *songExceptions;

+(PreferencesManager *) sharedManager;
-(void) addStation: (NSDictionary *) newStation;
-(void) removeStationAtIndex: (NSInteger) index;

-(void) saveChanges;

@end
