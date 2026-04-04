class Message {
  final String id;
  final String content;
  final MessageSender sender; // user or ai
  final DateTime timestamp;
  final MessageType type; // text, voice, suggestion

  Message({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.type = MessageType.text,
  });

  Message copyWith({
    String? id,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    MessageType? type,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }
}

enum MessageSender {
  user,
  ai,
}

enum MessageType {
  text,
  voice,
  suggestion,
}
