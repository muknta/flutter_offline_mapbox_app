import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_offline_mapbox/domain/entities/point.dart';
import 'package:flutter_offline_mapbox/domain/entities/user.dart';
import 'package:flutter_offline_mapbox/domain/session_service.dart';
import 'package:flutter_offline_mapbox/presentation/auth/auth_page.dart';
import 'package:flutter_offline_mapbox/presentation/main/main_page.dart';
import 'package:flutter_offline_mapbox/presentation/maps/offline_map_page.dart';
import 'package:flutter_offline_mapbox/presentation/metadata/recent_points_page.dart';
import 'package:flutter_offline_mapbox/utils/extensions/context_extension.dart';
import 'package:flutter_offline_mapbox/utils/injector.dart';
import 'package:flutter_offline_mapbox/utils/routes.dart';
import 'package:go_router/go_router.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Offline Mapbox',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: appRouter,
      // routes: {
      //   '/': (context) => const GlobalScope(),
      //   '/main': (context) => Ma(),
      // },
      // onGenerateRoute: (settings) {
      //   final Widget page;
      //   if (settings.name == Routes.globalScope) {
      //     page = const Center(child: CircularProgressIndicator());
      //   } else if (settings.name == Routes.main) {
      //     page = const MainPage();
      //   } else if (settings.name == Routes.auth) {
      //     page = const AuthPage();
      //   } else if (settings.name == Routes.recentPoints) {
      //     page = const RecentPointsPage();
      //   } else if (settings.name == Routes.offlineMaps) {
      //     page = const OfflineMapPage();
      //   } else if (settings.name == Routes.offlineMapsPoint) {
      //     final point = (settings.arguments as Map<String, dynamic>?)?['point'] as Point?;
      //     page = OfflineMapPage(preselectedPoint: point);
      //   } else {
      //     throw Exception('Unknown route: ${settings.name}');
      //   }
      //
      //   return MaterialPageRoute<dynamic>(
      //     builder: (context) {
      //       return page;
      //     },
      //     settings: settings,
      //   );
      // },
      // builder: (context, child) => GlobalScope(child: child),
    );
  }
}

class GlobalScope extends StatefulWidget {
  const GlobalScope({super.key, this.child});

  final Widget? child;

  @override
  State<GlobalScope> createState() => _GlobalScopeState();
}

class _GlobalScopeState extends State<GlobalScope> {
  StreamSubscription<User?>? _onSessionSub;

  @override
  void initState() {
    super.initState();
    _onSessionSub = getIt<SessionService>().currentUserStream.listen(_onSession);
  }

  void _onSession(User? user) {
    if (user == null) {
      // TODO
      context.replace(Routes.auth);
    } else {
      context.replace(Routes.main);
    }
  }

  @override
  void dispose() {
    _onSessionSub?.cancel();
    _onSessionSub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
