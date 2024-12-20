import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_offline_mapbox/data/db/dao/users_dao.dart';
import 'package:flutter_offline_mapbox/data/key_value/shared_prefs_client.dart';
import 'package:flutter_offline_mapbox/domain/entities/user.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@singleton
class SessionService {
  SessionService(this._usersDao, this._prefsClient);

  final UsersDao _usersDao;
  final SharedPrefsClient _prefsClient;

  final StreamController<User?> _userController = BehaviorSubject<User?>();
  Stream<User?> get currentUserStream => _userController.stream.transform(
        StreamTransformer<User?, User?>.fromHandlers(
          handleData: (value, sink) async {
            currentUser = value;
            sink.add(value);
          },
        ),
      ).distinct();

  User? currentUser;

  @PostConstruct(preResolve: true)
  Future<void> init() async {
    try {
      final userId = _prefsClient.getLoggedInUserId();
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(_prefsClient.getLoginExpirationMilliSinceEpoch() ?? 0);
      if (userId != null && expirationDate.isAfter(DateTime.now())) {
        final userJson = await _usersDao.getUserById(userId);
        if (userJson == null) {
          logoutUser();
        } else {
          _userController.add(User.fromLocalJson(userJson));
        }
      } else {
        logoutUser();
      }
    } catch (e) {
      debugPrint(e.toString());
      logoutUser();
      rethrow;
    }
  }

  void loginUser(User user) async {
    _prefsClient.setLoggedInUserId(user.id);
    // TODO: get expiration interval from remote config
    _prefsClient.setLoginExpirationMilliSinceEpoch(
        DateTime.now().millisecondsSinceEpoch + const Duration(hours: 2).inMilliseconds);
    _userController.add(user);
  }

  void logoutUser() async {
    _prefsClient.removeLoggedInUserId();
    _prefsClient.removeLoginExpirationMilliSinceEpoch();
    _userController.add(null);
  }
}
