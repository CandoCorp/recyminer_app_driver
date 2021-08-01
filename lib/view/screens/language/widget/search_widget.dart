import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recyminer_miner/localization/language_constrants.dart';
import 'package:recyminer_miner/provider/language_provider.dart';
import 'package:recyminer_miner/utill/color_resources.dart';
import 'package:recyminer_miner/utill/dimensions.dart';
import 'package:recyminer_miner/utill/images.dart';

class SearchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, searchProvider, child) => TextField(
        cursorColor: ColorResources.COLOR_PRIMARY,
        onChanged: (String query) {
          searchProvider.searchLanguage(query, context);
        },
        style: Theme.of(context).textTheme.headline2.copyWith(
            color: ColorResources.COLOR_BLACK,
            fontSize: Dimensions.FONT_SIZE_LARGE),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 9, horizontal: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7.0),
            borderSide: BorderSide(style: BorderStyle.none, width: 0),
          ),
          isDense: true,
          hintText: getTranslated('find_language', context),
          fillColor: ColorResources.COLOR_WHITE,
          hintStyle: Theme.of(context).textTheme.headline2.copyWith(
              fontSize: Dimensions.FONT_SIZE_SMALL,
              color: ColorResources.COLOR_GREY_CHATEAU),
          filled: true,
          suffixIcon: Padding(
            padding: const EdgeInsets.only(
                left: Dimensions.PADDING_SIZE_LARGE,
                right: Dimensions.PADDING_SIZE_SMALL),
            child: Image.asset(Images.search, width: 15, height: 15),
          ),
        ),
      ),
    );
  }
}
