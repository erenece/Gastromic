part of 'onboarding_view_model.dart';

class OnboardingState {
  final int currentPage;
  final bool isCompleted;

  const OnboardingState({this.currentPage = 0, this.isCompleted = false});

  bool get isLastPage => currentPage == 2;
  bool get isFirstPage => currentPage == 0;

  OnboardingState copyWith({int? currentPage, bool? isCompleted}) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
