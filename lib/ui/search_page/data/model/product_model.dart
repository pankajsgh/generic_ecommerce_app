class ProductResponseModel {
  final int code;
  final bool error;
  final int nums;
  final String totalData;
  final int totalFavourite;
  final int totalCartCheck;
  final String msg;
  final List<ProductModel> productList;

  ProductResponseModel({
    required this.code,
    required this.error,
    required this.nums,
    required this.totalData,
    required this.totalFavourite,
    required this.totalCartCheck,
    required this.msg,
    required this.productList,
  });

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductResponseModel(
      code: int.tryParse(json['code']?.toString() ?? '') ?? 0,
      error: json['error'] == true,
      nums: int.tryParse(json['nums']?.toString() ?? '') ?? 0,
      totalData: json['TotalData']?.toString() ?? '',
      totalFavourite:
      int.tryParse(json['TotalFavourate']?.toString() ?? '') ?? 0,
      totalCartCheck:
      int.tryParse(json['TotalCartCheck']?.toString() ?? '') ?? 0,
      msg: json['msg']?.toString() ?? '',
      productList: (json['ProductList'] as List?)
          ?.map(
            (e) => ProductModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],
    );
  }
}

class ProductModel {
  final String id;
  final String product;
  final String sizeName;
  final String sizeId;
  final String colorName;
  final String colorId;
  final String hsnCode;
  final String gst;
  final String favourite;
  final String salePrice;
  final String discountPrice;
  final String discountValue;
  final String discountPercent;
  final String image;
  final String status;

  ProductModel({
    required this.id,
    required this.product,
    required this.sizeName,
    required this.sizeId,
    required this.colorName,
    required this.colorId,
    required this.hsnCode,
    required this.gst,
    required this.favourite,
    required this.salePrice,
    required this.discountPrice,
    required this.discountValue,
    required this.discountPercent,
    required this.image,
    required this.status,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      product: json['product']?.toString() ?? '',
      sizeName: json['SizeName']?.toString() ?? '',
      sizeId: json['SizeId']?.toString() ?? '',
      colorName: json['ColorName']?.toString() ?? '',
      colorId: json['ColorId']?.toString() ?? '',
      hsnCode: json['Hsn_code']?.toString() ?? '',
      gst: json['Gst']?.toString() ?? '',
      favourite: json['Favourate']?.toString() ?? '',
      salePrice: json['SalePrice']?.toString() ?? '',
      discountPrice: json['DiscountPrice']?.toString() ?? '',
      discountValue: json['Discountval']?.toString() ?? '',
      discountPercent: json['Discountpercent']?.toString() ?? '',
      image: json['images']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product,
      'SizeName': sizeName,
      'SizeId': sizeId,
      'ColorName': colorName,
      'ColorId': colorId,
      'Hsn_code': hsnCode,
      'Gst': gst,
      'Favourate': favourite,
      'SalePrice': salePrice,
      'DiscountPrice': discountPrice,
      'Discountval': discountValue,
      'Discountpercent': discountPercent,
      'image': image,
      'status': status,
    };
  }
}