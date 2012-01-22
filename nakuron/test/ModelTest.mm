#include "ModelTest.h"

using namespace std;

void ModelTest::test() {
  HistoryModel mdl;

  mdl.query("drop table if exists history;");
  mdl.query("create table history (id integer primary key autoincrement, probNum int, step int, created text, time int);");

  KeyValue kv;
  kv["probNum"] = "1";
  kv["step"] = "10";
  kv["created"] = "2012-01-21 05:10:01";
  kv["time"] = "101";
  mdl.insert(kv);
 
  kv["probNum"] = "2";
  kv["step"] = "20";
  kv["created"] = "2012-01-21 05:20:02";
  kv["time"] = "202";
  mdl.insert(kv);

  kv["probNum"] = "3";
  kv["step"] = "30";
  kv["created"] = "2012-01-21 05:30:03";
  kv["time"] = "103";
  mdl.insert(kv);

  FindClause fc1;
  fc1 = fc1.where("id", "<=", "2").where("time",">=","102").where_or("id", "=", "3");
  mdl.update(kv, fc1);
  
  FindClause fc2 = FindClause().cnf().where("id", "<=", "2").where("time",">=","102").where_and("id", "=", "3");
  mdl.remove(fc2);
  
  fc1 = fc1.order("id","desc");

  vector<KeyValue> v = mdl.findAll(fc1);
  for (int i = 0; i < (int)v.size(); i++) {
    NSLog(@"%s", v[i]["created"].c_str());
  }
}
