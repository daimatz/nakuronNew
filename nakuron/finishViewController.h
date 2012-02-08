#import <UIKit/UIKit.h>
#include "nakuron.h"

#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"

@class nakuronViewController;

@interface finishViewController : UIViewController <SA_OAuthTwitterControllerDelegate> {
@private
  nakuronViewController *superVC;
  
  Difficulty difficulty;

  SA_OAuthTwitterEngine *twitterEngine;
  IBOutlet UIButton *twitterButton;
  NSString *authData;
}

- (void)setParameters:(nakuronViewController*)n;
- (IBAction)newGameButton:(id)sender;

- (void)updateTwitterAuthInfo;
- (IBAction)twitterButton;
- (IBAction)twitterSettingButton;

@end
