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
}

@property (nonatomic, retain) NSMutableArray *userAddedStations;

+(PreferencesManager *) sharedManager;
-(void) addStation: (NSDictionary *) newStation;
-(void) removeStationAtIndex: (NSInteger) index;

@end
