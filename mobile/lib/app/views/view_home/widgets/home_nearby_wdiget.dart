part of 'home_widgets.dart';

mixin HomeNearbyWidget {
  static Widget nearbySection(
    BuildContext context, {
    required List<VenueModel> venues,
    required ValueChanged<VenueModel> onVenueTap,
    required VoidCallback onSeeAll,
  }) {
    if (venues.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Çevrenizdeki Sık Gidilen Yerler',
                style: context.titleLarge,
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'Tümünü Gör',
                style: context.bodyMedium.copyWith(color: context.cPrimary),
              ),
            ),
          ],
        ),
        context.sizedHeightBoxNormal,
        SizedBox(
          height: context.dynamicHeight(0.2),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: venues.length,
            separatorBuilder: (_, __) => context.sizedWidthBoxLow2x,
            itemBuilder: (context, index) {
              final venue = venues[index];
              return GestureDetector(
                onTap: () => onVenueTap(venue),
                child: SizedBox(
                  width: context.dynamicWidth(0.6),
                  child: ClipRRect(
                    borderRadius: context.normalBorderRadius,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        venue.imageUrl.isNotEmpty
                            ? Image.network(venue.imageUrl, fit: BoxFit.cover)
                            : Container(
                                color: context.cPrimary.withValues(alpha: 0.1),
                              ),
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
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      venue.name,
                                      style: context.titleLarge.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      venue.categoryLine,
                                      style: context.bodyMedium.copyWith(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: context.cSurface,
                                  borderRadius: context.xLowBorderRadius,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 12,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      venue.rating.toStringAsFixed(1),
                                      style: context.bodyMedium.copyWith(
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
