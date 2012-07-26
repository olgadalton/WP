//
//  SmartAnalyzer.h
//  Radio Switch
//
//  Created by Olga Dalton on 24/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SmartAnalyzer : NSObject
{
    NSMutableArray *analyzedQue, *pagesToAnalyze;
    id delegate;
    
    BOOL analyzerBusy;
    NSString *lastAnalyzerResult;
    
    SEL errorSelector;
    SEL successSelector;
    
    NSString *lastURLToAnalyze;
    
    NSMutableArray *resultsToIgnore;
}

@property (nonatomic, retain) NSMutableArray *analyzedQue, *pagesToAnalyze;
@property (nonatomic, retain) id delegate;
@property BOOL analyzerBusy;
@property SEL errorSelector, successSelector;
@property (nonatomic, retain) NSString *lastAnalyzerResult, *lastURLToAnalyze;
@property (nonatomic, retain) NSMutableArray *resultsToIgnore;

+(SmartAnalyzer *) sharedAnalyzer;

-(void *) analyzeUrl: (NSString *) urlToAnalyze 
        withDelegate: (id) _delegate 
    andErrorSelector: (SEL) _errorSelector 
  andSuccessSelector: (SEL) _successSelector;

-(NSString *) searchForCorrectUrl: (NSString *) responseString;

-(BOOL) streamIsCorrectForKnownExceptions: (NSString *) url;

-(NSString *) clearUrl: (NSString *) url;

@end
