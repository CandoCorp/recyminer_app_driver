class LocationMiningModel {
  int _id;
  int _orderId;
  double _miningAmount;
  double _deliveryCharge;
  String _address;
  String _latitude;
  String _longitude;

  LocationMiningModel(
      {
        int id,
        int orderId,
        double miningAmount,
        double deliveryCharge,
        String address,
        String latitude,
        String longitude}) {
    this._id = id;
    this._orderId = orderId;
    this._miningAmount = miningAmount;
    this._deliveryCharge = deliveryCharge;
    this._address = address;
    this._latitude = latitude;
    this._longitude = longitude;
  }

  int get id => _id;
  int get orderId => _orderId;
  double get miningAmount => _miningAmount;
  double get deliveryCharge => _deliveryCharge;
  String get address => _address;
  String get latitude => _latitude;
  String get longitude => _longitude;

  // LocationMiningModel.fromJson(Map<String, dynamic> json) {
  //   _id = json['id'];
  //   _orderId = json['order_id'];
  //   _miningAmount = json['mining_amount'].toDouble();
  //   _deliveryCharge = json['delivery_charge'].toDouble();
  //   _address = json['address'];
  //   _latitude = json['latitude'];
  //   _longitude = json['longitude'];
  // }
  LocationMiningModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _orderId = json['order_id'];
    _miningAmount = json['order_amount'].toDouble();
    _deliveryCharge = json['delivery_charge'].toDouble();
    _address = json['address'];
    _latitude = json['latitude'];
    _longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['order_id'] = this._orderId;
    data['mining_amount'] = this._miningAmount;
    data['delivery_charge'] = this._deliveryCharge;
    data['address'] = this._address;
    data['latitude'] = this._latitude;
    data['longitude'] = this._longitude;
    return data;
  }
}
