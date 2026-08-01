import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'bio': '',
      'photoUrl': '',
      'visitCount': 0,
      'membershipYears': 0,
      'notificationsEnabled': true,
    });
    return credential;
  }
}
