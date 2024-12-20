import 'dart:convert';

import 'package:flutter_offline_mapbox/domain/entities/point.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class SharedPrefsClient {
  SharedPrefsClient(this._prefs);

  final SharedPreferences _prefs;

  static const _loggedInUserIdKey = 'loggedUserId';
  static const _loginExpirationKey = 'loginExpiration';
  static const _initialPositionKey = 'initialPosition_latLng';
  static const _isLoadedMapKey = 'isLoadedMap';

  Future<void> setLoggedInUserId(String userId) async {
    await _prefs.setString(_loggedInUserIdKey, userId);
  }

  Future<void> removeLoggedInUserId() async {
    await _prefs.remove(_loggedInUserIdKey);
  }

  String? getLoggedInUserId() {
    return _prefs.getString(_loggedInUserIdKey);
  }

  Future<void> setLoginExpirationMilliSinceEpoch(int millisecondsSinceEpoch) async {
    await _prefs.setInt(_loginExpirationKey, millisecondsSinceEpoch);
  }

  Future<void> removeLoginExpirationMilliSinceEpoch() async {
    await _prefs.remove(_loginExpirationKey);
  }

  int? getLoginExpirationMilliSinceEpoch() {
    return _prefs.getInt(_loginExpirationKey);
  }

  Future<void> setInitialPosition(Coordinates coordinates) async {
    await _prefs.setString(_initialPositionKey, jsonEncode(coordinates.toLocalJson()));
  }

  Future<void> removeInitialPosition() async {
    await _prefs.remove(_initialPositionKey);
  }

  Coordinates? getInitialPosition() {
    final encoded = _prefs.getString(_initialPositionKey);
    if (encoded == null) {
      return null;
    }
    return Coordinates.fromLocalJson(jsonDecode(encoded));
  }

  Future<void> setIsLoadedMap(bool loaded) async {
    await _prefs.setBool(_isLoadedMapKey, loaded);
  }

  bool getIsLoadedMap() {
    return _prefs.getBool(_isLoadedMapKey) == true;
  }
}
