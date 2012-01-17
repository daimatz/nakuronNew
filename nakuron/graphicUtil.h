
//
//  graphicUtol.h
//  OpenGLBook
//
//  Created by arai takahiro on 11/12/13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

void drawSquare();
void drawSquare(int red,int green,int blue,int alpha);
void drawSquare(float x,float y,int red,int green,int blue,int alpha);
void drawRectangle(float x,float y,float width,float height,int red,int green,int blue,int alpha);
void drawCircle(float x,float y,int divides,float radius,int red,int green,int blue,int alpha);
GLuint loadTexture(NSString *filename);
void drawTexture(float x,float y,float width,float height,GLuint texture,int red,int green,int blue,int alpha);
void drawTexture(float x, float y, float width, float height, GLuint texture, float u, float v, float tex_width, float tex_height, int red, int green, int blue, int alpha);