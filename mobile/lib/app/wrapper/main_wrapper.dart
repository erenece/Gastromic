import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:gastromic/app/routes/app_router.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';
import 'package:gastromic/core/navigation/nav_bar_helper.dart';

@RoutePage()
class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: [
        HomeViewRoute(),
        SearchViewRoute(),
        RatingViewRoute(),
        SettingsViewRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: child,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: context.cSurface,
              borderRadius: BorderRadius.vertical(top: context.normalRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: context.verticalPaddingConstLow,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(NavBarHelper.items.length, (index) {
                    final item = NavBarHelper.items[index];
                    final isActive = tabsRouter.activeIndex == index;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => tabsRouter.setActiveIndex(index),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: context.durationLow,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? context.cPrimary
                                  : Colors.transparent,
                              borderRadius: context.highBorderRadius,
                            ),
                            child: Icon(
                              isActive ? item.activeIcon : item.icon,
                              size: 22,
                              color: isActive
                                  ? Colors.white
                                  : context.cTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: context.bodyMedium.copyWith(
                              fontSize: 11,
                              color: isActive
                                  ? context.cPrimary
                                  : context.cTextPrimary,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
