class SectionResponseModel {
  final int code;
  final bool error;
  final String nums;
  final String totalData;
  final String msg;
  final List<SectionModel> sectionList;

  SectionResponseModel({
    required this.code,
    required this.error,
    required this.nums,
    required this.totalData,
    required this.msg,
    required this.sectionList,
  });

  factory SectionResponseModel.fromJson(Map<String, dynamic> json) {
    return SectionResponseModel(
      code: int.tryParse(json['code']?.toString() ?? '') ?? 0,
      error: json['error'] == true,
      nums: json['nums']?.toString() ?? '',
      totalData: json['TotalData']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
      sectionList: (json['ColorList'] as List?)
          ?.map(
            (e) => SectionModel.fromJson(
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
      'ColorList': sectionList.map((e) => e.toJson()).toList(),
    };
  }
}

class SectionModel {
  final String id;
  final String section;
  final String genType;
  final String images;

  SectionModel({
    required this.id,
    required this.section,
    required this.genType,
    required this.images,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      genType: json['gen_type']?.toString() ?? '',
      images: json['images']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section': section,
      'gen_type': genType,
      'images': images,
    };
  }
}