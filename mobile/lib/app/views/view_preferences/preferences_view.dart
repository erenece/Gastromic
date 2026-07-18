import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastromic/app/routes/app_router.dart';

import 'package:gastromic/app/views/view_preferences/view_model/preferences_view_model.dart';
import 'package:gastromic/app/views/view_preferences/widgets/preferences_widget.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';

@RoutePage()
class PreferencesView extends StatelessWidget with PreferencesWidgets {
  PreferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PreferencesViewModel(),
      child: BlocConsumer<PreferencesViewModel, PreferencesState>(
        listener: (context, state) {
          if (state.status == ViewStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.isCompleted) {
            context.router.replaceAll([const MainWrapperRoute()]);
          }
        },
        builder: (context, state) {
          final viewModel = context.read<PreferencesViewModel>();
          return Scaffold(
            backgroundColor: context.cBackground,
            appBar: AppBar(
              backgroundColor: context.cBackground,
              leading: state.currentPage == 1
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => viewModel.pageController.animateToPage(
                        0,
                        duration: context.durationLow,
                        curve: Curves.easeInOut,
                      ),
                    )
                  : null,
            ),
            body: SafeArea(
              child: PageView(
                controller: viewModel.pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) =>
                    viewModel.add(PreferencesPageChangedEvent(index)),
                children: [
                  pageOne(
                    context,
                    selectedAllergens: state.selectedAllergens,
                    selectedConditions: state.selectedConditions,
                    onToggleAllergen: (a) =>
                        viewModel.add(PreferencesToggleAllergenEvent(a)),
                    onToggleCondition: (c) =>
                        viewModel.add(PreferencesToggleConditionEvent(c)),
                    onNext: () => viewModel.pageController.animateToPage(
                      1,
                      duration: context.durationLow,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  pageTwo(
                    context,
                    selectedMode: state.selectedMode,
                    budget: state.budget,

                    smokingArea: state.smokingArea,
                    alcoholService: state.alcoholService,
                    onSelectMode: (m) =>
                        viewModel.add(PreferencesSelectModeEvent(m)),
                    onBudgetChanged: (b) =>
                        viewModel.add(PreferencesBudgetChangedEvent(b)),
                    onSmokingChanged: (_) =>
                        viewModel.add(PreferencesToggleSmokingEvent()),
                    onAlcoholChanged: (_) =>
                        viewModel.add(PreferencesToggleAlcoholEvent()),
                    onSubmit: () => viewModel.add(PreferencesSubmittedEvent()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
