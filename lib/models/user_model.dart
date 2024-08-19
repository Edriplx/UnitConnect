// lib/models/user_profile.dart
import 'dart:convert'; // Para codificar y decodificar Base64
import 'dart:typed_data'; // Para manejar datos binarios

class UserProfile {
  String uid;
  String name;
  String email;
  String mainStudyArea;
  List<String> skills;
  List<AcademicProject> academicHistory;
  Uint8List? foto; // Cambiado a Uint8List para manejar datos binarios
  String? bio;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.mainStudyArea,
    required this.skills,
    required this.academicHistory,
    this.foto, // Actualizado para manejar datos binarios
    this.bio,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'mainStudyArea': mainStudyArea,
      'skills': skills,
      'academicHistory': academicHistory.map((project) => project.toMap()).toList(),
      'foto': foto != null ? base64Encode(foto!) : null, // Codificar datos binarios a Base64
      'bio': bio,
    };
  }

  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      mainStudyArea: map['mainStudyArea'],
      skills: List<String>.from(map['skills']),
      academicHistory: (map['academicHistory'] as List)
          .map((project) => AcademicProject.fromMap(project))
          .toList(),
      foto: map['foto'] != null ? base64Decode(map['foto']) : null, // Decodificar Base64 a datos binarios
      bio: map['bio'],
    );
  }
}

class AcademicProject {
  String name;
  String area;
  String topic;

  AcademicProject({
    required this.name,
    required this.area,
    required this.topic,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'area': area,
      'topic': topic,
    };
  }

  static AcademicProject fromMap(Map<String, dynamic> map) {
    return AcademicProject(
      name: map['name'],
      area: map['area'],
      topic: map['topic'],
    );
  }
}
