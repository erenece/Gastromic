import 'package:flutter/material.dart';
import 'package:gastromic/app/views/view_rating/repository/model/pending_visit_model.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';
import 'package:gastromic/core/models/gastromic_map_marker.dart';
import 'package:gastromic/core/models/venue_model.dart';
import 'package:gastromic/core/widgets/map_preview_placeholder.dart';
import 'package:gastromic/core/widgets/primary_button.dart';
import 'package:gastromic/core/widgets/venue_image.dart';

part 'home_header_widget.dart';
part 'home_map_card_widget.dart';
part 'home_nearby_wdiget.dart';
part 'home_favorites_widget.dart';
part 'home_active_visit_card_widget.dart';

mixin HomeWidgets {
  final header = HomeHeaderWidget.header;
  final activeVisitCard = HomeActiveVisitCardWidget.activeVisitCard;
  final mapCard = HomeMapCardWidget.mapCard;
  final nearbySection = HomeNearbyWidget.nearbySection;
  final favoritesSection = HomeFavoritesWidget.favoritesSection;
}
