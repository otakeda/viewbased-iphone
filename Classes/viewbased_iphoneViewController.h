//
//  viewbased_iphoneViewController.h
//  viewbased-iphone
//
//  Created by otakeda on 12/10/01.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface viewbased_iphoneViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate>{
    IBOutlet UIWebView *webView;
    IBOutlet UITextView *txtView;
	IBOutlet UIButton *btn0;
    IBOutlet UIButton *btnClose;
    IBOutlet UITableView *tableView0;
    IBOutlet UIActivityIndicatorView *indicator0;
    IBOutlet UILabel *lblStatus;
    IBOutlet UIToolbar *toolbar;
    NSArray *defaultList;
    NSArray *gotList;
    NSArray *gotValue;
    NSMutableData *receivedData;
    NSDictionary *json_set;
//    int warnCount;
}
@property(nonatomic, retain) UIWebView *webView; 
@property(nonatomic, retain) UITableView *tableView0;
@property(nonatomic, retain) UIActivityIndicatorView *indicator0;
@property(nonatomic, retain) UIToolbar *toolbar;

- (IBAction) btn_down:(id)sender;
- (IBAction) btn_close:(id)sender;
- (IBAction) btn_reload:(id)sender;
- (IBAction) btn_help:(id)sender;
- (int) getWarnCount;
- (void)updateData;

@end

