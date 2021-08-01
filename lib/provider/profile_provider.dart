import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:recyminer_miner/data/model/response/base/api_response.dart';
import 'package:recyminer_miner/data/model/response/userinfo_model.dart';
import 'package:recyminer_miner/data/repository/profile_repo.dart';
import 'package:recyminer_miner/helper/api_checker.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepo profileRepo;

  ProfileProvider({@required this.profileRepo});

  UserInfoModel _userInfoModel;

  UserInfoModel get userInfoModel => _userInfoModel;

  getUserInfo(BuildContext context) async {
    ApiResponse apiResponse = await profileRepo.getUserInfo();
    if (apiResponse.response != null &&
        apiResponse.response.statusCode == 200) {
      _userInfoModel = UserInfoModel.fromJson(apiResponse.response.data);
    } else {
      if (apiResponse.error is String) {
        print(apiResponse.error.toString());
      } else {
        ApiChecker.checkApi(context, apiResponse);
      }
    }
    notifyListeners();
  }
}
