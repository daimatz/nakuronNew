#include "ModelTest.h"

using namespace std;

extern FMDatabase *_db;

void ModelTest::test() {
  HistoryModel hmdl;
  if (![_db open]) {
    NSLog(@"Database open failed");
    return;
  }
  [_db beginTransaction];
  [_db executeUpdate:@"drop table if exists history;"];
  [_db executeUpdate:@"create table history (id integer primary key autoincrement, probNum int, step int, date text, time int);"];
  [_db executeUpdate:@"insert into history (probNum, step, date, time) values (1, 10, '2012-01-21 05:10:01', 101);"];
  [_db executeUpdate:@"insert into history (probNum, step, date, time) values (2, 10, '2012-01-21 05:10:02', 102);"];
  [_db executeUpdate:@"insert into history (probNum, step, date, time) values (3, 10, '2012-01-21 05:10:03', 103);"];
  [_db commit];
  FindClause *fc = (new FindClause())->cnf()
                 ->where("id", "<=", "2")
                 ->where("time",">=","102")
                 ->where_and("id", "=", "3")
                 ->order("id","desc");
  vector<KeyValue> v = hmdl.findAll(fc);
  for (int i = 0; i < (int)v.size(); i++) {
    NSLog(@"%s", v[i]["date"].c_str());
  }
  delete fc;
}
