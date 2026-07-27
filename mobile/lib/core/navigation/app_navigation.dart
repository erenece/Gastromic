import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class AppNavigation {
  AppNavigation._();

  static void goToHomeTab(StackRouter router) {
    if (router.canPop()) {
      router.pop();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rootContext = router.navigatorKey.currentContext;
      if (rootContext == null || !rootContext.mounted) return;

      final tabsRouter = AutoTabsRouter.of(rootContext);
      tabsRouter.setActiveIndex(0);
    });
  }

  static Future<void> openDirectionsAndGoHome({
    required BuildContext context,
    required Future<void> Function() openDirections,
  }) async {
    final router = context.router;
    await openDirections();
    if (!context.mounted) return;
    goToHomeTab(router);
  }
}
