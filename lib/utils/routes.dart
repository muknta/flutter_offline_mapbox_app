import 'package:flutter/material.dart';
import 'package:flutter_offline_mapbox/domain/entities/point.dart';
import 'package:flutter_offline_mapbox/presentation/application.dart';
import 'package:flutter_offline_mapbox/presentation/auth/auth_page.dart';
import 'package:flutter_offline_mapbox/presentation/main/main_page.dart';
import 'package:flutter_offline_mapbox/presentation/maps/offline_map_page.dart';
import 'package:flutter_offline_mapbox/presentation/metadata/recent_points_page.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static const String globalScope = '/';
  static const String main = '/main';
  static const String auth = '/auth';
  static const String offlineMaps = '/offline_maps';
  static const String recentPoints = '/recent_points';
  static const String pointIdVar = 'pointId';
  static const String offlineMapsPointName = 'maps_point';
}

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const GlobalScope();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'main',
          builder: (BuildContext context, GoRouterState state) {
            return const MainPage();
          },
        ),
        GoRoute(
          path: 'auth',
          builder: (BuildContext context, GoRouterState state) {
            return const AuthPage();
          },
        ),
        GoRoute(
            path: 'recent_points',
            builder: (BuildContext context, GoRouterState state) {
              return const RecentPointsPage();
            },
            routes: [
              GoRoute(
                name: 'maps_point',
                path: 'offline_maps/point/:pointId',
                builder: (BuildContext context, GoRouterState state) {
                  return OfflineMapPage(preselectedPoint: state.extra as Point);
                },
              ),
            ]),
        GoRoute(
          path: 'offline_maps',
          builder: (BuildContext context, GoRouterState state) {
            return const OfflineMapPage();
          },
        ),
      ],
    ),
  ],
);
