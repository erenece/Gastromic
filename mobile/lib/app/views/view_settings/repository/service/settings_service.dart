import 'dart:io';

import 'package:gastromic/app/views/view_settings/repository/model/settings_profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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

  Future<void> updateName(String name) async {
    await _firestore.collection('users').doc(_uid).update({'name': name});
  }

  Future<String> uploadProfilePhoto(File file) async {
    final ref = _storage.ref().child('profile_photos').child('$_uid.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    await _firestore.collection('users').doc(_uid).update({'photoUrl': url});
    return url;
  }

  Future<void> deleteAccount() async {
    await _firestore.collection('users').doc(_uid).delete();
    await _auth.currentUser?.delete();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }


}
