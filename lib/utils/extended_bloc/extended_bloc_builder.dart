import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'extended_bloc.dart';

class ExtendedBlocBuilder<B extends BaseCommandBloc<S, C>, S, C> extends _BlocBuilderBase<B, S, C> {
  const ExtendedBlocBuilder({
    super.key,
    required this.builder,
    super.bloc,
    super.buildWhen,
    super.commandListener,
  });

  final BlocWidgetBuilder<S> builder;

  @override
  Widget build(BuildContext context, S state) => builder(context, state);
}

abstract class _BlocBuilderBase<B extends BaseCommandBloc<S, C>, S, C> extends StatefulWidget {
  const _BlocBuilderBase({super.key, this.bloc, this.buildWhen, this.commandListener});

  final B? bloc;
  final BlocBuilderCondition<S>? buildWhen;
  final void Function(BuildContext context, C command)? commandListener;

  Widget build(BuildContext context, S state);

  @override
  State<_BlocBuilderBase<B, S, C>> createState() => _BlocBuilderBaseState<B, S, C>();
}

class _BlocBuilderBaseState<B extends BaseCommandBloc<S, C>, S, C>
    extends State<_BlocBuilderBase<B, S, C>> {
  late B _bloc;
  late S _state;
  late final StreamSubscription<C> _commandSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
    _state = _bloc.state;
    _commandSubscription = _bloc.commands.listen(_onCommandReceived);
  }

  @override
  void dispose() {
    _commandSubscription.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(_BlocBuilderBase<B, S, C> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? context.read<B>();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      _bloc = currentBloc;
      _state = _bloc.state;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.read<B>();
    if (_bloc != bloc) {
      _bloc = bloc;
      _state = _bloc.state;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bloc == null) {
      context.select<B, bool>((bloc) => identical(_bloc, bloc));
    }
    return BlocListener<B, S>(
      bloc: _bloc,
      listenWhen: widget.buildWhen,
      listener: (context, state) => setState(() => _state = state),
      child: widget.build(context, _state),
    );
  }

  void _onCommandReceived(C command) => widget.commandListener?.call(context, command);
}
