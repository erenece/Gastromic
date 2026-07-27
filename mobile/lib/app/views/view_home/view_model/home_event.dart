part of 'home_view_model.dart';

abstract class HomeEvent {}

class HomeInitialEvent extends HomeEvent {}

class HomeRefreshEvent extends HomeEvent {}

class HomeProximityCheckEvent extends HomeEvent {}
