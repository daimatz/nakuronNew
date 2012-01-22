#import "AbstractModel.h"
#include <stdio.h>
#include <algorithm>

using namespace std;

string FindClause::typeFunctionMap(const string &t) {
  if (t == "datetime") return "datetime";
  return "";
}

FindClause::FindClause() {
  // return FindClause(""); // できない
  NSLog(@"constructed FindClause");
  _dnf = true;
  _where.clear();
  _where_and.clear();
  _where_or.clear();
  _order = _group = _having = "";
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
FindClause *FindClause::where(const string &k, const string &o, const string &v) {
  _where.push_back(Where(k,o,v));
  return this;
}
FindClause *FindClause::where_or(const string &k, const string &o, const string &v) {
  if (_dnf) _where_or.push_back(_where);
  else throw ProgrammingException("CNFではwhere_orは呼ばない");
  _where.clear();
  where(k, o, v);
  return this;
}
FindClause *FindClause::where_and(const string &k, const string &o, const string &v) {
  if (!_dnf) _where_and.push_back(_where);
  else throw ProgrammingException("DNFではwhere_andは呼ばない");
  _where.clear();
  where(k, o, v);
  return this;
}
FindClause *FindClause::order(const string &key, string ord) {
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
FindClause *FindClause::group(const string &g) { _group = g; return this;}
FindClause *FindClause::having(const string &h) { _having = h; return this;}
string FindClause::selectString(AbstractModel *mdl) {
  string ret;
  ret += whereString(mdl);
  if (!_order.empty()) ret += _order;
  if (_limit != 0) ret += " LIMIT "+intToString(_limit);
  if (!_group.empty()) ret += " GROUP BY `"+_group+"`";
  if (!_having.empty()) ret += " HAVING "+_having;
  ret += ";";
  return ret;
}
string FindClause::updateString(AbstractModel *mdl) {
  return whereString(mdl)+";";
}
string FindClause::whereString(AbstractModel *mdl) {
  string ret;
  if (!_where.empty()) {
    ret += " WHERE ";
    if (_dnf) {
      for (int i = 0; i < (int)_where_or.size(); i++) {
        ret += addWhereString(_where_or[i], mdl) + " OR ";
      }
    } else {
      for (int i = 0; i < (int)_where_and.size(); i++) {
        ret += addWhereString(_where_and[i], mdl) + " AND ";
      }
    }
    ret += addWhereString(_where, mdl);
  } else {
    if (!_where_or.empty() || !_where_and.empty()) {
      throw ProgrammingException("_whereはemptyなのに_where_orか_where_andがemptyでない");
    }
  }
  return ret;
}
string FindClause::addWhereString(const vector<Where> &where, AbstractModel *mdl) {
  string ret;
  for (int i = 0; i < (int)where.size(); i++) {
    // 見ようとしているキーが存在するか
    if ((mdl->fields).count(where[i].key) > 0) {
      string func;
      // そのキーの型の値に対してSQLiteの関数を通す
      func = typeFunctionMap(mdl->fields[where[i].key]);

      if (!ret.empty()) ret += _dnf ? " AND " : " OR ";
      if (func.empty()) {
        ret += "`"+where[i].key+"`"+where[i].op+"'"+where[i].value+"'";
      } else {
        ret += func+"(`"+where[i].key+"`)"+where[i].op+func+"('"+where[i].value+"')";
      }
    } else {
      throw ProgrammingException(mdl->table+"には"+where[i].key+"というキーは存在しない");
    }
  }
  return "("+ret+")";
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
  auto_ptr<FindClause> fc(new FindClause());
  fc->where(primary, "=", intToString(key));
  vector<KeyValue> ret = find(fc);
  return ret;
}

vector<KeyValue> AbstractModel::find(auto_ptr<FindClause> fc) {
  fc->limit(1);
  return findAll(fc);
}

vector<KeyValue> AbstractModel::findAll(auto_ptr<FindClause> fc) {
  string q = "SELECT * FROM `"+table+"` ";
  q += fc->selectString(this);
  return executeQuery(q);
}

bool AbstractModel::insert(KeyValue kv) {
  string query = "INSERT INTO `"+table+"` ", ks, vs;
  KeyValue::iterator it = kv.begin();
  while (true) {
    ks += "`"+it->first+"`";
    vs += "'"+it->second+"'";
    if (++it == kv.end()) break;
    ks += ", "; vs += ", ";
  }
  query += "("+ks+") VALUES ("+vs+");";
  return executeUpdate(query);
}

bool AbstractModel::update(KeyValue kv, auto_ptr<FindClause> fc) {
  string query = "UPDATE `"+table+"` SET ", kvs;
  KeyValue::iterator it = kv.begin();
  while (true) {
    kvs += "`"+it->first+"`='"+it->second+"'";
    if (++it == kv.end()) break;
    kvs += ", ";
  }
  query += kvs+fc->updateString(this);
  return executeUpdate(query);
}

bool AbstractModel::remove(auto_ptr<FindClause> fc) {
  string query = "DELETE FROM `"+table+"`"+fc->updateString(this);
  return executeUpdate(query);
}

// いちいち close しているので大量に呼ばれると遅い気がする
vector<KeyValue> AbstractModel::executeQuery(const string &query, bool no_transaction) {
  if (![_db open]) {
    throw ProgrammingException("DB open failed");
  }
  debug(query+(no_transaction?" (no transaction)":""));
  if (!no_transaction) [_db beginTransaction];
  FMResultSet *rs = [_db executeQuery:stringToNSString(query)];
  if (!no_transaction) [_db commit];
  vector<KeyValue> ret = fetch(rs);
  if (![_db close]) {
    throw ProgrammingException("DB close failed");
  }
  return ret;
}

bool AbstractModel::executeUpdate(const string &query, bool no_transaction) {
  if (![_db open]) {
    throw ProgrammingException("DB open failed");
  }
  debug(query+(no_transaction?" (no transaction)":""));
  if (!no_transaction) [_db beginTransaction];
  bool ret = [_db executeUpdate:stringToNSString(query)];
  if (!no_transaction) [_db commit];
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
    //for (int i = 0; i < (int)fields.size(); i++) {
    for (ValueType::iterator it = fields.begin();
         it != fields.end();
         it++) {
      string key = it->first;
      string value = NSStringToString([rs stringForColumn:stringToNSString(key)]);
      kv.insert(KeyValue::value_type(key, value));
    }
    ret.push_back(kv);
  }
  NSLog(@"%d columns found.", (int)ret.size());
  return ret;
}

bool AbstractModel::query(const std::string &q) {
  int i = 0;
  while (q[i] == ' ' || q[i] == '\t' || q[i] == '\n')
    i++;
  string st = q.substr(i, string("SELECT").size());
  std::transform(st.begin(), st.end(), st.begin(), ::toupper);
  
  // SELECT 文かどうかで変える
  if (st == "SELECT") {
    debug(q);
    executeQuery(q);
  } else {
    debug(q);
    executeUpdate(q);
  }
  
  return [_db lastErrorCode] == 0 ? true : false;
}

void AbstractModel::debug(const string &query) {
  NSLog(@"query = %s", query.c_str());
}
