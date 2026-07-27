import 'package:gastromic/core/models/user_preferences_snapshot.dart';

/// Firestore mekan dokümanından tercih filtrelemesi için minimum alan seti.
class VenueFilterData {
  const VenueFilterData({
    required this.name,
    required this.category,
    this.types = '',
    this.price = 0,
    this.priceLevel = 2,
  });

  final String name;
  final String category;
  final String types;
  final double price;
  final int priceLevel;

  factory VenueFilterData.fromMap(Map<String, dynamic> map) {
    return VenueFilterData(
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      types: map['types']?.toString() ?? '',
      price: (map['price'] ?? 0).toDouble(),
      priceLevel: ((map['priceLevel'] ?? 2) as num).toInt(),
    );
  }

  String get haystack => '$name $category $types'.toLowerCase();
}

class VenuePreferenceFilter {
  VenuePreferenceFilter._();

  static const _budgetVetoFactor = 1.5;

  static const _sensitivityMap = {
    'laktoz intoleransı': ['süt', 'peynir', 'tereyağı', 'krema'],
    'çölyak': ['buğday', 'gluten', 'arpa', 'çavdar'],
    'gluten hassasiyeti': ['buğday', 'gluten'],
    'fruktoz intoleransı': ['bal', 'yüksek fruktozlu şurup'],
    'diyabet': ['şeker', 'şerbet'],
    'gut': ['sakatat'],
    'hipertansiyon': ['aşırı tuz'],
  };

  static const _modeCategories = {
    'sporcu': ['protein bowl', 'ızgara', 'salata', 'sağlıklı'],
    'vejetaryen': ['vejetaryen', 'vegan', 'meze', 'sebze'],
    'organik': ['organik', 'çiftlik', 'farm-to-table', 'kahvaltı'],
    'kacamak': ['burger', 'tatlı', 'pizza', 'sokak lezzeti'],
  };

  static const _allergenKeywords = {
    'süt': ['süt', 'sütlü', 'milk', 'dairy', 'ice cream', 'dondurma', 'yoğurt'],
    'yumurta': ['yumurta', 'egg', 'omlet'],
    'buğday': ['buğday', 'wheat', 'bakery', 'börek', 'pide', 'pizza', 'pasta', 'ekmek'],
    'balık': ['balık', 'fish', 'seafood', 'deniz'],
    'deniz ürünleri': ['deniz', 'seafood', 'balık', 'karides', 'midye'],
    'soya': ['soya', 'soy'],
    'susam': ['susam', 'sesame'],
    'yer fıstığı': ['fıstık', 'peanut'],
    'kuruyemiş': ['kuruyemiş', 'nut', 'badem', 'ceviz'],
  };

  static const _alcoholTypes = {
    'bar',
    'cocktail_bar',
    'wine_bar',
    'pub',
    'night_club',
    'brewery',
  };

  static const _smokingKeywords = ['sigara', 'smoking', 'nargile', 'hookah', 'shisha'];

  static List<T> apply<T>(
    List<T> venues,
    UserPreferencesSnapshot prefs,
    VenueFilterData Function(T item) toFilterData,
  ) {
    if (!prefs.hasPreferences) return venues;

    final avoid = _buildAvoidList(prefs);
    final modeKeywords = _modeCategories[prefs.dailyModeSlug] ?? const [];

    return venues.where((venue) {
      final data = toFilterData(venue);
      if (_hasAllergenRisk(data, avoid)) return false;
      if (_isOverBudget(data, prefs.budget)) return false;
      if (!_matchesMode(data, modeKeywords)) return false;
      if (!_matchesAmenities(data, prefs)) return false;
      return true;
    }).toList();
  }

  static List<String> _buildAvoidList(UserPreferencesSnapshot prefs) {
    final avoid = prefs.allergens.map((a) => a.trim().toLowerCase()).toList();
    for (final condition in prefs.conditions) {
      final mapped = _sensitivityMap[condition.trim().toLowerCase()];
      if (mapped != null) avoid.addAll(mapped);
    }
    return avoid.toSet().toList();
  }

  static bool _hasAllergenRisk(VenueFilterData data, List<String> avoid) {
    if (avoid.isEmpty) return false;
    final text = data.haystack;
    final isVeganSafe = text.contains('vegan');

    for (final ingredient in avoid) {
      if (isVeganSafe &&
          {'süt', 'peynir', 'tereyağı', 'krema', 'yumurta'}.contains(ingredient)) {
        continue;
      }
      final keywords = _allergenKeywords[ingredient] ?? [ingredient];
      if (keywords.any(text.contains)) return true;
    }
    return false;
  }

  static bool _isOverBudget(VenueFilterData data, double budget) {
    final cost = data.price > 0 ? data.price : _estimateCost(data.priceLevel);
    return cost > budget * _budgetVetoFactor;
  }

  static int _estimateCost(int priceLevel) {
    const map = {1: 150, 2: 400, 3: 900, 4: 1800};
    return map[priceLevel] ?? 400;
  }

  static bool _matchesMode(VenueFilterData data, List<String> modeKeywords) {
    if (modeKeywords.isEmpty) return true;
    final text = data.haystack;

    if (modeKeywords.any((k) => k.contains('vegan') || k.contains('vejetaryen'))) {
      const meatHints = ['kebap', 'ocakbaşı', 'steak', 'bbq', 'burger', ' döner'];
      if (meatHints.any(text.contains)) return false;
    }
    return true;
  }

  static bool _matchesAmenities(VenueFilterData data, UserPreferencesSnapshot prefs) {
    final typeTokens = data.types
        .split(',')
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toSet();
    final text = data.haystack;

    final hasAlcohol = typeTokens.intersection(_alcoholTypes).isNotEmpty ||
        text.contains('bar') ||
        text.contains('pub');
    final hasSmoking = typeTokens.contains('hookah_bar') ||
        _smokingKeywords.any(text.contains);

    if (prefs.smokingArea && !hasSmoking) return false;
    if (prefs.alcoholService && !hasAlcohol) return false;
    return true;
  }
}
