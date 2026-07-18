import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/routes/app_router.dart';
import 'package:gastromic/app/views/view_splash/view_model/splash_view_model.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';

@RoutePage()
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashViewModel()..add(SplashInitialEvent()),
      child: BlocListener<SplashViewModel, SplashState>(
        listener: (context, state) {
          switch (state.destination) {
            case SplashDestination.onboarding:
              context.router.replaceAll([OnboardingViewRoute()]);
              break;
            case SplashDestination.login:
              context.router.replaceAll([LoginViewRoute()]);
              break;
            case SplashDestination.preferences:
              context.router.replaceAll([PreferencesViewRoute()]);
              break;
            case SplashDestination.home:
              context.router.replaceAll([const MainWrapperRoute()]);
              break;
            case SplashDestination.none:
              break;
          }
        },
        child: Scaffold(
          backgroundColor: context.cBackground,
          body: const Center(child: FlutterLogo(size: 96)),
        ),
      ),
    );
  }
}
