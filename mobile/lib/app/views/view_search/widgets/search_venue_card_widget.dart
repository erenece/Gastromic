part of 'search_widgets.dart';

mixin SearchVenueCardWidget {
  static Widget venueCard(
    BuildContext context, {
    required VenueModel venue,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: context.normalBorderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            VenueImage(
              imageUrl: venue.imageUrl,
              category: venue.category,
              types: venue.types,
              fit: BoxFit.cover,
            ),
            // Alt karartma + metin
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: context.paddingLow2x,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      venue.name,
                      style: context.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        context.sizedWidthBoxLow,
                        Text(
                          venue.rating.toStringAsFixed(1),
                          style: context.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
