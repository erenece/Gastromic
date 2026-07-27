import 'package:flutter/material.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';
import 'package:gastromic/core/models/gastromic_map_marker.dart';
import 'package:gastromic/core/models/venue_model.dart';
import 'package:gastromic/core/widgets/gastromic_google_map.dart';
import 'package:gastromic/core/widgets/venue_image.dart';

part 'home_header_widget.dart';
part 'home_map_card_widget.dart';
part 'home_nearby_wdiget.dart';
part 'home_favorites_widget.dart';

mixin HomeWidgets {
  final header = HomeHeaderWidget.header;
  final mapCard = HomeMapCardWidget.mapCard;
  final nearbySection = HomeNearbyWidget.nearbySection;
  final favoritesSection = HomeFavoritesWidget.favoritesSection;
}
