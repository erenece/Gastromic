import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastromic/app/views/view_register/repository/service/auth_service.dart';
import 'package:gastromic/core/enums/view_status.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterViewModel extends Bloc<RegisterEvent, RegisterState> {
  RegisterViewModel() : super(const RegisterState()) {
    on<RegisterNameChangedEvent>(_nameChanged);
    on<RegisterEmailChangedEvent>(_emailChanged);
    on<RegisterChangedPasswordEvent>(_passwordChanged);
    on<RegisterConfirmPasswordChangedEvent>(_confirmPasswordChanged);
    on<RegisterTogglePasswordVisibilityEvent>(_toggleVisibility);
    on<RegisterToggleTermsEvent>(_toggleTerms);
    on<RegisterSubmittedEvent>(_submit);
  }

  final AuthService _authService = AuthService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FutureOr<void> _nameChanged(
    RegisterNameChangedEvent event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(name: event.name));
  }

  FutureOr<void> _emailChanged(
    RegisterEmailChangedEvent event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(email: event.email));
  }

  FutureOr<void> _passwordChanged(
    RegisterChangedPasswordEvent event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(password: event.password));
  }

  FutureOr<void> _confirmPasswordChanged(
    RegisterConfirmPasswordChangedEvent event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(confirmPassword: event.confirmPassword));
  }

  FutureOr<void> _toggleTerms(
    RegisterToggleTermsEvent event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(termsAccepted: !state.termsAccepted));
  }

  FutureOr<void> _submit(
    RegisterSubmittedEvent event,
    Emitter<RegisterState> emit,
  ) async {
    if (!state.passwordsMatch) {
      emit(
        state.copyWith(
          status: ViewStatus.failure,
          errorMessage: "Şifreler Uyuşmuyor",
        ),
      );
      return;
    }

    emit(state.copyWith(status: ViewStatus.loading));

    try {
      await _authService.registerWithEmail(
        name: state.name,
        password: state.password,
        email: state.email,
      );
      emit(state.copyWith(status: ViewStatus.success, isRegistered: true));
    } catch (e) {
      emit(
        state.copyWith(status: ViewStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  FutureOr<void> _toggleVisibility(
    RegisterTogglePasswordVisibilityEvent event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }
}
