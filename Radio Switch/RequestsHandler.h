//
//  RequestsHandler.h
//  UnitedTickets
//
//  Created by Olga Dalton on 3/26/12.
//  Copyright (c) 2012 Finestmedia Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestsHandler : NSObject
{
    NSHTTPURLResponse *response;
    NSURLConnection *urlConnection;
    NSMutableData *data;
    
    id delegate;
    SEL errorSelector, successSelector;
    
    NSString *myGenreId;
}

@property (nonatomic, retain) NSHTTPURLResponse *response;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSURLConnection *urlConnection;
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) NSString *myGenreId;

-(id)initWithDelegate: (id) _delegate andErrorSelector: (SEL) sel1 andSuccessSelector: (SEL) sel2;

-(void) loadDataWithPostData: (NSData *) requestData andURL: (NSString *) connectionUrl andHTTPMethod: (NSString *) httpMethod andContentType: (NSString *) contentType andAuthorization: (NSString *) bearer;

-(void) stopRequests;

@end
