import 'package:flutter/material.dart';
//import 'package:flutter_map_example/pages/marker_rotate.dart';
//import 'package:flutter_map_example/pages/network_tile_provider.dart';
//
//import '../pages/animated_map_controller.dart';
//import '../pages/circle.dart';
//import '../pages/custom_crs/custom_crs.dart';
//import '../pages/esri.dart';
//import '../pages/home.dart';
//import '../pages/interactive_test_page.dart';
//import '../pages/live_location.dart';
//import '../pages/many_markers.dart';
//import '../pages/map_controller.dart';
//import '../pages/marker_anchor.dart';
//import '../pages/moving_markers.dart';
//import '../pages/offline_map.dart';
//import '../pages/on_tap.dart';
//import '../pages/overlay_image.dart';
//import '../pages/plugin_api.dart';
//import '../pages/plugin_scalebar.dart';
//import '../pages/plugin_zoombuttons.dart';
//import '../pages/polyline.dart';
//import '../pages/sliding_map.dart';
//import '../pages/stateful_markers.dart';
//import '../pages/tap_to_add.dart';
//import '../pages/tile_builder_example.dart';
//import '../pages/tile_loading_error_handle.dart';
//import '../pages/widgets.dart';
//import '../pages/wms_tile_layer.dart';

Widget _buildMenuItem(
    BuildContext context, Widget title, String routeName, String currentRoute) {
  var isSelected = routeName == currentRoute;

  return ListTile(
    title: title,
    selected: isSelected,
    onTap: () {
      if(routeName == null) return ;
      if (isSelected) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(context, routeName);
      }
    },
  );
}

Drawer buildDrawer(BuildContext context, String currentRoute) {
  return Drawer(
    child: ListView(
      children: <Widget>[
        const DrawerHeader(
          child: Center(
            child: Text('Flutter Map Examples'),
          ),
        ),
        _buildMenuItem(
          context,
          const Text('OpenStreetMap'),
//          HomePage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('NetworkTileProvider'),
//          NetworkTileProviderPage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('WMS Layer'),
//          WMSLayerPage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Custom CRS'),
//          CustomCrsPage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Add Pins'),
//          TapToAddPage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Esri'),
//          EsriPage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Polylines'),
//          PolylinePage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('MapController'),
//          MapControllerPage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Animated MapController'),
//          AnimatedMapControllerPage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Marker Anchors'),
//          MarkerAnchorPage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Marker Rotate'),
//          MarkerRotatePage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Plugins'),
//          PluginPage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('ScaleBar Plugins'),
//          PluginScaleBar.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('ZoomButtons Plugins'),
//          PluginZoomButtons.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Offline Map'),
//          OfflineMapPage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('OnTap'),
//          OnTapPage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Moving Markers'),
//          MovingMarkersPage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Circle'),
//          CirclePage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Overlay Image'),
//          OverlayImagePage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Sliding Map'),
//          SlidingMapPage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Widgets'),
//          WidgetsPage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Live Location Update'),
//          LiveLocationPage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Tile loading error handle'),
//          TileLoadingErrorHandle.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Tile builder'),
//          TileBuilderPage.route,
          null,
          currentRoute,
        ),
        _buildMenuItem(
          context,
          const Text('Interactive flags test page'),
//          InteractiveTestPage.route,
          null,
          currentRoute,
        ),
      ],
    ),
  );
}