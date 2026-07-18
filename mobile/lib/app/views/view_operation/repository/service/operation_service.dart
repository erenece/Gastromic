import 'package:gastromic/core/models/map_venue_model.dart';
import 'package:geolocator/geolocator.dart';

class OperationService {
  Future<Position> currentPosition() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Konum izni verilmedi');
    }
    return Geolocator.getCurrentPosition();
  }

  Future<List<MapVenueModel>> fetchVenues() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
      MapVenueModel(
        id: 'v1',
        name: 'Seraser Fine Dining',
        imageUrl: '',
        rating: 4.9,
        category: 'Akdeniz',
        district: 'Kaleiçi',
        latitude: 36.8841,
        longitude: 30.7056,
        price: 1200,
        busyness: 0.7,
        isOpenNow: true,
      ),
      MapVenueModel(
        id: 'v2',
        name: '7 Mehmet',
        imageUrl: '',
        rating: 4.7,
        category: 'Türk Mutfağı',
        district: 'Konyaaltı',
        latitude: 36.8721,
        longitude: 30.6339,
        price: 800,
        busyness: 0.5,
        isOpenNow: true,
      ),
      MapVenueModel(
        id: 'v3',
        name: 'Lara Balıkevi',
        imageUrl: '',
        rating: 4.8,
        category: 'Deniz Ürünleri',
        district: 'Lara',
        latitude: 36.8523,
        longitude: 30.7889,
        price: 1500,
        busyness: 0.3,
        isOpenNow: false,
      ),
      MapVenueModel(
        id: 'v4',
        name: 'Il Vicino Pizzeria',
        imageUrl: '',
        rating: 4.6,
        category: 'İtalyan',
        district: 'Muratpaşa',
        latitude: 36.8869,
        longitude: 30.7133,
        price: 400,
        busyness: 0.9,
        isOpenNow: true,
      ),
    ];
  }
}
