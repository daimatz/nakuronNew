#include "HistoryModel.h"

HistoryModel *HistoryMdl = new HistoryModel();

HistoryModel::HistoryModel() {
  fields.push_back("id");
  fields.push_back("probNum");
  fields.push_back("step");
  fields.push_back("date");
  fields.push_back("time");
  primary = "id";
  table = "history";
}
