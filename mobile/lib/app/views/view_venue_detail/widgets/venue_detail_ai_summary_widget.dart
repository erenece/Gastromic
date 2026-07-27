part of 'venue_detail_widgets.dart';

mixin VenueDetailAiSummaryWidget {
  static Widget aiSummary(
    BuildContext context, {
    required String summary,
    required String description,
    Map<String, dynamic> checks = const {},
    List<String> userAllergens = const [],
    List<String> userConditions = const [],
    String userDailyMode = '',
  }) {
    final baseStyle = context.bodyMedium;
    final highlighted = AiSummaryHighlighter.buildHighlightedSpan(
      text: summary,
      baseStyle: baseStyle,
      checks: checks,
      userAllergens: userAllergens,
      userConditions: userConditions,
      userDailyMode: userDailyMode,
    );

    final modeMatch = (checks['mode_match'] as String?)?.toLowerCase();
    final hasHighlights = checks.isNotEmpty ||
        userAllergens.isNotEmpty ||
        userConditions.isNotEmpty ||
        modeMatch == 'uyumlu';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: context.paddingNormal,
          decoration: BoxDecoration(
            color: context.cSecondary.withValues(alpha: 0.08),
            borderRadius: context.normalBorderRadius,
            border: Border.all(
              color: context.cSecondary.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: context.cSecondary,
                    size: 18,
                  ),
                  context.sizedWidthBoxLow,
                  Text(
                    'AI Önerisi',
                    style: context.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.cSecondary,
                    ),
                  ),
                ],
              ),
              context.sizedHeightBoxLow,
              RichText(text: highlighted),
              if (hasHighlights) ...[
                context.sizedHeightBoxLow,
                _legend(context),
              ],
            ],
          ),
        ),
        context.sizedHeightBoxNormal,
        Text(description, style: context.bodyMedium),
      ],
    );
  }

  static Widget _legend(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _legendDot(context, const Color(0xFFD32F2F), 'Hassasiyet'),
        _legendDot(context, const Color(0xFFF57C00), 'Alerjen'),
        _legendDot(context, const Color(0xFF2E7D32), 'Mod uyumu'),
      ],
    );
  }

  static Widget _legendDot(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: context.bodyMedium.copyWith(fontSize: 10, color: color),
        ),
      ],
    );
  }
}
