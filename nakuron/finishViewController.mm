#import "finishViewController.h"
#include "HistoryModel.h"
#include "nakuronViewController.h"

using namespace std;

@implementation finishViewController

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Twitter エンジン
  twitterEngine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
  twitterEngine.consumerKey = kOAuthConsumerKey;
  twitterEngine.consumerSecret = kOAuthConsumerSecret;
  NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:TWITTER_AUTHDATA_KEY]);

  HistoryModel hmdl;
  Find(fc)->order("id","desc");
  vector<KeyValue> kvs = hmdl.find(fc);
  assert(!kvs.empty());
  KeyValue kv = kvs[0];
  difficulty = stringToDifficulty(kv["difficulty"]);

  [self updateTwitterAuthInfo];
}

- (void)viewDidUnload
{
  [twitterButton release];
  twitterButton = nil;
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)setParameters:(nakuronViewController *)n {
  superVC = n;
}

- (IBAction)newGameButton:(id)sender {
  NSLog(@"newGame");
  int newProbNum = randomProbNum();
  [superVC boardInit:difficulty probNum:newProbNum];
  [self.view removeFromSuperview];
  [superVC backFromFinish];
  [self release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Twitter
- (void)updateTwitterAuthInfo {
  authData = [[NSUserDefaults standardUserDefaults] objectForKey:TWITTER_AUTHDATA_KEY];
  if (authData) {
    twitterButton.enabled = YES;
    [twitterButton setTitle:@"Twitterに投稿" forState:UIControlStateHighlighted];
    [twitterButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
  } else {
    twitterButton.enabled = NO;
    [twitterButton setTitle:@"認証されていません" forState:UIControlStateDisabled];
    [twitterButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
  }
}

- (IBAction)twitterSettingButton {
  if (!authData) {
    // 設定する
    UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:twitterEngine delegate:self];
    if (controller) {
      [self presentModalViewController:controller animated:YES];
    }
  }
}

- (IBAction)twitterButton {
  UIAlertView *alert = [[UIAlertView alloc]
                        initWithTitle:@"Send to Twitter"
                        message:@"Twitterに投稿しますか？"
                        delegate:self
                        cancelButtonTitle:@"NO"
                        otherButtonTitles:@"YES", nil];
  [alert show];
  [alert release];
}

// アラートをキャッチする
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 1) {
    // YES ボタン
    // 実際に Twitter にポスト
		[twitterEngine sendUpdate: [NSString stringWithFormat:@"Already Updated. %@", [NSDate date]]];
  }
}

- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
	[defaults setObject:data forKey:TWITTER_AUTHDATA_KEY];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	NSString *s = 	[[NSUserDefaults standardUserDefaults] objectForKey:TWITTER_AUTHDATA_KEY];
  NSLog(@"%@", s);
  return s;
}

#pragma mark SA_OAuthTwitterControllerDelegate
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
	NSLog(@"Authenicated for %@", username);
  [self updateTwitterAuthInfo];
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
	NSLog(@"Authentication Failed!");
  [self updateTwitterAuthInfo];
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
	NSLog(@"Authentication Canceled.");
  [self updateTwitterAuthInfo];
}

#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
}

- (void)dealloc {
  [twitterEngine release];
  [twitterButton release];
  [super dealloc];
}
@end
