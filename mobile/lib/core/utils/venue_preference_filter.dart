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
    'sporcu': [
      'protein',
      'ızgara',
      'grill',
      'salata',
      'sağlıklı',
      'healthy',
      'fit',
      'bowl',
    ],
    'vejetaryen': [
      'vejetaryen',
      'vegan',
      'meze',
      'sebze',
      'vegetarian',
      'vegan_restaurant',
      'vegetarian_restaurant',
    ],
    'organik': [
      'organik',
      'organic',
      'çiftlik',
      'farm',
      'farm-to-table',
      'kahvaltı',
      'breakfast',
    ],
    'kacamak': [
      'burger',
      'tatlı',
      'dessert',
      'pizza',
      'sokak',
      'fast_food',
      'hamburger',
      'ice cream',
      'dondurma',
      'street',
    ],
  };

  static const _modeExclude = {
    'kacamak': [
      'vegan_restaurant',
      'vegetarian_restaurant',
      'salata bar',
      'juice',
      'health_food',
      'smoothie',
    ],
    'vejetaryen': [
      'steakhouse',
      'fast_food_restaurant',
    ],
    'sporcu': [
      'ice_cream_shop',
      'patisserie',
    ],
    'organik': [
      'mcdonald',
      'burger king',
      'kfc',
    ],
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

  /// Liste görünümü: mekan elemez; günlük moda göre çok hafif sıralama yapar.
  /// Alerjen, bütçe, sigara/alkol tercihleri yalnızca AI özetinde uyarı olarak kullanılır.
  static List<T> apply<T>(
    List<T> venues,
    UserPreferencesSnapshot prefs,
    VenueFilterData Function(T item) toFilterData,
  ) {
    if (!prefs.hasPreferences) return venues;

    final modeSlug = prefs.dailyModeSlug;
    if (modeSlug.isEmpty) return venues;

    final sorted = List<T>.from(venues);
    sorted.sort((a, b) {
      final scoreA = _softModeScore(toFilterData(a), modeSlug);
      final scoreB = _softModeScore(toFilterData(b), modeSlug);
      return scoreB.compareTo(scoreA);
    });
    return sorted;
  }

  /// AI özeti için alerjen uyarı metni; liste filtrelemesinde kullanılmaz.
  static String? allergenWarning(
    VenueFilterData data,
    UserPreferencesSnapshot prefs,
  ) {
    final hit = _detectAllergen(data, _buildAvoidList(prefs));
    if (hit == null) return null;
    return 'Bu mekanda alerjen listenizde olan ürünler ($hit) olabilir — dikkatli olun.';
  }

  static List<String> _buildAvoidList(UserPreferencesSnapshot prefs) {
    final avoid = prefs.allergens.map((a) => a.trim().toLowerCase()).toList();
    for (final condition in prefs.conditions) {
      final mapped = _sensitivityMap[condition.trim().toLowerCase()];
      if (mapped != null) avoid.addAll(mapped);
    }
    return avoid.toSet().toList();
  }

  static String? _detectAllergen(VenueFilterData data, List<String> avoid) {
    if (avoid.isEmpty) return null;
    final text = data.haystack;
    final isVeganSafe = text.contains('vegan');

    for (final ingredient in avoid) {
      if (isVeganSafe &&
          {'süt', 'peynir', 'tereyağı', 'krema', 'yumurta'}.contains(ingredient)) {
        continue;
      }
      final keywords = _allergenKeywords[ingredient] ?? [ingredient];
      if (keywords.any(text.contains)) return ingredient;
    }
    return null;
  }

  static int _softModeScore(VenueFilterData data, String modeSlug) {
    final excludes = _modeExclude[modeSlug] ?? const [];
    final text = data.haystack;

    if (excludes.any((k) => text.contains(k.toLowerCase()))) return 0;

    final modeKeywords = _modeCategories[modeSlug] ?? const [];
    if (modeKeywords.any((k) => text.contains(k.toLowerCase()))) return 2;

    return 1;
  }
}
