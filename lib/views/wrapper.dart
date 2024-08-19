// lib/views/wrapper.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:unitconnect/controllers/user_controller.dart';
import 'home.dart';
import 'auth_view.dart';
import '../views/perfil_usuario/personal_info.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final ProfileController _profileService = ProfileController();

    if (user == null) {
      return AuthPage();
    } else {
      return FutureBuilder<bool>(
        future: _profileService.isFirstTimeUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            if (snapshot.data!) {
              // Es la primera vez del usuario, mostrar configuración de perfil
              return CompleteProfileView();
            } else {
              // El usuario ya tiene un perfil, mostrar página principal
              return HomePage();
            }
          } else {
            // Error al verificar el estado del usuario
            return Text("Error al cargar la aplicación");
          }
        },
      );
    }
  }
}