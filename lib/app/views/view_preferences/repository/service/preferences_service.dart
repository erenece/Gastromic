import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gastromic/app/views/view_preferences/repository/model/preferences_model.dart';

class PreferencesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> savePreferences(PreferencesModel preferences) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Oturum bulunamadı');
    }

    await _firestore
        .collection('users')
        .doc(uid)
        .set(preferences.toMap(), SetOptions(merge: true));
  }
}
