#include "ModelTest.h"

using namespace std;

void ModelTest::test() {
  FMDatabase *db;

  HistoryModel hmdl;
  string db_filepath = documentDir()+"/"+DB_BASENAME;
  NSLog(@"%@", stringToNSString(db_filepath));
  [db open];
  [db beginTransaction];
  [db executeUpdate:@"drop table if exists history;"];
  [db executeUpdate:@"create table history (id integer primary key autoincrement, probNum int, step int, date text, time int);"];
  [db executeUpdate:@"insert into history (probNum, step, date, time) values (1, 10, '2012-01-21 05:10:01', 101);"];
  [db executeUpdate:@"insert into history (probNum, step, date, time) values (2, 10, '2012-01-21 05:10:02', 102);"];
  [db executeUpdate:@"insert into history (probNum, step, date, time) values (3, 10, '2012-01-21 05:10:03', 103);"];
  [db commit];
  FindClause *fc = new FindClause();
  fc = fc->cnf()
  ->where("id", "<=", "2")
  ->where("time",">=","102")
  ->where_and("id", "=", "3");
  vector<KeyValue> v = hmdl.findAll(fc);
  for (int i = 0; i < (int)v.size(); i++) {
    NSLog(@"%s", v[i]["date"].c_str());
  }
  delete fc;
}
