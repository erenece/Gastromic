part of 'rating_view_model.dart';

abstract class RatingEvent {}

class RatingInitialEvent extends RatingEvent {}

class RatingVenueSelectedEvent extends RatingEvent {
  final String venueId;
  RatingVenueSelectedEvent(this.venueId);
}

class RatingFormClosedEvent extends RatingEvent {}

class RatingStarChangedEvent extends RatingEvent {
  final double rating;
  RatingStarChangedEvent(this.rating);
}

class RatingCommentChangedEvent extends RatingEvent {
  final String comment;
  RatingCommentChangedEvent(this.comment);
}

class RatingSubmittedEvent extends RatingEvent {}
