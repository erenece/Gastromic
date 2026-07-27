part of 'operation_widgets.dart';

mixin OperationVenueCardWidget {
  static Widget venueCard(
    BuildContext context, {
    required MapVenueModel venue,
    required VoidCallback onDetail,
    required VoidCallback onClose,
  }) {
    return Container(
      margin: context.paddingNormal,
      padding: context.paddingLow2x,
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: context.normalBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: context.mediumBorderRadius,
            child: SizedBox(
              width: 64,
              height: 64,
              child: VenueImage(
                imageUrl: venue.imageUrl,
                category: venue.category,
                types: venue.types,
                fit: BoxFit.cover,
              ),
            ),
          ),
          context.sizedWidthBoxNormal,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        venue.name,
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    context.sizedWidthBoxLow,
                    Text(
                      venue.rating.toStringAsFixed(1),
                      style: context.bodyMedium,
                    ),
                  ],
                ),
                Text(
                  venue.categoryLine,
                  style: context.bodyMedium.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                context.sizedHeightBoxLow,
                Row(
                  children: [
                    GestureDetector(
                      onTap: onDetail,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.cPrimary,
                          borderRadius: context.mediumBorderRadius,
                        ),
                        child: Text(
                          'Detaya Git',
                          style: context.bodyMedium.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onClose,
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: context.cTextPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
