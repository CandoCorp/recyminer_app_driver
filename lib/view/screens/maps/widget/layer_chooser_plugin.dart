import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';

class LayerChooserPluginOptions extends LayerOptions {
  final bool mini;
  final double padding;
  final Alignment alignment;
  final FontWeight weight;
  final int fontSize;
  final Color layer1Color;
  final Color layer1ColorIcon;
  final Color layer2Color;
  final Color layer2ColorIcon;
  final IconData layer1Icon;
  final IconData layer2Icon;
  final Map layerState;
  final ValueNotifier mapState;

  LayerChooserPluginOptions({
    Key key,
    this.mini = true,
    this.padding = 2.0,
    this.alignment = Alignment.topLeft,
    this.weight = FontWeight.normal,
    this.fontSize = 18,
    this.layer1Color = Colors.green,
    this.layer1ColorIcon = Colors.white,
    this.layer2Color = Colors.green,
    this.layer2ColorIcon = Colors.white,
    this.layer1Icon = Icons.monetization_on_outlined,
    this.layer2Icon = Icons.construction_sharp,
    this.layerState,
    this.mapState,
    Stream<Null> rebuild,
  }) : super(key: key, rebuild: rebuild);
}

class LayerChooserPlugin implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (options is LayerChooserPluginOptions) {
      return LayerButtons(options, mapState, stream);
    }
    throw Exception('Unknown options type for LayerChooserPlugin: $options');
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is LayerChooserPluginOptions;
  }
}

class LayerButtons extends StatelessWidget {
  final LayerChooserPluginOptions layerButtonsOpts;
  final MapState map;
  final Stream<Null> stream;
  final FitBoundsOptions options =
  const FitBoundsOptions(padding: EdgeInsets.all(12.0));

  LayerButtons(this.layerButtonsOpts, this.map, this.stream)
      : super(key: layerButtonsOpts.key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: layerButtonsOpts.alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                left: layerButtonsOpts.padding,
                top: layerButtonsOpts.padding,
                right: layerButtonsOpts.padding),
            child: FloatingActionButton(
                mini: layerButtonsOpts.mini,
                backgroundColor: layerButtonsOpts.layerState[0] ?
                  layerButtonsOpts.layer1Color ?? IconTheme.of(context).color :
                  Colors.black12,
                onPressed: () {
                  layerButtonsOpts.layerState[0] = !layerButtonsOpts.layerState[0];
                  map.rebuildLayers();
                  layerButtonsOpts.mapState.notifyListeners();
                },
                child: Icon(layerButtonsOpts.layer1Icon,
                    color: layerButtonsOpts.layerState[0] ?
                    layerButtonsOpts.layer1ColorIcon ?? IconTheme.of(context).color :
                    Colors.black12
                )
            )
          ),
          Padding(
            padding: EdgeInsets.all(layerButtonsOpts.padding),
            child: FloatingActionButton(
                mini: layerButtonsOpts.mini,
                backgroundColor: layerButtonsOpts.layerState[1] ?
                  layerButtonsOpts.layer2Color ?? IconTheme.of(context).color :
                  Colors.black12,
                onPressed: () {
                  layerButtonsOpts.layerState[1] = !layerButtonsOpts.layerState[1];
                  map.rebuildLayers();
                  layerButtonsOpts.mapState.notifyListeners();
                },
                child: Icon(layerButtonsOpts.layer2Icon,
                    color: layerButtonsOpts.layerState[1] ?
                    layerButtonsOpts.layer2ColorIcon ?? IconTheme.of(context).color :
                    Colors.black12
                )
            )
          ),
        ],
      ),
    );
  }
}