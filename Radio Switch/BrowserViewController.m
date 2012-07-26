//
//  BrowserViewController.m
//  Radio Switch
//
//  Created by Olga Dalton on 25/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import "BrowserViewController.h"
#import "PreferencesManager.h"
#import <QuartzCore/QuartzCore.h>
#import "SmartAnalyzer.h"

@implementation BrowserViewController

@synthesize webView, backButton, nextButton, addressBar, goButton;
@synthesize alertWithSpinner, lastResponder, waitSpinner, lastResult;

@synthesize alertTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(IBAction)editingDidStart:(id)sender
{
    self.lastResponder = sender;
    inEditing = YES;
}

-(void) firstAnalyze
{
    [[SmartAnalyzer sharedAnalyzer].resultsToIgnore removeAllObjects];
    [self analyze];
}

-(void) analyze
{
    self.alertWithSpinner = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Checking URL...\nPlease wait!", nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
    
    UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    
    [spinner setFrame: CGRectMake(124.0f, 73.0f, spinner.frame.size.width, spinner.frame.size.height)];
    
    [self.alertWithSpinner addSubview: spinner];
    [spinner startAnimating];
    
    [self.alertWithSpinner show];
    
    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
    
    [[SmartAnalyzer sharedAnalyzer] analyzeUrl:currentURL withDelegate:self andErrorSelector:@selector(analyzerFailedForUrl:) andSuccessSelector: @selector(analyzerFinishedForUrl:withResult:)];
}

-(void) analyzerFinishedForUrl: (NSString *) url withResult: (NSString *) result
{
    [self.alertWithSpinner dismissWithClickedButtonIndex:-10 animated:YES];
    
    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:
                           [NSString stringWithFormat:@"%@ %@",
                            NSLocalizedString(@"Stream URL found on ", nil), currentURL]  
                                                     message:[NSString stringWithFormat:@"Do you want to add %@ to stations list?", result] delegate:self 
                                           cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles: NSLocalizedString(@"Yes", nil), NSLocalizedString(@"Continue searching", nil), nil] autorelease];
    
    self.lastResult = result;
    
    alert.tag = 155;
    
    [alert show];
    
    NSLog(@"analyzer finished for url - %@ and result - %@", url, result);
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 155 && buttonIndex == 2) 
    {
        [[SmartAnalyzer sharedAnalyzer].resultsToIgnore addObject: self.lastResult];
        
        [self analyze];
    }
    else if(alertView.tag == 155 && buttonIndex == 1)
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0f) 
        {
            UIAlertView *enterNameAlert = [[[UIAlertView alloc] initWithTitle:@"Please enter station name:" message:@" " delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Add", nil), nil] autorelease];
            
            [enterNameAlert setBackgroundColor:[UIColor whiteColor]];
            
            enterNameAlert.tag = 156;
            
            self.alertTextField = [[[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)] autorelease];
            
            [enterNameAlert addSubview: self.alertTextField];
            
            [enterNameAlert show];
        }
        else
        {
            
            UIAlertView *enterNameAlert = [[[UIAlertView alloc] initWithTitle:@"Please enter station name:" message: nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Add", nil), nil] autorelease];
            
            enterNameAlert.tag = 156;
            
            [enterNameAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            
            [enterNameAlert show];
        }
    }
    else if(alertView.tag == 156 && buttonIndex == 1)
    {
        BOOL textEntered = NO;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0f) 
        {
            textEntered = self.alertTextField.text.length > 0;
        }
        else
        {
            textEntered = [[[alertView textFieldAtIndex:0] text] length] > 0;
        }
        
        if (textEntered) 
        {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0f) 
            {
                [[PreferencesManager sharedManager] addStation: [NSDictionary dictionaryWithObjectsAndKeys:self.alertTextField.text, @"name", self.lastResult, @"streamurl", nil]];
            }
            else
            {
                [[PreferencesManager sharedManager] addStation: [NSDictionary dictionaryWithObjectsAndKeys:[[alertView textFieldAtIndex:0] text], @"name", self.lastResult, @"streamurl", nil]];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0f) 
            {
                UIAlertView *enterNameAlert = [[[UIAlertView alloc] initWithTitle:@"Please enter CORRECT station name:" message:@" " delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Add", nil), nil] autorelease];
                
                [enterNameAlert setBackgroundColor:[UIColor whiteColor]];
                
                enterNameAlert.tag = 156;
                
                self.alertTextField = [[[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)] autorelease];
                
                [enterNameAlert addSubview: self.alertTextField];
                
                [enterNameAlert show];
            }
            else
            {
                    
                UIAlertView *enterNameAlert = [[[UIAlertView alloc] initWithTitle:@"Please enter station name:" message: nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Add", nil), nil] autorelease];
                
                enterNameAlert.tag = 156;
                
                [enterNameAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                
                [enterNameAlert show];
            }
        }
    }
}

-(void) analyzerFailedForUrl: (NSString *) url
{
    [self.alertWithSpinner dismissWithClickedButtonIndex:-10 animated:YES];
    
    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:
                           [NSString stringWithFormat:@"%@ %@",
                            NSLocalizedString(@"No streams found on ", nil), currentURL]  
                            message:nil delegate:self 
                            cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
    
    [alert show];
    
    NSLog(@"analyzer failed for url - %@", url);
}

-(IBAction)textFieldEditingFinished:(id)sender
{
    if ([sender isFirstResponder]) 
    {
        [sender resignFirstResponder];
    }
    
    inEditing = NO;
    
    [self goToUrl: nil];
}

-(IBAction) goToUrl: (id) sender
{
    [[SmartAnalyzer sharedAnalyzer].resultsToIgnore removeAllObjects];
    
    if (self.lastResponder && [self.lastResponder isFirstResponder]) 
    {
        [self.lastResponder resignFirstResponder];
    }
    
    if ([self.addressBar.text length]) 
    {
        NSString *url = self.addressBar.text;
        
        if (![url hasPrefix: @"http"]) 
        {
            url = [NSString stringWithFormat:@"http://%@", url];
        }
        
        [self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: url]]];
    }
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"webview did fail to load with an error - %@", [error description]);
}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    [self controlButtons];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration: 0.2f];
    
    [self.goButton setHidden: NO];
    [self.waitSpinner setHidden: YES];
    
    self.addressBar.text = [self.webView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
    
    [UIView commitAnimations];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self performSelector: @selector(updateAddress) withObject:nil afterDelay:1.0f];
    disappeared = NO;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    disappeared = YES;
}

-(void) updateAddress
{
    self.addressBar.text = [self.webView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
    
    if (!disappeared && !inEditing) 
    {
        [self performSelector: @selector(updateAddress) withObject:nil afterDelay:1.0f];
    }
}

-(void) webViewDidStartLoad:(UIWebView *)webView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration: 0.2f];
    
    [self.goButton setHidden: YES];
    [self.waitSpinner setHidden: NO];
    
    [UIView commitAnimations];
}

-(void) controlButtons
{
    if ([self.webView canGoBack]) 
    {
        [self.backButton setEnabled: YES];
    }
    else
    {
        [self.backButton setEnabled: NO];
    }
    
    if ([self.webView canGoForward]) 
    {
        [self.nextButton setEnabled: YES];
    }
    else
    {
        [self.nextButton setEnabled: NO];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationItem setTitle: NSLocalizedString(@"Add station", nil)];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Analyze", nil) style:UIBarButtonItemStyleDone target:self action:@selector(firstAnalyze)] autorelease];
    
    [self.goButton.layer setMasksToBounds: YES];
    [self.goButton.layer setCornerRadius: 3.0f];
    
    [self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: @"http://www.shoutcast.com"]]];
    [self.addressBar setText: @"http://www.shoutcast.com"];
    
    [self.backButton setEnabled: NO];
    [self.nextButton setEnabled: NO];
    
    [self disableWebViewBouncing:self.webView andScrolling: NO];
    
    [self.waitSpinner startAnimating];
}
                                               

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)disableWebViewBouncing:(UIWebView *)webview andScrolling:(BOOL)disableScrolling
{
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (version >= 5.0)
    {
        webview.scrollView.scrollEnabled = disableScrolling == YES ? NO : YES; 
        webview.scrollView.bounces = NO;
        webview.scrollView.showsVerticalScrollIndicator = NO;
        webview.scrollView.showsHorizontalScrollIndicator = NO;
    }
    else
    {
        for (id subview in webview.subviews)
        {
            if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            {
                [((UIScrollView *)subview) setBounces:NO];
                [((UIScrollView *)subview) setScrollEnabled:(disableScrolling == YES ? NO : YES)];
                
                [((UIScrollView *)subview) setShowsVerticalScrollIndicator:NO];
                [((UIScrollView *)subview) setShowsHorizontalScrollIndicator:NO];
            }
        }
    }
}

@end
