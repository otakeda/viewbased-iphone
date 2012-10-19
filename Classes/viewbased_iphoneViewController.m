//
//  viewbased_iphoneViewController.m
//  viewbased-iphone
//
//  Created by otakeda on 12/10/01.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "viewbased_iphoneViewController.h"
#import "Classes/SBJson.h"

@implementation viewbased_iphoneViewController
NSMutableArray *list0;
@synthesize webView;
@synthesize tableView0;
@synthesize indicator0;
@synthesize toolbar; 

- (void)dealloc {
    [super dealloc];
    [webView release];
    [tableView0 release];
    [btn0 release];
    [defaultList release];
    [json_set release];
//    [label release]
}
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}
- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}
- (void)viewDidLoad {
    
    
    [super viewDidLoad];
//    json_set = [[NSDictionary alloc] init];
    webView.hidden=YES;
    btnClose.hidden=YES;
//    [self updateData];
    [[webView layer] setCornerRadius:10];
    [webView setClipsToBounds:YES];
    [webView setBackgroundColor:[ UIColor blackColor]];
    [webView setOpaque:YES];
     
    [btnClose setBackgroundColor:[UIColor clearColor]];
    
    [self.view bringSubviewToFront:lblStatus];

    [self.view sendSubviewToBack:txtView];  //debug用のテキストはうらに隠す
    /*
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
    label.text = @"test";
    
    [toolbar setItems:[NSArray arrayWithObject:label]];

    [label release];
     */
//    webView.delegate=self.webView;
//    [btnClose setOpaque:NO];
    
}
- (IBAction) btn_help:(id)sender{
    UIAlertView *alertView
    = [[UIAlertView alloc] initWithTitle:@"条件について"
                                 message:@"ヘルプ情報です¥nです。"
                                delegate:nil
                       cancelButtonTitle:@"OK"
                       otherButtonTitles:nil];
    [alertView show];
    [alertView release];

}
- (IBAction) btn_reload:(id)sender{
    [self updateData];
}
- (IBAction) btn_close:(id)sender{
    webView.hidden=YES;
    btnClose.hidden=YES;
    
}
- (IBAction) btn_down:(id)sender{
    [self updateData];
}

- (int)getWarnCount{
    
    int warnCount=0;
    
    if (!json_set) return 0;
    
    for (id key in json_set){
        int val = [[json_set objectForKey:key] intValue];
        if ((val > 1)||(val<-1)) warnCount++;
    }
    return warnCount;
}
- (void) indicatorStart{    
    [self.view bringSubviewToFront:indicator0];
    [indicator0 startAnimating];
}
- (void) indicatorStop{
    [indicator0 stopAnimating];
    [self.view sendSubviewToBack:indicator0];
    
}
- (void)updateData{

    [self performSelectorInBackground:@selector(indicatorStart) withObject:nil];
    
    [NSThread sleepForTimeInterval:1.0];

    txtView.text=nil;
    // 送信したいURLを作成し、Requestを作成します。
    NSURL *url = [NSURL URLWithString:@"http://leanprojectman.com/php/n3/fxjson.php"];
    NSURLRequest  *request = [[NSURLRequest alloc] initWithURL:url];
    
    // NSURLConnectionのインスタンスを作成したら、すぐに
    // 指定したURLへリクエストを送信し始めます。
    // delegate指定すると、サーバーからデータを受信したり、
    // エラーが発生したりするとメソッドが呼び出される。
    NSURLConnection *aConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    // 作成に失敗する場合には、リクエストが送信されないので
    // チェックする
    if (!aConnection) {
        NSLog(@"connection error.");
        UIAlertView *alertView
        = [[UIAlertView alloc] initWithTitle:nil
                                     message:@"通信エラー"
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }else
    NSLog(@"succeed to create connection ");
    }

- (void) connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *)response {
    
    // receiveDataはフィールド変数
    receivedData = [[NSMutableData alloc] init];
}
// データ受信したら何度も呼び出されるメソッド。
// 受信したデータをreceivedDataに追加する
- (void) connection:(NSURLConnection *) connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error{
    NSLog(@"Connection failed! Error - %@ %d %@",
          [error domain],
          [error code],
          [error localizedDescription]);
    txtView.text = @"ネットワークに接続できません";
    lblStatus.text = @"ネットワークに接続できません";

    
    [self performSelectorInBackground:@selector(indicatorStop) withObject:nil];
}
- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // 今回受信したデータはHTMLデータなので、NSDataをNSStringに変換する。
    NSString *html=
     [[NSString alloc] initWithBytes:receivedData.bytes
                               length:receivedData.length
                             encoding:NSUTF8StringEncoding];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSError *error;
    
    UIAlertView *alertView
    = [[UIAlertView alloc] initWithTitle:nil
                                 message:@"受信データエラー"
                                delegate:nil
                       cancelButtonTitle:@"OK"
                       otherButtonTitles:nil];

    //    NSDictionary
    json_set = [parser objectWithString:html error:&error];
    if(!json_set){
        NSLog(@"%@",[error description]);
        [alertView show];
        lblStatus.text = @"受信データエラー";
    }else{
        NSLog(@"%@",[json_set description]);
        // 受信したデータをUITextViewに表示する。
        txtView.text = html;
        lblStatus.text = @"OK";
        [tableView0 reloadData];    //バックグラウンドのときはこの先にいってない
    }
    [self performSelectorInBackground:@selector(indicatorStop) withObject:nil];

    [html release];
    [parser release];
    [alertView release];
}

- (NSInteger)numberOfSections {
    return 1; // セクションは1個とします
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"title";
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"footer";
}
// 最初の１回しかよばれなさそう
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger cnt;
    if (json_set){
        cnt = [json_set count];
    }
    else
    {
        if (!defaultList)
        defaultList = [[NSArray alloc] initWithObjects:
                 @"USDJPY", @"EURJPY", @"EURUSD", @"AUDJPY",
                 @"GBPJPY", @"NZDJPY", @"CADJPY", @"CHFJPY",@"GBPUSD",@"USDCHF",
                 nil];
        cnt= [defaultList count];
    }
	return cnt;
}
//
//  tableView:cellForRowAtIndexPath
//    CellにNSArrayに登録されている文字列を設定
//    本メソッドは、UITableViewDataSourceプロトコルを採用しているのでコールされる。
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//	UITableViewCell *cell;
    NSString *cur_name = [defaultList objectAtIndex:indexPath.row];
//	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cur_name] autorelease];
    NSLog(@"cur_name:%@",cur_name);
    
    // セルを再利用するためのコード
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cur_name];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cur_name] autorelease];
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.detailTextLabel.hidden=YES;
    cell.detailTextLabel.textColor=[UIColor redColor];
    cell.detailTextLabel.enabled=NO;
    cell.imageView.image = nil;

    
    if (json_set)
    {
        
        int val = [[json_set objectForKey:cur_name] intValue];
        /*
        NSString *a1 = [json_set objectForKey:cur_name];
        NSString *a2 = [json_set objectForKey:@"aaa"];
        NSString *a3 = [json_set objectForKey:@"USDJPY"];
        NSLog(@"a1:%@   a2:%@   a3:%@",a1,a2,a3);
         */
        gotList = [json_set allKeys];
        gotValue = [json_set allValues];
        switch (val){
            case 1:
                cell.textLabel.textColor = [UIColor yellowColor];
                cell.imageView.image = nil;
                cell.imageView.image =[UIImage imageNamed:@"warning.png"];
//                cell.detailTextLabel.text = @" ↑";
                break;
            case 2:
                cell.textLabel.textColor = [UIColor redColor];
//                cell.detailTextLabel.text = @" ↑↑";
                cell.imageView.image =[UIImage imageNamed:@"warning.png"];
                break;
            case 3:
                cell.textLabel.textColor = [UIColor magentaColor];
//                cell.detailTextLabel.text = @" ↑↑↑";
                cell.imageView.image =[UIImage imageNamed:@"warning.png"];
                break;
            case -1:
                cell.textLabel.textColor = [UIColor yellowColor];
                cell.imageView.image = nil;
              
                cell.imageView.image =[UIImage imageNamed:@"warning.png"];
                
                break;
            case -2:
                cell.textLabel.textColor = [UIColor redColor];
//                cell.textLabel.text = [[gotList objectAtIndex: indexPath.row] stringByAppendingString:@" ↓"];
//                cell.detailTextLabel.text = @" ↓↓";
                cell.imageView.image =[UIImage imageNamed:@"warning.png"];
                break;
            case -3:
                cell.textLabel.textColor = [UIColor magentaColor];
//                cell.textLabel.text = [[gotList objectAtIndex: indexPath.row] stringByAppendingString:@" ↓"];
//                cell.detailTextLabel.text = @" ↓↓↓";
                cell.imageView.image =[UIImage imageNamed:@"warning.png"];
                break;
            default:
//                cell.textLabel.text = [[gotList objectAtIndex: indexPath.row] stringByAppendingString:@" "];
//                cell.detailTextLabel.text = cur_name;
                cell.imageView.image = nil;
                
//    warnCount++;
                
                
        }
    }
    else
    {
        cell.textLabel.text = [defaultList objectAtIndex: indexPath.row];
    }
	return cell;
}
//
//  tableView:didSelectRowAtIndexPath
//    選択されたCellの文字列をToolBarにあるLabelにセットし表示する。
//    本メソッドは、UITableViewDelegateプロトコルを採用しているのでコールされる。
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
    [self.view bringSubviewToFront:webView];
    webView.hidden=NO;
    NSString *urls = [[NSString alloc] initWithFormat:@"http://leanprojectman.com/php/n3/fxgraph.php?cur=%@", [defaultList objectAtIndex:indexPath.row] ];

    NSLog(@"http://leanprojectman.com/php/n3/fxgraph.php?cur=%@", [defaultList objectAtIndex:indexPath.row]);
//    webView.backgroundColor = [UIColor clearColor]; // お好みに応じて
    webView.scalesPageToFit = YES; // お好みに応じて
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urls]]];
    
    btnClose.hidden=NO;
    [self.view bringSubviewToFront:btnClose];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; //すぐに非選択状態にする
    
}
-(void)webViewDidStartLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

// ページ読込完了時にインジケータを非表示にする
-(void)webViewDidFinishLoad:(UIWebView*)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */
@end
