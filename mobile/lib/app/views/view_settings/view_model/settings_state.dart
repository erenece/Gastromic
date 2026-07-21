part of 'settings_view_model.dart';

class SettingsState {
  final ViewStatus status;
  final SettingsProfileModel? profile;
  final String? errorMessage;

  const SettingsState({
    this.status = ViewStatus.initial,
    this.profile,
    this.errorMessage,
  });

SettingsState copyWith({
  ViewStatus? status,
  SettingsProfileModel? profile,
  String? errorMessage,
}) {
  return SettingsState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
}





