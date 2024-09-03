import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/user_model.dart';
import '../controllers/user_controller.dart';
import '../controllers/chat_controller.dart';
import 'package:unitconnect/views/teams/search_team.dart';
import 'package:unitconnect/views/chat/chats_view.dart';
import 'package:unitconnect/views/usuario/profile_view.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final ProfileController _profileController = ProfileController();
  final ChatController _chatController = ChatController();
  UserProfile? _currentUserProfile;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserProfile();
  }

  Future<void> _loadCurrentUserProfile() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        UserProfile? profile =
            await _profileController.getProfile(currentUser.uid);
        setState(() {
          _currentUserProfile = profile;
        });
      }
    } catch (e) {
      print("Error loading current user profile: $e");
    }
  }

  Widget _getSelectedWidget() {
    switch (_selectedIndex) {
      case 0:
        return HomeContent();
      case 1:
        return _currentUserProfile != null
            ? ProfileView(userProfile: _currentUserProfile, isCurrentUser: true)
            : Center(child: CircularProgressIndicator());
      case 2:
        return SearchTeamView();
      case 3:
        return ChatsView(chatController: _chatController);
      default:
        return HomeContent();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD5D2D1),
              Color.fromARGB(255, 152, 199, 226),
              Color.fromARGB(255, 52, 166, 231)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _getSelectedWidget(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Encontrar Compañero',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF005088), // Azul oscuro
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final List<String> areas = [
    'Ingeniería',
    'Ciencias',
    'Humanidades',
    'Artes',
    'Negocios'
  ];
  final List<String> areaImages = [
    'lib/assets/ingenieria.png',
    'lib/assets/ciencias.jpg',
    'lib/assets/humanidades.png',
    'lib/assets/artes.png',
    'lib/assets/negocios.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height -
          kBottomNavigationBarHeight, // Resta la altura del BottomNavigationBar
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Text(
                'Hola, ',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005088), // Azul oscuro
                ),
              ),
              SizedBox(height: 8), // Reducido el espacio
              Text(
                'Áreas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 17, 112, 180), // Azul oscuro
                ),
              ),
              SizedBox(height: 16),
              AreaCarousel(areas: areas, areaImages: areaImages),
              SizedBox(height: 16),
              Text(
                'Mis Proyectos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005088), // Azul oscuro
                ),
              ),
              SizedBox(height: 16),
              ProjectCarousel(),
              SizedBox(height: 16),
              Text(
                'Intereses',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005088), // Azul oscuro
                ),
              ),
              SizedBox(height: 16),
              SimilarInterestsList(),
            ],
          ),
        ),
      ),
    );
  }
}

class AreaCarousel extends StatelessWidget {
  final List<String> areas;
  final List<String> areaImages;

  AreaCarousel({required this.areas, required this.areaImages});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
      items: areas.asMap().entries.map((entry) {
        int index = entry.key;
        String area = entry.value;

        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserListView(area: area),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 63, 158, 226), // Azul oscuro
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      areaImages[index],
                      height: 128, // Ajusta la altura de la imagen
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 8),
                    Text(
                      area,
                      style: TextStyle(fontSize: 24.0, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class UserListView extends StatelessWidget {
  final String area;

  UserListView({required this.area});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Usuarios en $area',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: const Color.fromARGB(
                255, 8, 8, 8), // Asegúrate de que el texto sea visible
          ),
        ),
        backgroundColor: Colors.transparent, // Sin color de fondo
        elevation: 0, // Sin sombra
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
          FutureBuilder<List<UserProfile>>(
            future: ProfileController().getUsersByArea(area),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No users found in this area.'));
              } else {
                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(16.0, 130.0, 16.0,
                      16.0), // Margen adicional en la parte superior
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 1,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    UserProfile user = snapshot.data![index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileView(
                                userProfile: user, isCurrentUser: false),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: user.foto != null
                                  ? MemoryImage(user.foto!)
                                  : AssetImage('lib/assets/default_avatar.png')
                                      as ImageProvider,
                            ),
                            SizedBox(height: 8),
                            Text(
                              user.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              user.mainStudyArea,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class ProjectCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: ProfileController()
          .getProfile(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData ||
            snapshot.data!.academicHistory.isEmpty) {
          return Center(child: Text('No projects found.'));
        } else {
          List<AcademicProject> projects = snapshot.data!.academicHistory;
          return CarouselSlider(
            options: CarouselOptions(
              height: 200.0,
              enlargeCenterPage: true,
              autoPlay: true,
              aspectRatio: 16 / 9,
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: true,
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              viewportFraction: 0.8,
            ),
            items: projects.map((project) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF005088), // Azul oscuro
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        project.area,
                        style: TextStyle(fontSize: 24.0, color: Colors.white),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        }
      },
    );
  }
}

class SimilarInterestsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserProfile>>(
      future: ProfileController()
          .getUsersWithSimilarInterests(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No similar interests found.'));
        } else {
          List<UserProfile> users = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              UserProfile user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.foto != null
                      ? MemoryImage(user.foto!)
                      : AssetImage('lib/assets/default_avatar.png')
                          as ImageProvider,
                ),
                title: Text(user.name),
                subtitle: Text(user.mainStudyArea),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfileView(userProfile: user, isCurrentUser: false),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
