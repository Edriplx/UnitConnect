import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/user_model.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import '../../controllers/chat_controller.dart';
import '../usuario/profile_view.dart';

class ChatView extends StatefulWidget {
  final String chatId;
  final UserProfile otherUserProfile;

  ChatView({required this.chatId, required this.otherUserProfile});

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ChatController _chatController = ChatController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Stream<List<Message>> _messagesStream;
  bool _isAccepted = false;

  @override
  void initState() {
    super.initState();
    _messagesStream = _chatController.getChatMessages(widget.chatId);
    _checkChatStatus();
  }

  void _checkChatStatus() async {
    final chatSnapshot = await FirebaseDatabase.instance
        .ref()
        .child('chats/${widget.chatId}')
        .get();
    if (chatSnapshot.exists) {
      final chatData = chatSnapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _isAccepted = chatData['isAccepted'] ?? false;
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final message = Message(
        id: '',
        senderId: FirebaseAuth.instance.currentUser!.uid,
        text: _messageController.text,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      _chatController.sendMessage(widget.chatId, message);
      _messageController.clear();
      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherUserProfile.foto != null
                  ? MemoryImage(widget.otherUserProfile.foto!)
                  : AssetImage('lib/assets/default_avatar.png')
                      as ImageProvider,
              radius: 30, // Tamaño aumentado del avatar
            ),
            SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileView(userProfile: widget.otherUserProfile),
                  ),
                );
              },
              child: Text(
                widget.otherUserProfile.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30, // Tamaño del texto aumentado
                ),
              ),
            ),
          ],
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
                  Color.fromARGB(255, 170, 210, 233),
                  Color(0xFFD5D2D1),
                  Color.fromARGB(255, 170, 210, 233),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              if (!_isAccepted)
                Container(
                  padding: EdgeInsets.all(16.0), // Aumentado el padding
                  color: const Color.fromRGBO(242, 181, 68, 1),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Chat pendiente de aceptación',
                          style: TextStyle(
                              fontSize: 18), // Tamaño del texto aumentado
                        ),
                      ),
                      SizedBox(width: 12), // Espacio adicional
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Solicitud de chat enviada'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Text('Aceptar',
                            style: TextStyle(
                                fontSize: 18)), // Tamaño del texto aumentado
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: StreamBuilder<List<Message>>(
                  stream: _messagesStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final messages = snapshot.data!;
                    return ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId ==
                            FirebaseAuth.instance.currentUser!.uid;
                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16), // Ajustado margen
                            padding: EdgeInsets.all(16), // Aumentado el padding
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue[100] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(
                                  16), // Borde más redondeado
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                  fontSize: 18), // Tamaño del texto aumentado
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0), // Aumentado el padding
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12), // Borde redondeado
                          ),

                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16), // Aumentado el padding interno
                        ),
                        style: TextStyle(
                            fontSize: 18), // Tamaño del texto aumentado
                      ),
                    ),
                    SizedBox(width: 12), // Espacio adicional
                    IconButton(
                      icon: Icon(Icons.send,
                          size: 30), // Tamaño del ícono aumentado
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
