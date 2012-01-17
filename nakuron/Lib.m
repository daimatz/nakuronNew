//
//  Lib.m
//  nakuron
//

#import "Lib.h"

@implementation Xor128

+(Xor128*)xor128WithSeed:(int)seed {
  return [[[Xor128 alloc] initWithSeed:seed] autorelease];
}

-(Xor128*)initWithSeed:(int)seed {
  x = 123456789, y = 362436069, z = 521288629, w = seed;
  return self;
}

-(int)getInt {
  int t = (x^(x<<11));
  x=y;y=z;z=w;
  return ( w=(w^((w>>19)&0x1FFF))^(t^((t>>8)&0xFFFFFF)) ) & 0x7FFFFFFF;
}

-(int)randomInt:(int)to {
  return [self randomIntFrom:0 to:to - 1];
}

-(int)randomIntFrom:(int)from to:(int)to {
  assert(from <= to);
  int size = to - from + 1;
  int r = [self getInt] % size;
  if (r < 0) r += size;
  return from + r;
}

@end
