#import "historyViewController.h"
#import "nakuronViewController.h"
#import "menuViewController.h"

using namespace std;

@implementation historyViewController
@synthesize display;
@synthesize currentLabel;
@synthesize difficultyLabel;
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
  for (UIView *v in historyMapView.subviews) {
    [v removeFromSuperview];
  }
  if (histories.empty()) {
    difficultyLabel.text = probNumLabel.text = datetimeLabel.text = scoreLabel.text = @"No histories";
    currentLabel.text = @"";
  } else {
    current = num % histories.size();
    NSLog(@"current: %d", current);
    Difficulty difficulty = intToDifficulty(atoi(histories[current]["difficulty"].c_str()));
    int probNum = atoi(histories[current]["probNum"].c_str());
    difficultyLabel.text = stringToNSString(difficultyToString(difficulty));
    probNumLabel.text = stringToNSString(histories[current]["probNum"]);
    datetimeLabel.text = stringToNSString(histories[current]["created"]);
    currentLabel.text = stringToNSString("No. "+intToString(current+1));
    scoreLabel.text = stringToNSString(histories[current]["score"]);

    drawMapToSubview(difficulty, probNum, historyMapView);
  }
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // 最初は -1 にしておく。まだ履歴がないとき対策
  current = -1;

  HistoryModel hmdl;
  Find(fc)->order("id","desc");
  histories = hmdl.findAll(fc);
  [self updateShowing:0]; // 最初は履歴の 0 番目を表示
  
  UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
  left.direction = UISwipeGestureRecognizerDirectionLeft;
  left.delegate = self;
  [display addGestureRecognizer:left];

  UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
  right.direction = UISwipeGestureRecognizerDirectionRight;
  right.delegate = self;
  [display addGestureRecognizer:right];
}

- (void)viewDidUnload
{
  [self setProbNumLabel:nil];
  [self setDatetimeLabel:nil];
  [self setScoreLabel:nil];
  [self setDifficultyLabel:nil];
  [historyMapView release];
  historyMapView = nil;
  [self setCurrentLabel:nil];
  [self setDisplay:nil];
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
  [superVC backFromHistory];
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
      [nakuronVC boardInit:difficulty probNum:probNum];
      [self.view removeFromSuperview];
      [superVC cancelButton:nil];
      [self release];
    }
  }
}

- (void)setParameters:(menuViewController *)m nakuron:(nakuronViewController*)n;
{
  superVC = m;
  nakuronVC = n;
}

- (void)dealloc {
  [probNumLabel release];
  [datetimeLabel release];
  [scoreLabel release];
  [difficultyLabel release];
  for (UIView *v in historyMapView.subviews) {
    [v removeFromSuperview];
  }
  [historyMapView release];
  [currentLabel release];
  [display release];
  [super dealloc];
}

-(void)rightSwipe:(id)sender {
  NSLog(@"right swipe");
  [self leftButton];
}

- (IBAction)rightButton {
  if (current == histories.size() - 1) current = 0;
  else current++;
  [self updateShowing:current];
}

-(void)leftSwipe:(id)sender {
  NSLog(@"left swipe");
  [self rightButton];
}

- (IBAction)leftButton {
  if (current == 0) current = histories.size() - 1;
  else current--;
  [self updateShowing:current];
}
@end
