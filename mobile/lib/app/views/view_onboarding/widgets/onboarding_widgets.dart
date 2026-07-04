import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gastromic/app/routes/app_router.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';
import 'package:gastromic/core/widgets/primary_button.dart';

import 'package:lottie/lottie.dart';

part 'onboarding_indicator_widget.dart';
part 'onboarding_view_widget.dart';

mixin OnboardingWidgets {
  final indicator = OnboardingIndicatorWidget.indicator;
  final onboardingPage = OnboardingViewWidget.onboardingPage;
}
