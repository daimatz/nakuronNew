#pragma once

#include "AbstractModel.h"

class HistoryModel : public AbstractModel {
public:
  HistoryModel() {
    table = "history";
    primary = "id";
    max = HISTORY_MAX;
    fields["id"] = "int";
    fields["probNum"] = "int";
    fields["difficulty"] = "int";
    fields["score"] = "int";
    fields["created"] = "datetime";
    fields["time"] = "int";
    init();
  }
};
