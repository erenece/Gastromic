import 'package:flutter/material.dart';
import 'package:flavor/flavor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastromic/app/routes/app_router.dart';
import 'package:gastromic/app/theme/theme_cubit.dart';
import 'package:gastromic/core/themes/app_theme_dark.dart';
import 'package:gastromic/core/themes/app_theme_light.dart';

class App extends StatelessWidget {
  App({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return FlavorBanner(
            child: MaterialApp.router(
              theme: appThemeLight(),
              darkTheme: appThemeDark(),
              themeMode: themeMode,
              debugShowCheckedModeBanner: false,
              title: 'Gastromic',
              routerConfig: _appRouter.config(),
            ),
          );
        },
      ),
    );
  }
}
