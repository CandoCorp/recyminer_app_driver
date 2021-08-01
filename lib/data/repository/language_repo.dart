import 'package:flutter/material.dart';
import 'package:recyminer_miner/data/model/response/language_model.dart';
import 'package:recyminer_miner/utill/app_constants.dart';

class LanguageRepo {
  List<LanguageModel> getAllLanguages({BuildContext context}) {
    return AppConstants.languages;
  }
}
