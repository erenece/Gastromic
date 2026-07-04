import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingViewModel extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingViewModel() : super(const OnboardingState()) {
    on<OnboardingPageChanged>(_pageChanged);
    on<OnboardingCompleted>(_onCompleted);
  }

  final PageController pageController = PageController();

  FutureOr<void> _pageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(currentPage: event.page));
  }

  FutureOr<void> _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    final box = Hive.box('settings');
    await box.put('onboarding_seen', true);
    emit(state.copyWith(isCompleted: true));
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}
