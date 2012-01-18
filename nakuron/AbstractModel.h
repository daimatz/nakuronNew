//
//  AbstractModel.h
//  nakuron
//

#include "nakuron.h"

//struct kvtype {
//  std::string keyType;
//  std::string valueType;
//  kvtype(std::string kt, std::string vt) {
//    keyType = kt; valueType = vt;
//  }
//};
typedef std::pair<std::string, std::string> kvtype;

class AbstractRecords {
public:
  void init(int n, std::string fs[][2]);
private:
  std::vector<std::pair<std::string, std::string> > fields;
};

class AbstractModel {
public:
  AbstractModel();
  virtual ~AbstractModel();
  NSDictionary *get(int key);
  BOOL set(int key, NSDictionary *dic);
  std::string insert(NSDictionary *dic);
  BOOL remove(int key);
protected:
  std::string unique_id;
  NSUserDefaults* ud;
private:
  NSString *keyName(int key);
};