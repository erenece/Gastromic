import 'package:gastromic/app/views/view_settings/repository/model/settings_profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Oturum bulunamadı');
    return uid;
  }

  Future<SettingsProfileModel> fetchProfile() async {
    final doc = await _firestore.collection('users').doc(_uid).get();
    final data = doc.data() ?? {};
    return SettingsProfileModel.fromMap(data);
  }


  Future<void> updateNotifications(bool value) async {
    await _firestore.collection('users').doc(_uid).update({
      'notificationsEnabled': value,
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }


}
