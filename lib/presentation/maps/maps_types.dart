part of 'maps_cubit.dart';

class MapsState extends Equatable {
  const MapsState({
    required this.currentUser,
    required this.regionForLoading,
    this.initialPosition,
    this.points,
    this.loadedPercentage,
  });

  final User currentUser;
  final Coordinates? initialPosition;
  final Coordinates regionForLoading;
  final List<Point>? points;
  final double? loadedPercentage;

  bool get isLoaded => (loadedPercentage ?? 0) >= 1;
  bool get isStartedLoading => (loadedPercentage ?? 0) > 0 && (loadedPercentage ?? 0) < 1;

  @override
  List<Object?> get props => [currentUser, initialPosition, points, loadedPercentage];
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
