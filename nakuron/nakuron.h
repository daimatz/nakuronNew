#pragma once

#include <exception>
#include <string>
#include <map>
#include <vector>
#include <cstring>
#include <cstdlib>

// SQLite3を扱うためのライブラリ
// トップレベルの ▼nakuron -> TARGETS -> nakuron -> Build Phases -> Link Binary With Libraries
// から libsqlite3.0.dylib を追加する。
#include "FMDatabase.h"
#include "FMDatabaseAdditions.h"
#include "FMResultSet.h"

const float EPS = 1e-6;

const int MIN_PROBNUM = 1;
const int MAX_PROBNUM = 100;

const int MAX_BOARD_WIDTH = 32;
const float boardSizePx = 240.0;
const float boardLeftLowerX = -120.0;
const float boardLeftLowerY = -120.0;
const int colorNum = 4;

const int HOLE_RATIO = 80;

const std::string DB_BASENAME = "nakuron.db";
#define DOCUMENT_DIR documentDir()
std::string documentDir();

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
  EASY,
  NORMAL,
  HARD,
  VERY_HARD,
} Difficulty;

typedef enum {
  UP,
  LEFT,
  DOWN,
  RIGHT,
} Direction;

struct PieceData;

int pieceToInt(Piece p);
int colorToInt(Color c);
int directionToInt(Direction d);
std::string pieceToStr(Piece p);
std::string colorToStr(Color c);
Color intToColor(int i);
int difficultyToInt(Difficulty d);
std::string difficultyToString(Difficulty d);
Difficulty intToDifficulty(int i);
int probNumToSeed(int p);
int difficultyToBoardSize(Difficulty d);

bool validatePieces(PieceData pd[MAX_BOARD_WIDTH+2][MAX_BOARD_WIDTH+2], int boardSize, int sx, int sy);

std::string intToString(int n);

std::string NSStringToString(NSString *ns);
NSString* stringToNSString(std::string s);
std::vector<std::string> string_split(std::string s, std::string c);
std::string string_join(std::vector<std::string> ss, std::string c);

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
