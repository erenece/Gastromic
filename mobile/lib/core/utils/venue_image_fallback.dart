/// Kategori bazlı stok görsel URL'leri (API key gerektirmez).
class VenueImageFallback {
  VenueImageFallback._();

  static const _default =
      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80';

  static const _byKeyword = {
    'cafe': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=800&q=80',
    'kafe': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=800&q=80',
    'kahve': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=800&q=80',
    'coffee': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=800&q=80',
    'bar': 'https://images.unsplash.com/photo-1572116469696-31de0fa17a90?auto=format&fit=crop&w=800&q=80',
    'pub': 'https://images.unsplash.com/photo-1572116469696-31de0fa17a90?auto=format&fit=crop&w=800&q=80',
    'meyhane': 'https://images.unsplash.com/photo-1572116469696-31de0fa17a90?auto=format&fit=crop&w=800&q=80',
    'balık': 'https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=800&q=80',
    'seafood': 'https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=800&q=80',
    'fish': 'https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=800&q=80',
    'kebap': 'https://images.unsplash.com/photo-1529042410799-b538fe247d4f?auto=format&fit=crop&w=800&q=80',
    'burger': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80',
    'pizza': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=800&q=80',
    'tatlı': 'https://images.unsplash.com/photo-1551024501-0b5c86a64e23?auto=format&fit=crop&w=800&q=80',
    'dessert': 'https://images.unsplash.com/photo-1551024501-0b5c86a64e23?auto=format&fit=crop&w=800&q=80',
    'bakery': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=800&q=80',
    'vegan': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80',
    'vejetaryen': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80',
    'breakfast': 'https://images.unsplash.com/photo-1533089860890-a1d9608ca6bc?auto=format&fit=crop&w=800&q=80',
    'kahvaltı': 'https://images.unsplash.com/photo-1533089860890-a1d9608ca6bc?auto=format&fit=crop&w=800&q=80',
  };

  static String forCategory(String category, {String types = ''}) {
    final text = '$category $types'.toLowerCase();
    for (final entry in _byKeyword.entries) {
      if (text.contains(entry.key)) return entry.value;
    }
    return _default;
  }

  /// Google Places media URL'leri Android'de 403 verir — Storage URL'leri kullan.
  static bool isGooglePlacesMediaUrl(String url) {
    return url.contains('places.googleapis.com');
  }

  static bool isUsableNetworkUrl(String url) {
    if (url.isEmpty) return false;
    if (isGooglePlacesMediaUrl(url)) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }
}
