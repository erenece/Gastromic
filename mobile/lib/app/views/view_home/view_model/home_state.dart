part of 'home_view_model.dart';

class HomeState {
  final ViewStatus status;
  final String locationName;
  final double userLat;
  final double userLng;
  final List<VenueModel> nearbyVenues;
  final List<VenueModel> favoriteVenues;
  final String? errorMessage;

  const HomeState({
    this.status = ViewStatus.initial,
    this.locationName = '',
    this.userLat = 0,
    this.userLng = 0,
    this.nearbyVenues = const [],
    this.favoriteVenues = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    ViewStatus? status,
    String? locationName,
    double? userLat,
    double? userLng,
    List<VenueModel>? nearbyVenues,
    List<VenueModel>? favoriteVenues,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      locationName: locationName ?? this.locationName,
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
      nearbyVenues: nearbyVenues ?? this.nearbyVenues,
      favoriteVenues: favoriteVenues ?? this.favoriteVenues,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
