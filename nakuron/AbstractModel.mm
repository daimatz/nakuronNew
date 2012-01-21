#import "AbstractModel.h"
#include <stdio.h>

using namespace std;

//FindClause::FindClause(string t) {
//  _table = t;
//  _where = _order = _group = _having = "";
//  _where_and.clear();
//  _where_or.clear();
//  _limit = 0;
//}
FindClause::FindClause() {
  // return FindClause(""); // できない
  _dnf = true;
  _table = _where = _order = _group = _having = "";
  _where_and.clear();
  _where_or.clear();
  _limit = 0;

}
FindClause *FindClause::cnf() {
  if (!_where.empty() || !_where_or.empty() || !_where_and.empty()
      || !_order.empty() || !_group.empty() || !_having.empty()) {
    throw ProgrammingException("cnf()は最初に呼ぶ");
  }
  _dnf = false;
  return this;
}
FindClause *FindClause::dnf() {
  if (!_where.empty() || !_where_or.empty() || !_where_and.empty()
      || !_order.empty() || !_group.empty() || !_having.empty()) {
    throw ProgrammingException("dnf()は最初に呼ぶ");
  }
  _dnf = true;
  return this;
}  
FindClause *FindClause::where(string k, string o, string v) {
  if (!_where.empty()) _where += _dnf ? " AND " : " OR ";
  _where += "`"+k+"` "+o+" '"+v+"'";
  return this;
}
FindClause *FindClause::where_or(string k, string o, string v) {
  if (_dnf) _where_or.push_back("("+_where+") OR ");
  else throw ProgrammingException("CNFではwhere_orは呼ばない");
  _where = "`"+k+"` "+o+" '"+v+"'";
  return this;
}
FindClause *FindClause::where_and(string k, string o, string v) {
  if (!_dnf) _where_and.push_back("("+_where+") AND ");
  else throw ProgrammingException("DNFではwhere_andは呼ばない");
  _where = "`"+k+"` "+o+" '"+v+"'";
  return this;
}
FindClause *FindClause::order(string key, string ord) {
  if (ord[0] == 'a' || ord[0] == 'A') {
    ord = "ASC";
  } else if (ord[0] == 'd' || ord[0] == 'D') {
    ord = "DESC";
  } else {
    throw ProgrammingException("orderの指定がおかしい");
  }
  _order = " ORDER BY `"+key+"` "+ord;
  return this;
}
FindClause *FindClause::limit(int l) { _limit = l; return this;}
FindClause *FindClause::group(string g) { _group = g; return this;}
FindClause *FindClause::having(string h) { _having = h; return this;}
string FindClause::clause() {
  string ret;
  if (!_table.empty()) ret += "SELECT * FROM `"+_table+"`";
  if (!_where.empty()) {
    ret += " WHERE ";
    if (_dnf) {
      for (int i = 0; i < (int)_where_or.size(); i++) {
        ret += _where_or[i];
      }
    } else {
      for (int i = 0; i < (int)_where_and.size(); i++) {
        ret += _where_and[i];
      }
    }
    ret += _where;
  } else {
    if (!_where_or.empty() || !_where_and.empty()) {
      throw ProgrammingException("_whereはemptyなのに_where_orか_where_andがemptyでない");
    }
  }
  if (!_order.empty()) ret += _order;
  if (_limit != 0) ret += " LIMIT "+intToString(_limit);
  if (!_group.empty()) ret += " GROUP BY `"+_group+"`";
  if (!_having.empty()) ret += " HAVING "+_having;
  ret += ";";
  return ret;
}

FMDatabase *_db = NULL;

AbstractModel::AbstractModel() {
  if (_db == NULL) {
    NSLog(@"FMDatabase instanced");
    NSString *path = stringToNSString(documentDir()+"/"+DB_BASENAME);
    NSLog(@"DB filepath = %@", path);
    _db = [FMDatabase databaseWithPath:path];
  }
}

AbstractModel::~AbstractModel() {
}

vector<KeyValue> AbstractModel::get(int key) {
  FindClause *fc = new FindClause();
  fc = fc->where(primary, "=", intToString(key));
  vector<KeyValue> ret = find(fc);
  delete fc;
  return ret;
}

vector<KeyValue> AbstractModel::find(FindClause *fc) {
  fc = fc->limit(1);
  return findAll(fc);
}

vector<KeyValue> AbstractModel::findAll(FindClause *fc) {
  string q = "SELECT * FROM `"+table+"` ";
  q += fc->clause();
  FMResultSet *rs = executeQuery(q);
  return fetch(rs);
}

FMResultSet *AbstractModel::executeQuery(string query, bool noTransaction) {
  if (noTransaction) query += " (no transaction)";
  debug(query);
  if (!noTransaction) [_db beginTransaction];
  FMResultSet *ret = [_db executeQuery:stringToNSString(query)];
  if (!noTransaction) [_db commit];
  return ret;
}

bool AbstractModel::executeUpdate(string query, bool noTransaction) {
  if (![_db open]) {
    throw ProgrammingException("DB open failed");
  }
  if (noTransaction) query += " (no transaction)";
  debug(query);
  if (!noTransaction) [_db beginTransaction];
  bool ret = [_db executeUpdate:stringToNSString(query)];
  if (!noTransaction) [_db commit];
  if (![_db close]) {
    throw ProgrammingException("DB close failed");
  }
  return ret;
}

vector<KeyValue> AbstractModel::fetch(FMResultSet *rs) {
  vector<KeyValue> ret;
  while ([rs next]) {
    // とりあえず一旦全部 string として読む
    KeyValue kv;
    for (int i = 0; i < (int)fields.size(); i++) {
      string key = fields[i];
      string value = NSStringToString([rs stringForColumn:stringToNSString(key)]);
      kv.insert(KeyValue::value_type(key, value));
    }
    ret.push_back(kv);
  }
  return ret;
}

void AbstractModel::debug(string query) {
  NSLog(@"query = %s", query.c_str());
}
