part of 'search_widgets.dart';

mixin SearchResultsWidget {
  static Widget frequentGrid(
    BuildContext context, {
    required List<VenueModel> venues,
    required ValueChanged<VenueModel> onVenueTap,
  }) {
    if (venues.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sık Ziyaret Edilen Yerler', style: context.titleLarge),
        context.sizedHeightBoxNormal,
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: venues.map((venue) {
            return SearchVenueCardWidget.venueCard(
              context,
              venue: venue,
              onTap: () => onVenueTap(venue),
            );
          }).toList(),
        ),
      ],
    );
  }

  static Widget resultsList(
    BuildContext context, {
    required List<VenueModel> results,
    required ValueChanged<VenueModel> onVenueTap,
  }) {
    if (results.isEmpty) {
      return Padding(
        padding: context.paddingHigh,
        child: Center(
          child: Text('Sonuç bulunamadı', style: context.bodyMedium),
        ),
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: results.map((venue) {
        return SearchVenueCardWidget.venueCard(
          context,
          venue: venue,
          onTap: () => onVenueTap(venue),
        );
      }).toList(),
    );
  }
}
