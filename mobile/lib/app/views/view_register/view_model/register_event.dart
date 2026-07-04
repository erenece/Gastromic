part of 'register_view_model.dart';

abstract class RegisterEvent {}

class RegisterNameChangedEvent extends RegisterEvent {
  final String name;
  RegisterNameChangedEvent(this.name);
}

class RegisterEmailChangedEvent extends RegisterEvent {
  final String email;
  RegisterEmailChangedEvent(this.email);
}

class RegisterChangedPasswordEvent extends RegisterEvent {
  final String password;
  RegisterChangedPasswordEvent(this.password);
}

class RegisterConfirmPasswordChangedEvent extends RegisterEvent {
  final String confirmPassword;
  RegisterConfirmPasswordChangedEvent(this.confirmPassword);
}

class RegisterTogglePasswordVisibilityEvent extends RegisterEvent {}

class RegisterToggleTermsEvent extends RegisterEvent {}

class RegisterSubmittedEvent extends RegisterEvent {}
