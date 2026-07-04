import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastromic/core/enums/view_status.dart';

part "splash_event.dart";
part "splash_state.dart";

class SplashViewModel extends Bloc<SplashEvent, SplashState> {
  SplashViewModel() : super(const SplashState()) {
    on<SplashInitialEvent>(_initial);
  }

  FutureOr<void> _initial(
    SplashInitialEvent event,
    Emitter<SplashState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading));

    try {
      await Future.delayed(Duration(seconds: 3));
      emit(
        state.copyWith(status: ViewStatus.success, navigateToOnboarding: true),
      );
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.failure));
    }
  }
}
