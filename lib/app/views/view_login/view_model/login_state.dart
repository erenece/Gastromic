part of 'login_view_model.dart';

class LoginState {
  final ViewStatus status;
  final String email;
  final String password;
  final bool obscurePassword;
  final String? errorMessage;
  final bool isLoggedIn;

  const LoginState({
    this.status = ViewStatus.initial,
    this.email = "",
    this.password = "",
    this.obscurePassword = true,
    this.errorMessage,
    this.isLoggedIn = false,
  });

  LoginState copyWith({
    ViewStatus? status,
    String? email,
    String? password,
    bool? obscurePassword,
    String? errorMessage,
    bool? isLoggedIn,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}
