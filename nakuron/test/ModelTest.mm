#include "ModelTest.h"

extern HistoryModel *HistoryMdl;
using namespace std;

void ModelTest::test() {
  HistoryMdl->query("drop table if exists history;");
  HistoryMdl->query("create table history (id integer primary key autoincrement, probNum int, step int, date text, time int);");

  KeyValue kv1;
  kv1.insert(KeyValue::value_type("probNum","1"));
  kv1.insert(KeyValue::value_type("step","10"));
  kv1.insert(KeyValue::value_type("date","2012-01-21 05:10:01"));
  kv1.insert(KeyValue::value_type("time","101"));
  HistoryMdl->insert(kv1);
 
  KeyValue kv2;
  kv2.insert(KeyValue::value_type("probNum","2"));
  kv2.insert(KeyValue::value_type("step","20"));
  kv2.insert(KeyValue::value_type("date","2012-01-21 05:20:02"));
  kv2.insert(KeyValue::value_type("time","202"));
  HistoryMdl->insert(kv2);

  KeyValue kv3;
  kv3.insert(KeyValue::value_type("probNum","3"));
  kv3.insert(KeyValue::value_type("step","30"));
  kv3.insert(KeyValue::value_type("date","2012-01-21 05:30:03"));
  kv3.insert(KeyValue::value_type("time","103"));
  HistoryMdl->insert(kv3);

  FindClause *fc1 = (new FindClause())//->cnf()
                 ->where("id", "<=", "2")
                 ->where("time",">=","102")
                 ->where_or("id", "=", "3");
  HistoryMdl->update(kv3, fc1);
  
  FindClause *fc2 = (new FindClause())->cnf()
  ->where("id", "<=", "2")
  ->where("time",">=","102")
  ->where_and("id", "=", "3");
  HistoryMdl->remove(fc2);
  
  fc1 = fc1->order("id","desc");

  vector<KeyValue> v = HistoryMdl->findAll(fc1);
  for (int i = 0; i < (int)v.size(); i++) {
    NSLog(@"%s", v[i]["date"].c_str());
  }
  delete fc1, fc2;
}
