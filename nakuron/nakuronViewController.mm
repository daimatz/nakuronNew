//
//  nakuronViewController.m
//  nakuron
//
//  Created by arai takahiro on 12/01/17.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "nakuronViewController.h"
#import "EAGLView.h"
#import "graphicUtil.h"
#include "HistoryModel.h"

using namespace std;

// Uniform index.
enum {
  UNIFORM_TRANSLATE,
  NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum {
  ATTRIB_VERTEX,
  ATTRIB_COLOR,
  NUM_ATTRIBUTES
};

@interface nakuronViewController ()
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation nakuronViewController
@synthesize scoreLabel;

@synthesize animating, context, displayLink;

-(void) dump{
  for(int r=0;r<boardSize;r++){
    for(int c=0;c<boardSize;c++){
      fprintf(stderr,"%2s %6s,",pieceToStr(pieces[r][c].piece).c_str(),colorToStr(pieces[r][c].color).c_str());
    }
    fprintf(stderr,"\n");
  }
  NSLog(@"----------------------");
}
-(void) printTargetCoord{
  for(int r=0;r<boardSize;r++){
    for(int c=0;c<boardSize;c++){
      fprintf(stderr,"(%f,%f),",real(targetCoord[r][c]),imag(targetCoord[r][c]));
    }
  }
}

//#include "ModelTest.h"
- (void)awakeFromNib
{
  //ModelTest::test();

  //常にES1を使う
  EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];

  if (!aContext)
    NSLog(@"Failed to create ES context");
  else if (![EAGLContext setCurrentContext:aContext])
    NSLog(@"Failed to set ES context current");

  self.context = aContext;
  [aContext release];

  [(EAGLView *)self.view setContext:context];
  [(EAGLView *)self.view setFramebuffer];

  animating = FALSE;
  animationFrameInterval = 1;
  self.displayLink = nil;

  //texture読み込み
  piecenumToTexture.insert(make_pair(PieceData(EMPTY, WHITE),loadTexture(@"empty.png")));
  piecenumToTexture.insert(make_pair(PieceData(WALL, BLACK), loadTexture(@"wall.png")));

  // colorNum の個数分
  NSString *cs[] = {@"red", @"green", @"blue", @"yellow"};
  Color s[] = {RED, GREEN, BLUE, YELLOW};
  for(int i=0;i<colorNum;i++) {
    piecenumToTexture.insert(make_pair(PieceData(BALL, s[i]), loadTexture([NSString stringWithFormat:@"b%@.png",cs[i]])));
    piecenumToTexture.insert(make_pair(PieceData(HOLE, s[i]), loadTexture([NSString stringWithFormat:@"h%@.png",cs[i]])));
  }
  //最初はballは移動してないので
  ballMoveFlag = false;
  //最初の盤面を作成
  [self boardInit:NORMAL
          probNum:(((arc4random() & 0x7FFFFFFF) % MAX_PROBNUM) + MIN_PROBNUM)
        holeRatio:HOLE_RATIO];
}

- (void)boardInit:(Difficulty)d probNum:(int)p holeRatio:(int)r
{
  difficulty = d;
  boardSize = difficultyToBoardSize(difficulty);
  probNum = p;
  if (probNum < MIN_PROBNUM) probNum = MIN_PROBNUM;
  else if (probNum > MAX_PROBNUM) probNum = MAX_PROBNUM;

  NSLog(@"difficulty = %d, boardSize = %d, probNum = %d", d, boardSize, probNum);

  cellSize = boardSizePx/boardSize;

  int hole = r;
  int wall = 100 - hole;
  Xor128 hash(probNum);
  for(int r=0;r<boardSize;r++){
    for(int c=0;c<boardSize;c++){
      if((r==0 && c==0) || (r==boardSize-1 && c==boardSize-1)) pieces[r][c] = PieceData(WALL, BLACK);
      else if(r==0 || c==0 || r==boardSize-1 || c==boardSize-1 ){
        pieces[r][c] = (hash.randomInt(100) < hole)
                       ? PieceData(HOLE, intToColor(hash.randomInt(colorNum)))
                       : PieceData(WALL, BLACK);
      } else{
        pieces[r][c] = (hash.randomInt(100) < wall)
                       ? PieceData(WALL, BLACK)
                       : PieceData(BALL, intToColor(hash.randomInt(colorNum)));
      }
    }
  }
  
  removeCycle(pieces, boardSize);
  
  step.clear();
  score = 0;
  [self updateScore:0];
}

- (void)dealloc
{
  if (program) {
    glDeleteProgram(program);
    program = 0;
  }

  // Tear down context.
  if ([EAGLContext currentContext] == context)
    [EAGLContext setCurrentContext:nil];

  //texture解放処理忘れないように

  [context release];

  [scoreLabel release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];

  // Release any cached data, images, etc. that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
  [self startAnimation];

  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [self stopAnimation];

  [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
  [self setScoreLabel:nil];
  [super viewDidUnload];

  if (program) {
    glDeleteProgram(program);
    program = 0;
  }

  // Tear down context.
  if ([EAGLContext currentContext] == context)
    [EAGLContext setCurrentContext:nil];
  self.context = nil;
}

- (NSInteger)animationFrameInterval
{
  return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
  /*
   Frame interval defines how many display frames must pass between each time the display link fires.
   The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
   */
  if (frameInterval >= 1) {
    animationFrameInterval = frameInterval;

    if (animating) {
      [self stopAnimation];
      [self startAnimation];
    }
  }
}
-(void)coordInit{
  for(int r=0;r<boardSize;r++){
    for(int c=0;c<boardSize;c++){
      float x = boardLeftLowerX + c*cellSize+cellSize/2;
      float y = boardLeftLowerY + boardSizePx - (r+1)*cellSize+cellSize/2;
      curCoord[r][c] = targetCoord[r][c]=complex<float>(x,y);
    }
  }
}
-(std::complex<float>)getCoordRC:(int)r C:(int)c{
  return complex<float>(boardLeftLowerX + c*cellSize+cellSize/2,
                        boardLeftLowerY+boardSizePx-(r+1)*cellSize+cellSize/2);
}

- (void)updateScore:(int)diff {
  score += diff;
  scoreLabel.text = [NSString stringWithFormat:@"%d", score];
}

- (IBAction)downButton {
  memcpy(prevPieces, pieces, sizeof(prevPieces));
  ballMoveFlag = true;
  pushedDir = DOWN;
  curVel = 0.0;
  [self updateStateDownButton];
}

- (IBAction)leftButton {
  memcpy(prevPieces, pieces, sizeof(prevPieces));
  ballMoveFlag = true;
  pushedDir = LEFT;
  curVel = 0.0;
  [self updateStateLeftButton];
}

- (IBAction)upButton {
  memcpy(prevPieces, pieces, sizeof(prevPieces));
  ballMoveFlag = true;
  pushedDir = UP;
  curVel = 0.0;
  [self updateStateUpButton];
}

- (IBAction)rightButton {
  memcpy(prevPieces, pieces, sizeof(prevPieces));
  ballMoveFlag = true;
  pushedDir = RIGHT;
  curVel = 0.0;
  [self updateStateRightButton];
}
-(void)updateState:(Direction)d{
  [self coordInit];
  for(int c=1;c < boardSize-1;c++){
    int wr = boardSize-2;
    //最初に穴があったら例外処理
    if(pieces[boardSize-1][c].piece == HOLE){
      //壁を探す
      while(pieces[wr][c].piece != WALL && wr>0) wr--;
      //壁より前が全部落とす
      for(int r=boardSize-2;r>wr;r--) {
        pieces[r][c]=PieceData(EMPTY,WHITE);
        targetCoord[r][c] = [self getCoordRC:boardSize-2 C:c];
      }
    }
    int pwr = wr;
    wr--;
    while(wr>0){
      //壁を探す
      while(pieces[wr][c].piece!=WALL && wr>0) wr--;
      //prはemptyか自分自身
      //crは初めてBALLがでてくる場所
      int pr=pwr-1,cr=pwr-1;
      while(cr>wr){
        while(cr>wr && pieces[cr][c].piece==EMPTY) cr--;
        swap(pieces[pr][c],pieces[cr][c]);
        targetCoord[cr][c] = [self getCoordRC:pr C:c];
        cr--;
        pr--;
      }
      wr--;
    }
  }
  //[self dump];
}
- (void)updateStateDownButton{
  //NSLog(@"down");
  //[self dump];
  [self coordInit];
  for(int c=1;c < boardSize-1;c++){
    int wr = boardSize-1;
    //最初に穴があったら例外処理
    if(pieces[boardSize-1][c].piece == HOLE){
      //壁を探す
      while(wr>0 && pieces[wr][c].piece != WALL) wr--;
      //壁より前が全部落とす
      for(int r=boardSize-2;r>wr;r--) {
        pieces[r][c]=PieceData(EMPTY,WHITE);
        targetCoord[r][c] = [self getCoordRC:boardSize-1 C:c];
      }
    }
    int pwr = wr;
    wr--;
    while(wr>0){
      //壁を探す
      while(wr>0 && pieces[wr][c].piece!=WALL) wr--;
      //prはemptyか自分自身
      //crは初めてBALLがでてくる場所
      int pr=pwr-1,cr=pwr-1;
      while(cr>wr){
        while(cr>wr && pieces[cr][c].piece==EMPTY) cr--;
        if(cr<=wr) break;
        swap(pieces[pr][c],pieces[cr][c]);
        targetCoord[cr][c] = [self getCoordRC:pr C:c];
        cr--;
        pr--;
      }
      pwr = wr;
      wr--;
    }
  }
  //[self dump];
}
- (void)updateStateUpButton{
  [self coordInit];
  for(int c=1;c < boardSize-1;c++){
    int wr = 0;
    //最初に穴があったら例外処理
    if(pieces[0][c].piece == HOLE){
      //壁を探す
      while(wr<boardSize-1 && pieces[wr][c].piece != WALL) wr++;
      //壁より前が全部落とす
      for(int r=1;r<wr;r++) {
        pieces[r][c]=PieceData(EMPTY,WHITE);
        targetCoord[r][c] = [self getCoordRC:0 C:c];
      }
    }
    int pwr = wr;
    wr++;
    while(wr<boardSize-1){
      //壁を探す
      while(pieces[wr][c].piece!=WALL && wr<boardSize-1) wr++;
      //prはemptyか自分自身
      //crは初めてBALLがでてくる場所
      int pr=pwr+1,cr=pwr+1;
      while(cr<wr){
        while(cr<wr && pieces[cr][c].piece==EMPTY) cr++;
        if(cr>=wr) break;
        swap(pieces[pr][c],pieces[cr][c]);
        targetCoord[cr][c] = [self getCoordRC:pr C:c];
        cr++;
        pr++;
      }
      pwr = wr;
      wr++;
    }
  }
  //[self dump];
}
- (void)updateStateRightButton{
  //NSLog(@"right");
  [self dump];
  [self coordInit];
  for(int r=1;r < boardSize-1;r++){
    //穴の場合
    int wc =boardSize-1;
    if(pieces[r][boardSize-1].piece == HOLE){
      //壁を探す
      while(pieces[r][wc].piece!=WALL && wc>0) wc--;
      //壁より前が全部落とす
      for(int c=boardSize-2;c>wc;c--){ 
        pieces[r][c]=PieceData(EMPTY,WHITE);
        targetCoord[r][c] = [self getCoordRC:r C:boardSize-1];
      }
    }
    int pwc = wc;
    wc--;
    while(wc>0){
      //壁を探す
      while(pieces[r][wc].piece!=WALL && wc>0) wc--;
      //壁がない
      //壁より前は壁まで落とす。
      //prはemptyか自分自身
      //crは初めてBALLがでてくる場所
      int pc=pwc-1,cc=pwc-1;
      while(cc>wc){
        while(cc>wc && pieces[r][cc].piece==EMPTY) cc--;
        if(cc<=wc) break;
        swap(pieces[r][pc],pieces[r][cc]);
        targetCoord[r][pc] = [self getCoordRC:r C:cc];
        cc--;
        pc--;
      }
      pwc=wc;
      wc--;
    }
  }
  [self dump];

}
- (void)updateStateLeftButton{
  //NSLog(@"right");
  //[self dump];
  [self coordInit];
  for(int r=1;r < boardSize-1;r++){
    //穴の場合
    int wc = 0;
    if(pieces[r][0].piece == HOLE){
      //壁を探す
      while(pieces[r][wc].piece!=WALL && wc<boardSize-1) wc++;
      //壁より前が全部落とす
      for(int c=1;c<wc;c++){ 
        pieces[r][c]=PieceData(EMPTY,WHITE);
        targetCoord[r][c] = [self getCoordRC:r C:0];
      }
    }
    int pwc = wc;
    wc++;
    while(wc<boardSize-1){
      //壁を探す
      while(pieces[r][wc].piece!=WALL && wc<boardSize-1) wc++;
      //壁がない
      //壁より前は壁まで落とす。
      //prはemptyか自分自身
      //crは初めてBALLがでてくる場所
      int cc=pwc+1,pc=pwc+1;
      while(cc<wc){
        while(cc<wc && pieces[r][cc].piece==EMPTY) cc++;
        if(cc>=wc) break;
        swap(pieces[r][pc],pieces[r][cc]);
        targetCoord[r][pc] = [self getCoordRC:r C:cc];
        cc++;
        pc++;
      }
      pwc=wc;
      wc++;
    }
  }
  //[self dump];

}

- (IBAction)menuButton {
  NSLog(@"menu");
  menuView = [[menuViewController alloc] initWithNibName:@"menuViewController" bundle:nil];
  menuView.view.bounds = menuView.view.frame = [UIScreen mainScreen].bounds;
  [self.view addSubview:menuView.view];
  [menuView setParameters:self difficulty:difficulty probNum:probNum];
}

- (void)startAnimation
{
  if (!animating) {
    CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(drawFrame)];
    [aDisplayLink setFrameInterval:animationFrameInterval];
    [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.displayLink = aDisplayLink;

    animating = TRUE;
  }
}

- (void)stopAnimation
{
  if (animating) {
    [self.displayLink invalidate];
    self.displayLink = nil;
    animating = FALSE;
  }
}

- (void)drawFrame
{
  [(EAGLView *)self.view setFramebuffer];

  glClearColor(255.0f, 255.0f, 255.0f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrthof(-160.0f, 160.0f, -240.0f, 240.0f ,0.5f ,-0.5f);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  //drawTexture(0.0, 0.0,20.0, 20.0,piecenumToTexture[1], 255, 255, 255, 255);
  [self drawMain];

  [(EAGLView *)self.view presentFramebuffer];
}
-(bool)isOverTarget:(int)r C:(int)c{
  complex<float> dv = polar(1.0f,(float)M_PI_2*directionToInt(pushedDir));
  complex<float> t = targetCoord[r][c]-curCoord[r][c];
  return dot(t,dv) < 0;
}
-(void)drawMain
{
  if(ballMoveFlag){
    bool endflag = true;
    curVel +=0.1f;
    complex<float> dv = polar(curVel,(float)M_PI_2*directionToInt(pushedDir));
    for(int r = 1; r < boardSize-1; r++) {
      for (int c = 1; c < boardSize-1; c++) {
        GLuint texture = piecenumToTexture[prevPieces[r][c]];
        if(targetCoord[r][c] != curCoord[r][c]){
          endflag = false;
          curCoord[r][c] += dv;
          if([self isOverTarget:(int)r C:(int)c]) curCoord[r][c] = targetCoord[r][c];
        }
        drawTexture(real(curCoord[r][c]),imag(curCoord[r][c]),cellSize,cellSize, texture,255,255,255,255);
      }
    }
    for(int r=0;r<boardSize;r++){
      GLuint texture = piecenumToTexture[pieces[r][0]];
      drawTexture(real(curCoord[r][0]),imag(curCoord[r][0]),cellSize,cellSize, texture,255,255,255,255);
      texture = piecenumToTexture[pieces[r][boardSize-1]];
      drawTexture(real(curCoord[r][boardSize-1]),imag(curCoord[r][boardSize-1]),cellSize,cellSize, texture,255,255,255,255);
    }
    for(int c=0;c<boardSize;c++){
      GLuint texture = piecenumToTexture[pieces[0][c]];
      drawTexture(real(curCoord[0][c]),imag(curCoord[0][c]),cellSize,cellSize, texture,255,255,255,255);
      texture = piecenumToTexture[pieces[boardSize-1][c]];
      drawTexture(real(curCoord[boardSize-1][c]),imag(curCoord[boardSize-1][c]),cellSize,cellSize, texture,255,255,255,255);
    }
    if(endflag) ballMoveFlag = false;
  }
  else{
    for(int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        GLuint texture = piecenumToTexture[pieces[r][c]];
        float x = boardLeftLowerX + c*cellSize+cellSize/2;
        float y = boardLeftLowerY + boardSizePx - (r+1)*cellSize+cellSize/2;
        //if(first) NSLog(@"%f %f",x,y);
        drawTexture(x,y,cellSize,cellSize, texture,255,255,255,255);
      }
    }
  }
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
  GLint status;
  const GLchar *source;

  source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
  if (!source)
  {
    NSLog(@"Failed to load vertex shader");
    return FALSE;
  }

  *shader = glCreateShader(type);
  glShaderSource(*shader, 1, &source, NULL);
  glCompileShader(*shader);

#if defined(DEBUG)
  GLint logLength;
  glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0)
  {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetShaderInfoLog(*shader, logLength, &logLength, log);
    NSLog(@"Shader compile log:\n%s", log);
    free(log);
  }
#endif

  glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
  if (status == 0)
  {
    glDeleteShader(*shader);
    return FALSE;
  }

  return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog
{
  GLint status;

  glLinkProgram(prog);

#if defined(DEBUG)
  GLint logLength;
  glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0)
  {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetProgramInfoLog(prog, logLength, &logLength, log);
    NSLog(@"Program link log:\n%s", log);
    free(log);
  }
#endif

  glGetProgramiv(prog, GL_LINK_STATUS, &status);
  if (status == 0)
    return FALSE;

  return TRUE;
}

- (BOOL)validateProgram:(GLuint)prog
{
  GLint logLength, status;

  glValidateProgram(prog);
  glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0)
  {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetProgramInfoLog(prog, logLength, &logLength, log);
    NSLog(@"Program validate log:\n%s", log);
    free(log);
  }

  glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
  if (status == 0)
    return FALSE;

  return TRUE;
}

- (BOOL)loadShaders
{
  GLuint vertShader, fragShader;
  NSString *vertShaderPathname, *fragShaderPathname;

  // Create shader program.
  program = glCreateProgram();

  // Create and compile vertex shader.
  vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
  if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
  {
    NSLog(@"Failed to compile vertex shader");
    return FALSE;
  }

  // Create and compile fragment shader.
  fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
  if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
  {
    NSLog(@"Failed to compile fragment shader");
    return FALSE;
  }

  // Attach vertex shader to program.
  glAttachShader(program, vertShader);

  // Attach fragment shader to program.
  glAttachShader(program, fragShader);

  // Bind attribute locations.
  // This needs to be done prior to linking.
  glBindAttribLocation(program, ATTRIB_VERTEX, "position");
  glBindAttribLocation(program, ATTRIB_COLOR, "color");

  // Link program.
  if (![self linkProgram:program])
  {
    NSLog(@"Failed to link program: %d", program);

    if (vertShader)
    {
      glDeleteShader(vertShader);
      vertShader = 0;
    }
    if (fragShader)
    {
      glDeleteShader(fragShader);
      fragShader = 0;
    }
    if (program)
    {
      glDeleteProgram(program);
      program = 0;
    }

    return FALSE;
  }

  // Get uniform locations.
  uniforms[UNIFORM_TRANSLATE] = glGetUniformLocation(program, "translate");

  // Release vertex and fragment shaders.
  if (vertShader)
    glDeleteShader(vertShader);
  if (fragShader)
    glDeleteShader(fragShader);

  return TRUE;
}

#pragma mark -
#pragma mark === Responding to accelerations ===
#pragma mark -
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
  const float kFilteringFactor = 0.05;

  // Use a basic low-pass filter to only keep the gravity in the accelerometer values for the X and Y axes
  accelerationX = acceleration.x * kFilteringFactor + accelerationX * (1.0 - kFilteringFactor);
  accelerationY = acceleration.y * kFilteringFactor + accelerationY * (1.0 - kFilteringFactor);
  
  // keep the raw reading, to use during calibrations
  currentRawReading = atan2(accelerationY, accelerationX);
}

@end
