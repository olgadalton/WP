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
#import "PreferencesManager.h"

@implementation RequestsManager
@synthesize handler, tempDataHolder, allData, waitAlert;

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

-(void) urlIsCorrect: (NSString *) url andResultSelector: (SEL) resultSelector andDelegate: (id) delegate
{
    self.waitAlert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Checking URL...\nPlease wait!", nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
    
    UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    
    [spinner setFrame: CGRectMake(124.0f, 73.0f, spinner.frame.size.width, spinner.frame.size.height)];
    
    [self.waitAlert addSubview: spinner];
    [spinner startAnimating];
    
    [self.waitAlert show];
    
    NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjectsAndKeys: url, @"url",         NSStringFromSelector(resultSelector), @"selector", delegate, @"delegate", nil];
    
    [self performSelector:@selector(performURLCheck:)
                            withObject: dataDictionary
                            afterDelay: 0.5f];
}

-(NSMutableArray *) searchResultsForTerm: (NSString *) searchTerm
{
    NSMutableArray *searchResults = [NSMutableArray array];
    
    for (NSDictionary *category in self.allData) 
    {
        NSArray *stations = [category objectForKey: @"stations"];
        
        for (NSDictionary *station in stations) 
        {
            NSString *name = [station objectForKey: @"name"];
            NSString *country = [station objectForKey: @"country"];
            NSString *streamurl = [station objectForKey: @"streamurl"];
            
            if ([[name lowercaseString] rangeOfString: [searchTerm lowercaseString]].location != NSNotFound
                || [[country lowercaseString] rangeOfString: [searchTerm lowercaseString]].location != NSNotFound
                || [[streamurl lowercaseString] rangeOfString: [searchTerm lowercaseString]].location != NSNotFound) 
            {
                [searchResults addObject: station];
            }
        }
    }
    return searchResults;
}

-(NSArray *) searchForTermInUserStations: (NSString *) term
{
    NSMutableArray *results = [NSMutableArray array];
    
    for (NSDictionary *station in [PreferencesManager sharedManager].userAddedStations) 
    {
        NSString *name = [station objectForKey: @"name"];
        NSString *streamurl = [station objectForKey: @"streamurl"];
        
        if ([[name lowercaseString] rangeOfString: [term lowercaseString]].location != NSNotFound 
            || [[streamurl lowercaseString] rangeOfString:[term lowercaseString]].location != NSNotFound) 
        {
            [results addObject: station];
        }
    }
    return results;
}

-(void) performURLCheck: (NSDictionary *) data
{
    NSURL *myURL = [NSURL URLWithString: [data objectForKey: @"url"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: myURL];
    [request setHTTPMethod: @"HEAD"];
    NSURLResponse *response;
    NSError *error;
    NSData *myData = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
    BOOL reachable;
    
    if (myData) {
        // we are probably reachable, check the response
        reachable = YES;
    } else {
        // we are probably not reachable, check the error:
        reachable = NO;
    }
    
    [self.waitAlert dismissWithClickedButtonIndex:-10 animated:YES];
    
    SEL resultSelector = NSSelectorFromString([data objectForKey: @"selector"]);
    
    id delegate = [data objectForKey: @"delegate"];
    
    if ([delegate respondsToSelector: resultSelector]) 
    {
        [delegate performSelector: resultSelector withObject: [NSNumber numberWithBool: reachable]];
    }
}

-(BOOL) performURLCheckAndReturn: (NSString *) url
{
    NSURL *myURL = [NSURL URLWithString: url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: myURL];
    [request setHTTPMethod: @"HEAD"];
    NSURLResponse *response;
    NSError *error;
    NSData *myData = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
    BOOL reachable;
    
    if (myData) {
        // we are probably reachable, check the response
        reachable = YES;
    } else {
        // we are probably not reachable, check the error:
        reachable = NO;
    }
    return reachable;
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
