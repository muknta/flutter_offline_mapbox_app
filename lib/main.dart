import 'package:flutter/material.dart';
import 'package:flutter_offline_mapbox/presentation/application.dart';
import 'package:flutter_offline_mapbox/utils/injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  runApp(const Application());
}
