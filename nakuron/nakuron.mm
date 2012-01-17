#include "nakuron.h"

using namespace std;

int pieceToInt(Piece p) {
  switch (p) {
    case EMPTY: return 0;
    case WALL: return 1;
    case HOLE: return 2;
    case BALL: return 3;
    default: throw ProgrammingException("Piece おかしい");
  }
}

int colorToInt(Color c) {
  switch (c) {
    case RED: return 0;
    case GREEN: return 1;
    case BLUE: return 2;
    case YELLOW: return 3;
    case BLACK: return 4;
    case WHITE: return 5;
    default: throw ProgrammingException("Color おかしい");
  }
}

Color intToColor(int i) {
  switch (i) {
    case 0: return RED;
    case 1: return GREEN;
    case 2: return BLUE;
    case 3: return YELLOW;
    case 4: return BLACK;
    case 5: return WHITE;
    default: throw ProgrammingException("intToColor(i) おかしい");
  }
}

int probNumToSeed(int p) {
  return 4;
}

int difficultyToBoardSize(Difficulty d) {
  int b;
  switch (d) {
    case DIFFICULTY_EASY: b = 4; break;
    case DIFFICULTY_NORMAL: b = 8; break;
    case DIFFICULTY_HARD: b = 16; break;
    case DIFFICULTY_VERY_HARD: b = 32; break;
    default: throw ProgrammingException("difficulty おかしい");
  }
  return b+2;
}

ProgrammingException::ProgrammingException(const string& mes) {

}

// ハッシュクラス
Xor128::Xor128(int seed) {
  x = 123456789, y = 362436069, z = 521288629, w = seed;
}
int Xor128::getInt() {
  int t = (x^(x<<11));
  x=y;y=z;z=w;
  return ( w=(w^((w>>19)&0x1FFF))^(t^((t>>8)&0xFFFFFF)) ) & 0x7FFFFFFF;
}
int Xor128::randomInt(int to) {
  return randomIntFrom(0, to-1);
}
int Xor128::randomIntFrom(int from, int to) {
  assert(from <= to);
  int size = to - from + 1;
  int r = getInt() % size;
  if (r < 0) r += size;
  return from + r;
}