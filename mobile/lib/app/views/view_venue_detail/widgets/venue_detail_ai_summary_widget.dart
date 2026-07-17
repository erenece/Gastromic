part of 'venue_detail_widgets.dart';

mixin VenueDetailAiSummaryWidget {
  static Widget aiSummary(
    BuildContext context, {
    required String summary,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: context.paddingNormal,
          decoration: BoxDecoration(
            color: context.cSecondary.withValues(alpha: 0.1),
            borderRadius: context.normalBorderRadius,
            border: Border.all(
              color: context.cSecondary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.verified_outlined,
                color: context.cSecondary,
                size: 20,
              ),
              context.sizedWidthBoxLow,
              Expanded(child: Text(summary, style: context.bodyMedium)),
            ],
          ),
        ),
        context.sizedHeightBoxNormal,
        Text(description, style: context.bodyMedium),
      ],
    );
  }
}
