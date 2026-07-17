part of 'rating_view_model.dart';

class RatingState {
  final ViewStatus status;
  final List<PendingVisitModel> nearbyVisits;
  final String? selectedVenueId;
  final double starRating;
  final String comment;
  final String? errorMessage;
  final bool isSubmitted;

  const RatingState({
    this.status = ViewStatus.initial,
    this.nearbyVisits = const [],
    this.selectedVenueId,
    this.starRating = 0,
    this.comment = '',
    this.errorMessage,
    this.isSubmitted = false,
  });

  bool get canSubmit => starRating > 0;

  RatingState copyWith({
    ViewStatus? status,
    List<PendingVisitModel>? nearbyVisits,
    String? selectedVenueId,
    bool clearSelection = false,
    double? starRating,
    String? comment,
    String? errorMessage,
    bool? isSubmitted,
  }) {
    return RatingState(
      status: status ?? this.status,
      nearbyVisits: nearbyVisits ?? this.nearbyVisits,
      selectedVenueId: clearSelection
          ? null
          : (selectedVenueId ?? this.selectedVenueId),
      starRating: starRating ?? this.starRating,
      comment: comment ?? this.comment,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}
