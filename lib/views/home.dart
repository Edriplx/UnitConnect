import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unitconnect/views/auth_view.dart';
import 'package:unitconnect/views/usuario/profile_view.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/user_model.dart';
import '../controllers/user_controller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final ProfileController _profileController = ProfileController();
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
        UserProfile? profile = await _profileController.getProfile(currentUser.uid);
        setState(() {
          _currentUserProfile = profile;
        });
      }
    } catch (e) {
      print("Error loading current user profile: $e");
      // Puedes mostrar un snackbar o un diálogo aquí para informar al usuario sobre el error
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
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Home' : 'Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => AuthPage()),
                );
              } catch (e) {
                print("Error al cerrar sesión: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al cerrar sesión')),
                );
              }
            },
          ),
        ],
      ),
      body: _getSelectedWidget(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              'Áreas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            AreaCarousel(areas: areas),
            SizedBox(height: 16),
            Text(
              'Mis Proyectos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ProjectCarousel(),
            SizedBox(height: 16),
            Text(
              'Intereses',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SimilarInterestsList(),
          ],
        ),
      ),
    );
  }
}

class AreaCarousel extends StatelessWidget {
  final List<String> areas;

  AreaCarousel({required this.areas});

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
      items: areas.map((area) {
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
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    area,
                    style: TextStyle(fontSize: 24.0, color: Colors.white),
                  ),
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
      appBar: AppBar(
        title: Text('Users in $area'),
      ),
      body: FutureBuilder<List<UserProfile>>(
        future: ProfileController().getUsersByArea(area),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users found in this area.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                UserProfile user = snapshot.data![index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.foto != null
                        ? MemoryImage(user.foto!)
                        : AssetImage('assets/default_avatar.png') as ImageProvider,
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.mainStudyArea),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileView(userProfile: user, isCurrentUser: false),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ProjectCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: ProfileController().getProfile(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.academicHistory.isEmpty) {
          return Text('No projects found.');
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
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          project.name,
                          style: TextStyle(fontSize: 24.0, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          project.area,
                          style: TextStyle(fontSize: 16.0, color: Colors.white70),
                        ),
                      ],
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
      future: ProfileController().getUsersWithSimilarInterests(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No se encontraron usuarios con intereses similares.');
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              UserProfile user = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.foto != null
                      ? MemoryImage(user.foto!)
                      : AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                title: Text(user.name),
                subtitle: Text('${user.mainStudyArea}\n${user.skills.join(", ")}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileView(userProfile: user, isCurrentUser: false),
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