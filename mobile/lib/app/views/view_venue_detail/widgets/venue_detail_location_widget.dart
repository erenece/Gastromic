part of 'venue_detail_widgets.dart';

mixin VenueDetailLocationWidget {
  static Widget locationSection(
    BuildContext context, {
    required VenueDetailModel venue,
  }) {
    final hasCoords = venue.latitude != 0 || venue.longitude != 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: context.normalBorderRadius,
          child: SizedBox(
            height: context.dynamicHeight(0.18),
            width: double.infinity,
            child: hasCoords
                ? GastromicGoogleMap(
                    latitude: venue.latitude,
                    longitude: venue.longitude,
                    zoom: 15,
                    markers: [
                      GastromicMapMarker(
                        id: venue.id,
                        latitude: venue.latitude,
                        longitude: venue.longitude,
                        title: venue.name,
                      ),
                    ],
                    interactive: false,
                    showMyLocation: false,
                    liteMode: true,
                  )
                : Container(
                    color: context.cPrimary.withValues(alpha: 0.08),
                    child: Center(
                      child: Icon(
                        Icons.map_outlined,
                        size: 40,
                        color: context.cPrimary.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
          ),
        ),
        context.sizedHeightBoxNormal,
        Text(
          venue.name,
          style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        context.sizedHeightBoxLow,
        Text(venue.address, style: context.bodyMedium),
        context.sizedHeightBoxNormal,
        _infoRow(
          context,
          Icons.access_time,
          'Çalışma Saatleri',
          venue.workingHours,
        ),
        context.sizedHeightBoxLow,
        _infoRow(context, Icons.phone_outlined, 'Telefon', venue.phone),
      ],
    );
  }

  static Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: context.cPrimary),
            context.sizedWidthBoxLow,
            Text(label, style: context.bodyMedium),
          ],
        ),
        Text(
          value,
          style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
