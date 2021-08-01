import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:recyminer_miner/data/datasource/remote/dio/dio_client.dart';
import 'package:recyminer_miner/data/datasource/remote/exception/api_error_handler.dart';
import 'package:recyminer_miner/data/model/response/base/api_response.dart';
import 'package:recyminer_miner/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationOrderRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  LocationOrderRepo(
      {@required this.dioClient, @required this.sharedPreferences});

  Future<ApiResponse> getAllLocationOrders() async {
    try {
      final response =
          await dioClient.get('${AppConstants.AVAILABLE_ORDERS_URI}');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getLocationOrderDetails({String orderID}) async {
    try {
      final response = await dioClient.get(
          '${AppConstants.AVAILABLE_ORDERS_DETAILS_URI}${sharedPreferences.get(AppConstants.TOKEN)}&order_id=$orderID');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getAllOrderHistory() async {
    try {
      final response = await dioClient.get(
          '${AppConstants.ORDER_HISTORY_URI}${sharedPreferences.get(AppConstants.TOKEN)}');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> updateLocationOrderStatus(
      {String token, int orderId, String status}) async {
    try {
      Response response = await dioClient.post(
        AppConstants.UPDATE_ORDER_STATUS_URI,
        data: {
          "token": token,
          "order_id": orderId,
          "status": status,
          "_method": 'put'
        },
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> updatePaymentStatus(
      {String token, int orderId, String status}) async {
    try {
      Response response = await dioClient.post(
        AppConstants.UPDATE_PAYMENT_STATUS_URI,
        data: {
          "token": token,
          "order_id": orderId,
          "status": status,
          "_method": 'put'
        },
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getTimeSlot() async {
    try {
      final response = await dioClient.get('${AppConstants.TIMESLOT_URI}');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
