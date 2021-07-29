import 'package:grocery_delivery_boy/data/model/response/order_model.dart';

class LocationOrderModel {
  int _orderId;
  double _orderAmount;
  double _deliveryCharge;
  String _address;
  String _latitude;
  String _longitude;

  LocationOrderModel(
      {
        int orderId,
        double orderAmount,
        double deliveryCharge,
        String address,
        String latitude,
        String longitude}) {
    this._orderId = orderId;
    this._orderAmount = orderAmount;
    this._deliveryCharge = deliveryCharge;
    this._address = address;
    this._latitude = latitude;
    this._longitude = longitude;
  }

  int get orderId => _orderId;
  double get orderAmount => _orderAmount;
  double get deliveryCharge => _deliveryCharge;
  String get address => _address;
  String get latitude => _latitude;
  String get longitude => _longitude;

  LocationOrderModel.fromJson(Map<String, dynamic> json) {
    _orderId = json['order_id'];
    _orderAmount = json['order_amount'].toDouble();
    _deliveryCharge = json['delivery_charge'].toDouble();
    _address = json['address'];
    _latitude = json['latitude'];
    _longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this._orderId;
    data['order_amount'] = this._orderAmount;
    data['delivery_charge'] = this._deliveryCharge;
    data['address'] = this._address;
    data['latitude'] = this._latitude;
    data['longitude'] = this._longitude;
    return data;
  }

  LocationOrderModel.fromOrderModel(OrderModel order){
    _orderId = order.id;
    _orderAmount = order.orderAmount;
    _deliveryCharge = order.deliveryCharge;
    _address = order.deliveryAddress.address;
    _latitude = order.deliveryAddress.latitude;
    _longitude = order.deliveryAddress.longitude;
  }
}
