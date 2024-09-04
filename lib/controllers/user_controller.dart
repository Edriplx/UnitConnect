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

    QuerySnapshot querySnapshot = await _firestore
        .collection('profiles')
        .where('mainStudyArea', isEqualTo: currentUser.mainStudyArea)
        .where('uid', isNotEqualTo: userId)
        .get();

    List<UserProfile> potentialMatches = querySnapshot.docs
        .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    List<UserProfile> similarUsers = potentialMatches.where((user) {
      int sharedSkills = user.skills
          .where((skill) => currentUser.skills.contains(skill))
          .length;
      return sharedSkills > 0;
    }).toList();

    similarUsers.sort((a, b) {
      int aSharedSkills =
          a.skills.where((skill) => currentUser.skills.contains(skill)).length;
      int bSharedSkills =
          b.skills.where((skill) => currentUser.skills.contains(skill)).length;
      return bSharedSkills.compareTo(aSharedSkills);
    });

    return similarUsers.take(20).toList();
  }

  Future<List<AcademicProject>> getUserProjects(String userId) async {
    UserProfile? user = await getProfile(userId);
    if (user != null) {
      return user.academicHistory;
    }
    return [];
  }

  Future<UserProfile> searchUser({
    required String studyArea,
    required String skill,
    required String currentUserId,
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
        .where((user) => user.uid != currentUserId)
        .toList();

    // Si se encuentra al menos un usuario que coincide con el área de estudio, devolver el mejor match
    if (users.isNotEmpty) {
      users.sort((a, b) {
        int aMatchScore = calculateMatchScore(a, skill);
        int bMatchScore = calculateMatchScore(b, skill);
        return bMatchScore.compareTo(aMatchScore);
      });
      return users.first;
    }

    // Si no se encuentra ningún usuario que coincida con el área de estudio, devolver el usuario más cercano
    return _findClosestMatchByArea(studyArea, skill, currentUserId);
  }

  Future<UserProfile> _findClosestMatchByArea(
    String studyArea,
    String skill,
    String currentUserId,
  ) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('profiles')
        .where('mainStudyArea', isEqualTo: studyArea)
        .where('uid', isNotEqualTo: currentUserId)
        .get();

    List<UserProfile> users = querySnapshot.docs
        .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    if (users.isNotEmpty) {
      // Ordenar los usuarios por coincidencia de habilidad y devolver el mejor match
      users.sort((a, b) {
        int aMatchScore = calculateMatchScore(a, skill);
        int bMatchScore = calculateMatchScore(b, skill);
        return bMatchScore.compareTo(aMatchScore);
      });
      return users.first;
    }

    // Si no se encuentra ningún usuario en el área de estudio, devolver un perfil de usuario vacío
    return UserProfile(
      uid: '',
      name: '',
      email: '',
      mainStudyArea: '',
      skills: [],
      academicHistory: [],
      foto: null,
      bio: null,
    );
  }

  int calculateMatchScore(UserProfile user, String skill) {
    int score = 0;

    if (user.skills.contains(skill)) {
      score += 10; // Puntuación por habilidad
    }

    return score;
  }
}
