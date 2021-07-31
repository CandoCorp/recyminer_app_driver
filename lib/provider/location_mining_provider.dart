import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grocery_delivery_boy/data/model/response/base/api_response.dart';
import 'package:grocery_delivery_boy/data/model/response/base/error_response.dart';
import 'package:grocery_delivery_boy/data/model/response/location_mining_model.dart';
import 'package:grocery_delivery_boy/data/model/response/location_order_model.dart';
import 'package:grocery_delivery_boy/data/model/response/order_details_model.dart';
import 'package:grocery_delivery_boy/data/model/response/order_model.dart';
import 'package:grocery_delivery_boy/data/model/response/timeslot_model.dart';
import 'package:grocery_delivery_boy/data/repository/location_mining_repo.dart';
import 'package:grocery_delivery_boy/data/repository/location_order_repo.dart';
import 'package:grocery_delivery_boy/data/repository/order_repo.dart';
import 'package:grocery_delivery_boy/data/repository/response_model.dart';
import 'package:grocery_delivery_boy/helper/api_checker.dart';
import 'package:provider/provider.dart';

class LocationMiningProvider with ChangeNotifier {
  final LocationMiningRepo locationMiningRepo;

  LocationMiningProvider({@required this.locationMiningRepo});

  List<LocationMiningModel> _availableLocations = [];
  List<LocationMiningModel> _availableLocationsReverse = [];

  List<LocationMiningModel> get availableLocations => _availableLocations;

  Future getAllAvailableMiningLocations(BuildContext context) async {
    ApiResponse apiResponse = await locationMiningRepo.getAllMiningLocations();
    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
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
