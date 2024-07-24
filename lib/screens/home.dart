// lib/screens/home.dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Materias',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TabBarSection(),
              SizedBox(height: 16),
              Text(
                'Mis Cursos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(
                  child: Text(
                    'Gráfico de Cursos',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Intereses',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              InterestSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class TabBarSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: 'Matemática'),
              Tab(text: 'Física'),
              Tab(text: 'Programación'),
            ],
          ),
          Container(
            height: 150,
            child: TabBarView(
              children: [
                SubjectImages(subject: 'Matemática'),
                SubjectImages(subject: 'Física'),
                SubjectImages(subject: 'Programación'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectImages extends StatelessWidget {
  final String subject;

  SubjectImages({required this.subject});

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        Image.asset('lib/assets/matematica.png', height: 100), // Cambia a tus imágenes
        SizedBox(width: 8),
        Image.asset('lib/assets/fisica.png', height: 100),
        SizedBox(width: 8),
        Image.asset('lib/assets/programacion.png', height: 100),
      ],
    );
  }
}

class InterestSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage('lib/assets/ada_lovelace.png'), // Cambia a tus imágenes
          ),
          title: Text('Ada Lovelace'),
          subtitle: Text('Matemáticas'),
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage('lib/assets/mark_hopper.png'), // Cambia a tus imágenes
          ),
          title: Text('Mark Hopper'),
          subtitle: Text('Física'),
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage('lib/assets/margaret_hamilton.png'), // Cambia a tus imágenes
          ),
          title: Text('Margaret Hamilton'),
          subtitle: Text('Programación'),
        ),
      ],
    );
  }
}
