import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:recyminer_miner/data/model/response/base/api_response.dart';
import 'package:recyminer_miner/data/model/response/location_mining_model.dart';
import 'package:recyminer_miner/data/repository/location_mining_repo.dart';
import 'package:recyminer_miner/helper/api_checker.dart';

class LocationMiningProvider with ChangeNotifier {
  final LocationMiningRepo locationMiningRepo;

  LocationMiningProvider({@required this.locationMiningRepo});

  List<LocationMiningModel> _availableLocations = [];
  List<LocationMiningModel> _availableLocationsReverse = [];

  List<LocationMiningModel> get availableLocations => _availableLocations;

  Future getAllAvailableMiningLocations(BuildContext context) async {
    ApiResponse apiResponse = await locationMiningRepo.getAllMiningLocations();
    if (apiResponse.response != null &&
        apiResponse.response.statusCode == 200) {
      _availableLocationsReverse = [];
      apiResponse.response.data.forEach((order) {
        LocationMiningModel _miningModel = LocationMiningModel.fromJson(order);
        _availableLocationsReverse.add(_miningModel);
      });
      _availableLocations = new List.from(_availableLocationsReverse.reversed);
    } else {
      ApiChecker.checkApi(context, apiResponse);
    }
    notifyListeners();
  }
}
