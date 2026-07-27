part of 'venue_detail_widgets.dart';

mixin VenueDetailLocationWidget {
  static Widget locationSection(
    BuildContext context, {
    required VenueDetailModel venue,
  }) {
    final hasCoords = venue.latitude != 0 || venue.longitude != 0;
    final todayHours = OpeningHoursDisplay.forToday(
      openingHoursWeek: venue.openingHoursWeek,
      workingHoursFallback: venue.workingHours,
      isOpenNow: venue.isOpenNow,
    );

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
        _hoursRow(context, todayHours, venue.isOpenNow),
      ],
    );
  }

  static Widget _hoursRow(
    BuildContext context,
    String todayHours,
    bool? isOpenNow,
  ) {
    final lower = todayHours.toLowerCase();
    final openColor = lower.contains('kapalı')
        ? const Color(0xFFD32F2F)
        : isOpenNow == true
        ? const Color(0xFF2E7D32)
        : isOpenNow == false
        ? const Color(0xFFD32F2F)
        : context.cTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: context.cPrimary),
            context.sizedWidthBoxLow,
            Text('Çalışma Saatleri', style: context.bodyMedium),
          ],
        ),
        context.sizedHeightBoxLow,
        Text(
          todayHours,
          style: context.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: openColor,
          ),
        ),
      ],
    );
  }
}
