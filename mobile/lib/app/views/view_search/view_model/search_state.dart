part of 'search_view_model.dart';

class SearchState {
  final ViewStatus status;
  final String query;
  final bool isSearching;
  final List<VenueModel> results;
  final List<String> recentSearches;
  final List<VenueModel> frequentVenues;
  final String? errorMessage;

  const SearchState({
    this.status = ViewStatus.initial,
    this.query = '',
    this.isSearching = false,
    this.results = const [],
    this.recentSearches = const [],
    this.frequentVenues = const [],
    this.errorMessage,
  });

  SearchState copyWith({
    ViewStatus? status,
    String? query,
    bool? isSearching,
    List<VenueModel>? results,
    List<String>? recentSearches,
    List<VenueModel>? frequentVenues,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      frequentVenues: frequentVenues ?? this.frequentVenues,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
