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
#import <AVFoundation/AVFoundation.h>

#import "menuViewController.h"
#import "finishViewController.h"

#include "nakuron.h"
#include <cstring>
#include <vector>
#include <algorithm>
#include <complex>
#include <deque>

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
  std::vector<std::vector<PieceData> > pieces;
  std::vector<std::vector<PieceData> > prevPieces;
  std::complex<float> targetCoord[MAX_BOARD_WIDTH+2][MAX_BOARD_WIDTH+2];
  std::complex<float> curCoord[MAX_BOARD_WIDTH+2][MAX_BOARD_WIDTH+2];
  bool correctEffect[MAX_BOARD_WIDTH+2][MAX_BOARD_WIDTH+2];
  std::vector<BasicImageData> fixPieces;
  std::deque<VanishState> vanishBalls;
  std::deque<PlusOneEffectState> plusOneEffects;
  
  Direction pushedDir;
  float curVel;

  bool ballMoveFlag;
  bool usedDebugballMoveFlag;

  float cellSize;
  
  int dScore; //scoreの増分
  int score;
  int times;
  int initialBallNum;
  
  std::map<PieceData, GLuint> piecenumToTexture;
  GLuint boardTexture,bgTexture[4];
  GLuint plusOneTexture[4];

  bool canUseAcc; // 加速度センサーを使える状態にあるか (SubView が上に乗ってたりすると使えない)
  bool useAcc; // 実際に加速度センサーを有効にしているか
  bool useSE;
  
  AVAudioPlayer *correctSound;
  AVAudioPlayer *pushSound;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

@property (retain, nonatomic) IBOutlet UILabel *scoreLabel;
@property (retain, nonatomic) IBOutlet UILabel *restLabel;
@property (retain, nonatomic) IBOutlet UILabel *timesLabel;
@property (retain, nonatomic) IBOutlet UIButton *useAccButtonLabel;
@property (retain, nonatomic) IBOutlet UIButton *useSEButtonLabel;

- (IBAction)rightButton;
- (IBAction)downButton;
- (IBAction)leftButton;
- (IBAction)upButton;
- (IBAction)menuButton;
- (IBAction)useAccButton;
- (IBAction)useSEButton;
- (IBAction)quitButton;

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
- (void)updateTimes:(int)times;
- (void)didDropAllBalls;

- (void)updateState:(Direction)d;
- (void)updateStateDownButton;
- (void)updateStateUpButton;
- (void)updateStateRightButton;
- (void)updateStateLeftButton;
- (void)endBallMove;
- (void)checkFixPiece;
- (std::complex<float>)getCoordRC:(int)r C:(int)c;
- (std::pair<int,int>)getRCCoord:(std::complex<float>)p;
- (void)boardInit:(Difficulty)d probNum:(int)p;

- (void)enableAcc;
- (void)disableAcc;

- (void)enableSE;
- (void)disableSE;

- (void)backFromSubview;
- (void)backFromFinish;
- (void)backFromMenu;

@end
