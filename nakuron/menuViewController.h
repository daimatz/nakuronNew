//
//  menuView.h
//  nakuron
//

#import <UIKit/UIKit.h>
#include "nakuron.h"
#include "historyViewController.h"

@interface menuViewController : UIViewController
{
@private
  Difficulty newDifficulty;
  int newProbNum;
  historyViewController *historyView;
}


- (IBAction)cancelButton:(id)sender;
- (IBAction)updateButton:(id)sender;

- (IBAction)probNumMinusButton;
- (IBAction)probNumPlusButton;
@property (retain, nonatomic) IBOutlet UITextField *probNumField;

@property (retain, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (retain, nonatomic) IBOutlet UISlider *difficultySlider;
- (IBAction)difficultyChanging:(UISlider*)slider;
- (IBAction)historyButton;

- (void)initView:(Difficulty)d probNum:(int)p;

@end
