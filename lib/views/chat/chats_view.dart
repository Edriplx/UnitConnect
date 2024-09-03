import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/chat_model.dart';
import '../../controllers/chat_controller.dart';
import '../../models/user_model.dart';
import '../../controllers/user_controller.dart';
import 'chat_view.dart';

class ChatsView extends StatefulWidget {
  final ChatController chatController;

  ChatsView({Key? key, required this.chatController}) : super(key: key);

  @override
  _ChatsViewState createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Stream<List<Chat>> _chatsStream;
  late ProfileController userController;
  bool _mounted = true;
  List<Chat>? _cachedChats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _chatsStream = widget.chatController
        .getUserChats(FirebaseAuth.instance.currentUser!.uid);
    userController = ProfileController();

    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_mounted) {
      setState(() {
        // Forzar una actualización de la UI cuando cambia la pestaña
      });
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mensajes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30, // Tamaño del texto aumentado
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white, // Color de la línea de selección
          labelColor: Colors.white, // Color del texto seleccionado
          unselectedLabelColor:
              Colors.grey[300], // Color del texto no seleccionado
          tabs: [
            Tab(
              text: 'Solicitudes',
              icon: Icon(Icons.request_page), // Icono opcional
            ),
            Tab(
              text: 'Chats Activos',
              icon: Icon(Icons.chat_bubble_outline), // Icono opcional
            ),
          ],
        ),
        backgroundColor:
            Color.fromARGB(255, 65, 142, 181), // Color de fondo del AppBar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 170, 210, 233),
              Color(0xFFD5D2D1),
              Color.fromARGB(255, 170, 210, 233),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<List<Chat>>(
          stream: _chatsStream,
          builder: (context, snapshot) {
            if (!_mounted) return Container();
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay chats disponibles.'));
            }

            _cachedChats = snapshot.data!
                .where((chat) => !(chat.isDeleted ?? false))
                .toList();
            return TabBarView(
              controller: _tabController,
              children: [
                _buildChatList(isRequest: true),
                _buildChatList(isRequest: false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChatList({required bool isRequest}) {
    if (_cachedChats == null) {
      return Center(child: CircularProgressIndicator());
    }

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final chats = _cachedChats!
        .where((chat) => isRequest
            ? !chat.isAccepted && chat.user2Id == currentUserId
            : chat.isAccepted)
        .toList();

    if (chats.isEmpty) {
      return Center(
          child: Text(isRequest
              ? 'No hay solicitudes de chat.'
              : 'No hay chats activos.'));
    }

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) =>
          _buildChatTile(context, chats[index], isRequest),
    );
  }

  Widget _buildChatTile(BuildContext context, Chat chat, bool isRequest) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final otherUserId =
        chat.user1Id == currentUserId ? chat.user2Id : chat.user1Id;

    return FutureBuilder<UserProfile?>(
      future: userController.getProfile(otherUserId),
      builder: (context, userSnapshot) {
        if (!_mounted) return Container();
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return ListTile(title: Text('Cargando...'));
        }
        if (userSnapshot.hasError || !userSnapshot.hasData) {
          return ListTile(title: Text('Error al cargar el perfil'));
        }
        final otherUser = userSnapshot.data!;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: otherUser.foto != null
                ? MemoryImage(otherUser.foto!)
                : AssetImage('lib/assets/default_avatar.png') as ImageProvider,
          ),
          title: Text(
            otherUser.name,
            style: TextStyle(
              fontSize: 18, // Aumentar el tamaño del texto
              fontWeight: FontWeight.bold, // Negrita para destacar el nombre
            ),
          ),
          subtitle: Text(
            isRequest ? 'Solicitud de chat' : 'Chat activo',
            style: TextStyle(fontSize: 16),
          ),
          trailing: isRequest
              ? _buildRequestActions(context, chat)
              : _buildDeleteAction(context, chat),
          onTap: () => _openChat(context, chat.id, otherUser),
        );
      },
    );
  }

  Widget _buildRequestActions(BuildContext context, Chat chat) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.check, color: Colors.green),
          onPressed: () => _handleChatAction(context, chat, true),
        ),
        IconButton(
          icon: Icon(Icons.close, color: Colors.red),
          onPressed: () => _handleChatAction(context, chat, false),
        ),
      ],
    );
  }

  Widget _buildDeleteAction(BuildContext context, Chat chat) {
    return IconButton(
      icon: Icon(Icons.delete, color: Colors.red),
      onPressed: () => _handleChatAction(context, chat, false),
    );
  }

  void _handleChatAction(BuildContext context, Chat chat, bool accept) async {
    if (!_mounted) return;
    try {
      if (accept) {
        await widget.chatController.acceptChat(chat.id);
        // Actualizar el chat en la caché local
        final index = _cachedChats?.indexWhere((c) => c.id == chat.id) ?? -1;
        if (index != -1) {
          setState(() {
            _cachedChats![index] = chat.copyWith(isAccepted: true);
          });
        }
      } else {
        await widget.chatController.deletedChat(chat.id);
        // Eliminar el chat de la caché local
        setState(() {
          _cachedChats?.removeWhere((c) => c.id == chat.id);
        });
      }
    } catch (e) {
      print('Error al manejar la acción del chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error al procesar la acción. Por favor, intenta de nuevo.')),
      );
    }
  }

  void _openChat(BuildContext context, String chatId, UserProfile otherUser) {
    if (!_mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatView(chatId: chatId, otherUserProfile: otherUser),
      ),
    );
  }
}
