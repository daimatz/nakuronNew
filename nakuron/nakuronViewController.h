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

@interface nakuronViewController : UIViewController {
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

  float cellSize;
  
  std::vector<Direction> step;
  int score;
  
  std::map<PieceData, GLuint> piecenumToTexture;
  
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (IBAction)rightButton;
- (IBAction)downButton;
- (IBAction)leftButton;
- (IBAction)upButton;

- (IBAction)menuButton;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawMain;
- (void)dump;
-(void)boardInit:(Difficulty)d probNum:(int)p holeRatio:(int)r;
@end
