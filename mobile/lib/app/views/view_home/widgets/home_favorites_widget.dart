part of 'home_widgets.dart';

mixin HomeFavoritesWidget {
  static Widget favoritesSection(
    BuildContext context, {
    required List<VenueModel> venues,
    required ValueChanged<VenueModel> onVenueTap,
  }) {
    if (venues.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Favori Yerler', style: context.titleLarge),
        context.sizedHeightBoxNormal,
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: venues.map((venue) {
            return GestureDetector(
              onTap: () => onVenueTap(venue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: context.mediumBorderRadius,
                      child: venue.imageUrl.isNotEmpty
                          ? Image.network(
                              venue.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: double.infinity,
                              color: context.cPrimary.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.restaurant,
                                color: context.cPrimary.withValues(alpha: 0.3),
                              ),
                            ),
                    ),
                  ),
                  context.sizedHeightBoxLow,
                  Text(
                    venue.name,
                    style: context.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    venue.categoryLine,
                    style: context.bodyMedium.copyWith(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
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
