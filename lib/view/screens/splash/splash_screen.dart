import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recyminer_miner/provider/auth_provider.dart';
import 'package:recyminer_miner/provider/splash_provider.dart';
import 'package:recyminer_miner/utill/app_constants.dart';
import 'package:recyminer_miner/utill/images.dart';
import 'package:recyminer_miner/utill/styles.dart';
import 'package:recyminer_miner/view/screens/dashboard/dashboard_screen.dart';
import 'package:recyminer_miner/view/screens/language/choose_language_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _route();
  }

  void _route() {
    Provider.of<SplashProvider>(context, listen: false).initSharedData();
    Provider.of<SplashProvider>(context, listen: false)
        .initConfig(context)
        .then((bool isSuccess) {
      if (isSuccess) {
        Timer(Duration(seconds: 1), () async {
          if (Provider.of<AuthProvider>(context, listen: false).isLoggedIn()) {
            Provider.of<AuthProvider>(context, listen: false).updateToken();
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => DashboardScreen()));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => ChooseLanguageScreen()));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(Images.logo, width: 150)),
            SizedBox(height: 20),
            Text(AppConstants.APP_NAME,
                style: rubikBold.copyWith(
                    fontSize: 30, color: Theme.of(context).primaryColor),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
