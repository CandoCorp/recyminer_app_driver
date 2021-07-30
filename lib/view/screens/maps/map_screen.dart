// @dart=2.9
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery_delivery_boy/data/model/response/location_order_model.dart';
import 'package:grocery_delivery_boy/data/model/response/order_model.dart';
import 'package:grocery_delivery_boy/localization/language_constrants.dart';
import 'package:grocery_delivery_boy/provider/location_order_provider.dart';
import 'package:grocery_delivery_boy/provider/order_provider.dart';
import 'package:grocery_delivery_boy/provider/profile_provider.dart';
import 'package:grocery_delivery_boy/provider/splash_provider.dart';
import 'package:grocery_delivery_boy/provider/tracker_provider.dart';
import 'package:grocery_delivery_boy/utill/dimensions.dart';
import 'package:grocery_delivery_boy/utill/images.dart';
import 'package:grocery_delivery_boy/view/screens/home/widget/order_widget.dart';
import 'package:grocery_delivery_boy/view/screens/language/choose_language_screen.dart';
import 'package:grocery_delivery_boy/view/screens/maps/widget/drawer.dart';
import 'package:grocery_delivery_boy/view/screens/maps/widget/zoombuttons_plugin.dart';
import 'package:grocery_delivery_boy/view/screens/order/widget/permission_dialog.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../data/model/response/location_order_model.dart';
import '../../../data/model/response/location_order_model.dart';
import '../../../data/model/response/location_order_model.dart';
import '../../../data/model/response/order_model.dart';
import '../../../provider/location_order_provider.dart';
import '../../../provider/location_order_provider.dart';
import '../../../provider/location_order_provider.dart';
import '../../../provider/location_order_provider.dart';
import '../../../provider/location_order_provider.dart';
import '../../../provider/location_order_provider.dart';
import '../../../provider/location_order_provider.dart';
import '../../../provider/location_order_provider.dart';

class MapScreen extends StatelessWidget {
  // This widget is the root of your application.
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  static const String route = '/moving_markers';

  @override
  Widget build(BuildContext context) {
    Provider.of<OrderProvider>(context, listen: false).getAllOrders(context);
    Provider.of<ProfileProvider>(context, listen: false).getUserInfo(context);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        leadingWidth: 0,
        actions: [
          Consumer<OrderProvider>(
            builder: (context, orderProvider, child) {
              if (orderProvider.currentOrders != null) {
                for (OrderModel order in orderProvider.currentOrders) {
                  if (order.orderStatus == 'out_for_delivery') {
                    _checkPermission(context, () {
                      Provider.of<TrackerProvider>(context, listen: false)
                          .setOrderID(order.id);
                      Provider.of<TrackerProvider>(context, listen: false)
                          .startLocationService();
                    });
                    break;
                  }
                }
              }
              return orderProvider.currentOrders.length > 0
                  ? SizedBox.shrink()
                  : IconButton(icon: Icon(Icons.refresh, color: Theme
                  .of(context)
                  .textTheme
                  .bodyText1
                  .color),
                  onPressed: () {
                    orderProvider.refresh(context);
                  });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'language':
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChooseLanguageScreen(fromHomeScreen: true)));
              }
            },
            icon: Icon(
              Icons.more_vert_outlined,
              color: Theme.of(context).textTheme.bodyText1.color,
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'language',
                child: Row(
                  children: [
                    Icon(Icons.language, color: Theme.of(context).textTheme.bodyText1.color),
                    SizedBox(width: Dimensions.PADDING_SIZE_LARGE),
                    Text(
                      getTranslated('change_language', context),
                      style: Theme.of(context).textTheme.headline2.copyWith(color: Theme.of(context).textTheme.bodyText1.color),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
        leading: SizedBox.shrink(),
        title: Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) => profileProvider.userInfoModel != null
              ? Row(
            children: [
              Container(
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FadeInImage.assetNetwork(
                    placeholder: Images.placeholder_user,
                    width: 40,
                    height: 40,
                    fit: BoxFit.fill,
                    image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls.deliveryManImageUrl}/${profileProvider.userInfoModel.image}',
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                profileProvider.userInfoModel.fName != null
                    ? '${profileProvider.userInfoModel.fName ?? ''} ${profileProvider.userInfoModel.lName ?? ''}'
                    : "",
                style:
                Theme.of(context).textTheme.headline3.copyWith(fontSize: Dimensions.FONT_SIZE_LARGE, color: Theme.of(context).textTheme.bodyText1.color),
              )
            ],
          )
              : SizedBox.shrink(),
        ),
      ),
      drawer: buildDrawer(context, route),
      body: Padding(
        padding: EdgeInsets.all(2.0),
        child: Column(
          children: [
            Flexible(child: MapWidget())
          ],
        ),
      )
    );
  }
  void _checkPermission(BuildContext context, Function callback) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showDialog(context: context, barrierDismissible: false, builder: (context) => PermissionDialog(isDenied: true, onPressed: () async {
        Navigator.pop(context);
        await Geolocator.requestPermission();
        _checkPermission(context, callback);
      }));
    }else if(permission == LocationPermission.deniedForever) {
      showDialog(context: context, barrierDismissible: false, builder: (context) => PermissionDialog(isDenied: false, onPressed: () async {
        Navigator.pop(context);
        await Geolocator.openAppSettings();
        _checkPermission(context, callback);
      }));
    }else {
      callback();
    }
  }
}

class MapWidget extends StatefulWidget {

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final PopupController _popupController = PopupController();
  final MapController _mapController = MapController();

  LocationOrderProvider provider;

  Position _currentPosition;
  LatLng _currentLocation;
  String _currentAddress;

  // final Geolocator geolocator = Geolocator();

  Timer _timer;
  List<Marker> markers = [];

  double _currentZoom = 4.0;
  double _maxZoom = 5.0;

  int pointIndex;
  List points = [
    LatLng(51.5, -0.09),
    LatLng(49.8566, 3.3522),
  ];

  @override
  void initState() {
    super.initState();

    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((position) {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    provider = Provider.of<LocationOrderProvider>(context, listen: false);

    _timer = Timer.periodic(Duration(seconds: 10), (_) {
      setState(() {
        _fetchDataPoints();
      });
    });

    _currentZoom = 5.0;
    _maxZoom = 15.0;

    pointIndex = 0;

    // _getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // pointIndex++;
          // if (pointIndex >= points.length) {
          //   pointIndex = 0;
          // }
          // setState(() {
          //   markers[0] = Marker(
          //     point: points[pointIndex],
          //     anchorPos: AnchorPos.align(AnchorAlign.center),
          //     height: 30,
          //     width: 30,
          //     builder: (ctx) => Icon(Icons.pin_drop),
          //   );
          //   markers = List.from(markers);

          // });
          Text(markers.length.toString());
        },
        child: Icon(Icons.refresh),
      ),
      body: Consumer<LocationOrderProvider>(
          builder: (context, locationOrder, child) {
            if(locationOrder.availableOrders != null) {
              for (LocationOrderModel order in locationOrder.availableOrders) {
                LatLng _latlng = LatLng(
                    double.parse(order.latitude),
                    double.parse(order.longitude)
                );
                Marker _marker = Marker(
                  anchorPos: AnchorPos.align(AnchorAlign.center),
                  height: 30,
                  width: 30,
                  point: _latlng,
                  builder: (ctx) => Icon(Icons.pin_drop),
                );
                markers.add(_marker);
              }
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: markers != null ? markers.isNotEmpty ? markers[0].point : LatLng(51.5, -0.09) : LatLng(51.5, -0.09),
                  zoom: _currentZoom,
                  maxZoom: _maxZoom,
                  plugins: [
                    MarkerClusterPlugin(),
                    ZoomButtonsPlugin()
                  ],
                  onTap: (_) => _popupController
                      .hidePopup(), // Hide popup when the map is tapped.
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerClusterLayerOptions(
                    maxClusterRadius: 120,
                    size: Size(40, 40),
                    anchor: AnchorPos.align(AnchorAlign.center),
                    fitBoundsOptions: FitBoundsOptions(
                      padding: EdgeInsets.all(50),
                    ),
                    markers: markers,
                    polygonOptions: PolygonOptions(
                        borderColor: Colors.blueAccent,
                        color: Colors.black12,
                        borderStrokeWidth: 3),
                    popupOptions: PopupOptions(
                        popupSnap: PopupSnap.markerTop,
                        popupController: _popupController,
                        popupBuilder: (_, marker) => Container(
                          width: 200,
                          height: 100,
                          color: Colors.white,
                          child: GestureDetector(
                              onTap: () => debugPrint('Popup tap!'),
                              child: Text(markers.length.toString())
                          ),
                        )),
                    builder: (context, markers) {
                      return FloatingActionButton(
                        onPressed: null,
                        child: Text(markers.length.toString()),
                      );
                    },
                  ),
                ],
                nonRotatedLayers: [
                  ZoomButtonsPluginOption(
                    minZoom: 5,
                    maxZoom: 15,
                    mini: false,
                    padding: 10,
                    alignment: Alignment.topRight,
                  ),
                ],
              );
            }else {
              return CircularProgressIndicator();
            }
      }),
    );
    // return Scaffold(
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: () {
    //       // pointIndex++;
    //       // if (pointIndex >= points.length) {
    //       //   pointIndex = 0;
    //       // }
    //       // setState(() {
    //       //   markers[0] = Marker(
    //       //     point: points[pointIndex],
    //       //     anchorPos: AnchorPos.align(AnchorAlign.center),
    //       //     height: 30,
    //       //     width: 30,
    //       //     builder: (ctx) => Icon(Icons.pin_drop),
    //       //   );
    //       //   markers = List.from(markers);
    //
    //       // });
    //       Text(markers.length.toString());
    //     },
    //     child: Icon(Icons.refresh),
    //   ),
    //   body: FlutterMap(
    //     mapController: _mapController,
    //     options: MapOptions(
    //       center: markers != null ? markers.isNotEmpty ? markers[0].point : LatLng(51.5, -0.09) : LatLng(51.5, -0.09),
    //       zoom: _currentZoom,
    //       maxZoom: _maxZoom,
    //       plugins: [
    //         MarkerClusterPlugin(),
    //         ZoomButtonsPlugin()
    //       ],
    //       onTap: (_) => _popupController
    //           .hidePopup(), // Hide popup when the map is tapped.
    //     ),
    //     layers: [
    //       TileLayerOptions(
    //         urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    //         subdomains: ['a', 'b', 'c'],
    //       ),
    //       MarkerClusterLayerOptions(
    //         maxClusterRadius: 120,
    //         size: Size(40, 40),
    //         anchor: AnchorPos.align(AnchorAlign.center),
    //         fitBoundsOptions: FitBoundsOptions(
    //           padding: EdgeInsets.all(50),
    //         ),
    //         markers: markers,
    //         polygonOptions: PolygonOptions(
    //             borderColor: Colors.blueAccent,
    //             color: Colors.black12,
    //             borderStrokeWidth: 3),
    //         popupOptions: PopupOptions(
    //             popupSnap: PopupSnap.markerTop,
    //             popupController: _popupController,
    //             popupBuilder: (_, marker) => Container(
    //               width: 200,
    //               height: 100,
    //               color: Colors.white,
    //               child: GestureDetector(
    //                   onTap: () => debugPrint('Popup tap!'),
    //                   child: Text(markers.length.toString())
    //               ),
    //             )),
    //         builder: (context, markers) {
    //           return FloatingActionButton(
    //             onPressed: null,
    //             child: Text(markers.length.toString()),
    //           );
    //         },
    //       ),
    //     ],
    //     nonRotatedLayers: [
    //       ZoomButtonsPluginOption(
    //         minZoom: 5,
    //         maxZoom: 15,
    //         mini: false,
    //         padding: 10,
    //         alignment: Alignment.topRight,
    //       ),
    //     ],
    //   )
    // );
  }

  void _fetchDataPoints(){
    provider.getAllAvailableOrders(context).then((x) {
      if (provider.availableOrders != null){
        for (LocationOrderModel order in provider.availableOrders){
          LatLng _latlng = LatLng(
              double.parse(order.latitude),
              double.parse(order.longitude)
          );
          Marker _marker = Marker(
            anchorPos: AnchorPos.align(AnchorAlign.center),
            height: 30,
            width: 30,
            point: _latlng,
            builder: (ctx) => Icon(Icons.pin_drop),
          );
          markers = [];
          markers.add(_marker);
          _mapController.move(_currentLocation, _currentZoom);
        }
      }
    }).onError((error, stackTrace) {
      debugPrint(error);
    });
  }

  Future<void> _getCurrentLocation() async{

    // verify permissions
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      await Geolocator.openLocationSettings();
    }
    // get current position
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // get address
    _currentAddress = await _getGeolocationAddress(_currentPosition);
  }

  // Method to get Address from position:
  Future<String> _getGeolocationAddress(Position position) async {
    // geocoding
    var places = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (places != null && places.isNotEmpty) {
      final Placemark place = places.first;
      return "${place.thoroughfare}, ${place.locality}";
    }

    return "No address available";
  }
}
