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
string pieceToStr(Piece p){
  switch(p){
    case EMPTY: return "E";
    case WALL: return "W";
    case HOLE: return "H";
    case BALL: return "B";
    default: throw ProgrammingException("Piece おかしい");
  }
}
string colorToStr(Color c){
  switch (c) {
    case RED: return "Red";
    case GREEN: return "Green";
    case BLUE: return "Blue";
    case YELLOW: return "Yellow";
    case BLACK: return "Black";
    case WHITE: return "White";
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

int difficultyToInt(Difficulty d) {
  switch (d) {
    case DIFFICULTY_EASY: return 0;
    case DIFFICULTY_NORMAL: return 1;
    case DIFFICULTY_HARD: return 2;
    case DIFFICULTY_VERY_HARD: return 3;
    default: throw ProgrammingException("difficultyToInt(d) おかしい");
  }
}

string difficultyToString(Difficulty d) {
  string str[4] = {"Easy", "Normal", "Hard", "Very Hard"};
  return str[difficultyToInt(d)];
}

Difficulty intToDifficulty(int i) {
  switch (i) {
    case 0: return DIFFICULTY_EASY;
    case 1: return DIFFICULTY_NORMAL;
    case 2: return DIFFICULTY_HARD;
    case 3: return DIFFICULTY_VERY_HARD;
    default: throw ProgrammingException("intToDifficulty(d) おかしい");
  }
}

int probNumToSeed(int p) {
  return (p % MAX_PROBNUM) + 1;
}

int difficultyToBoardSize(Difficulty d) {
  int b;
  switch (d) {
    case DIFFICULTY_EASY: b = 4; break;
    case DIFFICULTY_NORMAL: b = 8; break;
    case DIFFICULTY_HARD: b = 16; break;
    case DIFFICULTY_VERY_HARD: b = 32; break;
    default: throw ProgrammingException("difficultyToBoardSize(d) おかしい");
  }
  return b+2;
}

string intToString(int n) {
  char buf[32];
  sprintf(buf, "%d", n);
  return string(buf);
}

string NSStringToString(NSString* ns) {
  return string([ns UTF8String]);
}

NSString* stringToNSString(string s) {
  return [NSString stringWithFormat:@"%s", s.c_str()];
}

vector<string> string_split(string s, string c) {
  vector<string> ret;
  for( int i=0, n; i <= s.length(); i=n+1 ){
    n = s.find_first_of( c, i );
    if( n == string::npos ) n = s.length();
    string tmp = s.substr( i, n-i );
    ret.push_back(tmp);
  }
  return ret;
}

string string_join(vector<string> ss, string c) {
  string ret;
  for (int i = 0; i < (int)ss.size(); i++) {
    ret += ss[i];
    if (i != (int)ss.size() - 1)
      ret += c;
  }
  return ret;
}

string documentDir() {
  static string path;
  if (path == "") {
    NSArray* writePashs;
    writePashs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = NSStringToString([writePashs objectAtIndex:0]);
  }
  return path;
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