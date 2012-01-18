//
//  HistoryModel.h
//  nakuron
//


#include "AbstractModel.h"

class HistoryRecords : public AbstractRecords {
public:
  void init() {
    const int numFields = 5;
    std::string fields[numFields][2] = {
      {"id", "int"},
      {"probNum", "int"},
      {"step", "int"},
      {"date", "string"},
      {"time", "string"},
    };
    AbstractRecords::init(numFields, fields);
  }
};

class HistoryModel : public AbstractModel {
public:
  HistoryModel();
};
