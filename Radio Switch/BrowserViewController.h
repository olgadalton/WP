//
//  BrowserViewController.h
//  Radio Switch
//
//  Created by Olga Dalton on 25/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowserViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>
{
    IBOutlet UIButton *backButton, *nextButton;
    IBOutlet UITextField *addressBar;
    IBOutlet UIButton *goButton;
    IBOutlet UIWebView *webView;
    
    UIAlertView *alertWithSpinner;
    
    id lastResponder;
    
    IBOutlet UIActivityIndicatorView *waitSpinner;
    
    NSString *lastResult;
    
    UITextField *alertTextField;
    
    BOOL disappeared;
    
    BOOL inEditing;
}

@property (nonatomic, retain) IBOutlet UIButton *backButton, *nextButton;
@property (nonatomic, retain) IBOutlet UITextField *addressBar;
@property (nonatomic, retain) IBOutlet UIButton *goButton;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) UIAlertView *alertWithSpinner;
@property (nonatomic, retain) id lastResponder;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *waitSpinner;
@property (nonatomic, retain) NSString *lastResult;
@property (nonatomic, retain) UITextField *alertTextField;

-(IBAction)textFieldEditingFinished:(id)sender;

-(IBAction) goToUrl: (id) sender;
-(void) controlButtons;

-(void)disableWebViewBouncing:(UIWebView *)webview andScrolling:(BOOL)disableScrolling;

-(void) analyzerFinishedForUrl: (NSString *) url withResult: (NSString *) result;
-(void) analyzerFailedForUrl: (NSString *) url;

-(void) analyze;

@end
