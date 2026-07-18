part of 'splash_view_model.dart';

enum SplashDestination { none, onboarding, login, preferences, home }

class SplashState {
  final ViewStatus status;
  final SplashDestination destination;

  const SplashState({
    this.status = ViewStatus.initial,
    this.destination = SplashDestination.none,
  });

  SplashState copyWith({ViewStatus? status, SplashDestination? destination}) {
    return SplashState(
      status: status ?? this.status,
      destination: destination ?? this.destination,
    );
  }
}
