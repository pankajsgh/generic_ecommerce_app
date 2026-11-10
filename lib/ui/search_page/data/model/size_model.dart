class SizeResponseModel {
  final int code;
  final bool error;
  final String nums;
  final String totalData;
  final String msg;
  final List<SizeModel> sizeList;

  SizeResponseModel({
    required this.code,
    required this.error,
    required this.nums,
    required this.totalData,
    required this.msg,
    required this.sizeList,
  });

  factory SizeResponseModel.fromJson(Map<String, dynamic> json) {
    return SizeResponseModel(
      code: int.tryParse(json['code']?.toString() ?? '') ?? 0,
      error: json['error'] == true,
      nums: json['nums']?.toString() ?? '',
      totalData: json['TotalData']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
      sizeList: (json['SizeList'] as List?)
          ?.map(
            (e) => SizeModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'error': error,
      'nums': nums,
      'TotalData': totalData,
      'msg': msg,
      'SizeList': sizeList.map((e) => e.toJson()).toList(),
    };
  }
}

class SizeModel {
  final String id;
  final String sizeName;

  SizeModel({
    required this.id,
    required this.sizeName,
  });

  factory SizeModel.fromJson(Map<String, dynamic> json) {
    return SizeModel(
      id: json['id']?.toString() ?? '',
      sizeName: json['size_name']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'size_name': sizeName,
    };
  }
}