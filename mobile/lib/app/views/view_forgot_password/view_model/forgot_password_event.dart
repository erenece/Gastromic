part of "forgot_password_view_model.dart";

abstract class ForgotPasswordEvent {}

class ForgotPasswordEmailChangedEvent extends ForgotPasswordEvent {
  final String email;
  ForgotPasswordEmailChangedEvent(this.email);
}

class ForgotPasswordSubmittedEvent extends ForgotPasswordEvent {}
