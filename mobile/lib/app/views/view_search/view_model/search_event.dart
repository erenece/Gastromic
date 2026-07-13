part of "search_view_model.dart";

abstract class SearchEvent {}

class SearchInitialEvent extends SearchEvent {}

class SearchQueryChangedEvent extends SearchEvent {
  final String query;
  SearchQueryChangedEvent(this.query);
}

class SearchRecentTappedEvent extends SearchEvent {
  final String query;
  SearchRecentTappedEvent(this.query);
}

class SearchClearRecentEvent extends SearchEvent {}
