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

import '../data/model/response/order_model.dart';

class LocationOrderProvider with ChangeNotifier {
  final LocationOrderRepo locationOrderRepo;

  LocationOrderProvider({@required this.locationOrderRepo});

  // get all current order
  List<TimeSlotModel> _timeSlots;

  List<LocationOrderModel> _availableOrders = [];
  List<LocationOrderModel> _currentLocationOrdersReverse = [];

  List<LocationOrderModel> get availableOrders => _availableOrders;

  List<TimeSlotModel> get timeSlots => _timeSlots;

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
//
  // get all order history
  List<LocationOrderModel> _allLocationOrderHistory;
  List<OrderModel> _allOrderReverse;

  List<LocationOrderModel> get allLocationOrderHistory => _allLocationOrderHistory;

  Future<List<LocationOrderModel>> getLocationOrderHistory(BuildContext context) async {
    ApiResponse apiResponse = await locationOrderRepo.getAllOrderHistory();
    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
      _allLocationOrderHistory = [];
      _allOrderReverse = [];
      apiResponse.response.data.forEach((orderDetail) => _allOrderReverse.add(OrderModel.fromJson(orderDetail)));
      _allOrderReverse = _allOrderReverse.reversed;
      _allOrderReverse.removeWhere((order) => order.orderStatus != 'delivered');
      _allOrderReverse.forEach((order) {
        _allLocationOrderHistory.add(LocationOrderModel.fromOrderModel(order));
      });

    } else {
      ApiChecker.checkApi(context, apiResponse);
    }
    notifyListeners();
    return _allLocationOrderHistory;
  }

//  // update Order Status
//  bool _isLoading = false;
//
//  bool get isLoading => _isLoading;
//  String _feedbackMessage;
//
//  String get feedbackMessage => _feedbackMessage;
//
//  Future<ResponseModel> updateOrderStatus({String token, int orderId, String status, int index}) async {
//    _isLoading = true;
//    _feedbackMessage = '';
//    notifyListeners();
//    ApiResponse apiResponse = await orderRepo.updateOrderStatus(token: token, orderId: orderId, status: status);
//    _isLoading = false;
//    notifyListeners();
//    ResponseModel responseModel;
//    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
//      _currentOrdersReverse[index].orderStatus = status;
//      _feedbackMessage = apiResponse.response.data['message'];
//      responseModel = ResponseModel(apiResponse.response.data['message'], true);
//    } else {
//      String errorMessage;
//      if (apiResponse.error is String) {
//        print(apiResponse.error.toString());
//        errorMessage = apiResponse.error.toString();
//      } else {
//        ErrorResponse errorResponse = apiResponse.error;
//        print(errorResponse.errors[0].message);
//        errorMessage = errorResponse.errors[0].message;
//      }
//      _feedbackMessage = errorMessage;
//      responseModel = ResponseModel(errorMessage, false);
//    }
//    notifyListeners();
//    return responseModel;
//  }
//
//  Future updatePaymentStatus({String token, int orderId, String status}) async {
//    ApiResponse apiResponse = await orderRepo.updatePaymentStatus(token: token, orderId: orderId, status: status);
//
//    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
//    } else {
//      if (apiResponse.error is String) {
//        print(apiResponse.error.toString());
//      } else {
//        ErrorResponse errorResponse = apiResponse.error;
//        print(errorResponse.errors[0].message);
//      }
//    }
//    notifyListeners();
//  }

  Future<List<LocationOrderModel>> refresh(BuildContext context) async{
    getAllAvailableOrders(context);
    Timer(Duration(seconds: 5), () {});
    return getLocationOrderHistory(context);
  }

  Future<void> initializeTimeSlot(BuildContext context) async {
    ApiResponse apiResponse = await locationOrderRepo.getTimeSlot();
    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
      _timeSlots = [];
      apiResponse.response.data.forEach((timeSlot) => _timeSlots.add(TimeSlotModel.fromJson(timeSlot)));
    } else {
      ApiChecker.checkApi(context, apiResponse);
    }
    notifyListeners();
  }
}
