part of 'operation_widgets.dart';

mixin OperationMapWidget {
  static Widget mapArea(
    BuildContext context, {
    required List<MapVenueModel> venues,
    required String? selectedVenueId,
    required ValueChanged<String> onPinTap,
    double userLat = 0,
    double userLng = 0,
  }) {
    final markers = venues
        .where((v) => v.latitude != 0 || v.longitude != 0)
        .map(
          (v) => GastromicMapMarker(
            id: v.id,
            latitude: v.latitude,
            longitude: v.longitude,
            title: v.name,
          ),
        )
        .toList();

    return GastromicGoogleMap(
      latitude: userLat != 0 ? userLat : null,
      longitude: userLng != 0 ? userLng : null,
      zoom: 12,
      markers: markers,
      selectedMarkerId: selectedVenueId,
      interactive: true,
      showMyLocation: true,
      onMarkerTap: onPinTap,
    );
  }
}
