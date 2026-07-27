part of 'edit_profile_view_model.dart';

class EditProfileState {
  final String name;
  final String photoUrl;
  final ViewStatus status;
  final String? errorMessage;
  final bool nameSaved;
  final bool isUploadingPhoto;
  final bool accountDeleted;

  const EditProfileState({
    required this.name,
    required this.photoUrl,
    this.status = ViewStatus.initial,
    this.errorMessage,
    this.nameSaved = false,
    this.isUploadingPhoto = false,
    this.accountDeleted = false,
  });

  EditProfileState copyWith({
    String? name,
    String? photoUrl,
    ViewStatus? status,
    String? errorMessage,
    bool? nameSaved,
    bool? isUploadingPhoto,
    bool? accountDeleted,
  }) {
    return EditProfileState(
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      nameSaved: nameSaved ?? this.nameSaved,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
      accountDeleted: accountDeleted ?? this.accountDeleted,
    );
  }
}
