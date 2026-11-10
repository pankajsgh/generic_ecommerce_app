class CheckProductStockModel {
  int? code;
  bool? error;
  String? stockQty;
  String? allowPreorder;
  String? customOrder;
  String? favourate;
  String? size;
  String? color;
  String? msg;

  CheckProductStockModel(
      {this.code,
        this.error,
        this.stockQty,
        this.favourate,
        this.size,
        this.color,
        this.msg,
        this.allowPreorder,
        this.customOrder

      });

  CheckProductStockModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    error = json['error'];
    stockQty = json['stock_Qty'] != null && json['stock_Qty'] != ""
        ? json['stock_Qty']
        : "0";
    // stockQty = json['stock_Qty'] ?? "";
    favourate = json['Favourate'] ?? "";
    size = json['size'] ?? "";
    color = json['color'] ?? "";
    msg = json['msg'] ?? "";
    allowPreorder =json['AllowPreorder'] ?? '';
    customOrder =json['CustomOrder'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['error'] = error;
    data['stock_Qty'] = stockQty;
    data['Favourate'] = favourate;
    data['size'] = size;
    data['color'] = color;
    data['msg'] = msg;
    data['AllowPreorder'] = allowPreorder;
    data['CustomOrder'] = customOrder;
    return data;
  }
}
