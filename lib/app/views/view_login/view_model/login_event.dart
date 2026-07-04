part of "login_view_model.dart";

abstract class LoginEvent {}

class LoginEmailChangedEvent extends LoginEvent {
  final String email;
  LoginEmailChangedEvent(this.email);
}

class LoginPasswordChangedEvent extends LoginEvent {
  final String password;
  LoginPasswordChangedEvent(this.password);
}

class LoginTogglePasswordVisibilityEvent extends LoginEvent {}

class LoginSubmittedEvent extends LoginEvent {}
