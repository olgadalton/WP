//
//  SmartAnalyzer.m
//  Radio Switch
//
//  Created by Olga Dalton on 24/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import "SmartAnalyzer.h"
#import "ASIHTTPRequest.h"

@implementation SmartAnalyzer

static SmartAnalyzer *sharedAnalyzer = nil;

@synthesize analyzedQue, pagesToAnalyze, delegate, analyzerBusy, errorSelector, successSelector, lastAnalyzerResult;

@synthesize lastURLToAnalyze;

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
    NSString *responseString = [request responseString];
    
    
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
                                   @"wpl", @".zpl", nil];
                                                
           
    BOOL urlFound = NO;
    
    for(NSString *extension in extensionsToSearch)
    {
        NSRange extensionRange = [responseString rangeOfString: extension];
        
        if (extensionRange.location != NSNotFound) 
        {
            
        }
    }
                                   
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if ([self.pagesToAnalyze count]) 
    {
        [self.pagesToAnalyze removeLastObject];
        
        if ([self.pagesToAnalyze count]) 
        {
            NSDictionary *queItem = [self.pagesToAnalyze lastObject];
            
            [[SmartAnalyzer sharedAnalyzer] analyzeUrl:
                            [queItem objectForKey:@"urlToAnalyze"] 
                                          withDelegate: [queItem objectForKey:@"delegate"] 
                                      andErrorSelector:NSSelectorFromString([queItem objectForKey:@"errorSelector"]) 
                                    andSuccessSelector: NSSelectorFromString([queItem objectForKey: @"successSelector"])];
        }
    }
    
    if (self.errorSelector && self.delegate 
        && [self.delegate respondsToSelector:self.errorSelector]) 
    {
        [self.delegate performSelector: self.errorSelector withObject: self.lastURLToAnalyze];
    }
}

@end
