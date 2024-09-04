import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../models/user_model.dart';
import '../../controllers/user_controller.dart';
import '../../views/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';

class ProfilePicturePage extends StatefulWidget {
  final String selectedArea;
  final List<String> skills;
  final List<AcademicProject> academicProjects;
  final String userName;
  final String userBio;

  ProfilePicturePage({
    required this.selectedArea,
    required this.skills,
    required this.academicProjects,
    required this.userName,
    required this.userBio,
  });

  @override
  _ProfilePicturePageState createState() => _ProfilePicturePageState();
}

class _ProfilePicturePageState extends State<ProfilePicturePage> {
  File? _image;
  final picker = ImagePicker();
  final ProfileController _userController = ProfileController();
  bool _isLoading = false;

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<String> _encodeImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  void _finishProfileSetup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Uint8List? imageBytes;
      if (_image != null) {
        final base64String = await _encodeImageToBase64(_image!);
        imageBytes = base64Decode(base64String);
      }

      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      UserProfile profile = UserProfile(
        uid: user.uid,
        name: widget.userName,
        email: user.email ?? '',
        mainStudyArea: widget.selectedArea,
        skills: widget.skills,
        academicHistory: widget.academicProjects,
        foto: imageBytes,
        bio: widget.userBio,
      );

      await _userController.createProfile(profile);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFCDE1EE), Color(0xFF448AFF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Agrega una foto de perfil',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _image == null
                            ? Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.camera_alt,
                                    size: 50, color: Colors.grey[400]),
                              )
                            : CircleAvatar(
                                radius: 100,
                                backgroundImage: FileImage(_image!),
                              ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: getImage,
                          child: Text('Seleccionar Imagen'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            textStyle:
                                TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _finishProfileSetup,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Finalizar',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF005088),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
