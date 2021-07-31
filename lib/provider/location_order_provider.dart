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

  // get order details
  OrderDetailsModel _orderDetailsModel = OrderDetailsModel();

  OrderDetailsModel get orderDetailsModel => _orderDetailsModel;
  List<OrderDetailsModel> _orderDetails;

  List<OrderDetailsModel> get orderDetails => _orderDetails;

  Future<List<OrderDetailsModel>> getLocationOrderDetails(String orderID, BuildContext context) async {
    _orderDetails = null;
    ApiResponse apiResponse = await locationOrderRepo.getLocationOrderDetails(orderID: orderID);
    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
      _orderDetails = [];
      apiResponse.response.data.forEach((orderDetail) => _orderDetails.add(OrderDetailsModel.fromJson(orderDetail)));
    } else {
      ApiChecker.checkApi(context, apiResponse);
    }
    notifyListeners();
    return _orderDetails;
  }

  // update Order Status
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String _feedbackMessage;

  String get feedbackMessage => _feedbackMessage;

  Future<ResponseModel> updateOrderStatus({String token, int orderId, String status}) async {
    _isLoading = true;
    _feedbackMessage = '';
    notifyListeners();
    ApiResponse apiResponse = await locationOrderRepo.updateLocationOrderStatus(
        token: token,
        orderId: orderId,
        status: status
    );
    _isLoading = false;
    notifyListeners();
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
      // _currentLocationOrdersReverse.firstWhere((element) => element.orderId == orderId).orderStatus = status;
      _feedbackMessage = apiResponse.response.data['message'];
      responseModel = ResponseModel(apiResponse.response.data['message'], true);
    } else {
      String errorMessage;
      if (apiResponse.error is String) {
        print(apiResponse.error.toString());
        errorMessage = apiResponse.error.toString();
      } else {
        ErrorResponse errorResponse = apiResponse.error;
        print(errorResponse.errors[0].message);
        errorMessage = errorResponse.errors[0].message;
      }
      _feedbackMessage = errorMessage;
      responseModel = ResponseModel(errorMessage, false);
    }
    notifyListeners();
    return responseModel;
  }
}
