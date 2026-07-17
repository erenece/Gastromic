part of 'venue_detail_widgets.dart';

mixin VenueDetailHeroWidget {
  static Widget hero(
    BuildContext context, {
    required VenueDetailModel venue,
    required bool isFavorite,
    required VoidCallback onBack,
    required VoidCallback onToggleFavorite,
  }) {
    return SizedBox(
      height: context.dynamicHeight(0.35),
      child: Stack(
        fit: StackFit.expand,
        children: [
          venue.imageUrl.isNotEmpty
              ? Image.network(venue.imageUrl, fit: BoxFit.cover)
              : Container(color: context.cPrimary.withValues(alpha: 0.15)),
          // Karartma
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.75),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Geri butonu
          Positioned(
            top: 12,
            left: 12,
            child: _circleButton(context, Icons.arrow_back, onBack),
          ),
          // Favori butonu (sağ alt)
          Positioned(
            right: 12,
            bottom: 12,
            child: _circleButton(
              context,
              isFavorite ? Icons.favorite : Icons.favorite_border,
              onToggleFavorite,
              iconColor: isFavorite ? context.cPrimary : null,
            ),
          ),
          // Başlık bloğu
          Positioned(
            left: 16,
            right: 60,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _tag(context, venue.category.toUpperCase(), filled: true),
                    context.sizedWidthBoxLow,
                    _tag(context, 'Akdeniz Mutfağı'),
                  ],
                ),
                context.sizedHeightBoxLow,
                Text(
                  venue.name,
                  style: context.headlineLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                context.sizedHeightBoxLow,
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    context.sizedWidthBoxLow,
                    Text(
                      '${venue.rating}  (${venue.reviewCount} Değerlendirme)',
                      style: context.bodyMedium.copyWith(color: Colors.white),
                    ),
                    context.sizedWidthBoxNormal,
                    Text(
                      '₺' * venue.priceLevel,
                      style: context.bodyMedium.copyWith(color: Colors.white),
                    ),
                    context.sizedWidthBoxNormal,
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.white,
                    ),
                    Flexible(
                      child: Text(
                        venue.location,
                        style: context.bodyMedium.copyWith(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
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

  static Widget _circleButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: context.paddingLow,
        decoration: BoxDecoration(
          color: context.cSurface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: iconColor ?? context.cTextPrimary),
      ),
    );
  }

  static Widget _tag(
    BuildContext context,
    String label, {
    bool filled = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled
            ? context.cSecondary
            : context.cSurface.withValues(alpha: 0.85),
        borderRadius: context.xLowBorderRadius,
      ),
      child: Text(
        label,
        style: context.bodyMedium.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: filled ? Colors.white : context.cTextPrimary,
        ),
      ),
    );
  }
}
