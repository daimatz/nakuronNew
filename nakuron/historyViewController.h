#import <UIKit/UIKit.h>
#include "nakuron.h"

@interface historyViewController : UIViewController
{
@private
  int probNum;
  Difficulty difficulty;
}
- (IBAction)backButton:(id)sender;
- (IBAction)playButton:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *probNumLabel;

@end
