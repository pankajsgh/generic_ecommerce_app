class CartModel {
  String code;
  bool error;
  int nums;
  String totalData;
  String msg;
  String cartNum;
  String favourates;
  String notification;
  String onlineService;

  UserAddressModel? userAddress;

  List<CartProductModel> productCartList;

  GrandTotalsModel grandTotals;

  CartModel({
    this.code = '',
    this.error = false,
    this.nums = 0,
    this.totalData = '',
    this.msg = '',
    this.cartNum = '',
    this.favourates = '',
    this.notification = '',
    this.onlineService = '',
    this.userAddress,
    this.productCartList = const [],
    GrandTotalsModel? grandTotals,
  }) : grandTotals = grandTotals ?? GrandTotalsModel();

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      code: json['code']?.toString() ?? '',
      error: json['error'] == true,
      nums: int.tryParse(
        json['nums']?.toString() ?? '0',
      ) ??
          0,
      totalData: json['TotalData']?.toString() ?? '',
      msg: json['msg']?.toString() ?? '',
      cartNum: json['CartNum']?.toString() ?? '',
      favourates: json['Favourates']?.toString() ?? '',
      notification: json['notification']?.toString() ?? '',
      onlineService: json['Online_Service']?.toString() ?? '',

      userAddress: json['User_address'] != null
          ? UserAddressModel.fromJson(
        Map<String, dynamic>.from(
          json['User_address'],
        ),
      )
          : null,

      productCartList:
      (json['ProductCartList'] as List?)
          ?.map(
            (e) => CartProductModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],

      grandTotals: json['Grand_Totals'] != null
          ? GrandTotalsModel.fromJson(
        Map<String, dynamic>.from(
          json['Grand_Totals'],
        ),
      )
          : GrandTotalsModel(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'error': error,
      'nums': nums,
      'TotalData': totalData,
      'msg': msg,
      'CartNum': cartNum,
      'Favourates': favourates,
      'notification': notification,
      'Online_Service': onlineService,
      'User_address': userAddress?.toJson(),
      'ProductCartList':
      productCartList.map((e) => e.toJson()).toList(),
      'Grand_Totals': grandTotals.toJson(),
    };
  }
}

class CartProductModel {
  String cartId;
  String pid;
  String item;
  String hsnCode;
  String section;
  String qty;
  String rate;
  String discountPrice;
  String discountval;
  String discountpercent;
  String images;
  String color;
  String colorId;
  String size;
  String sizeId;
  String status;
  String stock;
  String customimg;
  String cartType;
  String allowPreorder;

  List<CartSizeModel> sizeList;

  CartProductModel({
    this.cartId = '',
    this.pid = '',
    this.item = '',
    this.hsnCode = '',
    this.section = '',
    this.qty = '0',
    this.rate = '',
    this.discountPrice = '',
    this.discountval = '',
    this.discountpercent = '',
    this.images = '',
    this.color = '',
    this.colorId = '',
    this.size = '',
    this.sizeId = '',
    this.status = '',
    this.stock = '',
    this.customimg = '',
    this.cartType = '',
    this.allowPreorder = '',
    this.sizeList = const [],
  });

  factory CartProductModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CartProductModel(
      cartId: json['cartid']?.toString() ?? '',
      pid: json['pid']?.toString() ?? '',
      item: json['item']?.toString() ?? '',
      hsnCode: json['hsn_code']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      qty: json['qty']?.toString() ?? '0',
      rate: json['Rate']?.toString() ?? '',
      discountPrice:
      json['DiscountPrice']?.toString() ?? '',
      discountval:
      json['Discountval']?.toString() ?? '',
      discountpercent:
      json['Discountpercent']?.toString() ?? '',
      images: json['images']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      colorId: json['color_id']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      sizeId: json['size_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      stock: json['stock']?.toString() ?? '',
      customimg: json['customimg']?.toString() ?? '',
      cartType: json['CartType']?.toString() ?? '',
      allowPreorder:
      json['AllowPreorder']?.toString() ?? '',

      sizeList:
      (json['Sizelist'] as List?)
          ?.map(
            (e) => CartSizeModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartid': cartId,
      'pid': pid,
      'item': item,
      'hsn_code': hsnCode,
      'section': section,
      'qty': qty,
      'Rate': rate,
      'DiscountPrice': discountPrice,
      'Discountval': discountval,
      'Discountpercent': discountpercent,
      'images': images,
      'color': color,
      'color_id': colorId,
      'size': size,
      'size_id': sizeId,
      'status': status,
      'stock': stock,
      'customimg': customimg,
      'CartType': cartType,
      'AllowPreorder': allowPreorder,
      'Sizelist':
      sizeList.map((e) => e.toJson()).toList(),
    };
  }
}

class CartColorModel {
  String id;
  String color;
  String salePrice;
  String discountPrice;
  String discountval;
  String discountpercent;
  String allowPreorder;
  String customOrder;
  String stock;

  CartColorModel({
    this.id = '',
    this.color = '',
    this.salePrice = '',
    this.discountPrice = '',
    this.discountval = '',
    this.discountpercent = '',
    this.allowPreorder = '',
    this.customOrder = '',
    this.stock = '',
  });

  factory CartColorModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CartColorModel(
      id: json['id']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      salePrice:
      json['SalePrice']?.toString() ?? '',
      discountPrice:
      json['DiscountPrice']?.toString() ?? '',
      discountval:
      json['Discountval']?.toString() ?? '',
      discountpercent:
      json['Discountpercent']?.toString() ?? '',
      allowPreorder:
      json['AllowPreorder']?.toString() ?? '',
      customOrder:
      json['CustomOrder']?.toString() ?? '',
      stock: json['Stock']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': color,
      'SalePrice': salePrice,
      'DiscountPrice': discountPrice,
      'Discountval': discountval,
      'Discountpercent': discountpercent,
      'AllowPreorder': allowPreorder,
      'CustomOrder': customOrder,
      'Stock': stock,
    };
  }
}

class GrandTotalsModel {
  String subtotal;
  String gst;
  String finalAmounts;

  GrandTotalsModel({
    this.subtotal = '',
    this.gst = '',
    this.finalAmounts = '',
  });

  factory GrandTotalsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return GrandTotalsModel(
      subtotal: json['Subtotal']?.toString() ?? '',
      gst: json['GST']?.toString() ?? '',
      finalAmounts:
      json['FinalAmounts']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Subtotal': subtotal,
      'GST': gst,
      'FinalAmounts': finalAmounts,
    };
  }
}

class CartSizeModel {
  String id;
  String size;

  List<CartColorModel> colorList;

  CartSizeModel({
    this.id = '',
    this.size = '',
    this.colorList = const [],
  });

  factory CartSizeModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CartSizeModel(
      id: json['id']?.toString() ?? '',
      size: json['Size']?.toString() ?? '',
      colorList:
      (json['ColorList'] as List?)
          ?.map(
            (e) => CartColorModel.fromJson(
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
      'ColorList':
      colorList.map((e) => e.toJson()).toList(),
    };
  }
}

class UserAddressModel {
  String id;
  String name;
  String mobile;
  String address;
  String city;
  String state;
  String pincode;
  String country;

  UserAddressModel({
    this.id = '',
    this.name = '',
    this.mobile = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.country = '',
  });

  factory UserAddressModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return UserAddressModel(
      id: json['id']?.toString() ?? '',
      name: json['Name']?.toString() ?? '',
      mobile: json['Mobile']?.toString() ?? '',
      address: json['Address']?.toString() ?? '',
      city: json['City']?.toString() ?? '',
      state: json['State']?.toString() ?? '',
      pincode: json['Pincode']?.toString() ?? '',
      country: json['Country']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Name': name,
      'Mobile': mobile,
      'Address': address,
      'City': city,
      'State': state,
      'Pincode': pincode,
      'Country': country,
    };
  }
}