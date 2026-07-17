import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:gastromic/core/models/venue_model.dart';

class HomeService {
  final Geocoding _geocoding = Geocoding();

  Future<String> fetchLocationName() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Konum izni verilmedi');
    }

    final position = await Geolocator.getCurrentPosition();
    final placemarks = await _geocoding.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) return 'Konum bulunamadı';

    final place = placemarks.first;
    final district = place.subAdministrativeArea ?? '';
    final city = place.administrativeArea ?? '';

    if (district.isEmpty && city.isEmpty) return 'Konum bulunamadı';
    if (district.isEmpty) return city;
    if (city.isEmpty) return district;
    return '$district, $city';
  }

  Future<List<VenueModel>> fetchNearbyVenues() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
      VenueModel(
        id: 'v1',
        name: 'Lara Balıkevi',
        rating: 4.8,
        imageUrl: '',
        category: 'Akdeniz',
        subCategory: 'Deniz Ürünleri',
      ),
      VenueModel(
        id: 'v2',
        name: 'Seraser Fine Dining',
        rating: 4.9,
        imageUrl: '',
        category: 'Fine Dining',
        subCategory: 'Akdeniz',
      ),
      VenueModel(
        id: 'v3',
        name: '7 Mehmet',
        rating: 4.7,
        imageUrl: '',
        category: 'Türk Mutfağı',
        subCategory: 'Kebap',
      ),
    ];
  }

  Future<List<VenueModel>> fetchFavoriteVenues() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
      VenueModel(
        id: 'f1',
        name: 'Il Vicino Pizzeria',
        rating: 4.6,
        imageUrl: '',
        category: 'İtalyan',
        subCategory: 'Pizza',
      ),
      VenueModel(
        id: 'f2',
        name: 'The Bar',
        rating: 4.5,
        imageUrl: '',
        category: 'Kokteyl Bar',
        subCategory: 'Lounge',
      ),
      VenueModel(
        id: 'f3',
        name: 'Grizzly Coffee',
        rating: 4.7,
        imageUrl: '',
        category: 'Kahve',
        subCategory: 'Tatlı',
      ),
    ];
  }
}
