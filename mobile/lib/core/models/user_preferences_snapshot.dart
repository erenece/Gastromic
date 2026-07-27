import 'package:gastromic/app/views/view_preferences/repository/model/preferences_model.dart';

class UserPreferencesSnapshot {
  const UserPreferencesSnapshot({
    this.allergens = const [],
    this.conditions = const [],
    this.mode = 'Organik',
    this.budget = 500,
    this.smokingArea = false,
    this.alcoholService = false,
    this.preferencesCompleted = false,
  });

  final List<String> allergens;
  final List<String> conditions;
  final String mode;
  final double budget;
  final bool smokingArea;
  final bool alcoholService;
  final bool preferencesCompleted;

  bool get hasPreferences => preferencesCompleted;

  String get dailyModeSlug {
    const map = {
      'Sporcu': 'sporcu',
      'Vejetaryen': 'vejetaryen',
      'Organik': 'organik',
      'Kaçamak': 'kacamak',
    };
    return map[mode] ?? 'organik';
  }

  factory UserPreferencesSnapshot.fromFirestore(Map<String, dynamic> data) {
    return UserPreferencesSnapshot(
      allergens: _stringList(data['allergens']),
      conditions: _stringList(data['conditions']),
      mode: data['mode'] as String? ?? 'Organik',
      budget: (data['budget'] ?? 500).toDouble(),
      smokingArea: data['smokingArea'] == true,
      alcoholService: data['alcoholService'] == true,
      preferencesCompleted: data['preferencesCompleted'] == true,
    );
  }

  factory UserPreferencesSnapshot.fromModel(PreferencesModel model) {
    return UserPreferencesSnapshot(
      allergens: model.allergens,
      conditions: model.conditions,
      mode: model.mode ?? 'Organik',
      budget: model.budget,
      smokingArea: model.smokingArea,
      alcoholService: model.alcoholService,
      preferencesCompleted: true,
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }
}
