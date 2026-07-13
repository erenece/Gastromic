import 'package:flutter/material.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';
import 'package:gastromic/core/models/venue_model.dart';

part 'search_bar_widget.dart';
part 'search_recent_widget.dart';
part 'search_results_widget.dart';
part 'search_venue_card_widget.dart';

mixin SearchWidgets {
  final searchBar = SearchBarWidget.searchBar;
  final recentSection = SearchRecentWidget.recentSection;
  final venueCard = SearchVenueCardWidget.venueCard;
  final resultsList = SearchResultsWidget.resultsList;
  final frequentGrid = SearchResultsWidget.frequentGrid;
}
