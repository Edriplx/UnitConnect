import 'package:flutter/material.dart';
import 'package:unitconnect/views/perfil_usuario/academic_history_page.dart';

class SkillsPage extends StatefulWidget {
  final String selectedArea;
  final String userName;
  final String userBio;

  SkillsPage({
    required this.selectedArea,
    required this.userName,
    required this.userBio,
  });

  @override
  _SkillsPageState createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  List<String> selectedSkills = [];
  final TextEditingController _skillController = TextEditingController();

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
              colors: [Color(0xFFCDE1EE), Color(0xFF448AFF)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agrega tus habilidades',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _skillController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.transparent,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              labelText: 'Nueva habilidad',
                              labelStyle: TextStyle(color: Colors.black54),
                              prefixIcon: Icon(Icons.star_outline),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        child: Text(
                          'Agregar',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (_skillController.text.isNotEmpty) {
                            setState(() {
                              selectedSkills.add(_skillController.text);
                              _skillController.clear();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF448AFF),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          textStyle: TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: selectedSkills.map((skill) {
                      return Chip(
                        label: Text(skill),
                        onDeleted: () {
                          setState(() {
                            selectedSkills.remove(skill);
                          });
                        },
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        deleteIconColor: Color(0xFF448AFF),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text(
                      'Siguiente',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    onPressed: selectedSkills.isNotEmpty
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AcademicHistoryPage(
                                  selectedArea: widget.selectedArea,
                                  skills: selectedSkills,
                                  userName: widget.userName,
                                  userBio: widget.userBio,
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF005088),
                      minimumSize: Size(double.infinity, 50),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
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
