#import <UIKit/UIKit.h>
#include "nakuron.h"
#include "HistoryModel.h"

@class menuViewController;
@class nakuronViewController;

@interface historyViewController : UIViewController <UIGestureRecognizerDelegate>
{
@private
  int current;
  std::vector<KeyValue> histories;
  
  IBOutlet UIView *historyMapView;
  menuViewController *superVC;
  nakuronViewController *nakuronVC;
}
- (IBAction)backButton:(id)sender;
- (IBAction)playButton:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (retain, nonatomic) IBOutlet UILabel *probNumLabel;
@property (retain, nonatomic) IBOutlet UILabel *datetimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *currentLabel;
@property (retain, nonatomic) IBOutlet UILabel *scoreLabel;
- (IBAction)rightButton;
- (IBAction)leftButton;

@property (retain, nonatomic) IBOutlet UIView *display;
- (void)setParameters:(menuViewController*)m nakuron:(nakuronViewController*)n;

@end
