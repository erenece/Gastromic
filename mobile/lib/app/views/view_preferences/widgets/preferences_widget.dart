import 'package:flutter/material.dart';
import 'package:gastromic/core/constants/preference_constants.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';
import 'package:gastromic/core/widgets/primary_button.dart';

part 'preferences_budget_widget.dart';
part 'preferences_chip_widget.dart';
part 'preferences_mode_card_widget.dart';
part 'preferences_toggle_widget.dart';
part 'preferences_page_one_widget.dart';
part 'preferences_page_two_widget.dart';

mixin PreferencesWidgets {
  final selectableChip = PreferencesChipWidget.selectableChip;
  final modeCard = PreferencesModeCardWidget.modeCard;
  final budgetSlider = PreferencesBudgetWidget.budgetSlider;
  final toggleRow = PreferencesToggleWidget.toggleRow;
  final pageOne = PreferencesPageOneWidget.pageOne;
  final pageTwo = PreferencesPageTwoWidget.pageTwo;
}
