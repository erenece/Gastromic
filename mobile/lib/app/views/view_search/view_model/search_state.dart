part of 'search_view_model.dart';

class SearchState {
  final ViewStatus status;
  final String query;
  final List<VenueModel> results;
  final List<String> recentSearches;
  final List<VenueModel> frequentVenues;
  final String? errorMessage;

  const SearchState({
    this.status = ViewStatus.initial,
    this.query = '',
    this.results = const [],
    this.recentSearches = const [],
    this.frequentVenues = const [],
    this.errorMessage,
  });

  bool get isSearching => query.isNotEmpty;

  SearchState copyWith({
    ViewStatus? status,
    String? query,
    List<VenueModel>? results,
    List<String>? recentSearches,
    List<VenueModel>? frequentVenues,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      frequentVenues: frequentVenues ?? this.frequentVenues,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
