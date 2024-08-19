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
      appBar: AppBar(
        title: Text('Habilidades'),
        backgroundColor: Colors.blue.shade300, // Consistent app bar color
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agrega tus habilidades',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade300,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Nueva habilidad',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      prefixIcon: Icon(Icons.star_outline),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  child: Text('Agregar'),
                  onPressed: () {
                    if (_skillController.text.isNotEmpty) {
                      setState(() {
                        selectedSkills.add(_skillController.text);
                        _skillController.clear();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade300, // Consistent button color
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  backgroundColor: Colors.blue.withOpacity(0.1), // Light background color for chips
                  deleteIconColor: Colors.blue.shade300, // Delete icon color
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Siguiente'),
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
                backgroundColor: Colors.green, // Consistent button color
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
    );
  }
}
