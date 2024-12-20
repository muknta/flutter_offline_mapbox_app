part of 'main_cubit.dart';

class MainState extends Equatable {
  const MainState(this.user);

  final User? user;

  @override
  List<Object?> get props => [user];
}

sealed class MainCommand extends Equatable {
  const MainCommand();

  @override
  List<Object?> get props => [];
}

class MainSignOutSuccessCommand extends MainCommand {
  const MainSignOutSuccessCommand();
}

class MainSignOutErrorCommand extends MainCommand {
  const MainSignOutErrorCommand();
}

class MainDeleteUserSuccessCommand extends MainCommand {
  const MainDeleteUserSuccessCommand();
}

class MainDeleteUserErrorCommand extends MainCommand {
  const MainDeleteUserErrorCommand();
}
