import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_rating/repository/model/pending_visit_model.dart';
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
  }

  final RatingService _ratingService = RatingService();
  final TextEditingController commentController = TextEditingController();

  FutureOr<void> _initial(
    RatingInitialEvent event,
    Emitter<RatingState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading));

    try {
      final visits = await _ratingService.fetchPendingVisits();
      if (visits.isEmpty) {
        emit(state.copyWith(status: ViewStatus.success, nearbyVisits: []));
        return;
      }
      final position = await _ratingService.currentPosition();
      final nearby = visits
          .where((visit) => _ratingService.isNearby(position, visit))
          .toList();
      emit(state.copyWith(status: ViewStatus.success, nearbyVisits: nearby));
    } catch (e) {
      emit(
        state.copyWith(status: ViewStatus.failure, errorMessage: e.toString()),
      );
    }
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
    if (venueId == null || !state.canSubmit) return;

    emit(state.copyWith(status: ViewStatus.loading));
    try {
      await _ratingService.submitReview(
        venueId: venueId,
        rating: state.starRating,
        comment: commentController.text.trim(),
      );
      commentController.clear();
      final remaining = state.nearbyVisits
          .where((v) => v.venueId != venueId)
          .toList();
      emit(
        state.copyWith(
          status: ViewStatus.success,
          nearbyVisits: remaining,
          clearSelection: true,
          starRating: 0,
          comment: '',
          isSubmitted: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ViewStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  @override
  Future<void> close() {
    commentController.dispose();
    return super.close();
  }
}
