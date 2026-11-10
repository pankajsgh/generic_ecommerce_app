import 'package:flutter_ecom/ui/product_detail/data/model/product_model.dart';

class DashboardModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String orgName;
  final String photo;
  final String totalFavourate;
  String totalCartCheck;
  final String developedBy;
  final String androidVersion;
  final String iosVersion;
  final String onlineService;
  final String whatsappNumber;
  final String outstanding;
  final String dueDays;
  final String status;
  final String aboutUs;
  final String privacyPolicy;
  final String contactUs;
  final String termCondition;

  final List<BannerModel> banners;
  final List<SectionModel> sections;
  List<SimilarProductModel> newArrival;
  List<SimilarProductModel> topCollection;
  List<SimilarProductModel> recentlyViewed;

  DashboardModel({
    this.id = '',
    this.name = '',
    this.email = '',
    this.mobile = '',
    this.orgName = '',
    this.photo = '',
    this.totalFavourate = '',
    this.totalCartCheck = '',
    this.developedBy = '',
    this.androidVersion = '',
    this.iosVersion = '',
    this.onlineService = '',
    this.whatsappNumber = '',
    this.outstanding = '',
    this.dueDays = '',
    this.status = '',
    this.aboutUs = '',
    this.privacyPolicy = '',
    this.contactUs = '',
    this.termCondition = '',
    this.banners = const [],
    this.sections = const [],
    this.newArrival = const [],
    this.topCollection = const [],
    this.recentlyViewed = const [],
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      orgName: json['org_name']?.toString() ?? '',
      photo: json['photo']?.toString() ?? '',

      totalFavourate:
      json['TotalFavourate']?.toString() ?? '',

      totalCartCheck:
      json['TotalCartCheck']?.toString() ?? '',

      developedBy:
      json['DevelopedBy']?.toString() ?? '',

      androidVersion:
      json['Android_Version']?.toString() ?? '',

      iosVersion:
      json['IOS_Version']?.toString() ?? '',

      onlineService:
      json['Online_Service']?.toString() ?? '',

      whatsappNumber:
      json['whatsapp_number']?.toString() ?? '',

      outstanding:
      json['Outstanding']?.toString() ?? '',

      dueDays:
      json['Duedays']?.toString() ?? '',

      status:
      json['Staus']?.toString() ?? '',

      aboutUs:
      json['Aboutus']?.toString() ?? '',

      privacyPolicy:
      json['Privacy_Policy']?.toString() ?? '',

      contactUs:
      json['Contactus']?.toString() ?? '',

      termCondition:
      json['Termcondition']?.toString() ?? '',

      banners: (json['Banner'] as List?)
          ?.map(
            (e) => BannerModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],

      sections: (json['SectionList'] as List?)
          ?.map(
            (e) => SectionModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],

      newArrival: (json['NewArrival'] as List?)
          ?.map(
            (e) => SimilarProductModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],

      topCollection: (json['TopCollection'] as List?)
          ?.map(
            (e) => SimilarProductModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],

      recentlyViewed: (json['Recently_viewed'] as List?)
          ?.map(
            (e) => SimilarProductModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],
    );
  }
}

class BannerModel {
  final String id;
  final String image;

  BannerModel({
    this.id = '',
    this.image = '',
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      image: json['images']?.toString() ?? '',
    );
  }
}

class ProductDashboardModel {
  final String id;
  final String product;
  final String sizeName;
  final String sizeId;
  final String colorName;
  String colorId;
  final String hsnCode;
  final String salePrice;
  final String discountPrice;
  final String discountVal;
  final String discountPercent;
  final String purchasePrice;
  final String gst;
  String favourate;
  final String image;
  final String status;

  ProductDashboardModel({
    this.id = '',
    this.product = '',
    this.sizeName = '',
    this.sizeId = '',
    this.colorName = '',
    this.colorId = '',
    this.hsnCode = '',
    this.salePrice = '',
    this.discountPrice = '',
    this.discountVal = '',
    this.discountPercent = '',
    this.purchasePrice = '',
    this.gst = '',
    this.favourate = '',
    this.image = '',
    this.status = '',
  });

  factory ProductDashboardModel.fromJson(Map<String, dynamic> json) {
    return ProductDashboardModel(
      id: json['id']?.toString() ?? '',
      product: json['product']?.toString() ?? '',

      sizeName: json['SizeName']?.toString() ?? '',
      sizeId: json['SizeId']?.toString() ?? '',

      colorName: json['ColorName']?.toString() ?? '',
      colorId: json['ColorId']?.toString() ?? '',

      hsnCode: json['Hsn_code']?.toString() ?? '',

      salePrice: json['SalePrice']?.toString() ?? '',
      discountPrice:
      json['DiscountPrice']?.toString() ?? '',
      discountVal:
      json['Discountval']?.toString() ?? '',
      discountPercent:
      json['Discountpercent']?.toString() ?? '',

      purchasePrice:
      json['PurchasePrice']?.toString() ?? '',

      gst: json['Gst']?.toString() ?? '',

      favourate:
      json['Favourate']?.toString() ?? '',

      image:
      json['images']?.toString() ?? '',

      status:
      json['status']?.toString() ?? '',
    );
  }

  bool get isFavourite => favourate == '1';

  bool get isInStock =>
      status.toLowerCase() == 'in-stock';

  String get displayPrice {
    if (salePrice.isEmpty) {
      return '₹ --';
    }

    return '₹$salePrice';
  }
}

class SectionModel {
  final String id;
  final String section;
  final String image;
  final String genderType;

  SectionModel({
    this.id = '',
    this.section = '',
    this.image = '',
    this.genderType=''
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      image: json['images']?.toString() ?? '',
      genderType: json['gen_type'] ?? (json['section']=="Kurta" || json['section']=="Sherwani" ? 'Men': 'Women'),
    );
  }
}
