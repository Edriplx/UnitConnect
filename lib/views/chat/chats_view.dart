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

class _ChatsViewState extends State<ChatsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Stream<List<Chat>> _chatsStream;
  late ProfileController userController;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _chatsStream = widget.chatController.getUserChats(FirebaseAuth.instance.currentUser!.uid);
    userController = ProfileController();
  }

  @override
  void dispose() {
    _mounted = false;
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Solicitudes'),
            Tab(text: 'Chats Activos'),
          ],
        ),
      ),
      body: StreamBuilder<List<Chat>>(
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

          final allChats = snapshot.data!.where((chat) => !(chat.isDeleted ?? false)).toList();
          return TabBarView(
            controller: _tabController,
            children: [
              _buildChatList(allChats, isRequest: true),
              _buildChatList(allChats, isRequest: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatList(List<Chat> allChats, {required bool isRequest}) {
    final chats = allChats.where((chat) => 
      isRequest ? !chat.isAccepted : chat.isAccepted
    ).toList();

    if (chats.isEmpty) {
      return Center(child: Text(isRequest ? 'No hay solicitudes de chat.' : 'No hay chats activos.'));
    }

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) => _buildChatTile(context, chats[index], isRequest),
    );
  }

  Widget _buildChatTile(BuildContext context, Chat chat, bool isRequest) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final otherUserId = chat.user1Id == currentUserId ? chat.user2Id : chat.user1Id;

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
          title: Text(otherUser.name),
          subtitle: Text(isRequest ? 'Solicitud de chat' : 'Chat activo'),
          trailing: isRequest ? _buildRequestActions(context, chat) : null,
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

  void _handleChatAction(BuildContext context, Chat chat, bool accept) async {
    if (!_mounted) return;
    try {
      if (accept) {
        await widget.chatController.acceptChat(chat.id);
      } else {
        await widget.chatController.deletedChat(chat.id);
         Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('Error al manejar la acción del chat: $e');
    }
  }

  void _openChat(BuildContext context, String chatId, UserProfile otherUser) {
    if (!_mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatView(chatId: chatId, otherUserProfile: otherUser),
      ),
    );
  }
}