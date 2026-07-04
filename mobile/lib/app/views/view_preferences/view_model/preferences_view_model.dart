import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastromic/app/views/view_preferences/repository/model/preferences_model.dart';
import 'package:gastromic/app/views/view_preferences/repository/service/preferences_service.dart';

import 'package:gastromic/core/enums/view_status.dart';

part 'preferences_event.dart';
part 'preferences_state.dart';

class PreferencesViewModel extends Bloc<PreferencesEvent, PreferencesState> {
  PreferencesViewModel() : super(const PreferencesState()) {
    on<PreferencesPageChangedEvent>(_pageChanged);
    on<PreferencesToggleAllergenEvent>(_toggleAllergen);
    on<PreferencesToggleConditionEvent>(_toggleCondition);
    on<PreferencesSelectModeEvent>(_selectMode);
    on<PreferencesBudgetChangedEvent>(_budgetChanged);
    on<PreferencesToggleSmokingEvent>(_toggleSmoking);
    on<PreferencesToggleAlcoholEvent>(_toggleAlcohol);
    on<PreferencesSubmittedEvent>(_submit);
  }

  final PageController pageController = PageController();
  final PreferencesService _preferencesService = PreferencesService();

  FutureOr<void> _pageChanged(
    PreferencesPageChangedEvent event,
    Emitter<PreferencesState> emit,
  ) {
    emit(state.copyWith(currentPage: event.page));
  }

  FutureOr<void> _toggleAllergen(
    PreferencesToggleAllergenEvent event,
    Emitter<PreferencesState> emit,
  ) {
    final updated = Set<String>.from(state.selectedAllergens);
    if (updated.contains(event.allergen)) {
      updated.remove(event.allergen);
    } else {
      updated.add(event.allergen);
    }
    emit(state.copyWith(selectedAllergens: updated));
  }

  FutureOr<void> _toggleCondition(
    PreferencesToggleConditionEvent event,
    Emitter<PreferencesState> emit,
  ) {
    final updated = Set<String>.from(state.selectedConditions);
    if (updated.contains(event.condition)) {
      updated.remove(event.condition);
    } else {
      updated.add(event.condition);
    }
    emit(state.copyWith(selectedConditions: updated));
  }

  FutureOr<void> _selectMode(
    PreferencesSelectModeEvent event,
    Emitter<PreferencesState> emit,
  ) {
    if (state.selectedMode == event.mode) {
      emit(state.copyWith(clearMode: true));
    } else {
      emit(state.copyWith(selectedMode: event.mode));
    }
  }

  FutureOr<void> _budgetChanged(
    PreferencesBudgetChangedEvent event,
    Emitter<PreferencesState> emit,
  ) {
    emit(state.copyWith(budget: event.budget));
  }

  FutureOr<void> _toggleSmoking(
    PreferencesToggleSmokingEvent event,
    Emitter<PreferencesState> emit,
  ) {
    emit(state.copyWith(smokingArea: !state.smokingArea));
  }

  FutureOr<void> _toggleAlcohol(
    PreferencesToggleAlcoholEvent event,
    Emitter<PreferencesState> emit,
  ) {
    emit(state.copyWith(alcoholService: !state.alcoholService));
  }

  FutureOr<void> _submit(
    PreferencesSubmittedEvent event,
    Emitter<PreferencesState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final model = PreferencesModel(
        allergens: state.selectedAllergens.toList(),
        conditions: state.selectedConditions.toList(),
        mode: state.selectedMode,
        budget: state.budget,
        smokingArea: state.smokingArea,
        alcoholService: state.alcoholService,
      );

      await _preferencesService.savePreferences(model);

      emit(state.copyWith(status: ViewStatus.success, isCompleted: true));
    } catch (e) {
      emit(
        state.copyWith(status: ViewStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}
