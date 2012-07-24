//
//  RequestsManager.m
//  Müü
//
//  Created by Olga Dalton on 6/15/12.
//  Copyright (c) 2012 Finestmedia Ltd. All rights reserved.
//

#import "RequestsManager.h"
#import "RequestsHandler.h"
#import "JSONKit.h"

@implementation RequestsManager
@synthesize handler, tempDataHolder, allData;

static RequestsManager *sharedRequestsManager = nil;

+(RequestsManager *) sharedManager
{
    @synchronized([RequestsManager class])
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
    @synchronized([RequestsManager class])
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
    return self;
}

-(void) loadRadiosListAndSave
{
    [self loadStationsDataFromCache];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL loadedOneTime = [defaults boolForKey: @"databaseLoaded"];
    NSDate *lastLoadingDate = [defaults objectForKey: @"lastLoaded"];
    
    if (!loadedOneTime || (loadedOneTime && [[NSDate date] timeIntervalSinceDate: lastLoadingDate] > EXPIRATION_TIME)) 
    {
        self.handler = [[RequestsHandler alloc] initWithDelegate:self 
                                                andErrorSelector:@selector(listDataFailedWithError:) andSuccessSelector: @selector(firstListLoadedWithData:andInfo:)];
        
        self.handler.myGenreId = nil;
        
        [self.handler loadDataWithPostData:nil andURL: [NSString stringWithFormat: CATEGORIES_LIST, API_KEY]
                             andHTTPMethod:@"GET" 
                            andContentType:@"application/json" andAuthorization:nil];
    }
//    else 
//    {
//        [self loadStationsDataFromCache];
//    }
}

-(void) firstListLoadedWithData: (NSString *) data 
                            andInfo: (NSDictionary *) info
{
    if([info objectForKey:@"stID"] == nil)
    {
        NSError *error = nil;
        
        NSArray *jsonData = [data objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
        
        if (jsonData) 
        {
            self.tempDataHolder = [NSMutableArray arrayWithArray: jsonData];

            [[NSUserDefaults standardUserDefaults] setBool:YES forKey: @"databaseLoaded"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastLoaded"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            for (NSDictionary *category in self.tempDataHolder) 
            {
                inQue++;
                
                NSNumber *catId = [category objectForKey: @"id"];
                
                NSString *categoryPath = [NSString stringWithFormat: STATIONS_LIST, API_KEY, catId];
                
                RequestsHandler *rHandler = [[RequestsHandler alloc] initWithDelegate:self andErrorSelector:@selector(listDataFailedWithError:) andSuccessSelector:@selector(firstListLoadedWithData:andInfo:)];
                
                rHandler.myGenreId = [NSString stringWithFormat: @"%@", catId];
                
                [rHandler loadDataWithPostData:nil andURL:categoryPath andHTTPMethod:@"GET" andContentType:@"application/json" andAuthorization:nil];
            }
        }
    }
    else
    {
        inQue--;
        
        NSArray *stationsList = [data objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:nil];
        
        if (stationsList) 
        {
            NSNumber *stId = [NSNumber numberWithInt: [[info objectForKey:@"stID"] intValue]];
            
            NSDictionary *toReplace = nil;
            
            for (NSDictionary *category in self.tempDataHolder) 
            {
                if ([[category objectForKey: @"id"] isEqual:stId]) 
                {
                    toReplace = category;
                    break;
                }
            }
            
            if (toReplace) 
            {
                NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary: toReplace];
                [newDict setObject:stationsList forKey: @"stations"];
                
                [self.tempDataHolder replaceObjectAtIndex: 
                                    [self.tempDataHolder indexOfObject: toReplace] 
                                               withObject: newDict];
            }
        }
        
        if (inQue <= 0) 
        {
            NSString *filePath = [[SHARED_DELEGATE applicationDocumentsDirectory] stringByAppendingPathComponent: @"cache.dat"];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath: filePath]) 
            {
                [[NSFileManager defaultManager] removeItemAtPath: filePath error: nil];
            }
            
            NSData *cacheData = [NSKeyedArchiver archivedDataWithRootObject: self.tempDataHolder];
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:cacheData attributes:nil];
            
            self.tempDataHolder = nil;
            [self loadStationsDataFromCache];
        }
    }
    
    if ([info objectForKey:@"handler"]) 
    {
        RequestsHandler *rHandler = (RequestsHandler *) [info objectForKey:@"handler"];
        [rHandler release];
    }
}

-(void) loadStationsDataFromCache
{
    self.allData = [NSMutableArray array];
    
    NSString *filePath = [[SHARED_DELEGATE applicationDocumentsDirectory] stringByAppendingPathComponent: @"cache.dat"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: filePath]) 
    {
        self.allData = [NSMutableArray arrayWithArray: [NSKeyedUnarchiver unarchiveObjectWithFile: filePath]];
    }
    else
    {
        NSString *cachePath = [[NSBundle mainBundle] pathForResource:@"cache" ofType:@"dat"];
        self.allData = [NSMutableArray arrayWithArray: [NSKeyedUnarchiver unarchiveObjectWithFile: cachePath]];
    }
    
    NSMutableArray *withStations = [NSMutableArray array];
    
    for (NSDictionary *category in self.allData) 
    {
        if ([[category objectForKey:@"stations"] count] > 1) 
        {
            [withStations addObject: category];
        }
        else if ([[category objectForKey:@"stations"] count] == 1) 
        {
            if ([[[category objectForKey:@"stations"] objectAtIndex: 0] isKindOfClass:[NSDictionary class]]) 
            {
                [withStations addObject: category];
            }
        }
    }
    
    self.allData = withStations;
    
    NSLog(@"all stations - %@", self.allData);
}

-(void) listDataFailedWithError: (NSString *) errorDescription
{
    inQue--;
}


@end
