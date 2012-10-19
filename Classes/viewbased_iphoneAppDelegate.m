//
//  viewbased_iphoneAppDelegate.m
//  viewbased-iphone
//
//  Created by otakeda on 12/10/01.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "viewbased_iphoneAppDelegate.h"
#import "viewbased_iphoneViewController.h"

@implementation viewbased_iphoneAppDelegate

@synthesize window;
@synthesize viewController;


- (void)createFrontJob{
    
    //フォアグラウンド用のタスクを動かす。dispatch_asyncなので結果を待たずにすぐ次へ
    dispatch_queue_t gcd_queue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(gcd_queue, ^{
        for(;;) {
            NSLog(@"Front Job: ");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.viewController updateData];  // dispatch_asyncをはずすと動かない。たぶんviewControllerがちゃんとしてないうちにこれが呼ばれるから？
            });
            [NSThread sleepForTimeInterval:10.0];    // dummy wait
            if (bgTask != UIBackgroundTaskInvalid) break;   //これのせいでback=>foreで復活しなくなった
            
        }
    });
    
    //バックグラウンドタスクを止める
    UIApplication* app = [UIApplication sharedApplication];

    if (bgTask != UIBackgroundTaskInvalid) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"finished!");
            if (bgTask != UIBackgroundTaskInvalid) {
                [app endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }


}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self getUUID];
    
    [self createFrontJob];
    
	return YES;
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self createFrontJob];
    
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = NO;
    if ([device respondsToSelector:@selector(isMultitaskingSupported)])
        backgroundSupported = device.multitaskingSupported;
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    if (backgroundSupported)
    {
        bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you.
        // stopped or ending the task outright.
            //10分でexpireする。
        NSLog(@"expired!");
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
        }];

    // Start the long-running task and return immediately.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for(;;) {
            NSLog(@"background: ");

            
            UIApplication* app = [UIApplication sharedApplication];
            int warnCount=[self.viewController getWarnCount];
            app.applicationIconBadgeNumber = warnCount;
            if (warnCount>0) [self setNotif];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.viewController updateData];  // dispatch_asyncをはずすと動かない。よくわからんロックされる
            });

            [NSThread sleepForTimeInterval:12.0];
            
            
            if (bgTask==UIBackgroundTaskInvalid) break;
        }

        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });

 }
 
    
}
/*
- (void)scheduleAlarmForDate:(NSDate*)theDate
{
    UIApplication* app = [UIApplication sharedApplication];
    NSArray*    oldNotifications = [app scheduledLocalNotifications];
    
    // Clear out the old notification before scheduling a new one.
    if ([oldNotifications count] > 0)
        [app cancelAllLocalNotifications];
    
    // Create a new notification.
    UILocalNotification* alarm = [[UILocalNotification alloc] init];
    if (alarm)
    {
        alarm.fireDate = theDate;
        alarm.timeZone = [NSTimeZone defaultTimeZone];
        alarm.repeatInterval = 0;
        // 効果音は標準の効果音を利用する
        [alarm setSoundName:UILocalNotificationDefaultSoundName];
        alarm.alertBody = @"Time to wake up!";
        
        [app scheduleLocalNotification:alarm];
    }
}
 */
- (void)setNotif{
    NSLog(@"Set Notification");
    // ローカル通知を作成する
    UILocalNotification *notification = [[UILocalNotification alloc] init];
	
    // 通知日時を設定する。今から10秒後
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:5];
    [notification setFireDate:date];
	
    // タイムゾーンを指定する
    [notification setTimeZone:[NSTimeZone localTimeZone]];
    
    NSString *alertmsg = [[NSString alloc]initWithFormat:@"Over %d",[self.viewController getWarnCount] ];
    // メッセージを設定する
    [notification setAlertBody:alertmsg];
	
    // 効果音は標準の効果音を利用する
    [notification setSoundName:UILocalNotificationDefaultSoundName];
	
    // ボタンの設定
    [notification setAlertAction:@"Open"];
	
    // ローカル通知を登録する
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    [notification release];
    
}
- (void) getUUID
{
    NSInteger alc = [[NSUserDefaults standardUserDefaults] integerForKey:@"alc"];
    NSString *uuidString ;
    if (alc == 0) {
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
        CFRelease(uuidObj);
        [[NSUserDefaults standardUserDefaults] setObject: [uuidString autorelease] forKey:@"UUID"];
    }
    else
        uuidString = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
    
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"alc"];
    NSLog(@"alc=%d",alc);
    NSLog(@"uuid=%@",uuidString);
    
}

@end
