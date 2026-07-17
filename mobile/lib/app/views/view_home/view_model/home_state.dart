part of 'home_view_model.dart';

class HomeState {
  final ViewStatus status;
  final String locationName;
  final List<VenueModel> nearbyVenues;
  final List<VenueModel> favoriteVenues;
  final String? errorMessage;

  const HomeState({
    this.status = ViewStatus.initial,
    this.locationName = '',
    this.nearbyVenues = const [],
    this.favoriteVenues = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    ViewStatus? status,
    String? locationName,
    List<VenueModel>? nearbyVenues,
    List<VenueModel>? favoriteVenues,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      locationName: locationName ?? this.locationName,
      nearbyVenues: nearbyVenues ?? this.nearbyVenues,
      favoriteVenues: favoriteVenues ?? this.favoriteVenues,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
