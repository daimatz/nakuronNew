#include "UserDefaultsModel.h"

using namespace std;

string UserDefaultsModel::get(string key) {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
  [defaults setObject:@"" forKey:stringToNSString(key)];
  [ud registerDefaults:defaults];
  return NSStringToString([ud stringForKey:stringToNSString(key)]);
}

void UserDefaultsModel::set(string key, string value) {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  [ud setObject:stringToNSString(value) forKey:stringToNSString(key)];
  [ud synchronize];
}