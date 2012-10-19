//
//  viewbased_iphoneAppDelegate.h
//  viewbased-iphone
//
//  Created by otakeda on 12/10/01.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class viewbased_iphoneViewController;

@interface viewbased_iphoneAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    viewbased_iphoneViewController *viewController;

    __block UIBackgroundTaskIdentifier bgTask;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet viewbased_iphoneViewController *viewController;

@end

