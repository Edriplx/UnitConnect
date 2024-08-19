// lib/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_model.dart';

class AuthController {
  final AuthModel _authModel = AuthModel();

  Future<void> login(BuildContext context, String email, String password) async {
    try {
      User? user = await _authModel.signInWithEmailAndPassword(email, password);
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home'); // Cambia a la pantalla principal
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> register(BuildContext context, String email, String password) async {
    try {
      User? user = await _authModel.registerWithEmailAndPassword(email, password);
      if (user != null) {
        Navigator.pop(context); // Regresa a la pantalla de login
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}
