import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_home/repository/service/home_service.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/models/venue_model.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeViewModel extends Bloc<HomeEvent, HomeState> {
  HomeViewModel() : super(const HomeState()) {
    on<HomeInitialEvent>(_initial);
  }

  final HomeService _homeService = HomeService();

  FutureOr<void> _initial(
    HomeInitialEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final nearby = await _homeService.fetchNearbyVenues();
      final favorites = await _homeService.fetchFavoriteVenues();

      String location;
      try {
        location = await _homeService.fetchLocationName();
      } catch (_) {
        location = 'Konum alınamadı';
      }

      emit(
        state.copyWith(
          status: ViewStatus.success,
          locationName: location,
          nearbyVenues: nearby,
          favoriteVenues: favorites,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ViewStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
