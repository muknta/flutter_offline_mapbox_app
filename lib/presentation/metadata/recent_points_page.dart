import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline_mapbox/presentation/metadata/recent_points_cubit.dart';
import 'package:flutter_offline_mapbox/presentation/widgets/ink_wrapper.dart';
import 'package:flutter_offline_mapbox/utils/extended_bloc/extended_bloc_builder.dart';
import 'package:flutter_offline_mapbox/utils/injector.dart';
import 'package:flutter_offline_mapbox/utils/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:super_context_menu/super_context_menu.dart';

class RecentPointsPage extends StatelessWidget {
  const RecentPointsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecentPointsCubit>(
      create: (context) => getIt<RecentPointsCubit>(),
      child: ExtendedBlocBuilder<RecentPointsCubit, RecentPointsState, RecentPointsCommand>(
        commandListener: (context, command) {},
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Recent points'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ToggleButtons(
                  onPressed: (_) => context.read<RecentPointsCubit>().toggleShowOnlyMyPoints(),
                  isSelected: [!state.showOnlyMy, state.showOnlyMy],
                  children: const [
                    Text('All'),
                    Text('Mine'),
                  ],
                ),
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: state.points.length,
            itemBuilder: (context, index) {
              final point = state.points[index];
              return InkWrapper(
                onTap: () => context.pushNamed(
                  Routes.offlineMapsPointName,
                  pathParameters: {Routes.pointIdVar: point.id},
                  extra: point,
                ),
                child: Card(
                  child: ListTile(
                    title: Text(point.name, style: Theme.of(context).textTheme.headlineSmall),
                    subtitle: Text('By ${point.user?.nickname} at ${point.updatedAt}', style: Theme.of(context).textTheme.bodySmall),

                    trailing: point.user?.id == state.currentUser.id
                        ? ContextMenuWidget(
                            child: Icon(
                              Icons.more_horiz_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            menuProvider: (_) => Menu(
                              children: [
                                MenuAction(
                                  callback: () => context.read<RecentPointsCubit>().deletePoint(point),
                                  title: 'Delete',
                                ),
                              ],
                            ),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
