import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline_mapbox/presentation/widgets/ink_wrapper.dart';
import 'package:flutter_offline_mapbox/utils/extended_bloc/extended_bloc_builder.dart';
import 'package:flutter_offline_mapbox/utils/extensions/context_extension.dart';
import 'package:flutter_offline_mapbox/utils/injector.dart';

import 'auth_cubit.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nicknameController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return BlocProvider<AuthCubit>(
      create: (BuildContext context) => getIt<AuthCubit>(),
      child: ExtendedBlocBuilder<AuthCubit, AuthState, AuthCommand>(
        commandListener: (BuildContext context, command) {
          switch (command) {
            case SignInNotFoundCommand():
              context.showErrorSnackBar('Nickname or password are wrong');
            case SignUpExistsCommand():
              context.showErrorSnackBar('User already exists');
            case SignUpValidationErrorCommand():
              context.showErrorSnackBar('Nickname or password are too short');
          }
        },
        builder: (context, state) {
          void Function({required String nickname, required String password}) proceed;
          void Function() switchTo;
          String currentAction;
          String oppositeAction;
          switch (state) {
            case SignInState():
              proceed = context.read<AuthCubit>().signIn;
              switchTo = context.read<AuthCubit>().switchToSignUp;
              currentAction = 'Sign In';
              oppositeAction = 'Sign Up';
            case SignUpState():
              proceed = context.read<AuthCubit>().signUp;
              switchTo = context.read<AuthCubit>().switchToSignIn;
              currentAction = 'Sign Up';
              oppositeAction = 'Sign In';
          }
          return PopScope(
            canPop: false,
            child: Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nickname', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        TextFormField(controller: nicknameController),
                        const SizedBox(height: 20),
                        Text('Password', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: passwordController,
                          obscureText: state is SignInState,
                        ),
                        const SizedBox(height: 20),
                        if (state is SignUpState) ...[
                          Text('Confirm password', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: confirmPasswordController,
                            validator: (value) {
                              return value != passwordController.text ? 'Passwords do not match' : null;
                            },
                          ),
                        ],
                        const SizedBox(height: 40),
                        Center(
                          child: ElevatedButton(
                            onPressed: state.isLoading
                                ? null
                                : () {
                                    final formState = formKey.currentState;
                                    if (formState == null || !formState.validate()) {
                                      return;
                                    }
                                    formState.save();
                                    proceed(nickname: nicknameController.text, password: passwordController.text);
                                  },
                            child: Text(currentAction, style: Theme.of(context).textTheme.headlineSmall),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: InkWrapper(
                            onTap: switchTo,
                            borderRadius: BorderRadius.circular(32),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(oppositeAction, style: Theme.of(context).textTheme.titleMedium),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
