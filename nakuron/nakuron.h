#pragma once

#include <exception>
#include <string>
#include <map>
#include <vector>
#include <cstring>
#include <cstdlib>
#include <complex>
#include <stdexcept>
#include <memory>

// SQLite3を扱うためのライブラリ
// トップレベルの ▼nakuron -> TARGETS -> nakuron -> Build Phases -> Link Binary With Libraries
// から libsqlite3.0.dylib を追加する。
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"

const float EPS = 1e-6;

const int MIN_PROBNUM = 1;
const int MAX_PROBNUM = 100;

const int MAX_BOARD_WIDTH = 32;
const float boardSizePx = 240.0;
const float boardLeftLowerX = -120.0;
const float boardLeftLowerY = -120.0;
const int colorNum = 4;

const int HOLE_RATIO = 80;

const float ANGLE_NUTRAL = 30.0f; // この角度以下は NUTRAL

const std::string DB_BASENAME = "nakuron.db";
#define DOCUMENT_DIR documentDir()
std::string documentDir();

#define Find(fc) auto_ptr<FindClause> fc(new FindClause()); fc
#define newFind(fc) fc=auto_ptr<FindClause>(new FindClause()); fc

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
  BROWN,
  RED_BROWN,
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

int randomProbNum();

int pieceToInt(Piece p);
int colorToInt(Color c);
int directionToInt(Direction d);
std::string pieceToStr(Piece p);
std::string colorToStr(Color c);
Color intToColor(int i);
int difficultyToInt(Difficulty d);
std::string difficultyToString(Difficulty d);
Difficulty stringToDifficulty(const std::string &s);
Difficulty intToDifficulty(int i);
int probNumToSeed(int p);
int difficultyToBoardSize(Difficulty d);

int removeCycle(std::vector<std::vector<PieceData> > &pd, int boardSize);

std::string intToString(int n);

std::string NSStringToString(NSString *ns);
NSString* stringToNSString(std::string s);
std::vector<std::string> string_split(std::string s, std::string c);
std::string string_join(std::vector<std::string> ss, std::string c);

std::string formattedTime();

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
struct VanishState{
  int num;
  std::complex<float> p;
  PieceData pd;
  VanishState(int n,std::complex<float> _p,PieceData _pd){
    num = n;
    p = _p;
    pd = _pd;
  }
};
struct BoardCoord{
  int r,c;
};
class ProgrammingException : public std::domain_error {
public:
  ProgrammingException(const std::string& cause)
  : std::domain_error("cause: " + cause) {}
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
//内積
double dot(const std::complex<float> & a, const std::complex<float> & b);

std::vector<std::vector<PieceData> > getBoard(Difficulty difficulty, int probNum);
