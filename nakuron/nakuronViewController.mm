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
#import "Lib.h"
#import "graphicUtil.h"

nakuronViewController *nakuron;

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
@synthesize mapView;

@synthesize animating, context, displayLink;

- (void)awakeFromNib
{
  nakuron = self;
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
  
  //seed
  seed = arc4random() & 0x7FFFFFFF;
  
  //texture読み込み
  piecenumToTexture.push_back(loadTexture(@"empty.png"));
  piecenumToTexture.push_back(loadTexture(@"wall.png"));
  NSString *cs[] = {@"red", @"blue", @"yellow", @"green"};
  for(int i=0;i<4;i++) piecenumToTexture.push_back(loadTexture([NSString stringWithFormat:@"b%@.png",cs[i]]));
  for(int i=0;i<4;i++) piecenumToTexture.push_back(loadTexture([NSString stringWithFormat:@"h%@.png",cs[i]]));
  //boardの大きさ
  boardSize = 240.0;
  boardLeftLowerX = boardLeftLowerY = -120.0;
  //最初の盤面を作成
  [self boardInitWithSize:8 colorNum:4];
}
-(void)boardInitWithSize:(int)size colorNum:(int)colnum
{
  colorNum = colnum;
  boardSize = size+2;
  cellSize = boardSize/boardWidth;
  int hole = 80,wall = 20;
  NSLog(@"hoge");
  Xor128 *hash = [Xor128 xor128WithSeed:seed];
  for(int r=0;r<boardSize;r++){
    for(int c=0;c<boardSize;c++){
      if((r==0 && c==0) || (r==boardSize-1 && c==boardSize-1)) pieces[r][c] = 1;
      else if(r==0 || c==0 || r==boardSize-1 || c==boardSize-1 ){
        if([hash randomInt:100] < hole) pieces[r][c] = 1+colnum+1+[hash randomInt:colnum];
        else pieces[r][c]=1;
      }
      else{
        if([hash randomInt:100] < wall) pieces[r][c] = 1;
        else pieces[r][c] = 2+[hash randomInt:colnum];
      }
    }
  }
  for(int r=0;r<boardWidth;r++){
    for(int c=0;c<boardWidth;c++){
      fprintf(stderr,"%d,",pieces[r][c]);
    }
    fprintf(stderr,"\n");
  }
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
  
  [mapView release];
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
  [self setMapView:nil];
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

- (IBAction)downButton {
  NSLog(@"down");
}

- (IBAction)leftButton {
  NSLog(@"left");
}

- (IBAction)upButton {
  NSLog(@"up");
}

- (IBAction)rightButton {
  NSLog(@"right");
}

- (IBAction)menuButton {
  NSLog(@"menu");
  menuView = [[menuViewController alloc] initWithNibName:@"menuViewController" bundle:nil];
  menuView.view.bounds = menuView.view.frame = [UIScreen mainScreen].bounds;
  [self.view addSubview:menuView.view];
//  menuView.newDifficulty = _difficulty;
//  menuView.newProbNum = _probNum;
//  [menuView initView];
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
  
  glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT);
  
  glLoadIdentity();
  glOrthof(-160.0f, 160.0f, -240.0f, 240.0f ,0.5f ,-0.5f);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  [self drawMain];
  
  [(EAGLView *)self.view presentFramebuffer];
}

-(void)drawMain
{
  for(int r = 0; r < boardSize; r++) {
    for (int c = 0; c < boardWidth; c++) {
      GLuint texture = piecenumToTexture[pieces[r][c]];
      float x = boardLeftLowerX + c*cellSize;
      float y = boardLeftLowerY + boardWidth - (r+1)*cellSize;
      drawTexture(x,y,cellSize,cellSize, texture,255,255,255,255);
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

@end
