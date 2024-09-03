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
      body: Container(
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
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          'Agrega tus proyectos académicos',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
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
                    controller: _projectNameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      labelText: 'Nombre del proyecto',
                      labelStyle: TextStyle(color: Colors.black54),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
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
                    controller: _projectAreaController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      labelText: 'Área del proyecto',
                      labelStyle: TextStyle(color: Colors.black54),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
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
                    controller: _projectTopicController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      labelText: 'Temática del proyecto',
                      labelStyle: TextStyle(color: Colors.black54),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text(
                    'Agregar Proyecto',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _addProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF448AFF),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(projects[index].name),
                          subtitle: Text(
                              '${projects[index].area} - ${projects[index].topic}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                projects.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text(
                    'Siguiente',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
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
                    backgroundColor: Color(0xFF005088),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size(double.infinity, 50),
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
    );
  }
}
