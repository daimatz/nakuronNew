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

#include "nakuron.h"
#include <cstring>
#include <vector>
#include <algorithm>
#include <complex>

@interface nakuronViewController : UIViewController <UIAccelerometerDelegate>
{
@private
  EAGLContext *context;
  GLuint program;
  
  BOOL animating;
  NSInteger animationFrameInterval;
  CADisplayLink *displayLink;

  menuViewController *menuView;

  int probNum;
  Difficulty difficulty;
  
  int boardSize;
  PieceData pieces[MAX_BOARD_WIDTH+2][MAX_BOARD_WIDTH+2];
  PieceData prevPieces[MAX_BOARD_WIDTH+2][MAX_BOARD_WIDTH+2];
  std::complex<float> targetCoord[MAX_BOARD_WIDTH+2][MAX_BOARD_WIDTH+2];
  std::complex<float> curCoord[MAX_BOARD_WIDTH+2][MAX_BOARD_WIDTH+2];
  Direction pushedDir;
  float curVel;

  bool ballMoveFlag;

  float cellSize;
  
  std::vector<Direction> step;
  int score;
  
  std::map<PieceData, GLuint> piecenumToTexture;

  // 傾きセンサー
  UIAccelerationValue accelerationX;
  UIAccelerationValue accelerationY;
  float currentRawReading;
  float calibrationOffset;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

@property (retain, nonatomic) IBOutlet UILabel *scoreLabel;

- (IBAction)rightButton;
- (IBAction)downButton;
- (IBAction)leftButton;
- (IBAction)upButton;
- (IBAction)menuButton;

- (void)startAnimation;
- (void)stopAnimation;

-(bool)isOverTarget:(int)r C:(int)c;
-(void)drawMain;

- (void)dump;
- (void)coordInit;
- (void)printTargetCoord;
- (void)updateScore:(int)diff;
- (void)updateState:(Direction)d;
- (void)updateStateDownButton;
- (void)updateStateUpButton;
- (void)updateStateRightButton;
- (void)updateStateLeftButton;
- (std::complex<float>)getCoordRC:(int)r C:(int)c;
-(void)boardInit:(Difficulty)d probNum:(int)p holeRatio:(int)r;

@end
