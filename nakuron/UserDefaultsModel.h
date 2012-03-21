#pragma once

#include "nakuron.h"

class UserDefaultsModel {
public:
  static std::string get(std::string key);
  static void set(std::string key, std::string value);
};
