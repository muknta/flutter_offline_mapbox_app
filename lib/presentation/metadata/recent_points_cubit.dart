import 'package:equatable/equatable.dart';
import 'package:flutter_offline_mapbox/domain/entities/point.dart';
import 'package:flutter_offline_mapbox/domain/entities/user.dart';
import 'package:flutter_offline_mapbox/domain/maps_metadata_service.dart';
import 'package:flutter_offline_mapbox/domain/session_service.dart';
import 'package:flutter_offline_mapbox/utils/extended_bloc/extended_bloc.dart';
import 'package:injectable/injectable.dart';

part 'recent_points_types.dart';

@injectable
class RecentPointsCubit extends ExtendedCubit<RecentPointsState, RecentPointsCommand> {
  RecentPointsCubit(this._mapsMetadataService, SessionService _sessionService)
      : super(RecentPointsState(currentUser: _sessionService.currentUser!, showOnlyMy: false, points: const [])) {
    init();
  }

  final MapsMetadataService _mapsMetadataService;

  Future<void> init() async {
    try {
      emit(RecentPointsState(
        currentUser: state.currentUser,
        points: (await _mapsMetadataService.getAllPoints())
          ..sort((Point a, Point b) => b.updatedAt.compareTo(a.updatedAt)),
        showOnlyMy: false,
      ));
    } catch (e) {
      command(const RecentPointsLoadErrorCommand());
    }
  }

  Future<void> toggleShowOnlyMyPoints() async {
    try {
      emit(RecentPointsState(
        currentUser: state.currentUser,
        points:
            (!state.showOnlyMy ? await _mapsMetadataService.getAllPoints() : await _mapsMetadataService.getMyPoints())
              ..sort((Point a, Point b) => b.updatedAt.compareTo(a.updatedAt)),
        showOnlyMy: !state.showOnlyMy,
      ));
    } catch (e) {
      command(const RecentPointsLoadErrorCommand());
    }
  }

  Future<void> deletePoint(Point point) async {
    try {
      await _mapsMetadataService.deletePoint(point);
      emit(RecentPointsState(
        currentUser: state.currentUser,
        points:
            !state.showOnlyMy ? await _mapsMetadataService.getAllPoints() : await _mapsMetadataService.getMyPoints(),
        showOnlyMy: !state.showOnlyMy,
      ));
    } catch (e) {
      command(const RecentPointsLoadErrorCommand());
    }
  }
}
