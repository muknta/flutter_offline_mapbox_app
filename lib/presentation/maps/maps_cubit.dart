import 'package:equatable/equatable.dart';
import 'package:flutter_offline_mapbox/data/key_value/shared_prefs_client.dart';
import 'package:flutter_offline_mapbox/domain/entities/point.dart';
import 'package:flutter_offline_mapbox/domain/entities/user.dart';
import 'package:flutter_offline_mapbox/domain/maps_metadata_service.dart';
import 'package:flutter_offline_mapbox/domain/session_service.dart';
import 'package:flutter_offline_mapbox/utils/extended_bloc/extended_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as maps;
import 'package:path_provider/path_provider.dart';

part 'maps_types.dart';

@injectable
class MapsCubit extends ExtendedCubit<MapsState, MapsCommand> {
  MapsCubit(this._mapsMetadataService, SessionService _sessionService, this._prefsClient)
      : super(MapsState(
          currentUser: _sessionService.currentUser!,
          regionForLoading: const Coordinates(lat: 50.4504, lng: 30.5245),
        ));

  final MapsMetadataService _mapsMetadataService;
  final SharedPrefsClient _prefsClient;

  late String _path;
  String get path => _path;

  Future<void> init({Point? preselectedPoint}) async {
    try {
      _path = (await getApplicationDocumentsDirectory()).path;
      emit(MapsState(
        currentUser: state.currentUser,
        regionForLoading: state.regionForLoading,
        initialPosition: preselectedPoint?.coordinates ?? _prefsClient.getInitialPosition() ?? state.regionForLoading,
        loadedPercentage: _prefsClient.getIsLoadedMap() ? 1 : 0,
      ));
      command(MapsInitPointsCommand(await _mapsMetadataService.getAllPoints()));
      if (preselectedPoint != null) {
        await requestPointDetails(preselectedPoint);
      }
    } catch (e) {
      command(const MapsLoadErrorCommand());
    }
  }

  void updateProgress(double progress) {
    emit(MapsState(
      currentUser: state.currentUser,
      regionForLoading: state.regionForLoading,
      initialPosition: state.initialPosition,
      loadedPercentage: progress,
    ));
    if (progress >= 1 || progress == 0) {
      _prefsClient.setIsLoadedMap(progress >= 1);
    }
  }

  Future<void> addPoint({required double lat, required double lng, required String? name}) async {
    try {
      await _mapsMetadataService.insertPoint(lat: lat, lng: lng, name: name);
      command(MapsAddPointCommand(lat: lat, lng: lng, name: name));
    } catch (e) {
      command(const MapsLoadErrorCommand());
    }
  }

  Future<void> deletePointByCoordinates({required double lat, required double lng}) async {
    try {
      await _mapsMetadataService.deletePointByCoordinates(lat: lat, lng: lng);
      // NOTE: we cannot remove in that case only one pointAnnotation, so we need to reinstall all of them
      command(MapsReinstallPointsCommand(await _mapsMetadataService.getAllPoints()));
    } catch (e) {
      command(const MapsLoadErrorCommand());
    }
  }

  Future<void> deletePoint({required maps.PointAnnotation pointAnnotation}) async {
    try {
      await _mapsMetadataService.deletePointByCoordinates(
        lat: pointAnnotation.geometry.coordinates.lat.toDouble(),
        lng: pointAnnotation.geometry.coordinates.lng.toDouble(),
      );
      command(MapsRemovePointCommand(pointAnnotation: pointAnnotation));
    } catch (e) {
      command(const MapsLoadErrorCommand());
    }
  }

  Future<void> requestPointDetailsFromCoordinates({required maps.PointAnnotation pointAnnotation}) async {
    try {
      final point = await _mapsMetadataService.getDetailedPointByCoordinates(
        lat: pointAnnotation.geometry.coordinates.lat.toDouble(),
        lng: pointAnnotation.geometry.coordinates.lng.toDouble(),
      );
      if (point != null) {
        emit(MapsState(
          currentUser: state.currentUser,
          regionForLoading: state.regionForLoading,
          initialPosition: state.initialPosition,
          loadedPercentage: state.loadedPercentage,
          openedDetailedPoint: point,
        ));
        command(MapsShowPointDetailsCommand(pointAnnotation: pointAnnotation));
      }
    } catch (e) {
      command(const MapsLoadErrorCommand());
    }
  }

  Future<void> requestPointDetails(Point point) async {
    try {
      final result = await _mapsMetadataService.getDetailedPoint(point);
      emit(MapsState(
        currentUser: state.currentUser,
        regionForLoading: state.regionForLoading,
        initialPosition: state.initialPosition,
        loadedPercentage: state.loadedPercentage,
        openedDetailedPoint: result,
      ));
      command(const MapsShowPointDetailsCommand());
    } catch (e) {
      command(const MapsLoadErrorCommand());
    }
  }

  Future<void> addComment(String text, {required List<XFile> resources, required Point detailedPoint}) async {
    try {
      await _mapsMetadataService.insertComment(
        text: text,
        resources: resources,
        userId: detailedPoint.user!.id,
        pointId: detailedPoint.id,
      );
      emit(MapsState(
        currentUser: state.currentUser,
        regionForLoading: state.regionForLoading,
        initialPosition: state.initialPosition,
        loadedPercentage: state.loadedPercentage,
        openedDetailedPoint: await _mapsMetadataService.getDetailedPoint(detailedPoint, forceUpdate: true),
      ));
    } catch (e) {
      command(const MapsLoadErrorCommand());
    }
  }

  Future<void> deleteComment(String id) async {
    try {
      await _mapsMetadataService.deleteComment(id);
      emit(MapsState(
        currentUser: state.currentUser,
        regionForLoading: state.regionForLoading,
        initialPosition: state.initialPosition,
        loadedPercentage: state.loadedPercentage,
        openedDetailedPoint: await _mapsMetadataService.getDetailedPoint(state.openedDetailedPoint!, forceUpdate: true),
      ));
    } catch (e) {
      command(const MapsLoadErrorCommand());
    }
  }

  Future<void> editComment({required String id, required String text}) async {
    try {
      await _mapsMetadataService.editComment(id: id, text: text);
      emit(MapsState(
        currentUser: state.currentUser,
        regionForLoading: state.regionForLoading,
        initialPosition: state.initialPosition,
        loadedPercentage: state.loadedPercentage,
        openedDetailedPoint: await _mapsMetadataService.getDetailedPoint(state.openedDetailedPoint!, forceUpdate: true),
      ));
    } catch (e) {
      command(const MapsLoadErrorCommand());
    }
  }
}
