part of 'venue_detail_view_model.dart';

abstract class VenueDetailEvent {}

class VenueDetailInitialEvent extends VenueDetailEvent {
  final String venueId;
  VenueDetailInitialEvent(this.venueId);
}

class VenueDetailToggleFavoriteEvent extends VenueDetailEvent {}
