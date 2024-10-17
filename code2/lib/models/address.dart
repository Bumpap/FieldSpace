import 'dart:core';

class Address {
  late String _addressType;
  late String? _contactUserName;
  late String? _contactUserPhoneNumber;
  late String _address;
  late String _latitude;
  late String _longitude;

  Address(
      {required addressType,
      contactUserName,
      contactUserPhoneNumber,
      address,
      latitude,
      longitude}) {
    _address = address;
    _addressType = addressType;
    _contactUserName = contactUserName;
    _contactUserPhoneNumber = contactUserPhoneNumber;
    _latitude = latitude;
    _longitude = longitude;
  }

  String get address => _address;

  String get addressType => _addressType;

  String? get contactUserName => _contactUserName;

  String? get contactUserPhoneNumber => _contactUserPhoneNumber;

  String get latitude => _latitude;

  String get longitude => _longitude;

  Address.fromJson(Map<String, dynamic> json) {
    _address = json["address"] ?? '';
    _addressType = json["address_type"] ?? '';
    _contactUserName = json['contact_user_name'] ?? '';
    _contactUserPhoneNumber = json['contact_user_phone_number'] ?? '';
    _latitude = json['latitude'];
    _longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['address'] = this._address;
    data['address_type'] = this._addressType;
    data['contact_user_name'] = this._contactUserName;
    data['contact_user_phone_number'] = this._contactUserPhoneNumber;
    data['latitude'] = this._latitude;
    data['longitude'] = this._longitude;
    return data;
  }
}
