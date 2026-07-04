part of 'preferences_view_model.dart';

abstract class PreferencesEvent {}

class PreferencesPageChangedEvent extends PreferencesEvent {
  final int page;
  PreferencesPageChangedEvent(this.page);
}

class PreferencesToggleAllergenEvent extends PreferencesEvent {
  final String allergen;
  PreferencesToggleAllergenEvent(this.allergen);
}

class PreferencesToggleConditionEvent extends PreferencesEvent {
  final String condition;
  PreferencesToggleConditionEvent(this.condition);
}

class PreferencesSelectModeEvent extends PreferencesEvent {
  final String mode;
  PreferencesSelectModeEvent(this.mode);
}

class PreferencesBudgetChangedEvent extends PreferencesEvent {
  final double budget;
  PreferencesBudgetChangedEvent(this.budget);
}

class PreferencesToggleSmokingEvent extends PreferencesEvent {}

class PreferencesToggleAlcoholEvent extends PreferencesEvent {}

class PreferencesSubmittedEvent extends PreferencesEvent {}
