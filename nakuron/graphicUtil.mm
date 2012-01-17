//
//  graphicUtil.mm
//  nakuron
//
//  Created by arai takahiro on 11/12/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "graphicUtil.h"

//
//  graphicUtil.mm
//  OpenGLBook
//
//  Created by arai takahiro on 11/12/13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "graphicUtil.h"
void drawSquare(){
  drawSquare(255,0,0,255);
}
void drawSquare(int red,int green,int blue,int alpha){
  drawSquare(0.0f,0.0f,red,green,blue,alpha);
}
void drawSquare(float x,float y,int red,int green,int blue,int alpha){
  drawRectangle(x,y,1.0f, 1.0f, red,green, blue, alpha);
}
void drawRectangle(float x,float y,float width,float height,int red,int green,int blue,int alpha){
  static const GLfloat squareVertices[] = {
    -0.5f*width+x, -0.5f*height+y,
    0.5f*width+x, -0.5f*height+y,
    -0.5*width+x,  0.5f*height+y,
    0.5f*width+x,  0.5f*height+y
  };

  const GLubyte squareColors[] = {
    red, green, blue, alpha,
    red, green, blue, alpha,
    red, green, blue, alpha,
    red, green, blue, alpha,
  };
  glVertexPointer(2, GL_FLOAT, 0, squareVertices);
  glEnableClientState(GL_VERTEX_ARRAY);
  glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
  glEnableClientState(GL_COLOR_ARRAY);
  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}
void drawCircle(float x,float y,int divides,float radius,int red,int green,int blue,int alpha){
  //頂点指定
  GLfloat vertices[divides*3*2];
  int vertexid = 0;
  for(int i=0;i<divides;i++){
    float theta1 = 2.0f/(float)divides * (float)i * M_PI;
    float theta2 = 2.0f/(float)divides * (float)(i+1) * M_PI;
    vertices[vertexid++]=x;
    vertices[vertexid++]=y;
    vertices[vertexid++]=cos(theta1)*radius+x;
    vertices[vertexid++]=sin(theta1)*radius+y;
    vertices[vertexid++]=cos(theta2)*radius+x;
    vertices[vertexid++]=sin(theta2)*radius+y;
  }
  //色指定
  glColor4ub(red, green, blue, alpha);
  glDisableClientState(GL_COLOR_ARRAY);
  glVertexPointer(2, GL_FLOAT, 0, vertices);
  glEnableClientState(GL_VERTEX_ARRAY);
  glDrawArrays(GL_TRIANGLES, 0, divides*3);
}
GLuint loadTexture(NSString* fileName){
  GLuint texture;

  //画像ファイルを展開しCGImageRefを生成します
  CGImageRef image = [UIImage imageNamed:fileName].CGImage;
  if(!image){ //画像ファイルの読み込みに失敗したらfalse(0)を返します
    NSLog(@"Error: %@ not found",fileName);
    return 0;
  }

  //画像の大きさを取得します
  size_t width = CGImageGetWidth(image);
  size_t height = CGImageGetHeight(image);

  //ビットマップデータを用意します
  GLubyte* imageData = (GLubyte *) malloc(width * height * 4);
  CGContextRef imageContext = CGBitmapContextCreate(imageData,width,height,8,width * 4,CGImageGetColorSpace(image),kCGImageAlphaPremultipliedLast);
  CGContextDrawImage(imageContext, CGRectMake(0, 0, (CGFloat)width, (CGFloat)height), image);
  CGContextRelease(imageContext);

  //OpenGL用のテクスチャを生成します
  glGenTextures(1, &texture);
  glBindTexture(GL_TEXTURE_2D, texture);
  glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
  free(imageData);

  //作成したテクスチャを返します
  return texture;
}

//指定した位置にテクスチャを描画します
void drawTexture(float x, float y, float width, float height, GLuint texture, int red, int green, int blue, int alpha){
  drawTexture(x, y, width, height, texture, 0.0f, 0.0f, 1.0f, 1.0f, red, green, blue, alpha);
}

//指定した位置にテクスチャを描画します
//その際、元のテクスチャ画像のどの範囲を描画するかを指定します
void drawTexture(float x, float y, float width, float height, GLuint texture, float u, float v, float tex_width, float tex_height, int red, int green, int blue, int alpha){

  //長方形を構成する四つの頂点の座標を決定します
  const GLfloat squareVertices[] = {
    -0.5f*width + x,  -0.5f*height + y,
    0.5f*width + x, -0.5f*height + y,
    -0.5f*width + x,   0.5f*height + y,
    0.5f*width + x,  0.5f*height + y,
  };

  //長方形を構成する四つの頂点の色を指定します
  //ここではすべての頂点を同じ色にしています
  const GLubyte squareColors[] = {
    red, green, blue ,alpha,
    red, green, blue ,alpha,
    red, green, blue ,alpha,
    red, green, blue ,alpha,
  };

  //元画像のどの範囲を描画に使うかを決定します
  const GLfloat texCoords[] = {
    u,        v+tex_height,
    u+tex_width,  v+tex_height,
    u,        v,
    u+tex_width,  v,
  };

  //テクスチャ機能を有効にし、描画に使用するテクスチャを指定します
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, texture);

  //頂点座標と色、およびテクスチャの範囲を指定し、描画します
  glVertexPointer(2, GL_FLOAT, 0, squareVertices);
  glEnableClientState(GL_VERTEX_ARRAY);
  glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
  glEnableClientState(GL_COLOR_ARRAY);
  glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);

  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

  //テクスチャ機能を無効にします
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisable(GL_TEXTURE_2D);
}
/*
  void testTexture(){
  //フレームバッファを作成し、それをバインドします。
  GLuint framebuffer;
  glGenFramebuffersOES(1,&framebuffer);
  glBindFramebufferOES(GL_FRAMEBUFFER_OES,framebuffer);
  //テクスチャを作成
  GLuint texture = loadTexture(@"wall.png");
  glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, texture, 0);
  //深度バッファーを割り当ててアタッチする
  GLuint depthRenderbuffer;
  glGenRenderbuffersOES(1, &depthRenderbuffer);
  glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
  glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, width, height);
  glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES,
  depthRenderbuffer);
  //バッファーの完全性をテストする。
  GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
  if(status != GL_FRAMEBUFFER_COMPLETE) {
  NSLog(@"failed to make complete framebuffer object %x", status);
  }
  }*/
