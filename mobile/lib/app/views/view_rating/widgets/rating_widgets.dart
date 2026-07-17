import 'package:flutter/material.dart';

import 'package:gastromic/app/views/view_rating/repository/model/pending_visit_model.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';
import 'package:gastromic/core/widgets/primary_button.dart';

part 'rating_venue_card_widget.dart';
part 'rating_form_widget.dart';
part 'rating_empty_widget.dart';

mixin RatingWidgets {
  final venueCard = RatingVenueCardWidget.venueCard;
  final ratingForm = RatingFormWidget.ratingForm;
  final emptyState = RatingEmptyWidget.emptyState;
}
