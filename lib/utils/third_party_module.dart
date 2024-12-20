import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// For generating third-party dependencies only
@module
abstract class ThirdPartyModule {
  @preResolve
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();
}
