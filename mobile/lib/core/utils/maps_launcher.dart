import 'package:url_launcher/url_launcher.dart';

class MapsLauncher {
  MapsLauncher._();

  static Future<void> openDirections({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
    );
    await _launch(uri);
  }

  static Future<void> openLocation({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final query = label != null && label.isNotEmpty
        ? Uri.encodeComponent(label)
        : '$latitude,$longitude';
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    await _launch(uri);
  }

  static Future<void> _launch(Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      throw Exception('Google Haritalar açılamadı');
    }
  }
}
