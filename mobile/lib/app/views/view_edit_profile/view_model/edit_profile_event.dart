part of 'edit_profile_view_model.dart';

abstract class EditProfileEvent {}

class EditProfileNameChangedEvent extends EditProfileEvent {
  final String name;
  EditProfileNameChangedEvent(this.name);
}

class EditProfileNameSavedEvent extends EditProfileEvent {}

class EditProfilePhotoPickedEvent extends EditProfileEvent {
  final File file;
  EditProfilePhotoPickedEvent(this.file);
}

class EditProfileDeleteAccountRequestedEvent extends EditProfileEvent {}
