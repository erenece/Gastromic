part of 'operation_view_model.dart';

abstract class OperationEvent {}

class OperationInitialEvent extends OperationEvent {}

class OperationPriceRangeChangedEvent extends OperationEvent {
  final RangeValues priceRange;
  OperationPriceRangeChangedEvent(this.priceRange);
}

class OperationBusynessChangedEvent extends OperationEvent {
  final double busyness;
  OperationBusynessChangedEvent(this.busyness);
}

class OperationOpenNowToggledEvent extends OperationEvent {}

class OperationVenueSelectedEvent extends OperationEvent {
  final String venueId;
  OperationVenueSelectedEvent(this.venueId);
}

class OperationCardClosedEvent extends OperationEvent {}
