#import <UIKit/UIKit.h>
#include "nakuron.h"

@class nakuronViewController;

@interface finishViewController : UIViewController {
@private
  nakuronViewController *superVC;
  
  Difficulty difficulty;
  int probNum;
  int score;

  IBOutlet UIView *finishMapView;
}

- (void)setParameters:(nakuronViewController*)n;
- (IBAction)newGameButton:(id)sender;

@property (retain, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (retain, nonatomic) IBOutlet UILabel *probNumLabel;
@property (retain, nonatomic) IBOutlet UILabel *datetimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *scoreLabel;

@end
