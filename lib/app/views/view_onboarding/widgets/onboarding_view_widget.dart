part of 'onboarding_widgets.dart';

mixin OnboardingViewWidget {
  static Widget onboardingPage(
    BuildContext context, {
    required String lottiePath,
    required String title,
    required String descripton,
    required int currentPage,
    required bool isLastPage,
    VoidCallback? onCompleted,
  }) {
    return Padding(
      padding: context.paddingNormal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Lottie.asset(
            lottiePath,
            height: context.dynamicHeight(0.3),
            fit: BoxFit.contain,
          ),
          context.sizedHeightBoxHigh,
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: context.headlineLarge,
                textAlign: TextAlign.center,
              ),
              context.sizedHeightBoxHigh,
              Text(
                descripton,
                style: context.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          context.sizedHeightBoxHigh,
          OnboardingIndicatorWidget.indicator(
            context,
            currentPage: currentPage,
            pageCount: 3,
          ),
          AnimatedSwitcher(
            duration: context.durationLow,
            child: isLastPage
                ? Padding(
                    key: const ValueKey('button'),
                    padding: context.paddingNormal,
                    child: Column(
                      children: [
                        PrimaryButton(
                          label: "Üye Ol",
                          onPressed: () {
                            onCompleted?.call();
                            context.router.push(RegisterViewRoute());
                          },
                        ),
                        context.sizedHeightBoxMedium,
                        Text.rich(
                          TextSpan(
                            text: 'Zaten bir hesabın var mı? ',
                            style: context.bodyMedium,
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    onCompleted?.call();
                                    context.router.push(LoginViewRoute());
                                  },
                                text: 'Giriş Yap',
                                style: context.textTheme.labelLarge?.copyWith(
                                  color: context.cPrimary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }
}
