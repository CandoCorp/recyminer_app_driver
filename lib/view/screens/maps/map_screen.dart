// @dart=2.9
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery_delivery_boy/data/model/response/location_mining_model.dart';
import 'package:grocery_delivery_boy/data/model/response/location_order_model.dart';
import 'package:grocery_delivery_boy/data/model/response/order_model.dart';
import 'package:grocery_delivery_boy/localization/language_constrants.dart';
import 'package:grocery_delivery_boy/provider/location_mining_provider.dart';
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
import 'package:grocery_delivery_boy/view/screens/maps/widget/layer_chooser_plugin.dart';
import 'package:grocery_delivery_boy/view/screens/maps/widget/order_popup_widget.dart';
import 'package:grocery_delivery_boy/view/screens/maps/widget/zoombuttons_plugin.dart';
import 'package:grocery_delivery_boy/view/screens/order/widget/permission_dialog.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../data/model/response/location_order_model.dart';
import '../../../data/model/response/order_model.dart';
import '../../../provider/location_order_provider.dart';

class MapScreen extends StatelessWidget {
  // This widget is the root of your application.
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
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
                    : IconButton(
                        icon: Icon(Icons.refresh,
                            color: Theme.of(context).textTheme.bodyText1.color),
                        onPressed: () {
                          orderProvider.refresh(context);
                        });
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'language':
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            ChooseLanguageScreen(fromHomeScreen: true)));
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
                      Icon(Icons.language,
                          color: Theme.of(context).textTheme.bodyText1.color),
                      SizedBox(width: Dimensions.PADDING_SIZE_LARGE),
                      Text(
                        getTranslated('change_language', context),
                        style: Theme.of(context).textTheme.headline2.copyWith(
                            color: Theme.of(context).textTheme.bodyText1.color),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
          leading: SizedBox.shrink(),
          title: Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) => profileProvider
                        .userInfoModel !=
                    null
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
                            image:
                                '${Provider.of<SplashProvider>(context, listen: false).baseUrls.deliveryManImageUrl}/${profileProvider.userInfoModel.image}',
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
                        style: Theme.of(context).textTheme.headline3.copyWith(
                            fontSize: Dimensions.FONT_SIZE_LARGE,
                            color: Theme.of(context).textTheme.bodyText1.color),
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
            children: [Flexible(child: MapWidget())],
          ),
        ));
  }

  void _checkPermission(BuildContext context, Function callback) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PermissionDialog(
              isDenied: true,
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.requestPermission();
                _checkPermission(context, callback);
              }));
    } else if (permission == LocationPermission.deniedForever) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PermissionDialog(
              isDenied: false,
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.openAppSettings();
                _checkPermission(context, callback);
              }));
    } else {
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
  OrderProvider _orderProvider;
  LocationMiningProvider _miningProvider;

  Position _currentPosition;
  LatLng _currentLocation;
  String _currentAddress;

  // final Geolocator geolocator = Geolocator();

  Timer _timer;
  List<Marker> _markersClustered = [];
  List<Marker> _markers = [];

  Map _markerOrder;
  double _currentZoom = 15.0;
  double _maxZoom = 18.0;

  Map _layerStates;
  ValueNotifier _layerStatesNotifier;

  @override
  void initState() {
    super.initState();

    _layerStates = {0: true, 1: true};
    _markerOrder = {'orders': [], 'mining': []};

    _layerStatesNotifier = new ValueNotifier(_layerStates);
    _layerStatesNotifier.addListener(() {
      setState(() {
        _filterDataPoints();
      });
    });

    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((position) {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _markers.insert(
          0,
          Marker(
              anchorPos: AnchorPos.align(AnchorAlign.center),
              height: 40,
              width: 40,
              point: _currentLocation,
              key: new Key("0"),
              builder: (ctx) {
                return Container(
                  key: Key('purple'),
                  child: Icon(
                    Icons.location_history,
                    size: 48,
                  ),
                );
                return Icon(Icons.pin_drop_outlined);
              }));
    });

    provider = Provider.of<LocationOrderProvider>(context, listen: false);
    _orderProvider = Provider.of<OrderProvider>(context, listen: false);
    _miningProvider =
        Provider.of<LocationMiningProvider>(context, listen: false);

    provider.addListener(() {
      if (this.mounted)
        setState(() {
          _repaintOrderDataPoints();
        });
    });

    _miningProvider.addListener(() {
      if (this.mounted)
        setState(() {
          _repaintMiningDataPoints();
        });
    });

    _fetchOrderDataPoints(context);
    _fetchMiningDataPoints(context);
    _orderProvider.getPendingOrders(context);

    _timer = Timer.periodic(Duration(seconds: 600), (_) {
      setState(() {
        _fetchOrderDataPoints(context);
        _fetchMiningDataPoints(context);
        _orderProvider.getPendingOrders(context);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _layerStatesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((position) {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    return _currentLocation != null
        ? Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_currentLocation != null)
                    _mapController.move(_currentLocation, _currentZoom);
                });
              },
              child: Icon(Icons.refresh),
            ),
            body: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentLocation != null
                    ? _currentLocation
                    : LatLng(-2.0, -79.00),
                zoom: _currentZoom,
                maxZoom: _maxZoom,
                plugins: [
                  MarkerClusterPlugin(),
                  MarkerClusterPlugin(),
                  ZoomButtonsPlugin(),
                  LayerChooserPlugin()
                ],
                onTap: (_) => _popupController
                    .hidePopup(), // Hide popup when the map is tapped.
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayerOptions(markers: _markers),
                MarkerClusterLayerOptions(
                  maxClusterRadius: 120,
                  size: Size(40, 40),
                  anchor: AnchorPos.align(AnchorAlign.center),
                  fitBoundsOptions: FitBoundsOptions(
                    padding: EdgeInsets.all(50),
                  ),
                  markers: _layerStates[0]
                      ? List.castFrom(_markerOrder['orders'])
                      : [],
                  polygonOptions: PolygonOptions(
                      borderColor: Colors.blueAccent,
                      color: Colors.black12,
                      borderStrokeWidth: 3),
                  popupOptions: PopupOptions(
                      popupSnap: PopupSnap.markerTop,
                      popupController: _popupController,
                      popupBuilder: (_, marker) => Container(
                            width: 300,
                            height: 180,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Theme.of(context)
                                          .shadowColor
                                          .withOpacity(.5),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(0, 1))
                                ],
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.PADDING_SIZE_SMALL)),
                            child: GestureDetector(
                                onTap: () => debugPrint('Popup tap!'),
                                child: Consumer<OrderProvider>(
                                    builder: (context, orderProvider, child) {
                                  if (_orderProvider.pendingOrders != null &&
                                      _orderProvider.pendingOrders.length != 0)
                                    return OrderWidget(
                                      orderModel: _fetchOrderModel(marker.key),
                                      index: _markersClustered.indexWhere(
                                          (_marker) =>
                                              _marker.key == marker.key),
                                    );
                                  return SizedBox.shrink();
                                })),
                          )),
                  builder: (context, markers) {
                    return FloatingActionButton(
                      onPressed: null,
                      child: Text(markers.length.toString()),
                    );
                  },
                ),
                MarkerClusterLayerOptions(
                  maxClusterRadius: 12,
                  size: Size(20, 20),
                  anchor: AnchorPos.align(AnchorAlign.center),
                  fitBoundsOptions: FitBoundsOptions(
                    padding: EdgeInsets.all(50),
                  ),
                  markers: _layerStates[1]
                      ? List.castFrom(_markerOrder['mining'])
                      : [],
                  polygonOptions: PolygonOptions(
                      borderColor: Colors.blueAccent,
                      color: Colors.green,
                      borderStrokeWidth: 3),
                  popupOptions: PopupOptions(
                      popupSnap: PopupSnap.markerTop,
                      popupController: _popupController,
                      popupBuilder: (_, marker) => Container(
                            width: 300,
                            height: 180,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Theme.of(context)
                                          .shadowColor
                                          .withOpacity(.5),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(0, 1))
                                ],
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.PADDING_SIZE_SMALL)),
                            child: GestureDetector(
                                onTap: () => debugPrint('Popup tap!'),
                                child: Consumer<OrderProvider>(
                                    builder: (context, orderProvider, child) {
                                  if (_orderProvider.pendingOrders != null &&
                                      _orderProvider.pendingOrders.length != 0)
                                    return OrderPopupWidget(
                                      orderModel: _fetchOrderModel(marker.key),
                                      isPending: true,
                                    );
                                  return SizedBox.shrink();
                                })),
                          )),
                  builder: (context, markers) {
                    return FloatingActionButton(
                      onPressed: null,
                      child: Text(markers.length.toString()),
                      backgroundColor: Colors.green,
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
                LayerChooserPluginOptions(
                    mini: false,
                    padding: 10,
                    layerState: _layerStates,
                    mapState: _layerStatesNotifier)
              ],
            ))
        : Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor)));
  }

  void _fetchOrderDataPoints(BuildContext context) {
    provider.getAllAvailableOrders(context);
  }

  void _repaintOrderDataPoints() {
    if (provider.availableOrders != null) {
      List _markers = [];
      for (LocationOrderModel order in provider.availableOrders) {
        Marker _marker = Marker(
          anchorPos: AnchorPos.align(AnchorAlign.center),
          height: 40,
          width: 40,
          point: LatLng(
              double.parse(order.latitude), double.parse(order.longitude)),
          key: new Key(order.orderId.toString()),
          builder: (ctx) {
            return Column(
              children: [
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    order.orderAmount.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.monetization_on_outlined)
              ],
            );
            // return Icon(Icons.pin_drop);
          },
        );
        _markers.add(_marker);
      }
      _markerOrder['orders'] = List.from(_markers);
      // _markersClustered = List.from(_markers);
    }
  }

  void _fetchMiningDataPoints(BuildContext context) {
    _miningProvider.getAllAvailableMiningLocations(context);
  }

  void _repaintMiningDataPoints() {
    if (_miningProvider.availableLocations != null) {
      List _markers = [];
      for (LocationMiningModel miningLocation
          in _miningProvider.availableLocations) {
        Marker _marker = Marker(
          anchorPos: AnchorPos.align(AnchorAlign.center),
          height: 40,
          width: 40,
          point: LatLng(double.parse(miningLocation.latitude),
              double.parse(miningLocation.longitude)),
          key: new Key(miningLocation.orderId.toString()),
          builder: (ctx) {
            return Column(
              children: [
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    miningLocation.miningAmount.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.restore_from_trash_outlined)
              ],
            );
          },
        );
        _markers.add(_marker);
      }
      _markerOrder['mining'] = List.from(_markers);
      // _markersClustered = List.from(_markers);
    }
  }

  void _filterDataPoints() {
    List _markers = [];
    if (_layerStates[0]) _markers.addAll(_markerOrder['orders']);

    if (_layerStates[1]) _markers.addAll(_markerOrder['mining']);
    _markersClustered = List.from(_markers);
  }

  OrderModel _fetchOrderModel(Key key) {
    OrderModel model;

    final start = "[<'";
    final end = "'>]";

    final startIndex = key.toString().indexOf(start);
    final endIndex = key.toString().indexOf(end);
    final result =
        key.toString().substring(startIndex + start.length, endIndex).trim();

    if (_orderProvider.pendingOrders != null) {
      model = _orderProvider.pendingOrders
          .firstWhere((element) => element.id.toString() == result);
    }

    return model;
  }

  Future<void> _getCurrentLocation() async {
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
