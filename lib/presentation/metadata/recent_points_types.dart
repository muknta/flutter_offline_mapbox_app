part of 'recent_points_cubit.dart';

class RecentPointsState extends Equatable {
  const RecentPointsState({required this.currentUser, required this.showOnlyMy, required this.points});

  final User currentUser;
  final bool showOnlyMy;
  final List<Point> points;

  @override
  List<Object?> get props => [currentUser, showOnlyMy, points];
}

sealed class RecentPointsCommand extends Equatable {
  const RecentPointsCommand();

  @override
  List<Object?> get props => [];
}

class RecentPointsLoadErrorCommand extends RecentPointsCommand {
  const RecentPointsLoadErrorCommand();
}
