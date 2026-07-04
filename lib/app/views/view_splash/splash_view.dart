import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastromic/app/routes/app_router.dart';
import 'package:gastromic/app/views/view_splash/view_model/splash_view_model.dart';

@RoutePage()
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashViewModel()..add(SplashInitialEvent()),
      child: BlocListener<SplashViewModel, SplashState>(
        listener: (context, state) {
          if (state.navigateToOnboarding) {
            context.router.replace(OnboardingViewRoute());
          }
        },
        child: Scaffold(body: Center(child: FlutterLogo(size: 96))),
      ),
    );
  }
}
