import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:recyminer_miner/data/model/response/order_model.dart';
import 'package:recyminer_miner/localization/language_constrants.dart';
import 'package:recyminer_miner/provider/auth_provider.dart';
import 'package:recyminer_miner/provider/localization_provider.dart';
import 'package:recyminer_miner/provider/order_provider.dart';
import 'package:recyminer_miner/utill/dimensions.dart';
import 'package:recyminer_miner/utill/images.dart';
import 'package:recyminer_miner/view/base/custom_button.dart';
import 'package:recyminer_miner/view/screens/order/order_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderPopupWidget extends StatelessWidget {
  final OrderModel orderModel;
  final bool isPending;
  bool loading = false;
  OrderPopupWidget({this.orderModel, this.isPending = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      margin: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_SMALL),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(.5),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1))
          ],
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.PADDING_SIZE_SMALL)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    getTranslated('order_id', context),
                    style: Theme.of(context).textTheme.headline2.copyWith(
                        color: Theme.of(context).textTheme.bodyText1.color),
                  ),
                  Text(
                    ' # ${orderModel.id.toString()}',
                    style: Theme.of(context).textTheme.headline3.copyWith(
                        color: Theme.of(context).textTheme.bodyText1.color),
                  ),
                ],
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(),
                  Provider.of<LocalizationProvider>(context).isLtr
                      ? Positioned(
                          right: -10,
                          top: -23,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                                horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(
                                        Dimensions.PADDING_SIZE_SMALL),
                                    bottomLeft: Radius.circular(
                                        Dimensions.PADDING_SIZE_SMALL))),
                            child: Text(
                              getTranslated(
                                  '${orderModel.orderStatus}', context),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline1
                                  .copyWith(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: Dimensions.FONT_SIZE_SMALL),
                            ),
                          ),
                        )
                      : Positioned(
                          left: -10,
                          top: -28,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                                horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(
                                        Dimensions.PADDING_SIZE_SMALL),
                                    bottomLeft: Radius.circular(
                                        Dimensions.PADDING_SIZE_SMALL))),
                            child: Text(
                              getTranslated(
                                  '${orderModel.orderStatus}', context),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline1
                                  .copyWith(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: Dimensions.FONT_SIZE_SMALL),
                            ),
                          ),
                        )
                ],
              ),
            ],
          ),
          SizedBox(height: 25),
          Row(
            children: [
              Image.asset(Images.location,
                  color: Theme.of(context).textTheme.bodyText1.color,
                  width: 15,
                  height: 20),
              SizedBox(width: 10),
              Expanded(
                  child: Text(
                orderModel.deliveryAddress != null
                    ? orderModel.deliveryAddress.address
                    : 'Address not found',
                style: Theme.of(context).textTheme.headline2.copyWith(
                    color: Theme.of(context).textTheme.bodyText1.color),
              )),
            ],
          ),
          SizedBox(height: 25),
          Row(
            children: [
              isPending
                  ? loading
                      ? null
                      : Expanded(
                          child: CustomButton(
                          btnTxt: 'Take it',
                          onTap: () async {
                            loading = true;

                            String token = Provider.of<AuthProvider>(context,
                                    listen: false)
                                .getUserToken();
                            await Provider.of<OrderProvider>(context,
                                    listen: false)
                                .updateOrderToMe(
                                    token: token,
                                    orderId: orderModel.id,
                                    status: 'processing');

                            await Provider.of<OrderProvider>(context,
                                    listen: false)
                                .getAllOrders(context);

                            //if (_orderProvider.pendingOrders != null) {
                            //      model = _orderProvider.pendingOrders
                            //          .firstWhere((element) => element.id.toString() == result);

                            var x = Provider.of<OrderProvider>(context,
                                    listen: false)
                                .currentOrders
                                .firstWhere((element) =>
                                    element.id.toString() ==
                                    orderModel.id.toString());

                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) =>
                                    OrderDetailsScreen(orderModel: x)));
                          },
                          //isShowBorder: true,
                        ))
                  : Expanded(
                      child: CustomButton(
                      btnTxt: getTranslated('view_details', context),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) =>
                                OrderDetailsScreen(orderModel: orderModel)));
                      },
                      isShowBorder: true,
                    )),
              isPending ? SizedBox(width: 0) : SizedBox(width: 20),
              isPending
                  ? SizedBox(width: 0)
                  : Expanded(
                      child: CustomButton(
                          btnTxt: getTranslated('direction', context),
                          onTap: () {
                            Geolocator.getCurrentPosition(
                                    desiredAccuracy: LocationAccuracy.high)
                                .then((position) {
                              MapUtils.openMap(
                                  double.parse(orderModel
                                          .deliveryAddress.latitude) ??
                                      23.8103,
                                  double.parse(orderModel
                                          .deliveryAddress.longitude) ??
                                      90.4125,
                                  position.latitude ?? 23.8103,
                                  position.longitude ?? 90.4125);
                            });
                          })),
            ],
          ),
        ],
      ),
    );
  }
}

//OrderModel _fetchOrderModel(Key key) {
//  OrderModel model;
//
//  final start = "[<'";
//  final end = "'>]";
//
//  final startIndex = key.toString().indexOf(start);
//  final endIndex = key.toString().indexOf(end);
//  final result =
//  key.toString().substring(startIndex + start.length, endIndex).trim();
//
//  if (_orderProvider.pendingOrders != null) {
//    model = _orderProvider.pendingOrders
//        .firstWhere((element) => element.id.toString() == result);
//  }
//
//  return model;
//}

class MapUtils {
  MapUtils._();

  static Future<void> openMap(
      double destinationLatitude,
      double destinationLongitude,
      double userLatitude,
      double userLongitude) async {
    String googleUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$userLatitude,$userLongitude'
        '&destination=$destinationLatitude,$destinationLongitude&mode=d';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}
