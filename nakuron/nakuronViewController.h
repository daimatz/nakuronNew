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
#include<cstring>
#include<vector>
#include<algorithm>

@interface nakuronViewController : UIViewController {
@private
  EAGLContext *context;
  GLuint program;
  
  BOOL animating;
  NSInteger animationFrameInterval;
  CADisplayLink *displayLink;

  menuViewController *menuView;

  int seed;
  
  //壁 1
  //空 0
  //色1...色n 1 ~ n+1
  //色壁1...色壁n n+2 ~ 2*n-1
  PieceData pieces[MAX_BOARD_WIDTH+2][MAX_BOARD_WIDTH+2];
  int boardSize;
  int colorNum;

  float boardLeftLowerX,boardLeftLowerY,cellSize,boardSizePx;
  
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
-(void)boardInitWithSize:(int)size colorNum:(int)colnum holeRatio:(int)hole;
@end
