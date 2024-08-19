import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'profile_picture_page.dart';

class AcademicHistoryPage extends StatefulWidget {
  final String selectedArea;
  final List<String> skills;
  final String userName;
  final String userBio;

  AcademicHistoryPage({
    required this.selectedArea,
    required this.skills,
    required this.userName,
    required this.userBio,
  });

  @override
  _AcademicHistoryPageState createState() => _AcademicHistoryPageState();
}

class _AcademicHistoryPageState extends State<AcademicHistoryPage> {
  List<AcademicProject> projects = [];
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectAreaController = TextEditingController();
  final TextEditingController _projectTopicController = TextEditingController();

  void _addProject() {
    if (_projectNameController.text.isNotEmpty &&
        _projectAreaController.text.isNotEmpty &&
        _projectTopicController.text.isNotEmpty) {
      setState(() {
        projects.add(AcademicProject(
          name: _projectNameController.text,
          area: _projectAreaController.text,
          topic: _projectTopicController.text,
        ));
        _projectNameController.clear();
        _projectAreaController.clear();
        _projectTopicController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial Académico'),
        backgroundColor: Colors.blue, // Consistent styling
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agrega tus proyectos académicos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _projectNameController,
              decoration: InputDecoration(
                labelText: 'Nombre del proyecto',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _projectAreaController,
              decoration: InputDecoration(
                labelText: 'Área del proyecto',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _projectTopicController,
              decoration: InputDecoration(
                labelText: 'Temática del proyecto',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Agregar Proyecto'),
              onPressed: _addProject,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Consistent button color
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(projects[index].name),
                    subtitle: Text('${projects[index].area} - ${projects[index].topic}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          projects.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Siguiente'),
              onPressed: projects.isNotEmpty
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePicturePage(
                            selectedArea: widget.selectedArea,
                            skills: widget.skills,
                            academicProjects: projects,
                            userName: widget.userName,
                            userBio: widget.userBio,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Consistent button color
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
