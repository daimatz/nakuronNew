#pragma once

#include <exception>
#include <string>
#include <map>
#include <vector>
#include <cstring>

const int MAX_BOARD_WIDTH = 32;

typedef enum {
  EMPTY,
  WALL,
  HOLE,
  BALL,
} Piece;

typedef enum {
  RED,
  GREEN,
  BLUE,
  YELLOW,
  BLACK,
  WHITE,
} Color;

typedef enum {
  DIFFICULTY_EASY = 0,
  DIFFICULTY_NORMAL = 1,
  DIFFICULTY_HARD = 2,
  DIFFICULTY_VERY_HARD = 3,
} Difficulty;

int pieceToInt(Piece p);
int colorToInt(Color c);
std::string pieceToStr(Piece p);
std::string colorToStr(Color c);
Color intToColor(int i);

struct PieceData {
  Piece piece;
  Color color;
  PieceData() { }
  PieceData(Piece p, Color c) {
    piece = p; color = c;
  }
  bool operator<(const PieceData &pd) const {
    int s = pieceToInt(piece), t = pieceToInt(pd.piece);
    if(s != t) return s<t;
    else return colorToInt(color)<colorToInt(pd.color);
  }
};

class ProgrammingException : std::exception {
public:
  ProgrammingException(const std::string& mes);
};

// ハッシュクラス
class Xor128 {
private:
  int x, y, z, w;
public:
  Xor128(int seed);
  
  int getInt();
  int randomInt(int to);
  int randomIntFrom(int from, int to);
};
