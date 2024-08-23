import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import '../../models/user_model.dart';
import '../../controllers/user_controller.dart';
import 'profile_edit_view.dart';

class ProfileView extends StatefulWidget {
  final UserProfile? userProfile;
  final bool isCurrentUser;

  ProfileView({this.userProfile, this.isCurrentUser = false});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileController _profileService = ProfileController();
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    if (widget.userProfile != null) {
      _userProfile = widget.userProfile;
    } else if (widget.isCurrentUser) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      UserProfile? profile = await _profileService.getProfile(currentUser.uid);
      setState(() {
        _userProfile = profile;
      });
    }
  }

  ImageProvider _getProfileImage() {
    if (_userProfile?.foto != null) {
      try {
        final Uint8List bytes = _userProfile!.foto!;
        return MemoryImage(bytes);
      } catch (e) {
        print('Error al cargar la imagen de perfil: $e');
      }
    }
    return AssetImage('assets/default_avatar.png');
  }

  @override
  Widget build(BuildContext context) {
    if (_userProfile == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Perfil')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: widget.isCurrentUser ? null : AppBar(title: Text('Perfil de ${_userProfile!.name}')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _getProfileImage(),
                child: _userProfile!.foto == null
                    ? Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            Text(_userProfile!.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(_userProfile!.email, style: TextStyle(fontSize: 16, color: Colors.grey)),
            if (_userProfile!.bio != null) 
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(_userProfile!.bio!, style: TextStyle(fontSize: 16)),
              ),
            SizedBox(height: 20),
            Text('Área de estudio: ${_userProfile!.mainStudyArea}'),
            SizedBox(height: 10),
            Text('Habilidades:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8.0,
              children: _userProfile!.skills.map((skill) => Chip(label: Text(skill))).toList(),
            ),
            SizedBox(height: 20),
            Text('Proyectos académicos:', style: TextStyle(fontWeight: FontWeight.bold)),
            Column(
              children: _userProfile!.academicHistory.map((project) {
                return ListTile(
                  title: Text(project.name),
                  subtitle: Text('${project.area} - ${project.topic}'),
                );
              }).toList(),
            ),
            if (widget.isCurrentUser) ...[
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  child: Text('Editar perfil'),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfileView(userProfile: _userProfile!)),
                    );
                    if (result == true) {
                      _loadProfile();
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}