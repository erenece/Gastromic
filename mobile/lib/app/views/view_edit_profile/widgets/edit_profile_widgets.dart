import 'package:flutter/material.dart';

import 'package:gastromic/core/extensions/core_extensions.dart';

part 'edit_profile_avatar_widget.dart';
part 'edit_profile_photo_sheet_widget.dart';

mixin EditProfileWidgets {
  final avatar = EditProfileAvatarWidget.avatar;
  final photoSourceSheet = EditProfilePhotoSheetWidget.photoSourceSheet;
}
