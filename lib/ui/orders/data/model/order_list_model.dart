import 'dart:convert';

class OrderListModel {
  final String id;
  final String orderId;
  final String orderDate;
  final String image;
  final int qty;
  final double subtotal;
  final double finalAmount;
  final String status;
  final String customStatus;

  OrderListModel({
    required this.id,
    required this.orderId,
    required this.orderDate,
    required this.image,
    required this.qty,
    required this.subtotal,
    required this.finalAmount,
    required this.status,
    required this.customStatus,
  });

  factory OrderListModel.fromJson(Map<String, dynamic> json) {
    return OrderListModel(
      id: json['id']?.toString() ?? '',
      orderId: json['orderid']?.toString() ?? '',
      orderDate: json['order_date']?.toString() ?? '',
      image: json['images']?.toString() ?? '',
      qty: int.tryParse(json['qty']?.toString() ?? '0') ?? 0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      finalAmount:
      double.tryParse(json['finalamount']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'Pending',
      customStatus: json['custom_status']?.toString() ?? '0',
    );
  }
}

class OrderProductModel {
  final String id;
  final String pid;
  final String product;
  final String hsnCode;
  final String section;
  final String image;
  final String color;
  final String size;
  final int qty;
  final double price;
  final double salePrice;
  final double amount;
  final double cgst;
  final double cgstPer;
  final double sgst;
  final double sgstPer;
  final double igst;
  final double igstPer;
  final String customImg;
  final String cartType;

  OrderProductModel({
    required this.id,
    required this.pid,
    required this.product,
    required this.hsnCode,
    required this.section,
    required this.image,
    required this.color,
    required this.size,
    required this.qty,
    required this.price,
    required this.salePrice,
    required this.amount,
    required this.cgst,
    required this.cgstPer,
    required this.sgst,
    required this.sgstPer,
    required this.igst,
    required this.igstPer,
    required this.customImg,
    required this.cartType,
  });

  factory OrderProductModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      return double.tryParse(value?.toString() ?? '0') ?? 0;
    }

    return OrderProductModel(
      id: json['id']?.toString() ?? '',
      pid: json['pid']?.toString() ?? '',
      product: json['product']?.toString() ?? '',
      hsnCode: json['Hsn_code']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      image: json['images']?.toString() ?? '',
      color: json['Colors']?.toString() ?? '',
      size: json['Sizes']?.toString() ?? '',
      qty: int.tryParse(json['qty']?.toString() ?? '0') ?? 0,
      price: toDouble(json['price']),
      salePrice: toDouble(json['saleprice']),
      amount: toDouble(json['Amount']),
      cgst: toDouble(json['CGST']),
      cgstPer: toDouble(json['CGSTPer']),
      sgst: toDouble(json['SGST']),
      sgstPer: toDouble(json['SGSTPer']),
      igst: toDouble(json['IGST']),
      igstPer: toDouble(json['IGSTPer']),
      customImg: json['customimg']?.toString() ?? '',
      cartType: json['CartType']?.toString() ?? '',
    );
  }
}

class OrderGrandTotals {
  final double subtotal;
  final double gst;
  final double finalAmount;

  OrderGrandTotals({
    required this.subtotal,
    required this.gst,
    required this.finalAmount,
  });

  factory OrderGrandTotals.fromJson(Map<String, dynamic> json) {
    return OrderGrandTotals(
      subtotal: double.tryParse(json['Subtotal']?.toString() ?? '0') ?? 0,
      gst: double.tryParse(json['GST']?.toString() ?? '0') ?? 0,
      finalAmount:
      double.tryParse(json['FinalAmounts']?.toString() ?? '0') ?? 0,
    );
  }
}

class ShippingAddressModel {
  final String name;
  final String mobile;
  final String address;
  final String state;
  final String city;
  final String pincode;

  ShippingAddressModel({
    required this.name,
    required this.mobile,
    required this.address,
    required this.state,
    required this.city,
    required this.pincode,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
    );
  }
}

class OrderDetailModel {
  final String id;
  final String orderDate;
  final String orderId;
  final double orderTotal;
  final String orderStatus;
  final List<OrderProductModel> products;
  final OrderGrandTotals totals;
  final ShippingAddressModel? shippingAddress;

  OrderDetailModel({
    required this.id,
    required this.orderDate,
    required this.orderId,
    required this.orderTotal,
    required this.orderStatus,
    required this.products,
    required this.totals,
    required this.shippingAddress,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final products = (json['OrderProduct'] as List? ?? [])
        .map((e) => OrderProductModel.fromJson(e))
        .toList();

    return OrderDetailModel(
      id: json['id']?.toString() ?? '',
      orderDate: json['order_date']?.toString() ?? '',
      orderId: json['orderid']?.toString() ?? '',
      orderTotal:
      double.tryParse(json['Order_Total']?.toString() ?? '0') ?? 0,
      orderStatus: json['Order_status']?.toString() ?? 'Pending',
      products: products,
      totals: OrderGrandTotals.fromJson(
        json['Grand_Totals'] ?? {},
      ),
      shippingAddress: json['shipping_address'] != null
          ? ShippingAddressModel.fromJson(json['shipping_address'])
          : null,
    );
  }
}