import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_rating/repository/model/pending_visit_model.dart';
import 'package:gastromic/app/views/view_rating/repository/model/user_review_history_model.dart';
import 'package:gastromic/app/views/view_rating/repository/service/rating_service.dart';
import 'package:gastromic/core/enums/view_status.dart';

part 'rating_event.dart';
part 'rating_state.dart';

class RatingViewModel extends Bloc<RatingEvent, RatingState> {
  RatingViewModel() : super(const RatingState()) {
    on<RatingInitialEvent>(_initial);
    on<RatingVenueSelectedEvent>(_venueSelected);
    on<RatingFormClosedEvent>(_formClosed);
    on<RatingStarChangedEvent>(_starChanged);
    on<RatingCommentChangedEvent>(_commentChanged);
    on<RatingSubmittedEvent>(_submit);
    on<RatingProximityCheckEvent>(_proximityCheck);
  }

  final RatingService _ratingService = RatingService();
  final TextEditingController commentController = TextEditingController();

  FutureOr<void> _initial(
    RatingInitialEvent event,
    Emitter<RatingState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading, isSubmitted: false));

    try {
      final results = await Future.wait([
        _ratingService.fetchPendingVisits(),
        _ratingService.fetchReviewHistory(),
      ]);
      final visits = results[0] as List<PendingVisitModel>;
      final history = results[1] as List<UserReviewHistoryModel>;
      final nearby = await _filterNearby(visits);

      emit(
        state.copyWith(
          status: ViewStatus.success,
          nearbyVisits: nearby,
          pastReviews: history,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ViewStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  FutureOr<void> _proximityCheck(
    RatingProximityCheckEvent event,
    Emitter<RatingState> emit,
  ) async {
    try {
      final visits = await _ratingService.fetchPendingVisits();
      final nearby = await _filterNearby(visits);
      final selectedId = state.selectedVenueId;
      final clearSelection = selectedId != null &&
          !nearby.any((visit) => visit.venueId == selectedId);
      emit(
        state.copyWith(
          nearbyVisits: nearby,
          clearSelection: clearSelection,
        ),
      );
    } catch (_) {}
  }

  Future<List<PendingVisitModel>> _filterNearby(
    List<PendingVisitModel> visits,
  ) async {
    if (visits.isEmpty) return const [];

    final position = await _ratingService.currentPosition();
    if (position == null) return const [];

    return visits
        .where((visit) => _ratingService.isNearby(position, visit))
        .toList();
  }

  FutureOr<void> _venueSelected(
    RatingVenueSelectedEvent event,
    Emitter<RatingState> emit,
  ) {
    commentController.clear();
    emit(
      state.copyWith(
        selectedVenueId: event.venueId,
        starRating: 0,
        comment: '',
        isSubmitted: false,
      ),
    );
  }

  FutureOr<void> _formClosed(
    RatingFormClosedEvent event,
    Emitter<RatingState> emit,
  ) {
    commentController.clear();
    emit(state.copyWith(clearSelection: true, starRating: 0, comment: ''));
  }

  FutureOr<void> _starChanged(
    RatingStarChangedEvent event,
    Emitter<RatingState> emit,
  ) {
    emit(state.copyWith(starRating: event.rating));
  }

  FutureOr<void> _commentChanged(
    RatingCommentChangedEvent event,
    Emitter<RatingState> emit,
  ) {
    emit(state.copyWith(comment: event.comment));
  }

  FutureOr<void> _submit(
    RatingSubmittedEvent event,
    Emitter<RatingState> emit,
  ) async {
    final venueId = state.selectedVenueId;
    if (venueId == null || !state.canSubmit || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true));
    try {
      PendingVisitModel? selected;
      for (final visit in state.nearbyVisits) {
        if (visit.venueId == venueId) {
          selected = visit;
          break;
        }
      }
      await _ratingService.submitReview(
        venueId: venueId,
        venueName: selected?.venueName ?? 'Mekan',
        rating: state.starRating,
        comment: commentController.text.trim(),
      );
      commentController.clear();
      final remaining = state.nearbyVisits
          .where((v) => v.venueId != venueId)
          .toList();
      final history = await _ratingService.fetchReviewHistory();
      emit(
        state.copyWith(
          status: ViewStatus.success,
          nearbyVisits: remaining,
          pastReviews: history,
          clearSelection: true,
          starRating: 0,
          comment: '',
          isSubmitting: false,
          isSubmitted: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    commentController.dispose();
    return super.close();
  }
}
