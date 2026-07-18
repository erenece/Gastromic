part of 'operation_view_model.dart';

class OperationState {
  final ViewStatus status;
  final List<MapVenueModel> allVenues;
  final List<MapVenueModel> filteredVenues;
  final double userLat;
  final double userLng;
  final RangeValues priceRange;
  final double busynessThreshold;
  final bool openNowOnly;
  final String? selectedVenueId;
  final String? errorMessage;

  const OperationState({
    this.status = ViewStatus.initial,
    this.allVenues = const [],
    this.filteredVenues = const [],
    this.userLat = 0,
    this.userLng = 0,
    this.priceRange = const RangeValues(0, 3000),
    this.busynessThreshold = 1.0,
    this.openNowOnly = false,
    this.selectedVenueId,
    this.errorMessage,
  });

  MapVenueModel? get selectedVenue {
    if (selectedVenueId == null) return null;
    for (final v in filteredVenues) {
      if (v.id == selectedVenueId) return v;
    }
    return null;
  }

  OperationState copyWith({
    ViewStatus? status,
    List<MapVenueModel>? allVenues,
    List<MapVenueModel>? filteredVenues,
    double? userLat,
    double? userLng,
    RangeValues? priceRange,
    double? busynessThreshold,
    bool? openNowOnly,
    String? selectedVenueId,
    bool clearSelection = false,
    String? errorMessage,
  }) {
    return OperationState(
      status: status ?? this.status,
      allVenues: allVenues ?? this.allVenues,
      filteredVenues: filteredVenues ?? this.filteredVenues,
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
      priceRange: priceRange ?? this.priceRange,
      busynessThreshold: busynessThreshold ?? this.busynessThreshold,
      openNowOnly: openNowOnly ?? this.openNowOnly,
      selectedVenueId: clearSelection
          ? null
          : (selectedVenueId ?? this.selectedVenueId),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
