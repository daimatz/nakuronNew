#pragma once

#include "nakuron.h"

// 1件のうちのキーと値は map<string, string> で表しておく
typedef std::map<std::string, std::string> KeyValue;

// find節。コンストラクタでテーブル名を指定。
// CNFはandでつなげる形、DNFはorでつなげる形。デフォルトはDNF
// FindClause fc = new FindClause();
// fc->cnf()->where("id","=","1")
//          ->where("date","=","2012-01-21 00:00:00")
//          ->where_or("date","=","2012-01-22 00:00:00");
// とすると、CNFで
// (id=1) and (date="2012-01-21 00:00:00" or date="2012-01-22 00:00:00)
// という形式のfind節を生成する
class FindClause {
private:
  bool _dnf;
  std::string _table;
  std::string _where;
  std::vector<std::string> _where_and, _where_or;
  std::string _order, _group, _having;
  int _limit;
public:
  //FindClause(std::string _table); // SELECT 文
  FindClause(); // UPDATE, DELETE 文
  FindClause *cnf();
  FindClause *dnf();
  FindClause *where(std::string key, std::string op, std::string value);
  FindClause *where_or(std::string key, std::string op, std::string value);
  FindClause *where_and(std::string key, std::string op, std::string value);
  FindClause *order(std::string key, std::string ord="asc");
  FindClause *limit(int _limit);
  FindClause *group(std::string _group);
  FindClause *having(std::string _having);
  std::string clause();
};

class AbstractModel {
public:
  AbstractModel();
  virtual ~AbstractModel();
  std::vector<KeyValue> get(int key);
  std::vector<KeyValue> find(FindClause *fc);
  std::vector<KeyValue> findAll(FindClause *fc);
protected:
  FMResultSet *executeQuery(std::string query, bool noTransaction = false);
  bool executeUpdate(std::string query, bool noTransaction = false);
  FMDatabase *db;
  std::vector<std::string> fields;
  std::string primary;
  std::string table;
private:
  std::vector<KeyValue> fetch(FMResultSet *rs);
  void debug(std::string query);
};