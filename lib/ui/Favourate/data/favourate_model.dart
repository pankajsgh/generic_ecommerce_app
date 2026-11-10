

import 'package:flutter_ecom/ui/product_detail/data/model/product_model.dart';

class FavouriteModel {
  final int code;
  final bool error;
  final int nums;
  final String totalData;
  final String totalFavourate;
  final String totalCartCheck;
  final String msg;
  final List<SimilarProductModel> productList;

  FavouriteModel({
    required this.code,
    required this.error,
    required this.nums,
    required this.totalData,
    required this.totalFavourate,
    required this.totalCartCheck,
    required this.msg,
    required this.productList,
  });

  factory FavouriteModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return FavouriteModel(
      code: int.tryParse(
        json['code']?.toString() ?? '0',
      ) ??
          0,
      error: json['error'] == true ||
          json['error']?.toString() == 'true',
      nums: int.tryParse(
        json['nums']?.toString() ?? '0',
      ) ??
          0,
      totalData:
      json['TotalData']?.toString() ?? '',
      totalFavourate:
      json['TotalFavourate']?.toString() ?? '',
      totalCartCheck:
      json['TotalCartCheck']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
      productList:
      (json['ProductList'] as List?)
          ?.map(
            (e) => SimilarProductModel.fromJson(
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
      'TotalFavourate': totalFavourate,
      'TotalCartCheck': totalCartCheck,
      'msg': msg,
      'ProductList':
      productList.map((e) => e.toJson()).toList(),
    };
  }
}


// ============================================================
// FAVOURITE PRODUCT
// ============================================================

// class FavouriteProductModel {
//   final String id;
//   final String fid;
//   final String product;
//   final String hsnCode;
//   final String section;
//   final String sizeId;
//   final String sizeName;
//   final String colorId;
//   final String colorName;
//   final String rate;
//   final String discountPrice;
//   final String discountval;
//   final String discountpercent;
//   final String images;
//   final String favourate;
//   final String carts;
//   final String addedTime;
//   final String status;
//
//   FavouriteProductModel({
//     required this.id,
//     required this.fid,
//     required this.product,
//     required this.hsnCode,
//     required this.section,
//     required this.sizeId,
//     required this.sizeName,
//     required this.colorId,
//     required this.colorName,
//     required this.rate,
//     required this.discountPrice,
//     required this.discountval,
//     required this.discountpercent,
//     required this.images,
//     required this.favourate,
//     required this.carts,
//     required this.addedTime,
//     required this.status,
//   });
//
//   factory FavouriteProductModel.fromJson(
//       Map<String, dynamic> json,
//       ) {
//     return FavouriteProductModel(
//       id: json['id']?.toString() ?? '',
//       fid: json['fid']?.toString() ?? '',
//       product: json['product']?.toString() ?? '',
//       hsnCode: json['Hsn_code']?.toString() ?? '',
//       section: json['section']?.toString() ?? '',
//       sizeId: json['SizeId']?.toString() ?? '',
//       sizeName: json['SizeName']?.toString() ?? '',
//       colorId: json['ColorId']?.toString() ?? '',
//       colorName: json['ColorName']?.toString() ?? '',
//       rate: json['Rate']?.toString() ?? '',
//       discountPrice:
//       json['DiscountPrice']?.toString() ?? '',
//       discountval:
//       json['Discountval']?.toString() ?? '',
//       discountpercent:
//       json['Discountpercent']?.toString() ?? '',
//       images: json['images']?.toString() ?? '',
//       favourate:
//       json['Favourate']?.toString() ?? '0',
//       carts: json['Carts']?.toString() ?? '0',
//       addedTime:
//       json['AddedTime']?.toString() ?? '',
//       status: json['status']?.toString() ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'fid': fid,
//       'product': product,
//       'Hsn_code': hsnCode,
//       'section': section,
//       'SizeId': sizeId,
//       'SizeName': sizeName,
//       'ColorId': colorId,
//       'ColorName': colorName,
//       'Rate': rate,
//       'DiscountPrice': discountPrice,
//       'Discountval': discountval,
//       'Discountpercent': discountpercent,
//       'images': images,
//       'Favourate': favourate,
//       'Carts': carts,
//       'AddedTime': addedTime,
//       'status': status,
//     };
//   }
//
//   bool get isFavourite =>
//       favourate == '1';
//
//   bool get isInCart =>
//       carts == '1';
//
//   bool get isOutOfStock =>
//       status.toLowerCase() == 'out-stock';
//
//   double get price {
//     return double.tryParse(rate) ?? 0;
//   }
//
//   double get salePrice {
//     final discount =
//         double.tryParse(discountPrice) ?? 0;
//
//     return discount > 0 ? discount : price;
//   }
//
//   bool get hasDiscount {
//     final discount =
//         double.tryParse(discountPrice) ?? 0;
//
//     return discount > 0 && discount < price;
//   }
// }

