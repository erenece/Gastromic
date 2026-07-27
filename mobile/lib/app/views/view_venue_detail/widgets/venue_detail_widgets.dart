import 'package:flutter/material.dart';
import 'package:gastromic/app/views/view_venue_detail/repository/model/venue_detail_model.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';
import 'package:gastromic/core/models/dish_model.dart';
import 'package:gastromic/core/models/gastromic_map_marker.dart';
import 'package:gastromic/core/utils/ai_summary_highlighter.dart';
import 'package:gastromic/core/utils/opening_hours_display.dart';
import 'package:gastromic/core/widgets/gastromic_google_map.dart';
import 'package:gastromic/core/widgets/venue_image.dart';

part 'venue_detail_hero_widget.dart';
part 'venue_detail_ai_summary_widget.dart';
part 'venue_detail_features_widget.dart';
part 'venue_detail_dishes_widget.dart';
part 'venue_detail_reviews_widget.dart';
part 'venue_detail_location_widget.dart';

mixin VenueDetailWidgets {
  final hero = VenueDetailHeroWidget.hero;
  final aiSummary = VenueDetailAiSummaryWidget.aiSummary;
  final features = VenueDetailFeaturesWidget.features;
  final dishes = VenueDetailDishesWidget.dishes;
  final reviews = VenueDetailReviewsWidget.reviews;
  final locationSection = VenueDetailLocationWidget.locationSection;
}
