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
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Cargando...",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ],
                ),
              ),
            );
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
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                    SizedBox(height: 20),
                    Text(
                      "Error al cargar la aplicación",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Lógica para intentar recargar la pantalla
                      },
                      child: Text("Reintentar"),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      );
    }
  }
}
