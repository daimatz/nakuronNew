#import <UIKit/UIKit.h>
#include "nakuron.h"
#include "HistoryModel.h"

@class menuViewController;
@class nakuronViewController;

@interface historyViewController : UIViewController
{
@private
  int current;
  std::vector<KeyValue> histories;
  
  menuViewController *superViewController;
  nakuronViewController *nakuron;
}
- (IBAction)backButton:(id)sender;
- (IBAction)playButton:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *probNumLabel;
@property (retain, nonatomic) IBOutlet UILabel *datetimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *scoreLabel;
- (IBAction)rightButton;
- (IBAction)leftButton;

- (void)setParameters:(menuViewController*)m nakuron:(nakuronViewController*)n;

@end
