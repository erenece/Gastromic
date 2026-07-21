part of 'settings_view_model.dart';

abstract class SettingsEvent {}

class SettingsInitialEvent extends SettingsEvent {}

class SettingsNotificationToggledEvent extends SettingsEvent {
  final bool value;
  SettingsNotificationToggledEvent(this.value);
}

class SettingsSignOutRequestedEvent extends SettingsEvent {}
