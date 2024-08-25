import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class ProfileController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createProfile(UserProfile profile) async {
    await _firestore
        .collection('profiles')
        .doc(profile.uid)
        .set(profile.toMap());
  }

  Future<UserProfile?> getProfile(String uid) async {
    DocumentSnapshot doc =
        await _firestore.collection('profiles').doc(uid).get();
    if (doc.exists) {
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _firestore
        .collection('profiles')
        .doc(profile.uid)
        .update(profile.toMap());
  }

  Future<bool> isFirstTimeUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('profiles').doc(user.uid).get();
      return !doc.exists;
    }
    return false;
  }

  Future<List<UserProfile>> getUsersByArea(String area) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('profiles')
        .where('mainStudyArea', isEqualTo: area)
        .get();

    return querySnapshot.docs
        .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserProfile>> getUsersWithSimilarInterests(String userId) async {
    UserProfile? currentUser = await getProfile(userId);
    if (currentUser == null) {
      return [];
    }

    // Obtener todos los usuarios con la misma área de estudio principal
    QuerySnapshot querySnapshot = await _firestore
        .collection('profiles')
        .where('mainStudyArea', isEqualTo: currentUser.mainStudyArea)
        .where('uid', isNotEqualTo: userId)
        .get();

    List<UserProfile> potentialMatches = querySnapshot.docs
        .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    // Filtrar y ordenar usuarios basados en habilidades compartidas
    List<UserProfile> similarUsers = potentialMatches.where((user) {
      // Contar habilidades compartidas
      int sharedSkills = user.skills
          .where((skill) => currentUser.skills.contains(skill))
          .length;
      // Considerar como match si comparten al menos una habilidad
      return sharedSkills > 0;
    }).toList();

    // Ordenar por número de habilidades compartidas (de mayor a menor)
    similarUsers.sort((a, b) {
      int aSharedSkills =
          a.skills.where((skill) => currentUser.skills.contains(skill)).length;
      int bSharedSkills =
          b.skills.where((skill) => currentUser.skills.contains(skill)).length;
      return bSharedSkills.compareTo(aSharedSkills);
    });

    // Limitar a un máximo de 20 usuarios para evitar cargar demasiados datos
    return similarUsers.take(20).toList();
  }

  Future<List<AcademicProject>> getUserProjects(String userId) async {
    UserProfile? user = await getProfile(userId);
    if (user != null) {
      return user.academicHistory;
    }
    return [];
  }

  // Implementación de searchUsers
  Future<List<UserProfile>> searchUsers({
    required String studyArea,
    required String skill,
    required String projectTopic,
  }) async {
    Query query = _firestore.collection('profiles');

    if (studyArea.isNotEmpty) {
      query = query.where('mainStudyArea', isEqualTo: studyArea);
    }

    if (skill.isNotEmpty) {
      query = query.where('skills', arrayContains: skill);
    }

    QuerySnapshot querySnapshot = await query.get();
    List<UserProfile> users = querySnapshot.docs
        .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    if (projectTopic.isNotEmpty) {
      users = users.where((user) {
        return user.academicHistory
            .any((project) => project.topic.contains(projectTopic));
      }).toList();
    }

    return users;
  }
}
