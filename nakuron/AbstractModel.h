//
//  AbstractModel.h
//  nakuron
//

#include "nakuron.h"

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