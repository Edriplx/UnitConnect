class Chat {
  final String id;
  final String user1Id;
  final String user2Id;
  final bool isAccepted;
  final bool isDeleted;

  Chat({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.isAccepted = false,
    this.isDeleted = false,
  });

  factory Chat.fromMap(String id, Map<String, dynamic> data) {
    return Chat(
      id: id,
      user1Id: data['user1Id'] ?? '',
      user2Id: data['user2Id'] ?? '',
      isAccepted: data['isAccepted'] ?? false,
      isDeleted: data['isAccepted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'isAccepted': isAccepted,
      'isDeleted': isDeleted,
    };
  }
}