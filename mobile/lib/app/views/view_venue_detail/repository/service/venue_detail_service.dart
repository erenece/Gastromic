import 'package:gastromic/app/views/view_venue_detail/repository/model/venue_detail_model.dart';
import 'package:gastromic/core/models/dish_model.dart';

// şu anlık mock data
class VenueDetailService {
  Future<VenueDetailModel> fetchVenueDetail(String venueId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return const VenueDetailModel(
      id: 'mock-1',
      name: 'Seraser Fine Dining',
      imageUrl: '',
      rating: 4.8,
      reviewCount: 324,
      category: 'Fine Dining',
      distance: '1.2 km',
      aiSummary:
          'Damak tadınıza ve alerji tercihlerinize uygun bir mekan. '
          'Deniz ürünleri ağırlıklı menüsüyle öne çıkıyor, glutensiz seçenekler mevcut.',
      description:
          'Kaleiçi\'nin tarihi dokusunda yer alan Seraser, modern Akdeniz mutfağını '
          'yerel malzemelerle buluşturuyor. Şef önerisi menüsü ve zengin şarap '
          'kartıyla özel günler için tercih ediliyor.',
      features: ['Bahçe Katı', 'Teras Alan', 'Vale Hizmeti', 'Canlı Müzik'],
      dishes: [
        DishModel(
          id: 'd1',
          name: 'Deniz Tarağı',
          description: 'Karamelize soğan ve limon sos ile',
          imageUrl: '',
        ),
        DishModel(
          id: 'd2',
          name: 'Dana Bonfile',
          description: 'Trüf mantarı ve kök sebze püresi',
          imageUrl: '',
        ),
      ],
      reviews: [
        ReviewModel(
          id: 'r1',
          userName: 'Emre K.',
          rating: 5,
          comment:
              'Alerji tercihlerimi belirttiğimde menüyü baştan sona uyarladılar. '
              'Servis ve lezzet kusursuzdu.',
          date: '2 gün önce',
        ),
        ReviewModel(
          id: 'r2',
          userName: 'Selin A.',
          rating: 4.5,
          comment: 'Teras katı manzarası çok güzel, rezervasyon şart.',
          date: '1 hafta önce',
        ),
      ],
      address: 'Tuzcular Mah. Kandiller Sok. No: 18 Kaleiçi / Antalya',
      phone: '+90 242 247 6015',
      workingHours: '10:00 - 23:00',
      latitude: 36.8841,
      longitude: 30.7056,
      priceLevel: 4,
      location: 'Kaleiçi, Antalya',
    );
  }
}
