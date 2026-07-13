import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_forgot_password/view_model/forgot_password_view_model.dart';
import 'package:gastromic/app/views/view_forgot_password/widgets/forgot_password_widgets.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';

@RoutePage()
class ForgotPasswordView extends StatelessWidget with ForgotPasswordWidgets {
  ForgotPasswordView({super.key});

  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordViewModel(),
      child: BlocConsumer<ForgotPasswordViewModel, ForgotPasswordState>(
        listener: (context, state) {
          if (state.status == ViewStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.isEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sıfırlama bağlantısı gönderildi')),
            );
          }
        },

        builder: (context, state) {
          final viewModel = context.read<ForgotPasswordViewModel>();
          return Scaffold(
            backgroundColor: context.cBackground,
            appBar: AppBar(
              backgroundColor: context.cBackground,
              leading: const BackButton(),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: forgotPasswordForm(
                  context,
                  formKey: viewModel.formKey,
                  emailController: _emailController,
                  isLoading: state.status == ViewStatus.loading,
                  isEmailSent: state.isEmailSent,
                  onEmailChanged: (v) =>
                      viewModel.add(ForgotPasswordEmailChangedEvent(v)),
                  onSubmit: () {
                    if (viewModel.formKey.currentState?.validate() ?? false) {
                      viewModel.add(ForgotPasswordSubmittedEvent());
                    }
                  },
                  onSupport: () {},
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
