import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline_mapbox/domain/entities/point.dart' as point;
import 'package:flutter_offline_mapbox/presentation/maps/maps_cubit.dart';
import 'package:flutter_offline_mapbox/presentation/widgets/ink_wrapper.dart';
import 'package:flutter_offline_mapbox/utils/extended_bloc/extended_bloc_builder.dart';
import 'package:flutter_offline_mapbox/utils/extensions/context_extension.dart';
import 'package:flutter_offline_mapbox/utils/injector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide ImageSource;

PointAnnotation? _tappedPoint;

class OfflineMapPage extends StatelessWidget {
  const OfflineMapPage({super.key, this.preselectedPoint});

  final point.Point? preselectedPoint;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MapsCubit>(
      create: (BuildContext context) => getIt<MapsCubit>()..init(preselectedPoint: preselectedPoint),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Offline Map with Markers'),
        ),
        body: const _OfflineMap(),
      ),
    );
  }
}

class _OfflineMap extends StatefulWidget {
  const _OfflineMap();

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

  Future<void> _downloadOfflineMap(point.Coordinates regionForLoading) async {
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
      geometry: Point(coordinates: Position(regionForLoading.lng, regionForLoading.lat)).toJson(),
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

  // TODO: think about more elegant way
  Future<void> waitForManagerInitialization() async {
    await Future.delayed(const Duration(milliseconds: 120));
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedBlocBuilder<MapsCubit, MapsState, MapsCommand>(
      commandListener: (context, command) async {
        switch (command) {
          case MapsLoadSuccessCommand():
            context.showSuccessSnackBar('Successfully loaded map');
          case MapsLoadErrorCommand():
            context.showErrorSnackBar('Error during map loading');
          case MapsInitPointsCommand():
            await waitForManagerInitialization();
            for (final point in command.points) {
              await _addMarker(
                Point(coordinates: Position(point.coordinates.lng, point.coordinates.lat)),
                point.name ?? '',
              );
            }
          case MapsAddPointCommand():
            await _addMarker(
              Point(coordinates: Position(command.lng, command.lat)),
              command.name ?? '',
            );
          case MapsRemovePointCommand():
            if (_tappedPoint != null) {
              pointAnnotationManager?.delete(_tappedPoint!);
              _tappedPoint = null;
            }
          case MapsShowPointDetailsCommand():
            await _showPointDetailsSheet();
        }
      },
      builder: (context, state) => Column(
        children: [
          Expanded(
            child: MapWidget(
              styleUri: MapboxStyles.MAPBOX_STREETS,
              cameraOptions: CameraOptions(
                center: state.initialPosition != null
                    ? Point(coordinates: Position(state.initialPosition!.lng, state.initialPosition!.lat))
                    : null,
                zoom: 12.0,
              ),
              onTapListener: (MapContentGestureContext mapContext) async {
                pointAnnotationManager?.addOnPointAnnotationClickListener(AnnotationClickListener());

                if (_tappedPoint == null) {
                  await _addPointSheet(mapContext.point.coordinates);
                } else {
                  context.read<MapsCubit>().requestPointDetailsFromCoordinates(
                        lat: _tappedPoint!.geometry.coordinates.lat.toDouble(),
                        lng: _tappedPoint!.geometry.coordinates.lng.toDouble(),
                      );
                  _tappedPoint = null;
                }
              },
              onMapCreated: _onMapCreated,
            ),
          ),
          if (state.isStartedLoading)
            LinearProgressIndicator(
              minHeight: 20.0,
              value: state.loadedPercentage,
            )
          else if (!state.isLoaded)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => _downloadOfflineMap(state.regionForLoading),
                child: const Text('Download Offline Map'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addPointSheet(Position coordinates) async {
    final cubit = context.read<MapsCubit>();
    final TextEditingController controller = TextEditingController();
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Enter a title', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                TextField(controller: controller),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      cubit.addPoint(
                        lat: coordinates.lat.toDouble(),
                        lng: coordinates.lng.toDouble(),
                        name: controller.text,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      child: Text("Add point", style: Theme.of(context).textTheme.headlineSmall),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        });
  }

  Future<void> _showPointDetailsSheet() async {
    final cubit = context.read<MapsCubit>();
    showBottomSheet(
        context: context,
        builder: (context) {
          final resources = <XFile>[];
          final TextEditingController controller = TextEditingController();
          return BlocBuilder<MapsCubit, MapsState>(
              bloc: cubit,
              buildWhen: (previous, current) => previous.openedDetailedPoint != current.openedDetailedPoint,
              builder: (context, state) {
                if (state.openedDetailedPoint == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final point.Point detailedPoint = state.openedDetailedPoint!;
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Text('Point details', style: Theme.of(context).textTheme.headlineMedium),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Are you sure you want to delete this marker?",
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                        Text(
                                          detailedPoint.name,
                                          style: Theme.of(context).textTheme.headlineSmall,
                                        ),
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
                                          cubit.deletePoint(
                                            lat: detailedPoint.coordinates.lat.toDouble(),
                                            lng: detailedPoint.coordinates.lng.toDouble(),
                                          );
                                        },
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text('Title', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        Text(detailedPoint.name, style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 12),
                        Text('Author', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        Text(detailedPoint.user?.nickname ?? '', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 12),
                        Text('Latitude', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        Text(detailedPoint.coordinates.lat.toString(), style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        Text('Longitude', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        Text(detailedPoint.coordinates.lng.toString(), style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 36),
                        Text('Comments', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          children: resources.map((e) => Image.file(File(e.path))).toList(),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(border: OutlineInputBorder())),
                            ),
                            const SizedBox(width: 12),
                            InkWrapper(
                              borderRadius: BorderRadius.circular(40),
                              onTap: () {
                                try {
                                  ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
                                    if (value != null) {
                                      resources.add(value);
                                    }
                                  });
                                } catch (e) {
                                  debugPrint('eee $e');
                                }
                              },
                              padding: const EdgeInsets.all(8.0),
                              child: const Icon(
                                Icons.add,
                                color: Colors.black54,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWrapper(
                              borderRadius: BorderRadius.circular(40),
                              onTap: () {
                                cubit.addComment(
                                  controller.text,
                                  resources: resources,
                                  detailedPoint: detailedPoint,
                                );
                                controller.clear();
                                resources.clear();
                              },
                              padding: const EdgeInsets.all(8.0),
                              child: const Icon(
                                Icons.send,
                                color: Colors.black54,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: detailedPoint.comments?.length ?? 0,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(detailedPoint.comments![index].text),
                              subtitle: Text('Author: ${detailedPoint.user?.nickname}'),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              });
        });
  }

  // @override
  // Future<void> dispose() async {
  //   _tappedPoint = null;
  //   await pointAnnotationManager?.deleteAll();
  //   pointAnnotationManager = null;
  //   return super.dispose();
  // }
}

class AnnotationClickListener extends OnPointAnnotationClickListener {
  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    _tappedPoint = annotation;
  }
}
