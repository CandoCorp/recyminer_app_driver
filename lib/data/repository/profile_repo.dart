import 'package:flutter/foundation.dart';
import 'package:recyminer_miner/data/datasource/remote/dio/dio_client.dart';
import 'package:recyminer_miner/data/datasource/remote/exception/api_error_handler.dart';
import 'package:recyminer_miner/data/model/response/base/api_response.dart';
import 'package:recyminer_miner/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepo {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  ProfileRepo({@required this.dioClient, @required this.sharedPreferences});

  Future<ApiResponse> getUserInfo() async {
    try {
      final response = await dioClient.get(
          '${AppConstants.PROFILE_URI}${sharedPreferences.getString(AppConstants.TOKEN)}');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
