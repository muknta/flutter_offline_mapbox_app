import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_offline_mapbox/domain/entities/user.dart';
import 'package:flutter_offline_mapbox/domain/session_service.dart';
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
