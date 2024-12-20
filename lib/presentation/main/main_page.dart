import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline_mapbox/presentation/main/main_cubit.dart';
import 'package:flutter_offline_mapbox/utils/extended_bloc/extended_bloc_builder.dart';
import 'package:flutter_offline_mapbox/utils/extensions/context_extension.dart';
import 'package:flutter_offline_mapbox/utils/injector.dart';
import 'package:flutter_offline_mapbox/utils/routes.dart';
import 'package:go_router/go_router.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MainCubit>(
      create: (context) => getIt<MainCubit>(),
      child: ExtendedBlocBuilder<MainCubit, MainState, MainCommand>(
        commandListener: (context, command) {
          switch (command) {
            case MainSignOutSuccessCommand():
              context.showSuccessSnackBar('Successfully signed out');
            case MainSignOutErrorCommand():
              context.showErrorSnackBar('Error on sign out');
            case MainDeleteUserSuccessCommand():
              context.showSuccessSnackBar('Successfully deleted user');
            case MainDeleteUserErrorCommand():
              context.showErrorSnackBar('Error on delete user');
          }
        },
        builder: (context, state) {
          return PopScope(
            canPop: false,
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    if (state.user != null)
                      Text(
                        'Hello, ${state.user!.nickname}',
                        style: const TextStyle(fontSize: 50, fontWeight: FontWeight.w500),
                      ),
                    const Spacer(),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: const Text(
                        'Mapbox',
                        style: TextStyle(fontSize: 30, color: Colors.black54),
                      ),
                      onPressed: () => context.push(Routes.offlineMaps),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      child: const Text('Recent points'),
                      onPressed: () => context.push(Routes.recentPoints),
                    ),
                    const Spacer(flex: 3),
                    if (state.user != null)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade200),
                        child: const Text('Sign out', style: TextStyle(color: Colors.black)),
                        onPressed: () => context.read<MainCubit>().signOut(),
                      ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(backgroundColor: Colors.red.shade400),
                      child: const Text('Delete account', style: TextStyle(color: Colors.black)),
                      onPressed: () => context.read<MainCubit>().deleteUser(),
                    ),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
