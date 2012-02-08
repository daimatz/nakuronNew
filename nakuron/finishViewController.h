#import <UIKit/UIKit.h>
#include "nakuron.h"

@class nakuronViewController;

@interface finishViewController : UIViewController {
@private
  nakuronViewController *superVC;
  
  Difficulty difficulty;
}

- (void)setParameters:(nakuronViewController*)n;
- (IBAction)newGameButton:(id)sender;

@end
