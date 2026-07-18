import 'package:flutter/material.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';
import 'package:gastromic/core/models/map_venue_model.dart';

part 'operation_map_wdiget.dart';
part 'operation_venue_card_widget.dart';
part 'operation_filters_widget.dart';

mixin OperationWidgets {
  final mapArea = OperationMapWidget.mapArea;
  final venueCard = OperationVenueCardWidget.venueCard;
  final filters = OperationFiltersWidget.filters;
}
