part of 'onboarding_widgets.dart';

mixin OnboardingIndicatorWidget {
  static Widget indicator(
    BuildContext context, {
    required int currentPage,
    required int pageCount,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => AnimatedContainer(
          duration: context.durationLow,
          margin: context.horizontalPaddingConstLow,
          width: currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentPage == index
                ? context.cPrimary
                : context.cPrimary.withValues(alpha: 0.3),
            borderRadius: context.xLowBorderRadius,
          ),
        ),
      ),
    );
  }
}
