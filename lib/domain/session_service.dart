import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_offline_mapbox/data/db/dao/users_dao.dart';
import 'package:flutter_offline_mapbox/data/key_value/shared_prefs_client.dart';
import 'package:flutter_offline_mapbox/domain/entities/user.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@lazySingleton
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
      );

  User? currentUser;

  @PostConstruct(preResolve: true)
  Future<void> init() async {
    try {
      final userId = _prefsClient.getLoggedInUserId();
      if (userId != null) {
        final userJson = await _usersDao.getUserById(userId);
        if (userJson == null) {
          _userController.add(null);
        } else {
          _userController.add(User.fromLocalJson(userJson));
        }
      } else {
        _userController.add(null);
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  void loginUser(User user) async {
    _prefsClient.setLoggedInUserId(user.id);
    _userController.add(user);
  }

  void logoutUser() async {
    _prefsClient.removeLoggedInUserId();
    _userController.add(null);
  }
}
