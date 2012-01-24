#pragma once

#include "AbstractModel.h"

class HistoryModel : public AbstractModel {
public:
  HistoryModel() {
    table = "history";
    primary = "id";
    fields["id"] = "int";
    fields["probNum"] = "int";
    fields["step"] = "int";
    fields["created"] = "datetime";
    fields["time"] = "int";
    init();
  }
};
