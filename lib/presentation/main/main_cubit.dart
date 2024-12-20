import 'package:equatable/equatable.dart';
import 'package:flutter_offline_mapbox/domain/account_service.dart';
import 'package:flutter_offline_mapbox/domain/auth_service.dart';
import 'package:flutter_offline_mapbox/domain/entities/user.dart';
import 'package:flutter_offline_mapbox/domain/session_service.dart';
import 'package:flutter_offline_mapbox/utils/extended_bloc/extended_bloc.dart';
import 'package:injectable/injectable.dart';

part 'main_types.dart';

@injectable
class MainCubit extends ExtendedCubit<MainState, MainCommand> {
  MainCubit(this._authService, this._accountService, SessionService _sessionService)
      : super(MainState(_sessionService.currentUser));

  final AuthService _authService;
  final AccountService _accountService;

  Future<void> signOut() async {
    try {
      await _authService.logOut();
      command(const MainSignOutSuccessCommand());
    } catch (e) {
      command(const MainSignOutErrorCommand());
    }
  }

  Future<void> deleteUser() async {
    try {
      await _accountService.deleteUser(id: state.user!.id);
      command(const MainDeleteUserSuccessCommand());
    } catch (e) {
      command(const MainDeleteUserErrorCommand());
    }
  }
}
