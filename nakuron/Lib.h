//
//  Lib.h
//  nakuron
//

#import <Foundation/Foundation.h>

int SCREEN_WIDTH, SCREEN_HEIGHT;

@interface Xor128 : NSObject {
  int x, y, z, w;
}

+(Xor128*)xor128WithSeed:(int)seed;
-(Xor128*)initWithSeed:(int)seed;
-(int)getInt;

// [0, to)
-(int)randomInt:(int)to;
// [from, to]
-(int)randomIntFrom:(int)from to:(int)to;

@end
