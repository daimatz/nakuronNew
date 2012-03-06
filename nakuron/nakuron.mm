#include "nakuron.h"
#include<iostream>

using namespace std;

int randomProbNum() {
  return (((arc4random() & 0x7FFFFFFF) % MAX_PROBNUM) + MIN_PROBNUM);
}

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
    case BROWN: return 6;
    case RED_BROWN: return 7;
    default: throw ProgrammingException("Color おかしい");
  }
}
int directionToInt(Direction d){
  switch(d){
    case RIGHT:return 0;
    case UP:return 1;
    case LEFT:return 2;
    case DOWN:return 3;
    default: throw ProgrammingException("Direction おかしい");
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
    case BROWN: return "Brown";
    case RED_BROWN: return "RedBrown";
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
    case EASY: return 0;
    case NORMAL: return 1;
    case HARD: return 2;
    case VERY_HARD: return 3;
    default: throw ProgrammingException("difficultyToInt(d) おかしい");
  }
}

string difficultyToString(Difficulty d) {
  string str[4] = {"Easy", "Normal", "Hard", "Very Hard"};
  return str[difficultyToInt(d)];
}

Difficulty stringToDifficulty(const string &s) {
  if (s == "Easy") return EASY;
  else if (s == "Normal") return NORMAL;
  else if (s == "Hard") return HARD;
  else if (s == "Very Hard") return VERY_HARD;
  else throw ProgrammingException("Difficulty String がおかしい");
}

Difficulty intToDifficulty(int i) {
  switch (i) {
    case 0: return EASY;
    case 1: return NORMAL;
    case 2: return HARD;
    case 3: return VERY_HARD;
    default: throw ProgrammingException("intToDifficulty(d) おかしい");
  }
}

int probNumToSeed(int p) {
  return (p % MAX_PROBNUM) + 1;
}

int difficultyToBoardSize(Difficulty d) {
  int b;
  switch (d) {
    case EASY: b = 4; break;
    case NORMAL: b = 8; break;
    case HARD: b = 16; break;
    case VERY_HARD: b = 32; break;
    default: throw ProgrammingException("difficultyToBoardSize(d) おかしい");
  }
  return b+2;
}

void removeCycleRec(int temp[MAX_BOARD_WIDTH+2][MAX_BOARD_WIDTH+2], int size, int sx, int sy) {
  int dx[] = {-1,0,1,0}, dy[] = {0,-1,0,1};
  // ある箇所が 1 or 2 ならその周りは全部 2
  if (temp[sx][sy] == 1 || temp[sx][sy] == 2) {
    for (int i = 0; i < 4; i++) {
      if (0 <= sx+dx[i] && sx+dx[i] < size // 次の x が範囲内
          && 0 <= sy+dy[i] && sy+dy[i] < size // 次の y が範囲内
          && temp[sx+dx[i]][sy+dy[i]] == 0) { // 次の (x,y) をまだ調べてない
        temp[sx+dx[i]][sy+dy[i]] = 2;
        removeCycleRec(temp, size, sx+dx[i], sy+dy[i]);
      }
    }
  }
}

// 閉路を壁で埋める。閉路 => Cycle?
int removeCycle(vector<vector<PieceData> > &pd, int boardSize) {
  int count = 0; // 球の個数
  int temp[MAX_BOARD_WIDTH+2][MAX_BOARD_WIDTH+2];
  for (int i = 0; i < boardSize; i++) {
    for (int j = 0; j < boardSize; j++) {
      if (pd[i][j].piece == HOLE) temp[i][j] = 1;
      else if (pd[i][j].piece == WALL) temp[i][j] = -1;
      else if (pd[i][j].piece == BALL) temp[i][j] = 0;
      else throw ProgrammingException("EMPTYがある");
    }
  }
  for (int i = 0; i < boardSize; i++)
    for (int j = 0; j < boardSize; j++)
      removeCycleRec(temp, boardSize, i, j);
  for (int i = 0; i < boardSize; i++) {
    for (int j = 0; j < boardSize; j++) {
      // 0 のまま残ったところが閉路
      if (temp[i][j] == 0) {
        pd[i][j].piece = WALL;
        pd[i][j].color = BLACK;
      } else if (temp[i][j] == 2) {
        count++;
      }
      //printf("%2d ", temp[i][j]);
    }
    //printf("\n");
  }
  return count;
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

string formattedTime() {
  // 時刻を取得
  time_t current;
  struct tm *local;
  time(&current);
  local = localtime(&current);
  char ret[20];
  sprintf(ret, "%04d/%02d/%02d %02d:%02d:%02d", 1900+local->tm_year, 1+local->tm_mon, local->tm_mday, local->tm_hour, local->tm_min, local->tm_sec);
  return string(ret);
}

// ドキュメントディレクトリのパスを std::string で得る
// ここにDBファイルとか置く
string documentDir() {
  static string dir;
  if (dir.empty()) {
    dir = NSStringToString([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]);
  }
  return dir;
}

void drawMapToSubview(Difficulty difficulty, int probNum, UIView *view) {
  int boardSize = difficultyToBoardSize(difficulty);
  int cellSizePx = boardSizePx / boardSize;
  vector<vector<PieceData> > pd = getBoard(difficulty, probNum);
  NSString *cs[] = {@"red", @"green", @"blue", @"yellow"};
  for (int r = 0; r < boardSize; r++) {
    for (int c = 0; c < boardSize; c++) {
      CGRect frame = CGRectMake(c*cellSizePx, r*cellSizePx, cellSizePx, cellSizePx);
      UIImageView *imgs = [[[UIImageView alloc]
                            initWithFrame:frame] autorelease];
      NSString *imgFile;
      if (pd[r][c].piece == WALL) {
        imgFile = @"wall.png";
      } else if (pd[r][c].piece == HOLE) {
        imgFile = [NSString stringWithFormat:@"h%@2.png", cs[colorToInt(pd[r][c].color)]];
      } else {
        imgFile = [NSString stringWithFormat:@"b%@.png", cs[colorToInt(pd[r][c].color)]];
      }
      imgs.image = [UIImage imageNamed:imgFile];
      [view addSubview:imgs];
    }
  }
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
double dot(const complex<float> & a, const complex<float> & b){
  return real(conj(a)*b);
}
std::vector<std::vector<PieceData> > getBoard(Difficulty difficulty, int probNum){
  int hole = HOLE_RATIO;
  int wall = 100 - hole;
  
  Xor128 hash(probNum);
  int boardSize = difficultyToBoardSize(difficulty);
  vector<vector<PieceData> > pieces;
  for(int r=0;r<boardSize;r++){
    vector<PieceData> tv(boardSize);
    for(int c=0;c<boardSize;c++){
      if((r==0 && c==0) || (r==boardSize-1 && c==boardSize-1)) tv[c] = PieceData(WALL, BLACK);
      else if(r==0 || c==0 || r==boardSize-1 || c==boardSize-1 ){
        tv[c] = (hash.randomInt(100) < hole)
        ? PieceData(HOLE, intToColor(hash.randomInt(colorNum)))
        : ((hash.randomInt(100) < 50) 
           ? PieceData(WALL, BLACK):
           PieceData(WALL,BLACK));
      } else{
        tv[c] = (hash.randomInt(100) < wall)
        ? ((hash.randomInt(100) < 50) 
           ? PieceData(WALL, BLACK):
           PieceData(WALL,BLACK))
        : PieceData(BALL, intToColor(hash.randomInt(colorNum)));
      }
    }
    pieces.push_back(tv);
  }
  return pieces;
}
