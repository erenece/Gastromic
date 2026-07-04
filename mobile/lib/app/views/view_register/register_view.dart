import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastromic/app/routes/app_router.dart';
import 'package:gastromic/app/views/view_register/view_model/register_view_model.dart';
import 'package:gastromic/app/views/view_register/widgets/register_widget.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';

@RoutePage()
class RegisterView extends StatelessWidget with RegisterWidget {
  RegisterView({super.key});

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterViewModel(),
      child: BlocConsumer<RegisterViewModel, RegisterState>(
        listener: (context, state) {
          if (state.status == ViewStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.isRegistered) {
            context.router.replaceAll([PreferencesViewRoute()]);
          }
        },
        builder: (BuildContext context, RegisterState state) {
          final viewModel = context.read<RegisterViewModel>();
          return Scaffold(
            backgroundColor: context.cBackground,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: registerForm(
                    context,
                    formKey: viewModel.formKey,
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    obscurePassword: state.obscurePassword,
                    termsAccepted: state.termsAccepted,
                    canSubmit: state.canSubmit,
                    onToggleObscure: () =>
                        viewModel.add(RegisterTogglePasswordVisibilityEvent()),
                    onToggleTerms: () =>
                        viewModel.add(RegisterToggleTermsEvent()),
                    onNameChanged: (v) =>
                        viewModel.add(RegisterNameChangedEvent(v)),
                    onEmailChanged: (v) =>
                        viewModel.add(RegisterEmailChangedEvent(v)),
                    onPasswordChanged: (v) =>
                        viewModel.add(RegisterChangedPasswordEvent(v)),
                    onConfirmPasswordChanged: (v) =>
                        viewModel.add(RegisterConfirmPasswordChangedEvent(v)),
                    onSubmit: () {
                      if (viewModel.formKey.currentState?.validate() ?? false) {
                        if (!state.termsAccepted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Kullanım koşullarını kabul etmelisiniz',
                              ),
                            ),
                          );
                          return;
                        }
                        viewModel.add(RegisterSubmittedEvent());
                      }
                    },
                    onGoToLogin: () => context.router.replace(LoginViewRoute()),
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
