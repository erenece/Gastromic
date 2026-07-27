import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_settings/repository/service/settings_service.dart';
import 'package:gastromic/core/enums/view_status.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

class EditProfileViewModel extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileViewModel({required String name, required String photoUrl})
    : super(EditProfileState(name: name, photoUrl: photoUrl)) {
    on<EditProfileNameChangedEvent>(_nameChanged);
    on<EditProfileNameSavedEvent>(_saveName);
    on<EditProfilePhotoPickedEvent>(_photoPicked);
    on<EditProfileDeleteAccountRequestedEvent>(_deleteAccount);
  }

  final SettingsService _settingsService = SettingsService();

  FutureOr<void> _nameChanged(
    EditProfileNameChangedEvent event,
    Emitter<EditProfileState> emit,
  ) {
    emit(state.copyWith(name: event.name));
  }

  FutureOr<void> _saveName(
    EditProfileNameSavedEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading, nameSaved: false));

    try {
      await _settingsService.updateName(state.name);
      emit(state.copyWith(status: ViewStatus.success, nameSaved: true));
    } catch (e) {
      emit(
        state.copyWith(status: ViewStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  FutureOr<void> _photoPicked(
    EditProfilePhotoPickedEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading, isUploadingPhoto: true));

    try {
      final url = await _settingsService.uploadProfilePhoto(event.file);
      emit(
        state.copyWith(
          status: ViewStatus.success,
          photoUrl: url,
          isUploadingPhoto: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ViewStatus.failure,
          errorMessage: e.toString(),
          isUploadingPhoto: false,
        ),
      );
    }
  }

  FutureOr<void> _deleteAccount(
    EditProfileDeleteAccountRequestedEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading));

    try {
      await _settingsService.deleteAccount();
      emit(state.copyWith(status: ViewStatus.success, accountDeleted: true));
    } catch (e) {
      emit(
        state.copyWith(status: ViewStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
