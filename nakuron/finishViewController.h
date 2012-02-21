#import <UIKit/UIKit.h>
#include "nakuron.h"

#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"

@class nakuronViewController;

@interface finishViewController : UIViewController {// <SA_OAuthTwitterControllerDelegate> {
@private
  nakuronViewController *superVC;
  
  Difficulty difficulty;
  int probNum;
  int score;

  IBOutlet UIView *finishMapView;

//  SA_OAuthTwitterEngine *twitterEngine;
//  IBOutlet UIButton *twitterButton;
//  NSString *authData;
}

- (void)setParameters:(nakuronViewController*)n;
- (IBAction)newGameButton:(id)sender;

@property (retain, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (retain, nonatomic) IBOutlet UILabel *probNumLabel;
@property (retain, nonatomic) IBOutlet UILabel *datetimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *scoreLabel;

//- (void)updateTwitterAuthInfo;
//- (IBAction)twitterButton;
//- (IBAction)twitterSettingButton;

@end
