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

  // Método copyWith para crear una copia del objeto Chat con campos modificados
  Chat copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    bool? isAccepted,
    bool? isDeleted,
  }) {
    return Chat(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      isAccepted: isAccepted ?? this.isAccepted,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  // Factory para crear una instancia de Chat a partir de un Map
  factory Chat.fromMap(String id, Map<String, dynamic> data) {
    return Chat(
      id: id,
      user1Id: data['user1Id'] ?? '',
      user2Id: data['user2Id'] ?? '',
      isAccepted: data['isAccepted'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  // Método para convertir una instancia de Chat a un Map
  Map<String, dynamic> toMap() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'isAccepted': isAccepted,
      'isDeleted': isDeleted,
    };
  }
}
