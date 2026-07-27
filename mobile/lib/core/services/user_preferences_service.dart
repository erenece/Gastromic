import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gastromic/app/views/view_preferences/repository/model/preferences_model.dart';
import 'package:gastromic/core/models/user_preferences_snapshot.dart';

class UserPreferencesService {
  UserPreferencesService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserPreferencesSnapshot? _cache;

  Future<UserPreferencesSnapshot> loadPreferences() async {
    if (_cache != null) return _cache!;

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _cache = const UserPreferencesSnapshot();
      return _cache!;
    }

    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      _cache = const UserPreferencesSnapshot();
      return _cache!;
    }

    _cache = UserPreferencesSnapshot.fromFirestore(doc.data()!);
    return _cache!;
  }

  Future<void> savePreferences(PreferencesModel preferences) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Oturum bulunamadı');
    }

    await _firestore
        .collection('users')
        .doc(uid)
        .set(preferences.toMap(), SetOptions(merge: true));

    _cache = UserPreferencesSnapshot.fromModel(preferences);
  }

  void invalidateCache() {
    _cache = null;
  }
}
