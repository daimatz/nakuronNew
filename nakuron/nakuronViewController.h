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
#include<cstring>
#include<vector>

#define MAX_BOARD_WIDTH 32

using namespace std;

#define EMPTY 0
#define WALL 1
#define RED 2
#define BLUE 3
#define YELLOW 4
#define GREEN 5


@interface nakuronViewController : UIViewController {
@private
  EAGLContext *context;
  GLuint program;
  
  BOOL animating;
  NSInteger animationFrameInterval;
  CADisplayLink *displayLink;
  
  int seed;
  
  //壁 1
  //空 0
  //色1...色n 1 ~ n+1
  //色壁1...色壁n n+2 ~ 2*n-1
  int pieces[MAX_BOARD_WIDTH+2][MAX_BOARD_WIDTH+2];
  int boardSize;
  int colorNum;
  float boardLeftLowerX,boardLeftLowerY,cellSize,boardSizePx;
  
  vector<GLint> piecenumToTexture;
  
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (retain, nonatomic) IBOutlet UIView *mapView;

- (IBAction)rightButton;
- (IBAction)downButton;
- (IBAction)leftButton;
- (IBAction)upButton;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawMain;
- (void)boardInitWithSize:(int)size colorNum:(int)colnum;
@end
