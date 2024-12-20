part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState({required this.isLoading});

  final bool isLoading;

  @override
  List<Object?> get props => [isLoading];
}

class SignInState extends AuthState {
  const SignInState({required super.isLoading});
}

class SignUpState extends AuthState {
  const SignUpState({required super.isLoading});
}

sealed class AuthCommand extends Equatable {
  const AuthCommand();

  @override
  List<Object?> get props => [];
}

class SignInNotFoundCommand extends AuthCommand {
  const SignInNotFoundCommand();
}

class SignUpExistsCommand extends AuthCommand {
  const SignUpExistsCommand();
}

class SignUpValidationErrorCommand extends AuthCommand {
  const SignUpValidationErrorCommand();
}
