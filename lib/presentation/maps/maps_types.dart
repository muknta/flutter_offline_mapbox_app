part of 'maps_cubit.dart';

class MapsState extends Equatable {
  const MapsState({
    required this.currentUser,
    required this.regionForLoading,
    this.initialPosition,
    this.loadedPercentage,
    this.openedDetailedPoint,
  });

  final User currentUser;
  final Coordinates? initialPosition;
  final Coordinates regionForLoading;
  final double? loadedPercentage;
  final Point? openedDetailedPoint;

  bool get isLoaded => (loadedPercentage ?? 0) >= 1;
  bool get isStartedLoading => (loadedPercentage ?? 0) > 0 && (loadedPercentage ?? 0) < 1;

  @override
  List<Object?> get props => [currentUser, initialPosition, regionForLoading, loadedPercentage, openedDetailedPoint];
}

sealed class MapsCommand extends Equatable {
  const MapsCommand();

  @override
  List<Object?> get props => [];
}

class MapsLoadSuccessCommand extends MapsCommand {
  const MapsLoadSuccessCommand();
}

class MapsLoadErrorCommand extends MapsCommand {
  const MapsLoadErrorCommand();
}

class MapsInitPointsCommand extends MapsCommand {
  const MapsInitPointsCommand(this.points);

  final List<Point> points;
}

class MapsAddPointCommand extends MapsCommand {
  const MapsAddPointCommand({required this.lat, required this.lng, required this.name});

  final double lat;
  final double lng;
  final String? name;
}

class MapsRemovePointCommand extends MapsCommand {
  const MapsRemovePointCommand({required this.lat, required this.lng});

  final double lat;
  final double lng;
}

class MapsShowPointDetailsCommand extends MapsCommand {
  const MapsShowPointDetailsCommand();
}
