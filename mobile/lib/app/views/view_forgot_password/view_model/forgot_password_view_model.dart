import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastromic/app/views/view_login/repository/service/auth_service.dart';
import 'package:gastromic/core/enums/view_status.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordViewModel
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordViewModel() : super(const ForgotPasswordState()) {
    on<ForgotPasswordEmailChangedEvent>(_emailChanged);
    on<ForgotPasswordSubmittedEvent>(_submit);
  }

  final AuthService _authService = AuthService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FutureOr<void> _emailChanged(
    ForgotPasswordEmailChangedEvent event,
    Emitter<ForgotPasswordState> emit,
  ) {
    emit(state.copyWith(email: event.email));
  }

  FutureOr<void> _submit(
    ForgotPasswordSubmittedEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      await _authService.sendPasswordResetEmail(state.email);
      emit(state.copyWith(status: ViewStatus.success, isEmailSent: true));
    } catch (e) {
      emit(
        state.copyWith(status: ViewStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
