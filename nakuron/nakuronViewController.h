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
#include<map>
#include<cstring>

#define MAX_BOARD_WIDTH 32

using namespace std;

@interface nakuronViewController : UIViewController {
@private
  EAGLContext *context;
  GLuint program;
  
  BOOL animating;
  NSInteger animationFrameInterval;
  CADisplayLink *displayLink;
  
  int seed;
  
  //壁 0
  //空 -1
  //色1...色n n
  //色壁1...色壁n 2*n
  int pieces[MAX_BOARD_WIDTH+2][MAX_BOARD_WIDTH+2];
  int boardSize;
  int colorNum;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawMain;
- (void)boardInitWithSize:(int)size colorNum:(int)colnum;
@end
