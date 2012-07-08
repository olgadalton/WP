//
//  AppDelegate.h
//  Radio Switch
//
//  Created by Olga Dalton on 04/07/2012.
//  Copyright (c) 2012 Olga Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>
{
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tabBarController;
}

@property (strong, nonatomic) IBOutlet UIWindow *window;

@property (strong, nonatomic) IBOutlet UITabBarController *tabBarController;

- (NSString *) applicationDocumentsDirectory;

@end
