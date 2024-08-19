import 'package:flutter/material.dart';
import 'skills_page.dart';

class MainStudyAreaPage extends StatefulWidget {
  final String userName;
  final String userBio;

  MainStudyAreaPage({required this.userName, required this.userBio});

  @override
  _MainStudyAreaPageState createState() => _MainStudyAreaPageState();
}

class _MainStudyAreaPageState extends State<MainStudyAreaPage> {
  String? selectedArea;
  final List<String> studyAreas = [
    'Ingeniería',
    'Ciencias',
    'Humanidades',
    'Artes',
    'Negocios',
    // Agregar más áreas según sea necesario
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade300, Colors.purple.shade300],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '¿Cuál es tu área de estudio principal?',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  DropdownButtonFormField<String>(
                    value: selectedArea,
                    items: studyAreas.map((String area) {
                      return DropdownMenuItem<String>(
                        value: area,
                        child: Text(area),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedArea = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      labelText: 'Selecciona tu área',
                      labelStyle: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Siguiente',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue.shade300,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: selectedArea != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SkillsPage(
                                  selectedArea: selectedArea!,
                                  userName: widget.userName,
                                  userBio: widget.userBio,
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
