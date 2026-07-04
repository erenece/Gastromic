part of 'splash_view_model.dart';

class SplashState {
  final ViewStatus status;
  final bool navigateToOnboarding;

  const SplashState({
    this.status = ViewStatus.initial,
    this.navigateToOnboarding = false,
  });

  SplashState copyWith({ViewStatus? status, bool? navigateToOnboarding}) {
    return SplashState(
      status: status ?? this.status,
      navigateToOnboarding: navigateToOnboarding ?? this.navigateToOnboarding,
    );
  }
}
