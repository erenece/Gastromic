import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_operation/repository/service/operation_service.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/models/map_venue_model.dart';

part 'operation_event.dart';
part 'opeartion_state.dart';

class OperationViewModel extends Bloc<OperationEvent, OperationState> {
  OperationViewModel() : super(const OperationState()) {
    on<OperationInitialEvent>(_initial);
    on<OperationPriceRangeChangedEvent>(_priceChanged);
    on<OperationBusynessChangedEvent>(_busynessChanged);
    on<OperationOpenNowToggledEvent>(_openNowToggled);
    on<OperationVenueSelectedEvent>(_venueSelected);
    on<OperationCardClosedEvent>(_cardClosed);
  }

  final OperationService _service = OperationService();

  FutureOr<void> _initial(
    OperationInitialEvent event,
    Emitter<OperationState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final venues = await _service.fetchVenues();

      double lat = 0, lng = 0;
      try {
        final pos = await _service.currentPosition();
        lat = pos.latitude;
        lng = pos.longitude;
      } catch (_) {}

      emit(
        state.copyWith(
          status: ViewStatus.success,
          allVenues: venues,
          filteredVenues: _applyFilters(venues, state),
          userLat: lat,
          userLng: lng,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ViewStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  List<MapVenueModel> _applyFilters(
    List<MapVenueModel> venues,
    OperationState s,
  ) {
    return venues.where((v) {
      final priceOk =
          v.price >= s.priceRange.start && v.price <= s.priceRange.end;
      final busyOk = v.busyness <= s.busynessThreshold;
      final openOk = !s.openNowOnly || v.isOpenNow;
      return priceOk && busyOk && openOk;
    }).toList();
  }

  FutureOr<void> _priceChanged(
    OperationPriceRangeChangedEvent event,
    Emitter<OperationState> emit,
  ) {
    final next = state.copyWith(priceRange: event.priceRange);
    emit(next.copyWith(filteredVenues: _applyFilters(state.allVenues, next)));
  }

  FutureOr<void> _busynessChanged(
    OperationBusynessChangedEvent event,
    Emitter<OperationState> emit,
  ) {
    final next = state.copyWith(busynessThreshold: event.busyness);
    emit(next.copyWith(filteredVenues: _applyFilters(state.allVenues, next)));
  }

  FutureOr<void> _openNowToggled(
    OperationOpenNowToggledEvent event,
    Emitter<OperationState> emit,
  ) {
    final next = state.copyWith(openNowOnly: !state.openNowOnly);
    emit(next.copyWith(filteredVenues: _applyFilters(state.allVenues, next)));
  }

  FutureOr<void> _venueSelected(
    OperationVenueSelectedEvent event,
    Emitter<OperationState> emit,
  ) {
    emit(state.copyWith(selectedVenueId: event.venueId));
  }

  FutureOr<void> _cardClosed(
    OperationCardClosedEvent event,
    Emitter<OperationState> emit,
  ) {
    emit(state.copyWith(clearSelection: true));
  }
}
