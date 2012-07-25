//
//  RequestsManager.h
//  Müü
//
//  Created by Olga Dalton on 6/15/12.
//  Copyright (c) 2012 Finestmedia Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestsHandler.h"

@interface RequestsManager : NSObject
{
    RequestsHandler *handler;
    
    int currentlyLoaded;
    
    int allNeededCount;
    
    NSMutableArray *tempDataHolder;
    
    int inQue;
    
    NSMutableArray *allData;
    
    UIAlertView *waitAlert;
}

@property (nonatomic, retain) RequestsHandler *handler;
@property (nonatomic, retain) NSMutableArray *tempDataHolder;
@property (nonatomic, retain) NSMutableArray *allData;
@property (nonatomic, retain) UIAlertView *waitAlert;

-(void) loadRadiosListAndSave;

+(RequestsManager *) sharedManager;

-(void) firstListLoadedWithData: (NSString *) data 
                        andInfo: (NSDictionary *) info;

-(void) listDataFailedWithError: (NSString *) errorDescription;

-(void) loadStationsDataFromCache;

-(void) urlIsCorrect: (NSString *) url andResultSelector: (SEL) resultSelector andDelegate: (id) delegate;
-(void) performURLCheck: (NSDictionary *) data;

-(BOOL) performURLCheckAndReturn: (NSString *) url;

-(NSMutableArray *) searchResultsForTerm: (NSString *) searchTerm;
-(NSArray *) searchForTermInUserStations: (NSString *) term;

@end
