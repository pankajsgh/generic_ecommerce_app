class ColorResponseModel {
  final int code;
  final bool error;
  final String nums;
  final String totalData;
  final String msg;
  final List<ColorModel> colorList;

  ColorResponseModel({
    required this.code,
    required this.error,
    required this.nums,
    required this.totalData,
    required this.msg,
    required this.colorList,
  });

  factory ColorResponseModel.fromJson(Map<String, dynamic> json) {
    return ColorResponseModel(
      code: int.tryParse(json['code']?.toString() ?? '') ?? 0,
      error: json['error'] == true,
      nums: json['nums']?.toString() ?? '',
      totalData: json['TotalData']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
      colorList: (json['ColorList'] as List?)
          ?.map(
            (e) => ColorModel.fromJson(
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
      'ColorList': colorList.map((e) => e.toJson()).toList(),
    };
  }
}
class ColorModel {
  final String id;
  final String colorName;

  ColorModel({
    required this.id,
    required this.colorName,
  });

  factory ColorModel.fromJson(Map<String, dynamic> json) {
    return ColorModel(
      id: json['id']?.toString() ?? '',
      colorName: json['color_name']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color_name': colorName,
    };
  }
}