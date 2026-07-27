import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_venue_detail/repository/model/venue_detail_model.dart';
import 'package:gastromic/app/views/view_venue_detail/repository/service/venue_detail_service.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/services/favorites_service.dart';

part 'venue_detail_event.dart';
part 'venue_detail_state.dart';

class VenueDetailViewModel extends Bloc<VenueDetailEvent, VenueDetailState> {
  VenueDetailViewModel() : super(const VenueDetailState()) {
    on<VenueDetailInitialEvent>(_initial);
    on<VenueDetailToggleFavoriteEvent>(_toggleFavorite);
  }

  final VenueDetailService _venueDetailService = VenueDetailService();
  final FavoritesService _favoritesService = FavoritesService();

  FutureOr<void> _initial(
    VenueDetailInitialEvent event,
    Emitter<VenueDetailState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final venue = await _venueDetailService.fetchVenueDetail(event.venueId);
      final isFavorite = await _favoritesService.isFavorite(event.venueId);
      emit(
        state.copyWith(
          status: ViewStatus.success,
          venue: venue,
          isFavorite: isFavorite,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ViewStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  FutureOr<void> _toggleFavorite(
    VenueDetailToggleFavoriteEvent event,
    Emitter<VenueDetailState> emit,
  ) async {
    final venue = state.venue;
    if (venue == null) return;

    try {
      if (state.isFavorite) {
        await _favoritesService.removeFavorite(venue.id);
        emit(state.copyWith(isFavorite: false));
      } else {
        await _favoritesService.addFavoriteFromDetail(
          venueId: venue.id,
          name: venue.name,
          category: venue.category,
          imageUrl: venue.imageUrl,
          rating: venue.rating,
        );
        emit(state.copyWith(isFavorite: true));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
