//
//  AbstractModel.m
//  nakuron
//

#import "AbstractModel.h"
#include <stdio.h>

using namespace std;

void AbstractRecords::init(int n, std::string fs[][2]) {
  for (int i = 0; i < n; i++) {
    fields.push_back(pair<string, string>(fs[i][0], fs[i][1]));
  }
}

AbstractModel::AbstractModel() {
  NSLog(@"AbstractModel::AbstractModel()");
  ud = [NSUserDefaults standardUserDefaults];
}

AbstractModel::~AbstractModel() {
  [ud release];
}

NSDictionary* AbstractModel::get(int key) {
  return [ud objectForKey:keyName(key)];
}

BOOL AbstractModel::set(int key, NSDictionary *dic) {
  [ud setObject:dic forKey:keyName(key)];
  return [ud synchronize];
}

string AbstractModel::insert(NSDictionary *dic) {
}

BOOL AbstractModel::remove(int key) {
  [ud removeObjectForKey:keyName(key)];
}

NSString *AbstractModel::keyName(int key) {
  char s[32];
  sprintf(s, "%d", key);
  string k(s);
  return stringToNSString(unique_id+"_"+k);
}
