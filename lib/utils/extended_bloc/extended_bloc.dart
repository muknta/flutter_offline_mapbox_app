import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract interface class BaseCommandBloc<S, C> extends BlocBase<S> {
  BaseCommandBloc(super.initialState, C command);

  Stream<C> get commands;
}

abstract class ExtendedCubit<S, C> extends Cubit<S> implements BaseCommandBloc<S, C> {
  final _commandsController = StreamController<C>.broadcast();

  ExtendedCubit(super.initialState);
  @override
  Future<void> close() {
    _commandsController.close();
    return super.close();
  }

  void command(C command) => _commandsController.add(command);

  @override
  Stream<C> get commands => _commandsController.stream;
}
