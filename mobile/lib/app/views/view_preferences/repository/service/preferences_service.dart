import 'package:gastromic/app/views/view_preferences/repository/model/preferences_model.dart';
import 'package:gastromic/core/services/user_preferences_service.dart';

class PreferencesService {
  PreferencesService({UserPreferencesService? preferencesService})
      : _preferencesService = preferencesService ?? UserPreferencesService();

  final UserPreferencesService _preferencesService;

  Future<void> savePreferences(PreferencesModel preferences) {
    return _preferencesService.savePreferences(preferences);
  }
}
