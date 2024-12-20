import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline_mapbox/domain/entities/point.dart' as point;
import 'package:flutter_offline_mapbox/presentation/maps/maps_cubit.dart';
import 'package:flutter_offline_mapbox/utils/extended_bloc/extended_bloc_builder.dart';
import 'package:flutter_offline_mapbox/utils/extensions/context_extension.dart';
import 'package:flutter_offline_mapbox/utils/injector.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

PointAnnotation? _tappedPoint;

class OfflineMapPage extends StatelessWidget {
  const OfflineMapPage({super.key, this.preselectedPoint});

  final point.Point? preselectedPoint;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MapsCubit>(
      create: (BuildContext context) => getIt<MapsCubit>()..init(preselectedPoint: preselectedPoint),
      child: ExtendedBlocBuilder<MapsCubit, MapsState, MapsCommand>(
        commandListener: (context, command) {
          switch (command) {
            case MapsLoadSuccessCommand():
              context.showSuccessSnackBar('Successfully loaded map');
            case MapsLoadErrorCommand():
              context.showErrorSnackBar('Error during map loading');
          }
        },
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Offline Map with Markers'),
          ),
          body: _OfflineMap(preselectedPoint: preselectedPoint, state: state),
        ),
      ),
    );
  }
}

class _OfflineMap extends StatefulWidget {
  const _OfflineMap({required this.preselectedPoint, required this.state});

  final point.Point? preselectedPoint;
  final MapsState state;

  @override
  State<_OfflineMap> createState() => _OfflineMapState();
}

class _OfflineMapState extends State<_OfflineMap> {
  late MapboxMap mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  TileStore? tileStore;
  OfflineManager? offlineManager;
  final String tileRegionId = "my-tile-region";

  @override
  void initState() {
    super.initState();
    _initializeOfflineManager();

    // Pass your access token to MapboxOptions so you can load a map
    String mapboxAccessToken = const String.fromEnvironment("MAPBOX_ACCESS_TOKEN");
    MapboxOptions.setAccessToken(mapboxAccessToken);
  }

  Future<void> _initializeOfflineManager() async {
    offlineManager = await OfflineManager.create();
    tileStore = await TileStore.createDefault();
    tileStore?.setDiskQuota(null); // Reset disk quota to default.
  }

  Future<void> _downloadOfflineMap() async {
    // Download the style pack (map style resources).
    final stylePackLoadOptions = StylePackLoadOptions(
      acceptExpired: true,
      glyphsRasterizationMode: GlyphsRasterizationMode.IDEOGRAPHS_RASTERIZED_LOCALLY,
      metadata: {"tag": "offline-style"},
    );

    const loadersCount = 2;
    double progressDone = 0.0;
    await offlineManager?.loadStylePack(
      MapboxStyles.MAPBOX_STREETS,
      stylePackLoadOptions,
      (progress) {
        context.read<MapsCubit>().updateProgress(
            progressDone + (progress.completedResourceCount / progress.requiredResourceCount) / loadersCount);
      },
    );
    progressDone += 1 / loadersCount;

    // Download the tile region (map tiles).
    final tileRegionLoadOptions = TileRegionLoadOptions(
      acceptExpired: true,
      networkRestriction: NetworkRestriction.NONE,
      geometry:
          Point(coordinates: Position(widget.state.regionForLoading.lng, widget.state.regionForLoading.lat)).toJson(),
      descriptorsOptions: [
        TilesetDescriptorOptions(
          styleURI: MapboxStyles.MAPBOX_STREETS,
          minZoom: 0,
          maxZoom: 16,
        ),
      ],
    );

    await tileStore?.loadTileRegion(
      tileRegionId,
      tileRegionLoadOptions,
      (progress) {
        context.read<MapsCubit>().updateProgress(
            progressDone + (progress.completedResourceCount / progress.requiredResourceCount) / loadersCount);
      },
    );
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    // Initialize point annotation manager.
    pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();
  }

  Future<void> _addMarker(Point point, String title) async {
    if (pointAnnotationManager == null) return;

    // Load custom marker image from assets.
    final ByteData bytes = await rootBundle.load('assets/marker.png'); // Replace with your asset.
    final Uint8List imageData = bytes.buffer.asUint8List();

    // Create and add a marker.
    final PointAnnotationOptions options = PointAnnotationOptions(
      geometry: point,
      image: imageData,
      iconAnchor: IconAnchor.BOTTOM,
      textField: title.length > 15 ? "${title.substring(0, 13)}..." : title,
      textOffset: [0.0, 0.8],
      iconSize: 0.3, // Adjust marker size as needed.
    );

    await pointAnnotationManager?.create(options);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: MapWidget(
            styleUri: MapboxStyles.MAPBOX_STREETS,
            cameraOptions: CameraOptions(
              center: widget.state.initialPosition != null
                  ? Point(coordinates: Position(widget.state.initialPosition!.lng, widget.state.initialPosition!.lat))
                  : null,
              zoom: 12.0,
            ),
            onTapListener: (MapContentGestureContext mapContext) async {
              // final PointAnnotationManager pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager(id: DateTime.now().toString());
              ///
              print("pointAnnotationManager: ${pointAnnotationManager?.id}");

              pointAnnotationManager?.addOnPointAnnotationClickListener(AnnotationClickListener());

              if (_tappedPoint == null && widget.preselectedPoint == null) {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      final TextEditingController controller = TextEditingController();
                      return Container(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text("Add marker"),
                              TextField(controller: controller),
                              ElevatedButton(
                                child: const Text("Add marker"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _addMarker(mapContext.point, controller.text);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              } else {
                final id = _tappedPoint?.id ?? widget.preselectedPoint!.id;
                final title = _tappedPoint?.textField ?? widget.preselectedPoint!.name;
                final lat = mapContext.point.coordinates.lat; // ?? widget.preselectedPoint!.lat;
                final lng = mapContext.point.coordinates.lng; // ?? widget.preselectedPoint!.lng;
                await showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text("Marker details"),
                              Text("id: $id"),
                              Text("title: $title"),
                              Text("Latitude: $lat"),
                              Text("Longitude: $lng"),
                              ElevatedButton(
                                child: const Text("Delete marker"),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text("Are you sure you want to delete this marker?"),
                                          Text("title: ${_tappedPoint!.textField}"),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context)
                                              ..pop()
                                              ..pop();
                                            pointAnnotationManager?.delete(_tappedPoint!);
                                          },
                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    });

                _tappedPoint = null;
              }
            },
            onMapCreated: _onMapCreated,
          ),
        ),
        if (widget.state.isStartedLoading)
          LinearProgressIndicator(
            minHeight: 20.0,
            value: widget.state.loadedPercentage,
          )
        else if (!widget.state.isLoaded)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _downloadOfflineMap,
              child: const Text('Download Offline Map'),
            ),
          ),
      ],
    );
  }
}

class AnnotationClickListener extends OnPointAnnotationClickListener {
  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    print("onAnnotationClick, id: ${annotation.id}");
    _tappedPoint = annotation;
  }
}
