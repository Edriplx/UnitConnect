import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import '../../models/user_model.dart';
import '../../controllers/user_controller.dart';
import '../../controllers/chat_controller.dart';
import 'profile_edit_view.dart';
import '../chat/chat_view.dart';

class ProfileView extends StatefulWidget {
  final UserProfile? userProfile;
  final bool isCurrentUser;

  ProfileView({this.userProfile, this.isCurrentUser = false});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileController _profileService = ProfileController();
  final ChatController _chatController = ChatController();
  UserProfile? _userProfile;
  bool _hasActiveChat = false;

  @override
  void initState() {
    super.initState();
    if (widget.userProfile != null) {
      _userProfile = widget.userProfile;
      _checkActiveChat();
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
      _checkActiveChat();
    }
  }

  Future<void> _checkActiveChat() async {
    if (_userProfile != null && !widget.isCurrentUser) {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      bool hasActive =
          await _chatController.hasActiveChat(currentUserId, _userProfile!.uid);
      setState(() {
        _hasActiveChat = hasActive;
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
    return AssetImage('lib/assets/default_avatar.png');
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pop(); // Volver a la pantalla de inicio
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
      extendBodyBehindAppBar: true,
      appBar: widget.isCurrentUser
          ? null
          : AppBar(
              title: Text(
                'Perfil de ${_userProfile!.name}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 119, 190, 235),
                  Color(0xFFD5D2D1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    height: 120), // Ajuste para posicionar el avatar más abajo
                Center(
                  child: CircleAvatar(
                    radius: 70, // Aumenta el tamaño del círculo
                    backgroundImage: _getProfileImage(),
                    backgroundColor: Colors.white,
                    child: _userProfile!.foto == null
                        ? Icon(Icons.person, size: 60, color: Colors.grey[700])
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  _userProfile!.name,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _userProfile!.email,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                if (_userProfile!.bio != null)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        _userProfile!.bio!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                Text(
                  'Área de estudio: ${_userProfile!.mainStudyArea}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Habilidades:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Wrap(
                  spacing: 8.0,
                  children: _userProfile!.skills
                      .map((skill) => Chip(
                            label: Text(skill),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(color: Colors.black),
                          ))
                      .toList(),
                ),
                SizedBox(height: 20),
                Text(
                  'Proyectos académicos:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Column(
                  children: _userProfile!.academicHistory.map((project) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 5,
                      child: ListTile(
                        title: Text(project.name),
                        subtitle: Text('${project.area} - ${project.topic}'),
                      ),
                    );
                  }).toList(),
                ),
                if (widget.isCurrentUser) ...[
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      child: Text('Editar perfil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF448AFF), // backgroundColor
                        foregroundColor: Colors.white, // foregroundColor
                        minimumSize: Size(200, 50), // Tamaño más grande
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 5,
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditProfileView(userProfile: _userProfile!)),
                        );
                        if (result == true) {
                          _loadProfile();
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.logout, color: Colors.white),
                      label: Text('Cerrar sesión'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF448AFF), // backgroundColor
                        foregroundColor: Colors.white, // foregroundColor
                        minimumSize: Size(200, 50), // Tamaño más grande
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 5,
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
                      ),
                      onPressed: _signOut,
                    ),
                  ),
                ],
                if (!widget.isCurrentUser && !_hasActiveChat) ...[
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      child: Text('Iniciar chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF448AFF), // backgroundColor
                        foregroundColor: Colors.white, // foregroundColor
                        minimumSize: Size(200, 50), // Tamaño más grande
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 5,
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
                      ),
                      onPressed: () async {
                        String chatId = await _chatController.createChat(
                          FirebaseAuth.instance.currentUser!.uid,
                          _userProfile!.uid,
                        );
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatView(
                                chatId: chatId,
                                otherUserProfile: _userProfile!),
                          ),
                        );
                        if (result == true) {
                          // El chat fue rechazado, actualizamos el estado
                          _checkActiveChat();
                        }
                      },
                    ),
                  ),
                ],
                SizedBox(
                    height:
                        50), // Espacio para asegurar que el contenido no se oculte tras la barra de navegación
              ],
            ),
          ),
        ],
      ),
    );
  }
}
