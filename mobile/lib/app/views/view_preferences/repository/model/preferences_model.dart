class PreferencesModel {
  final List<String> allergens;
  final List<String> conditions;
  final String? mode;
  final double budget;
  final bool smokingArea;
  final bool alcoholService;

  PreferencesModel({
    required this.allergens,
    required this.conditions,
    required this.mode,
    required this.budget,
    required this.smokingArea,
    required this.alcoholService,
  });

  Map<String, dynamic> toMap() {
    return {
      'allergens': allergens,
      'conditions': conditions,
      'mode': mode,
      'budget': budget,
      'smokingArea': smokingArea,
      'alcoholService': alcoholService,
      'preferencesCompleted': true,
    };
  }
}
