/// Mekan tip/kategori metninden sigara ve alkol sinyallerini çıkarır.
class VenueAmenities {
  VenueAmenities._();

  static const _alcoholTypes = {
    'bar',
    'cocktail_bar',
    'wine_bar',
    'pub',
    'night_club',
    'brewery',
    'beer_garden',
  };

  static const _alcoholKeywords = ['bar', 'pub', 'meyhane', 'meyhanesi'];

  /// Sigara: tüm mekanlarda varsayılan olarak müsait kabul edilir.
  /// Alkol: yalnızca bar, pub, meyhane vb. gerçek alkol servisi olan tiplerde true.
  static ({bool alcohol, bool smoking}) infer({
    String types = '',
    String category = '',
    String name = '',
  }) {
    final haystack = '$types $category $name'.toLowerCase();
    final typeTokens = types
        .split(',')
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toSet();

    final alcohol = typeTokens.intersection(_alcoholTypes).isNotEmpty ||
        _alcoholKeywords.any(haystack.contains);

    return (alcohol: alcohol, smoking: true);
  }
}
