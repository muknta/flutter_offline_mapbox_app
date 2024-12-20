import 'package:equatable/equatable.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_offline_mapbox/domain/auth_service.dart';
import 'package:flutter_offline_mapbox/utils/extended_bloc/extended_bloc.dart';
import 'package:injectable/injectable.dart';

part 'auth_types.dart';

@injectable
class AuthCubit extends ExtendedCubit<AuthState, AuthCommand> {
  AuthCubit(this._service) : super(const SignInState(isLoading: false));

  final AuthService _service;

  Future<void> signIn({
    required String nickname,
    required String password,
  }) async {
    if (state is! SignInState) {
      return;
    }
    try {
      emit(const SignInState(isLoading: true));
      await _service.signIn(nickname: nickname, password: password);
      // NOTE: no need to navigate, it will be done in listener
    } catch (e) {
      emit(const SignInState(isLoading: false));
      command(const SignInNotFoundCommand());
    }
  }

  Future<void> signUp({
    required String nickname,
    required String password,
  }) async {
    if (state is! SignUpState) {
      return;
    }
    if (nickname.length < 4 && password.length < 4) {
      command(const SignUpValidationErrorCommand());
      return;
    }
    try {
      emit(const SignUpState(isLoading: true));
      await _service.signUp(nickname: nickname, password: password);
      // NOTE: no need to navigate, it will be done in listener
    } catch (e) {
      emit(const SignUpState(isLoading: false));
      command(const SignUpExistsCommand());
    }
  }

  void switchToSignUp() => emit(const SignUpState(isLoading: false));

  void switchToSignIn() => emit(const SignInState(isLoading: false));
}
