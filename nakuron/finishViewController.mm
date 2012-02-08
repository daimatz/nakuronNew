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

  HistoryModel hmdl;
  Find(fc)->order("id","desc");
  vector<KeyValue> kvs = hmdl.find(fc);
  assert(!kvs.empty());
  KeyValue kv = kvs[0];
  difficulty = stringToDifficulty(kv["difficulty"]);
}

- (void)viewDidUnload
{
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
  [superVC boardInit:difficulty probNum:newProbNum holeRatio:HOLE_RATIO];
  [self.view removeFromSuperview];
  [superVC backFromFinish];
  [self release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
