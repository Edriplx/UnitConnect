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
    _mainStudyAreaController = TextEditingController(text: widget.userProfile.mainStudyArea);
    _skills = List.from(widget.userProfile.skills);
    _academicProjects = List.from(widget.userProfile.academicHistory);
    _newFoto = widget.userProfile.foto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _selectImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _newFoto != null
                      ? MemoryImage(_newFoto!)
                      : null,
                  child: _newFoto == null
                      ? Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _mainStudyAreaController,
                decoration: InputDecoration(labelText: 'Main Study Area'),
                validator: (value) => value!.isEmpty ? 'Please enter your main study area' : null,
              ),
              SizedBox(height: 20),
              Text('Skills', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8.0,
                children: _skills.map((skill) => Chip(
                  label: Text(skill),
                  onDeleted: () {
                    setState(() {
                      _skills.remove(skill);
                    });
                  },
                )).toList(),
              ),
              ElevatedButton(
                child: Text('Add Skill'),
                onPressed: _addSkill,
              ),
              SizedBox(height: 20),
              Text('Academic Projects', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._academicProjects.map((project) => ListTile(
                title: Text(project.name),
                subtitle: Text('${project.area} - ${project.topic}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _academicProjects.remove(project);
                    });
                  },
                ),
              )).toList(),
              ElevatedButton(
                child: Text('Add Academic Project'),
                onPressed: _addAcademicProject,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  child: Text('Save Changes'),
                  onPressed: _saveChanges,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    // Usa la cámara o la galería según el caso
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Leer el archivo de la imagen en bytes
      File imageFile = File(image.path);
      Uint8List imageData = await imageFile.readAsBytes();
      
      // Codificar los bytes en Base64
      String base64Image = base64Encode(imageData);
      
      // Actualizar el estado con la nueva imagen
      setState(() {
        _newFoto = base64Decode(base64Image); // Guardar la imagen como datos binarios
      });
    }
  }

  void _addSkill() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newSkill = '';
        return AlertDialog(
          title: Text('Add Skill'),
          content: TextField(
            onChanged: (value) {
              newSkill = value;
            },
            decoration: InputDecoration(hintText: "Enter new skill"),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Add'),
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
          title: Text('Add Academic Project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => name = value,
                decoration: InputDecoration(hintText: "Project Name"),
              ),
              TextField(
                onChanged: (value) => area = value,
                decoration: InputDecoration(hintText: "Area"),
              ),
              TextField(
                onChanged: (value) => topic = value,
                decoration: InputDecoration(hintText: "Topic"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (name.isNotEmpty && area.isNotEmpty && topic.isNotEmpty) {
                  setState(() {
                    _academicProjects.add(AcademicProject(name: name, area: area, topic: topic));
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
        foto: _newFoto ?? widget.userProfile.foto, // Guardar la nueva foto si existe, de lo contrario usar la anterior
        bio: _bioController.text,
      );

      await _profileService.updateProfile(updatedProfile);
      Navigator.of(context).pop(true);
    }
  }
}
