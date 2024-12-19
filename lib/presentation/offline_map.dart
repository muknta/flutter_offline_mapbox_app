import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

PointAnnotation? tappedPoint;

class OfflineMap extends StatefulWidget {
  const OfflineMap({super.key});

  @override
  State<OfflineMap> createState() => _OfflineMapState();
}

class _OfflineMapState extends State<OfflineMap> {
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

    await offlineManager?.loadStylePack(
      MapboxStyles.MAPBOX_STREETS,
      stylePackLoadOptions,
      (progress) {
        //todo: progress
      },
    );

    // Download the tile region (map tiles).
    final tileRegionLoadOptions = TileRegionLoadOptions(
      acceptExpired: true,
      networkRestriction: NetworkRestriction.NONE,
      geometry: Point(coordinates: Position(-74.00913, 40.75183)).toJson(), // Example coordinates.
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
        //todo: progress
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
      textField: title.length > 15 ? title.substring(0, 13) + "..." : title,
      textOffset: [0.0, 0.8],
      iconSize: 0.3, // Adjust marker size as needed.
    );

    await pointAnnotationManager?.create(options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Map with Markers'),
      ),
      body: Column(
        children: [
          Expanded(
            child: MapWidget(
              key: ValueKey("offlineMap"),
              styleUri: MapboxStyles.MAPBOX_STREETS,
              cameraOptions: CameraOptions(
                center: Point(coordinates: Position(-74.00913, 40.75183)),
                zoom: 12.0,
              ),
              onTapListener: (MapContentGestureContext mapContext) async {
                // final PointAnnotationManager pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager(id: DateTime.now().toString());
                ///
                print("pointAnnotationManager: ${pointAnnotationManager?.id}");

                pointAnnotationManager?.addOnPointAnnotationClickListener(AnnotationClickListener());

                if (tappedPoint == null) {
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
                                Text("Add marker"),
                                TextField(controller: controller),
                                ElevatedButton(
                                  child: Text("Add marker"),
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
                                Text("Marker details"),
                                Text("id: ${tappedPoint!.id}"),
                                Text("title: ${tappedPoint!.textField}"),
                                Text("Latitude: ${mapContext.point.coordinates.lat}"),
                                Text("Longitude: ${mapContext.point.coordinates.lng}"),
                                ElevatedButton(
                                  child: Text("Delete marker"),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("Are you sure you want to delete this marker?"),
                                            Text("title: ${tappedPoint!.textField}"),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Cancel")),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.of(context)
                                                ..pop()
                                                ..pop();
                                              pointAnnotationManager?.delete(tappedPoint!);
                                            },
                                            child: Text("Delete"),
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

                  tappedPoint = null;
                }
              },
              onMapCreated: _onMapCreated,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _downloadOfflineMap,
              child: Text('Download Offline Map'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pointAnnotationManager?.deleteAll();
    tileStore?.removeRegion(tileRegionId);
    offlineManager?.removeStylePack(MapboxStyles.MAPBOX_STREETS);
    super.dispose();
  }
}

class AnnotationClickListener extends OnPointAnnotationClickListener {
  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    print("onAnnotationClick, id: ${annotation.id}");
    tappedPoint = annotation;
  }
}
