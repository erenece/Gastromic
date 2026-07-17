part of 'venue_detail_widgets.dart';

mixin VenueDetailFeaturesWidget {
  static Widget features(
    BuildContext context, {
    required List<String> features,
  }) {
    if (features.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Öne Çıkan Özellikler', style: context.titleLarge),
        context.sizedHeightBoxNormal,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: features.map((feature) {
            return Container(
              width: (context.width - 56) / 2,
              padding: context.paddingLow2x,
              decoration: BoxDecoration(
                color: context.cSurface,
                borderRadius: context.mediumBorderRadius,
                border: Border.all(
                  color: context.cPrimary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: context.cSecondary,
                  ),
                  context.sizedWidthBoxLow,
                  Expanded(
                    child: Text(
                      feature,
                      style: context.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
