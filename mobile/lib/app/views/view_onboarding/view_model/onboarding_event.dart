part of 'onboarding_view_model.dart';

abstract class OnboardingEvent {}

class OnboardingPageChanged extends OnboardingEvent {
  final int page;
  OnboardingPageChanged(this.page);
}

class OnboardingCompleted extends OnboardingEvent {}
