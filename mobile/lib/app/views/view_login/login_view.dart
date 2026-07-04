import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastromic/app/routes/app_router.dart';

import 'package:gastromic/app/views/view_login/view_model/login_view_model.dart';
import 'package:gastromic/app/views/view_login/widgets/login_widgets.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';

@RoutePage()
class LoginView extends StatelessWidget with LoginWidgets {
  LoginView({super.key});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginViewModel(),
      child: BlocConsumer<LoginViewModel, LoginState>(
        listener: (context, state) {
          if (state.status == ViewStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.isLoggedIn) {}
        },
        builder: (context, state) {
          final viewModel = context.read<LoginViewModel>();
          return Scaffold(
            backgroundColor: context.cBackground,
            body: SafeArea(
              child: Center(
                child: loginForm(
                  context,
                  formKey: viewModel.formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  obscurePassword: state.obscurePassword,
                  onToggleObscure: () =>
                      viewModel.add(LoginTogglePasswordVisibilityEvent()),
                  onEmailChanged: (v) =>
                      viewModel.add(LoginEmailChangedEvent(v)),
                  onPasswordChanged: (v) =>
                      viewModel.add(LoginPasswordChangedEvent(v)),
                  onSubmit: () {
                    if (viewModel.formKey.currentState?.validate() ?? false) {
                      viewModel.add(LoginSubmittedEvent());
                    }
                  },
                  onForgotPassword: () =>
                      context.router.replace(ForgotPasswordViewRoute()),
                  onGoToRegister: () =>
                      context.router.replace(RegisterViewRoute()),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
