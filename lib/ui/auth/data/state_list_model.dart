class StateListModel {
  int? code;
  bool? error;
  String? nums;
  String? totalData;
  String? msg;
  List<StateList>? stateList;

  StateListModel(
      {this.code,
        this.error,
        this.nums,
        this.totalData,
        this.msg,
        this.stateList});

  StateListModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    error = json['error'];
    nums = json['nums'] ?? "";
    totalData = json['TotalData'] ?? "";
    msg = json['msg'] ?? "";
    if (json['StateList'] != null) {
      stateList = <StateList>[];
      json['StateList'].forEach((v) {
        stateList!.add(StateList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['error'] = error;
    data['nums'] = nums;
    data['TotalData'] = totalData;
    data['msg'] = msg;
    if (stateList != null) {
      data['StateList'] = stateList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StateList {
  String? id;
  String? stateName;

  StateList({this.id, this.stateName});

  StateList.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    stateName = json['state_name'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['state_name'] = stateName;
    return data;
  }
}
