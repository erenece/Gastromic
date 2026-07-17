part of 'rating_widgets.dart';

mixin RatingVenueCardWidget {
  static Widget venueCard(
    BuildContext context, {
    required PendingVisitModel visit,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: context.onlyBottomPaddingNormal,
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: context.normalBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Görsel
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: context.normalRadius),
            child: SizedBox(
              height: context.dynamicHeight(0.18),
              width: double.infinity,
              child: visit.imageUrl.isNotEmpty
                  ? Image.network(visit.imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: context.cPrimary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.restaurant,
                        color: context.cPrimary.withValues(alpha: 0.4),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: context.paddingNormal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        visit.venueName,
                        style: context.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        context.sizedWidthBoxLow,
                        Text(
                          visit.rating.toStringAsFixed(1),
                          style: context.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                context.sizedHeightBoxLow,
                Row(
                  children: [
                    _chip(context, visit.category),
                    context.sizedWidthBoxLow,
                    _chip(context, visit.location),
                  ],
                ),
                context.sizedHeightBoxNormal,
                // "Şu an buradasınız" rozeti
                Container(
                  padding: context.horizontalPaddingConstNormalVertical14,
                  decoration: BoxDecoration(
                    color: context.cSecondary.withValues(alpha: 0.12),
                    borderRadius: context.mediumBorderRadius,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: context.cSecondary,
                      ),
                      context.sizedWidthBoxLow,
                      Text(
                        'Şu an buradasınız',
                        style: context.bodyMedium.copyWith(
                          color: context.cSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                context.sizedHeightBoxNormal,
                PrimaryButton(label: 'Puan Ver', onPressed: onTap),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _chip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.cPrimary.withValues(alpha: 0.08),
        borderRadius: context.xLowBorderRadius,
      ),
      child: Text(label, style: context.bodyMedium.copyWith(fontSize: 11)),
    );
  }
}
