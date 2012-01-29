//
//  menuView.h
//  nakuron
//

#import <UIKit/UIKit.h>
#import "historyViewController.h"
#import "twitterViewController.h"
#include "nakuron.h"

@class nakuronViewController;

@interface menuViewController : UIViewController
{
@private
  Difficulty newDifficulty;
  int newProbNum;
  historyViewController *historyVC;
  twitterViewController *twitterVC;

  nakuronViewController *superVC;
}


- (IBAction)cancelButton:(id)sender;
- (IBAction)updateButton:(id)sender;

- (IBAction)probNumMinusButton;
- (IBAction)probNumPlusButton;
@property (retain, nonatomic) IBOutlet UITextField *probNumField;
- (IBAction)probNumFieldEndEdit:(id)sender;
- (IBAction)backgroundTap:(id)sender; // 背景をタップしてキーボードを隠す

@property (retain, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (retain, nonatomic) IBOutlet UISlider *difficultySlider;
- (IBAction)difficultyChanging:(UISlider*)slider;
- (IBAction)historyButton;
- (IBAction)twitterButton;

- (void)setParameters:(nakuronViewController*)n difficulty:(Difficulty)d probNum:(int)p;

@end
