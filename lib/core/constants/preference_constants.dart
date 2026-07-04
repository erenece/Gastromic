class PreferenceConstants {
  PreferenceConstants._();

  static const List<String> allergens = [
    'Süt',
    'Yumurta',
    'Yer Fıstığı',
    'Kuruyemiş',
    'Buğday',
    'Balık',
    'Deniz Ürünleri',
    'Soya',
    'Susam',
  ];

  static const List<String> conditions = [
    'Laktoz İntoleransı',
    'Fruktoz İntoleransı',
    'Çölyak',
    'Gluten Hassasiyeti',
    'Diyabet',
    'Gut',
    'Hipertansiyon',
    'Fenilketonüri',
    'Favizm',
  ];

  static const Map<String, String> dailyModeImages = {
    'Sporcu': 'assets/images/sporcu.png',
    'Vejetaryen': 'assets/images/vejetaryen.png',
    'Organik': 'assets/images/organik.png',
    'Kaçamak': 'assets/images/kacamak.png',
  };

  static const List<String> dailyModes = [
    'Sporcu',
    'Vejetaryen',
    'Organik',
    'Kaçamak',
  ];

  static const double minBudget = 50;
  static const double maxBudget = 3000;
}
