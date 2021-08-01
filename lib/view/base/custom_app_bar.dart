import 'package:flutter/material.dart';
import 'package:recyminer_miner/utill/color_resources.dart';
import 'package:recyminer_miner/utill/dimensions.dart';
import 'package:recyminer_miner/utill/styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isBackButtonExist;
  CustomAppBar({@required this.title, this.isBackButtonExist = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title,
          style: rubikMedium.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE)),
      centerTitle: true,
      leading: isBackButtonExist
          ? IconButton(
              icon:
                  Icon(Icons.arrow_back_ios, color: ColorResources.COLOR_BLACK),
              onPressed: () => Navigator.pop(context),
            )
          : SizedBox(),
      backgroundColor: ColorResources.COLOR_WHITE,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size(double.maxFinite, 50);
}
