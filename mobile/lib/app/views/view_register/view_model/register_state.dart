part of 'register_view_model.dart';

class RegisterState {
  final ViewStatus status;
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final bool obscurePassword;
  final bool termsAccepted;
  final String? errorMessage;
  final bool isRegistered;

  const RegisterState({
    this.status = ViewStatus.initial,
    this.name = "",
    this.email = "",
    this.password = "",
    this.confirmPassword = "",
    this.obscurePassword = true,
    this.termsAccepted = false,
    this.errorMessage,
    this.isRegistered = false,
  });

  bool get passwordsMatch => password == confirmPassword;

  bool get canSubmit =>
      name.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      passwordsMatch &&
      termsAccepted;

  RegisterState copyWith({
    ViewStatus? status,
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    bool? obscurePassword,
    bool? termsAccepted,
    String? errorMessage,
    bool? isRegistered,
  }) {
    return RegisterState(
      status: status ?? this.status,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      errorMessage: errorMessage ?? this.errorMessage,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}
