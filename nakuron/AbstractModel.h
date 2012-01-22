#pragma once

#include "nakuron.h"

class AbstractModel;

// 1件のうちのキーと値は map<string, string> で表しておく
typedef std::map<std::string, std::string> KeyValue;

// 型
typedef std::map<std::string, std::string> ValueType;

// Where の各節
struct Where {
  std::string key, op, value;
  Where(std::string k, std::string o, std::string v) {
    key = k; op = o; value = v;
  }
};

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
public:
  FindClause();
  FindClause cnf();
  FindClause dnf();
  FindClause where(std::string key, std::string op, std::string value);
  FindClause where_or(std::string key, std::string op, std::string value);
  FindClause where_and(std::string key, std::string op, std::string value);
  FindClause order(std::string key, std::string ord="asc");
  FindClause limit(int _limit);
  FindClause group(std::string _group);
  FindClause having(std::string _having);

  std::string selectString(AbstractModel *mdl);
  std::string updateString(AbstractModel *mdl);
private:
  bool _dnf;
  //  std::string _where;
  //  std::vector<std::string> _where_and, _where_or;
  std::vector<Where> _where;
  std::vector<std::vector<Where> > _where_and, _where_or;
  std::string _order, _group, _having;
  int _limit;

  std::string whereString(AbstractModel *mdl);
  std::string addWhereString(std::vector<Where> &where, AbstractModel *mdl);
};

class AbstractModel {
  friend std::string FindClause::addWhereString(std::vector<Where> &where, AbstractModel *mdl);
public:
  AbstractModel();
  virtual ~AbstractModel();
  std::vector<KeyValue> get(int key);  
  std::vector<KeyValue> find(FindClause fc);
  std::vector<KeyValue> findAll(FindClause fc);
  bool insert(KeyValue kv);
  bool update(KeyValue kv, FindClause fc);
  bool remove(FindClause fc); // delete は予約語だから使えない(´･_･`)
  bool query(std::string q);
  ValueType getFields();
protected:
  std::vector<KeyValue> executeQuery(std::string query, bool no_transaction = false);
  bool executeUpdate(std::string query, bool no_transaction = false);
  ValueType fields;
  std::string primary;
  std::string table;
private:
  std::vector<KeyValue> fetch(FMResultSet *rs);
  void debug(std::string query);
};