class Task {
  String id; 
  String title;
  String description;
  String type;
  DateTime dateTime;
  bool isComplete;

  Task({
    this.id = '',
    required this.title,
    required this.description,
    required this.type,
    required this.dateTime,
    this.isComplete = false,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'dateTime': dateTime.toIso8601String(),
      'isComplete': isComplete,
    };
  }


  factory Task.fromMap(Map<String, dynamic> map, String documentId) {
    return Task(
      id: documentId, 
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      dateTime: DateTime.parse(map['dateTime']), 
      isComplete: map['isComplete'] ?? false,
    );
  }
  
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    DateTime? dateTime,
    bool? isComplete,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

