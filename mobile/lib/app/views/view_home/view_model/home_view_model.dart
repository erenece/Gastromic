import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_home/repository/service/home_service.dart';
import 'package:gastromic/app/views/view_rating/repository/model/pending_visit_model.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/models/venue_model.dart';
import 'package:gastromic/core/services/pending_visit_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeViewModel extends Bloc<HomeEvent, HomeState> {
  HomeViewModel() : super(const HomeState()) {
    on<HomeInitialEvent>(_initial);
    on<HomeRefreshEvent>(_refresh);
    on<HomeProximityCheckEvent>(_proximityCheck);
  }

  final HomeService _homeService = HomeService();
  final PendingVisitService _pendingVisitService = PendingVisitService();

  FutureOr<void> _initial(
    HomeInitialEvent event,
    Emitter<HomeState> emit,
  ) async {
    await _loadHomeData(emit, showLoading: true);
  }

  FutureOr<void> _refresh(
    HomeRefreshEvent event,
    Emitter<HomeState> emit,
  ) async {
    await _loadHomeData(emit, showLoading: false);
  }

  FutureOr<void> _proximityCheck(
    HomeProximityCheckEvent event,
    Emitter<HomeState> emit,
  ) async {
    final visit = await _pendingVisitService.findNearbyActiveVisit();
    emit(
      state.copyWith(
        activeNearbyVisit: visit,
        clearActiveVisit: visit == null,
      ),
    );
  }

  Future<void> _loadHomeData(
    Emitter<HomeState> emit, {
    required bool showLoading,
  }) async {
    if (showLoading) {
      emit(state.copyWith(status: ViewStatus.loading));
    }
    try {
      final prefs = await _homeService.loadPreferences();
      final position = await _homeService.fetchCurrentPosition();
      final lat = position?.lat ?? 0;
      final lng = position?.lng ?? 0;

      final nearby = await _homeService.fetchNearbyVenues(
        userLat: lat,
        userLng: lng,
        prefs: prefs,
      );
      final favorites = await _homeService.fetchFavoriteVenues(prefs: prefs);

      String location;
      try {
        location = await _homeService.fetchLocationName(lat: lat, lng: lng);
      } catch (_) {
        location = lat != 0 || lng != 0 ? 'Konum alınamadı' : 'Konum izni gerekli';
      }

      PendingVisitModel? activeVisit;
      try {
        activeVisit = await _pendingVisitService.findNearbyActiveVisit();
      } catch (_) {}

      emit(
        state.copyWith(
          status: ViewStatus.success,
          locationName: location,
          userLat: lat,
          userLng: lng,
          nearbyVenues: nearby,
          favoriteVenues: favorites,
          activeNearbyVisit: activeVisit,
          clearActiveVisit: activeVisit == null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ViewStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
