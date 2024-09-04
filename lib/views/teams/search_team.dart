import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';
import '../usuario/profile_view.dart';

class SearchTeamView extends StatefulWidget {
  @override
  _SearchTeamViewState createState() => _SearchTeamViewState();
}

class _SearchTeamViewState extends State<SearchTeamView> {
  String selectedStudyArea = '';
  String selectedSkill = '';
  String selectedProjectTopic = '';
  UserProfile? _searchResult;
  Completer<void>?
      _loadingCompleter; // Completer para manejar el cierre del diálogo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Buscar Compañero',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: const Color.fromARGB(255, 8, 8, 8),
          ),
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
                  Color.fromARGB(255, 100, 180, 225),
                  Color(0xFFD5D2D1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Filtrar por:',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Área principal de estudio',
                    items: <String>[
                      'Ciencias',
                      'Ingeniería',
                      'Arte',
                      'Matemáticas'
                    ],
                    selectedValue: selectedStudyArea,
                    onChanged: (value) {
                      setState(() {
                        selectedStudyArea = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Habilidades',
                    onChanged: (value) {
                      setState(() {
                        selectedSkill = value!;
                      });
                    },
                  ),
                  SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        searchForBestMatch(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        backgroundColor: Color(0xFF005088),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Buscar',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  _buildResultSection(), // Sección para el resultado de la búsqueda
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String selectedValue,
    required void Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue.isNotEmpty ? selectedValue : null,
              isExpanded: true,
              hint: Text('Selecciona $label'),
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Escribe $label',
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resultado:',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF005088),
          ),
        ),
        SizedBox(height: 16),
        _searchResult != null
            ? ListTile(
                leading: CircleAvatar(
                  backgroundImage: _searchResult!.foto != null
                      ? MemoryImage(_searchResult!.foto!)
                      : AssetImage('lib/assets/default_avatar.png')
                          as ImageProvider,
                ),
                title: Text(_searchResult!.name),
                subtitle: Text(_searchResult!.mainStudyArea),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          SearchResultView(userProfile: _searchResult!),
                    ),
                  );
                },
              )
            : Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'No hay resultados para mostrar',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
      ],
    );
  }

  void showLoadingDialog(BuildContext context) {
    _loadingCompleter = Completer<void>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            height: 150.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20.0),
                Text("Buscando similitudes...",
                    style: TextStyle(color: Colors.white)),
                SizedBox(height: 10.0),
                Text("Buscando personas para ti...",
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        );
      },
    );

    // Simula un retraso de 3 segundos antes de cerrar el modal
    Future.delayed(Duration(seconds: 3), () {
      if (_loadingCompleter != null && !_loadingCompleter!.isCompleted) {
        Navigator.of(context).pop(); // Cierra el modal de carga
        _loadingCompleter!.complete();
      }
    });
  }

  void searchForBestMatch(BuildContext context) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    showLoadingDialog(context);

    // Realiza la búsqueda
    UserProfile? bestMatchProfile = await ProfileController().searchUser(
      studyArea: selectedStudyArea,
      skill: selectedSkill,
      currentUserId: currentUser!.uid,
    );

    // Espera a que se cierre el modal de carga antes de continuar
    await _loadingCompleter?.future;

    setState(() {
      _searchResult = bestMatchProfile;
    });

    // Navega a la vista de resultados
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchResultView(userProfile: _searchResult!),
      ),
    );
  }
}

class SearchResultView extends StatelessWidget {
  final UserProfile userProfile;

  const SearchResultView({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('El mejor compañero para ti'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: userProfile.foto != null
                  ? MemoryImage(userProfile.foto!)
                  : AssetImage('lib/assets/default_avatar.png')
                      as ImageProvider,
            ),
            SizedBox(height: 20),
            Text(
              userProfile.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              userProfile.mainStudyArea,
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            Text(
              'Habilidades: ${userProfile.skills.join(', ')}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileView(userProfile: userProfile),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                backgroundColor: Color(0xFF005088),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Ver perfil',
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                backgroundColor: Colors.grey[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Atrás',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
