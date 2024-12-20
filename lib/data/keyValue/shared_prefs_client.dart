import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@injectable
class SharedPrefsClient {
  SharedPrefsClient(this._prefs);

  final SharedPreferences _prefs;

  // TODO: expiration
  Future<void> setLoggedInUserId(String userId) async {
    await _prefs.setString('loggedUserId', userId);
  }

  Future<void> removeLoggedInUserId() async {
    await _prefs.remove('loggedUserId');
  }

  String? getLoggedInUserId() {
    return _prefs.getString('loggedUserId');
  }
}
