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
    NSMutableArray *newTempDataHolder;
    
    int inQue;
    
    NSMutableArray *allData;
}

@property (nonatomic, retain) RequestsHandler *handler;
@property (nonatomic, retain) NSMutableArray *tempDataHolder, *newTempDataHolder;
@property (nonatomic, retain) NSMutableArray *allData;

-(void) loadRadiosListAndSave;

+(RequestsManager *) sharedManager;

-(void) firstListLoadedWithData: (NSString *) data 
                        andInfo: (NSDictionary *) info;

-(void) listDataFailedWithError: (NSString *) errorDescription;

-(void) loadStationdetails;
-(void) loadStationsDataFromCache;

@end
