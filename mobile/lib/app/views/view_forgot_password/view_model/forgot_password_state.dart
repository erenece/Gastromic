part of 'forgot_password_view_model.dart';

class ForgotPasswordState {
  final ViewStatus status;
  final String email;
  final String? errorMessage;
  final bool isEmailSent;

  const ForgotPasswordState({
    this.status = ViewStatus.initial,
    this.email = "",
    this.errorMessage,
    this.isEmailSent = false,
  });

  ForgotPasswordState copyWith({
    ViewStatus? status,
    String? email,
    String? errorMessage,
    bool? isEmailSent,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      email: email ?? this.email,
      errorMessage: errorMessage ?? this.errorMessage,
      isEmailSent: isEmailSent ?? this.isEmailSent,
    );
  }
}
