import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastromic/app/views/view_splash/repository/splash_service.dart';

import 'package:gastromic/core/enums/view_status.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashViewModel extends Bloc<SplashEvent, SplashState> {
  SplashViewModel() : super(const SplashState()) {
    on<SplashInitialEvent>(_initial);
  }

  final SplashService _splashService = SplashService();

  FutureOr<void> _initial(
    SplashInitialEvent event,
    Emitter<SplashState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading));

    await Future.delayed(const Duration(seconds: 2));

    try {
      final SplashDestination destination;

      if (_splashService.isLoggedIn) {
        final completed = await _splashService.isPreferencesCompleted();
        destination = completed
            ? SplashDestination.home
            : SplashDestination.preferences;
      } else {
        destination = _splashService.isOnboardingSeen
            ? SplashDestination.login
            : SplashDestination.onboarding;
      }

      emit(
        state.copyWith(status: ViewStatus.success, destination: destination),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ViewStatus.success,
          destination: SplashDestination.login,
        ),
      );
    }
  }
}
