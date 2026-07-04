part of 'preferences_view_model.dart';

class PreferencesState {
  final ViewStatus status;
  final int currentPage;
  final Set<String> selectedAllergens;
  final Set<String> selectedConditions;
  final String? selectedMode;
  final double budget;
  final bool smokingArea;
  final bool alcoholService;
  final String? errorMessage;
  final bool isCompleted;

  const PreferencesState({
    this.status = ViewStatus.initial,
    this.currentPage = 0,
    this.selectedAllergens = const {},
    this.selectedConditions = const {},
    this.selectedMode,
    this.budget = 250,
    this.smokingArea = false,
    this.alcoholService = false,
    this.errorMessage,
    this.isCompleted = false,
  });

  bool get isLastPage => currentPage == 1;

  PreferencesState copyWith({
    ViewStatus? status,
    int? currentPage,
    Set<String>? selectedAllergens,
    Set<String>? selectedConditions,
    String? selectedMode,
    bool clearMode = false,
    double? budget,
    bool? smokingArea,
    bool? alcoholService,
    String? errorMessage,
    bool? isCompleted,
  }) {
    return PreferencesState(
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      selectedAllergens: selectedAllergens ?? this.selectedAllergens,
      selectedConditions: selectedConditions ?? this.selectedConditions,
      selectedMode: clearMode ? null : (selectedMode ?? this.selectedMode),
      budget: budget ?? this.budget,
      smokingArea: smokingArea ?? this.smokingArea,
      alcoholService: alcoholService ?? this.alcoholService,
      errorMessage: errorMessage ?? this.errorMessage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
