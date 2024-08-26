import 'package:flutter/material.dart';
import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';

class SearchTeamView extends StatefulWidget {
  @override
  _SearchTeamViewState createState() => _SearchTeamViewState();
}

class _SearchTeamViewState extends State<SearchTeamView> {
  String selectedStudyArea = '';
  String selectedSkill = '';
  String selectedProjectTopic = '';
  List<UserProfile> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Compañeros'),
        backgroundColor: Colors.indigoAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              _buildDropdownField(
                label: 'Habilidades',
                items: <String>[
                  'Programación',
                  'Diseño Gráfico',
                  'Redacción',
                  'Investigación'
                ],
                selectedValue: selectedSkill,
                onChanged: (value) {
                  setState(() {
                    selectedSkill = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                label: 'Tema del Proyecto Académico',
                onChanged: (value) {
                  setState(() {
                    selectedProjectTopic = value;
                  });
                },
              ),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    List<UserProfile> searchResults =
                        await ProfileController().searchUsers(
                      studyArea: selectedStudyArea,
                      skill: selectedSkill,
                      projectTopic: selectedProjectTopic,
                    );

                    setState(() {
                      _searchResults = searchResults;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    backgroundColor: Colors.indigoAccent,
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
              _buildResultsSection(), // Sección para los resultados de la búsqueda
            ],
          ),
        ),
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

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resultados:',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        SizedBox(height: 16),
        _searchResults.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  UserProfile user = _searchResults[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.foto != null
                          ? MemoryImage(user.foto!)
                          : AssetImage('lib/assets/default_avatar.png')
                              as ImageProvider,
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.mainStudyArea),
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
}
