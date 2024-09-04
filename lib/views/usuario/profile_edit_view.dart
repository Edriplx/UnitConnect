import 'package:flutter/material.dart';
import 'dart:typed_data'; // Para manejar datos binarios
import 'dart:convert'; // Para codificar y decodificar Base64
import 'package:image_picker/image_picker.dart'; // Para seleccionar imágenes
import '../../models/user_model.dart';
import '../../controllers/user_controller.dart';
import 'dart:io'; // Para trabajar con archivos

class EditProfileView extends StatefulWidget {
  final UserProfile userProfile;

  EditProfileView({required this.userProfile});

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final ProfileController _profileService = ProfileController();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _mainStudyAreaController;
  List<String> _skills = [];
  List<AcademicProject> _academicProjects = [];
  Uint8List? _newFoto; // Nueva foto

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile.name);
    _bioController = TextEditingController(text: widget.userProfile.bio);
    _mainStudyAreaController =
        TextEditingController(text: widget.userProfile.mainStudyArea);
    _skills = List.from(widget.userProfile.skills);
    _academicProjects = List.from(widget.userProfile.academicHistory);
    _newFoto = widget.userProfile.foto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Editar perfil',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24), // Título en negrita y más grande
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
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height:
                          180), // Ajuste para posicionar el avatar más abajo
                  Center(
                    child: GestureDetector(
                      onTap: _selectImage,
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage:
                            _newFoto != null ? MemoryImage(_newFoto!) : null,
                        child: _newFoto == null
                            ? Icon(Icons.camera_alt,
                                size: 50, color: Colors.grey[700])
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nombre',
                    validator: (value) =>
                        value!.isEmpty ? 'Por favor ingrese su nombre' : null,
                  ),
                  _buildTextField(
                    controller: _bioController,
                    label: 'Biografía',
                    maxLines: 4,
                  ),
                  _buildTextField(
                    controller: _mainStudyAreaController,
                    label: 'Área de estudio',
                    validator: (value) => value!.isEmpty
                        ? 'Por favor ingrese su área de estudio'
                        : null,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Habilidades',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _skills
                        .map((skill) => Chip(
                              label: Text(skill),
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(color: Colors.black),
                              onDeleted: () {
                                setState(() {
                                  _skills.remove(skill);
                                });
                              },
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    child: Text('Agregar habilidad'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF448AFF), // backgroundColor
                      foregroundColor: Colors.white, // foregroundColor
                      minimumSize: Size(double.infinity,
                          50), // Tamaño más grande y ancho completo
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 5,
                    ),
                    onPressed: _addSkill,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Proyectos académicos',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  ..._academicProjects
                      .map((project) => ListTile(
                            title: Text(project.name),
                            subtitle:
                                Text('${project.area} - ${project.topic}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _academicProjects.remove(project);
                                });
                              },
                            ),
                          ))
                      .toList(),
                  SizedBox(height: 16),
                  ElevatedButton(
                    child: Text('Agregar proyecto académico'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF448AFF), // backgroundColor
                      foregroundColor: Colors.white, // foregroundColor
                      minimumSize: Size(double.infinity,
                          50), // Tamaño más grande y ancho completo
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 5,
                    ),
                    onPressed: _addAcademicProject,
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      child: Text('Guardar cambios'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF448AFF), // backgroundColor
                        foregroundColor: Colors.white, // foregroundColor
                        minimumSize: Size(double.infinity,
                            50), // Tamaño más grande y ancho completo
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 5,
                      ),
                      onPressed: _saveChanges,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.0), // Separación mayor entre campos
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold, // Label en negrita
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: maxLines,
            validator: validator,
          ),
        ],
      ),
    );
  }

  void _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      Uint8List imageData = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageData);
      setState(() {
        _newFoto = base64Decode(
            base64Image); // Actualizar la imagen como datos binarios
      });
    }
  }

  void _addSkill() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newSkill = '';
        return AlertDialog(
          title: Text('Agregar habilidad'),
          content: TextField(
            onChanged: (value) {
              newSkill = value;
            },
            decoration: InputDecoration(hintText: "Ingrese nueva habilidad"),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Agregar'),
              onPressed: () {
                if (newSkill.isNotEmpty) {
                  setState(() {
                    _skills.add(newSkill);
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addAcademicProject() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '', area = '', topic = '';
        return AlertDialog(
          title: Text('Agregar proyecto académico'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => name = value,
                decoration: InputDecoration(hintText: "Nombre del proyecto"),
              ),
              TextField(
                onChanged: (value) => area = value,
                decoration: InputDecoration(hintText: "Área"),
              ),
              TextField(
                onChanged: (value) => topic = value,
                decoration: InputDecoration(hintText: "Tema"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Agregar'),
              onPressed: () {
                if (name.isNotEmpty && area.isNotEmpty && topic.isNotEmpty) {
                  setState(() {
                    _academicProjects.add(
                        AcademicProject(name: name, area: area, topic: topic));
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      UserProfile updatedProfile = UserProfile(
        uid: widget.userProfile.uid,
        name: _nameController.text,
        email: widget.userProfile.email,
        mainStudyArea: _mainStudyAreaController.text,
        skills: _skills,
        academicHistory: _academicProjects,
        foto: _newFoto ??
            widget.userProfile
                .foto, // Guardar la nueva foto si existe, de lo contrario usar la anterior
        bio: _bioController.text,
      );

      await _profileService.updateProfile(updatedProfile);
      Navigator.of(context).pop(true);
    }
  }
}
