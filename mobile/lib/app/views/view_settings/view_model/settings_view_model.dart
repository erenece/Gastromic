import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_settings/repository/model/settings_profile_model.dart';
import 'package:gastromic/app/views/view_settings/repository/service/settings_service.dart';
import 'package:gastromic/core/enums/view_status.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsViewModel extends Bloc<SettingsEvent, SettingsState>{
  SettingsViewModel() : super(const SettingsState()){
    on<SettingsInitialEvent>(_initial);
    on<SettingsNotificationToggledEvent>(_notificationToggled);
  }

  final SettingsService _settingsService = SettingsService();

  FutureOr<void> _initial(
    SettingsInitialEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading));

    try {
      final profile = await _settingsService.fetchProfile();
      emit(state.copyWith(status: ViewStatus.success, profile: profile));
    } catch (e) {
      emit(
        state.copyWith(status: ViewStatus.failure, errorMessage: e.toString()),
      );
    }
  }


  FutureOr<void> _notificationToggled(
    SettingsNotificationToggledEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final current = state.profile;
    if (current == null) return;

    final updated = SettingsProfileModel(
      name: current.name,
      bio: current.bio,
      photoUrl: current.photoUrl,
      visitCount: current.visitCount,
      membershipYears: current.membershipYears,
      notificationsEnabled: event.value,
    );

    emit(state.copyWith(profile: updated));
    await _settingsService.updateNotifications(event.value);
  }

}