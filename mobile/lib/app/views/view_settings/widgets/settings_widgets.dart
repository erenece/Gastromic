import 'package:flutter/material.dart';

import 'package:gastromic/app/views/view_settings/repository/model/settings_profile_model.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';
import 'package:gastromic/core/widgets/primary_button.dart';

part 'settings_profile_card_widget.dart';
part 'settings_stat_item_widget.dart';
part 'settings_row_widget.dart';
part 'settings_theme_sheet_widget.dart';

mixin SettingsWidgets {
  final profileCard = SettingsProfileCardWidget.profileCard;
  final statItem = SettingsStatItemWidget.statItem;
  final settingsRow = SettingsRowWidget.settingsRow;
  final themeSheet = SettingsThemeSheetWidget.themeSheet;
}
