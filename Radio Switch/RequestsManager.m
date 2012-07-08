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
@synthesize handler, tempDataHolder, allData, newTempDataHolder;

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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL loadedOneTime = [defaults boolForKey: @"databaseLoaded"];
    NSDate *lastLoadingDate = [defaults objectForKey: @"lastLoaded"];
    
    if (!loadedOneTime || (loadedOneTime && [[NSDate date] timeIntervalSinceDate: lastLoadingDate] > EXPIRATION_TIME)) 
    {
        self.handler = [[RequestsHandler alloc] initWithDelegate:self 
                                                andErrorSelector:@selector(listDataFailedWithError:) andSuccessSelector: @selector(firstListLoadedWithData:andInfo:)];
        
        self.handler.myGenreId = nil;
        
        [self.handler loadDataWithPostData:nil andURL:RADIO_LIST_API_URL 
                             andHTTPMethod:@"GET" 
                            andContentType:@"application/json" andAuthorization:nil];
    }
    else 
    {
        [self loadStationsDataFromCache];
    }
}

-(void) firstListLoadedWithData: (NSString *) data 
                            andInfo: (NSDictionary *) info
{
    if([info objectForKey:@"stID"] == nil)
    {
        NSError *error = nil;
        
        NSDictionary *jsonData = [data objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
        
        if (jsonData) 
        {
            NSMutableArray *stations = [NSMutableArray arrayWithArray: [jsonData objectForKey: @"stations"]];
            
            int allCount = [stations count];
            
            int filesNum = allNeededCount = (int)(allCount / 500) + 1;
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"databaseLoaded"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey: @"lastLoaded"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            for(int i = 0; i < filesNum; i++)
            {
                NSArray *subArray = [stations subarrayWithRange: NSMakeRange(i * 500, MIN([stations count] - (i * 500), 500))];
                
                NSString *filePath = [[SHARED_DELEGATE applicationDocumentsDirectory]
                                      stringByAppendingPathComponent: [NSString stringWithFormat:@"cache%d.dat", i]];
                
                if([[NSFileManager defaultManager] fileExistsAtPath: filePath])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error: nil];
                }
                
                [[NSFileManager defaultManager] createFileAtPath:filePath 
                                                        contents:[NSKeyedArchiver archivedDataWithRootObject:subArray]
                                                      attributes:nil];
                
                NSLog(@"file exists at path after writing - %d / %@", [[NSFileManager defaultManager] 
                                                                       fileExistsAtPath: filePath], filePath);
            }
            
            currentlyLoaded = 0;
            
            [self loadStationdetails];
        }
        else
        {
            [self loadStationsDataFromCache];
        }
    }
    else
    {
        inQue--;
        
        NSLog(@"in que - %d", inQue);
        
        NSDictionary *stationInfo = [data objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:nil];
        
        if (stationInfo) 
        {
            if ([stationInfo objectForKey: @"audiostream"]) 
            {
                NSString *name = [stationInfo objectForKey: @"name"];
                
                NSDictionary *stationDictionary = nil;
                
                NSInteger index = -10;
                
                for (NSDictionary *dict in self.tempDataHolder) 
                {
                    if ([dict objectForKey: @"name"] &&
                        ![[dict objectForKey: @"name"] isEqual: [NSNull null]] 
                        && [[dict objectForKey: @"name"] isEqualToString: name]) 
                    {
                        stationDictionary = dict;
                        index = [self.tempDataHolder indexOfObject: dict];
                        break;
                    }
                }
                
                if (stationDictionary && 
                    [stationInfo objectForKey: @"audiostream"] &&
                    ![[stationInfo objectForKey: @"audiostream"] isEqual: [NSNull null]])
                {
                    NSMutableDictionary *replacementDict = [NSMutableDictionary dictionaryWithDictionary: stationDictionary];
                    
                    [replacementDict setObject:
                                    [stationInfo objectForKey: @"audiostream"] 
                                        forKey: @"audiostream"];
                    
                    [self.newTempDataHolder addObject: replacementDict];
                }
            }
            
            if (inQue <= 0) 
            {
                NSString *filePath = [[SHARED_DELEGATE applicationDocumentsDirectory]
                                      stringByAppendingPathComponent: [NSString stringWithFormat:@"cache%d.dat", currentlyLoaded]];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath: filePath]) 
                {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                }
                
                NSLog(@"WRITING CACHE FILE TO PATH - %@", filePath);
                
                NSLog(@"tempdataholder - %@", self.newTempDataHolder);
                
                
                [[NSFileManager defaultManager] createFileAtPath:filePath 
                                                        contents:[NSKeyedArchiver archivedDataWithRootObject: self.newTempDataHolder]
                                                      attributes:nil];
                self.tempDataHolder = nil;
                self.newTempDataHolder = nil;
                
                currentlyLoaded++;
                [self loadStationdetails];
            }
        }
        else
        {
            // just skip, nothing to do
            // ??
        }
    }
    
    if ([info objectForKey:@"handler"]) 
    {
        RequestsHandler *rHandler = [info objectForKey:@"handler"];
        [rHandler release];
    }
}

-(void) loadStationdetails
{
    if (currentlyLoaded < allNeededCount) 
    {
        NSString *filePath = [[SHARED_DELEGATE applicationDocumentsDirectory]
                              stringByAppendingPathComponent: [NSString stringWithFormat:@"cache%d.dat", currentlyLoaded]];
        
        NSLog(@"file exists at path before reading - %d / %@", [[NSFileManager defaultManager] 
                                                               fileExistsAtPath: filePath], filePath);
        
        if (![[NSFileManager defaultManager] fileExistsAtPath: filePath]) 
        {
            currentlyLoaded++;
            [self loadStationdetails];
        }
        else
        {
            NSArray *arrayFromFile = [NSKeyedUnarchiver unarchiveObjectWithData: [NSData dataWithContentsOfFile: filePath]];
            
            self.tempDataHolder = [NSMutableArray arrayWithArray: arrayFromFile];
            
            inQue = 0;
            
            self.newTempDataHolder = nil;
            self.newTempDataHolder = [NSMutableArray array];
            
            for (NSDictionary *station in self.tempDataHolder) 
            {
                NSString *name = [station objectForKey: @"name"];
                
                NSString *stationUrlToLoad = [[NSString stringWithFormat: STATION_INFO, name]
                                                        stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
                
                RequestsHandler *rHandler = [[RequestsHandler alloc] initWithDelegate:self andErrorSelector:@selector(listDataFailedWithError:) andSuccessSelector:@selector(firstListLoadedWithData:andInfo:)];
                
                rHandler.myGenreId = name;
                
                [rHandler loadDataWithPostData:nil 
                                        andURL:stationUrlToLoad 
                                 andHTTPMethod:@"GET" 
                                andContentType:@"application/json" 
                              andAuthorization:nil];
                
                inQue++;
            }
        }
    }
    else
    {
        NSLog(@"Everything is loaded! Juhhuuuu!");
        
        [self loadStationsDataFromCache];
    }
}

-(void) loadStationsDataFromCache
{
    int max = 10000;
    
    self.allData = [NSMutableArray array];
    
    for(int i = 0; i < max; i++)
    {
        NSString *filePath = [[SHARED_DELEGATE applicationDocumentsDirectory]
                                    stringByAppendingPathComponent: 
                              [NSString stringWithFormat:@"cache%d.dat", i]];
        
        NSLog(@"filePath - %@", filePath);
        
        if (![[NSFileManager defaultManager] fileExistsAtPath: filePath]) 
        {
            break;
        }
        else
        {
            NSData *arrayData = [NSData dataWithContentsOfFile:filePath options:nil error:nil];
            
            if (arrayData) 
            {
                NSArray *fileArray = [NSKeyedUnarchiver unarchiveObjectWithData: arrayData];
                
                if (fileArray) 
                {
                    [self.allData addObjectsFromArray: fileArray];
                }
            }
        }
    }
    
    NSLog(@"FINAL STATIONS COUNT: %d", [self.allData count]);
    NSLog(@"STATIONS PRINT OUT: %@", self.allData);
}

-(void) listDataFailedWithError: (NSString *) errorDescription
{
    inQue--;
}


@end
