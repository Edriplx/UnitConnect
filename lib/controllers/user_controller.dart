// lib/services/profile_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class ProfileController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createProfile(UserProfile profile) async {
    await _firestore.collection('profiles').doc(profile.uid).set(profile.toMap());
  }

  Future<UserProfile?> getProfile(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('profiles').doc(uid).get();
    if (doc.exists) {
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _firestore.collection('profiles').doc(profile.uid).update(profile.toMap());
  }

  Future<bool> isFirstTimeUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('profiles').doc(user.uid).get();
      return !doc.exists;
    }
    return false;
  }
}