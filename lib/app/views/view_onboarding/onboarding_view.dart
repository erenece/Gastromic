import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_onboarding/view_model/onboarding_view_model.dart';
import 'package:gastromic/app/views/view_onboarding/widgets/onboarding_widgets.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';

@RoutePage()
class OnboardingView extends StatelessWidget with OnboardingWidgets {
  OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingViewModel(),
      child: BlocBuilder<OnboardingViewModel, OnboardingState>(
        builder: (context, state) {
          final viewModel = context.read<OnboardingViewModel>();
          return Scaffold(
            appBar: AppBar(
              backgroundColor: context.cBackground,
              actions: [
                if (!state.isLastPage)
                  TextButton(
                    onPressed: () {
                      viewModel.add(OnboardingCompleted());
                      viewModel.pageController.animateToPage(
                        2,
                        duration: context.durationLow,
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text('Geç', style: context.textTheme.labelSmall),
                  ),
              ],
            ),
            body: PageView(
              onPageChanged: (index) =>
                  viewModel.add(OnboardingPageChanged(index)),
              controller: viewModel.pageController,
              children: [
                onboardingPage(
                  context,
                  lottiePath: 'assets/animations/onboarding1.json',
                  title: 'Sana Özel Lezzet Rotası',
                  descripton:
                      'Beslenme alışkanlıklarına ve tercihlerine göre kişiselleştirilmiş öneriler al',
                  currentPage: state.currentPage,
                  isLastPage: false,
                ),
                onboardingPage(
                  context,
                  lottiePath: 'assets/animations/onboarding2.json',
                  title: 'Herkesin Konuştuğu Mekanlar',
                  descripton:
                      'Yerel halkın ve gezginlerin favori mekanlarını tek yerden gör',
                  currentPage: state.currentPage,
                  isLastPage: false,
                ),
                onboardingPage(
                  context,
                  lottiePath: 'assets/animations/onboarding3.json',
                  title: 'Keşfe Hazır mısın?',
                  descripton:
                      "Hemen üye ol, sana özel rotanı birkaç saniyede oluştur",
                  currentPage: state.currentPage,
                  isLastPage: true,
                  onCompleted: () => viewModel.add(OnboardingCompleted()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
