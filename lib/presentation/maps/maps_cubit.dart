import 'package:equatable/equatable.dart';
import 'package:flutter_offline_mapbox/data/key_value/shared_prefs_client.dart';
import 'package:flutter_offline_mapbox/domain/entities/point.dart';
import 'package:flutter_offline_mapbox/domain/entities/user.dart';
import 'package:flutter_offline_mapbox/domain/maps_metadata_service.dart';
import 'package:flutter_offline_mapbox/domain/session_service.dart';
import 'package:flutter_offline_mapbox/utils/extended_bloc/extended_bloc.dart';
import 'package:injectable/injectable.dart';

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

  Future<void> init({Point? preselectedPoint}) async {
    try {
      emit(MapsState(
        currentUser: state.currentUser,
        regionForLoading: state.regionForLoading,
        initialPosition: preselectedPoint?.coordinates ?? _prefsClient.getInitialPosition() ?? state.regionForLoading,
        points: await _mapsMetadataService.getAllPoints(),
        loadedPercentage: _prefsClient.getIsLoadedMap() ? 1 : 0,
      ));
    } catch (e) {
      command(const MapsLoadErrorCommand());
    }
  }

  // TODO
  void updateProgress(double progress) {
    emit(MapsState(
      currentUser: state.currentUser,
      regionForLoading: state.regionForLoading,
      initialPosition: state.initialPosition,
      points: state.points,
      loadedPercentage: progress,
    ));
    if (progress > 1 || progress == 0) {
      _prefsClient.setIsLoadedMap(progress > 1);
    }
  }
}
