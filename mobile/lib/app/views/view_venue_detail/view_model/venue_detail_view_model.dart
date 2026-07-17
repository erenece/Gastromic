import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_venue_detail/repository/model/venue_detail_model.dart';
import 'package:gastromic/app/views/view_venue_detail/repository/service/venue_detail_service.dart';
import 'package:gastromic/core/enums/view_status.dart';

part 'venue_detail_event.dart';
part 'venue_detail_state.dart';

class VenueDetailViewModel extends Bloc<VenueDetailEvent, VenueDetailState> {
  VenueDetailViewModel() : super(const VenueDetailState()) {
    on<VenueDetailInitialEvent>(_initial);
    on<VenueDetailToggleFavoriteEvent>(_toggleFavorite);
  }

  final VenueDetailService _venueDetailService = VenueDetailService();

  FutureOr<void> _initial(
    VenueDetailInitialEvent event,
    Emitter<VenueDetailState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final venue = await _venueDetailService.fetchVenueDetail(event.venueId);
      emit(state.copyWith(status: ViewStatus.success, venue: venue));
    } catch (e) {
      emit(
        state.copyWith(status: ViewStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  FutureOr<void> _toggleFavorite(
    VenueDetailToggleFavoriteEvent event,
    Emitter<VenueDetailState> emit,
  ) {
    emit(state.copyWith(isFavorite: !state.isFavorite));
  }
}
