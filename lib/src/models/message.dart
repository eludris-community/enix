class Message {
  final String author;
  final String content;

  Message({required this.author, required this.content});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(author: json['author'], content: json['content']);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'author': author,
      'content': content,
    };
  }

  @override
  String toString() {
    return 'Message(author: $author, content: $content)';
  }
}
