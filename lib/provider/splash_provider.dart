import 'package:flutter/material.dart';
import 'package:recyminer_miner/data/model/response/base/api_response.dart';
import 'package:recyminer_miner/data/model/response/config_model.dart';
import 'package:recyminer_miner/data/repository/splash_repo.dart';
import 'package:recyminer_miner/helper/api_checker.dart';

class SplashProvider extends ChangeNotifier {
  final SplashRepo splashRepo;
  SplashProvider({@required this.splashRepo});

  ConfigModel _configModel;
  BaseUrls _baseUrls;

  ConfigModel get configModel => _configModel;
  BaseUrls get baseUrls => _baseUrls;

  Future<bool> initConfig(BuildContext context) async {
    ApiResponse apiResponse = await splashRepo.getConfig();
    bool isSuccess;
    if (apiResponse.response != null &&
        apiResponse.response.statusCode == 200) {
      _configModel = ConfigModel.fromJson(apiResponse.response.data);
      _baseUrls = ConfigModel.fromJson(apiResponse.response.data).baseUrls;
      isSuccess = true;
      notifyListeners();
    } else {
      isSuccess = false;
      ApiChecker.checkApi(context, apiResponse);
    }
    return isSuccess;
  }

  Future<bool> initSharedData() {
    return splashRepo.initSharedData();
  }

  Future<bool> removeSharedData() {
    return splashRepo.removeSharedData();
  }
}
