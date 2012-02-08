//
//  nakuronViewController.h
//  nakuron
//
//  Created by arai takahiro on 12/01/17.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "menuViewController.h"
#import "finishViewController.h"

#include "nakuron.h"
#include <cstring>
#include <vector>
#include <algorithm>
#include <complex>
#include <deque>

#import "SA_OAuthTwitterEngine.h"
#include "nakuron-twitter.h"

@interface nakuronViewController : UIViewController <UIAccelerometerDelegate>
{
@private
  EAGLContext *context;
  GLuint program;
  
  BOOL animating;
  NSInteger animationFrameInterval;
  CADisplayLink *displayLink;

  menuViewController *menuView;
  finishViewController *finishVC;

  int probNum;
  Difficulty difficulty;
  int restBallNum;
  
  int boardSize;
  PieceData pieces[MAX_BOARD_WIDTH+2][MAX_BOARD_WIDTH+2];
  PieceData prevPieces[MAX_BOARD_WIDTH+2][MAX_BOARD_WIDTH+2];
  std::complex<float> targetCoord[MAX_BOARD_WIDTH+2][MAX_BOARD_WIDTH+2];
  std::complex<float> curCoord[MAX_BOARD_WIDTH+2][MAX_BOARD_WIDTH+2];
  std::deque<VanishState> vanishBalls;
  
  Direction pushedDir;
  float curVel;

  bool ballMoveFlag;
  bool usedDebugballMoveFlag;

  float cellSize;
  
  std::vector<Direction> step;
  int dScore; //scoreの増分
  int score;
  
  std::map<PieceData, GLuint> piecenumToTexture;
  GLuint boardTexture,bgTexture;
  bool useAcc;

  // Twitter エンジン
  SA_OAuthTwitterEngine *twitterEngine;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

@property (retain, nonatomic) IBOutlet UILabel *scoreLabel;
@property (retain, nonatomic) IBOutlet UILabel *restLabel;

- (IBAction)rightButton;
- (IBAction)downButton;
- (IBAction)leftButton;
- (IBAction)upButton;
- (IBAction)menuButton;
- (IBAction)favoriteButton;
- (IBAction)useAccButton;

- (void)startAnimation;
- (void)stopAnimation;

-(bool)isHoleCoord:(std::complex<float>)p;
-(bool)isOverTarget:(int)r C:(int)c;
-(void)drawMain;

- (void)dump;
- (void)coordInit;
- (void)printTargetCoord;
- (void)updateScore:(int)nscore;
- (void)updateRestBallNum:(int)num;
- (void)didDropAllBalls;

- (void)updateState:(Direction)d;
- (void)updateStateDownButton;
- (void)updateStateUpButton;
- (void)updateStateRightButton;
- (void)updateStateLeftButton;
- (void)endBallMove;
- (std::complex<float>)getCoordRC:(int)r C:(int)c;
-(void)boardInit:(Difficulty)d probNum:(int)p holeRatio:(int)r;

- (void)enableAcc;
- (void)disableAcc;

- (void)backFromSubview;
- (void)backFromFinish;
- (void)backFromMenu;

@end
