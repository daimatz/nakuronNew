#import "finishViewController.h"
#include "HistoryModel.h"
#include "nakuronViewController.h"

using namespace std;

@implementation finishViewController
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

- (void)viewDidLoad
{
  [super viewDidLoad];

  HistoryModel hmdl;
  Find(fc)->order("id","desc");
  vector<KeyValue> kvs = hmdl.find(fc);
  assert(!kvs.empty());
  KeyValue kv = kvs[0];
  difficulty = intToDifficulty(atoi(kv["difficulty"].c_str()));
  probNum = atoi(kv["probNum"].c_str());
  score = atoi(kv["score"].c_str());
  drawMapToSubview(difficulty, probNum, finishMapView);

  difficultyLabel.text = stringToNSString(difficultyToString(difficulty));
  probNumLabel.text = stringToNSString(kv["probNum"]);
  datetimeLabel.text = stringToNSString(kv["created"]);
  string scoreStr;
  scoreStr += kv["score"];
  scoreStr += " / " + kv["nums"];
  scoreStr += " / " + kv["times"];
  scoreLabel.text = stringToNSString(scoreStr);
}

- (void)viewDidUnload
{
  [finishMapView release];
  finishMapView = nil;
  [self setDifficultyLabel:nil];
  [self setProbNumLabel:nil];
  [self setDatetimeLabel:nil];
  [self setScoreLabel:nil];
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

- (IBAction)retryButton:(id)sender {
  NSLog(@"Retry");
  [superVC boardInit:difficulty probNum:probNum];
  [self.view removeFromSuperview];
  [superVC backFromFinish];
  [self release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
  for (UIView *v in finishMapView.subviews) {
    [v removeFromSuperview];
  }
  [finishMapView release];
  [difficultyLabel release];
  [probNumLabel release];
  [datetimeLabel release];
  [scoreLabel release];
  [super dealloc];
}
@end
