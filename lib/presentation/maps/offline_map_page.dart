import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline_mapbox/domain/entities/comment.dart';
import 'package:flutter_offline_mapbox/domain/entities/point.dart' as point;
import 'package:flutter_offline_mapbox/presentation/maps/maps_cubit.dart';
import 'package:flutter_offline_mapbox/presentation/widgets/ink_wrapper.dart';
import 'package:flutter_offline_mapbox/utils/extended_bloc/extended_bloc_builder.dart';
import 'package:flutter_offline_mapbox/utils/extensions/context_extension.dart';
import 'package:flutter_offline_mapbox/utils/injector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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

    pointAnnotationManager?.addOnPointAnnotationClickListener(AnnotationClickListener(
      (PointAnnotation annotation) {
        if (Platform.isAndroid) {
          context.read<MapsCubit>().requestPointDetailsFromCoordinates(pointAnnotation: _tappedPoint!);
          _tappedPoint = null;
        }
      },
    ));
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
    await Future.delayed(const Duration(milliseconds: 220));
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedBlocBuilder<MapsCubit, MapsState, MapsCommand>(
      commandListener: (context, command) async {
        switch (command) {
          case MapsLoadSuccessCommand():
            context.showSuccessSnackBar('Successfully loaded');
          case MapsLoadErrorCommand():
            context.showErrorSnackBar('Error during loading');
          case MapsInitPointsCommand():
            await waitForManagerInitialization();
            for (final point in command.points) {
              await _addMarker(
                Point(coordinates: Position(point.coordinates.lng, point.coordinates.lat)),
                point.name,
              );
            }
          case MapsReinstallPointsCommand():
            await pointAnnotationManager?.deleteAll();
            for (final point in command.points) {
              await _addMarker(
                Point(coordinates: Position(point.coordinates.lng, point.coordinates.lat)),
                point.name,
              );
            }
          case MapsAddPointCommand():
            await _addMarker(
              Point(coordinates: Position(command.lng, command.lat)),
              command.name ?? '',
            );
          case MapsRemovePointCommand():
            pointAnnotationManager?.delete(command.pointAnnotation);
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
                if (_tappedPoint == null) {
                  await _addPointSheet(mapContext.point.coordinates);
                } else if (Platform.isIOS) {
                  context.read<MapsCubit>().requestPointDetailsFromCoordinates(pointAnnotation: _tappedPoint!);
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
          final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
          // NOTE: scroll is needed for keyboard
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 48 + keyboardPadding),
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
                ],
              ),
            ),
          );
        });
  }

  Future<void> _showPointDetailsSheet() async {
    final cubit = context.read<MapsCubit>();
    showBottomSheet(
        context: context,
        builder: (context) {
          return BlocBuilder<MapsCubit, MapsState>(
              bloc: cubit,
              buildWhen: (previous, current) => previous.openedDetailedPoint != current.openedDetailedPoint,
              builder: (context, state) {
                if (state.openedDetailedPoint == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final sortedComments = state.openedDetailedPoint!.comments
                  ?..sort((Comment a, Comment b) => b.updatedAt.compareTo(a.updatedAt));
                final point.Point detailedPoint = state.openedDetailedPoint!;
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _Content(
                      cubit: cubit,
                      state: state,
                      detailedPoint: detailedPoint,
                      sortedComments: sortedComments ?? [],
                    ),
                  ),
                );
              });
        });
  }

// TODO won't work correctly with dispose
// @override
// Future<void> dispose() async {
//   _tappedPoint = null;
//   await pointAnnotationManager?.deleteAll();
//   pointAnnotationManager = null;
//   return super.dispose();
// }
}

class _Content extends StatefulWidget {
  const _Content({required this.cubit, required this.detailedPoint, required this.sortedComments, required this.state});

  final MapsCubit cubit;
  final point.Point detailedPoint;
  final List<Comment>? sortedComments;
  final MapsState state;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  late final List<XFile> resources;
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    resources = <XFile>[];
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                          widget.detailedPoint.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context)
                            ..pop()
                            ..pop();
                          widget.cubit.deletePointByCoordinates(
                            lat: widget.detailedPoint.coordinates.lat.toDouble(),
                            lng: widget.detailedPoint.coordinates.lng.toDouble(),
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
        Text(widget.detailedPoint.name, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        Text('Author', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(widget.detailedPoint.user?.nickname ?? '', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        Text('Latitude', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(widget.detailedPoint.coordinates.lat.toString(), style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),
        Text('Longitude', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(widget.detailedPoint.coordinates.lng.toString(), style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 36),
        Text('Comments', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),
        Row(
          children: resources
              .map((e) => Image.file(
                    File(e.path),
                    width: 100,
                    height: 100,
                  ))
              .toList(),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 12),
            InkWrapper(
              borderRadius: BorderRadius.circular(40),
              onTap: () {
                try {
                  ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
                    if (value != null) {
                      resources.add(value);
                      setState(() {});
                    }
                  });
                } catch (e) {
                  debugPrint('ImagePicker $e');
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
                if (controller.text.trim().isEmpty) {
                  return;
                }
                widget.cubit.addComment(
                  controller.text,
                  resources: resources,
                  detailedPoint: widget.detailedPoint,
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
          // TODO
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.sortedComments?.length ?? 0,
          itemBuilder: (context, index) {
            final listTile = Column(
              children: [
                ListTile(
                  title: Text(widget.sortedComments![index].text, style: Theme.of(context).textTheme.bodyLarge),
                  subtitle: Text(
                    'Author: ${widget.sortedComments![index].user.nickname}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: Text(
                    DateFormat('h:mm a, dd.MM').format(widget.detailedPoint.comments![index].updatedAt),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                GridView(
                  // TODO
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  children: widget.sortedComments![index].resources
                      .map((e) => Image.file(
                            File('${widget.cubit.path}/${e.toString()}'),
                            width: 100,
                            height: 70,
                          ))
                      .toList(),
                ),
                if (index < widget.sortedComments!.length - 1) const Divider(height: 1),
              ],
            );
            if (widget.sortedComments![index].user.id == widget.state.currentUser.id) {
              return Column(
                children: [
                  PopupMenuButton<String>(
                    onSelected: (String result) {
                      if (result == 'Edit') {
                        final controller = TextEditingController(text: widget.sortedComments![index].text);
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Modify your content:',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(border: OutlineInputBorder()),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  if (controller.text.trim().isEmpty) {
                                    return;
                                  }
                                  Navigator.of(context).pop();
                                  widget.cubit.editComment(
                                    id: widget.sortedComments![index].id,
                                    text: controller.text,
                                  );
                                  controller.clear();
                                },
                                child: const Text("Submit"),
                              ),
                            ],
                          ),
                        );
                      } else if (result == 'Delete') {
                        widget.cubit.deleteComment(widget.sortedComments![index].id);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'Edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Delete',
                        child: Text('Delete'),
                      ),
                    ],
                    child: listTile,
                  ),
                ],
              );
            }
            return listTile;
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class AnnotationClickListener extends OnPointAnnotationClickListener {
  AnnotationClickListener(this._onPointAnnotationClick);

  final void Function(PointAnnotation annotation) _onPointAnnotationClick;

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    _tappedPoint = annotation;
    _onPointAnnotationClick(annotation);
  }
}
