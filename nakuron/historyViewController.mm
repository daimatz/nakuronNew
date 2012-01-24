#import "historyViewController.h"
#import "nakuronViewController.h"
#import "menuViewController.h"

using namespace std;

@implementation historyViewController
@synthesize probNumLabel;
@synthesize datetimeLabel;
@synthesize scoreLabel;

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

- (void)updateShowing:(int)num
{
  if (histories.empty()) {
    probNumLabel.text = datetimeLabel.text = scoreLabel.text = @"No histories";
  } else {
    current = num % histories.size();
    NSLog(@"current: %d", current);
    probNumLabel.text = stringToNSString(histories[current]["probNum"]);
    datetimeLabel.text = stringToNSString(histories[current]["created"]);
    scoreLabel.text = stringToNSString(histories[current]["score"]);
  }
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // 最初は -1 にしておく。まだ履歴がないとき対策
  current = -1;

  HistoryModel hmdl;
  auto_ptr<FindClause> fc(new FindClause());
  fc->order("id","desc");
  histories = hmdl.findAll(fc);
  [self updateShowing:0]; // 最初は履歴の 0 番目を表示
}

- (void)viewDidUnload
{
  [self setProbNumLabel:nil];
  [self setDatetimeLabel:nil];
  [self setScoreLabel:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)backButton:(id)sender {
  [self.view removeFromSuperview];
  [self release];
}

- (IBAction)playButton:(id)sender {
  if (current == -1) {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Play from History"
                          message:@"履歴がありません"
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
  } else {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Play from History"
                          message:@"この問題をやり直しますか？"
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
  }
}

// アラートをキャッチする
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (current != -1) {
    // この問題をやり直しますか？
    if (buttonIndex == 1) {
      // OK ボタン
      NSLog(@"Play probNum: %d", current);
      int probNum = atoi(histories[current]["probNum"].c_str());
      Difficulty difficulty = intToDifficulty(atoi(histories[current]["difficulty"].c_str()));
      [nakuron boardInit:difficulty probNum:probNum holeRatio:HOLE_RATIO];
      [self.view removeFromSuperview];
      [self release];
      [superViewController cancelButton:nil];
    }
  }
}

- (void)setParameters:(menuViewController *)m nakuron:(nakuronViewController*)n;
{
  superViewController = m;
  nakuron = n;
}

- (void)dealloc {
  [probNumLabel release];
  [datetimeLabel release];
  [scoreLabel release];
  [super dealloc];
}
- (IBAction)rightButton {
  [self updateShowing:current+1];
}

- (IBAction)leftButton {
  [self updateShowing:current-1];
}
@end
