//
//  SmartAnalyzer.m
//  Radio Switch
//
//  Created by Olga Dalton on 24/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import "SmartAnalyzer.h"
#import "ASIHTTPRequest.h"
#import "RequestsManager.h"

@implementation SmartAnalyzer

static SmartAnalyzer *sharedAnalyzer = nil;

@synthesize analyzedQue, pagesToAnalyze, delegate, analyzerBusy, errorSelector, successSelector, lastAnalyzerResult;

@synthesize lastURLToAnalyze, resultsToIgnore;

+(SmartAnalyzer *) sharedAnalyzer
{
    @synchronized([SmartAnalyzer class])
    {
        if (!sharedAnalyzer)
        {
            [[self alloc] init];
        }
        return sharedAnalyzer;
    }
    return nil;
}

+(id) alloc
{
    @synchronized([SmartAnalyzer class])
    {
        if (sharedAnalyzer == nil)
        {
            sharedAnalyzer = [super alloc];
        }
        return sharedAnalyzer;
    }
    return nil;
}

-(id) init
{
    self = [super init];
    
    if (self) 
    {
        self.pagesToAnalyze = [NSMutableArray array];
        self.resultsToIgnore = [NSMutableArray array];
    }
    
    return self;
}

-(void *) analyzeUrl: (NSString *) urlToAnalyze 
        withDelegate: (id) _delegate 
    andErrorSelector: (SEL) _errorSelector 
  andSuccessSelector: (SEL) _successSelector
{
    if (!analyzerBusy) 
    {
        self.delegate = _delegate;
        self.errorSelector = _errorSelector;
        self.successSelector = _successSelector;
        
        self.lastURLToAnalyze = urlToAnalyze;
        
        analyzerBusy = YES;
        
        self.analyzedQue = [NSMutableArray array];
        
        self.lastAnalyzerResult = nil;
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString: urlToAnalyze]];
        [request setDelegate:self];
        [request startAsynchronous];
    }
    else
    {
        NSDictionary *queItem = [NSDictionary dictionaryWithObjectsAndKeys: urlToAnalyze, @"urlToAnalyze", _delegate, @"delegate", NSStringFromSelector(_errorSelector), @"errorSelector", NSStringFromSelector(_successSelector), @"successSelector", nil];
        
        [self.pagesToAnalyze addObject: queItem];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    analyzerBusy = NO;
    
    NSString *responseString = [request responseString];
    
    NSString *searchResult = [self searchForCorrectUrl: responseString];
    
    if (searchResult != nil) 
    {
        if (self.delegate && self.successSelector 
            && [self.delegate respondsToSelector: self.successSelector]) 
        {
            [self.delegate performSelector: self.successSelector withObject:self.lastURLToAnalyze withObject: searchResult];
        }
    }
    else
    {
        if (self.delegate && self.errorSelector 
            && [self.delegate respondsToSelector:self.errorSelector]) 
        {
            [self.delegate performSelector: self.errorSelector withObject: self.lastURLToAnalyze];
        }
    }
    
    if ([self.pagesToAnalyze count]) 
    {
        if ([self.pagesToAnalyze count]) 
        {
            NSDictionary *queItem = [self.pagesToAnalyze lastObject];
            
            [[SmartAnalyzer sharedAnalyzer] analyzeUrl:
             [queItem objectForKey:@"urlToAnalyze"] 
                                          withDelegate: [queItem objectForKey:@"delegate"] 
                                      andErrorSelector:NSSelectorFromString([queItem objectForKey:@"errorSelector"]) 
                                    andSuccessSelector: NSSelectorFromString([queItem objectForKey: @"successSelector"])];
            
            [self.pagesToAnalyze removeLastObject];
        }
    }
}

-(NSString *) searchForCorrectUrl: (NSString *) responseString
{
    NSArray *extensionsToSearch = [NSArray arrayWithObjects: @".m4a", @".m4b", @".m4p", @".m4r", 
                                   @".3gp", @".mp4", @".aac", @".amr", 
                                   @".lbc", @".aiff", @".aif", @".aifc", 
                                   @".l16", @".wav", @".au", @".pcm", 
                                   @".mp3", @".pls", @".m3u", @".xspf", 
                                   @".asx", @".bio", @".fpl", @".kpl", 
                                   @".pla", @".plc", @".smil", @".vlc", 
                                   @".wpl", @".zpl", nil];
    
    
    // Needs ranges check, and swithc to i for!
    for(NSString *extension in extensionsToSearch)
    {
        NSRange extensionRange = [responseString rangeOfString: extension];
        
        if (extensionRange.location != NSNotFound) 
        {
            NSLog(@"extension found - %@", extension);
            
            NSRange delimiterSpace = [responseString rangeOfCharacterFromSet: 
                                      [NSCharacterSet characterSetWithCharactersInString:@"\"'"] options:NSBackwardsSearch 
                                                                       range:NSMakeRange(0, extensionRange.location)];
            
            if (delimiterSpace.location != NSNotFound) 
            {
                self.lastAnalyzerResult = [[responseString substringFromIndex: delimiterSpace.location + 1] substringToIndex: extensionRange.location - delimiterSpace.location + [extension length] - 1];
                
                NSLog(@"url to check - %@", self.lastAnalyzerResult);
                
                BOOL isCorrect = [[RequestsManager sharedManager] performURLCheckAndReturn: self.lastAnalyzerResult];
                
                if (isCorrect) 
                {
                    if (![self.resultsToIgnore containsObject: self.lastAnalyzerResult]) 
                    {
                        return self.lastAnalyzerResult;
                    }
                    else
                    {
                        self.lastAnalyzerResult = nil;
                        continue;
                    }
                }
                else
                {
                    self.lastAnalyzerResult = nil;
                    continue;
                }
                
                NSLog(@"analyzer result - %@", self.lastAnalyzerResult);
            }
        }
    }
    
    NSArray *partialExtensionsToSearch = [NSArray arrayWithObjects: @"m4a", @"m4b", @"m4p", @"m4r", 
                                          @"3gp", @"mp4", @"aac", @"amr", 
                                          @"lbc", @"aiff", @"aif", @"aifc", 
                                          @"l16", @"wav", @"au", @"pcm", 
                                          @"mp3", @"pls", @"m3u", @"xspf", 
                                          @"asx", @"bio", @"fpl", @"kpl", 
                                          @"pla", @"plc", @"smil", @"vlc", 
                                          @"wpl", @"zpl", nil];
    
    for(NSString *extension in partialExtensionsToSearch)
    {
        NSRange extensionRange = [responseString rangeOfString: extension];
        
        if (extensionRange.location != NSNotFound) 
        {
            NSRange delimiterSpace = [responseString rangeOfCharacterFromSet: 
                                      [NSCharacterSet characterSetWithCharactersInString:@"\"'"] options:NSBackwardsSearch 
                                                                       range:NSMakeRange(0, extensionRange.location)];
            
            NSRange otherDelimiterSpace = [responseString rangeOfCharacterFromSet: 
                                           [NSCharacterSet characterSetWithCharactersInString:@"\"'"] options:0 
                                                                            range:NSMakeRange(extensionRange.location, [responseString length] -  extensionRange.location - 1)];
            
            if (delimiterSpace.location != NSNotFound && otherDelimiterSpace.location != NSNotFound) 
            {
                self.lastAnalyzerResult = [[responseString substringFromIndex: delimiterSpace.location + 1] substringToIndex: otherDelimiterSpace.location - delimiterSpace.location];
                
                NSLog(@"url to check - %@", self.lastAnalyzerResult);
                
                BOOL isCorrect = [[RequestsManager sharedManager] performURLCheckAndReturn: self.lastAnalyzerResult];
                
                if (isCorrect) 
                {
                    if (![self.resultsToIgnore containsObject: self.lastAnalyzerResult]) 
                    {
                        return self.lastAnalyzerResult;
                    }
                    else
                    {
                        self.lastAnalyzerResult = nil;
                        
                        NSRange extensionRange2 = [responseString rangeOfString: extension options:0 range:NSMakeRange(otherDelimiterSpace.location, [responseString length] - otherDelimiterSpace.location - 1)];
                        
                        if (extensionRange2.location != NSNotFound) 
                        {
                            NSRange delimiterSpace2 = [responseString rangeOfCharacterFromSet: 
                                                       [NSCharacterSet characterSetWithCharactersInString:@"\"'"] options:NSBackwardsSearch 
                                                                                        range:NSMakeRange(0, extensionRange2.location)];
                            
                            NSRange otherDelimiterSpace2 = [responseString rangeOfCharacterFromSet: 
                                                            [NSCharacterSet characterSetWithCharactersInString:@"\"'"] options:0 
                                                                                             range:NSMakeRange(extensionRange2.location, [responseString length] -  extensionRange2.location - 1)];
                            
                            if (delimiterSpace2.location != NSNotFound && otherDelimiterSpace2.location != NSNotFound) 
                            {
                                self.lastAnalyzerResult = [[responseString substringFromIndex: delimiterSpace2.location + 1] substringToIndex: otherDelimiterSpace2.location - delimiterSpace2.location];
                                
                                if (![self.resultsToIgnore containsObject: self.lastAnalyzerResult]) 
                                {
                                    return self.lastAnalyzerResult;
                                }
                                else
                                {
                                    self.lastAnalyzerResult = nil;
                                }
                            }
                        }
                    }}
                else
                {
                    self.lastAnalyzerResult = nil;
                    continue;
                }
                
                NSLog(@"analyzer result - %@", self.lastAnalyzerResult);
            }
        }
    }
    
    
    return nil;
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    analyzerBusy = NO;
    
    if ([self.pagesToAnalyze count]) 
    {
        if ([self.pagesToAnalyze count]) 
        {
            NSDictionary *queItem = [self.pagesToAnalyze lastObject];
            
            [[SmartAnalyzer sharedAnalyzer] analyzeUrl:
             [queItem objectForKey:@"urlToAnalyze"] 
                                          withDelegate: [queItem objectForKey:@"delegate"] 
                                      andErrorSelector:NSSelectorFromString([queItem objectForKey:@"errorSelector"]) 
                                    andSuccessSelector: NSSelectorFromString([queItem objectForKey: @"successSelector"])];
            
            [self.pagesToAnalyze removeLastObject];
        }
    }
    
    if (self.errorSelector && self.delegate 
        && [self.delegate respondsToSelector:self.errorSelector]) 
    {
        [self.delegate performSelector: self.errorSelector withObject: self.lastURLToAnalyze];
    }
}

@end
