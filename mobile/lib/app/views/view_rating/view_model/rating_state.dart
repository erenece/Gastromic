part of 'rating_view_model.dart';

class RatingState {
  final ViewStatus status;
  final List<PendingVisitModel> nearbyVisits;
  final List<UserReviewHistoryModel> pastReviews;
  final String? selectedVenueId;
  final double starRating;
  final String comment;
  final String? errorMessage;
  final bool isSubmitted;
  final bool isSubmitting;

  const RatingState({
    this.status = ViewStatus.initial,
    this.nearbyVisits = const [],
    this.pastReviews = const [],
    this.selectedVenueId,
    this.starRating = 0,
    this.comment = '',
    this.errorMessage,
    this.isSubmitted = false,
    this.isSubmitting = false,
  });

  bool get canSubmit => starRating > 0;

  RatingState copyWith({
    ViewStatus? status,
    List<PendingVisitModel>? nearbyVisits,
    List<UserReviewHistoryModel>? pastReviews,
    String? selectedVenueId,
    bool clearSelection = false,
    double? starRating,
    String? comment,
    String? errorMessage,
    bool? isSubmitted,
    bool? isSubmitting,
  }) {
    return RatingState(
      status: status ?? this.status,
      nearbyVisits: nearbyVisits ?? this.nearbyVisits,
      pastReviews: pastReviews ?? this.pastReviews,
      selectedVenueId: clearSelection
          ? null
          : (selectedVenueId ?? this.selectedVenueId),
      starRating: starRating ?? this.starRating,
      comment: comment ?? this.comment,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
