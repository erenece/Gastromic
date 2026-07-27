import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_search/repository/service/search_service.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/models/venue_model.dart';
import 'package:gastromic/core/utils/debounce_transformer.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchViewModel extends Bloc<SearchEvent, SearchState> {
  SearchViewModel() : super(const SearchState()) {
    on<SearchInitialEvent>(_initial);
    on<SearchQueryChangedEvent>(
      _queryChanged,
      transformer: debounceTransformer(const Duration(milliseconds: 600)),
    );
    on<SearchSubmittedEvent>(_submitted);
    on<SearchVenueSelectedEvent>(_venueSelected);
    on<SearchRecentTappedEvent>(_recentTapped);
    on<SearchClearRecentEvent>(_clearRecent);
  }

  final SearchService _searchService = SearchService();
  final TextEditingController searchController = TextEditingController();

  FutureOr<void> _initial(
    SearchInitialEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      await _searchService.sanitizeRecentSearches();
      final recent = _searchService.getRecentSearches();
      final frequent = await _searchService.fetchFrequentVenues();
      unawaited(_searchService.warmVenuePool());
      emit(
        state.copyWith(
          status: ViewStatus.success,
          recentSearches: recent,
          frequentVenues: frequent,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ViewStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  FutureOr<void> _queryChanged(
    SearchQueryChangedEvent event,
    Emitter<SearchState> emit,
  ) async {
    await _runSearch(
      emit,
      query: event.query,
      saveRecent: false,
    );
  }

  FutureOr<void> _submitted(
    SearchSubmittedEvent event,
    Emitter<SearchState> emit,
  ) async {
    await _runSearch(
      emit,
      query: event.query,
      saveRecent: true,
    );
  }

  FutureOr<void> _venueSelected(
    SearchVenueSelectedEvent event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.length < 3) return;
    await _searchService.addRecentSearch(query);
    emit(state.copyWith(recentSearches: _searchService.getRecentSearches()));
  }

  Future<void> _runSearch(
    Emitter<SearchState> emit, {
    required String query,
    required bool saveRecent,
  }) async {
    final trimmed = query.trim();
    emit(state.copyWith(query: trimmed, isSearching: trimmed.isNotEmpty));

    if (trimmed.isEmpty) {
      emit(
        state.copyWith(
          results: [],
          status: ViewStatus.success,
          isSearching: false,
        ),
      );
      return;
    }

    if (trimmed.length < 2) {
      emit(
        state.copyWith(
          results: [],
          status: ViewStatus.success,
          isSearching: true,
        ),
      );
      return;
    }

    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final results = await _searchService.searchVenues(trimmed);
      if (state.query.trim() != trimmed) return;

      if (saveRecent) {
        await _searchService.addRecentSearch(trimmed);
      }

      emit(
        state.copyWith(
          status: ViewStatus.success,
          results: results,
          recentSearches: _searchService.getRecentSearches(),
        ),
      );
    } catch (e) {
      if (state.query.trim() != trimmed) return;
      emit(
        state.copyWith(status: ViewStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  FutureOr<void> _recentTapped(
    SearchRecentTappedEvent event,
    Emitter<SearchState> emit,
  ) async {
    searchController.text = event.query;
    add(SearchSubmittedEvent(event.query));
  }

  FutureOr<void> _clearRecent(
    SearchClearRecentEvent event,
    Emitter<SearchState> emit,
  ) async {
    await _searchService.clearRecentSearches();
    emit(state.copyWith(recentSearches: []));
  }

  @override
  Future<void> close() {
    searchController.dispose();
    return super.close();
  }
}
