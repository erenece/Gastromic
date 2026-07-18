import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

class SplashService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box _settingsBox = Hive.box('settings');

  bool get isLoggedIn => _auth.currentUser != null;

  bool get isOnboardingSeen =>
      _settingsBox.get('onboarding_seen', defaultValue: false) as bool;

  Future<bool> isPreferencesCompleted() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _firestore.collection('users').doc(uid).get();
    return (doc.data()?['preferencesCompleted'] ?? false) as bool;
  }
}
