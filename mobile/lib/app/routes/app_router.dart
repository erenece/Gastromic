import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gastromic/app/views/view_forgot_password/forgot_password_view.dart';
import 'package:gastromic/app/views/view_login/login_view.dart';
import 'package:gastromic/app/views/view_onboarding/onboarding_view.dart';
import 'package:gastromic/app/views/view_preferences/preferences_view.dart';
import 'package:gastromic/app/views/view_register/register_view.dart';
import 'package:gastromic/app/views/view_search/search_view.dart';
import 'package:gastromic/app/views/view_splash/splash_view.dart';
import 'package:gastromic/app/views/view_venue_detail/venue_detail_view.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'View')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashViewRoute.page, initial: true),
    AutoRoute(page: OnboardingViewRoute.page),
    AutoRoute(page: LoginViewRoute.page),
    AutoRoute(page: RegisterViewRoute.page),
    AutoRoute(page: ForgotPasswordViewRoute.page),
    AutoRoute(page: PreferencesViewRoute.page),
    AutoRoute(page: SearchViewRoute.page),
    AutoRoute(page: VenueDetailViewRoute.page),
  ];
}
