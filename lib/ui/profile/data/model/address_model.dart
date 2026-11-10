class AddressListResponse {
  final int code;
  final bool error;
  final String msg;
  final List<AddressModel> addressList;

  AddressListResponse({
    required this.code,
    required this.error,
    required this.msg,
    required this.addressList,
  });

  factory AddressListResponse.fromJson(Map<String, dynamic> json) {
    return AddressListResponse(
      code: int.tryParse(json['code']?.toString() ?? '0') ?? 0,
      error: json['error'] == true,
      msg: json['msg']?.toString() ?? '',
      addressList: (json['AddressList'] as List?)
          ?.map((e) => AddressModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class AddressModel {
  String id;
  String fullName;
  String mobile;
  String address;
  String state;
  String city;
  String pinCode;
  String addressType;
  String country;
  bool isDefault;

  AddressModel({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.address,
    required this.state,
    required this.city,
    required this.pinCode,
    required this.addressType,
    required this.country,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final addrType = json['AddrType']?.toString() ?? '';

    return AddressModel(
      id: json['id']?.toString() ?? '',
      fullName: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      pinCode: json['pincode']?.toString() ?? '',
      addressType: addrType,
      country: json['country']?.toString().trim() ?? '',
      isDefault: addrType.toLowerCase() == 'default',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'AddrType': addressType,
      'name': fullName,
      'mobile': mobile,
      'address': address,
      'state': state,
      'city': city,
      'pincode': pinCode,
      'country': country,
    };
  }
}