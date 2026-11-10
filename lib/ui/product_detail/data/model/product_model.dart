class ProductDetailsModel {
  String code;
  bool error;
  String msg;
  String id;
  String product;
  String hsnCode;
  String section;
  String salePrice;
  String purchasePrice;
  String gst;
  String images;
  String description;
  String allowPreorder;
  String stock;
  String favourate;
  String cartCheck;
  String totalFavourate;
  String totalCartCheck;
  String customiseOrder;
  List<CartItemModel> cartList;
  List<SizeListModel> sizeList;
  List<SimilarProductModel> similarProduct;

  ProductDetailsModel({
    this.code = '',
    this.error = false,
    this.msg = '',
    this.id = '',
    this.product = '',
    this.hsnCode = '',
    this.section = '',
    this.salePrice = '',
    this.purchasePrice = '',
    this.gst = '',
    this.images = '',
    this.description = '',
    this.allowPreorder = '',
    this.stock = '',
    this.favourate = '',
    this.cartCheck = '',
    this.totalFavourate = '',
    this.totalCartCheck = '',
    this.customiseOrder = '',
    this.sizeList = const [],
    this.similarProduct = const [],
    this.cartList = const [],
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {

    return ProductDetailsModel(
      code: json['code']?.toString() ?? '',
      error: json['error'] == true,
      msg: json['msg']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      product: json['product']?.toString() ?? '',
      hsnCode: json['Hsn_code']?.toString() ?? '',
      section: json['Section']?.toString() ?? '',
      salePrice: json['SalePrice']?.toString() ?? '',
      purchasePrice: json['PurchasePrice']?.toString() ?? '',
      gst: json['Gst']?.toString() ?? '',
      images: json['images']?.toString() ?? '',
      description: json['Description']?.toString() ?? '',
      allowPreorder: json['AllowPreorder']?.toString() ?? '',
      stock: json['Stock']?.toString() ?? '',
      favourate: json['Favourate']?.toString() ?? '',
      cartCheck: json['CartCheck']?.toString() ?? '',
      totalFavourate: json['TotalFavourate']?.toString() ?? '',
      totalCartCheck: json['TotalCartCheck']?.toString() ?? '',
      customiseOrder: json['CustomiseOrder']?.toString() ?? '',

      sizeList: (json['Sizelist'] as List?)
          ?.map(
            (e) => SizeListModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],

      similarProduct: (json['SimilarProduct'] as List?)
          ?.map(
            (e) => SimilarProductModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],
      cartList: (json['Cartlist'] as List?)
          ?.map(
            (e) => CartItemModel.fromJson(
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
      'msg': msg,
      'id': id,
      'product': product,
      'Hsn_code': hsnCode,
      'Section': section,
      'SalePrice': salePrice,
      'PurchasePrice': purchasePrice,
      'Gst': gst,
      'images': images,
      'Description': description,
      'AllowPreorder': allowPreorder,
      'Stock': stock,
      'Favourate': favourate,
      'CartCheck': cartCheck,
      'TotalFavourate': totalFavourate,
      'TotalCartCheck': totalCartCheck,
      'CustomiseOrder': customiseOrder,

      'Sizelist': sizeList
          .map((e) => e.toJson())
          .toList(),

      'SimilarProduct': similarProduct
          .map((e) => e.toJson())
          .toList(),
      'Cartlist': cartList.map((e) => e.toJson()).toList(),
    };
  }
}

class ColorListModel {
  String id;
  String color;
  String salePrice;
  String discountPrice;
  String discountVal;
  String discountPercent;
  String images;
  String stock;
  String allowPreorder;
  String customOrder;
  String status;
  bool isSelected;

  List<ImageListModel> imageList;

  ColorListModel({
    this.id = '',
    this.color = '',
    this.salePrice = '',
    this.discountPrice = '',
    this.discountVal = '',
    this.discountPercent = '',
    this.images = '',
    this.stock = '',
    this.allowPreorder = '',
    this.customOrder = '',
    this.status = '',
    this.isSelected = false,
    this.imageList = const [],
  });

  factory ColorListModel.fromJson(Map<String, dynamic> json) {
    return ColorListModel(
      id: json['id']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      salePrice: json['SalePrice']?.toString() ?? '',
      discountPrice: json['DiscountPrice']?.toString() ?? '',
      discountVal: json['Discountval']?.toString() ?? '',
      discountPercent: json['Discountpercent']?.toString() ?? '',
      images: json['Images']?.toString() ?? '',
      stock: json['Stock']?.toString() ?? '',
      allowPreorder: json['AllowPreorder']?.toString() ?? '',
      customOrder: json['CustomOrder']?.toString() ?? '',
      status: json['Status']?.toString() ?? '',

      imageList: (json['ImageList'] as List?)
          ?.map(
            (e) => ImageListModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': color,
      'SalePrice': salePrice,
      'DiscountPrice': discountPrice,
      'Discountval': discountVal,
      'Discountpercent': discountPercent,
      'Images': images,
      'Stock': stock,
      'AllowPreorder': allowPreorder,
      'CustomOrder': customOrder,
      'Status': status,

      'ImageList': imageList
          .map((e) => e.toJson())
          .toList(),
    };
  }
}
class ImageListModel {
  String id;
  String type;
  String img;

  ImageListModel({
    this.id = '',
    this.type = '',
    this.img = '',
  });

  factory ImageListModel.fromJson(Map<String, dynamic> json) {
    return ImageListModel(
      id: json['id']?.toString() ?? '',
      type: json['Type']?.toString() ?? '',
      img: json['Img']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Type': type,
      'Img': img,
    };
  }
}

class SizeListModel {
  String id;
  String size;
  bool isSelected;

  List<ColorListModel> colorList;

  SizeListModel({
    this.id = '',
    this.size = '',
    this.isSelected = false,
    this.colorList = const [],
  });

  factory SizeListModel.fromJson(Map<String, dynamic> json) {
    return SizeListModel(
      id: json['id']?.toString() ?? '',
      size: json['Size']?.toString() ?? '',

      colorList: (json['ColorList'] as List?)
          ?.map(
            (e) => ColorListModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Size': size,

      'ColorList': colorList
          .map((e) => e.toJson())
          .toList(),
    };
  }
}

class SimilarProductModel {
  String id;
  String product;
  String sizeName;
  String sizeId;
  String colorId;
  String colorName;
  String hsnCode;
  String salePrice;
  String discountPrice;
  String discountval;
  String discountpercent;
  String purchasePrice;
  String gst;
  String image;
  String description;
  String stock;
  bool isFavourite;
  String cartCheck;
  String totalFavourate;
  String totalCartCheck;
  String customiseOrder;
  String status;

  SimilarProductModel({
    this.id = '',
    this.product = '',
    this.sizeName = '',
    this.sizeId = '',
    this.colorId = '',
    this.colorName = '',
    this.hsnCode = '',
    this.salePrice = '',
    this.discountPrice = '',
    this.discountval = '',
    this.discountpercent = '',
    this.purchasePrice = '',
    this.gst = '',
    this.image = '',
    this.description = '',
    this.stock = '',
    this.isFavourite = false,
    this.cartCheck = '',
    this.totalFavourate = '',
    this.totalCartCheck = '',
    this.customiseOrder = '',
    this.status = '',
  });

  factory SimilarProductModel.fromJson(Map<String, dynamic> json) {
    return SimilarProductModel(
      id: json['id']?.toString() ?? '',
      product: json['product']?.toString() ?? '',
      sizeName: json['SizeName']?.toString() ?? '',
      sizeId: json['SizeId']?.toString() ?? '',
      colorId: json['ColorId']?.toString() ?? '',
      colorName: json['ColorName']?.toString() ?? '',
      hsnCode: json['Hsn_code']?.toString() ?? '',
      salePrice: json['SalePrice']!=null ?json['SalePrice'].toString():json['Rate']!=null? json['Rate'].toString(): '',
      discountPrice: json['DiscountPrice']?.toString() ?? '',
      discountval: json['Discountval']?.toString() ?? '',
      discountpercent: json['Discountpercent']?.toString() ?? '',
      purchasePrice: json['PurchasePrice']?.toString() ?? '',
      gst: json['Gst']?.toString() ?? '',
      image: json['images']?.toString() ?? '',
      description: json['Description']?.toString() ?? '',
      stock: json['Stock']?.toString() ?? '',
      isFavourite: json['Favourate']!=null? json['Favourate']?.toString()=="1"? true: false:false,
      cartCheck: json['CartCheck']?.toString() ?? '',
      totalFavourate: json['TotalFavourate']?.toString() ?? '',
      totalCartCheck: json['TotalCartCheck']?.toString() ?? '',
      customiseOrder: json['CustomiseOrder']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product,
      'SizeName': sizeName,
      'SizeId': sizeId,
      'ColorId': colorId,
      'ColorName': colorName,
      'Hsn_code': hsnCode,
      'SalePrice': salePrice,
      'DiscountPrice': discountPrice,
      'Discountval': discountval,
      'Discountpercent': discountpercent,
      'PurchasePrice': purchasePrice,
      'Gst': gst,
      'images': image,
      'Description': description,
      'Stock': stock,
      'Favourate': isFavourite,
      'CartCheck': cartCheck,
      'TotalFavourate': totalFavourate,
      'TotalCartCheck': totalCartCheck,
      'CustomiseOrder': customiseOrder,
      'status': status,
    };
  }
}

class CartItemModel {
  String itemId;
  String color;
  String size;

  CartItemModel({
    this.itemId = '',
    this.color = '',
    this.size = '',
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      itemId: json['item_id']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'color': color,
      'size': size,
    };
  }
}