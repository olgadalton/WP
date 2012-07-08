//
//  RequestsHandler.m
//  UnitedTickets
//
//  Created by Olga Dalton on 3/26/12.
//  Copyright (c) 2012 Finestmedia Ltd. All rights reserved.
//

#import "RequestsHandler.h"

@implementation RequestsHandler

@synthesize delegate, urlConnection, data, response;

@synthesize myGenreId;

-(id)initWithDelegate: (id) _delegate andErrorSelector: (SEL) sel1 andSuccessSelector: (SEL) sel2
{
    self = [super init];
    
    if (self)
    {
        self.delegate = _delegate;
        errorSelector = sel1;
        successSelector = sel2;
    }
    return self;
}

-(void) loadDataWithPostData: (NSData *) requestData andURL: (NSString *) connectionUrl andHTTPMethod: (NSString *) httpMethod andContentType: (NSString *) contentType andAuthorization: (NSString *) bearer
{
    NSLog(@"Connection started with URL %@\n and HTTPMethod %@ \n requestData - %@ and authorization %@", connectionUrl, httpMethod, [[[NSString alloc] initWithData: requestData encoding:NSUTF8StringEncoding] autorelease], bearer);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.urlConnection = nil;
    self.response = nil;
    self.data = nil;
    
    NSURL *url = [NSURL URLWithString: connectionUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url];
    [request setHTTPMethod: httpMethod];
    
    if (contentType != nil) 
    {
        [request setValue: contentType forHTTPHeaderField: @"Content-Type"];
    }
    
    if(bearer != nil)
    {
        [request setValue:bearer forHTTPHeaderField:@"Authorization"];
    }
    
    if (requestData != nil)
    {
        [request setHTTPBody: requestData];
    }
    
    self.urlConnection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
    
    [request release];
    
    if (!self.urlConnection)
    {
        if ([delegate respondsToSelector: errorSelector])
        {
            [delegate performSelector: errorSelector withObject:nil];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
    }
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace 
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge 
{
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
    NSLog(@"Connection did fail with an error - %@", [error description]);
    
    if([delegate respondsToSelector:errorSelector])
    {
        [delegate performSelector:errorSelector withObject:nil]; 
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [connection cancel];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)_response {
    
    self.response = (NSHTTPURLResponse*)_response;
	if([self.response expectedContentLength] < 1) 
    {
		self.data = [[NSMutableData alloc] init];
	}
	else 
    {
		self.data = [[NSMutableData alloc] initWithCapacity: [self.response expectedContentLength]];
	}
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)receivedData
{
    // Just append received data
    [self.data appendData:receivedData];
}

-(void)connectionDidFinishLoading: (NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([delegate respondsToSelector: successSelector])
    {
        NSMutableDictionary *additionalInfo = [NSMutableDictionary dictionary];
        
        if (self.myGenreId) 
        {
            [additionalInfo setObject:self.myGenreId forKey:@"stID"];
        }
        
        [additionalInfo setObject:self forKey: @"handler"];
        
        [delegate performSelector: successSelector withObject: 
                [[[NSString alloc] initWithData:self.data encoding: NSUTF8StringEncoding] autorelease] withObject: additionalInfo];
    }
}

-(void) stopRequests
{
    [self.urlConnection cancel];
    self.urlConnection = nil;
}

-(void) dealloc
{
    [delegate release];
    [urlConnection release];
    [response release];
    [super dealloc];
}

@end
