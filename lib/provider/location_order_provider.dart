import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grocery_delivery_boy/data/model/response/base/api_response.dart';
import 'package:grocery_delivery_boy/data/model/response/base/error_response.dart';
import 'package:grocery_delivery_boy/data/model/response/location_order_model.dart';
import 'package:grocery_delivery_boy/data/model/response/order_details_model.dart';
import 'package:grocery_delivery_boy/data/model/response/order_model.dart';
import 'package:grocery_delivery_boy/data/model/response/timeslot_model.dart';
import 'package:grocery_delivery_boy/data/repository/location_order_repo.dart';
import 'package:grocery_delivery_boy/data/repository/order_repo.dart';
import 'package:grocery_delivery_boy/data/repository/response_model.dart';
import 'package:grocery_delivery_boy/helper/api_checker.dart';
import 'package:provider/provider.dart';

class LocationOrderProvider with ChangeNotifier {
  final LocationOrderRepo locationOrderRepo;

  LocationOrderProvider({@required this.locationOrderRepo});

  List<LocationOrderModel> _availableOrders = [];
  List<LocationOrderModel> _currentLocationOrdersReverse = [];

  List<LocationOrderModel> get availableOrders => _availableOrders;

  Future getAllAvailableOrders(BuildContext context) async {
    ApiResponse apiResponse = await locationOrderRepo.getAllLocationOrders();
    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
      _currentLocationOrdersReverse = [];
      apiResponse.response.data.forEach((order) {
        LocationOrderModel _orderModel = LocationOrderModel.fromJson(order);
        _currentLocationOrdersReverse.add(_orderModel);
      });
      _availableOrders = new List.from(_currentLocationOrdersReverse.reversed);
    } else {
      ApiChecker.checkApi(context, apiResponse);
    }
    notifyListeners();
  }

}
