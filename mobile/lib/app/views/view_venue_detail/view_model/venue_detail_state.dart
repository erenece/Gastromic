part of 'venue_detail_view_model.dart';

class VenueDetailState {
  final ViewStatus status;
  final VenueDetailModel? venue;
  final bool isFavorite;
  final String? errorMessage;

  const VenueDetailState({
    this.status = ViewStatus.initial,
    this.venue,
    this.isFavorite = false,
    this.errorMessage,
  });

  VenueDetailState copyWith({
    ViewStatus? status,
    VenueDetailModel? venue,
    bool? isFavorite,
    String? errorMessage,
  }) {
    return VenueDetailState(
      status: status ?? this.status,
      venue: venue ?? this.venue,
      isFavorite: isFavorite ?? this.isFavorite,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
