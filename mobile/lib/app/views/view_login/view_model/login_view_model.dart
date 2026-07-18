import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastromic/app/views/view_login/repository/service/auth_service.dart';
import 'package:gastromic/core/enums/view_status.dart';

part "login_event.dart";

part 'login_state.dart';

class LoginViewModel extends Bloc<LoginEvent, LoginState> {
  LoginViewModel() : super(LoginState()) {
    on<LoginEmailChangedEvent>(_emailChanged);
    on<LoginPasswordChangedEvent>(_passwordChanged);
    on<LoginTogglePasswordVisibilityEvent>(_toggleVisibility);
    on<LoginSubmittedEvent>(_submit);
  }

  final AuthService _authService = AuthService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FutureOr<void> _emailChanged(
    LoginEmailChangedEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(email: event.email));
  }

  FutureOr<void> _passwordChanged(
    LoginPasswordChangedEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(password: event.password));
  }

  FutureOr<void> _toggleVisibility(
    LoginTogglePasswordVisibilityEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  FutureOr<void> _submit(
    LoginSubmittedEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      await _authService.signInWithEmail(
        email: state.email,
        password: state.password,
      );
      final completed = await _authService.isPreferencesCompleted();
      emit(
        state.copyWith(
          status: ViewStatus.success,
          isLoggedIn: true,
          preferencesCompleted: completed,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ViewStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
