import 'package:firebase_database/firebase_database.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatController {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<String> createChat(String user1Id, String user2Id) async {
    final newChatRef = _database.child('chats').push();
    try {
      await newChatRef.set({
        'user1Id': user1Id,
        'user2Id': user2Id,
        'isAccepted': false,
        'isDeleted': false,
      });
      print('Chat creado con ID: ${newChatRef.key}');
      return newChatRef.key!;
    } catch (e) {
      print('Error al crear el chat: $e');
      rethrow;
    }
  }

  Future<void> acceptChat(String chatId) async {
    try {
      await _database.child('chats/$chatId').update({'isAccepted': true});
      print('Chat $chatId aceptado');
    } catch (e) {
      print('Error al aceptar el chat: $e');
      rethrow;
    }
  }

  Future<void> sendMessage(String chatId, Message message) async {
    try {
      await _database.child('messages/$chatId').push().set(message.toMap());
      print('Mensaje enviado en el chat $chatId');
    } catch (e) {
      print('Error al enviar el mensaje: $e');
      rethrow;
    }
  }

  Stream<List<Chat>> getUserChats(String userId) {
    return _database.child('chats').onValue.map((event) {
      final chatsMap = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return chatsMap.entries
          .where((entry) =>
              entry.value['user1Id'] == userId ||
              entry.value['user2Id'] == userId)
          .map((entry) =>
              Chat.fromMap(entry.key, Map<String, dynamic>.from(entry.value)))
          .toList();
    });
  }

  Future<void> deletedChat(String chatId) async {
    try {
      await _database.child('chats/$chatId').update({'isDeleted': true});
      print('Chat $chatId borrado');
    } catch (e) {
      print('Error al borrar el chat: $e');
      rethrow;
    }
  }

  Stream<List<Message>> getChatMessages(String chatId) {
    return _database.child('messages/$chatId').onValue.map((event) {
      final messagesMap = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return messagesMap.entries
          .map((entry) => Message.fromMap(
              entry.key, Map<String, dynamic>.from(entry.value)))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  Future<bool> hasActiveChat(String user1Id, String user2Id) async {
    try {
      final snapshot = await _database.child('chats').get();
      if (snapshot.exists) {
        final chatsMap = snapshot.value as Map<dynamic, dynamic>;
        return chatsMap.values.any((chat) =>
            ((chat['user1Id'] == user1Id && chat['user2Id'] == user2Id) ||
            (chat['user1Id'] == user2Id && chat['user2Id'] == user1Id)) &&
            !(chat['isDeleted'] ?? false));
      }
      return false;
    } catch (e) {
      print('Error al verificar chat activo: $e');
      return false;
    }
  }
}