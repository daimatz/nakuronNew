//
//  menuView.m
//  nakuron
//

#import "menuViewController.h"
#import "nakuronViewController.h"

extern nakuronViewController *nakuron;

@implementation menuViewController
@synthesize probNumField;
@synthesize difficultyLabel;
@synthesize difficultySlider;

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

  // スライド中もイベント通知
  difficultySlider.continuous = YES;
}

- (void)viewDidUnload
{
  [self setDifficultyLabel:nil];
  [self setDifficultySlider:nil];
  [self setProbNumField:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancelButton:(id)sender {
  [self.view removeFromSuperview];
  [self release];
}

- (IBAction)updateButton:(id)sender {
  // newDifficulty はここで代入しなくてよい
  newProbNum = [probNumField.text intValue];
  [nakuron boardInit:newDifficulty probNum:newProbNum holeRatio:HOLE_RATIO];
  [self.view removeFromSuperview];
  [self release];
}

- (IBAction)probNumMinusButton {
  probNumField.text = [NSString stringWithFormat:@"%d", [probNumField.text intValue]-1];
}

- (IBAction)probNumPlusButton {
  probNumField.text = [NSString stringWithFormat:@"%d", [probNumField.text intValue]+1];
}

- (IBAction)difficultyChanging:(UISlider*)slider {
  if (slider.value < 0.75) {
    newDifficulty = DIFFICULTY_EASY;
    slider.value = 0;
  } else if (slider.value < 1.5) {
    newDifficulty = DIFFICULTY_NORMAL;
    slider.value = 1;
  } else if (slider.value < 2.25) {
    newDifficulty = DIFFICULTY_HARD;
    slider.value = 2;
  } else {
    newDifficulty = DIFFICULTY_VERY_HARD;
    slider.value = 3;
  }
  
  NSString *str[4] = {@"Easy", @"Normal", @"Hard", @"Very Hard"};
  difficultyLabel.text = str[(int)newDifficulty];
}

- (void)initView:(Difficulty)d probNum:(int)p
{
  newDifficulty = d;
  newProbNum = p;
  probNumField.text = [NSString stringWithFormat:@"%d", newProbNum];
  switch (d) {
    case DIFFICULTY_EASY: difficultySlider.value = 0; break;
    case DIFFICULTY_NORMAL: difficultySlider.value = 1; break;
    case DIFFICULTY_HARD: difficultySlider.value = 2; break;
    case DIFFICULTY_VERY_HARD: difficultySlider.value = 3; break;
    default: throw ProgrammingException("[menuView initView] difficulty がおかしい");
  }
  [self difficultyChanging:difficultySlider];
}

- (void)dealloc {
  [difficultyLabel release];
  [difficultySlider release];
  [probNumField release];
  [super dealloc];
}
@end
